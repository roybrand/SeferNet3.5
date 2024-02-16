
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Helper_LongPrint]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Helper_LongPrint]
GO

CREATE PROCEDURE [dbo].[Helper_LongPrint]( @string nvarchar(max) )
AS
SET NOCOUNT ON
set @string = rtrim( @string )
declare @cr char(1), @lf char(1)
set @cr = char(13)
set @lf = char(10)

declare @len int, @cr_index int, @lf_index int, @crlf_index int, @has_cr_and_lf bit, @left nvarchar(4000), @reverse nvarchar(4000)

set @len = 4000

while ( len( @string ) > @len )
begin

set @left = left( @string, @len )
set @reverse = reverse( @left )
set @cr_index = @len - charindex( @cr, @reverse ) + 1
set @lf_index = @len - charindex( @lf, @reverse ) + 1
set @crlf_index = case when @cr_index < @lf_index then @cr_index else @lf_index end

set @has_cr_and_lf = case when @cr_index < @len and @lf_index < @len then 1 else 0 end

print left( @string, @crlf_index - 1 )

set @string = right( @string, len( @string ) - @crlf_index - @has_cr_and_lf )

end

print @string

GO

GRANT EXEC ON [dbo].[Helper_LongPrint] TO PUBLIC
GO

---------------------------------------------------------

IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'fun_GetAdditionalDistrictCodes')
	BEGIN
		DROP  FUNCTION  fun_GetAdditionalDistrictCodes
	END
GO

CREATE FUNCTION [dbo].[fun_GetAdditionalDistrictCodes] 
(
	@deptCode int
)
RETURNS varchar(500)

AS
	
BEGIN
	DECLARE  @AdditionalDistrictsCodes varchar(500)
	
	SET @AdditionalDistrictsCodes = ''
	SELECT @AdditionalDistrictsCodes = @AdditionalDistrictsCodes + CAST(districtCode as varchar(10)) + ','  
	FROM x_Dept_District
	WHERE deptCode = @deptCode

	IF(LEN(@AdditionalDistrictsCodes) > 0) 
		SET @AdditionalDistrictsCodes = LEFT(@AdditionalDistrictsCodes, LEN(@AdditionalDistrictsCodes) - 1)
						
	RETURN( @AdditionalDistrictsCodes )		
END

GO
 -- ******************************************************************************************************
 IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'fun_GetAdditionalDistrictNames')
	BEGIN
		DROP  FUNCTION  fun_GetAdditionalDistrictNames
	END
GO

CREATE FUNCTION [dbo].[fun_GetAdditionalDistrictNames] 
(
	@deptCode int
)
RETURNS varchar(500)

AS
	
BEGIN
	DECLARE  @AdditionalDistrictsNames varchar(500)
	
	SET @AdditionalDistrictsNames = ''
	SELECT @AdditionalDistrictsNames = @AdditionalDistrictsNames + CAST(districtName as varchar(100)) + ', '  
	FROM x_Dept_District
	JOIN View_AllDistricts ON x_Dept_District.districtCode = View_AllDistricts.districtCode
	WHERE deptCode = @deptCode

	IF(LEN(@AdditionalDistrictsNames) > 0) 
		SET @AdditionalDistrictsNames = LEFT(@AdditionalDistrictsNames, LEN(@AdditionalDistrictsNames) - 1)
						
	RETURN( @AdditionalDistrictsNames )		
END

GO
-- ****************************************************************************************************** 
 
IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'fun_StingToTable_DeptNames')
	BEGIN
		DROP  FUNCTION  fun_StingToTable_DeptNames
	END

GO

CREATE FUNCTION [dbo].[fun_StingToTable_DeptNames]
(
	@InputStr varchar(1000),
	@DeptCode int,
	@UpdateUser varchar(50)
)
RETURNS 
/*@ResultTable has the structure of "DeptNames" table
@InputStr has "records" separated with ';' and "field" separated with ','
the fields are: deptName, fromDate
*/
@ResultTable table
(
	deptCode int,
	deptName varchar(100),
	fromDate smalldatetime,
	updateDate smalldatetime,
	updateUser varchar(50)
)
AS

BEGIN

	DECLARE @DeptName varchar(100)
	DECLARE @FromDate varchar(30)
	DECLARE @TableRow varchar(500)
	DECLARE @Index int
	DECLARE @RowSeparatorPosition int

	
	SET @InputStr = LTRIM(RTRIM(@InputStr)) + ';'
	SET @RowSeparatorPosition = CHARINDEX(';', @InputStr, 1)
	
	IF REPLACE(REPLACE(@InputStr, ',', ''), ';', '') <> ''
	BEGIN
		WHILE @RowSeparatorPosition > 0
		BEGIN
			SET @TableRow = LTRIM(RTRIM(LEFT(@InputStr, @RowSeparatorPosition - 1)))
			IF REPLACE(@TableRow, ',', '') <> ''
			BEGIN
				SET @TableRow = LTRIM(RTRIM(@TableRow))+ ','
				SET @Index = CHARINDEX(',', @TableRow, 1)
				
				SET @DeptName = LTRIM(RTRIM(LEFT(@TableRow, @Index - 1)))
				SET @TableRow = RIGHT(@TableRow, LEN(@TableRow) - @Index)
				SET @Index = CHARINDEX(',', @TableRow, 1)

				SET @FromDate = LTRIM(RTRIM(LEFT(@TableRow, @Index - 1)))
				SET @TableRow = RIGHT(@TableRow, LEN(@TableRow) - @Index)
				--SET @Index = CHARINDEX(',', @TableRow, 1)
				
				IF @DeptName <> '' AND @FromDate <> ''
				BEGIN
					INSERT INTO @ResultTable (deptCode, deptName, fromDate, updateDate, updateUser) 
					VALUES (@DeptCode, @DeptName, CONVERT(smalldatetime, @FromDate, 103), getdate(), @UpdateUser) 
				END
			END
			
			SET @InputStr = RIGHT(@InputStr, LEN(@InputStr) - @RowSeparatorPosition)
			SET @RowSeparatorPosition = CHARINDEX(';', @InputStr, 1)
			
		END
	END
	RETURN
END
GO

GRANT select ON fun_StingToTable_DeptNames TO PUBLIC
GO
-- ******************************************************************************************************

IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'GetAddress')
	BEGIN
		PRINT 'Dropping Function GetAddress'
		DROP  Function  GetAddress
	END
GO

PRINT 'Creating Function GetAddress'
GO     
CREATE FUNCTION [dbo].[GetAddress]
(
	@DeptCode int
)
RETURNS varchar(600)

AS
BEGIN
	DECLARE @Address varchar(600)
	DECLARE @Index int
    DECLARE @apostraphe varchar(10)
    --set @apostraphe = escape "\"
	SET @Address = (
		--SELECT CASE ISNULL(LEN(dept.StreetCode),'0') WHEN '0' THEN '' ELSE /*'רח' + '''' + ' '+*/ RTRIM(LTRIM(streetName)) END
		SELECT CASE ISNULL(LEN(dept.streetName),'0') WHEN '0' THEN '' ELSE  RTRIM(LTRIM(streetName)) END
			+ CASE ISNULL(LEN(house),'0') WHEN '0' THEN '' ELSE ' ' + house END 
			+ CASE ISNULL(LEN(floor),'0') WHEN '0' THEN '' ELSE ', קומה ' + floor END
			+ CASE ISNULL(LEN(flat),'0') WHEN '0' THEN '' ELSE ', חדר ' + flat END
			+ ISNULL(CASE WHEN dept.IsSite = 1 THEN Atarim.InstituteName ELSE Neighbourhoods.NybName END, '')
			+ CASE ISNULL(LEN(addressComment),'0') WHEN '0' THEN '' ELSE ', ' + addressComment END
		FROM dept
		LEFT JOIN Atarim ON dept.NeighbourhoodOrInstituteCode = Atarim.InstituteCode
		LEFT JOIN Neighbourhoods ON dept.NeighbourhoodOrInstituteCode = Neighbourhoods.NeighbourhoodCode
		WHERE deptCode = @DeptCode
		)

	IF CHARINDEX(',', @Address, 1) = 1	/* clear ',' at first position */
		BEGIN
			SET @Address = SUBSTRING( @Address, 2, LEN(@Address) - 1 )
		END
	IF ISNUMERIC(@Address) = 1	/* reasonable address can't be just a number*/
		BEGIN
			SET @Address = ''
		END
	RETURN (CASE CAST(ISNULL(@Address,0) as varchar(600)) WHEN '0' THEN '' ELSE @Address END)
END

GO


GRANT EXEC ON GetAddress TO PUBLIC
GO
-- *******************************************************************************************************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeeServiceQueueOrderMethods')
	BEGIN
		DROP  Procedure  rpc_getEmployeeServiceQueueOrderMethods
	END
GO

CREATE PROCEDURE [dbo].[rpc_getEmployeeServiceQueueOrderMethods]

	@x_Dept_Employee_ServiceID int

AS

	SELECT xDES.QueueOrder, ESQOM.QueueOrderMethod, 
	'DeptPhone' = dbo.fun_ParsePhoneNumberWithExtension(DeptPhones.prePrefix, DeptPhones.prefix, DeptPhones.phone, DeptPhones.extension),
	queuePhones.prePrefix, DIC.prefixCode, DIC.prefixValue as PrefixText, queuePhones.phone, queuePhones.extension
	FROM x_Dept_Employee_Service xdes
	LEFT JOIN EmployeeServiceQueueOrderMethod esqom ON xdes.x_Dept_Employee_ServiceID = esqom.x_dept_employee_serviceID 		
	INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
	LEFT JOIN DeptPhones ON deptPhones.DeptCode = xd.deptCode AND PhoneType = 1 AND PhoneOrder = 1 AND QueueOrderMethod = 1
	LEFT JOIN EmployeeServiceQueueOrderPhones queuePhones ON ESQOM.EmployeeServiceQueueOrderMethodID = queuePhones.EmployeeServiceQueueOrderMethodID
	LEFT JOIN DIC_PhonePrefix DIC ON queuePhones.prefix = DIC.prefixCode
	WHERE xDES.x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID

	SELECT EmployeeServiceQueueOrderHoursID as QueueOrderHoursID,
	ReceptionDay, FromHour as OpeningHour, ToHour as ClosingHour,
	'NumOfSessionsPerDay' = (
		SELECT COUNT(*)
		FROM EmployeeServiceQueueOrderMethod ESQOM2
		INNER JOIN EmployeeServiceQueueOrderHours ESQOH2 ON ESQOM2.EmployeeServiceQueueOrderMethodID = ESQOH2.EmployeeServiceQueueOrderMethodID
		AND ESQOH.ReceptionDay = ESQOH2.ReceptionDay
		GROUP BY ReceptionDay
		)
	FROM EmployeeServiceQueueOrderMethod ESQOM
	INNER JOIN EmployeeServiceQueueOrderHours ESQOH ON ESQOM.EmployeeServiceQueueOrderMethodID = ESQOH.EmployeeServiceQueueOrderMethodID
	
	INNER JOIN x_Dept_Employee_Service xDES ON ESQOM.x_dept_employee_serviceID = xDES.x_Dept_Employee_ServiceID		
	WHERE xDES.x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID
GO

GRANT EXEC ON rpc_getEmployeeServiceQueueOrderMethods TO PUBLIC
GO


IF EXISTS (SELECT * FROM sysobjects WHERE name = 'fun_GetEmployeeServiceSector')
	BEGIN
		DROP  FUNCTION  fun_GetEmployeeServiceSector
	END
GO

CREATE FUNCTION [dbo].[fun_GetEmployeeServiceSector] (@employeeID bigint, @ServiceCode int)
RETURNS varchar(100)
WITH EXECUTE AS CALLER
AS
BEGIN
	
	DECLARE @Sector int SET @Sector = 0

	SET @Sector = 
		(SELECT SectorToShowWith FROM [Services] WHERE [Services].ServiceCode = @ServiceCode )
		
	IF @Sector IS NULL
		SET @Sector = 
			(SELECT EmployeeSectorCode FROM Employee WHERE employeeID = @employeeID )
			
	RETURN @Sector

END
GO

grant exec on fun_GetEmployeeServiceSector to public 
go 

-- changes of SP's and functions because DeptEmployeeID column
-- changed by Ran

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_GetDeptEmployeePhones')
	BEGIN
		DROP  function  fun_GetDeptEmployeePhones
	END
GO

CREATE FUNCTION [dbo].[fun_GetDeptEmployeePhones]
(
	@EmployeeID int,
	@DeptCode int
)
RETURNS varchar(500)
AS
BEGIN
 
    DECLARE @p_str VARCHAR(500)
    SET @p_str = ''
    
    SELECT @p_str = @p_str + dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) + ','
    FROM x_dept_employee xd
    INNER JOIN DeptPhones dp ON xd.DeptCode  = dp.DeptCode
    WHERE xd.DeptCode = @deptCode AND xd.EmployeeID = @employeeID 
    AND CascadeUpdateDeptEmployeePhonesFromClinic = 1
    ORDER BY dp.phoneType, dp.phoneOrder
    

	SELECT @p_str = @p_str + dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) + ','
	FROM x_dept_employee xd 
	INNER JOIN DeptEmployeePhones dep ON xd.deptEmployeeID = dep.DeptEmployeeID
	WHERE xd.deptCode = @DeptCode
	AND xd.employeeID = @EmployeeID
	ORDER BY dep.phoneType, dep.phoneOrder

	IF len(@p_str) > 1
	-- remove last comma
	BEGIN
		SET @p_str = SUBSTRING(@p_str, 0, len(@p_str))
	END
	
    RETURN @p_str

END

GO

grant exec on fun_GetDeptEmployeePhones to public 
GO    

-- *********************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_GetDeptEmployeePhonesOnly')
	BEGIN
		DROP  function  fun_GetDeptEmployeePhonesOnly
	END
GO

CREATE FUNCTION [dbo].[fun_GetDeptEmployeePhonesOnly]
(
	@EmployeeID int,
	@DeptCode int
) 
RETURNS varchar(500)
AS
BEGIN
 
    DECLARE @p_str VARCHAR(500)
    SET @p_str = ''
    
    SELECT @p_str = @p_str + dbo.fun_ParsePhoneNumberWithExtension(dp.prePrefix, dp.prefix, dp.phone, dp.extension) + ', '
	FROM x_dept_employee xd
	INNER JOIN DeptPhones dp on xd.DeptCode = dp.DeptCode
	WHERE xd.deptCode = @DeptCode
	AND xd.employeeID = @EmployeeID
	AND dp.phoneType <> 2 -- fax
	AND xd.CascadeUpdateDeptEmployeePhonesFromClinic = 1
	ORDER BY dp.phoneType, phoneOrder
    
    
	SELECT @p_str = @p_str + dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) + ', '
	FROM x_dept_Employee xd
	INNER JOIN DeptEmployeePhones dep on xd.DeptEmployeeID = dep.DeptEmployeeID	
	WHERE xd.deptCode = @DeptCode
	AND xd.employeeID = @EmployeeID
	AND dep.phoneType <> 2 -- fax
	AND xd.CascadeUpdateDeptEmployeePhonesFromClinic = 0
	ORDER BY dep.phoneType, phoneOrder
	

	IF len(@p_str) > 1
	-- remove last comma
	BEGIN
		SET @p_str = SUBSTRING(@p_str, 0, len(@p_str))
	END
	
    RETURN @p_str

END
GO

grant exec on fun_GetDeptEmployeePhonesOnly to public 
GO    


--  ***********************
 
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_GetDeptEmployeeFax')
	BEGIN
		DROP  function  fun_GetDeptEmployeeFax
	END
GO

CREATE FUNCTION [dbo].[fun_GetDeptEmployeeFax]
(
	@EmployeeID int,
	@DeptCode int
)
RETURNS varchar(500)
AS
BEGIN
 
    DECLARE @p_str VARCHAR(500)
    SET @p_str = ''
    
    SELECT @p_str = @p_str + dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) + ','
    FROM x_dept_employee xd
    INNER JOIN DeptPhones dp ON xd.DeptCode = dp.DeptCode
    WHERE xd.DeptCode = @deptCode AND xd.EmployeeID = @employeeID
    AND CascadeUpdateDeptEmployeePhonesFromClinic = 1
    AND PhoneType = 2
    ORDER BY phoneType, phoneOrder
    
        

	SELECT @p_str = @p_str + dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) + ', '
	FROM x_dept_employee xd
    INNER JOIN DeptEmployeePhones dep on xd.DeptEmployeeID = dep.DeptEmployeeID
	WHERE xd.deptCode = @DeptCode
	AND xd.employeeID = @EmployeeID
	AND phoneType = 2 -- fax
	ORDER BY phoneType, phoneOrder

	IF len(@p_str) > 1
	-- remove last comma
	BEGIN
		SET @p_str = SUBSTRING(@p_str, 0, len(@p_str))
	END
	
    RETURN @p_str

END
GO
  
grant exec on fun_GetDeptEmployeeFax to public 
GO 

-- ***************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'v_EmployeeReceptionByServiceAndProfession')
	BEGIN
		DROP  view  v_EmployeeReceptionByServiceAndProfession
	END
GO

CREATE VIEW [dbo].[v_EmployeeReceptionByServiceAndProfession]
AS 

SELECT DISTINCT 
        xd.EmployeeID, der.receptionID, xd.deptCode, Dept.deptName, Dept.cityCode, Cities.cityName, der.receptionDay, der.openingHour, 
        der.closingHour, der.validFrom, der.validTo, derr.RemarkID, derr.RemarkText, 
		CASE WHEN s.IsService = 1 THEN 'service' ELSE 'profession' END AS ItemType, 
 		s.ServiceDescription AS ItemDesc,	 
		s.servicecode AS ItemID,
		deptEmployeeReceptionServicesID AS ItemRecID
FROM    deptEmployeeReception AS der 
		LEFT JOIN DeptEmployeeReceptionRemarks AS derr ON der.receptionID = derr.EmployeeReceptionID 
		INNER JOIN x_dept_employee xd ON der.DeptEmployeeID = xd.DeptEmployeeID
		INNER JOIN Dept ON xd.deptCode = Dept.deptCode 
		INNER JOIN Cities ON Dept.cityCode = Cities.cityCode 
		LEFT JOIN deptEmployeeReceptionServices AS ders ON der.receptionID = ders.receptionID 
		LEFT JOIN x_Dept_Employee_Service AS xdes  ON (ders.serviceCode = xdes.serviceCode OR ders.serviceCode IS NULL) 
																					AND xd.DeptEmployeeID = xdes.DeptEmployeeID			
        INNER JOIN dbo.[Services] AS s ON ders.serviceCode = s.ServiceCode OR ders.serviceCode IS NULL 
WHERE     (ders.receptionID IS NOT NULL) AND (xdes.serviceCode IS NOT NULL) 

GO

-- ***************************

IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'fun_getAdminManagerName')
	BEGIN
		DROP  FUNCTION  fun_getAdminManagerName
	END
GO

CREATE FUNCTION [dbo].[fun_getAdminManagerName] 
(
	@deptCode int
)
RETURNS varchar(500)

AS
	
BEGIN
	DECLARE  @strManagerName varchar(500)
	
	SET @strManagerName = (SELECT TOP 1 DegreeName + ' ' + lastName + ' ' + firstName
						FROM employee
						INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode
						INNER JOIN x_dept_employee xd ON employee.employeeID = xd.employeeID
						INNER JOIN x_Dept_Employee_Position ON xd.DeptEmployeeID = x_Dept_Employee_Position.DeptEmployeeID							
						INNER JOIN mappingPositions ON x_Dept_Employee_Position.positionCode = mappingPositions.positionCode
						WHERE xd.DeptCode = @deptCode
						AND mappingPositions.mappedToAdministrativeManager = 1)							
							
	
	IF(@strManagerName = '' or @strManagerName is null )						
	BEGIN
		SET @strManagerName = (SELECT administrativeManagerName FROM Dept WHERE deptCode = @deptCode)
	END
							
	RETURN( @strManagerName )		
END

GO
 
 
-- ***************************
 
IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[dbo].[fun_getPharmacologyManagerName]') and xtype in (N'FN', N'IF', N'TF'))
	DROP FUNCTION [dbo].[fun_getPharmacologyManagerName]
GO

CREATE FUNCTION [dbo].[fun_getPharmacologyManagerName]
(
	@DeptCode int
)

RETURNS varchar(100)

AS
BEGIN
	DECLARE  @strPharmacologyManagerName varchar(100)
	SET @strPharmacologyManagerName = ''
	
	set @strPharmacologyManagerName = 
		(SELECT  TOP 1 DegreeName + ' ' + lastName + ' ' + firstName
			FROM employee
			INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode
			INNER JOIN x_dept_employee xd ON employee.employeeID = xd.employeeID
			INNER JOIN x_Dept_Employee_Position pos ON xd.DeptEmployeeID = pos.DeptEmployeeID
			AND pos.positionCode = 59 -- רוקח אחראי
			WHERE xd.DeptCode = @deptCode
		)			
							
	IF(@strPharmacologyManagerName is null OR @strPharmacologyManagerName = '')						
	begin
		 SET @strPharmacologyManagerName = 
		 (
			SELECT TOP 1 DegreeName + ' ' + lastName + ' ' + firstName 
			FROM dept 
			JOIN x_Dept_Employee ON dept.deptCode = x_Dept_Employee.deptCode
			JOIN employee ON x_Dept_Employee.employeeID = employee.employeeID
			JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode
			JOIN x_Dept_Employee_Position pos ON x_Dept_Employee.DeptEmployeeID = pos.DeptEmployeeID				
				AND pos.positionCode = 59
			WHERE dept.subAdministrationCode = @deptCode
			AND dept.typeUnitCode = 401 -- בית מרקחת
		 )		
	end 
	
	IF(@strPharmacologyManagerName is null )	
		SET @strPharmacologyManagerName = ''					
	
	RETURN( @strPharmacologyManagerName )		
END
GO
 
grant exec on fun_getPharmacologyManagerName to public 
GO

-- ***************************

 IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rfn_GetDeptEmployeeQueueOrderDescriptionsHTML')
	BEGIN
		DROP  FUNCTION  dbo.rfn_GetDeptEmployeeQueueOrderDescriptionsHTML
	END

GO

CREATE  function [dbo].rfn_GetDeptEmployeeQueueOrderDescriptionsHTML(@deptCode int, @employeeID bigint) 
RETURNS varchar(500)

WITH EXECUTE AS CALLER

AS
BEGIN

	declare @Str varchar(500) 
	set @Str = ''
	
	SELECT @Str = @Str + CASE @Str WHEN '' THEN '' ELSE ' | ' END +
		CASE QueueOrderMethod 
			WHEN 3 THEN '<span dir="ltr">*2700</span>' 
			WHEN 4 THEN '@' 
			WHEN 5 THEN '<span style=' + CHAR(39)+ 'font-family:"Webdings"; font-size:16px' + CHAR(39) + '>' + CHAR(72) + '</span>' 
			ELSE '<span style=' + CHAR(39)+ 'font-family:"Wingdings 2"; font-size:16px' + CHAR(39) + '>' + CHAR(39) + '</span>' 
		END  
	FROM
		-- Using "distinct" because methods "1" & "2" both require "phone picture", but only one picture is needed
		(select DISTINCT CASE WHEN DIC_QOM.QueueOrderMethod <= 2 THEN 1 ELSE DIC_QOM.QueueOrderMethod END as 'QueueOrderMethod'
		FROM x_Dept_Employee as xDE
		join EmployeeQueueOrderMethod as eqom
			ON xDE.DeptEmployeeID = eqom.DeptEmployeeID				
		join DIC_QueueOrderMethod as DIC_QOM
			on EQOM.QueueOrderMethod = DIC_QOM.QueueOrderMethod
		WHERE xDE.deptCode = @deptCode
		and xDE.employeeID = @employeeID
		and xDE.QueueOrder = 3 -- "זימון באמצעות:"
		) 
		as d 
	order by d.QueueOrderMethod

	SELECT @Str = @Str + QueueOrderDescription
	FROM x_Dept_Employee as xDE
	JOIN DIC_QueueOrder ON xDE.QueueOrder = DIC_QueueOrder.QueueOrder
		AND DIC_QueueOrder.PermitOrderMethods = 0
		AND xDE.deptCode = @deptCode
		AND xDE.employeeID = @employeeID

	
	IF (@Str = '')
	BEGIN
		SET @Str = '&nbsp;'
	END
	return (@Str)
end 

go 

grant exec on dbo.rfn_GetDeptEmployeeQueueOrderDescriptionsHTML to public 
go

-- ***************************************

go
IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rfn_GetDeptEmployeeQueueOrderDescriptions')
	BEGIN
		DROP  FUNCTION  dbo.rfn_GetDeptEmployeeQueueOrderDescriptions
	END

GO

--case @deptCode = -1  -- means all depts
--case @employeeID = -1  -- means all employees
create  function [dbo].rfn_GetDeptEmployeeQueueOrderDescriptions(@deptCode bigint, @employeeID bigint) 
RETURNS varchar(500)

WITH EXECUTE AS CALLER

AS
BEGIN 

	declare @Str varchar(500) 
	set @Str = ''
	
	SELECT @Str = @Str + d.QueueOrderMethodDescription + '; ' 
	FROM
		(select distinct DIC_QOM.QueueOrderMethodDescription, DIC_QOM.QueueOrderMethod
		FROM x_Dept_Employee as xDE
		join EmployeeQueueOrderMethod  as eqom
			ON xDE.deptEmployeeID = eqom.DeptEmployeeID						
		join DIC_QueueOrderMethod as DIC_QOM
			on EQOM.QueueOrderMethod = DIC_QOM.QueueOrderMethod
		WHERE (@deptCode = -1 or xDE.deptCode = @deptCode)
		  and (@employeeID = -1 or xDE.employeeID = @employeeID)
		  and (xDE.QueueOrder = 3)-- "זימון באמצעות:"
		) 
		as d 
	order by d.QueueOrderMethod
	
	IF(LEN(@Str)) > 0 -- to remove last ','
		BEGIN
			SET @Str = Left( @Str, LEN(@Str) -1 )
		END
		
	return (@Str);
end 

go 

grant exec on dbo.rfn_GetDeptEmployeeQueueOrderDescriptions to public 
go

-- ***************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fun_GetEmployeeInDeptPositions]
(
	@EmployeeID int,
	@DeptCode int,
	@Sex int
)
RETURNS varchar(500)
AS
BEGIN
 
    DECLARE @p_str VARCHAR(500)
    SET @p_str = ''
    
    SET @Sex = IsNull(@Sex, 1)
    IF @Sex = 0
		BEGIN
			SET @Sex = 1
		END

    SELECT @p_str = @p_str + position.positionDescription + ','

	FROM x_Dept_Employee_Position
	INNER JOIN position ON x_Dept_Employee_Position.positionCode = position.positionCode
	INNER JOIN x_dept_employee xd ON x_Dept_Employee_Position.DeptEmployeeID = xd.DeptEmployeeID
	WHERE xd.employeeID = @EmployeeID
	AND xd.deptCode = @DeptCode
	AND position.gender = @Sex
	
	IF len(@p_str) > 1
	-- remove last comma
	BEGIN
		SET @p_str = SUBSTRING(@p_str, 0, len(@p_str))
	END

    RETURN @p_str

END
GO



         
-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptDetailsForUpdate')
	BEGIN
		DROP  Procedure  rpc_getDeptDetailsForUpdate
	END

GO

CREATE Procedure [dbo].[rpc_getDeptDetailsForUpdate]
	(
		@deptCode int
	)

AS

DECLARE @ExpirationDate datetime = DATEADD(day, DATEDIFF(day, 0, getdate()), 0) 
DECLARE @DateAfterExpiration datetime
SET @DateAfterExpiration = DATEADD(day, 1, DATEADD(day, DATEDIFF(day, 0, getdate()), 0))


--- DeptDetails --------------------------------------------------------
SELECT
-- FIRST SECTION on page --------------------------------------------------------
D.deptName,
D.deptType, -- 1, 2, 3
DIC_DeptTypes.deptTypeDescription, -- מחוז, מנהלת, מרפאה
D.typeUnitCode, -- סוג יחידה
'subUnitTypeCode' = IsNull(D.subUnitTypeCode, -1), -- שיוך

D.deptLevel,
D.managerName,
'substituteManagerName' = IsNull((SELECT TOP 1 DegreeName + ' ' + lastName + ' ' + firstName
							FROM employee
							INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode
							INNER JOIN x_dept_employee ON employee.employeeID = x_dept_employee.employeeID
							INNER JOIN x_Dept_Employee_Position ON x_dept_employee.DeptEmployeeID = x_Dept_Employee_Position.DeptEmployeeID								
							INNER JOIN mappingPositions ON x_Dept_Employee_Position.positionCode = mappingPositions.positionCode
							WHERE mappingPositions.mappedToManager = 1
							AND x_Dept_Employee.deptCode = D.deptCode
							), ''),
D.administrativeManagerName,
'substituteAdministrativeManagerName' = IsNull((SELECT TOP 1 DegreeName + ' ' + lastName + ' ' + firstName
							FROM employee
							INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode
							INNER JOIN x_dept_employee ON employee.employeeID = x_dept_employee.employeeID
							INNER JOIN x_Dept_Employee_Position ON x_dept_employee.DeptEmployeeID = x_Dept_Employee_Position.DeptEmployeeID
							INNER JOIN mappingPositions ON x_Dept_Employee_Position.positionCode = mappingPositions.positionCode
							WHERE mappingPositions.mappedToAdministrativeManager = 1
							AND x_Dept_Employee.deptCode = D.deptCode
							), ''),

-- SECOND SECTION --------------------------------------------------------
D.cityCode,
Cities.cityName,
D.streetCode,
'streetName' = RTRIM(LTRIM(D.streetName)),
D.house,
D.flat,
D.floor,
D.addressComment,
D.email,
'showEmailInInternet' = CAST(IsNull(D.showEmailInInternet, 0) as bit),
D.NeighbourhoodOrInstituteCode,
D.IsSite,
CASE WHEN D.IsSite = 1 THEN Atarim.InstituteName ELSE Neighbourhoods.NybName END as NeighbourhoodOrInstituteName,

-- THIRD SECTION --------------------------------------------------------
D.transportation,
D.parking,

-- FORTH SECTION --------------------------------------------------------
'districtCode' = IsNull(D.districtCode, -1),
'additionaDistrictCodes' = dbo.fun_GetAdditionalDistrictCodes(@deptCode),
'additionaDistrictNames' = dbo.fun_GetAdditionalDistrictNames(@deptCode), 
'administrationCode' = IsNull(D.administrationCode, -1),				-- "מנהלות" 
'subAdministrationCode' = IsNull(D.subAdministrationCode, -1),
'subAdministrationName' = (SELECT dept.deptName 
							FROM dept
							WHERE dept.deptCode = D.subAdministrationCode),
'populationSectorCode' = IsNull(D.populationSectorCode, -1),
D.deptCode,
deptSimul.Simul228,
DIC_ActivityStatus.statusDescription,

-- FIFTH SECTION --------------------------------------------------------
deptSimul.deptNameSimul,
'statusSimul' = CASE deptSimul.statusSimul WHEN 1 THEN 'פתוח' ELSE 'סגור' END,
'openDateSimul'= CONVERT(varchar(10),openDateSimul,101),
'closingDateSimul'= CONVERT(varchar(10),closingDateSimul,101),
deptSimul.SimulManageDescription,

deptSimul.SugSimul501,
deptSimul.TatSugSimul502,
deptSimul.TatHitmahut503,
deptSimul.RamatPeilut504,
'SugSimulDesc' = SugSimul501.SimulDesc,
'TatSugSimulDesc' = TatSugSimul502.TatSugSimulDesc,
'TatHitmahutDesc' = TatHitmahut503.HitmahutDesc,
'RamatPeilutDesc' = RamatPeilut504.Teur,
'UnitTypeNameSimul' = UT.UnitTypeName,
 
'showUnitInInternet' = IsNull(D.showUnitInInternet, 1),
'AllowQueueOrder' = IsNull(UnitType.AllowQueueOrder, 0),
x_dept_XY.xcoord,
x_dept_XY.ycoord,
d.IsCommunity,
d.IsHospital,
d.IsMushlam

FROM dept as D
INNER JOIN DIC_DeptTypes ON D.deptType = DIC_DeptTypes.deptType	-- ??
INNER JOIN Cities ON D.cityCode = Cities.cityCode
INNER JOIN DIC_ActivityStatus ON D.status = DIC_ActivityStatus.status
LEFT JOIN deptSimul ON D.deptCode = deptSimul.deptCode
LEFT JOIN SugSimul501 ON deptSimul.SugSimul501 = SugSimul501.SugSimul
LEFT JOIN TatSugSimul502 ON deptSimul.TatSugSimul502 = TatSugSimul502.TatSugSimulId
	AND deptSimul.SugSimul501 = TatSugSimul502.SugSimul
LEFT JOIN TatHitmahut503 ON deptSimul.TatHitmahut503 = TatHitmahut503.TatHitmahut
	AND deptSimul.TatSugSimul502 = TatHitmahut503.TatSugSimulId
	AND deptSimul.SugSimul501 = TatHitmahut503.TatSugSimulId
LEFT JOIN RamatPeilut504 ON deptSimul.RamatPeilut504 = RamatPeilut504.RamatPeilut
	AND deptSimul.TatHitmahut503 = RamatPeilut504.TatHitmahut
	AND deptSimul.TatSugSimul502 = RamatPeilut504.TatSugSimul
	AND deptSimul.SugSimul501 = RamatPeilut504.SugSimul
LEFT JOIN UnitTypeConvertSimul ON deptSimul.SugSimul501 = UnitTypeConvertSimul.SugSimul
	AND deptSimul.TatSugSimul502 = UnitTypeConvertSimul.TatSugSimul
	AND deptSimul.TatHitmahut503 = UnitTypeConvertSimul.TatHitmahut
	AND deptSimul.RamatPeilut504 = UnitTypeConvertSimul.RamatPeilut
LEFT JOIN UnitType as UT ON UnitTypeConvertSimul.key_TypUnit = UT.UnitTypeCode
INNER JOIN UnitType ON D.typeUnitCode = UnitType.UnitTypeCode
LEFT JOIN x_dept_XY ON D.deptCode = x_dept_XY.deptCode
LEFT JOIN Atarim ON D.NeighbourhoodOrInstituteCode = Atarim.InstituteCode
LEFT JOIN Neighbourhoods ON D.NeighbourhoodOrInstituteCode = Neighbourhoods.NeighbourhoodCode

WHERE D.deptCode = @deptCode



-- DeptHandicappedFacilities
SELECT T1.FacilityCode, T1.FacilityDescription,
'CinicHasFacility' = CASE IsNull(T2.FacilityCode, 0) WHEN 0 THEN 0 ELSE 1 END
FROM
(SELECT
DIC_HandicappedFacilities.FacilityCode,
DIC_HandicappedFacilities.FacilityDescription
FROM DIC_HandicappedFacilities where Active=1) as T1 

LEFT JOIN 
(SELECT FacilityCode FROM DeptHandicappedFacilities
WHERE DeptCode = @deptCode) as T2 ON T1.FacilityCode = T2.FacilityCode

-- DeptQueueOrderMethods_ForHeadline
DECLARE @QueueOrderMethods varchar(100)
SET @QueueOrderMethods = ''

SELECT @QueueOrderMethods = QueueOrderDescription + ', ' + @QueueOrderMethods
FROM Dept d
INNER JOIN DIC_QueueOrder dic ON d.QueueOrder = dic.QueueOrder
WHERE DeptCode = @deptCode 
AND d.QueueOrder IS NOT NULL AND dic.PermitOrderMethods = 0

SELECT @QueueOrderMethods = QueueOrderMethodDescription + ', ' + @QueueOrderMethods
FROM DeptQueueOrderMethod
INNER JOIN DIC_QueueOrderMethod ON DeptQueueOrderMethod.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
WHERE deptCode = @deptCode AND ShowPhonePicture = 0

SELECT @QueueOrderMethods = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) + ', '+ @QueueOrderMethods
FROM DeptPhones
INNER JOIN DeptQueueOrderMethod ON DeptPhones.deptCode = DeptQueueOrderMethod.deptCode
INNER JOIN DIC_QueueOrderMethod ON DeptQueueOrderMethod.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
WHERE DeptPhones.deptCode = @deptCode AND phoneType = 1 AND phoneOrder = 1
AND SpecialPhoneNumberRequired = 0 AND ShowPhonePicture = 1

SELECT @QueueOrderMethods = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) + ', '+ @QueueOrderMethods
FROM DeptQueueOrderPhones
INNER JOIN DeptQueueOrderMethod ON DeptQueueOrderPhones.QueueOrderMethodID = DeptQueueOrderMethod.QueueOrderMethodID
INNER JOIN DIC_QueueOrderMethod ON DIC_QueueOrderMethod.QueueOrderMethod = DeptQueueOrderMethod.QueueOrderMethod
WHERE deptCode = @deptCode 
AND SpecialPhoneNumberRequired = 1

IF len(@QueueOrderMethods) > 1
-- remove last comma
BEGIN
	SET @QueueOrderMethods = SUBSTRING(@QueueOrderMethods, 0, len(@QueueOrderMethods))
END

SELECT TOP 1 @QueueOrderMethods FROM EmployeeServiceQueueOrderMethod



--------- Remarks (for viewing purposes only)--------------------------------------------------------
--------- general Remarks concern the clinic--------------------------------------------------------
SELECT remarkID
, 'RemarkText' = dbo.rfn_GetFotmatedRemark(RemarkText)
, validFrom
, validTo
, displayInInternet
, RemarkDeptCode as deptCode
, View_DeptRemarks.IsSharedRemark as 'sweeping' 
, ShowOrder
FROM View_DeptRemarks
LEFT JOIN Dept ON View_DeptRemarks.deptCode = Dept.deptCode
WHERE View_DeptRemarks.deptCode = @deptCode
AND validFrom < @DateAfterExpiration AND ( validTo is null OR validTo >= @ExpirationDate )
AND (IsSharedRemark = 0 OR Dept.IsCommunity = 1) 
ORDER BY sweeping desc ,ShowOrder asc



-------- DeptPhones --------------------------------------------------------
SELECT 
DeptPhoneID,
DeptPhones.phoneType,
phoneOrder,
prePrefix,
prefixCode,
PrefixValue as PrefixText,
phone,
extension
FROM DeptPhones
LEFT JOIN DIC_PhonePrefix dic ON DeptPhones.Prefix = dic.PrefixCode
WHERE deptCode = @deptCode
AND DeptPhones.phoneType = 1 -- (Phone)



-------- DeptFaxes --------------------------------------------------------
SELECT 
DeptPhoneID,
DeptPhones.phoneType,
phoneOrder,
prePrefix,
prefixCode,
PrefixValue as PrefixText,
phone,
extension
FROM DeptPhones
LEFT JOIN DIC_PhonePrefix dic ON DeptPhones.Prefix = dic.PrefixCode
WHERE deptCode = @deptCode
AND DeptPhones.phoneType = 2 -- (Fax)





GO

GRANT EXEC ON rpc_getDeptDetailsForUpdate TO PUBLIC
GO



-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDeptsForEmployeeRemarkFromAllDepts')
	BEGIN
		DROP  Procedure  rpc_GetDeptsForEmployeeRemarkFromAllDepts
	END

GO

CREATE Procedure dbo.rpc_GetDeptsForEmployeeRemarkFromAllDepts
(
	@employeeRemarkID INT
)

AS


SELECT 
er.EmployeeRemarkId,
-1 as DeptCode , 
'כל היחידות בקהילה' as DeptName, 
'RemarkRelatedToDept' = er.AttributedToAllClinicsInCommunity
FROM EmployeeRemarks er 
WHERE er.EmployeeRemarkID = @employeeRemarkID


UNION

SELECT  er.EmployeeRemarkId, dept.deptCode, deptName, 
'RemarkRelatedToDept' = CASE er.AttributedToAllClinicsInCommunity 
							WHEN 0 THEN	CASE ISNULL(xder.DeptEmployeeID, 0) 
											WHEN 0 THEN 0 
											ELSE 1 
										END
							ELSE 1 
						END
																					
FROM x_dept_employee xd
INNER JOIN Dept on xd.deptCode = dept.deptCode
LEFT JOIN EmployeeRemarks er ON xd.EmployeeID = er.EmployeeID
LEFT JOIN x_Dept_Employee_EmployeeRemarks xder ON er.EmployeeRemarkID = xder.EmployeeRemarkID AND xd.DeptEmployeeID = xder.DeptEmployeeID
WHERE er.EmployeeRemarkID = @employeeRemarkID
--AND xd.Active = 1

GO


GRANT EXEC ON rpc_GetDeptsForEmployeeRemarkFromAllDepts TO PUBLIC

GO

-- ***************************************


/****** Object:  View [dbo].[View_DeptEmployee_EmployeeRemarks]    Script Date: 12/25/2011 13:07:00 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[View_DeptEmployee_EmployeeRemarks]'))
DROP VIEW [dbo].[View_DeptEmployee_EmployeeRemarks]
GO




CREATE VIEW [dbo].[View_DeptEmployee_EmployeeRemarks]
AS
 
SELECT 
xd.DeptCode as DeptCode,
xd.EmployeeID,
xd.DeptCode as EmpRemarkDeptCode,
EmployeeRemarks.EmployeeRemarkID,
EmployeeRemarks.DicRemarkID,
EmployeeRemarks.AttributedToAllClinicsInCommunity,
EmployeeRemarks.AttributedToAllClinicsInMushlam,
EmployeeRemarks.AttributedToAllClinicsInHospitals,
EmployeeRemarks.RemarkText as RemarkText,
dbo.rfn_GetFotmatedRemark(EmployeeRemarks.RemarkText) as RemarkTextFormated,
EmployeeRemarks.displayInInternet,
EmployeeRemarks.ValidFrom,
EmployeeRemarks.ValidTo


FROM x_Dept_Employee_EmployeeRemarks as x_D_E_ER
INNER JOIN EmployeeRemarks ON x_D_E_ER.EmployeeRemarkID = EmployeeRemarks.EmployeeRemarkID
INNER JOIN x_Dept_Employee xd ON x_D_E_ER.DeptEmployeeID = xd.DeptEmployeeID





UNION

SELECT
Dept.deptCode as DeptCode,
EmployeeRemarks.EmployeeID,
0 as EmpRemarkDeptCode,
EmployeeRemarks.EmployeeRemarkID,
EmployeeRemarks.DicRemarkID,
EmployeeRemarks.AttributedToAllClinicsInCommunity,
EmployeeRemarks.AttributedToAllClinicsInMushlam,
EmployeeRemarks.AttributedToAllClinicsInHospitals,
EmployeeRemarks.RemarkText as RemarkText,
dbo.rfn_GetFotmatedRemark(EmployeeRemarks.RemarkText) as RemarkTextFormated,
EmployeeRemarks.displayInInternet,
EmployeeRemarks.ValidFrom,
EmployeeRemarks.ValidTo

FROM EmployeeRemarks 
join x_Dept_Employee as x_D_E on EmployeeRemarks.EmployeeID = x_D_E.employeeID
join Dept on Dept.deptCode = x_D_E.DeptCode
	and (
		(EmployeeRemarks.AttributedToAllClinicsInCommunity = 1 and Dept.IsCommunity = 1)  
	or (EmployeeRemarks.AttributedToAllClinicsInMushlam = 1 and Dept.IsMushlam = 1)
	or (EmployeeRemarks.AttributedToAllClinicsInHospitals = 1 and Dept.IsHospital = 1)
	)



GO

grant select on View_DeptEmployee_EmployeeRemarks to public 
go




-- ***************************************

IF EXISTS (SELECT * FROM sysobjects WHERE name = 'fun_GetEmployeeInDeptProfessions')
	BEGIN
		DROP  FUNCTION  fun_GetEmployeeInDeptProfessions
	END
GO

CREATE FUNCTION [dbo].[fun_GetEmployeeInDeptProfessions]
(
	@EmployeeID int,
	@DeptCode int,
	@isOrderASC bit
)
-- gets professions for employee in clinic as list of comma separated values

RETURNS varchar(500)
AS
BEGIN
    DECLARE @p_str VARCHAR(500)
    SET @p_str = ''   	
    	
	declare @tempTable table
	(
		professionDescription VARCHAR(100)
	)

	INSERT INTO @tempTable        
    SELECT [Services].serviceDescription    
    FROM x_Dept_Employee_Service
    INNER JOIN [Services] ON x_Dept_Employee_Service.serviceCode = [Services].serviceCode
    INNER JOIN x_dept_employee xd ON x_Dept_Employee_Service.DeptEmployeeID = xd.DeptEmployeeID
    WHERE xd.employeeID = @EmployeeID
    AND xd.deptCode = @DeptCode
    AND x_Dept_Employee_Service.Status = 1
	AND [Services].IsService = 0
    ORDER BY 
	CASE @isOrderASC
		WHEN 1 THEN [Services].serviceDescription 
		END,
	CASE WHEN @isOrderASC <> 1 OR @isOrderASC IS NULL THEN [Services].serviceDescription 
		END DESC  
	
	
	SELECT @p_str = @p_str + professionDescription + ','
	FROM @tempTable    
    	
	IF len(@p_str) > 1
	-- remove last comma
	BEGIN
		SET @p_str = SUBSTRING(@p_str, 0, len(@p_str))
	END
	
    RETURN @p_str

END
GO

grant exec on fun_GetEmployeeInDeptProfessions to public 
GO

-- ***************************************
  
IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[dbo].[fun_GetEmployeeInDeptServices]') and xtype in (N'FN', N'IF', N'TF'))
	DROP FUNCTION [dbo].[fun_GetEmployeeInDeptServices]
GO

create FUNCTION [dbo].[fun_GetEmployeeInDeptServices] 
(
	@EmployeeID int, 
	@DeptCode int,
	@isOrderASC bit
)
RETURNS varchar(500)
WITH EXECUTE AS CALLER
AS
BEGIN 

    DECLARE @p_str VARCHAR(500)
    SET @p_str = ''
    
    	
	declare @tempTable table
	(
		serviceDescription VARCHAR(100)
	)


	INSERT INTO @tempTable        
    SELECT [Services].serviceDescription    
    FROM x_Dept_Employee_Service
    INNER JOIN [Services] ON x_Dept_Employee_Service.serviceCode = [Services].serviceCode
	INNER JOIN x_Dept_Employee xd ON x_Dept_Employee_service.DeptEmployeeID = xd.DeptEmployeeID
    WHERE xd.employeeID = @EmployeeID
    AND xd.deptCode = @DeptCode
    AND x_Dept_Employee_Service.Status = 1
	AND [Services].IsService = 1
    ORDER BY 
	CASE @isOrderASC
		WHEN 1 THEN [Services].serviceDescription 
		END,
	CASE WHEN @isOrderASC <> 1 OR @isOrderASC IS NULL THEN [Services].serviceDescription 
		END DESC    
    
    SELECT @p_str = @p_str + serviceDescription + ','
	FROM @tempTable    
    
    
	IF len(@p_str) > 1
	-- remove last comma
	BEGIN
		SET @p_str = SUBSTRING(@p_str, 0, len(@p_str))
	END
	
    RETURN @p_str
	
END

go 

grant exec on dbo.fun_GetEmployeeInDeptServices to public 

go 

-- ***************************************

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vEmployeeReceptionHours]'))
DROP VIEW [dbo].[vEmployeeReceptionHours]
GO

create VIEW [dbo].[vEmployeeReceptionHours]
AS
SELECT     xd.deptCode, dER.receptionID, xd.EmployeeID, dER.receptionDay, dER.openingHour, dER.closingHour, 
                      dbo.DIC_ReceptionDays.ReceptionDayName, 
                      CASE closingHour WHEN '00:00' THEN CASE openingHour WHEN '00:01' THEN '24' WHEN '01:00' THEN '24' WHEN '00:00' THEN '24' ELSE openingHour
                       + '-' END WHEN '23:59' THEN CASE openingHour WHEN '00:01' THEN '24' WHEN '01:00' THEN '24' WHEN '00:00' THEN '24' ELSE openingHour + '-' END
                       ELSE openingHour + '-' END + CASE closingHour WHEN '00:00' THEN CASE openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN
                       '00:00' THEN 'שעות' ELSE closingHour END WHEN '23:59' THEN CASE openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN '00:00'
                       THEN 'שעות' ELSE closingHour END ELSE closingHour END + CASE dbo.fun_GetEmployeeRemarksForReception(dER.receptionID) 
                      WHEN '' THEN '' ELSE '<br>' + dbo.fun_GetEmployeeRemarksForReception(dER.receptionID) END AS OpeningHourText, 
                      dbo.Employee.EmployeeSectorCode,
                      S.ServiceDescription
FROM DeptEmployeeReception AS dER 
INNER JOIN dbo.DIC_ReceptionDays ON dER.receptionDay = dbo.DIC_ReceptionDays.ReceptionDayCode 
INNER JOIN x_Dept_Employee xd ON dER.DeptEmployeeID = xd.DeptEmployeeID
			AND xd.active <> 0
INNER JOIN dbo.Employee ON xd.EmployeeID = dbo.Employee.employeeID
INNER JOIN deptEmployeeReceptionServices dERS ON dER.receptionID = dERS.receptionID
INNER JOIN [Services] S ON dERS.serviceCode = S.ServiceCode
                      

GO


grant select on vEmployeeReceptionHours to public 
go

-- ***************************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeePositionsForDept')
	BEGIN
		DROP  Procedure  rpc_getEmployeePositionsForDept
	END

GO
-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'fun_getManagerName')
	BEGIN
		DROP  FUNCTION  fun_getManagerName
	END

GO

CREATE FUNCTION [dbo].[fun_getManagerName] 
(
	@deptCode int
)
RETURNS varchar(500)

AS
BEGIN
	DECLARE  @strManagerName varchar(500)
	SET @strManagerName = ''
	
	 set @strManagerName = (SELECT  TOP 1 DegreeName + ' ' + lastName + ' ' + firstName
							FROM employee
							INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode
							INNER JOIN x_dept_employee ON employee.employeeID = x_dept_employee.employeeID
							INNER JOIN x_Dept_Employee_Position ON x_dept_employee.DeptEmployeeID = x_Dept_Employee_Position.DeptEmployeeID 								
							INNER JOIN mappingPositions ON x_Dept_Employee_Position.positionCode = mappingPositions.positionCode
							WHERE mappingPositions.mappedToManager = 1
							AND x_dept_employee.deptCode = @deptCode)
		
	
							
	if(@strManagerName = '' or @strManagerName is null )						
	begin
		 select @strManagerName = Dept.managerName from Dept where Dept.deptCode = @deptCode			
	end 
	
	RETURN( @strManagerName )

	
	
END

GO

GRANT EXEC ON fun_getManagerName TO PUBLIC 

GO

 
-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'rfn_GetDeptEmployeesServiceDescriptions')
	BEGIN
		DROP  FUNCTION  rfn_GetDeptEmployeesServiceDescriptions
	END

GO
create FUNCTION [dbo].rfn_GetDeptEmployeesServiceDescriptions(@deptCode bigint, @employeeID bigint)
RETURNS varchar(500)
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @NewLineChar AS CHAR(2) 
	set @NewLineChar = CHAR(13) + CHAR(10)
	
	DECLARE @strServices varchar(500)
	SET @strServices = ''
	
--  @strServices look like  not corect ordered in case any serviceDescription containce english literals.
	SELECT @strServices = @strServices + s.serviceDescription +'; '
	from
		(SELECT DISTINCT [Services].serviceDescription, [Services].serviceCode
		FROM x_Dept_Employee_Service AS xdes		
		INNER JOIN [Services] ON xDES.serviceCode = [Services].ServiceCode
		INNER JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
		WHERE (@deptCode = -1 or xd.deptCode = @deptCode)
			AND (@employeeID = -1 or xd.employeeID = @employeeID)
			AND status = 1
			AND [Services].IsService = 1
		)
		as s
	order by s.serviceDescription
	
	IF(LEN(@strServices)) > 0 -- to remove last ','
	BEGIN
		SET @strServices = left( @strServices, LEN(@strServices) -1 )
	END
	
	RETURN( @strServices )
END
go 

grant exec on rfn_GetDeptEmployeesServiceDescriptions to public 
go


-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteEmployeePositionInDept')
	BEGIN
		DROP  Procedure  rpc_deleteEmployeePositionInDept
	END

GO

CREATE Procedure rpc_deleteEmployeePositionInDept
	(
		@EmployeeID int,
		@DeptCode int, 
		@PositionCode int = NULL
	)

AS

DELETE x_Dept_Employee_Position 
FROM x_Dept_Employee_Position pos
INNER JOIN x_dept_employee xd ON pos.DeptEmployeeID = xd.DeptEmployeeID
WHERE xd.deptCode = @DeptCode
AND xd.employeeID = @EmployeeID
AND IsNull(@PositionCode, PositionCode) = PositionCode

GO

GRANT EXEC ON rpc_deleteEmployeePositionInDept TO PUBLIC

GO

-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteEmployeeProfessionsInDept')
	BEGIN
		DROP  Procedure  rpc_deleteEmployeeProfessionsInDept
	END

GO

CREATE Procedure dbo.rpc_deleteEmployeeProfessionsInDept
(
	@employeeID INT,
	@deptCode	INT
)

AS

DELETE x_Dept_Employee_Service 
FROM x_Dept_Employee_Service xdes
INNER JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
WHERE xd.DeptCode = @deptCode 
AND xd.EmployeeID = @employeeID
AND xdes.serviceCode IN
	(SELECT serviceCode FROM [Services] WHERE IsProfession = 1)



GO


GRANT EXEC ON rpc_deleteEmployeeProfessionsInDept TO PUBLIC

GO

-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteEmployeeRemarksAttributedToDepts')
	BEGIN
		DROP  Procedure  rpc_deleteEmployeeRemarksAttributedToDepts
	END

GO

CREATE Procedure rpc_deleteEmployeeRemarksAttributedToDepts
	(
		@EmployeeID int,
		@DeptCode int,
		@EmployeeRemarkIDs varchar(50)
	)

AS

DELETE x_Dept_Employee_EmployeeRemarks 
FROM x_Dept_Employee_EmployeeRemarks xder
INNER JOIN x_dept_employee xd ON xder.DeptemployeeID = xd.DeptEmployeeID
WHERE EmployeeRemarkID in (Select IntField from  dbo.SplitString(@EmployeeRemarkIDs))
AND xd.DeptCode = @DeptCode
AND xd.EmployeeID = @EmployeeID

GO

GRANT EXEC ON rpc_deleteEmployeeRemarksAttributedToDepts TO PUBLIC

GO

-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteEmployeeServiceQueueOrderMethods')
	BEGIN
		DROP  Procedure  rpc_DeleteEmployeeServiceQueueOrderMethods
	END
GO

CREATE PROCEDURE dbo.rpc_DeleteEmployeeServiceQueueOrderMethods
	@x_Dept_Employee_ServiceID int
AS

IF EXISTS 	(
				SELECT * 
				FROM x_Dept_Employee_Service
				WHERE x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID AND QueueOrder = 3
			)
		
BEGIN
	DELETE EmployeeServiceQueueOrderMethod
	WHERE EmployeeServiceQueueOrderMethodID IN 
								(SELECT EmployeeServiceQueueOrderMethodID
								 FROM EmployeeServiceQueueOrderMethod esqom
								 INNER JOIN x_Dept_Employee_Service xdes ON esqom.x_dept_employee_serviceID = xdes.x_dept_employee_serviceID								 									
								 WHERE xDES.x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID)
	
	
	UPDATE x_Dept_Employee_Service
	SET QueueOrder = -1
	WHERE x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID
END
GO

GRANT EXEC ON rpc_DeleteEmployeeServiceQueueOrderMethods TO PUBLIC
GO

-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptForEmployeeWithPermissions')
	BEGIN
		DROP  Procedure  rpc_getDeptForEmployeeWithPermissions
	END

GO
-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptEmployeeServicesExtended')
	BEGIN
		DROP  Procedure  rpc_getDeptEmployeeServicesExtended
	END

GO

-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'fun_GetEmployeeServiceGroup_QueueOrderDescription')
	BEGIN
		DROP  FUNCTION  fun_GetEmployeeServiceGroup_QueueOrderDescription
	END
GO

CREATE FUNCTION [dbo].[fun_GetEmployeeServiceGroup_QueueOrderDescription] (@DeptEmployeeID int, @ServiceCode int)
RETURNS varchar(100)
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @QueueOrderDescription varchar(50) SET @QueueOrderDescription = ''
		
	IF(@ServiceCode <> 0)
	BEGIN
		SELECT @QueueOrderDescription = DIC_QueueOrder.QueueOrderDescription
		FROM x_Dept_Employee_Service xdes 
		INNER JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
		INNER JOIN DIC_QueueOrder ON xdes.QueueOrder = DIC_QueueOrder.QueueOrder
		WHERE xd.DeptEmployeeID = @DeptEmployeeID
		AND xdes.ServiceCode = @ServiceCode
	END
	ELSE
	BEGIN
		SET @QueueOrderDescription = ''
	END
	
	-- if there's no queue order via employee service
	-- try to get queue order via employee
	IF(@QueueOrderDescription = '') 
	BEGIN
		SELECT @QueueOrderDescription = DIC_QueueOrder.QueueOrderDescription
		FROM x_Dept_Employee x_D_E
		INNER JOIN DIC_QueueOrder ON x_D_E.QueueOrder = DIC_QueueOrder.QueueOrder
		WHERE x_D_E.DeptEmployeeID = @DeptEmployeeID
		
		IF( @QueueOrderDescription is null)
			SET @QueueOrderDescription = ''
	END

	RETURN @QueueOrderDescription

END
GO


grant exec on fun_GetEmployeeServiceGroup_QueueOrderDescription to public 
go 

-- ***************************************



IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetEmployeeQueueOrderDescription')
	BEGIN
		DROP  Procedure  rpc_GetEmployeeQueueOrderDescription
	END

GO

CREATE Procedure dbo.rpc_GetEmployeeQueueOrderDescription
(
		@employeeID INT,
		@deptCode INT
)


AS


SELECT 
xe.deptCode,
xe.EmployeeID,
qo.QueueOrder,
qo.QueueOrderDescription,
0 as QueueOrderMethod
 
FROM x_dept_Employee xe
INNER JOIN Dic_QueueOrder qo ON xe.QueueOrder = qo.QueueOrder

WHERE xe.deptcode = @deptCode AND xe.employeeid = @employeeID
AND permitorderMethods = 0 


UNION 

SELECT 
xd.deptCode,
xd.EmployeeID,
qo.QueueOrder,
CASE WHEN dbo.fun_ParsePhoneNumberWithExtension(deptPhones.prePrefix,deptPhones.prefix,deptPhones.phone,deptPhones.extension) = '' THEN 
			CASE WHEN dbo.fun_ParsePhoneNumberWithExtension(queuePhones.prePrefix,queuePhones.prefix,queuePhones.phone,queuePhones.extension) = '' 
					THEN qom.QueueOrderMethodDescription 
				 ELSE dbo.fun_ParsePhoneNumberWithExtension(queuePhones.prePrefix,queuePhones.prefix,queuePhones.phone,queuePhones.extension) 
			END
	  ELSE dbo.fun_ParsePhoneNumberWithExtension(deptPhones.prePrefix,deptPhones.prefix,deptPhones.phone,deptPhones.extension) END as QueueOrderMethodDescription,
eqom.QueueOrderMethod
 
FROM x_dept_Employee xd
LEFT JOIN EmployeeQueueOrderMethod eqom ON xd.DeptEmployeeID  = eqom.DeptEmployeeID 
LEFT JOIN DeptPhones ON xd.deptCode = deptPhones.DeptCode AND PhoneType = 1 AND PhoneOrder = 1 AND QueueOrderMethod = 1
LEFT JOIN DeptEmployeeQueueOrderPhones queuePhones ON eqom.QueueOrderMethodID = queuePhones.QueueOrderMethodID
INNER JOIN Dic_QueueOrder qo ON xd.QueueOrder = qo.QueueOrder
LEFT JOIN DIC_QueueOrderMethod qom ON eqom.QueueOrderMethod = qom.QueueOrderMethod
WHERE xd.deptcode = @deptCode 
AND xd.employeeid = @employeeID
AND permitOrderMethods = 1 



GO


GRANT EXEC ON rpc_GetEmployeeQueueOrderDescription TO PUBLIC

GO


-- ***************************************


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeeReceptionAndRemarks')
	BEGIN
		drop procedure rpc_getEmployeeReceptionAndRemarks
	END

GO

CREATE Procedure [dbo].[rpc_getEmployeeReceptionAndRemarks]
(
	@EmployeeID int,
	@DeptCode int,
	@ExpirationDate datetime
)
as

IF (@ExpirationDate is null OR @ExpirationDate <= cast('1/1/1900 12:00:00 AM' as datetime))
	BEGIN
		SET  @ExpirationDate = getdate()
	END	

------ Employee remark -------------------------------------------------------------

--using  View_DeptEmployee_EmployeeRemarks includes EmployeeRemarks  per dept 
-- and EmployeeRemarks Attributed ToAll Clinics InCommunity, ..InMushlam, ..InHospitals 
-- according to Dept Membership Type

 SELECT distinct
	dbo.rfn_GetFotmatedRemark(v_DE_ER.RemarkTextFormated) as remark,
	v_DE_ER.displayInInternet,
	'' as ServiceName
from View_DeptEmployee_EmployeeRemarks as v_DE_ER
	where v_DE_ER.EmployeeID = @EmployeeID
	and v_DE_ER.DeptCode = @DeptCode
	AND (v_DE_ER.ValidFrom is null OR DATEDIFF(dd, v_DE_ER.ValidFrom ,@ExpirationDate) >= 0)
	AND (v_DE_ER.ValidTo is null OR DATEDIFF(dd, v_DE_ER.ValidTo ,@ExpirationDate) <= 0)

UNION

SELECT
dbo.rfn_GetFotmatedRemark(desr.RemarkText), displayInInternet, ServiceDescription as ServiceName
FROM DeptEmployeeServiceRemarks desr
INNER JOIN x_Dept_Employee_Service xdes ON desr.x_dept_employee_serviceID = xdes.x_dept_employee_serviceID
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
INNER JOIN [Services] ON xdes.ServiceCode = [Services].ServiceCode AND xdes.Status = 1
WHERE xd.EmployeeID = @EmployeeID 
AND xd.DeptCode = @deptCode
AND (ValidFrom is NULL OR DATEDIFF(dd, ValidFrom ,@ExpirationDate) >= 0 )
AND (ValidTo is NULL OR  DATEDIFF(dd, ValidTo ,@ExpirationDate) <= 0 ) 

------ Employee name, dept name, profession in dept -------------------------------------------------------------
SELECT 
dept.deptName,
'employeeName' = DegreeName + ' ' + Employee.lastName + ' ' + Employee.firstName,
'professions' = [dbo].[fun_GetEmployeeInDeptProfessions](x_Dept_Employee.employeeID, x_Dept_Employee.deptCode, 1)
FROM Employee
INNER JOIN x_Dept_Employee ON Employee.EmployeeID = x_Dept_Employee.EmployeeID
INNER JOIN dept ON x_Dept_Employee.deptCode = dept.deptCode
INNER JOIN DIC_EmployeeDegree ON Employee.degreeCode = DIC_EmployeeDegree.DegreeCode

WHERE Employee.EmployeeID = @EmployeeID
AND x_Dept_Employee.deptCode = @DeptCode


-- get the closest new reception within 14 days for each profession or service
SELECT MIN(ValidFrom) as ChangeDate , s.serviceCode AS ServiceOrProfessionCode, s.ServiceDescription as professionOrServiceDescription
FROM deptEmployeeReception der
INNER JOIN deptEmployeeReceptionServices  ders on der.receptionID = ders.receptionID
INNER JOIN x_Dept_Employee xd ON der.DeptEmployeeID = xd.DeptEmployeeID
INNER JOIN [Services] s ON dERS.serviceCode = s.serviceCode
WHERE xd.DeptCode = @DeptCode
AND xd.EmployeeID = @EmployeeID
AND DATEDIFF(dd, ValidFrom ,@ExpirationDate) < 0 
AND DATEDIFF(dd, ValidFrom ,@ExpirationDate) >= -14
GROUP BY s.serviceCode, s.serviceDescription



--------  "doctorReception" (Doctor's Hours in Clinic) -------------------

SELECT
dER.receptionID,
xd.EmployeeID,
xd.deptCode,
IsNull(dERS.serviceCode, 0) as professionOrServiceCode,
IsNull(serviceDescription, 'NoData') as professionOrServiceDescription,
DER.validFrom,
DER.validTo,
'expirationDate' = DER.validTo,
'willExpireIn' = DATEDIFF(day, getdate(), IsNull(validTo,'01/01/2050')),
dER.receptionDay,
vReceptionDaysForDisplay.ReceptionDayName,
'openingHour' = 
	CASE closingHour 
		WHEN '00:00' THEN	
			CASE openingHour WHEN '00:01' THEN '24' WHEN '01:00' THEN '24' WHEN '00:00' THEN '24' ELSE openingHour END
		WHEN '23:59' THEN	
			CASE openingHour WHEN '00:01' THEN '24' WHEN '01:00' THEN '24' WHEN '00:00' THEN '24' ELSE openingHour END			
		ELSE openingHour END,
'closingHour' =
	CASE closingHour 
		WHEN '00:00' THEN	
			CASE openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN '00:00' THEN 'שעות' ELSE closingHour END
		WHEN '23:59' THEN	
			CASE openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN '00:00' THEN 'שעות' ELSE closingHour END
		ELSE closingHour END,
'receptionRemarks' = dbo.fun_GetEmployeeRemarksForReception(dER.receptionID),
'serviceCodes' = dbo.fun_GetServiceCodesForEmployeeReception(dER.receptionID),
'receptionDaysInDept'= (SELECT COUNT(*) FROM deptEmployeeReception as der2
						 INNER JOIN deptEmployeeReceptionServices as ders2 ON dER2.receptionID = ders2.receptionID
						 INNER JOIN x_Dept_Employee xd ON der2.DeptEmployeeID = xd.DeptEmployeeID
						 WHERE xd.deptCode = @deptCode AND xd.EmployeeID = @EmployeeID
						 AND ders2.serviceCode = ders.serviceCode
		)

FROM deptEmployeeReception as der
INNER JOIN deptEmployeeReceptionServices as dERS ON der.receptionID = dERS.receptionID
INNER JOIN [Services] ON dERS.serviceCode = [Services].serviceCode
INNER JOIN x_dept_employee_service xdes ON der.DeptEmployeeID = xdes.DeptEmployeeID AND [Services].serviceCode = xdes.serviceCode AND xdes.Status = 1
INNER JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
INNER JOIN vReceptionDaysForDisplay on dER.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode
WHERE xd.deptCode = @DeptCode
AND xd.EmployeeID = @EmployeeID
AND (
	(validFrom is null OR DATEDIFF(dd, ValidFrom ,@ExpirationDate) >= 0 )
	and 
	(validTo is null OR DATEDIFF(dd, ValidTo ,@ExpirationDate) <= 0 ) 
	)

ORDER BY EmployeeID, receptionDay, openingHour

------ DeptEmployeePhones
SELECT
employeeID,
phoneOrder,
'phone' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension),
phoneType,
phoneTypeName,
'shortPhoneTypeName' = CASE phoneType WHEN 2 THEN 'פקס' ELSE 'טל`' END

FROM DeptEmployeePhones dep
INNER JOIN x_Dept_Employee xd ON dep.DeptEmployeeID = xd.DeptEmployeeID
INNER JOIN DIC_PhoneTypes ON dep.phoneType = DIC_PhoneTypes.phoneTypeCode
WHERE deptCode = @DeptCode
AND employeeID = @EmployeeID




GO


GRANT EXEC ON rpc_getEmployeeReceptionAndRemarks TO PUBLIC
GO


-- ***************************************


 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetEmployeeReceptionByServiceAndProfession')
	BEGIN
		DROP  Procedure  rpc_GetEmployeeReceptionByServiceAndProfession
	END
GO

CREATE  procedure [dbo].[rpc_GetEmployeeReceptionByServiceAndProfession]
(
	@employeeID  BIGINT,
	@deptCode INT = NULL
) 
as 

-- linked with receptions
SELECT EmployeeID , receptionID , deptCode, deptName ,cityCode ,cityName , 
  receptionDay, openingHour, closingHour, validFrom,validTo , ItemType, ItemID, ItemDesc, 
v.RemarkID, RemarkText, EnableOverMidnightHours
FROM v_EmployeeReceptionByServiceAndProfession v
LEFT JOIN DIC_GeneralRemarks rem ON v.RemarkID = rem.RemarkID
WHERE EmployeeID =   @employeeID  AND IsNULL(@deptCode,DeptCode) = DeptCode
AND (DATEDIFF(dd,GETDATE(),validTo) >= 0 OR ValidTo IS NULL)

UNION 

--  linked service without reception
SELECT distinct xd.EmployeeID, null receptionID, dept.deptCode, dept.deptName ,cities.cityCode ,cities.cityName , 
				null as receptionDay, null as openingHour, null as closingHour, null as validFrom, null as validTo,
				CASE s.IsProfession WHEN 0 THEN 'service' ELSE 'profession'  END as ItemType, 
				xdes.serviceCode as ItemID, s.ServiceDescription as ItemDesc, null as RemarkID, null RemarkText, null as EnableOverMidnightHours
FROM x_Dept_Employee xd
INNER JOIN x_Dept_Employee_service xdes ON xd.DeptEmployeeID = xdes.DeptEmployeeID
INNER JOIN [Services] s ON xdes.serviceCode = s.ServiceCode
LEFT JOIN  dbo.Dept ON xd.deptCode = dbo.Dept.deptCode 
INNER JOIN dbo.Cities ON dbo.Dept.cityCode = dbo.Cities.cityCode
WHERE xd.Employeeid = @employeeID 
AND IsNULL(@deptCode,xd.DeptCode) = xd.DeptCode
							  
ORDER BY deptCode,ValidFrom


SELECT DeptCode, openinghour, ClosingHour ,  remarkText,  ValidFrom , ValidTo, ItemID, receptionDay,dense_rank() 
over (order by  DeptCode,openinghour, ClosingHour,  remarkText, ValidFrom , ValidTo, dayGroup) as RecRank 
FROM 
(
SELECT DeptCode, openinghour, ClosingHour , remarkText,  ValidFrom , ValidTo, ItemID, receptionDay,
sum(power(2,receptionDay-1)) over (partition by DeptCode, openinghour,  ClosingHour,  remarkText, ValidFrom , ValidTo, itemid) dayGroup,
   COUNT(*) as nrecs 
FROM v_EmployeeReceptionByServiceAndProfession v
WHERE employeeid =  @employeeID  AND IsNULL(@deptCode,DeptCode) = DeptCode     
GROUP BY  DeptCode, openinghour, ClosingHour, remarkText,   ValidFrom , ValidTo, ItemID, receptionDay) as a 

GO


grant exec on dbo.rpc_GetEmployeeReceptionByServiceAndProfession to public

GO

-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeeRemarksAttributedToDepts')
	BEGIN
		DROP  Procedure  rpc_getEmployeeRemarksAttributedToDepts
	END

GO

CREATE Procedure rpc_getEmployeeRemarksAttributedToDepts
	(
		@EmployeeRemarkID int
	)

AS

SELECT 
xd.deptCode,
xd.employeeID,
dept.deptName,
'attributed' = 
	CAST(
		CASE
			isNull((SELECT EmployeeRemarkID 
					FROM x_Dept_Employee_EmployeeRemarks
					WHERE xd.DeptEmployeeID = x_Dept_Employee_EmployeeRemarks.DeptEmployeeID					
					AND x_Dept_Employee_EmployeeRemarks.EmployeeRemarkID = @EmployeeRemarkID), 0)
		WHEN 0 THEN 0 ELSE 1 END
	AS bit)
	
FROM x_Dept_Employee xd
INNER JOIN dept ON dept.deptCode = xd.deptCode
INNER JOIN Employee ON xd.EmployeeID = Employee.EmployeeID
INNER JOIN EmployeeRemarks ON Employee.EmployeeID = EmployeeRemarks.EmployeeID
LEFT JOIN x_Dept_Employee_EmployeeRemarks ON xd.DeptEmployeeID = x_Dept_Employee_EmployeeRemarks.DeptEmployeeID	
	AND x_Dept_Employee_EmployeeRemarks.EmployeeRemarkID = @EmployeeRemarkID
	 

WHERE EmployeeRemarks.EmployeeRemarkID = @EmployeeRemarkID

GO

GRANT EXEC ON rpc_getEmployeeRemarksAttributedToDepts TO PUBLIC

GO
 
-- ***************************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeeRemarksForDept')
	BEGIN
		DROP  Procedure  rpc_getEmployeeRemarksForDept
	END

GO

CREATE Procedure rpc_getEmployeeRemarksForDept
	(
		@DeptCode int,
		@EmployeeID int
	)

AS

SELECT 
EmployeeRemarks.EmployeeRemarkID,
xd.DeptCode,
xd.EmployeeID,
EmployeeRemarks.RemarkText

FROM x_Dept_Employee_EmployeeRemarks as xder
INNER JOIN EmployeeRemarks ON xder.EmployeeRemarkID = EmployeeRemarks.EmployeeRemarkID
INNER JOIN x_Dept_Employee xd ON xder.DeptEmployeeID = xd.DeptEmployeeID
WHERE xd.DeptCode = @DeptCode
AND xd.EmployeeID = @EmployeeID
AND ValidFrom <= getdate()
AND (ValidTo is NULL OR ValidTo >= getdate())

GO

GRANT EXEC ON rpc_getEmployeeRemarksForDept TO PUBLIC

GO

-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_GetEmployeeRemarkDeptsNames')
	BEGIN
		DROP  FUNCTION  fun_GetEmployeeRemarkDeptsNames						
	END
GO


CREATE FUNCTION [dbo].[fun_GetEmployeeRemarkDeptsNames](@RemarkID int,@EmployeeID int) 
RETURNS varchar(2000)
AS
BEGIN
	declare @DeptsNames varchar(2000) 
	 
	set @DeptsNames = '' 

	SELECT @DeptsNames = @DeptsNames + DeptName + ','
	FROM (
		SELECT DISTINCT deptName as DeptName 
		FROM x_Dept_Employee_EmployeeRemarks as xder
		INNER JOIN x_dept_employee xd ON xder.DeptEmployeeID = xd.DeptEmployeeID
		INNER JOIN Dept as d ON xd.DeptCode = d.DeptCode 
		WHERE xder.EmployeeRemarkID = @RemarkID
		AND xd.EmployeeID = @EmployeeID) as tblDepts
	WHERE DeptName is not null 
	
	IF len(@DeptsNames) > 1
	-- remove last comma
	BEGIN
		SET @DeptsNames = SUBSTRING(@DeptsNames, 0, len(@DeptsNames))
	END
	
	RETURN @DeptsNames	

end 

GO

GRANT EXEC ON fun_GetEmployeeRemarkDeptsNames to public 
GO  

-- ***************************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_GetEmployeeRemarkDeptsCodes')
	BEGIN
		DROP  FUNCTION  fun_GetEmployeeRemarkDeptsCodes						
	END
GO

CREATE FUNCTION [dbo].[fun_GetEmployeeRemarkDeptsCodes](@RemarkID int,@EmployeeID int) 
RETURNS varchar(2000)
AS
BEGIN
	declare @DeptsCodes varchar(2000) 
	 
	set @DeptsCodes = '' 

	SELECT @DeptsCodes = @DeptsCodes + cast(DeptCode as varchar(10)) + ','
	FROM (
		SELECT DISTINCT xd.DeptCode as DeptCode
		FROM x_Dept_Employee_EmployeeRemarks as xder
		INNER JOIN x_dept_employee as xd ON xder.DeptEmployeeID = xd.DeptEmployeeID
		INNER JOIN Dept as d ON xd.DeptCode = d.DeptCode 
		WHERE xder.EmployeeRemarkID = @RemarkID
		AND xd.EmployeeID = @EmployeeID) as tblDepts
	where DeptCode is not null 


		IF len(@DeptsCodes) > 1
		-- remove last comma
		BEGIN
			SET @DeptsCodes = SUBSTRING(@DeptsCodes, 0, len(@DeptsCodes))
		END
		
		RETURN @DeptsCodes

	return @DeptsCodes 
end

GO 

GRANT EXEC ON fun_GetEmployeeRemarkDeptsCodes to public 
GO  

-- ***************************************


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetEmployeeRemarksForUpdate')
	BEGIN
		DROP  Procedure  rpc_GetEmployeeRemarksForUpdate
	END

GO

CREATE Procedure dbo.rpc_GetEmployeeRemarksForUpdate
(
	@EmployeeID int
)
AS


-- Current Remarks 
SELECT RecordType , RemarkID, RemarkText, RemarkTemplate, ValidFROM, ValidTo, Internetdisplay, Deleted, 
AttributedToAllClinicsInCommunity as AttributedToAllClinics,  AreasNames, DeptsCodes, RelevantForSystemManager
FROM 
(
	SELECT RecordType , RemarkID, RemarkText, RemarkTemplate, ValidFROM, ValidTo, Internetdisplay, Deleted, 
	AttributedToAllClinicsInCommunity, AreasNames, DeptsCodes, RelevantForSystemManager
	FROM(
			SELECT  DISTINCT 
				1 as RecordType,
				er.EmployeeRemarkID as RemarkID, 
				RemarkText as RemarkText,  
				CASE WHEN dgr.Remark  IS NOT NULL THEN dgr.Remark ELSE '' END AS RemarkTemplate , 
				convert(varchar, ValidFROM, 103) as ValidFROM,
				convert(varchar, ValidTo , 103)  as ValidTo ,
				displayInInternet as Internetdisplay,
				0 as Deleted , 			
				AttributedToAllClinicsInCommunity , 
				dbo.fun_GetEmployeeRemarkDeptsNames(er.EmployeeRemarkID,@EmployeeID )  as  AreasNames, 
				dbo.fun_GetEmployeeRemarkDeptsCodes(er.EmployeeRemarkID,@EmployeeID )  as  DeptsCodes,
				IsNull(dgr.RelevantForSystemManager, 0) as RelevantForSystemManager
			FROM EmployeeRemarks as er 
			LEFT JOIN dbo.DIC_GeneralRemarks as dgr ON er.DicRemarkID = dgr.RemarkID 
			LEFT JOIN x_Dept_Employee_EmployeeRemarks as xder ON er.EmployeeRemarkID = xder.EmployeeRemarkID 
			WHERE dbo.rfn_IsDatesCurrent(validFROM, validTo, GETDATE()) = 1  
			AND er.EmployeeID = @EmployeeID 
			--and (xDept.DeptCode > 0
			--or er.AttributedToAllClinicsInCommunity = 1)
		) as tblCurrent 
) as tblFinalCurrent 
ORDER BY RemarkText


-- Future Remarks 
SELECT RecordType , RemarkID, RemarkText, RemarkTemplate, ValidFROM, ValidTo, Internetdisplay, Deleted, 
AttributedToAllClinicsInCommunity as AttributedToAllClinics,  AreasNames , DeptsCodes, RelevantForSystemManager
FROM 
(
	SELECT RecordType , RemarkID, RemarkText, RemarkTemplate, ValidFROM, ValidTo, Internetdisplay, Deleted, 
		AttributedToAllClinicsInCommunity, AreasNames, DeptsCodes, RelevantForSystemManager
	FROM(
			SELECT  distinct 1 as RecordType, er.EmployeeRemarkID as RemarkID, RemarkText as RemarkText,  
				CASE 
					WHEN dgr.Remark  is not null then dgr.Remark  
					ELSE '' 
				end as RemarkTemplate , convert(varchar, ValidFROM, 103) as ValidFROM, convert(varchar, ValidTo , 103)  as ValidTo ,
				displayInInternet as Internetdisplay, 0 as Deleted , 			
				AttributedToAllClinicsInCommunity , 
				dbo.fun_GetEmployeeRemarkDeptsNames(er.EmployeeRemarkID,@EmployeeID )  as  AreasNames, 
				dbo.fun_GetEmployeeRemarkDeptsCodes(er.EmployeeRemarkID,@EmployeeID )  as  DeptsCodes,
				IsNull(dgr.RelevantForSystemManager, 0) as RelevantForSystemManager
			FROM EmployeeRemarks as er 
			LEFT JOIN dbo.DIC_GeneralRemarks as dgr ON er.DicRemarkID = dgr.RemarkID 
			LEFT JOIN x_Dept_Employee_EmployeeRemarks as xder ON er.EmployeeRemarkID = xder.EmployeeRemarkID 
			WHERE ValidFROM > getdate() 
			AND er.EmployeeID = @EmployeeID
			--and (xDept.DeptCode > 0
			--or er.AttributedToAllClinicsInCommunity = 1)
		) as tblCurrent 
) as tblFinalCurrent 
ORDER BY RemarkText




-- Historic Remarks 
SELECT RecordType , RemarkID, RemarkText, RemarkTemplate, ValidFROM, ValidTo, Internetdisplay, Deleted, 
	AttributedToAllClinicsInCommunity as AttributedToAllClinics,  AreasNames , DeptsCodes, RelevantForSystemManager
FROM 
(
	SELECT RecordType , RemarkID, RemarkText, RemarkTemplate, ValidFROM, ValidTo, Internetdisplay, Deleted, 
	AttributedToAllClinicsInCommunity, AreasNames, DeptsCodes, RelevantForSystemManager
	FROM(
			SELECT  distinct 1 as RecordType, er.EmployeeRemarkID as RemarkID, RemarkText as RemarkText,  
				CASE 
					WHEN dgr.Remark  is not null then dgr.Remark  
					ELSE '' 
				end as RemarkTemplate , convert(varchar, ValidFROM, 103) as ValidFROM, convert(varchar, ValidTo , 103)  as ValidTo ,
				displayInInternet as Internetdisplay, 0 as Deleted , 			
				AttributedToAllClinicsInCommunity , 
				dbo.fun_GetEmployeeRemarkDeptsNames(er.EmployeeRemarkID,@EmployeeID )  as  AreasNames, 
				dbo.fun_GetEmployeeRemarkDeptsCodes(er.EmployeeRemarkID,@EmployeeID )  as  DeptsCodes,
				IsNull(dgr.RelevantForSystemManager, 0) as RelevantForSystemManager
			FROM EmployeeRemarks as er 
			LEFT JOIN dbo.DIC_GeneralRemarks as dgr ON er.DicRemarkID = dgr.RemarkID 
			LEFT JOIN x_Dept_Employee_EmployeeRemarks as xDept ON er.EmployeeRemarkID = xDept.EmployeeRemarkID 
			WHERE DateDiff(day, ValidTo, getdate()) >= 1
			AND er.EmployeeID = @EmployeeID
			--and (xDept.DeptCode > 0
			--or er.AttributedToAllClinicsInCommunity = 1)
		) as tblCurrent 
) as tblFinalCurrent 
ORDER BY RemarkText


GO

GRANT EXEC ON rpc_GetEmployeeRemarksForUpdate TO PUBLIC
GO
 
-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeeServicesExtended')
	BEGIN
		DROP  Procedure  rpc_getEmployeeServicesExtended
	END

GO

CREATE Procedure [dbo].[rpc_getEmployeeServicesExtended]
(
	@employeeID INT,
	@deptCode INT,					 -- in case @deptCode = null or @deptCode <= 0  -- all depts
	@IsLinkedToEmployeeOnly bit,		-- in case = 0 returns with whole service list;
									-- = 1 returns only services Linked To this Employee
	@IsService bit
)

AS 

DECLARE @RelevantForProfession int

SELECT @RelevantForProfession = RelevantForProfession
FROM EmployeeSector
INNER JOIN Employee ON EmployeeSector.EmployeeSectorCode = Employee.EmployeeSectorCode
WHERE Employee.EmployeeID = @employeeID

select distinct
ServiceCode 
,ServiceDescription
,ServiceCategoryID 
,LinkedToEmployee
,LinkedToEmployeeInDept
,HasReceptionInDept
,CategoryIDForSort
,CategoryDescrForSort
,AgreementType
,IsProfession
from

-- ServiceCategory table
( -- begin union
SELECT  
ISNULL(SerCatSer.ServiceCategoryID, -1) as 'ServiceCode'   --'ServiceCategoryID'
,ISNULL(SerCat.ServiceCategoryDescription, 'שירותים שונים') as 'ServiceDescription' ---'ServiceCategoryDescription'
,null as 'ServiceCategoryID'
,0 as 'LinkedToEmployee'
,0 as 'LinkedToEmployeeInDept'
,0 as 'HasReceptionInDept'
,ISNULL(SerCatSer.ServiceCategoryID, -1)as 'CategoryIDForSort'
,ISNULL(SerCat.ServiceCategoryDescription, 'תתתת') AS 'CategoryDescrForSort'
,null as 'AgreementType'
,0 as IsProfession

--"ServiceCategory-From" - block begin ---"ServiceCategory-From" - block  equal to "Professions-From" block 
FROM [Services] as Ser
left JOIN x_Services_EmployeeSector xSerEmSec 
	ON Ser.ServiceCode = xSerEmSec.ServiceCode

-- filter by Employee.EmployeeSectorCode of this Employee(@employeeID)
inner JOIN Employee 
	ON (xSerEmSec.EmployeeSectorCode is null or Employee.IsMedicalTeam = 1
		or xSerEmSec.EmployeeSectorCode = Employee.EmployeeSectorCode)
	 AND Employee.EmployeeID = @employeeID
	 AND (@IsService is null OR Ser.IsService = @IsService)


LEFT JOIN EmployeeServices EmpSer
	ON Ser.ServiceCode = EmpSer.serviceCode 
	AND EmpSer.EmployeeID = @employeeID
	
LEFT JOIN x_Dept_Employee as xd 
	ON xd.EmployeeID = @employeeID AND xd.deptCode = @deptCode

LEFT JOIN x_Dept_Employee_Service xdes
	ON xd.EmployeeID = @employeeID 
	AND xdes.serviceCode = Ser.ServiceCode
	and (@deptCode is null 
		or @deptCode <= 0
		or xd.DeptEmployeeID = xdes.DeptEmployeeID)

left JOIN  x_ServiceCategories_Services as SerCatSer
	ON 	SerCatSer.ServiceCode = Ser.ServiceCode
	
left join ServiceCategories SerCat 
	on  SerCat.ServiceCategoryID = SerCatSer.ServiceCategoryID

	
where (@IsLinkedToEmployeeOnly = 0 or EmpSer.serviceCode is not null)
	and(xd.AgreementType is null
		or xd.AgreementType in (1,2) and Ser.IsInCommunity = 1
		or xd.AgreementType in (3,4) and Ser.IsInMushlam = 1
		or xd.AgreementType in (5,6) and Ser.IsInHospitals = 1)
	AND (@RelevantForProfession = 1 OR Ser.IsProfession = 0)
--- end from block

union

------------- Professions table
SELECT 
Ser.ServiceCode
,Ser.ServiceDescription
,ISNULL(SerCatSer.ServiceCategoryID, -1) AS 'ServiceCategoryID'
,CASE IsNull(EmpSer.serviceCode,0) WHEN 0 THEN 0 ELSE 1 END as 'LinkedToEmployee' 
,CASE IsNull(xdes.serviceCode, 0) WHEN 0 THEN 0 ELSE 1 END as 'LinkedToEmployeeInDept'
,'HasReceptionInDept' = 
(case
(
select COUNT(*) 
from deptEmployeeReception der 
INNER JOIN deptEmployeeReceptionServices ders 
	ON der.ReceptionID = ders.ReceptionID 
	AND ders.serviceCode = Ser.ServiceCode
	and (der.ValidTo IS NULL 
		OR DATEDIFF(dd, der.ValidTo, GETDATE()) <= 0)
)
when 0 then 0
else 1 end
)
,ISNULL(SerCatSer.ServiceCategoryID, -1) AS 'CategoryIDForSort'
,ISNULL(SerCat.ServiceCategoryDescription, 'תתתת') AS 'CategoryDescrForSort'
,case when (Ser.IsInMushlam = 1
			and isnull(Ser.IsInCommunity, 0) = 0 
			and isnull(Ser.IsInHospitals, 0) = 0) 
	then 3 else null end as 'AgreementType'
,Ser.IsProfession
	
	
------ "Services-From" block 
FROM [Services] as Ser
left JOIN x_Services_EmployeeSector xSerEmSec 
	ON Ser.ServiceCode = xSerEmSec.ServiceCode

-- filter by Employee.EmployeeSectorCode of this Employee(@employeeID)
INNER JOIN Employee 
	ON (xSerEmSec.EmployeeSectorCode is null or Employee.IsMedicalTeam = 1
		or xSerEmSec.EmployeeSectorCode = Employee.EmployeeSectorCode)
	 AND Employee.EmployeeID = @employeeID
	 AND (@IsService is null OR Ser.IsService = @IsService)
	 
LEFT JOIN x_Dept_Employee xd 
	ON Employee.employeeID = xd.employeeID AND (xd.deptCode = @deptCode OR @deptCode is null OR @deptCode <= 0)

LEFT JOIN EmployeeServices EmpSer
	ON Ser.ServiceCode = EmpSer.serviceCode 
	AND EmpSer.EmployeeID = @employeeID

LEFT JOIN x_Dept_Employee_Service xdes
	ON xd.DeptEmployeeID = xdes.DeptEmployeeID
	AND xdes.serviceCode = Ser.ServiceCode

left JOIN  x_ServiceCategories_Services as SerCatSer
	ON 	SerCatSer.ServiceCode = Ser.ServiceCode
	
left join ServiceCategories SerCat 
	on  SerCat.ServiceCategoryID = SerCatSer.ServiceCategoryID


where (@IsLinkedToEmployeeOnly = 0 or EmpSer.serviceCode is not null)
	and(xd.AgreementType is null
		or xd.AgreementType in (1,2) and Ser.IsInCommunity = 1
		or xd.AgreementType in (3,4) and Ser.IsInMushlam = 1
		or xd.AgreementType in (5,6) and Ser.IsInHospitals = 1)
	AND (@RelevantForProfession = 1 OR Ser.IsProfession = 0)
----- "Professions-From" block end
) as temp     -- end union


ORDER BY CategoryDescrForSort, ServiceCategoryID, ServiceDescription
GO

GRANT EXEC ON rpc_getEmployeeServicesExtended TO PUBLIC

GO


-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'fun_getEmployeeQueueOrderPhones_ByQueueOrderGroup')
	BEGIN
		DROP  FUNCTION  fun_getEmployeeQueueOrderPhones_ByQueueOrderGroup
	END
GO

CREATE FUNCTION [dbo].[fun_getEmployeeQueueOrderPhones_ByQueueOrderGroup] (@DeptEmployeeID int, @ServiceCode int)
RETURNS varchar(100)
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @strPhones varchar(1000) SET @strPhones = ''

	SELECT @strPhones = @strPhones + dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) + '<br>'
	FROM EmployeeServiceQueueOrderPhones phones
	INNER JOIN EmployeeServiceQueueOrderMethod method ON phones.EmployeeServiceQueueOrderMethodID = method.EmployeeServiceQueueOrderMethodID
	INNER JOIN x_dept_employee_service xdes ON method.x_dept_employee_serviceID = xdes.x_dept_employee_serviceID 
	WHERE xdes.DeptEmployeeID  = @DeptEmployeeID	
	AND xdes.serviceCode = @ServiceCode


	IF(LEN(@strPhones) = 0)	
		BEGIN
			SET @strPhones = '' 
		END

	RETURN( @strPhones )

END
GO

grant exec on fun_getEmployeeQueueOrderPhones_ByQueueOrderGroup to public 
go 

-- *************************************** 
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'rfn_GetDeptEmployeePhoneDescriptions')
	BEGIN
		DROP  FUNCTION  rfn_GetDeptEmployeePhoneDescriptions
	END

GO

create function [dbo].rfn_GetDeptEmployeePhoneDescriptions(@DeptCode int, @employeeID bigint) 
RETURNS varchar(500)
WITH EXECUTE AS CALLER

AS
BEGIN
	declare @Str varchar(500) 
	set @Str = ''
	
	SELECT @Str = @Str + phone + ' ; ' 
	FROM
		(select distinct phone = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension),
			  DEP.phoneType, DEP.phoneOrder
		from DeptEmployeePhones as dep
		INNER JOIN x_dept_employee xd ON dep.DeptEmployeeID = xd.DeptEmployeeID
		WHERE xd.deptCode = @DeptCode 
		AND xd.employeeID = @employeeID
		)
		as d 
	order by d.phoneType, d.phoneOrder
	
	IF(LEN(@Str)) > 0 -- to remove last ';'
		BEGIN
			SET @Str = Left( @Str, LEN(@Str) -1 )
		END
	
	return (@Str);
end 

go 
grant exec on rfn_GetDeptEmployeePhoneDescriptions to public 
go

-- *************************************** 

IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rfn_GetDeptEmployeeProfessionDescriptions')
	BEGIN
		DROP  FUNCTION  dbo.rfn_GetDeptEmployeeProfessionDescriptions
	END

GO

--case @deptCode = -1  -- means all depts
--case @employeeID = -1  -- means all employees
CREATE FUNCTION [dbo].rfn_GetDeptEmployeeProfessionDescriptions(@deptCode bigint, @employeeID bigint) 
RETURNS varchar(500)
AS
BEGIN

	declare @ProfessionsStr varchar(500) 
	set @ProfessionsStr = ''
	
	SELECT @ProfessionsStr = @ProfessionsStr + d.ServiceDescription + '; ' 
	FROM
		(select distinct [Services].ServiceDescription, [Services].ServiceCode
		from x_Dept_Employee_Service as xDES
		INNER JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
		INNER JOIN [Services] on xDES.ServiceCode = [Services].ServiceCode
		WHERE (@deptCode = -1 or xd.deptCode = @deptCode)
		AND (@employeeID = -1 or xd.employeeID = @employeeID)
		AND [Services].IsProfession = 1
		) 
		as d 
	order by d.ServiceDescription
	
	IF(LEN(@ProfessionsStr)) > 0 -- to remove last ','
		BEGIN
			SET @ProfessionsStr = Left( @ProfessionsStr, LEN(@ProfessionsStr) -1 )
		END
		
	return (@ProfessionsStr);

end 

go 

grant exec on dbo.rfn_GetDeptEmployeeProfessionDescriptions to public 
go

-- *************************************** 


IF EXISTS (SELECT * FROM sysobjects WHERE name = 'fun_GetEmployeeServiceQueueOrderGroup')
	BEGIN
		DROP  FUNCTION  fun_GetEmployeeServiceQueueOrderGroup
	END
GO

CREATE FUNCTION [dbo].[fun_GetEmployeeServiceQueueOrderGroup] (@DeptEmployeeID int, @ServiceCode int)
RETURNS varchar(100)
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @ESQOGroup varchar(50) SET @ESQOGroup = ''
	DECLARE @Temp int SET @Temp = 0
	DECLARE @TempStr varchar(50) SET @TempStr = ''
	DECLARE @EmptyGroup varchar(50) SET @EmptyGroup = '00000000000000'
	DECLARE @EmployeeIDPrefix varchar(50) SET @EmployeeIDPrefix = RIGHT('00000000000' + CAST(@DeptEmployeeID as varchar(11)), 11)
	DECLARE @ServicePhone varchar(50) SET @ServicePhone = '00000000000'
			
	IF(@ServiceCode <> 0)
	BEGIN
		SELECT @ESQOGroup = @ESQOGroup + CAST(IsNull(xdes.QueueOrder, 0) as varchar(1))
		FROM x_Dept_Employee_Service xdes 
		INNER JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
		WHERE xd.DeptEmployeeID = @DeptEmployeeID
		AND xdes.ServiceCode = @ServiceCode

		IF( @ESQOGroup is null OR @ESQOGroup = '')
			SET @ESQOGroup = '0'
			
		SELECT @Temp = @Temp + (ESQOM.QueueOrderMethod * ESQOM.QueueOrderMethod)
		FROM EmployeeServiceQueueOrderMethod esqom
		INNER JOIN x_dept_employee_service xdes ON esqom.x_dept_employee_serviceID  = xdes.x_dept_employee_serviceID
		INNER JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
		WHERE xd.DeptEmployeeID = @DeptEmployeeID
		AND xdes.ServiceCode = @ServiceCode
		
		
		SELECT TOP 1 @TempStr = --@TempStr +
			CAST(ISNULL(prePrefix, 0) as varchar(1)) + 
			RIGHT('000' + CAST(ISNULL(prefixValue, 0) as varchar(3)), 3) +
			RIGHT('0000000' + CAST(ISNULL(phone, 0) as varchar(7)), 7)
		FROM EmployeeServiceQueueOrderPhones esqohp
		INNER JOIN DIC_PhonePrefix ON esqohp.prefix = DIC_PhonePrefix.prefixCode
		INNER JOIN EmployeeServiceQueueOrderMethod esqom ON esqohp.EmployeeServiceQueueOrderMethodID = esqom.EmployeeServiceQueueOrderMethodID
		INNER JOIN x_dept_employee_service xdes ON esqom.x_dept_employee_serviceID = xdes.x_dept_employee_serviceID
		INNER JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID		
		WHERE xd.DeptEmployeeID = @DeptEmployeeID
		AND xdes.ServiceCode = @ServiceCode

		IF( @TempStr is null OR @TempStr = '')
			SET @TempStr = '00000000000'

		SET @ESQOGroup = @ESQOGroup + RIGHT('00' + CAST(ISNULL(@Temp, 0) as varchar(2)), 2) + 
						ISNULL(@TempStr, '00000000000')

		SELECT TOP 1 @ServicePhone = 
			CAST(ISNULL(prePrefix, 0) as varchar(1)) + 
			RIGHT('000' + CAST(ISNULL(prefixValue, 0) as varchar(3)), 3) +
			RIGHT('0000000' + CAST(ISNULL(phone, 0) as varchar(7)), 7)
		FROM EmployeeServicePhones esp
		INNER JOIN DIC_PhonePrefix ON esp.prefix = DIC_PhonePrefix.prefixCode
		INNER JOIN x_Dept_Employee_Service xdes ON esp.x_Dept_Employee_ServiceID = xdes.x_Dept_Employee_ServiceID
		INNER JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
		WHERE xd.DeptEmployeeID = @DeptEmployeeID
		AND xdes.ServiceCode = @ServiceCode 

		IF( @ServicePhone is null OR @TempStr = '')
			SET @ServicePhone = '00000000000'

	END
	ELSE
	BEGIN
		SET @ESQOGroup = @EmptyGroup
	END
	
	-- if there's no queue order via employee service
	-- try to get queue order via employee
	IF(@ESQOGroup = @EmptyGroup) 
	BEGIN
		SET @ESQOGroup = ''
		SET @Temp = 0
		SET @TempStr = ''	
		
		SELECT @ESQOGroup = @ESQOGroup + CAST(IsNull(x_D_E.QueueOrder, 0) as varchar(1))
		FROM x_Dept_Employee x_D_E 
		WHERE x_D_E.DeptEmployeeID = @DeptEmployeeID
		
		IF( @ESQOGroup is null OR @ESQOGroup = '')
			SET @ESQOGroup = '0'
		
		SELECT @Temp = @Temp + (EQOM.QueueOrderMethod * EQOM.QueueOrderMethod)
		FROM EmployeeQueueOrderMethod eqom
		INNER JOIN x_dept_employee xd ON eqom.DeptEmployeeID = xd.DeptEmployeeID		
		WHERE xd.DeptEmployeeID = @DeptEmployeeID

		SELECT TOP 1 @TempStr = 
			CAST(ISNULL(prePrefix, 0) as varchar(1)) + 
			RIGHT('000' + CAST(ISNULL(prefixValue, 0) as varchar(3)), 3) +
			RIGHT('0000000' + CAST(ISNULL(phone, 0) as varchar(7)), 7)
		FROM DeptEmployeeQueueOrderPhones DEQOPh
		INNER JOIN DIC_PhonePrefix ON DEQOPh.prefix = DIC_PhonePrefix.prefixCode
		INNER JOIN EmployeeQueueOrderMethod EQOM ON DEQOPh.QueueOrderMethodID = EQOM.QueueOrderMethodID
		INNER JOIN x_dept_employee xd ON EQOM.DeptEmployeeID = xd.DeptEmployeeID		
		WHERE xd.DeptEmployeeID = @DeptEmployeeID

		IF( @TempStr is null OR @TempStr = '')
			SET @TempStr = '00000000000'

		SET @ESQOGroup = @ESQOGroup 
			+ RIGHT('00' + CAST(ISNULL(@Temp, 0) as varchar(2)), 2)
			+ @TempStr
		
	END

	RETURN @EmployeeIDPrefix + @ESQOGroup + @ServicePhone

END
GO

grant exec on fun_GetEmployeeServiceQueueOrderGroup to public 
go 

-- *************************************** 

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_getEmployeeQueueOrderPhones_Grouped')
	BEGIN
		DROP  FUNCTION  fun_getEmployeeQueueOrderPhones_Grouped
	END
GO


CREATE FUNCTION [dbo].fun_getEmployeeQueueOrderPhones_Grouped(@DeptEmployeeID int, @DeptCode int, @EmployeeServiceQueueOrderGroup varchar(50))
RETURNS varchar(1000)
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @ThereIsQueueOrderViaClinicPhone int SET @ThereIsQueueOrderViaClinicPhone = 0
	DECLARE @strPhones varchar(1000) SET @strPhones = ''
	DECLARE @PhoneTable as Table
	(
		Phone varchar(20),
		ShowPhonePicture int,
		SpecialPhoneNumberRequired int
	)
	
	INSERT INTO @PhoneTable
	SELECT 
	'Phone' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension),-- + '<br>'
	ShowPhonePicture, SpecialPhoneNumberRequired
	FROM EmployeeServiceQueueOrderMethod ESQOM
	JOIN DIC_QueueOrderMethod ON ESQOM.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
	LEFT JOIN EmployeeServiceQueueOrderPhones ON ESQOM.EmployeeServiceQueueOrderMethodID = EmployeeServiceQueueOrderPhones.EmployeeServiceQueueOrderMethodID
	JOIN x_Dept_Employee_Service x_DES ON ESQOM.x_dept_employee_serviceID = x_DES.x_dept_employee_serviceID
	JOIN x_dept_employee x_DE ON x_DES.DeptEmployeeID = x_DE.DeptemployeeID
	WHERE x_DE.DeptEmployeeID = @DeptEmployeeID	
	AND dbo.fun_GetEmployeeServiceQueueOrderGroup(x_DE.DeptEmployeeID, x_DES.serviceCode ) = @EmployeeServiceQueueOrderGroup
	
	UNION
	
	SELECT 'Phone' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension),-- + '<br>'
	ShowPhonePicture, SpecialPhoneNumberRequired	
	FROM EmployeeQueueOrderMethod
	JOIN DIC_QueueOrderMethod ON EmployeeQueueOrderMethod.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
	LEFT JOIN DeptEmployeeQueueOrderPhones ON EmployeeQueueOrderMethod.QueueOrderMethodID = DeptEmployeeQueueOrderPhones.QueueOrderMethodID
	INNER JOIN x_dept_employee x_DE ON EmployeeQueueOrderMethod.DeptEmployeeID = x_DE.DeptemployeeID
	WHERE x_DE.DeptEmployeeID  = @DeptEmployeeID
	AND dbo.fun_GetEmployeeServiceQueueOrderGroup(x_DE.DeptEmployeeID, 0 ) = @EmployeeServiceQueueOrderGroup

	SELECT @strPhones = @strPhones + CASE WHEN Phone = '' THEN '' ELSE Phone + '<br>' END
	FROM @PhoneTable
		
	SET @ThereIsQueueOrderViaClinicPhone = 
		(SELECT Count(*)
		FROM @PhoneTable
		WHERE ShowPhonePicture = 1 AND SpecialPhoneNumberRequired = 0
		)
	
	IF(@ThereIsQueueOrderViaClinicPhone > 0)
	BEGIN
		SELECT TOP 1 @strPhones = @strPhones + dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) + '<br>'
		FROM DeptPhones
		WHERE deptCode = @DeptCode AND DeptPhones.phoneType = 1
		ORDER BY phoneOrder
		
	END
	
	
	IF(LEN(@strPhones) = 0)	
		BEGIN
			SET @strPhones = ''--'&nbsp;'
		END
	RETURN( @strPhones )
	
END
GO 

grant exec on fun_getEmployeeQueueOrderPhones_Grouped to public 
GO
 

-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptEmployeeServicesForReceptionToAdd')
	BEGIN
		DROP  Procedure  rpc_getDeptEmployeeServicesForReceptionToAdd
	END

GO

CREATE Procedure rpc_getDeptEmployeeServicesForReceptionToAdd
	(
		@receptionID int,
		@deptCode int,
		@employeeID int
	)

AS

IF @receptionID is null 
BEGIN
	SET @receptionID = 0
END

IF(@receptionID <> 0)
BEGIN
SELECT
xdes.serviceCode,
services.serviceDescription,

-- The last "LEFT JOIN" is for this purpose only:
-- if 'canBeAdded'== 1 then an appropriate service isn't attributed to the reception yet AND can be attributed
-- When @receptionID is NUL it means that it's about to add a new reception and all the professions could be added
'canBeAdded' = CASE IsNull(deptEmployeeReceptionServices.serviceCode, 0) WHEN 0 THEN 0 ELSE 1 END,
'parentCode' = IsNull(parentCode, 0),
'groupCode' = services.serviceCode,
'groupName' = serviceDescription

FROM x_Dept_Employee_Service as xdes
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
INNER JOIN services ON xdes.serviceCode = services.serviceCode
LEFT JOIN serviceParentChild ON services.serviceCode = serviceParentChild.childCode

LEFT JOIN deptEmployeeReceptionServices ON xdes.serviceCode = deptEmployeeReceptionServices.serviceCode
	AND ( @receptionID = 0 OR deptEmployeeReceptionServices.receptionID = @receptionID)

WHERE xd.EmployeeID = @EmployeeID
AND xd.deptCode = @DeptCode
AND parentCode is null

UNION

SELECT
xdes.serviceCode,
services.serviceDescription,
'canBeAdded' = CASE IsNull(deptEmployeeReceptionServices.serviceCode, 0) WHEN 0 THEN 0 ELSE 1 END,
'parentCode' = IsNull(parentCode, 0),
'groupCode' = parentCode,
'groupName' = P.serviceDescription

FROM x_Dept_Employee_Service as xdes
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xdes.DeptEmployeeID
INNER JOIN services ON xdes.serviceCode = services.serviceCode
LEFT JOIN serviceParentChild ON services.serviceCode = serviceParentChild.childCode

LEFT JOIN deptEmployeeReceptionServices ON xdes.serviceCode = deptEmployeeReceptionServices.serviceCode
	AND ( @receptionID = 0 OR deptEmployeeReceptionServices.receptionID = @receptionID)

INNER JOIN services as P ON serviceParentChild.parentCode = P.serviceCode

WHERE xd.EmployeeID = @EmployeeID
AND xd.deptCode = @DeptCode
AND parentCode is NOT null

ORDER BY groupName, parentCode
END

ELSE

BEGIN
SELECT
x_D_E_S.serviceCode,
service.serviceDescription,

'canBeAdded' = 1,
'parentCode' = IsNull(parentCode, 0),
'groupCode' = service.serviceCode,
'groupName' = serviceDescription

FROM x_Dept_Employee_Service as x_D_E_S
INNER JOIN service ON x_D_E_S.serviceCode = service.serviceCode
LEFT JOIN serviceParentChild ON service.serviceCode = serviceParentChild.childCode

WHERE x_D_E_S.EmployeeID = @EmployeeID
AND x_D_E_S.deptCode = @DeptCode
AND parentCode is null

UNION

SELECT
x_D_E_S.serviceCode,
service.serviceDescription,
'canBeAdded' = 1,
'parentCode' = IsNull(parentCode, 0),
'groupCode' = parentCode,
'groupName' = P.serviceDescription

FROM x_Dept_Employee_Service as x_D_E_S
INNER JOIN service ON x_D_E_S.serviceCode = service.serviceCode
LEFT JOIN serviceParentChild ON service.serviceCode = serviceParentChild.childCode

INNER JOIN service as P ON serviceParentChild.parentCode = P.serviceCode

WHERE EmployeeID = @EmployeeID
AND deptCode = @DeptCode
AND parentCode is NOT null

ORDER BY groupName, parentCode

END
GO

GRANT EXEC ON rpc_getDeptEmployeeServicesForReceptionToAdd TO PUBLIC

GO


-- *********************************************************************************************************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetEmployeeServicePhones')
	BEGIN
		DROP  Procedure  rpc_GetEmployeeServicePhones
	END
GO

CREATE PROCEDURE [dbo].[rpc_GetEmployeeServicePhones]
	@x_Dept_Employee_ServiceID int, 
	@phoneType int,
	@SimulateCascadeUpdate bit

AS
	DECLARE @GetCascade BIT

	IF(@SimulateCascadeUpdate is null OR @SimulateCascadeUpdate = 0)
		SELECT @GetCascade = ISNULL(CascadeUpdateEmployeeServicePhones, 0) 
		FROM x_Dept_Employee_Service
		WHERE x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID
	ELSE
		SET @GetCascade = @SimulateCascadeUpdate

	IF @GetCascade = 0
		BEGIN
			SELECT EmployeeServicePhones.phoneType, phoneOrder, prePrefix, prefix as 'prefixCode', prefixValue as 'prefixText', phone, extension,
				0 as 'GetCascade'
			FROM EmployeeServicePhones
			INNER JOIN DIC_PhonePrefix ON EmployeeServicePhones.prefix = DIC_PhonePrefix.prefixCode
			WHERE (@x_Dept_Employee_ServiceID is null OR x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID)
			AND (@phoneType is null OR EmployeeServicePhones.phoneType = @phoneType)
			ORDER BY phoneOrder
		END
	ELSE
		BEGIN
			SELECT @GetCascade = ISNULL(CascadeUpdateDeptEmployeePhonesFromClinic, 0) 
			FROM x_Dept_Employee xd
			INNER JOIN x_Dept_Employee_Service xdes ON xd.DeptEmployeeID = xdes.DeptEmployeeID				
			WHERE x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID

			IF @GetCascade = 0
				BEGIN
					SELECT dep.phoneType, phoneOrder, prePrefix, prefix as 'prefixCode', prefixValue as 'prefixText', phone, extension,
						1 as 'GetCascade'
					FROM DeptEmployeePhones dep
					INNER JOIN DIC_PhoneTypes phoneTypes ON dep.phoneType = phoneTypes.phoneTypeCode
					INNER JOIN DIC_PhonePrefix dic ON dep.prefix = dic.prefixCode
					INNER JOIN x_Dept_Employee_Service xdes ON dep.DeptEmployeeID = xdes.DeptEmployeeID						
					WHERE xdes.x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID
					AND dep.phoneType <> 2
					ORDER BY dep.phoneType, phoneOrder
				END
			ELSE
				BEGIN
					SELECT dp.phoneType, phoneOrder, prePrefix, prefix as 'prefixCode', prefixValue as 'prefixText', phone, extension,
																													  1 as 'GetCascade'
					FROM DeptPhones dp
					INNER JOIN DIC_PhonePrefix dic ON dp.prefix = dic.prefixCode
					INNER JOIN x_Dept_Employee xd ON dp.deptCode = xd.deptCode
					INNER JOIN x_Dept_Employee_Service xdes ON xd.DeptEmployeeID = xdes.DeptEmployeeID
					WHERE xdes.x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID
					AND dp.phoneType <> 2
								
				END	
		END
		
		SELECT CASE ISNULL(@SimulateCascadeUpdate, 0) 
			WHEN 0 THEN ISNULL(CascadeUpdateEmployeeServicePhones, 0) ELSE ISNULL(@SimulateCascadeUpdate, 0) END as CascadeUpdateEmployeeServicePhones
		FROM x_Dept_Employee_Service
		WHERE x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID

GO


GRANT EXEC ON dbo.rpc_GetEmployeeServicePhones TO PUBLIC
GO

-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetEmployeeServiceQueueOrderDescription')
	BEGIN
		DROP  Procedure  rpc_GetEmployeeServiceQueueOrderDescription
	END

GO

CREATE Procedure dbo.rpc_GetEmployeeServiceQueueOrderDescription
(
	@x_Dept_Employee_ServiceID int
)


AS


SELECT 
xd.deptCode,
xd.EmployeeID,
xDES.serviceCode,
qo.QueueOrder,
qo.QueueOrderDescription,
0 as QueueOrderMethod
 
FROM x_Dept_Employee_Service xdes
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
INNER JOIN Dic_QueueOrder qo ON xDES.QueueOrder = qo.QueueOrder
WHERE xDES.x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID
AND permitorderMethods = 0 


UNION 

SELECT 
xd.deptCode,
xd.EmployeeID,
xDES.serviceCode,
qo.QueueOrder,
CASE WHEN dbo.fun_ParsePhoneNumberWithExtension(deptPhones.prePrefix,deptPhones.prefix,deptPhones.phone,deptPhones.extension) = '' THEN 
			CASE WHEN dbo.fun_ParsePhoneNumberWithExtension(queuePhones.prePrefix,queuePhones.prefix,queuePhones.phone,queuePhones.extension) = '' 
					THEN qom.QueueOrderMethodDescription 
				 ELSE dbo.fun_ParsePhoneNumberWithExtension(queuePhones.prePrefix,queuePhones.prefix,queuePhones.phone,queuePhones.extension) 
			END
	  ELSE dbo.fun_ParsePhoneNumberWithExtension(deptPhones.prePrefix,deptPhones.prefix,deptPhones.phone,deptPhones.extension) END as QueueOrderMethodDescription,
ESQOM.QueueOrderMethod
 
FROM x_Dept_Employee_Service xdes
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
LEFT JOIN EmployeeServiceQueueOrderMethod esqom
	ON xdes.x_Dept_Employee_ServiceID = esqom.x_dept_employee_serviceID 	
LEFT JOIN DeptPhones ON deptPhones.DeptCode = xd.deptCode AND PhoneType = 1 AND PhoneOrder = 1 AND QueueOrderMethod = 1
LEFT JOIN EmployeeServiceQueueOrderPhones queuePhones ON ESQOM.EmployeeServiceQueueOrderMethodID = queuePhones.EmployeeServiceQueueOrderMethodID
INNER JOIN Dic_QueueOrder qo ON xDES.QueueOrder = qo.QueueOrder
LEFT JOIN DIC_QueueOrderMethod qom ON ESQOM.QueueOrderMethod = qom.QueueOrderMethod
WHERE xDES.x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID
AND permitOrderMethods = 1 



GO

GRANT EXEC ON rpc_GetEmployeeServiceQueueOrderDescription TO PUBLIC

GO

-- ***************************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeeServicesForDept')
	BEGIN
		DROP  Procedure  rpc_getEmployeeServicesForDept
	END

GO
-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_getEmployeeServiceQueueOrderPhones_All')
	BEGIN
		DROP  FUNCTION  fun_getEmployeeServiceQueueOrderPhones_All
	END
GO

CREATE FUNCTION [dbo].fun_getEmployeeServiceQueueOrderPhones_All(@EmployeeID bigint, @DeptCode int, @ServiceCode int)
RETURNS varchar(1000)
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @ThereIsQueueOrderViaClinicPhone int
	SET @ThereIsQueueOrderViaClinicPhone = 0
	
	DECLARE @strPhones varchar(1000)
	SET @strPhones = ''
	
	
	DECLARE @employee_service_id INT
	SELECT @employee_service_id  =	x_dept_employee_serviceID
									FROM x_dept_employee xd 
									INNER JOIN x_dept_employee_service xdes ON xd.DeptEmployeeID = xdes.DeptEmployeeID
									WHERE xd.DeptCode = @deptCode
									AND xd.EmployeeID = @employeeID
									AND xdes.ServiceCode = @serviceCode

	SELECT @strPhones = @strPhones + dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) + '<br>'
	FROM EmployeeServiceQueueOrderPhones phones
	INNER JOIN EmployeeServiceQueueOrderMethod method ON phones.EmployeeServiceQueueOrderMethodID = method.EmployeeServiceQueueOrderMethodID
	WHERE method.x_dept_employee_serviceID  = @employee_service_id
	

SET @ThereIsQueueOrderViaClinicPhone =	
	(SELECT Count(*)
	FROM EmployeeServiceQueueOrderMethod method
	INNER JOIN DIC_QueueOrderMethod ON method.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
	WHERE method.x_dept_employee_serviceID = @employee_service_id	
	AND ShowPhonePicture = 1 AND SpecialPhoneNumberRequired = 0)
	
	IF(@ThereIsQueueOrderViaClinicPhone = 1)
	BEGIN
		SELECT TOP 1 @strPhones = @strPhones + dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) + '<br>'
		FROM DeptPhones
		WHERE deptCode = @DeptCode 
		AND DeptPhones.phoneType = 1
		ORDER BY phoneOrder
		
	END
	
	
	IF(LEN(@strPhones) = 0)	
		BEGIN
			SET @strPhones = ''--'&nbsp;'
		END
	RETURN( @strPhones )
	
END
GO 

grant exec on fun_getEmployeeServiceQueueOrderPhones_All to public 
GO

-- ***************************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetServicesForPopup')
	BEGIN
		DROP  Procedure  rpc_GetServicesForPopup
	END

GO

-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertDeptEmployeeServiceRemark')
	BEGIN
		DROP  Procedure  rpc_InsertDeptEmployeeServiceRemark
	END

GO

CREATE Procedure dbo.rpc_InsertDeptEmployeeServiceRemark
(
	@employeeID BIGINT,
	@deptCode INT,  
	@serviceCode INT, 
	@remarkID INT, 
	@remarkText VARCHAR(500), 
    @dateFrom DATETIME, 
    @dateTo DATETIME,  
    @displayOnInternet BIT, 
    @userName VARCHAR(30)
)

AS

DECLARE @deptEmployeeServiceID INT

SELECT @deptEmployeeServiceID = x_Dept_Employee_ServiceID		
								FROM x_Dept_Employee_Service xdes		
								INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
								WHERE xd.deptCode = @deptCode
								AND xd.employeeID = @employeeID
								AND xdes.serviceCode = @serviceCode 

IF EXISTS 
(
	SELECT * 
	FROM DeptEmployeeServiceRemarks
	WHERE x_dept_employee_serviceID = @deptEmployeeServiceID
)

	UPDATE DeptEmployeeServiceRemarks
	SET RemarkID = @remarkID, 
		RemarkText = @remarkText, 
		ValidFrom = @dateFrom,
		ValidTo = @dateTo,
		DisplayInInternet = @displayOnInternet,
		UpdateDate = GETDATE(),
		UpdateUser = @userName

ELSE
BEGIN

INSERT INTO DeptEmployeeServiceRemarks
VALUES (@remarkID, @remarkText, @dateFrom, @dateTo,  @displayOnInternet, GETDATE(), @userName, @deptEmployeeServiceID )


UPDATE x_dept_employee_service
SET DeptEmployeeServiceRemarkID = @@IDENTITY
WHERE x_Dept_Employee_ServiceID = @deptEmployeeServiceID

END

GO


GRANT EXEC ON dbo.rpc_InsertDeptEmployeeServiceRemark TO PUBLIC

GO

-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertDoctorInClinic')
	BEGIN
		DROP  Procedure  rpc_InsertDoctorInClinic
	END

GO

CREATE PROCEDURE dbo.rpc_InsertDoctorInClinic
(
		@DeptCode int,
		@employeeID int,
		@agreementType int,
		@updateUserName varchar(50),
		@active int,
		@ErrorStatus int output,
		@deptEmployeeID int output
)

AS

IF(NOT EXISTS (SELECT EmployeeID FROM Employee WHERE EmployeeID = @employeeID))
BEGIN
	RETURN
END

--DECLARE @deptEmployeeID INT
	
		INSERT INTO x_Dept_Employee
		(
			DeptCode,
			employeeID,
			AgreementType,
			updateUserName,
			active
		)
		VALUES
		(
			@DeptCode,
			@employeeID,
			@agreementType,
			@updateUserName,
			cast (@active as tinyint)
		)
		
SET @deptEmployeeID = @@IDENTITY		
		
	/* After Employee was added to Dept  
		we have to add all his remarks marked as "AttributedToAllClinics" */
				
		INSERT INTO x_Dept_Employee_EmployeeRemarks
		(EmployeeRemarkID, updateUser, updateDate, DeptEmployeeID)
		SELECT
		EmployeeRemarkID, @updateUserName, getdate(), @deptEmployeeID
		FROM EmployeeRemarks 		
		WHERE AttributedToAllClinicsInCommunity  = 1
		AND EmployeeID = @employeeID


		INSERT INTO EmployeeStatusInDept 
		(Status, UpdateUser, FromDate, DeptEmployeeID)
		VALUES
		(@active, @updateUserName, getdate(), @deptEmployeeID)
					
		SET @ErrorStatus = @@Error
	
GO


GRANT EXEC ON rpc_InsertDoctorInClinic TO PUBLIC

GO

-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertEmployeePositionsInDept')
	BEGIN
		DROP  Procedure  rpc_insertEmployeePositionsInDept
	END

GO

CREATE PROCEDURE dbo.rpc_insertEmployeePositionsInDept
	(
		@EmployeeID int,
		@DeptCode int,
		@PositionCodes varchar(50),
		@UpdateUser varchar(50),
		@ErrCode int OUTPUT
	)

AS

DECLARE @count int, @currentCount int, @OrderNumber int
DECLARE @CurrPositionCode int

SET @OrderNumber = 1
SET @count = IsNull((SELECT COUNT(IntField) FROM SplitString(@PositionCodes)), 0)
IF (@count = 0)
BEGIN
	RETURN
END

	DECLARE @deptEmployeeID INT 
	SELECT @deptEmployeeID =	DeptEmployeeID
								FROM x_dept_employee
								WHERE DeptCode = @deptCode 
								AND EmployeeID = @employeeID
	
	SET @currentCount = @count
	
	WHILE(@currentCount > 0)
		BEGIN

			SET @CurrPositionCode = (SELECT IntField FROM SplitString(@PositionCodes) WHERE OrderNumber = @OrderNumber)

			INSERT INTO x_Dept_Employee_Position
			( positionCode, updateUser, updateDate, DeptEmployeeID)
			VALUES
			(@CurrPositionCode, @UpdateUser, getdate(), @deptEmployeeID)

			SET @OrderNumber = @OrderNumber + 1
			SET @currentCount = @currentCount - 1
		END
						
	SET @ErrCode = @@Error
	

GO

GRANT EXEC ON rpc_insertEmployeePositionsInDept TO PUBLIC

GO

-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertEmployeeRemarks')
	BEGIN
		DROP  Procedure  rpc_insertEmployeeRemarks
	END

GO

CREATE Procedure dbo.rpc_insertEmployeeRemarks
	(
		@EmployeeID int,
		@RemarkText varchar(500),
		@dicRemarkID INT,
		@attributedToAllClinics BIT,
		@delimitedDepts VARCHAR(500),
		@displayInInternet int,
		@ValidFrom datetime,
		@ValidTo datetime,
		@updateUser varchar(50),
		@ErrCode int OUTPUT
	)

AS

DECLARE @newID INT
DECLARE @count INT
DECLARE @currentCount INT
DECLARE @OrderNumber INT
DECLARE @CurrDeptCode INT
DECLARE @deptEmployeeID INT



IF @ValidFrom <= cast('1/1/1900 12:00:00 AM' as datetime)
	BEGIN
		SET  @ValidFrom = null
	END		

IF @validTo <= cast('1/1/1900 12:00:00 AM' as datetime)
	BEGIN
		SET  @validTo = null
	END		

	INSERT INTO EmployeeRemarks 
	(EmployeeID, RemarkText, DicRemarkID, displayInInternet, AttributedToAllClinicsInCommunity , ValidFrom, ValidTo, updateDate, updateUser)
	VALUES 
	(@EmployeeID, @RemarkText, @dicRemarkID, @displayInInternet, @attributedToAllClinics, @ValidFrom, @ValidTo, getdate(), @updateUser)
	
	SET @newID =  @@IDENTITY	

	IF (@attributedToAllClinics <> 1 AND @delimitedDepts <> '')
	BEGIN
	
		SET @count = (SELECT COUNT(IntField) FROM SplitString(@delimitedDepts))
		SET @currentCount = @count
		SET @OrderNumber = 1
	
		WHILE(@currentCount > 0)
		BEGIN
			SET @CurrDeptCode = (SELECT IntField FROM SplitString(@delimitedDepts) WHERE OrderNumber = @OrderNumber)
			
			SET @deptEmployeeID =  (SELECT DeptEmployeeID 
									FROM x_Dept_Employee
									WHERE deptCode = @CurrDeptCode
									AND employeeID = @EmployeeID)
									
		
			INSERT INTO x_Dept_Employee_EmployeeRemarks
			(employeeRemarkID, UpdateUser, UpdateDate, DeptEmployeeID)
			VALUES
			(@newID, @UpdateUser, GetDate(), @deptEmployeeID)

			SET @OrderNumber = @OrderNumber + 1
			SET @currentCount = @currentCount - 1
		END	
	END

 
	SET @ErrCode = @@Error

GO

GRANT EXEC ON dbo.rpc_insertEmployeeRemarks TO PUBLIC

GO


-- ***************************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertEmployeeRemarksAttributedToDepts')
	BEGIN
		DROP  Procedure  rpc_insertEmployeeRemarksAttributedToDepts
	END

GO

CREATE PROCEDURE dbo.rpc_insertEmployeeRemarksAttributedToDepts
	(
		@EmployeeID int,
		@DeptCodes varchar(50),
		@AttributedToAll int,
		@EmployeeRemarkID int,
		@UpdateUser varchar(50),
		@ErrCode int OUTPUT
	)

AS

	DECLARE @count int, @currentCount int
	DECLARE @curDeptCode int
	
	Declare @MinDeptCode int
	SET @curDeptCode = 0
	Set @MinDeptCode = 0
	SET @count = (Select count(IntField) from  dbo.SplitString(@DeptCodes))

	IF( @count = 0 AND @AttributedToAll = 0)
	-- It means there are NO attributed to any clinic and all records to be deleted
		BEGIN
			DELETE FROM x_Dept_Employee_EmployeeRemarks WHERE EmployeeRemarkID = @EmployeeRemarkID
		END

	IF( @count > 0 AND @AttributedToAll = 0)
	-- Attribute Remark to clinics with deptCodes in @DeptCodes

			SET @currentCount = @count
			
			
				DELETE FROM x_Dept_Employee_EmployeeRemarks WHERE EmployeeRemarkID = @EmployeeRemarkID
				
				UPDATE EmployeeRemarks SET AttributedToAllClinicsInCommunity = @AttributedToAll
				WHERE EmployeeRemarkID = @EmployeeRemarkID
				
				WHILE (@currentCount > 0)
					BEGIN 
						SET @curDeptCode = (select min(IntField) from dbo.SplitString(@DeptCodes)
												where IntField > @MinDeptCode)
					
						SET @MinDeptCode = @curDeptCode
													   
						INSERT INTO x_Dept_Employee_EmployeeRemarks 
						(EmployeeRemarkID, updateUser, DeptEmployeeID)
						SELECT @EmployeeRemarkID, @UpdateUser, DeptEmployeeID
						FROM x_Dept_Employee
						WHERE deptCode = @curDeptCode
						AND employeeID = @EmployeeID
						
						
						SET @currentCount = @currentCount - 1
					
					END
				
			SET @ErrCode = @@Error
	
	IF(@AttributedToAll = 1)
	-- Attribute Remark to ALL clinics where Employee works
	

			
			DELETE FROM x_Dept_Employee_EmployeeRemarks WHERE EmployeeRemarkID = @EmployeeRemarkID
			
			UPDATE EmployeeRemarks SET AttributedToAllClinicsInCommunity = @AttributedToAll
			WHERE EmployeeRemarkID = @EmployeeRemarkID
			
								
			INSERT INTO x_Dept_Employee_EmployeeRemarks 
			(EmployeeRemarkID, updateUser, DeptEmployeeID)
			SELECT  EmployeeRemarkID, @UpdateUser, DeptEmployeeID
			FROM x_Dept_Employee
			INNER JOIN EmployeeRemarks ON x_Dept_Employee.employeeID = EmployeeRemarks.EmployeeID
			WHERE x_Dept_Employee.employeeID = @EmployeeID
			AND EmployeeRemarkID = @EmployeeRemarkID
			
			SET @ErrCode = @@Error


GO

GRANT EXEC ON rpc_insertEmployeeRemarksAttributedToDepts TO PUBLIC

GO

-- ***************************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertEmployeeServiceQueueOrderMethod')
	BEGIN
		DROP  Procedure  rpc_InsertEmployeeServiceQueueOrderMethod
	END
GO

CREATE PROCEDURE [dbo].[rpc_InsertEmployeeServiceQueueOrderMethod]
	(
		@x_Dept_Employee_ServiceID int,
		@QueueOrderMethod int, 
		@updateUser varchar(50),
		@ErrCode int OUTPUT,
		@newID int OUTPUT
	)

AS

		INSERT INTO EmployeeServiceQueueOrderMethod
		(QueueOrderMethod, updateUser, x_dept_employee_serviceID)
		SELECT @QueueOrderMethod, @updateUser, x_dept_employee_serviceID
		FROM x_Dept_Employee_Service xDES
		WHERE xDES.x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID
				
		SET @ErrCode = @@ERROR
		SET @newID = @@IDENTITY
		
GO


GRANT EXEC ON rpc_InsertEmployeeServiceQueueOrderMethod TO PUBLIC
GO

-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateDoctorsInClinic')
	BEGIN
		DROP  Procedure  rpc_updateDoctorsInClinic
	END

GO

CREATE Procedure dbo.rpc_updateDoctorsInClinic
	(
		@deptCode int,
		@employeeID int,
		@agreementType int,
		@updateUserName varchar(50),
		@showPhonesFromDept bit,
		@ErrorStatus int output
	)

AS
DECLARE @Err int, @Count int
SET @Err = 0
SET @Count = 0
SET @ErrorStatus = 0

		UPDATE x_Dept_Employee
		SET 
		AgreementType = @agreementType,
		updateUserName = @updateUserName,
		CascadeUpdateDeptEmployeePhonesFromClinic = @showPhonesFromDept,
		updateDate = getdate()
		WHERE deptCode = @deptCode
		AND employeeID = @employeeID

		
	IF @showPhonesFromDept = 1 
	BEGIN
		DELETE FROM DeptEmployeePhones 
		FROM DeptEmployeePhones dep
		INNER JOIN x_Dept_Employee xd ON dep.DeptEmployeeID = xd.DeptEmployeeID		
		WHERE deptCode = @DeptCode 
		AND employeeID = @employeeID
	END
				
		SET @ErrorStatus = @@Error
	



GO


GRANT EXEC ON dbo.rpc_updateDoctorsInClinic TO PUBLIC

GO
-- ***************************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateEmployee')
	BEGIN
		DROP  Procedure  rpc_updateEmployee
	END

GO

CREATE Procedure dbo.rpc_updateEmployee
	(
		@employeeID bigint,
		@degreeCode int,
		@firstName varchar(50),
		@lastName varchar(50),
		@EmployeeSectorCode int,
		@sex int,
		@primaryDistrict int,
		@email varchar(50),
		@showEmailInInternet bit,
		@updateUser varchar(50)
	)

AS

DECLARE @RelevantForProfession int
SET @RelevantForProfession = (SELECT RelevantForProfession FROM EmployeeSector WHERE EmployeeSectorCode = @EmployeeSectorCode)
--print '@RelevantForProfession ' +  CAST(@RelevantForProfession as varchar(10))

	
UPDATE Employee
SET degreeCode = @degreeCode,
	firstName = @firstName,
	lastName = @lastName,
	EmployeeSectorCode = @EmployeeSectorCode,
	sex = @sex,
	primaryDistrict = @primaryDistrict,
	email = @email,
	showEmailInInternet = @showEmailInInternet,
	updateUser = @updateUser,
	updateDate = getdate()
WHERE employeeID = @employeeID
		
IF(@RelevantForProfession <> 1)
BEGIN
	DELETE FROM x_Dept_Employee_Service 
	FROM x_Dept_Employee_Service  xdes
	INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
	WHERE employeeID = @employeeID
	AND xdes.serviceCode IN
		(SELECT serviceCode FROM [Services] WHERE IsProfession = 1)

	DELETE FROM deptEmployeeReceptionServices 
	FROM deptEmployeeReceptionServices ders
	INNER JOIN deptEmployeeReception der ON ders.receptionID = der.receptionID
	INNER JOIN x_Dept_Employee xd ON der.DeptEmployeeID = xd.DeptEmployeeID
	WHERE xd.EmployeeID = @employeeID
	AND ders.serviceCode IN (SELECT serviceCode FROM [Services] WHERE IsProfession = 1)


	DELETE FROM deptEmployeeReception 
	FROM deptEmployeeReception der
	INNER JOIN x_Dept_Employee xd ON der.DeptEmployeeID = xd.DeptEmployeeID
	WHERE xd.EmployeeID = @employeeID
	AND NOT EXISTS 
		(SELECT * FROM deptEmployeeReceptionServices ders
		WHERE ders.receptionID = der.receptionID 
		AND serviceCode IN (SELECT serviceCode FROM [Services] WHERE IsProfession = 1)
		)
	
	DELETE FROM EmployeeServices WHERE EmployeeID = @employeeID
END

GO

GRANT EXEC ON rpc_updateEmployee TO PUBLIC

GO

-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateEmployeeInDeptCurrentStatus')
	BEGIN
		DROP  Procedure  rpc_UpdateEmployeeInDeptCurrentStatus
	END

GO

CREATE Procedure dbo.rpc_UpdateEmployeeInDeptCurrentStatus
(		
	@employeeID BIGINT,
	@deptCode INT,
	@status	TINYINT,
	@updateUser VARCHAR(30)
)

AS

UPDATE x_Dept_Employee 
SET Active = @status, updateDate = GETDATE(),  UpdateUserName = @updateUser
WHERE DeptCode = @deptCode 
AND EmployeeID = @employeeID

DELETE FROM x_Dept_Employee_Position
FROM x_Dept_Employee_Position xdep
INNER JOIN x_Dept_Employee xd ON xdep.DeptEmployeeID = xd.DeptEmployeeID
WHERE xd.EmployeeID  = @employeeID 
AND xd.deptCode = @deptCode
AND @status = 0

GO


GRANT EXEC ON rpc_UpdateEmployeeInDeptCurrentStatus TO PUBLIC

GO


-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateEmployeeRemarks')
	BEGIN
		DROP  Procedure  rpc_updateEmployeeRemarks
	END

GO

CREATE Procedure dbo.rpc_updateEmployeeRemarks
	(
		@EmployeeRemarkID int,
		@RemarkText varchar(500),
		@ValidFrom datetime,
		@ValidTo datetime,
		@displayInInternet int,
		@delimitedDeptsCodes VARCHAR(100),
		@attributedToAllClinics BIT,
		@updateUser varchar(50),  
		@ErrCode int OUTPUT
	)

AS

DECLARE @CurrDeptCode INT
DECLARE @OrderNumber INT
DECLARE @currentCount INT
DECLARE @employeeID BIGINT


IF @validTo <= cast('1/1/1900 12:00:00 AM' as datetime)
	BEGIN
		SET  @validTo=null
	END		


DELETE x_Dept_Employee_EmployeeRemarks
WHERE EmployeeRemarkID = @EmployeeRemarkID
	
	

IF (@delimitedDeptsCodes <> '' AND @attributedToAllClinics <> 1)
BEGIN

	SET @currentCount = (SELECT COUNT(IntField) FROM SplitString(@delimitedDeptsCodes))
	SET @OrderNumber = 1
	SELECT @employeeID = EmployeeID	
						 FROM EmployeeRemarks
						 WHERE EmployeeRemarkId = @EmployeeRemarkID

	WHILE(@currentCount > 0)
	BEGIN
		SET @CurrDeptCode = (SELECT IntField FROM SplitString(@delimitedDeptsCodes) WHERE OrderNumber = @OrderNumber)
	
		INSERT INTO x_Dept_Employee_EmployeeRemarks
		(employeeRemarkID, UpdateUser, UpdateDate, DeptEmployeeID)
		SELECT 
		@EmployeeRemarkID, @UpdateUser, GetDate(), DeptEmployeeID
		FROM x_Dept_Employee
		WHERE deptCode = @CurrDeptCode
		AND EmployeeID = @employeeID

		SET @OrderNumber = @OrderNumber + 1
		SET @currentCount = @currentCount - 1
	END	
END
	
	

UPDATE EmployeeRemarks 
SET RemarkText = @RemarkText,  
	displayInInternet = @displayInInternet,
	AttributedToAllClinicsInCommunity = @attributedToAllClinics,
	ValidFrom = @ValidFrom, 
	ValidTo = @ValidTo, 
	updateDate = getdate(), 
	updateUser = @updateUser

WHERE EmployeeRemarkID = @EmployeeRemarkID


GO

GRANT EXEC ON rpc_updateEmployeeRemarks TO PUBLIC

GO
-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateEmployeeServiceInDeptCurrentStatus')
	BEGIN
		DROP  Procedure  rpc_UpdateEmployeeServiceInDeptCurrentStatus
	END

GO

CREATE Procedure dbo.rpc_UpdateEmployeeServiceInDeptCurrentStatus
(	
	@employeeID BIGINT,
	@deptCode	INT,
	@serviceCode INT,
	@status SMALLINT,
	@updateUser VARCHAR(30)
)

AS

DECLARE @deptEmployeeID INT

SET @deptEmployeeID = (SELECT DeptEmployeeID	
					   FROM x_Dept_Employee 
					   WHERE deptCode = @deptCode
					   AND employeeID = @employeeID)


UPDATE x_Dept_Employee_Service
SET Status = @status , UpdateUser = @updateUser, UpdateDate = GETDATE()
WHERE DeptEmployeeID = @deptEmployeeID
AND ServiceCode = @serviceCode

IF ( @status = 0 )
BEGIN
	DELETE FROM deptEmployeeReception
	WHERE receptionID IN
	(	SELECT deptEmployeeReception.receptionID
		FROM deptEmployeeReception
		INNER JOIN deptEmployeeReceptionServices 
			ON deptEmployeeReception.receptionID = deptEmployeeReceptionServices.receptionID
			AND deptEmployeeReception.DeptEmployeeID = @deptEmployeeID			
			AND deptEmployeeReceptionServices.serviceCode = @serviceCode
	)
END

GO


GRANT EXEC ON rpc_UpdateEmployeeServiceInDeptCurrentStatus TO PUBLIC

GO
-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateEmplyeePhonesCascadeFromDept')
	BEGIN
		DROP  Procedure  rpc_updateEmplyeePhonesCascadeFromDept
	END

GO

CREATE PROCEDURE dbo.rpc_updateEmplyeePhonesCascadeFromDept
	(
		@DeptCode int,
		@EmployeeID int,
		@CascadeUpdateDeptEmployeePhonesFromClinic int,
		@UpdateUser varchar(50),
		@ErrorCode int OUTPUT
	)

AS

SET @ErrorCode = 0
DECLARE @deptEmployeeID INT


	IF @CascadeUpdateDeptEmployeePhonesFromClinic = 0 -- DO NOT update
		BEGIN
			UPDATE x_dept_employee
			SET CascadeUpdateDeptEmployeePhonesFromClinic = @CascadeUpdateDeptEmployeePhonesFromClinic
			WHERE deptCode = @DeptCode
			AND employeeID = @EmployeeID
		END

	IF @CascadeUpdateDeptEmployeePhonesFromClinic = 1 -- Update
		BEGIN
			UPDATE x_dept_employee
			SET CascadeUpdateDeptEmployeePhonesFromClinic = @CascadeUpdateDeptEmployeePhonesFromClinic
			WHERE deptCode = @DeptCode
			AND employeeID = @EmployeeID
			
			SET @deptEmployeeID =  (SELECT DeptEmployeeID
									FROM x_Dept_Employee
									WHERE deptCode = @DeptCode
									AND employeeID = @EmployeeID)
			
			DELETE FROM DeptEmployeePhones
			WHERE DeptEmployeeID = @deptEmployeeID			

			INSERT INTO DeptEmployeePhones
				(phoneType, phoneOrder, prePrefix, prefix, phone, updateUser, updateDate, DeptEmployeeID)
				
			SELECT phoneType, phoneOrder, prePrefix, prefix, phone, @UpdateUser, getdate(), @deptEmployeeID
			FROM DeptPhones
			WHERE DeptPhones.deptCode = @deptCode
			
		END
		
	SET @ErrorCode = @@Error

GO

GRANT EXEC ON rpc_updateEmplyeePhonesCascadeFromDept TO PUBLIC

GO

-- ***************************************

 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'vEmployeeDeptRemarks')
	BEGIN
		DROP  view  vEmployeeDeptRemarks
	END

GO


CREATE VIEW [dbo].[vEmployeeDeptRemarks]
AS
SELECT     dbo.EmployeeRemarks.EmployeeRemarkID, dbo.EmployeeRemarks.EmployeeID, dbo.EmployeeRemarks.DicRemarkID, 
					  dbo.EmployeeRemarks.RemarkText, dbo.EmployeeRemarks.displayInInternet, 
					  dbo.EmployeeRemarks.AttributedToAllClinicsInCommunity as AttributedToAllClinics, 
					  dbo.EmployeeRemarks.ValidFrom, dbo.EmployeeRemarks.ValidTo, dbo.x_Dept_Employee.deptCode, dbo.Employee.EmployeeSectorCode
FROM        dbo.EmployeeRemarks 
			INNER JOIN dbo.Employee ON dbo.EmployeeRemarks.EmployeeID = dbo.Employee.employeeID 
			INNER JOIN dbo.x_Dept_Employee ON dbo.EmployeeRemarks.EmployeeID = dbo.x_Dept_Employee.employeeID 
			LEFT JOIN dbo.x_Dept_Employee_EmployeeRemarks xder ON dbo.EmployeeRemarks.EmployeeRemarkID = xder.EmployeeRemarkID 				
WHERE					   
	(dbo.EmployeeRemarks.ValidFrom IS NULL 	OR	dbo.EmployeeRemarks.ValidFrom <= GETDATE()) 
	AND (dbo.EmployeeRemarks.ValidTo IS NULL OR 	dbo.EmployeeRemarks.ValidTo >= GETDATE())
	AND (EmployeeRemarks.AttributedToAllClinicsInCommunity = 1 OR xder.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID)

GO
  
grant select on vEmployeeDeptRemarks to public 

go
-- ***************************************
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fun_getEmployeeOrderByProfessionInDept]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fun_getEmployeeOrderByProfessionInDept]
GO

CREATE FUNCTION [dbo].[fun_getEmployeeOrderByProfessionInDept] 
(
	@DeptCode int,
	@EmployeeID bigint
)
RETURNS int

AS
BEGIN
	DECLARE @order int
	SET @order = 4
	
	SET @order =
		(SELECT TOP 1 opder FROM
			(SELECT opder = CASE xDES.serviceCode WHEN 2 THEN 1 WHEN 40 THEN 2 ELSE 3 END
			FROM x_Dept_Employee_Service xdes
			INNER JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
			WHERE xd.employeeID = @EmployeeID 
			AND xd.deptCode = @DeptCode
			) as T
		ORDER BY opder)
	IF (@order is null)
		SET @order = 4
	
	RETURN( @order )		
END

GO
-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_DeptEmployeeExpertProfessions')
	BEGIN
		DROP  View View_DeptEmployeeExpertProfessions
	END
GO

CREATE VIEW [dbo].View_DeptEmployeeExpertProfessions
AS
SELECT  xd.deptCode, xd.EmployeeId
			,STUFF( 
				(
					SELECT  '; ' + cast([Services].ServiceDescription as varchar(max))
					from x_Dept_Employee_Service as xDES
					inner join EmployeeServices 
						on  xDES.DeptEmployeeID = xd.DeptEmployeeID						
						and xd.employeeID = EmployeeServices.employeeID 
						and xDES.serviceCode = EmployeeServices.serviceCode
						and EmployeeServices.expProfession = 1
					inner join [Services] 
						on xDES.serviceCode = [Services].ServiceCode
						and [Services].IsProfession = 1
					order by [Services].ServiceDescription
					FOR XML PATH('') 
				)
				,1,2,'') as ExpertProfessionDescriptions
			,STUFF( 
				(
					SELECT  '; ' + cast([Services].ServiceCode as varchar(max))
					from x_Dept_Employee_Service as xDES
					inner join EmployeeServices 
						on  xDES.DeptEmployeeID = xd.DeptEmployeeID						
						and xd.employeeID = EmployeeServices.employeeID 
						and xdes.serviceCode = EmployeeServices.serviceCode
						and EmployeeServices.expProfession = 1
					inner join [Services]
						on xDES.ServiceCode = [Services].ServiceCode
						and [Services].IsProfession = 1
					order by [Services].ServiceDescription
					FOR XML PATH('') 
				)
				,1,2,'') as ExpertProfessionCodes
FROM x_Dept_Employee  xd

GO

-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_DeptEmployeeReceptions')
	BEGIN
		DROP  View View_DeptEmployeeReceptions
	END
GO

CREATE VIEW [dbo].[View_DeptEmployeeReceptions]
AS
SELECT *
FROM         
(
----------------- deptEmployeeReceptionProfession --------------------
SELECT
x_dept_employee.deptCode,
x_dept_employee.employeeId,
serviceDescription = null,
serviceCode = null,
Services.ServiceDescription as ProfessionDescription,
Services.ServiceCode as ProfessionCode,
recep.receptionID,
recep.receptionDay,
DIC_ReceptionDays.ReceptionDayName,
recep.openingHour,
recep.closingHour,
'totalHours' =  [dbo].rfn_TimeInterval_float(recep.openingHour, recep.closingHour),
recep.validFrom,
recep.validTo,
RecRemarks.remarkText

FROM x_dept_employee

inner join [dbo].DeptEmployeeReception as Recep on x_dept_employee.DeptEmployeeID =  recep.DeptEmployeeID 
inner join dbo.deptEmployeeReceptionServices as RecProf on Recep.receptionID = RecProf.receptionID  
inner join Services	ON RecProf.ServiceCode = Services.ServiceCode
	and Services.IsProfession = 1  
inner join DIC_ReceptionDays on Recep.receptionDay = DIC_ReceptionDays.ReceptionDayCode
left join DeptEmployeeReceptionRemarks as RecRemarks on Recep.receptionID = RecRemarks.EmployeeReceptionID

		
UNION
----------------- deptEmployeeReceptionServices --------------------
SELECT
x_dept_employee.deptCode,
x_dept_employee.employeeId,
Services.serviceDescription,
RecServ.serviceCode,
ProfessionDescription = null,
ProfessionCode = null,
recep.receptionID,
recep.receptionDay,
DIC_ReceptionDays.ReceptionDayName,
recep.openingHour,
recep.closingHour,
'totalHours' =  [dbo].rfn_TimeInterval_float(recep.openingHour, recep.closingHour),
recep.validFrom,
recep.validTo,
RecRemarks.remarkText

FROM x_dept_employee

inner join [dbo].DeptEmployeeReception as Recep  on	x_dept_employee.DeptEmployeeID = recep.DeptEmployeeID	
inner join dbo.deptEmployeeReceptionServices as RecServ on Recep.receptionID = RecServ.receptionID  
inner join Services	ON RecServ.serviceCode = Services.serviceCode 
	and Services.IsService = 1 
inner join DIC_ReceptionDays on Recep.receptionDay = DIC_ReceptionDays.ReceptionDayCode
left join DeptEmployeeReceptionRemarks as RecRemarks on Recep.receptionID = RecRemarks.DeptEmployeeReceptionRemarkID

 )
AS subq

GO

-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_DeptEmployeeRemarks')
	BEGIN
		DROP  View View_DeptEmployeeRemarks
	END
GO

CREATE VIEW [dbo].View_DeptEmployeeRemarks
AS
SELECT  x_Dept_Employee.deptCode, x_Dept_Employee.EmployeeId
			,STUFF( 
				(
					SELECT  '; ' + replace(replace(EmployeeRemarks.RemarkText,'#', ''), '&quot;', char(34))
					from x_Dept_Employee_EmployeeRemarks as xDEP
					inner join EmployeeRemarks 
						on xDEP.EmployeeRemarkID = EmployeeRemarks.EmployeeRemarkID
						and xDEP.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID						
						and EmployeeRemarks.ValidFrom  < dateadd(day,1,convert(Date, GETDATE()))
						and EmployeeRemarks.ValidTo  >= convert(Date, GETDATE())
					order by EmployeeRemarks.RemarkText
					FOR XML PATH('') 
				)
				,1,2,'') as RemarkDescriptions
			,STUFF( 
				(
					SELECT  '; ' + cast(xDEP.EmployeeRemarkID as varchar(max))
					from x_Dept_Employee_EmployeeRemarks as xDEP
					inner join EmployeeRemarks 
						on xDEP.EmployeeRemarkID = EmployeeRemarks.EmployeeRemarkID
						and xDEP.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
						and EmployeeRemarks.ValidFrom  < dateadd(day,1,convert(Date, GETDATE()))
						and EmployeeRemarks.ValidTo  >= convert(Date, GETDATE())
					order by EmployeeRemarks.RemarkText
					FOR XML PATH('') 
				)
				,1,2,'') as RemarkCodes
	from x_Dept_Employee 
GO

-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_DeptEmployeeServices')
	BEGIN
		DROP  View View_DeptEmployeeServices
	END
GO

CREATE VIEW [dbo].View_DeptEmployeeServices
AS
SELECT  x_Dept_Employee.deptCode, x_Dept_Employee.EmployeeId
			,STUFF( 
				(
					SELECT  '; ' + serviceDescription
					FROM x_Dept_Employee_Service AS xDEP
					inner join Services  
						ON xDEP.serviceCode = Services.serviceCode
						and xDEP.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID						
						and Services.IsService = 1
					order by serviceDescription
					FOR XML PATH('') 
				)
				,1,2,'') as serviceDescriptions
			,STUFF( 
				(
					SELECT  '; ' + cast(Services.ServiceCode as varchar(max))
					FROM x_Dept_Employee_Service AS xDEP
					inner join Services 
						ON xDEP.serviceCode = Services.serviceCode
						and xDEP.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID						
						and Services.IsService = 1
					order by serviceDescription
					FOR XML PATH('') 
				)
				,1,2,'') as ServiceCodes
	from x_Dept_Employee 
GO


-- ***************************************
IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[dbo].[fun_getGeriatricsManagerName]') and xtype in (N'FN', N'IF', N'TF'))
	DROP FUNCTION [dbo].[fun_getGeriatricsManagerName]
GO

CREATE FUNCTION [dbo].[fun_getGeriatricsManagerName]
(
	@DeptCode int
)

RETURNS varchar(100)

AS
BEGIN
	DECLARE  @strGeriatricsManagerName varchar(100)
	SET @strGeriatricsManagerName = ''
	
	set @strGeriatricsManagerName = (SELECT  TOP 1 DegreeName + ' ' + lastName + ' ' + firstName
							FROM employee
							INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode
							INNER JOIN x_dept_employee xd ON employee.EmployeeID = xd.EmployeeID
							INNER JOIN x_Dept_Employee_Position ON xd.DeptEmployeeID = x_Dept_Employee_Position.DeptEmployeeID
							AND x_Dept_Employee_Position.positionCode = 17
							AND xd.deptCode = @deptCode		
)			
							
	if(@strGeriatricsManagerName is null )						
	begin
		 SET @strGeriatricsManagerName = ''		
	end 
	
	RETURN( @strGeriatricsManagerName )		
END 

GO

GRANT EXEC ON dbo.fun_getGeriatricsManagerName TO PUBLIC 

GO

-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'rfn_GetDeptEmployeePositionCodes')
	BEGIN
		DROP  FUNCTION  rfn_GetDeptEmployeePositionCodes
	END

GO

create function [dbo].rfn_GetDeptEmployeePositionCodes(@DeptCode int, @employeeID bigint) 
RETURNS varchar(500)
WITH EXECUTE AS CALLER

AS
BEGIN
	declare @PositionsStr varchar(500) 
	set @PositionsStr = ''
	
	SELECT @PositionsStr = @PositionsStr + convert(varchar(50), d.PositionCode) + ' ; ' 
	FROM
		(select distinct Position.PositionDescription, Position.PositionCode
		from x_Dept_Employee_Position as xDEP
		INNER JOIN x_dept_employee xd ON xdep.DeptEmployeeID = xd.DeptEmployeeID
		INNER JOIN Employee on xd.employeeID = Employee.employeeID			
		INNER JOIN Position on xDEP.PositionCode = Position.PositionCode and Employee.sex = Position.gender
		WHERE xd.DeptCode = @deptCode
		AND xd.EmployeeID = @employeeID
		)
		as d 
	order by d.PositionDescription
	 
	IF(LEN(@PositionsStr)) > 0 -- to remove last ','
		BEGIN
			SET @PositionsStr = Left( @PositionsStr, LEN(@PositionsStr) -1 )
		END
	
	
	return (@PositionsStr);
end 

go 
grant exec on dbo.rfn_GetDeptEmployeePositionCodes to public 
go

-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'rfn_GetDeptEmployeePositionDescriptions')
	BEGIN
		DROP  FUNCTION  rfn_GetDeptEmployeePositionDescriptions
	END

GO

create function [dbo].rfn_GetDeptEmployeePositionDescriptions(@DeptCode int, @employeeID bigint) 
RETURNS varchar(500)
WITH EXECUTE AS CALLER

AS
BEGIN
	declare @PositionsStr varchar(500) 
	set @PositionsStr = ''
	
	SELECT @PositionsStr = @PositionsStr + PositionDescription + ' ; ' 
	FROM
		(select distinct Position.PositionDescription, Position.PositionCode
		from x_Dept_Employee_Position as xDEP
		INNER JOIN x_dept_employee xd ON xdep.DeptEmployeeID = xd.DeptEmployeeID
		INNER JOIN Employee ON xd.employeeID = Employee.employeeID			
		INNER JOIN Position on xDEP.PositionCode = Position.PositionCode and Employee.sex = Position.gender
		WHERE xd.DeptCode = @deptCode
		AND xd.EmployeeID = @employeeID
		)
		as d 
	order by d.PositionDescription
	
	IF(LEN(@PositionsStr)) > 0 -- to remove last ','
		BEGIN
			SET @PositionsStr = Left( @PositionsStr, LEN(@PositionsStr) -1 )
		END
	
	return (@PositionsStr);
end 

go 
grant exec on rfn_GetDeptEmployeePositionDescriptions to public 
go

-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_DeptEmployeePositions')
	BEGIN
		DROP  View View_DeptEmployeePositions
	END
GO

CREATE VIEW [dbo].View_DeptEmployeePositions
AS
SELECT  x_Dept_Employee.deptCode, x_Dept_Employee.EmployeeId
			,STUFF( 
				(
					SELECT  '; ' + cast(PositionDescription as varchar(max))
					from x_Dept_Employee_Position as xDEP
					INNER JOIN Employee
						on  xDEP.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID						
						and x_Dept_Employee.employeeID = Employee.employeeID
					INNER JOIN Position 
						on xDEP.PositionCode = Position.PositionCode
						and Employee.sex = Position.gender
					order by Position.PositionDescription
					FOR XML PATH('') 
				)
				,1,2,'') as PositionDescriptions
			,STUFF( 
				(
					SELECT  '; ' + cast(xDEP.PositionCode as varchar(max))
					from x_Dept_Employee_Position as xDEP
					INNER JOIN Employee 
						on  xDEP.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID						
						and x_Dept_Employee.employeeID = Employee.employeeID
					join Position 
						on xDEP.PositionCode = Position.PositionCode
						and Employee.sex = Position.gender
					order by Position.PositionDescription
					FOR XML PATH('') 
				)
				,1,2,'') as PositionCodes
	from x_Dept_Employee 
GO
-- ***************************************


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_getServiceForPopUp_ViaEmployee]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[rpc_getServiceForPopUp_ViaEmployee]
GO

CREATE Procedure [dbo].[rpc_getServiceForPopUp_ViaEmployee]
	(
		@DeptCode int,
		@EmployeeID int,
		@AgreementType int,
		@ServiceCode int,
		@ExpirationDate datetime
	)

AS


DECLARE @deptEmployeeID INT
SET @deptEmployeeID = ( SELECT DeptEmployeeID
						FROM x_Dept_Employee xd
						WHERE deptCode = @DeptCode
						AND employeeID = @EmployeeID
						AND AgreementType = @AgreementType)

IF (@ExpirationDate is null OR @ExpirationDate <= cast('1/1/1900 12:00:00 AM' as datetime))
	BEGIN
		SET  @ExpirationDate = getdate()
	END	


----- clinic -----------
SELECT
Dept.deptName,
'address' = dbo.GetAddress(Dept.deptCode),
cityName

FROM Dept
INNER JOIN Cities ON Dept.cityCode = Cities.cityCode
WHERE dept.deptCode = @DeptCode

---- service -----------
--SELECT serviceDescription FROM [Services] WHERE ServiceCode = @ServiceCode
  select [Services].ServiceDescription,
  CASE WHEN DIC_QO_S.QueueOrderDescription is null 
	   THEN 
			CASE WHEN DIC_QO_E.QueueOrderDescription is null THEN '' ELSE DIC_QO_E.QueueOrderDescription END
	   ELSE DIC_QO_S.QueueOrderDescription END
	   as QueueOrderDescription,
  CASE WHEN DIC_QO_S.PermitOrderMethods is null 
		THEN 	   
			CASE WHEN DIC_QO_E.PermitOrderMethods is null THEN -1 ELSE DIC_QO_E.PermitOrderMethods END
		ELSE DIC_QO_S.PermitOrderMethods END
		as PermitOrderMethods,
	dbo.fun_GetEmployeeServiceQueueOrderPhones(x_DES.DeptEmployeeID, x_DES.serviceCode)
	as ServiceQueueOrderPhones
			
  FROM x_Dept_Employee x_DE
  JOIN Employee ON x_DE.employeeID = Employee.employeeID
  LEFT JOIN x_Dept_Employee_Service x_DES ON x_DE.DeptEmployeeID = x_DES.DeptEmployeeID
  LEFT JOIN [Services] ON x_DES.serviceCode = [Services].serviceCode
  LEFT JOIN DIC_QueueOrder DIC_QO_E ON x_DE.QueueOrder = DIC_QO_E.QueueOrder
  LEFT JOIN DIC_QueueOrder DIC_QO_S ON x_DES.QueueOrder = DIC_QO_S.QueueOrder  
  where deptCode = @DeptCode 
  and x_DE.employeeID = @EmployeeID
  and x_DES.serviceCode = @ServiceCode  

------- deptPhones ----------------
SELECT
phoneOrder,
'phone' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension)

FROM DeptPhones
WHERE deptCode = @DeptCode
AND phoneType <> 2 -- not fax

----DoctorReceptions------------------------
SELECT
dER.receptionID,
xd.EmployeeID,
xd.deptCode,
IsNull(ders.serviceCode, 0) as professionOrServiceCode,
IsNull(serviceDescription, 'NoData') as professionOrServiceDescription,
dER.receptionDay,
DIC_ReceptionDays.ReceptionDayName,
DER.validFrom,
'expirationDate' = DER.validTo,
'willExpireIn' = DATEDIFF(day, getdate(), IsNull(validTo,'01/01/2050')),
'openingHour' = 
	CASE closingHour 
		WHEN '00:00' THEN	
			CASE openingHour WHEN '00:01' THEN '24' WHEN '01:00' THEN '24' WHEN '00:00' THEN '24' ELSE openingHour END
		WHEN '23:59' THEN	
			CASE openingHour WHEN '00:01' THEN '24' WHEN '01:00' THEN '24' WHEN '00:00' THEN '24' ELSE openingHour END
		ELSE openingHour END,
'closingHour' =
	CASE closingHour 
		WHEN '00:00' THEN	
			CASE openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN '00:00' THEN 'שעות' ELSE closingHour END
		WHEN '23:59' THEN	
			CASE openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN '00:00' THEN 'שעות' ELSE closingHour END
		ELSE closingHour END,

'receptionRemarks' = dbo.fun_GetEmployeeRemarksForReception(dER.receptionID),
'serviceCodes' = dbo.fun_GetServiceCodesForEmployeeReception(dER.receptionID)

FROM deptEmployeeReception as der
INNER JOIN x_Dept_Employee xd ON der.DeptEmployeeID = xd.DeptEmployeeID
LEFT JOIN deptEmployeeReceptionServices as ders ON der.receptionID = ders.receptionID
LEFT JOIN [Services] ON ders.serviceCode = [Services].serviceCode
INNER JOIN DIC_ReceptionDays on dER.receptionDay = DIC_ReceptionDays.ReceptionDayCode
WHERE xd.deptCode = @DeptCode
AND xd.EmployeeID = @EmployeeID
AND dERS.serviceCode = @ServiceCode
AND (
	(validFrom is null OR @ExpirationDate >= validFrom )
	and 
	(validTo is null OR validTo >= @ExpirationDate) 
	)

ORDER BY EmployeeID, receptionDay, openingHour


-- closest reception add date within 14 days
SELECT MIN(ValidFrom)
FROM deptEmployeeReception der
INNER JOIN deptEmployeeReceptionServices ders ON der.receptionID = ders.receptionID
WHERE der.DeptEmployeeID = @deptEmployeeID 
AND ders.serviceCode = @ServiceCode
AND DATEDIFF(dd, ValidFrom, GETDATE()) < 0
AND DATEDIFF(dd, ValidFrom, GETDATE()) >= -14



SELECT  
deptCode,
employeeID,
serviceCode,
dbo.rfn_GetFotmatedRemark(desr.RemarkText) as Remark,
DisplayInInternet

FROM DeptEmployeeServiceRemarks desr
INNER JOIN  x_Dept_Employee_Service xdes ON desr.x_dept_employee_serviceID = xdes.x_dept_employee_serviceID
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
WHERE deptCode = @DeptCode 
AND employeeID = @EmployeeID
AND ServiceCode = @serviceCode

-- Dept faxes --------------------------
SELECT
phoneOrder,
'fax' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension)

FROM DeptPhones
WHERE deptCode = @DeptCode
AND phoneType = 2 -- fax

-- Queue order for methods, phones and hours
select * from dbo.fun_GetQueueOrderMethods(@DeptCode,@EmployeeID,@ServiceCode)
select * from dbo.fun_GetQueueOrderPhones(@DeptCode,@EmployeeID,@ServiceCode)
select * from dbo.fun_GetQueueOrderHours(@DeptCode,@EmployeeID,@ServiceCode)


-- Service phones and faxes -----------------------------
select * from [fun_GetServicePhoneAndFaxes](@DeptCode,@EmployeeID,@ServiceCode)

-- Employee name and degree
select firstName + ' ' + lastName as employeeName,DegreeName from Employee
join DIC_EmployeeDegree on Employee.degreeCode = DIC_EmployeeDegree.DegreeCode
and Employee.employeeID = @EmployeeID

GO


GRANT EXEC ON rpc_getServiceForPopUp_ViaEmployee TO PUBLIC
GO
-- ***************************************
-- ***** inegration / external views
-- ***************************************

/*

View for internal system - view not in use in SeferNet!
Do not change without Maria's permition!!!


מערכת מר"ע (רופאים עצמאיים) צריכה לקבל אינפורמציה באופן 
שוטף לגבי רופאים שנותנים שירות 1600 – רפואת ילדים בערב
יש להחזיר להם את הנתונים הבאים:
קוד סימול ישן, קוד סימול חדש, רישיון רופא
*/
/****** Object:  View [dbo].[View_DeptEmployeeService1600]    Script Date: 02/07/2011 15:35:01 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[View_DeptEmployeeService1600]'))
DROP VIEW [dbo].[View_DeptEmployeeService1600]
GO

/****** Object:  View [dbo].[View_DeptEmployeeService1600]    Script Date: 02/07/2011 15:35:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[View_DeptEmployeeService1600]
AS
SELECT     xd.deptCode, dbo.deptSimul.Simul228, dbo.Dept.districtCode, dbo.Employee.licenseNumber
FROM         dbo.x_Dept_Employee_Service xdes
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID 
INNER JOIN dbo.Employee ON xd.employeeID = dbo.Employee.employeeID 
INNER JOIN dbo.deptSimul ON dbo.deptSimul.deptCode = xd.deptCode 
AND dbo.deptSimul.openDateSimul <= GETDATE() 
AND (dbo.deptSimul.closingDateSimul > GETDATE() OR dbo.deptSimul.closingDateSimul IS NULL) 
INNER JOIN dbo.Dept ON dbo.deptSimul.deptCode = dbo.Dept.deptCode
WHERE     (xdes.serviceCode = 1600)


GO

-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_checkIfDeptEmployeeQueueOrderEnabled')
	BEGIN
		DROP  Procedure  rpc_checkIfDeptEmployeeQueueOrderEnabled
	END

GO

CREATE Procedure rpc_checkIfDeptEmployeeQueueOrderEnabled
(
	@employeeID BIGINT,
	@deptCode	INT
)

AS

IF NOT EXISTS 
(
	SELECT *  
	FROM x_Dept_Employee_Service xdes
	INNER JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
	WHERE xd.EmployeeID = @employeeID 
	AND xd.DeptCode = @deptCode
)
	SELECT 0
ELSE
	SELECT 1


GO


GRANT EXEC ON rpc_checkIfDeptEmployeeQueueOrderEnabled TO PUBLIC

GO
-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteAllDeptEmployeePhones')
	BEGIN
		DROP  Procedure  rpc_DeleteAllDeptEmployeePhones
	END

GO

CREATE Procedure dbo.rpc_DeleteAllDeptEmployeePhones
(
	@deptEmployeeID INT	
)

AS

DELETE DeptEmployeePhones
WHERE DeptEmployeeID = @deptEmployeeID

GO


GRANT EXEC ON rpc_DeleteAllDeptEmployeePhones TO PUBLIC

GO

-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteDeptEmployeeQueueOrderMethods')
	BEGIN
		DROP  Procedure  rpc_DeleteDeptEmployeeQueueOrderMethods
	END

GO

CREATE Procedure dbo.rpc_DeleteDeptEmployeeQueueOrderMethods
(
	@deptEmployeeID INT	
)

AS




DELETE DeptEmployeeQueueOrderPhones
WHERE QueueOrderMethodID IN 
							(SELECT QueueOrderMethodID
								FROM EmployeeQueueOrderMethod  
								WHERE DeptEmployeeID = @deptEmployeeID)


DELETE EmployeeQueueOrderHours
WHERE QueueOrderMethodID IN 
							(SELECT QueueOrderMethodID
								FROM EmployeeQueueOrderMethod  
								WHERE DeptEmployeeID = @deptEmployeeID)
							
					

DELETE EmployeeQueueOrderMethod
WHERE DeptEmployeeID = @deptEmployeeID

	
	
UPDATE x_dept_Employee
SET QueueOrder = -1
WHERE DeptEmployeeID = @deptEmployeeID



GO

GRANT EXEC ON rpc_DeleteDeptEmployeeQueueOrderMethods TO PUBLIC

GO


-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteDeptEmployeeService')
	BEGIN
		DROP  Procedure  rpc_deleteDeptEmployeeService
	END

GO

CREATE Procedure dbo.rpc_deleteDeptEmployeeService
	(
		@deptEmployeeID int,
		@ServiceCode int
	)

AS 

DECLARE @deptEmployeeServiceID INT
SET @deptEmployeeServiceID = (
						SELECT  x_dept_employee_serviceID
						FROM x_Dept_employee_service
						WHERE DeptEmployeeID = @deptEmployeeID			
						AND ServiceCode = @serviceCode			
					   )


	DELETE FROM x_Dept_Employee_Service
	WHERE x_dept_employee_serviceID = @deptEmployeeServiceID
	

	
	DELETE DeptEmployeeServiceRemarks
	WHERE x_dept_employee_serviceID = @deptEmployeeServiceID
	

GO


GRANT EXEC ON dbo.rpc_deleteDeptEmployeeService TO PUBLIC

GO


-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteDoctorInClinic')
	BEGIN
		DROP  Procedure  rpc_deleteDoctorInClinic
	END

GO

CREATE Procedure dbo.rpc_deleteDoctorInClinic
(
		@DeptEmployeeID int
)

AS

	
		DELETE x_Dept_Employee_EmployeeRemarks
		WHERE DeptEmployeeID  = @DeptEmployeeID		
		
		DELETE FROM x_dept_Employee 
		WHERE DeptEmployeeID = @DeptEmployeeID
		 

GO


GRANT EXEC ON rpc_deleteDoctorInClinic TO PUBLIC

GO

-- ***************************************
	IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteEmployeeReception')
	BEGIN
		DROP  Procedure  rpc_DeleteEmployeeReception
	END

GO

CREATE Procedure dbo.rpc_DeleteEmployeeReception
(
	@employeeID BIGINT,
	@deptCode INT
)

AS

DELETE DeptEmployeeReception
FROM DeptEmployeeReception der
INNER JOIN x_dept_employee xd ON der.DeptEmployeeID = xd.DeptEmployeeID
WHERE ( @deptCode = -1 AND EmployeeID = @employeeID )
OR (EmployeeID = @employeeID AND DeptCode = @deptCode )

GO

GRANT EXEC ON rpc_DeleteEmployeeReception TO PUBLIC

GO

-- ***************************************


--**** Yaniv - Start create view View_SubUnitTypes --------------------

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[View_SubUnitTypes]'))
DROP VIEW [dbo].[View_SubUnitTypes]
GO


CREATE VIEW [dbo].[View_SubUnitTypes]
AS
SELECT  TOP (100) PERCENT subUnitType.subUnitTypeCode, subUnitType.UnitTypeCode, DIC_SubUnitTypes.subUnitTypeName,
			DIC_SubUnitTypes.IsCommunity, DIC_SubUnitTypes.IsMushlam, DIC_SubUnitTypes.IsHospitals,
			subUnitType.DefaultReceptionHoursTypeID
FROM subUnitType 
INNER JOIN DIC_SubUnitTypes ON subUnitType.subUnitTypeCode = DIC_SubUnitTypes.subUnitTypeCode
ORDER BY subUnitType.UnitTypeCode, DIC_SubUnitTypes.subUnitTypeName

GO

grant select on View_SubUnitTypes to public 

go

--**** Yaniv - End create view View_SubUnitTypes --------------------


-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetCurrentStatusForEmployeeInDept')
	BEGIN
		DROP  Procedure  rpc_GetCurrentStatusForEmployeeInDept
	END

GO

CREATE Procedure dbo.rpc_GetCurrentStatusForEmployeeInDept
(
	@deptEmployeeID INT
)

AS

SELECT xd.active, StatusDescription
FROM x_dept_employee xd
INNER JOIN DIC_ActivityStatus dic ON xd.active = dic.status
WHERE xd.DeptEmployeeID = @deptEmployeeID 



GO


GRANT EXEC ON rpc_GetCurrentStatusForEmployeeInDept TO PUBLIC

GO

-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptEmployeePhones')
	BEGIN
		DROP  Procedure  rpc_getDeptEmployeePhones
	END

GO

CREATE Procedure dbo.rpc_getDeptEmployeePhones
	(
		@deptEmployeeID int
	)

AS


DECLARE @deptPhone BIT

SELECT @deptPhone = CascadeUpdateDeptEmployeePhonesFromClinic 
FROM x_Dept_Employee
WHERE DeptEmployeeID = @deptEmployeeID

IF @deptPhone = 0

	SELECT 1 AS PhoneID,  dep.phoneType, phoneOrder,prePrefix, prefixCode, dic.prefixValue as prefixText,  
																									phone, extension, 0 as 'IsOriginalDeptPhone'
	FROM DeptEmployeePhones dep
	INNER JOIN DIC_PhoneTypes phoneTypes ON dep.phoneType = phoneTypes.phoneTypeCode
	LEFT JOIN DIC_PhonePrefix dic ON dep.prefix = dic.prefixCode
	WHERE DeptEmployeeID = @deptEmployeeID	
	ORDER BY dep.phoneType, phoneOrder

ELSE

	SELECT 1 AS PhoneID, DeptPhones.phoneType,phoneOrder,prePrefix, prefixCode, dic.prefixValue as prefixText,
																									 phone, extension, 1 as 'IsOriginalDeptPhone'
	FROM DeptPhones
	INNER JOIN x_dept_employee xd ON DeptPhones.DeptCode = xd.DeptCode
	INNER JOIN DIC_PhonePrefix dic ON DeptPhones.prefix = dic.prefixCode
	WHERE phoneOrder = 1 AND @deptEmployeeID = xd.DeptEmployeeID



GO

GRANT EXEC ON rpc_getDeptEmployeePhones TO PUBLIC

GO

-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDeptGeneralBelongings')
    BEGIN
	    DROP  Procedure  rpc_GetDeptGeneralBelongings
    END

GO

CREATE Procedure dbo.rpc_GetDeptGeneralBelongings
(
	@deptCode INT
)

AS


SELECT DeptCode, Isnull(IsCommunity,0) as IsCommunity, IsNull(isMushlam,0) as isMushlam, IsNull(IsHospital,0) as IsHospital
FROM Dept
WHERE DeptCode = @deptCode

                
GO


GRANT EXEC ON rpc_GetDeptGeneralBelongings TO PUBLIC

GO            

-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDeptGeneralBelongingsByEmployee')
    BEGIN
	    DROP  Procedure  rpc_GetDeptGeneralBelongingsByEmployee
    END

GO

CREATE Procedure dbo.rpc_GetDeptGeneralBelongingsByEmployee
(
	@deptEmployeeID INT
)

AS


SELECT Dept.DeptCode, Isnull(IsCommunity,0) as IsCommunity, IsNull(isMushlam,0) as isMushlam, IsNull(IsHospital,0) as IsHospital
FROM Dept
INNER JOIN x_dept_employee xd ON Dept.DeptCode = xd.DeptCode
WHERE DeptEmployeeID = @deptEmployeeID

                
GO


GRANT EXEC ON rpc_GetDeptGeneralBelongingsByEmployee TO PUBLIC

GO            

-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeeInClinicDetails')
	BEGIN
		DROP  Procedure  rpc_getEmployeeInClinicDetails
	END

GO

CREATE Procedure dbo.rpc_getEmployeeInClinicDetails
	(
		@deptEmployeeID int		
	)

AS


declare @indValue bit

SELECT
x_Dept_Employee.employeeID, 
x_Dept_Employee.deptCode, 
AgreementType,
'active'= Cast(ISNULL(x_Dept_Employee.active, 0) as bit),
'DoctorsName' = DIC_EmployeeDegree.DegreeName + ' ' + Employee.LastName + ' ' + Employee.FirstName,
Employee.FirstName, Employee.LastName,
EmployeeSector.EmployeeSectorCode,
EmployeeSectorDescription, 
dept.deptName,
dept.deptCode,
'phonesOnly' = dbo.fun_GetDeptEmployeePhonesOnly(x_Dept_Employee.employeeID, x_Dept_Employee.deptCode),	
'fax' = dbo.fun_GetDeptEmployeeFax(x_Dept_Employee.employeeID, x_Dept_Employee.deptCode),	
'expert' = dbo.fun_GetEmployeeExpert(x_Dept_Employee.employeeID)

FROM x_Dept_Employee
INNER JOIN Employee ON x_Dept_Employee.employeeID = Employee.employeeID
INNER JOIN DIC_EmployeeDegree ON Employee.degreeCode = DIC_EmployeeDegree.DegreeCode
INNER JOIN EmployeeSector ON Employee.EmployeeSectorCode = EmployeeSector.EmployeeSectorCode
INNER JOIN dept ON x_Dept_Employee.deptCode = dept.deptCode

WHERE x_Dept_Employee.deptEmployeeID = @deptEmployeeID

GO

GRANT EXEC ON rpc_getEmployeeInClinicDetails TO PUBLIC

GO

-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeePositionsExtended')
	BEGIN
		DROP  Procedure  rpc_getEmployeePositionsExtended
	END

GO

CREATE Procedure rpc_getEmployeePositionsExtended
(
	@deptEmployeeID INT
)

AS

DECLARE @employeeSector INT
DECLARE @employeeGender INT
DECLARE @employeeID INT

SET @employeeID = (	SELECT EmployeeID
					FROM x_dept_employee
					WHERE DeptEmployeeID = @deptEmployeeID
				   )

SET @employeeSector  =	(SELECT EmployeeSectorCode
						FROM Employee
						WHERE employeeID = @employeeID)
						
SET @employeeGender  =	(SELECT Sex
						FROM Employee
						WHERE employeeID = @employeeID)						


SELECT p.PositionCode, p.Gender, p.PositionDescription, 0 as linkedToEmpInDept
FROM Position as p
WHERE ((@employeeGender = 0 AND p.gender = 1) OR ( @employeeGender <> 0 AND @employeeGender = p.gender)) 
AND p.relevantSector = @employeeSector
AND p.positionCode NOT IN
(
	SELECT positionCode
	FROM x_Dept_Employee_Position dep	
	WHERE DeptEmployeeID = @deptEmployeeID
)

UNION

SELECT p.PositionCode, p.Gender, p.PositionDescription, 1 as linkedToEmpInDept
FROM Position as p 
INNER JOIN x_Dept_Employee_Position dep ON p.positionCode = dep.positionCode
WHERE DeptEmployeeID = @deptEmployeeID
AND ((@employeeGender = 0 AND p.gender = 1) OR ( @employeeGender <> 0 AND @employeeGender = p.gender)) 
AND p.relevantSector = @employeeSector


ORDER BY p.PositionDescription



GO

GRANT EXEC ON rpc_getEmployeePositionsExtended TO PUBLIC

GO

-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeeProfessionsInDept')
	BEGIN
		DROP  Procedure  rpc_getEmployeeProfessionsInDept
	END
GO

CREATE Procedure dbo.rpc_getEmployeeProfessionsInDept
(
	@deptEmployeeID int
)

AS

SELECT 
xdes.serviceCode as professionCode,
[Services].ServiceDescription as professionDescription,
mainProfession,
'expProfession' = CASE expProfession WHEN 1 THEN '(מומחה)' ELSE '' END
FROM x_Dept_Employee_Service as xdes
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
INNER JOIN EmployeeServices ON xdes.serviceCode = EmployeeServices.serviceCode AND xd.employeeID = EmployeeServices.EmployeeID
INNER JOIN [Services] ON xdes.serviceCode = [Services].ServiceCode
WHERE xdes.deptEmployeeID = @deptEmployeeID
AND [Services].IsService = 0
ORDER BY professionDescription


GO


GRANT EXEC ON rpc_getEmployeeProfessionsInDept TO PUBLIC

GO

-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeeServicesInDept')
	BEGIN
		drop procedure rpc_getEmployeeServicesInDept
	END

GO


CREATE Procedure [dbo].[rpc_getEmployeeServicesInDept]
(
	@deptEmployeeID INT	
)

AS

SELECT
'ToggleID' = xdes.serviceCode,
xdes.x_Dept_Employee_ServiceID, 
xd.deptCode,
xd.employeeID,
xdes.serviceCode,
ServiceDescription,
StatusDescription,
desr.RemarkID,
dbo.rfn_GetFotmatedRemark(desr.RemarkText) as RemarkText,
'parentCode' = 0,
'QueueOrderDescription' = IsNull(DIC_QueueOrder.QueueOrderDescription, '&nbsp;'),
'phonesForQueueOrder' = [dbo].fun_getEmployeeServiceQueueOrderPhones_All(xd.employeeID, xd.deptCode, xdes.serviceCode),
IsService,
IsProfession

FROM x_Dept_Employee_Service as xdes
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
INNER JOIN EmployeeServices ON xd.employeeID = EmployeeServices.employeeID AND xdes.serviceCode = EmployeeServices.serviceCode
INNER JOIN DIC_ActivityStatus dic ON xdes.Status = dic.Status	
INNER JOIN [Services] ON xdes.serviceCode = [Services].ServiceCode
LEFT JOIN DeptEmployeeServiceRemarks desr ON xdes.DeptEmployeeServiceRemarkID = desr.DeptEmployeeServiceRemarkID
LEFT JOIN DIC_QueueOrder ON xdes.QueueOrder = DIC_QueueOrder.QueueOrder
--QueueOrder
WHERE xdes.DeptEmployeeID = @deptEmployeeID
ORDER BY  IsService, ServiceDescription



SELECT 
ESQOM.EmployeeServiceQueueOrderMethodID,
ESQOM.QueueOrderMethod,
xdes.serviceCode,
DIC_QueueOrderMethod.QueueOrderMethodDescription,
DIC_QueueOrderMethod.ShowPhonePicture,
DIC_QueueOrderMethod.SpecialPhoneNumberRequired,
xdes.x_Dept_Employee_ServiceID

FROM EmployeeServiceQueueOrderMethod ESQOM
INNER JOIN DIC_QueueOrderMethod ON ESQOM.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
INNER JOIN x_Dept_Employee_Service xdes ON ESQOM.x_dept_employee_serviceID = xdes.x_Dept_Employee_ServiceID	
--INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
WHERE xdes.DeptEmployeeID = @deptEmployeeID
ORDER BY QueueOrderMethod


SELECT 
x_Dept_Employee_ServiceID,
'shortPhoneTypeName' = CASE phoneType WHEN 2 THEN 'פקס' ELSE 'טל`' END,
phoneOrder,
'phoneNumber' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension)
FROM EmployeeServicePhones
WHERE x_Dept_Employee_ServiceID in
	(SELECT x_Dept_Employee_ServiceID 
	FROM x_Dept_Employee_Service xdes	
	WHERE xdes.DeptEmployeeID = @deptEmployeeID)

UNION

SELECT
x_Dept_Employee_ServiceID,
'shortPhoneTypeName' = CASE phoneType WHEN 2 THEN 'פקס' ELSE 'טל`' END,
phoneOrder,
'phoneNumber' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension)

FROM x_Dept_Employee_Service xdes
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
INNER JOIN DeptEmployeePhones dep ON dep.DeptEmployeeID = xd.DeptEmployeeID AND dep.phoneType <> 2
WHERE xdes.CascadeUpdateEmployeeServicePhones = 1

UNION

SELECT
x_Dept_Employee_ServiceID,
'shortPhoneTypeName' = CASE phoneType WHEN 2 THEN 'פקס' ELSE 'טל`' END,
phoneOrder,
'phoneNumber' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension)

FROM x_Dept_Employee_Service xdes
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID	
INNER JOIN DeptPhones dp ON xd.deptCode = dp.deptCode AND dp.phoneType <> 2
WHERE xdes.CascadeUpdateEmployeeServicePhones = 1
AND xd.CascadeUpdateDeptEmployeePhonesFromClinic = 1




SELECT
xdes.x_Dept_Employee_ServiceID,
xdes.DeptEmployeeID,
xdes.serviceCode,
EmployeeServiceQueueOrderHoursID,
esqoh.EmployeeServiceQueueOrderMethodID,
esqoh.receptionDay,
ReceptionDayName,
FromHour,
ToHour
FROM EmployeeServiceQueueOrderHours esqoh
INNER JOIN vReceptionDaysForDisplay ON esqoh.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode
INNER JOIN EmployeeServiceQueueOrderMethod esqom ON esqoh.EmployeeServiceQueueOrderMethodID = esqom.EmployeeServiceQueueOrderMethodID
INNER JOIN x_Dept_Employee_Service as xdes ON esqom.x_dept_employee_serviceID = xdes.x_Dept_Employee_ServiceID
WHERE xdes.DeptEmployeeID = @deptEmployeeID
ORDER BY vReceptionDaysForDisplay.ReceptionDayCode, FromHour

GO


GRANT EXEC ON rpc_getEmployeeServicesInDept TO PUBLIC
GO

-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertDeptEmployeePhone')
	BEGIN
		DROP  Procedure  rpc_insertDeptEmployeePhone
	END

GO

CREATE Procedure dbo.rpc_insertDeptEmployeePhone
	(	
		@deptEmployeeID int,
		@phoneType int,
		@prePrefix int,
		@prefix int,
		@phone int,
		@extension int,		
		@updateUser varchar(50),
		@ErrCode int OUTPUT 
	)

AS

IF @Prefix = -1
	BEGIN
		SET @Prefix = null 
	END
IF @PrePrefix = -1
	BEGIN
		SET @PrePrefix = null
	END
IF @extension = -1
	BEGIN
		SET @extension = null
	END

DECLARE @PhoneOrder int
SET @PhoneOrder = (SELECT MAX(phoneOrder) + 1 
					FROM DeptEmployeePhones 
					WHERE DeptEmployeeID = @deptEmployeeID
					AND phoneType = @phoneType
				   )
SET @PhoneOrder = IsNull(@PhoneOrder,1)


	INSERT INTO DeptEmployeePhones
		(phoneType, phoneOrder, prePrefix, prefix, phone, extension, updateUser, updateDate, DeptEmployeeID)
	VALUES
		(@phoneType, @PhoneOrder, @prePrefix, @prefix, @phone, @extension, @updateUser, getdate(), @deptEmployeeID)
		
	SET @ErrCode = @@Error


GO

GRANT EXEC ON rpc_insertDeptEmployeePhone TO PUBLIC

GO


-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertEmployeeQueueOrderMethod')
	BEGIN
		DROP  Procedure  rpc_insertEmployeeQueueOrderMethod
	END

GO

CREATE Procedure dbo.rpc_insertEmployeeQueueOrderMethod
	(
		@deptEmployeeID int,
		@QueueOrderMethod int, 
		@updateUser varchar(50),
		@ErrCode int OUTPUT,
		@newID int OUTPUT
	)

AS			   

	INSERT INTO EmployeeQueueOrderMethod
	(QueueOrderMethod, updateDate, updateUser, DeptEmployeeID)
	VALUES
	(@QueueOrderMethod, getdate(), @updateUser, @deptEmployeeID)

				
	SET @ErrCode = @@Error
	SET @newID = @@IDENTITY
		
GO

GRANT EXEC ON rpc_insertEmployeeQueueOrderMethod TO PUBLIC

GO

-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertEmployeeReception')
	BEGIN
		DROP  Procedure  rpc_InsertEmployeeReception
	END

GO

CREATE Procedure dbo.rpc_InsertEmployeeReception
(
		@employeeID INT,
		@deptCode  INT,
		@receptionDay INT,
		@openingHour VARCHAR(5),
		@closingHour VARCHAR(5),
		@validFrom SMALLDATETIME,
		@validTo SMALLDATETIME,
		@itemType VARCHAR(10),
		@itemID  INT,
		@remark  VARCHAR(500),
		@remarkID INT,
		@updateUser VARCHAR(50)
)

AS

DECLARE @ReceptionID  INT
DECLARE @enableOverlappingHours  INT
DECLARE @deptEmployeeID  INT

SET @enableOverlappingHours = 0

SET @deptEmployeeID =	(SELECT DeptEmployeeID
						 FROM x_dept_employee
						 WHERE DeptCode = @deptCode
						 AND EmployeeID = @employeeID
						)


--EmployeeReception
INSERT INTO DeptEmployeeReception (ReceptionDay, OpeningHour, ClosingHour, 
											ValidFrom, ValidTo, UpdateDate, UpdateUser, disableBecauseOfOverlapping, DeptEmployeeID )
VALUES( @receptionDay, @openingHour, @closingHour, @validFrom, @validTo, GetDate(), @updateUser, 0, @deptEmployeeID)


SET @ReceptionID = @@IDENTITY

IF (@remarkID > 0)
BEGIN
	SELECT @enableOverlappingHours = EnableOverlappingHours
									 FROM DIC_GeneralRemarks
									 WHERE RemarkID = @remarkID
	-- Remarks
	INSERT INTO DeptEmployeeReceptionRemarks(EmployeeReceptionID, RemarkText, RemarkId,  ValidFrom, 
											ValidTo, UpdateDate, UpdateUser, EnableOverlappingHours, DisplayInInternet)
	VALUES( @receptionID, @remark, @remarkID, @validFrom, @validTo, GetDate(), @updateUser, @enableOverlappingHours, 1 )									 
END								 
	

INSERT INTO	deptEmployeeReceptionServices
(receptionID, serviceCode, updateUser, updateDate)
VALUES(@ReceptionID, @itemID, @updateUser, getdate())

GO


GRANT EXEC ON dbo.rpc_InsertEmployeeReception TO PUBLIC

GO

-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateDeptEmployeeQueueOrder')
	BEGIN
		DROP  Procedure  rpc_UpdateDeptEmployeeQueueOrder
	END

GO

CREATE Procedure dbo.rpc_UpdateDeptEmployeeQueueOrder
(
	@deptEmployeeID INT,	
	@queueOrder INT
)

AS


UPDATE x_Dept_Employee
SET QueueOrder = @queueOrder
WHERE DeptEmployeeID = @deptEmployeeID


GO


GRANT EXEC ON rpc_UpdateDeptEmployeeQueueOrder TO PUBLIC

GO

-- ***************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateEmployeeInDeptStatusWhenNoProfessions')
	BEGIN
		DROP  Procedure  rpc_UpdateEmployeeInDeptStatusWhenNoProfessions
	END

GO

CREATE Procedure [dbo].[rpc_UpdateEmployeeInDeptStatusWhenNoProfessions]
(		
	@deptEmployeeID INT,	
	@updateUser VARCHAR(50)
)

AS


IF (SELECT COUNT(*) FROM x_Dept_Employee_Service xdes
		INNER JOIN [Services] ON xdes.serviceCode = [Services].serviceCode
		WHERE DeptEmployeeID = @deptEmployeeID
		AND [Services].IsProfession = 1	) = 0
	AND 
	(SELECT COUNT(*) 
	FROM Employee 
	INNER JOIN EmployeeSector ON Employee.EmployeeSectorCode = EmployeeSector.EmployeeSectorCode
	INNER JOIN x_dept_employee xd ON  Employee.EmployeeID = xd.EmployeeID
	WHERE xd.DeptEmployeeID = @deptEmployeeID
	AND EmployeeSector.RelevantForProfession = 1
	AND Employee.IsMedicalTeam = 0
	) > 0

BEGIN
	DECLARE @CurrentDate datetime SET @CurrentDate = GETDATE()
	DECLARE @MaxNONfutureStatusID bigint
	
	SET @MaxNONfutureStatusID = (SELECT MAX(StatusID) 
								FROM EmployeeStatusInDept 
								WHERE DeptEmployeeID = @deptEmployeeID								
								AND FromDate <=  @CurrentDate)
		
	UPDATE EmployeeStatusInDept
	SET Status = 0
	WHERE DeptEmployeeID = @deptEmployeeID	
	AND (FromDate >= @CurrentDate
		OR
		(FromDate <= @CurrentDate AND StatusID = @MaxNONfutureStatusID)	)
			
	UPDATE x_Dept_Employee 
	SET Active = 0, updateDate = @CurrentDate,  UpdateUserName = @updateUser
	WHERE DeptEmployeeID = @deptEmployeeID

	DELETE FROM deptEmployeeReception
	WHERE DeptEmployeeID = @deptEmployeeID
	
	DELETE FROM x_Dept_Employee_Position
	WHERE DeptEmployeeID = @deptEmployeeID	

END
GO


GRANT EXEC ON rpc_UpdateEmployeeInDeptStatusWhenNoProfessions TO PUBLIC
GO


-- ***************************************


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetServicesNewBySector')
	BEGIN
		DROP  Procedure  rpc_GetServicesNewBySector
	END

GO

CREATE Procedure dbo.rpc_GetServicesNewBySector
(
	@selectedServices VARCHAR(max),
	@sectorCode INT,
	@IncludeService int = 1, -- in case  = 1 include Services with s.IsService = 1; case = 0 don't include them;
	@IncludeProfession int = 1,-- in case  = 1 include Professions with s.IsProfession = 1; case = 0 don't include them;
	@IsInCommunity bit,
	@IsInMushlam bit, 
	@IsInHospitals bit
)
 
AS


select distinct 
ServiceCode 
,ServiceDescription
,ServiceCategoryID 
,selected
,CategoryIDForSort
,CategoryDescrForSort
,AgreementType
,IsService
,IsProfession

from

------------------- ServiceCategory table
( -- begin union
SELECT 
ISNULL(SeCa_Se.ServiceCategoryID, -1) as ServiceCode   --'ServiceCategoryID'
,ISNULL(SeCa.ServiceCategoryDescription, 'שירותים שונים') as ServiceDescription ---'ServiceCategoryDescription'
,null as ServiceCategoryID
,0 as selected
,ISNULL(SeCa_Se.ServiceCategoryID, -1)as CategoryIDForSort
,ISNULL(SeCa.ServiceCategoryDescription, 'תתתת') AS CategoryDescrForSort
,null as 'AgreementType'
,0 as 'IsService'
,0 as IsProfession

FROM [Services] as s
left JOIN  x_ServiceCategories_Services as SeCa_Se
	ON 	SeCa_Se.ServiceCode = s.ServiceCode
		
left join x_Services_EmployeeSector as Se_EmSec
	on SeCa_Se.ServiceCode = Se_EmSec.ServiceCode
	 
left join ServiceCategories SeCa 
	on  SeCa.ServiceCategoryID = SeCa_Se.ServiceCategoryID

where	(	@sectorCode = -1
		or (Se_EmSec.EmployeeSectorCode is null 
			or Se_EmSec.EmployeeSectorCode = @sectorCode)
		)
		and (@IncludeService = 1 and s.IsService = 1 
			or	@IncludeProfession = 1 and s.IsProfession = 1)
		
		and(@IsInCommunity = 1 and s.IsInCommunity = 1
			or @IsInMushlam = 1 and  s.IsInMushlam = 1
			or @IsInHospitals = 1 and s.IsInHospitals = 1)

union

------------- Services table
SELECT 
s.ServiceCode
,s.ServiceDescription
,ISNULL(SeCa_Se.ServiceCategoryID, -1) AS 'ServiceCategoryID'
, CASE IsNull(sel.IntField, 0) WHEN 0 THEN 0 ELSE 1 END as 'selected'
,ISNULL(SeCa_Se.ServiceCategoryID, -1) AS 'CategoryIDForSort'
,ISNULL(SeCa.ServiceCategoryDescription, 'תתתת') AS 'CategoryDescrForSort'
,case when (s.IsInMushlam = 1
			and isnull(s.IsInCommunity, 0) = 0 
			and isnull(s.IsInHospitals, 0) = 0) 
	then 3 else null end as 'AgreementType'
,s.IsService as 'IsService'
,s.IsProfession

FROM [Services] as s
left JOIN  x_ServiceCategories_Services as SeCa_Se
	ON 	SeCa_Se.ServiceCode = s.ServiceCode
	
left join x_Services_EmployeeSector as Se_EmSec
	on SeCa_Se.ServiceCode = Se_EmSec.ServiceCode
	
LEFT JOIN (SELECT IntField FROM dbo.SplitString(@selectedServices)) as sel ON s.ServiceCode = sel.IntField

left join ServiceCategories SeCa 
	on  SeCa.ServiceCategoryID = SeCa_Se.ServiceCategoryID
	
where	(	@sectorCode = -1
		or (Se_EmSec.EmployeeSectorCode is null 
			or Se_EmSec.EmployeeSectorCode = @sectorCode)
		)
		and (@IncludeService = 1 and s.IsService = 1 
		or	@IncludeProfession = 1 and s.IsProfession = 1)
		
		and(@IsInCommunity = 1 and s.IsInCommunity = 1
			or @IsInMushlam = 1 and  s.IsInMushlam = 1
			or @IsInHospitals = 1 and s.IsInHospitals = 1)
) as t     -- end union


ORDER BY  CategoryDescrForSort, IsService, ServiceCategoryID, ServiceDescription

GO


GRANT EXEC ON rpc_GetServicesNewBySector TO PUBLIC

GO

----------------------------------------------------------------

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_getEmployeeQueueOrderPhones_All')
	BEGIN
		DROP  FUNCTION  fun_getEmployeeQueueOrderPhones_All
	END
GO

CREATE FUNCTION [dbo].fun_getEmployeeQueueOrderPhones_All(@EmployeeID int, @DeptCode int)
RETURNS varchar(1000)
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @ThereIsQueueOrderViaClinicPhone int SET @ThereIsQueueOrderViaClinicPhone = 0
	DECLARE @strPhones varchar(1000) SET @strPhones = ''

	SELECT @strPhones = @strPhones + dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) + '<br>'
	FROM DeptEmployeeQueueOrderPhones
	INNER JOIN EmployeeQueueOrderMethod ON DeptEmployeeQueueOrderPhones.QueueOrderMethodID = EmployeeQueueOrderMethod.QueueOrderMethodID
	INNER JOIN x_dept_employee xd ON EmployeeQueueOrderMethod.DeptemployeeID = xd.DeptemployeeID
	WHERE xd.deptCode  = @DeptCode
	AND xd.employeeID = @EmployeeID

SET @ThereIsQueueOrderViaClinicPhone =	
	(SELECT Count(*)
	FROM EmployeeQueueOrderMethod eqom
	INNER JOIN x_dept_employee xd ON eqom.DeptEmployeeID = xd.DeptEmployeeID
	INNER JOIN DIC_QueueOrderMethod ON eqom.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
	WHERE deptCode = @DeptCode
	AND employeeID = @EmployeeID
	AND ShowPhonePicture = 1 AND SpecialPhoneNumberRequired = 0)
	
	IF(@ThereIsQueueOrderViaClinicPhone = 1)
	BEGIN
		SELECT TOP 1 @strPhones = @strPhones + dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) + '<br>'
		FROM DeptPhones
		WHERE deptCode = @DeptCode AND DeptPhones.phoneType = 1
		ORDER BY phoneOrder
		
	END
	
	
	IF(LEN(@strPhones) = 0)	
		BEGIN
			SET @strPhones = ''--'&nbsp;'
		END
	RETURN( @strPhones )
	
END
GO 

grant exec on fun_getEmployeeQueueOrderPhones_All to public 
GO

 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDeptEmployeeID')
	BEGIN
		DROP  Procedure  rpc_GetDeptEmployeeID
	END

GO

CREATE Procedure rpc_GetDeptEmployeeID
	(
		@DeptCode int,
		@EmployeeID bigint
	)

AS

SELECT DeptEmployeeID 
FROM x_Dept_Employee
WHERE DeptCode = @DeptCode
AND employeeID = @EmployeeID

GO

GRANT EXEC ON rpc_GetDeptEmployeeID TO PUBLIC

GO

--**** Yaniv - Start fun_GetQueueOrderPhones **********************
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fun_GetQueueOrderPhones]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fun_GetQueueOrderPhones]
GO

CREATE FUNCTION [dbo].[fun_GetQueueOrderPhones] 
(
	@DeptCode int,
	@employeeID bigint,
	@serviceCode int
)

RETURNS 
@ResultTable table
(
	Phone varchar(20),
	QueueOrderMethodID int,		
	deptCode int,
	employeeID bigint,
	serviceCode int
)
as
begin
	/* The first select is from the service phones,
	   if it's empty the next select is from the employee phones,
	   and if there is no result, the next select is from the dept
	   phones.
	*/
	insert into @ResultTable
	
	SELECT 
	dbo.fun_ParsePhoneNumberWithExtension(ESQOP.Preprefix, ESQOP.Prefix, ESQOP.Phone, ESQOP.Extension) as Phone,  
	ESQOM.EmployeeServiceQueueOrderMethodID,
	dept.deptCode,
	xDE.employeeID,
	xDEs.serviceCode
	
	
	FROM EmployeeServiceQueueOrderPhones ESQOP
	join employeeServiceQueueOrderMethod ESQOM on ESQOM.employeeServiceQueueOrderMethodID = ESQOP.employeeServiceQueueOrderMethodID
	join x_dept_employee_service xDES on xDES.x_dept_employee_serviceID = ESQOM.x_dept_employee_serviceID
	join x_dept_employee xDE on xDE.deptEmployeeID = xDES.deptEmployeeID
	join dept on dept.deptCode = xDE.deptCode
	join DIC_QueueOrderMethod on DIC_QueueOrderMethod.QueueOrderMethod = ESQOM.QueueOrderMethod
	WHERE (xDEs.serviceCode = @serviceCode)
	and (dept.deptCode = @deptCode)
	and(xDE.employeeID = @employeeID) 
	
	UNION
	
	SELECT 
	dbo.fun_ParsePhoneNumberWithExtension(DEQOP.Preprefix, DEQOP.Prefix, DEQOP.Phone, DEQOP.Extension) as Phone,  
	EQOM.QueueOrderMethodID,
	xDE.deptCode,
	xDE.employeeID,
	x_D_E_S.serviceCode
	
	FROM DeptEmployeeQueueOrderPhones DEQOP
	join EmployeeQueueOrderMethod EQOM on DEQOP.QueueOrderMethodID = EQOM.QueueOrderMethodID
	join x_dept_employee xDE on xDE.deptEmployeeID = EQOM.deptEmployeeID
	join dept on xDE.deptCode = dept.deptCode
	left JOIN x_Dept_Employee_Service x_D_E_S
		ON xDE.deptemployeeID = x_D_E_S.deptemployeeID
	
	WHERE xDE.deptCode = @DeptCode and xDE.employeeID = @employeeID
	and x_D_E_S.serviceCode = @serviceCode 
	AND NOT EXISTS
	(SELECT * FROM EmployeeServiceQueueOrderMethod ESQOM
	join x_dept_employee_service xDES on xDES.x_dept_employee_serviceID = ESQOM.x_dept_employee_serviceID
	join x_dept_employee xDE2 on xDE2.deptEmployeeID = xDES.deptEmployeeID
	WHERE xDE2.deptCode = xDE.deptCode
	AND xDE2.employeeID = xDE.employeeID 
	AND xDES.serviceCode = x_D_E_S.serviceCode)
	
	
	UNION
	
	SELECT 
	dbo.fun_ParsePhoneNumberWithExtension(DQOP.Preprefix, DQOP.Prefix, DQOP.Phone, DQOP.Extension) as Phone,
	DQOP.QueueOrderMethodID,
	xDE.deptCode,
	xDE.employeeID,
	xDES.serviceCode
	
	from DeptQueueOrderPhones DQOP
	join deptQueueOrderMethod DQOM on DQOM.QueueOrderMethodID = DQOP.QueueOrderMethodID
	join Dept on dept.deptCode = DQOM.deptCode
	join x_dept_employee xDE on dept.deptCode = xDE.deptCode
	join x_dept_employee_service xDES on xDE.deptEmployeeID = xDES.deptEmployeeID
	
	WHERE 
	DQOM.deptCode = @deptCode
	and xDE.employeeID = @employeeID 
	and xDES.serviceCode = @serviceCode
	AND NOT EXISTS
	(SELECT * FROM EmployeeServiceQueueOrderMethod ESQOM
	join x_dept_employee_service xDES2 on xDES2.x_dept_employee_serviceID = ESQOM.x_dept_employee_serviceID
	join x_dept_employee xDE2 on xDE2.deptEmployeeID = xDES2.deptEmployeeID
	WHERE xDE2.deptCode = xDE.deptCode
	AND xDE2.employeeID = xDE.employeeID 
	AND xDES2.serviceCode = xDES.serviceCode)
	
	AND NOT EXISTS
	(SELECT * FROM EmployeeQueueOrderMethod EQOM
	join x_dept_employee xDE2 on EQOM.deptEmployeeID = xDE2.deptEmployeeID
	
	WHERE xDE2.deptCode = xDE.deptCode
	AND xDE2.employeeID = xDE.employeeID)
	
	return
end





GO


--**** Yaniv - End fun_GetQueueOrderPhones **********************



--**** Yaniv - Start fun_GetQueueOrderMethods *******************

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fun_GetQueueOrderMethods]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fun_GetQueueOrderMethods]
GO


CREATE FUNCTION [dbo].[fun_GetQueueOrderMethods] 
(
	@DeptCode int,
	@employeeID bigint,
	@serviceCode int
)

RETURNS 
@ResultTable table
(
	QueueOrderMethodID int,
	QueueOrderMethod int,		
	employeeID bigint,
	QueueOrderMethodDescription varchar(50),
	ShowPhonePicture tinyint,
	SpecialPhoneNumberRequired tinyint
)
as
begin

insert into @ResultTable
	
SELECT 
esqom.EmployeeServiceQueueOrderMethodID as 'QueueOrderMethodID',
esqom.QueueOrderMethod,
xDE.DeptEmployeeID,
--xdes.serviceCode,
DIC_QueueOrderMethod.QueueOrderMethodDescription,
DIC_QueueOrderMethod.ShowPhonePicture,
DIC_QueueOrderMethod.SpecialPhoneNumberRequired

FROM EmployeeServiceQueueOrderMethod esqom
INNER JOIN x_Dept_Employee_Service xdes ON esqom.x_dept_employee_serviceID = xdes.x_dept_employee_serviceID
INNER JOIN x_Dept_Employee xDE ON xdes.DeptEmployeeID = xDE.DeptEmployeeID
INNER JOIN DIC_QueueOrderMethod ON esqom.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
WHERE xDE.deptCode = @DeptCode
AND xDE.EmployeeID = @EmployeeID
AND xdes.serviceCode = @serviceCode





UNION

SELECT 
EQOM.QueueOrderMethodID,
EQOM.QueueOrderMethod,
xDE.DeptEmployeeID,
--'serviceCode' = 0,
DIC_QueueOrderMethod.QueueOrderMethodDescription,
DIC_QueueOrderMethod.ShowPhonePicture,
DIC_QueueOrderMethod.SpecialPhoneNumberRequired

FROM EmployeeQueueOrderMethod EQOM
INNER JOIN DIC_QueueOrderMethod ON EQOM.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
INNER JOIN x_dept_employee xDE ON EQOM.DeptEmployeeID = xDE.DeptEmployeeID	
WHERE xDE.deptCode = @DeptCode 
AND xDE.EmployeeID = @employeeID
AND NOT EXISTS
(
	SELECT * FROM EmployeeServiceQueueOrderMethod esqom
	INNER JOIN x_Dept_Employee_Service xdes ON esqom.x_dept_employee_serviceID = xdes.x_dept_employee_serviceID
	INNER JOIN x_Dept_Employee xDE2 ON xdes.DeptEmployeeID = xDE2.DeptEmployeeID
	WHERE xDE2.EmployeeID = xDE.EmployeeID
	AND xDE2.DeptCode = xDE.DeptCode
	AND xdes.serviceCode = @serviceCode
)


	
	
	return
end





GO


--**** Yaniv - End fun_GetQueueOrderMethods *******************


--**** Yaniv - Start fun_GetQueueOrderHours *******************

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fun_GetQueueOrderHours]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fun_GetQueueOrderHours]
GO

CREATE FUNCTION [dbo].[fun_GetQueueOrderHours] 
(
	@DeptCode int,
	@employeeID bigint,
	@serviceCode int
)

RETURNS 
@ResultTable table
(
	--deptCode int,
	--serviceCode int,
	--employeeID bigint,
	--QueueOrderMethodID int,		
	receptionDay int,
	ReceptionDayName varchar(50),
	FromHour varchar(5),
	toHour varchar(5)
	
)
as
begin
/* 
   The first select is from the service hours,
   if it's empty the next select is from the employee hours.
   
*/



insert into @ResultTable
SELECT
--xDE.deptCode,
--xDES.serviceCode,
--xDE.employeeID,
--ESQOH.EmployeeServiceQueueOrderMethodID,
ESQOH.receptionDay,
vReceptionDaysForDisplay.ReceptionDayName,
ESQOH.FromHour,
ESQOH.ToHour

FROM
EmployeeServiceQueueOrderHours ESQOH
JOIN vReceptionDaysForDisplay
	ON ESQOH.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode
JOIN EmployeeServiceQueueOrderMethod SQOM ON ESQOH.EmployeeServiceQueueOrderMethodID = SQOM.EmployeeServiceQueueOrderMethodID
JOIN x_Dept_Employee_Service xDES ON SQOM.x_Dept_Employee_ServiceID = xDES.x_Dept_Employee_ServiceID
JOIN x_Dept_Employee xDE ON xDES.DeptEmployeeID = xDE.DeptEmployeeID

WHERE xDES.serviceCode = @serviceCode
and xDE.deptCode = @deptCode
and xDE.EmployeeID = @employeeID

insert into @ResultTable
SELECT 
--xDE.deptCode,
--'serviceCode' = @serviceCode,
--xDE.employeeID,
--EQOH.EmployeeQueueOrderMethodID,
EQOH.receptionDay,
vReceptionDaysForDisplay.ReceptionDayName,
EQOH.FromHour,
EQOH.ToHour

FROM 
EmployeeQueueOrderHours EQOH
JOIN vReceptionDaysForDisplay
	ON EQOH.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode 
JOIN EmployeeQueueOrderMethod EQOM ON EQOM.queueOrderMethodID = EQOH.queueOrderMethodID	
JOIN x_Dept_Employee xDE ON EQOM.DeptEmployeeID = xDE.DeptEmployeeID
WHERE xDE.EmployeeID = @EmployeeID
AND xDE.DeptCode = @DeptCode
AND NOT EXISTS
(
	SELECT * FROM @ResultTable
)
return
end


GO





--**** Yaniv - End fun_GetQueueOrderHours *******************

--**** Yaniv - fun_GetServicePhoneAndFaxes ******************

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fun_GetServicePhoneAndFaxes]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fun_GetServicePhoneAndFaxes]
GO

CREATE FUNCTION [dbo].[fun_GetServicePhoneAndFaxes] 
(
	@DeptCode int,
	@employeeID bigint,
	@serviceCode int
)

RETURNS 
@ResultTable table
(
	phone varchar(15),
	phoneType int
)
as
begin
/* 
   The function select first from the service phones,
   if it's empty it select from the employeeDept phones,
   if it's empty it select from the dept phones.
   
*/

declare @tableServicePhones table
(
	phone varchar(15),
	phoneType int
	
)

declare @tableEmployeePhones table
(
	phone varchar(15),
	phoneType int
	
)

declare @tableDeptPhones table
(
	phone varchar(15),
	phoneType int
	
)

insert into @tableServicePhones
select
'phone' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension),
phoneType from x_Dept_Employee xDE
JOIN x_Dept_Employee_Service xDES
on xDE.DeptEmployeeID = xDES.DeptEmployeeID
JOIN EmployeeServicePhones ESP 
on xDES.x_Dept_Employee_ServiceID = ESP.x_Dept_Employee_ServiceID
where xDE.deptCode = @deptCode and xDE.employeeID = @employeeID
and xDES.serviceCode = @serviceCode


insert into @tableEmployeePhones
select
'phone' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension),
phoneType from DeptEmployeePhones DEP
JOIN x_Dept_Employee xDE
on DEP.DeptEmployeeID = xDE.DeptEmployeeID
where xDE.deptCode = @deptCode and xDE.employeeID = @employeeID
and not exists
(
	select phone from @tableServicePhones
)


insert into @tableDeptPhones
select
'phone' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension),
phoneType from DeptPhones
where deptCode = @deptCode
and not exists
(
	select phone from @tableServicePhones
)
and not exists
(
	select phone from @tableEmployeePhones
)



insert into @ResultTable
select * from @tableServicePhones
union
select * from @tableEmployeePhones
union
select * from @tableDeptPhones
order by phoneType
return
end






GO



--**** Yaniv - End fun_GetServicePhoneAndFaxes ******************


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetServiceByCode')
    BEGIN
	    DROP  Procedure  rpc_GetServiceByCode
    END

GO

CREATE Procedure dbo.rpc_GetServiceByCode
(
	@serviceCode INT
)

AS


DECLARE @sectors VARCHAR(30)
DECLARE @categories VARCHAR(200)
DECLARE @categoriesCodes VARCHAR(200)


SET @sectors = ''
SET @categories = ''
SET @categoriesCodes = ''

-- Sectors *****
SELECT @sectors = @sectors + CONVERT(varchar,EmployeeSectorCode) + ','
FROM x_Services_EmployeeSector
WHERE ServiceCode = @serviceCode	
	

-- Categories *****
SELECT @categories = @categories + CONVERT(varchar,ServiceCategoryDescription) + ','
FROM x_ServiceCategories_Services xsc
INNER JOIN ServiceCategories sc on xsc.ServiceCategoryID = sc.ServiceCategoryID
WHERE ServiceCode = @serviceCode

IF LEN(@categories) > 0
	SET @categories = SUBSTRING(@categories,1 , LEN(@categories) - 1)

SELECT @categoriesCodes = @categoriesCodes + CONVERT(varchar,xsc.ServiceCategoryID) + ','
FROM x_ServiceCategories_Services xsc
INNER JOIN ServiceCategories sc on xsc.ServiceCategoryID = sc.ServiceCategoryID
WHERE ServiceCode = @serviceCode

IF LEN(@categoriesCodes) > 0
	SET @categoriesCodes = SUBSTRING(@categoriesCodes,1 , LEN(@categoriesCodes) - 1)


		
-- main select *****
SELECT ServiceCode, ServiceDescription, IsService, IsProfession, ISNULL(IsInMushlam,0) as IsInMushlam,
				ISNULL(IsInCommunity,0) as IsInCommunity, EnableExpert, 
				ISNULL(IsInHospitals,0) as IsInHospitals,  ShowExpert, @sectors  as Sectors, 
				@categories as Categories, @categoriesCodes as CategoriesCodes, SectorToShowWith
FROM [Services] s
WHERE ServiceCode = @serviceCode

                
GO


GRANT EXEC ON rpc_GetServiceByCode TO PUBLIC

GO            


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertService')
    BEGIN
	    DROP  Procedure  rpc_InsertService
    END

GO

CREATE Procedure dbo.rpc_InsertService
(
	@serviceCode INT,  
	@serviceDesc VARCHAR(100),  
	@isService BIT,  
	@isProfession BIT,  
	@sectors VARCHAR(30),
	@isCommunity BIT,  
	@isMushlam BIT,  
	@isHospitals BIT,  
	@categories VARCHAR(100),  
	@enableExpert BIT,  
	@showExpert VARCHAR(100),
	@SectorToShowWith int
)

AS

INSERT INTO [Services] (ServiceCode,  ServiceDescription, IsService, IsProfession, IsInMushlam, IsInCommunity, 
									IsInHospitals, ShowExpert, EnableExpert, SectorToShowWith)
VALUES (@serviceCode,  @serviceDesc, @isService, @isProfession, @isMushlam, @isCommunity, @isHospitals, @showExpert, @enableExpert, @SectorToShowWith)


INSERT INTO x_Services_EmployeeSector
SELECT @serviceCode, IntField
FROM dbo.SplitString(@sectors)


INSERT INTO x_ServiceCategories_Services
SELECT IntField, @serviceCode
FROM dbo.SplitString(@categories)


                
GO


GRANT EXEC ON rpc_InsertService TO PUBLIC

GO            


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateService')
    BEGIN
	    DROP  Procedure  rpc_UpdateService
    END

GO

CREATE Procedure dbo.rpc_UpdateService
(
	@serviceCode INT,  
	@serviceDesc VARCHAR(100),  
	@isService BIT,  
	@isProfession BIT,  
	@sectors VARCHAR(100), 
	@isCommunity BIT,  
	@isMushlam BIT,  
	@isHospitals BIT,  
	@categories VARCHAR(100),  
	@enableExpert BIT,  
	@showExpert VARCHAR(50),
	@SectorToShowWith int
)

AS


UPDATE [Services]
SET ServiceDescription = @serviceDesc, 
IsService = @isService, 
IsProfession = @isProfession,
IsInCommunity = @isCommunity,
IsInMushlam = @isMushlam,
IsInHospitals = @isHospitals,
EnableExpert = @enableExpert,
ShowExpert = @showExpert,
SectorToShowWith =	@SectorToShowWith
WHERE ServiceCode = @serviceCode

-- Sectors
DELETE x_Services_EmployeeSector
WHERE ServiceCode = @serviceCode

INSERT INTO x_Services_EmployeeSector
SELECT @serviceCode, IntField
FROM dbo.SplitString(@sectors)


-- Categories
DELETE x_ServiceCategories_Services
WHERE ServiceCode = @serviceCode

INSERT INTO x_ServiceCategories_Services
SELECT IntField, @serviceCode
FROM dbo.splitString(@categories)



                
GO


GRANT EXEC ON rpc_UpdateService TO PUBLIC

GO            

--*****************************************************************************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getNeighbourhoodsAndSitesByCityCode')
	BEGIN
		DROP  Procedure  rpc_getNeighbourhoodsAndSitesByCityCode
	END

GO

CREATE Procedure dbo.rpc_getNeighbourhoodsAndSitesByCityCode
(
	@cityCode int,
	@SearchStr varchar(20)=null
)

AS

SELECT CityCode, rtrim( ltrim(InstituteName)) as Name, InstituteCode as Code, 1 as IsSite 
FROM Atarim
WHERE (@cityCode is null or CityCode = @cityCode ) 
AND (@SearchStr is null or InstituteName like '%' + @SearchStr + '%') 


UNION

SELECT CityCode, rtrim( ltrim(NybName)) as Name, NeighbourhoodCode as Code, 0 as IsSite  
FROM Neighbourhoods
WHERE (@cityCode is null or CityCode = @cityCode ) 
AND (@SearchStr is null or NybName like '%' + @SearchStr+ '%') 

ORDER BY Name

GO


GRANT EXEC ON dbo.rpc_getNeighbourhoodsAndSitesByCityCode TO PUBLIC

GO

--*****************************************************************************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getNeighbourhoodsByCityCode')
	BEGIN
		DROP  Procedure  rpc_getNeighbourhoodsByCityCode
	END

GO

CREATE Procedure dbo.rpc_getNeighbourhoodsByCityCode
	(
		@cityCode int,
		@SearchStr varchar(20)=null
	)

AS

SELECT CityCode, rtrim( ltrim(NybName)) as NeighbourhoodName, NeighbourhoodCode 
FROM Neighbourhoods
WHERE (@cityCode is null or CityCode = @cityCode ) 
AND (@SearchStr is null or NybName like '%' + @SearchStr+ '%') 
ORDER BY NybName

GO

GRANT EXEC ON rpc_getNeighbourhoodsByCityCode TO PUBLIC

GO

--**** Yaniv - Start rpc_findDistrictsByName ----------------

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_findDistrictsByName')
	BEGIN
		DROP  Procedure  dbo.rpc_findDistrictsByName
	END

GO

CREATE Procedure dbo.rpc_findDistrictsByName
	(
		@SearchString varchar(50),
		@unitCodes varchar(20)
	)

AS

SELECT deptCode as districtCode, DistrictName FROM
(	
Select deptCode, rtrim(ltrim(deptName)) as DistrictName, showOrder = 0,
'typeUnitCode' = case typeUnitCode 
	when 65 then 0
	when 60 then 1
	end

FROM dept
WHERE typeUnitCode in (SELECT IntField FROM dbo.SplitString(@unitCodes))
AND deptName like @SearchString + '%'

UNION

Select deptCode, rtrim(ltrim(deptName)) as DistrictName, showOrder = 1,
'typeUnitCode' = case typeUnitCode 
	when 65 then 0
	when 60 then 1
	end
FROM dept
WHERE typeUnitCode in (SELECT IntField FROM dbo.SplitString(@unitCodes))
AND(deptName like '%'+ @SearchString + '%' AND deptName NOT like @SearchString + '%')

) as T1
ORDER BY typeUnitCode,showOrder, DistrictName


GO

GRANT EXEC ON dbo.rpc_findDistrictsByName TO PUBLIC

GO


--**** Yaniv - End rpc_findDistrictsByName ----------------

--**** Yaniv - Start rpc_getDistrictsExtended --------------
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDistrictsExtended')
	BEGIN
		DROP  Procedure  rpc_getDistrictsExtended
	END

GO

CREATE Procedure rpc_getDistrictsExtended
	(
		@SelectedDistricts varchar(100),
		@unitCodes varchar(20)
	)

AS

select deptCode,deptName,typeUnitCode,
'selected' = CASE IsNull(sel.IntField, 0) WHEN 0 THEN 0 ELSE 1 END
into #tmpTable from
	Dept
	LEFT JOIN (SELECT IntField FROM dbo.SplitString(@SelectedDistricts)) as sel ON dept.deptCode = sel.IntField
	WHERE typeUnitCode in (SELECT IntField FROM dbo.SplitString(@unitCodes))
	
	order by typeUnitCode desc,deptName


select deptCode as districtCode,
deptName as districtName,selected from #tmpTable
DROP TABLE #tmpTable


GO

GRANT EXEC ON rpc_getDistrictsExtended TO PUBLIC

GO


--**** Yaniv - End rpc_getDistrictsExtended --------------

--**** Yaniv - Start rpc_getDistrictsByUnitType ---------------
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDistrictsByUnitType')
	BEGIN
		DROP  Procedure  rpc_getDistrictsByUnitType
	END

GO

CREATE Procedure dbo.rpc_getDistrictsByUnitType
	(
		@unitCodes varchar(20)
	)

AS

select deptCode,deptName,
'sort' = case typeUnitCode
		 when '60' then 1
		 when '65' then 0
		 end
into #tmpTable from Dept
	WHERE typeUnitCode in (SELECT IntField FROM dbo.SplitString(@unitCodes))
ORDER BY sort,deptName


select deptCode as districtCode,
deptName as districtName from #tmpTable
DROP TABLE #tmpTable



GO

GRANT EXEC ON dbo.rpc_getDistrictsByUnitType TO PUBLIC

GO


--**** Yaniv - End rpc_getDistrictsByUnitType ---------------

--*************************************************************************************************************************************
--**** Yaniv - End rpc_getDistrictsByUnitType ---------------

--**** Yaniv - Start rpc_getCitiesAndDistrictsByNameAndDistrict ------

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getCitiesAndDistrictsByNameAndDistrict')
	BEGIN
		DROP  Procedure  rpc_getCitiesAndDistrictsByNameAndDistrict
	END

GO

CREATE Procedure dbo.rpc_getCitiesAndDistrictsByNameAndDistrict
(
	@SearchStr varchar(20),
	@DistrictCode int,
	@DeptCode int
)
 
AS
declare @tmpDistrictCode int
declare @tmpTypeUnitCode int

set @tmpDistrictCode = @DistrictCode

/* If the ditrict of the dept is hospital it will return the all cities */
if @DistrictCode <> -1
	begin
	set @tmpTypeUnitCode = (select typeUnitCode from Dept where deptCode = @DistrictCode)
	if(@tmpTypeUnitCode = 60)
		set @tmpDistrictCode = -1
	end


SELECT 
cityCode, 
'cityName' = cityName + ' - ' + districtName, 
Cities.districtCode
FROM Cities
INNER JOIN View_AllDistricts ON Cities.districtCode = View_AllDistricts.districtCode
WHERE ( @SearchStr is null or cityName like @SearchStr+'%')
	AND ( @tmpDistrictCode = -1 or Cities.districtCode = @tmpDistrictCode)
ORDER BY cityName


GO

GRANT EXEC ON rpc_getCitiesAndDistrictsByNameAndDistrict TO PUBLIC

GO

--**** Yaniv - End rpc_getCitiesAndDistrictsByNameAndDistrict ------


--**** Yaniv - Start DROP Procedures -----------------------
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptProfessionHoursForUpdate')
	BEGIN
		DROP  Procedure  rpc_getDeptProfessionHoursForUpdate
	END

GO 

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptProfessionHours')
	BEGIN
		DROP  Procedure  rpc_getDeptProfessionHours
	END

GO 



--**** Yaniv - End DROP Procedures -----------------------



IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDeptEmployeeServiceRemark')
	BEGIN
		DROP  Procedure  rpc_GetDeptEmployeeServiceRemark
	END

GO

CREATE Procedure dbo.rpc_GetDeptEmployeeServiceRemark
(
	@serviceCode INT,
	@employeeID BIGINT,
	@deptCode INT
)

AS


SELECT RemarkID, DeptEmployeeServiceRemarks.RemarkText, ValidFrom, ValidTo, DisplayInInternet
FROM DeptEmployeeServiceRemarks
JOIN x_Dept_Employee_Service xDES ON DeptEmployeeServiceRemarks.x_dept_employee_serviceID = xDES.x_Dept_Employee_ServiceID
JOIN x_Dept_Employee xDE ON xDES.DeptEmployeeID = xDE.DeptEmployeeID
WHERE xDES.ServiceCode = @serviceCode
AND xDE.DeptCode = @deptCode
AND xDE.EmployeeID = @employeeID


GO


GRANT EXEC ON rpc_GetDeptEmployeeServiceRemark TO PUBLIC

GO
-----------------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteDeptEmployeeServiceRemark')
	BEGIN
		DROP  Procedure  rpc_DeleteDeptEmployeeServiceRemark
	END

GO

CREATE Procedure dbo.rpc_DeleteDeptEmployeeServiceRemark
(
	@employeeID BIGINT,
	@deptCode INT, 
	@serviceCode INT
)

AS




DECLARE @deptEmployeeServiceID INT

SET @deptEmployeeServiceID = (
							  SELECT x_dept_employee_serviceID
							  FROM x_dept_employee_service xdes
							  INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
							  WHERE xd.deptCode = @deptCode
							  AND xd.employeeID = @employeeID
							  AND xdes.serviceCode = @serviceCode
							 )

DECLARE  @relevantRemarkID INT

SELECT @relevantRemarkID = DeptEmployeeServiceRemarkID
						FROM x_dept_employee_service
						WHERE x_Dept_Employee_ServiceID = @deptEmployeeServiceID
						
						
UPDATE x_dept_employee_service			
SET DeptEmployeeServiceRemarkID = NULL
WHERE x_Dept_Employee_ServiceID = @deptEmployeeServiceID



DELETE DeptEmployeeServiceRemarks
WHERE DeptEmployeeServiceRemarkID = @relevantRemarkID



GO


GRANT EXEC ON rpc_DeleteDeptEmployeeServiceRemark TO PUBLIC

GO


-- ***********************************************************************************************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeeQueueOrderMethods')
	BEGIN
		DROP  Procedure  rpc_getEmployeeQueueOrderMethods
	END

GO

CREATE Procedure dbo.rpc_getEmployeeQueueOrderMethods
(
	@deptEmployeeID int
)

AS


SELECT xd.QueueOrder,
eqom.QueueOrderMethod,
'DeptPhone' = dbo.fun_ParsePhoneNumberWithExtension(deptPhones.prePrefix,deptPhones.prefix,deptPhones.phone,deptPhones.extension),
queuePhones.prePrefix , dic.prefixCode, dic.prefixValue as PrefixText, queuePhones.phone, queuePhones.extension	

 
FROM x_dept_Employee xd
LEFT JOIN EmployeeQueueOrderMethod eqom ON xd.DeptEmployeeID  = eqom.DeptEmployeeID 
LEFT JOIN DeptPhones ON deptPhones.DeptCode = xd.deptCode AND PhoneType = 1 AND PhoneOrder = 1 AND QueueOrderMethod = 1
LEFT JOIN DeptEmployeeQueueOrderPhones queuePhones ON eqom.QueueOrderMethodID = queuePhones.QueueOrderMethodID
LEFT JOIN DIC_PhonePrefix dic ON queuePhones.Prefix = dic.prefixCode

WHERE xd.DeptEmployeeID = @deptEmployeeID



SELECT EmployeeQueueOrderHoursID AS QueueOrderHoursID, receptionDay, FromHour as OpeningHour, ToHour as ClosingHour, 
'NumOfSessionsPerDay' = (
			SELECT count(*)
			FROM EmployeeQueueOrderMethod eqom2
			INNER JOIN EmployeeQueueOrderHours hours2 ON eqom2.QueueOrderMethodID = hours2.QueueOrderMethodID 
			AND hours.ReceptionDay = hours2.ReceptionDay
			GROUP BY receptionDay
		)
FROM EmployeeQueueOrderMethod eqom
INNER JOIN EmployeeQueueOrderHours hours ON eqom.QueueOrderMethodID = hours.QueueOrderMethodID
WHERE eqom.DeptEmployeeID = @deptEmployeeID
ORDER BY FromHour,ToHour



GO

GRANT EXEC ON rpc_getEmployeeQueueOrderMethods TO PUBLIC

GO

-- ***********************************************************************************************************************

--**** Yaniv - Start updating v_DeptReception -------------------------------
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_DeptReception]'))
DROP VIEW [dbo].[v_DeptReception]
GO

CREATE view [dbo].[v_DeptReception]
as 
select distinct  deptER.receptionID, deptER.deptCode, 
deptER.receptionDay,deptER.openingHour,deptER.closingHour,deptER.validFrom,deptER.validTo , 
deptERRemarks.RemarkID as RemarkID, deptERRemarks.RemarkText ,
Dept.deptName ,Dept.cityCode,cityName,deptER.ReceptionHoursTypeID

from DeptReception as deptER
left join DeptReceptionRemarks as deptERRemarks  on deptER.receptionID = deptERRemarks.ReceptionID
inner join  Dept on deptER.deptCode = Dept.deptCode 
inner join  Cities on Dept.cityCode = Cities.cityCode   
--where deptER.deptCode=43300

GO

grant select on v_DeptReception to public 
go

--**** Yaniv - End updating v_DeptReception -------------------------------


-- ***********************************************************************************************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetEmployeeStatusInDept')
	BEGIN
		DROP  Procedure  rpc_GetEmployeeStatusInDept
	END

GO

CREATE Procedure dbo.rpc_GetEmployeeStatusInDept
(
		@employeeID BIGINT,
		@deptCode	INT
)

AS


SELECT es.Status,DIC_ActivityStatus.StatusDescription, FromDate,ToDate
FROM EmployeeStatusInDept es
INNER JOIN x_dept_employee xd ON es.deptEmployeeID = xd.DeptEmployeeID
INNER JOIN DIC_ActivityStatus ON es.Status = DIC_ActivityStatus.status
WHERE xd.EmployeeID = @employeeID AND xd.DeptCode = @deptCode
ORDER BY fromDate


GO


GRANT EXEC ON rpc_GetEmployeeStatusInDept TO PUBLIC

GO


-- ***********************************************************************************************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptNamesForUpdate')
	BEGIN
		DROP  Procedure  rpc_getDeptNamesForUpdate
	END

GO

CREATE Procedure dbo.rpc_getDeptNamesForUpdate
	(
		@deptCode int
	)
AS

--- DeptDetails --------------------------------------------------------
SELECT
D.deptName,
D.deptType, -- 1, 2, 3
DIC_DeptTypes.deptTypeDescription, -- מחוז, מנהלת, מרפאה
D.typeUnitCode, -- סוג יחידה
'subUnitTypeCode' = IsNull(D.subUnitTypeCode, -1), -- שיוך
D.deptLevel,
D.DisplayPriority,
'showUnitInInternet' = IsNull(D.showUnitInInternet, 1)

FROM dept as D
INNER JOIN DIC_DeptTypes ON D.deptType = DIC_DeptTypes.deptType	-- ??
WHERE D.deptCode = @deptCode

-- DeptNames
SELECT
deptCode, deptName, fromDate, toDate
FROM DeptNames
WHERE deptCode = @deptCode
ORDER BY fromDate


GO

GRANT EXEC ON rpc_getDeptNamesForUpdate TO PUBLIC

GO


-- ***********************************************************************************************************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertDeptName')
	BEGIN
		DROP  Procedure  rpc_insertDeptName
	END

GO


CREATE Procedure dbo.rpc_insertDeptName
	(
		@DeptCode int,
		@DeptName varchar(100),
		@FromDate datetime,
		@ToDate datetime,
		@UpdateUser varchar(50)
	)

AS


	
INSERT INTO DeptNames
(deptCode, deptName, fromDate, ToDate, updateDate, updateUser)
VALUES
(@DeptCode, @DeptName, @FromDate, @ToDate, getdate(), @UpdateUser)

-- if it's from today, update dept name
IF DATEDIFF(dd, @FromDate, GETDATE()) = 0
	UPDATE DEPT
	SET DeptName = @DeptName
	WHERE DeptCode = @deptCode




GO

GRANT EXEC ON rpc_insertDeptName TO PUBLIC

GO
          
-- ***********************************************************************************************************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertDeptEvent')
	BEGIN
		DROP  Procedure  rpc_insertDeptEvent
	END

GO

CREATE Procedure dbo.rpc_insertDeptEvent
	(
		@DeptCode int, 
		@DeptEventID int, -- not in use but don't remove
		@EventCode int, 
		@EventDescription varchar(100),
		@meetingsNumber int,
		@FromDate smalldatetime,
		@ToDate smalldatetime,
		@RegistrationStatus int,
		@PayOrder int,
		@CommonPrice real,
		@MemberPrice real,
		@FullMemberPrice real,
		@TargetPopulation varchar(100),
		@Remark varchar(500),
		@displayInInternet tinyint,
		@UpdateUser	varchar(50),
		@cascadePhonesFromDept BIT,
		@DeptEventIDInserted int OUTPUT
	)

AS

IF @FromDate <= cast('1/1/1900 12:00:00 AM' as datetime)
	BEGIN
		SET  @FromDate=null
	END		
IF @ToDate <= cast('1/1/1900 12:00:00 AM' as datetime)
	BEGIN
		SET  @ToDate=null
	END		

BEGIN 

	INSERT INTO DeptEvent
	(deptCode, EventCode, EventDescription, MeetingsNumber, FromDate, ToDate, RegistrationStatus,
	PayOrder, CommonPrice, MemberPrice, FullMemberPrice, TargetPopulation, Remark, displayInInternet, UpdateUser, CascadeUpdatePhonesFromClinic)
	VALUES
	(@DeptCode, @EventCode, @EventDescription, @meetingsNumber, @FromDate, @ToDate, @RegistrationStatus,
	@PayOrder, @CommonPrice, @MemberPrice, @FullMemberPrice, @TargetPopulation, @Remark, @displayInInternet, @UpdateUser, @cascadePhonesFromDept)

	SET @DeptEventIDInserted = @@IDENTITY 
		
END 


GO

GRANT EXEC ON rpc_insertDeptEvent TO PUBLIC

GO
 
-- ***********************************************************************************************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_Insert_Interface_NewDepts_Intermediate')
	BEGIN
		DROP  Procedure  rpc_Insert_Interface_NewDepts_Intermediate
	END

GO

CREATE Procedure dbo.rpc_Insert_Interface_NewDepts_Intermediate

AS

INSERT INTO Interface_NewDepts_Intermediate
( SimulDeptId, SimulDeptName, dept_name, manageId, SimulManageDescription, 
City, street, house, entrance, flat, zip, 
Preprefix1, Prefix1, Nphone1, preprefix2, prefix2, Nphone2, 
faxpreprefix, faxprefix, Nfax, 
SugSimul501, TatSugSimul502, TatHitmahut503, RamatPeilut504, 
DistrictId, SugMosad, 
OpenDateSimul, ClosingDateSimul, StatusSimul, Email, Menahel, 
Simul228, DeptType, key_TypUnit, PopSectorID, NeedToInsertInto_UnitTypeConvertSimul)

SELECT 
 SimulDeptId, SimulDeptName, dept_name, manageId, SimulManageDescription, 
City, street, house, entrance, flat, zip, 
Preprefix1, Prefix1, Nphone1, preprefix2, prefix2, Nphone2, 
faxpreprefix, faxprefix, Nfax, 
SugSimul501, TatSugSimul502, TatHitmahut503, RamatPeilut504, 
DistrictId, SugMosad, 
OpenDateSimul, ClosingDateSimul, StatusSimul, Email, Menahel, 
Simul228, DeptType, key_TypUnit, PopSectorID, NeedToInsertInto_UnitTypeConvertSimul 

FROM( 
SELECT DISTINCT
dept.deptCode,
S403.KodSimul as SimulDeptId,
S403.TeurSimul as SimulDeptName,
'שם לא ידוע' as dept_name,
S403.manageId,
s2.TeurSimul as SimulManageDescription,
MF_Cities200.NewCityCode as City,
S403.street,
S403.house,
S403.entrance,
S403.flat,
S403.zip,
S403.Preprefix1,
S403.Prefix1,
S403.phone1 as Nphone1,
S403.preprefix2,
S403.prefix2,
S403.phone2 as Nphone2,
S403.faxpreprfix as faxpreprefix,
S403.faxprefix,
S403.fax as Nfax,
S403.SugSimul501,
S403.TatSugSimul502,
S403.TatHitmahut503,
S403.RamatPeilut504,
S403.Mahoz as DistrictId,
S403.SugMosad,
S403.DateOpened as OpenDateSimul,
S403.DateClosed as ClosingDateSimul,
S403.status as StatusSimul,
S403.Email,
S403.Menahel,
CASE WHEN C405.SimulConvertId is null THEN null ELSE CAST (RIGHT( RTRIM( IsNull(C405.SimulConvertId, 0) ), 4) as int) END
	as Simul228,
CASE S403.SugSimul501
		WHEN 65 THEN 1
		WHEN 55 THEN 2
		ELSE 3 END
	as DeptType,
IsNull(UTCS.key_TypUnit, 301) 
	as key_TypUnit,
CASE WHEN UTCS.SugSimul is NOT null THEN  IsNull(UTCS.PopSectorID, 1) ELSE null END
	as PopSectorID,

CASE WHEN	(
			SELECT COUNT(*) FROM UnitTypeConvertSimul UT 
			WHERE UT.SugSimul = S403.SugSimul501
			AND (	IsNull(S403.TatSugSimul502, 0) = 0 
					OR 
					(UT.TatSugSimul = S403.TatSugSimul502
						AND (IsNull(S403.TatHitmahut503, 0) = 0
							OR 
								(UT.TatHitmahut = S403.TatHitmahut503
									AND (IsNull(S403.RamatPeilut504, 0) = 0
										OR UT.RamatPeilut = S403.RamatPeilut504
										)
								)
							)
					) 
				)
			) > 0 THEN 0 ELSE 1 END
	as NeedToInsertInto_UnitTypeConvertSimul

FROM Simul403 S403
LEFT JOIN dept ON S403.KodSimul = dept.deptCode
LEFT JOIN Simul403 as s2 ON S403.manageId = s2.KodSimul
LEFT JOIN SimulExceptions SE ON S403.KodSimul = SE.SimulId
LEFT JOIN Conversion405 C405 ON S403.KodSimul = C405.SimulId 
								AND C405.SystemId = 11 AND C405.InActive = 0
LEFT JOIN UnitTypeConvertSimul UTCS ON S403.SugSimul501 = UTCS.SugSimul
									AND S403.TatSugSimul502 = UTCS.TatSugSimul
									AND S403.TatHitmahut503 = UTCS.TatHitmahut
									AND (UTCS.RamatPeilut is null OR S403.RamatPeilut504 = UTCS.RamatPeilut)
LEFT JOIN MF_Cities200 ON s2.City = MF_Cities200.Code

WHERE (dept.deptCode is null
		AND ( SE.SeferSherut = 1
			OR 
			(SE.SeferSherut is null AND DATEDIFF(d, S403.DateOpened, GETDATE()) < 8 AND dbo.fun_IsForSeferBy501To503(S403.KodSimul) = 1) )
	  )
	  OR
	  (dept.deptCode is NOT null
		AND dept.IsMushlam = 1
		AND dept.IsCommunity = 0
	  )
 ) as T

GO

GRANT EXEC ON rpc_Insert_Interface_NewDepts_Intermediate TO PUBLIC

GO

-- ***********************************************************************************************************************

--**** Yaniv - Start rpc_DeleteDeptReceptions *********************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteDeptReceptions')
	BEGIN
		DROP  Procedure  rpc_DeleteDeptReceptions
	END

GO

CREATE Procedure dbo.rpc_DeleteDeptReceptions

	(
			@deptCode int,
			@receptionHoursTypeID tinyint	
	)


AS
		BEGIN 
			DELETE FROM DeptReception
			WHERE DeptCode = @deptCode	
				and ReceptionHoursTypeID = @receptionHoursTypeID	
		END 	
GO

GRANT EXEC ON rpc_DeleteDeptReceptions TO PUBLIC

GO


--**** Yaniv - End rpc_DeleteDeptReceptions *********************

--**** Yaniv - Start rpc_GetDeptReceptions **********************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDeptReceptions')
	BEGIN
		DROP  Procedure  rpc_GetDeptReceptions
	END

GO

CREATE Procedure [dbo].[rpc_GetDeptReceptions]
(
	@deptCode int,
	@receptionHoursTypeID tinyint		
)
 
  
AS

SELECT  receptionID ,
  receptionDay, openingHour, closingHour, validFrom,validTo ,
v.RemarkID, RemarkText, EnableOverMidnightHours
FROM v_DeptReception v
LEFT JOIN DIC_GeneralRemarks rem ON v.RemarkID = rem.RemarkID
WHERE deptCode =  @deptCode AND  (validTo >= GETDATE() OR validTo IS NULL)
	And v.ReceptionHoursTypeID = @receptionHoursTypeID
ORDER BY receptionDay ,openingHour



SELECT 

openinghour, ClosingHour , remarkText, ValidFrom, ValidTo,  receptionDay,dense_rank() OVER (ORDER BY  

openinghour, ClosingHour,dayGroup) AS RecRank FROM 
(
SELECT 

openinghour, Closinghour , remarkText, ValidFrom, ValidTo, receptionDay,
sum(power(2,receptionDay-1)) OVER (partition BY 
openinghour,  CLOSINGhour, remarkText, ValidFrom, ValidTo ) dayGroup,
   COUNT(*) as nrecs 
FROM v_DeptReception
WHERE deptCode =  @deptCode   AND (validTo >= GETDATE() OR validTo IS NULL)
	And v_DeptReception.ReceptionHoursTypeID = @receptionHoursTypeID
GROUP BY  DeptCode, openinghour, CLOSINGhour, remarkText, ValidFrom, ValidTo, receptionDay) AS a 

GO


GRANT EXEC ON rpc_GetDeptReceptions TO PUBLIC

GO


--**** Yaniv - End rpc_GetDeptReceptions **********************

--**** Yaniv - Start rpc_insertDeptReceptions *****************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertDeptReceptions')
	BEGIN
		DROP  Procedure  rpc_insertDeptReceptions
	END

GO

CREATE Procedure dbo.rpc_insertDeptReceptions
(
		@deptCode int,
		@receptionDay int,
		@openingHour varchar(5),
		@closingHour varchar(5),
		@validFrom datetime,
		@validTo datetime,
		@RemarkID int,
		@RemarkText varchar(500),
		@updateUserName varchar(50),
		@receptionHoursTypeID tinyint
)

AS

DECLARE @NewReceptionID AS int

BEGIN 

	INSERT INTO DeptReception
	(
		DeptCode,
		receptionDay,
		openingHour,
		closingHour , 
		ValidFrom,
		ValidTo,
		UpdateDate,
		UpdateUserName,
		ReceptionHoursTypeID
	)
	VALUES
	(
		@DeptCode,
		@receptionDay,
		@openingHour,@closingHour,
		@validFrom,
		@validTo,		
		getdate(),
		@UpdateUserName,
		@receptionHoursTypeID
	)
print 'IDENT_CURRENT : - '
print IDENT_CURRENT('DeptReception')

set @NewReceptionID =  IDENT_CURRENT('DeptReception')

print '@NewReceptionID'
print @NewReceptionID

	if(@RemarkText <> '' and @RemarkID <> -1)
	begin 
	INSERT INTO DeptReceptionRemarks
		(
			ReceptionID, 
			RemarkText, 
			RemarkID, 
			ValidFrom, 
			ValidTo, 
			DisplayInInternet, 
			UpdateDate, 
			UpdateUser
		)
		VALUES
		(
			@NewReceptionID,
			@RemarkText,
			@RemarkID,
			null,
			null,	
			null,	
			getdate(),
			@UpdateUserName
		)
	end

	
END 

GO

GRANT EXEC ON rpc_insertDeptReceptions TO PUBLIC

GO

--**** Yaniv - End rpc_insertDeptReceptions *****************


IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[dbo].[SplitStringNoOrder]') and xtype in (N'FN', N'IF', N'TF'))
	DROP FUNCTION [dbo].[SplitStringNoOrder]

GO


PRINT 'Creating Procedure SplitStringNoOrder'
GO

--The following is a general purpose UDF to split comma separated lists into individual items with no order.
CREATE FUNCTION dbo.SplitStringNoOrder
(
	@ItemList varchar(500)
)
RETURNS 
@ParsedList table
(
	ItemID int
)
AS
BEGIN
	DECLARE @ItemID varchar(10), @Pos int

	SET @ItemList = LTRIM(RTRIM(@ItemList))+ ','
	SET @Pos = CHARINDEX(',', @ItemList, 1)

	IF REPLACE(@ItemList, ',', '') <> ''
	BEGIN
		WHILE @Pos > 0
		BEGIN
			SET @ItemID = LTRIM(RTRIM(LEFT(@ItemList, @Pos - 1)))
			IF @ItemID <> ''
			BEGIN
				INSERT INTO @ParsedList (ItemID) 
				VALUES (CAST(@ItemID AS int)) --Use Appropriate conversion
			END
			SET @ItemList = RIGHT(@ItemList, LEN(@ItemList) - @Pos)
			SET @Pos = CHARINDEX(',', @ItemList, 1)

		END
	END	
	RETURN
END



GO

GRANT select ON SplitStringNoOrder TO [clalit\webuser]

GO
------------------------------------------------------------------

--**** Yaniv - Start rfn_SplitStringValues ---------------------
 IF EXISTS (SELECT * FROM sysobjects WHERE name = 'rfn_SplitStringValues')
	BEGIN
		PRINT 'Dropping Procedure rfn_SplitStringValues'
		DROP  function rfn_SplitStringValues
	END

GO

PRINT 'Creating Procedure rfn_SplitStringValues'
GO

--The following is a general purpose UDF to split comma separated lists into individual items.
--Consider an additional input parameter for the delimiter, so that you can use any delimiter you like.
CREATE FUNCTION dbo.rfn_SplitStringValues
(
	@ItemList varchar(max)
)
RETURNS 
@ParsedList table
(
	ItemID int
)
AS
BEGIN
	DECLARE @ItemID varchar(10), @Pos int

	SET @ItemList = LTRIM(RTRIM(@ItemList))+ ','
	SET @Pos = CHARINDEX(',', @ItemList, 1)

	IF REPLACE(@ItemList, ',', '') <> ''
	BEGIN
		WHILE @Pos > 0
		BEGIN
			SET @ItemID = LTRIM(RTRIM(LEFT(@ItemList, @Pos - 1)))
			IF @ItemID <> ''
			BEGIN
				INSERT INTO @ParsedList (ItemID) 
				VALUES (CAST(@ItemID AS int)) --Use Appropriate conversion
			END
			SET @ItemList = RIGHT(@ItemList, LEN(@ItemList) - @Pos)
			SET @Pos = CHARINDEX(',', @ItemList, 1)

		END
	END	
	RETURN
END





GO

GRANT select ON rfn_SplitStringValues TO public

GO

--**** Yaniv - End rfn_SplitStringValues ---------------------

--**** Yaniv - Start rpc_getDoctorList_PagedSorted -----------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_getDoctorList_PagedSorted]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[rpc_getDoctorList_PagedSorted]
GO


CREATE Procedure [dbo].[rpc_getDoctorList_PagedSorted]

@FirstName varchar(max)=null,
@LastName varchar(max)=null,
@DistrictCodes varchar(max)=null,
@EmployeeID bigint=null,
@CityName varchar(max)=null,
@serviceCode varchar(max)=null,
@ExpProfession int=null,
@LanguageCode varchar(max)=null,
@ReceptionDays varchar(max)=null,
@OpenAtHour_Str varchar(max)=null,	-- string in format "hh:mm"
@OpenFromHour_Str varchar(max)=null,	-- string in format "hh:mm"
@OpenToHour_Str varchar(max)=null,	-- string in format "hh:mm"
@Active int=null,
@CityCode int=null,
@EmployeeSectorCode int = null,
@sex int = null,
@agreementType int = null,
@isInCommunity bit,
@isInMushlam bit,
@isInHospitals bit,
@deptHandicappedFacilities varchar(max) = null,
@licenseNumber int = null,
@positionCode int = null,

@PageSise int = null,
@StartingPage int = null,
@SortedBy varchar(max),
@IsOrderDescending int = null,

@NumberOfRecordsToShow int=null,
@CoordinateX float=null,
@CoordinateY float=null,

@userIsRegistered int=null,

@isGetEmployeesReceptionHours bit=null

with recompile
AS

IF @StartingPage is null
BEGIN SET @StartingPage = 1 END

SET @StartingPage = @StartingPage - 1 /* @StartingPage enumeration starts from 1. Here we start from  0 */

DECLARE @StartingPosition int
SET @StartingPosition = (@StartingPage * @PageSise)

DECLARE @SortedByDefault varchar(max)
SET @SortedByDefault = 'lastname'

DECLARE @Count int


DECLARE @HandicappedFacilitiesCount int
SET @HandicappedFacilitiesCount = IsNull((SELECT COUNT(IntField) FROM dbo.SplitString(@deptHandicappedFacilities)), 0)

IF (@CoordinateX = -1)
BEGIN
	SET @CoordinateX = null
	SET @CoordinateY = null
END

IF @CityCode <> null
BEGIN
	SET @CityName = null
END

IF(@NumberOfRecordsToShow <> -1)
	BEGIN
	IF(@NumberOfRecordsToShow < @PageSise)
		BEGIN
			SET @PageSise = @NumberOfRecordsToShow
		END
	END

DECLARE @OpenAtHour_var varchar(5)
DECLARE @OpenFromHour_var varchar(5)
DECLARE @OpenToHour_var varchar(5)
SET @OpenAtHour_var = IsNull(@OpenAtHour_Str,'00:00');
SET @OpenFromHour_var = IsNull(@OpenFromHour_Str,'00:00');
SET @OpenToHour_var = IsNull(@OpenToHour_Str,'24:00');

DECLARE @OpenAtHour_real real
DECLARE @OpenFromHour_real real
DECLARE @OpenToHour_real real

SET @OpenFromHour_real = CAST (LEFT(IsNull(@OpenFromHour_Str,'00:00'),2) as real) + CAST (RIGHT(IsNull(@OpenFromHour_Str,'00:00'),2) as real)/60
SET @OpenToHour_real = CAST (LEFT(IsNull(@OpenToHour_Str, '24:00'),2) as real) + CAST (RIGHT(IsNull(@OpenToHour_Str, '24:00'),2) as real)/60 
IF (@OpenAtHour_Str is not null)
BEGIN
	SET @OpenAtHour_real = CAST (LEFT(@OpenAtHour_Str,2) as real) + CAST (RIGHT(@OpenAtHour_Str,2) as real)/60 
END

--SELECT TOP (@PageSise) * INTO #tempTable FROM
SELECT  * INTO #tempTableAllRows FROM
(
-- middle selection - "employees themself" + RowNumber
SELECT *,
'RowNumber' = CASE @SortedBy 
			WHEN 'lastname' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY lastname  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY lastname   )
				END
			WHEN 'deptName' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY deptName  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY deptName   )
				END
			WHEN 'professions' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY professions DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY professions   )
				END				
			WHEN 'cityName' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY cityName  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY cityName   )
				END
			WHEN 'phone' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY phone  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY phone   )
				END
			WHEN 'address' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY address  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY address   )
				END
			WHEN 'AgreementType' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY AgreementType  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY AgreementType   )
				END
			-- map search	
			WHEN 'distance' THEN ROW_NUMBER() OVER(ORDER BY distance, deptCode)
		
			ELSE
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY orderLastNameLike DESC, lastname DESC, firstName DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY orderLastNameLike , lastname , firstName  )
				END
			END	

FROM
-- inner selection - "employees themself"
(
SELECT
Employee.employeeID,
'EmployeeName' = DegreeName + ' ' + lastName + ' ' + firstName,
lastname,
firstName,
'deptName' = IsNull(dept.deptName, ''),
'deptCode' = IsNull(dept.deptCode, ''),
x_dept_employee.DeptEmployeeID,
dic.QueueOrderDescription,
'address' = dbo.GetAddress(x_Dept_Employee.deptCode),
'cityName' = IsNull(cityName, ''),
--'phone' = '08-1234567','HasReception' =1, 'expert' = 'expert', 'HasRemarks' = 1,

'phone' = IsNULL(	(SELECT dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) 
					FROM DeptEmployeePhones 
					WHERE DeptEmployeeID = x_Dept_Employee.DeptEmployeeID					
					AND phoneType = 1
					AND phoneOrder = 1), 
			
					(SELECT dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension)
					FROM DeptPhones
					WHERE deptCode = x_Dept_Employee.deptCode
					AND phoneType = 1
					AND phoneOrder = 1
					AND x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1)
				),
'fax' = IsNULL(	(SELECT dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) 
					FROM DeptEmployeePhones 
					WHERE deptEmployeeID = x_Dept_Employee.DeptEmployeeID 					
					AND phoneType = 2
					AND phoneOrder = 1), 
			
					(SELECT dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension)
					FROM DeptPhones
					WHERE deptCode = x_Dept_Employee.deptCode
					AND phoneType = 2
					AND phoneOrder = 1
					AND x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1)
				),
'HasReception' = 
			CASE IsNull((SELECT count(receptionID) --!!Is it possible a doctor to be without reception?
					FROM deptEmployeeReception der
					WHERE der.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID					
					AND GETDATE() between ISNULL(validFrom,'1900-01-01') 
						and ISNULL(validTo,'2079-01-01'))
					, 0)
				WHEN 0 THEN 0 ELSE 1 END,
'expert' = CASE(Employee.IsVirtualDoctor) WHEN 1 THEN '' ELSE dbo.fun_GetEmployeeExpert(Employee.employeeID) END,
'HasRemarks' = CASE IsNull(
--using  View_DeptEmployee_EmployeeRemarks includes EmployeeRemarks  per clinic
-- and EmployeeRemarks Attributed ToAll Clinics InCommunity, ..InMushlam, ..InHospitals 
-- according to Dept Membership Type
				(SELECT distinct COUNT(*) 
				from View_DeptEmployee_EmployeeRemarks as v_DE_ER
					where v_DE_ER.EmployeeID =  x_Dept_Employee.EmployeeID
					and v_DE_ER.DeptCode = x_Dept_Employee.deptCode
					AND GETDATE() between ISNULL(v_DE_ER.validFrom,'1900-01-01') 
						and ISNULL(v_DE_ER.validTo,'2079-01-01')
				)
				+
				(SELECT COUNT(desr.DeptEmployeeServiceRemarkID)
				 FROM DeptEmployeeServiceRemarks desr
				 INNER JOIN x_Dept_Employee_Service xdes ON desr.x_dept_employee_serviceID = xdes.x_Dept_Employee_ServiceID
				 WHERE xdes.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
					AND GETDATE() between ISNULL(validFrom,'1900-01-01') 
						and ISNULL(validTo,'2079-01-01')
				)
				+
				(
				select COUNT(DERR.DeptEmployeeReceptionRemarkID)
				FROM DeptEmployeeReception DER
				join DeptEmployeeReceptionRemarks DERR on DER.receptionID = DERR.EmployeeReceptionID
				where DER.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
				AND GETDATE() between ISNULL(DER.ValidFrom,'1900-01-01') 
										and ISNULL(DER.ValidTo,'2079-01-01')
				), 0)
				
				WHEN 0 THEN 0 ELSE 1 END,
				
'professions' = stuff((select ','+ [Services].serviceDescription 
		FROM [Services]
		inner join x_Dept_Employee_Service xdes
		ON xdes.serviceCode = [Services].serviceCode
		and xdes.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
		WHERE xdes.Status = 1
		AND [Services].IsService = 0
		ORDER BY 
		CASE @IsOrderDescending
			WHEN 0 THEN [Services].serviceDescription 
			END,
		CASE WHEN @IsOrderDescending = 1 OR @IsOrderDescending IS NULL THEN [Services].serviceDescription 
			END DESC  
		for xml path('')
	),1,1,''),			
'services' = stuff((select ','+ [Services].serviceDescription 
		FROM [Services]
		inner join x_Dept_Employee_Service xdes
		ON xdes.serviceCode = [Services].serviceCode
		and xdes.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
		WHERE xdes.Status = 1
		AND [Services].IsService = 1
		ORDER BY 
		CASE @IsOrderDescending
			WHEN 0 THEN [Services].serviceDescription 
			END,
		CASE WHEN @IsOrderDescending = 1 OR @IsOrderDescending IS NULL THEN [Services].serviceDescription 
			END DESC  
		for xml path('')
	),1,1,''),	
'positions'	= stuff((SELECT ',' + position.positionDescription
		FROM position 
		INNER JOIN x_Dept_Employee_Position ON x_Dept_Employee_Position.positionCode = position.positionCode
		WHERE x_Dept_Employee_Position.DeptEmployeeID = x_dept_employee.DeptEmployeeID
		AND position.gender = employee.sex
		for xml path('')
	),1,1,''),	
'AgreementType' = IsNull(x_Dept_Employee.agreementType, 0),
'distance' = (xcoord - @CoordinateX)*(xcoord - @CoordinateX) + (ycoord - @CoordinateY)*(ycoord - @CoordinateY),

'hasMapCoordinates' = CASE IsNull((xcoord + ycoord),0) WHEN 0 THEN 0 ELSE 1 END,
'EmployeeStatus' = Employee.active,
'EmployeeStatusInDept' = IsNull(dbo.fun_GetDeptEmployeeCurrentStatus(x_dept_Employee.deptCode, x_dept_Employee.employeeID,x_dept_Employee.AgreementType), 0),
'orderLastNameLike' =
	CASE WHEN @LastName is NOT null AND Employee.LastName like @LastName + '%' THEN 0
		 WHEN @LastName is NOT null AND Employee.LastName like '%' + @LastName + '%' THEN 1 
		 ELSE 0 END,
IsMedicalTeam,
IsVirtualDoctor,
dbo.x_dept_XY.xcoord,
dbo.x_dept_XY.ycoord			 

FROM Employee
INNER JOIN DIC_EmployeeDegree ON Employee.degreeCode = DIC_EmployeeDegree.DegreeCode
LEFT JOIN x_Dept_Employee ON Employee.employeeID = x_Dept_Employee.employeeID
LEFT JOIN DIC_QueueOrder dic ON x_dept_employee.QueueOrder = dic.QueueOrder AND PermitOrderMethods = 0
LEFT JOIN dept ON x_Dept_Employee.deptCode = dept.deptCode
LEFT JOIN x_dept_XY ON dept.deptCode = x_dept_XY.deptCode
LEFT JOIN Cities ON dept.cityCode = Cities.cityCode
left join View_DeptEmployeesCurrentStatus as v_DECStatus 
	on x_Dept_Employee.deptCode = v_DECStatus.deptCode
	and Employee.employeeID = v_DECStatus.employeeID
	
WHERE
(@DistrictCodes is null 
	or dept.districtCode IN (SELECT IntField FROM dbo.SplitString(@DistrictCodes))
	or dept.DeptCode IN (SELECT x_Dept_District.DeptCode FROM dbo.SplitString(@DistrictCodes) as T
						 JOIN  x_Dept_District ON T.IntField = x_Dept_District.districtCode) 
)
and (@FirstName is null or Employee.FirstName like @FirstName +'%')
and (@LastName is null or Employee.LastName like '%'+ @LastName +'%')
and (@EmployeeID is null or Employee.EmployeeID = @EmployeeID)
and (@CityName is null OR @CoordinateX is NOT null or Cities.CityName like @CityName+'%')
and (@CityCode is null OR @CoordinateX is NOT null or Cities.CityCode = @CityCode)


AND (
		(
			@Active = 1 
			and	
			(	
				v_DECStatus.status IN (1,2) 			    
				or (v_DECStatus.status is null and Employee.active IN (1,2))
			)
		)
		or
		(
			@Active is null					    
			or v_DECStatus.status = @Active 
			or(v_DECStatus.status is null and Employee.active = @Active)
		)
	)
	
AND (@EmployeeSectorCode is null OR EmployeeSectorCode = @EmployeeSectorCode)
AND (@sex is null OR sex = @sex)
AND (@ExpProfession is null 
	OR
		(
			exists  (
							SELECT EmployeeID
							FROM EmployeeServices 
							WHERE ExpProfession = 1 
							and EmployeeServices.EmployeeID = Employee.employeeID
							)
			--Employee.employeeID IN  (
			--				SELECT DISTINCT EmployeeID
			--				FROM EmployeeServices 
			--				WHERE ExpProfession = 1 
			--				)
			AND @expProfession = 1
		)
	OR
		(
			Employee.employeeID NOT IN  (
								SELECT DISTINCT EmployeeID
								FROM EmployeeServices 
								WHERE ExpProfession = 1 
								)
			AND @expProfession = 0
		)										
	)
-- UnatedService concept changes: UnatedService = service + profession
AND
(--begin  UnatedService  
 	@serviceCode is null 
	OR 
	exists (SELECT employeeID 
	--x_Dept_Employee.employeeID IN (SELECT employeeID 
			FROM x_Dept_Employee_Service  xdes
			INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
			WHERE xd.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
			and x_Dept_Employee.employeeID = xd.employeeID
			AND serviceCode IN (SELECT IntField FROM dbo.SplitString(@serviceCode))
			AND xdes.status = 1
			AND (	@ExpProfession is null 
					OR @expProfession = 0
					OR
					(
						exists  (
										SELECT EmployeeID
										FROM EmployeeServices 
										WHERE ExpProfession = 1 
										and EmployeeServices.employeeID = xd.employeeID
										)
						--employeeID IN  (
						--				SELECT DISTINCT EmployeeID
						--				FROM EmployeeServices 
						--				WHERE ExpProfession = 1 
						--				)
						AND @expProfession = 1
					)
				)	
			)

	)

AND (@AgreementType is null OR x_Dept_Employee.AgreementType = @AgreementType)
AND ( (@isInCommunity is null AND @isInMushlam is null AND @isInHospitals is null)
	  OR
	  (Employee.IsInCommunity = @isInCommunity AND @isInCommunity IS NOT NULL AND (Dept.IsCommunity = @isInCommunity 
																					OR Dept.IsCommunity IS NULL))
	  OR
	  (Employee.IsInMushlam = @isInMushlam AND @isInMushlam IS NOT NULL AND (Dept.IsMushlam = @isInMushlam 
																					OR Dept.IsMushlam IS NULL))
	  OR
	  (Employee.isInHospitals = @isInHospitals AND @isInHospitals IS NOT NULL AND (Dept.isHospital = @isInHospitals 
																					OR Dept.isHospital IS NULL))
	)

AND (@LanguageCode is null 
	OR
		exists (SELECT EmployeeID 
										FROM EmployeeLanguages
										WHERE x_Dept_Employee.employeeID = EmployeeLanguages.EmployeeID
										and languageCode IN (SELECT IntField FROM dbo.SplitString(@LanguageCode))	
										)		
		--x_Dept_Employee.employeeID IN (SELECT EmployeeID 
		--								FROM EmployeeLanguages
		--								WHERE languageCode IN (SELECT IntField FROM dbo.SplitString(@LanguageCode))	
		--								)									
	)
AND (@deptHandicappedFacilities is null
	OR
	exists (SELECT employeeID FROM x_Dept_Employee as New
								WHERE x_Dept_Employee.employeeID = New.employeeID
								AND (SELECT COUNT(deptCode) FROM DeptHandicappedFacilities as T
										WHERE FacilityCode IN (SELECT IntField FROM dbo.SplitString(@deptHandicappedFacilities))
										AND T.deptCode = New.deptCode) = @HandicappedFacilitiesCount )
	--x_Dept_Employee.employeeID IN (SELECT employeeID FROM x_Dept_Employee as New
	--							WHERE (SELECT COUNT(deptCode) FROM DeptHandicappedFacilities as T
	--									WHERE FacilityCode IN (SELECT IntField FROM dbo.SplitString(@deptHandicappedFacilities))
	--									AND T.deptCode = New.deptCode) = @HandicappedFacilitiesCount )
	)
AND (@positionCode is null
	OR
	exists (SELECT xd.employeeID 
									FROM x_Dept_Employee_Position xdep
									INNER JOIN x_Dept_Employee xd ON xdep.DeptEmployeeID = xd.DeptEmployeeID
									WHERE x_Dept_Employee.employeeID = xd.employeeID
									AND xdep.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID									
									AND xdep.positionCode = @positionCode)
	--x_Dept_Employee.employeeID IN (SELECT xd.employeeID 
	--								FROM x_Dept_Employee_Position xdep
	--								INNER JOIN x_Dept_Employee xd ON xdep.DeptEmployeeID = xd.DeptEmployeeID
	--								WHERE xdep.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID									
	--								AND xdep.positionCode = @positionCode)
	)
AND (@ReceptionDays is null
	OR
	(exists (SELECT employeeID 
								FROM deptEmployeeReception as der
								INNER JOIN deptEmployeeReceptionServices ders ON der.receptionID = ders.receptionID
								INNER JOIN x_Dept_Employee xd ON der.DeptEmployeeID = xd.DeptEmployeeID
								WHERE x_Dept_Employee.employeeID = xd.employeeID
								AND receptionDay IN (SELECT IntField FROM dbo.SplitString(@ReceptionDays))
								AND xd.DeptCode = Dept.DeptCode
								AND
									(@ServiceCode is null OR ders.serviceCode IN (SELECT IntField FROM dbo.SplitString(@ServiceCode)) )
								)
		)
	--(x_Dept_Employee.employeeID IN (SELECT employeeID 
	--							FROM deptEmployeeReception as der
	--							INNER JOIN deptEmployeeReceptionServices ders ON der.receptionID = ders.receptionID
	--							INNER JOIN x_Dept_Employee xd ON der.DeptEmployeeID = xd.DeptEmployeeID
	--							WHERE receptionDay IN (SELECT IntField FROM dbo.SplitString(@ReceptionDays))
	--							AND xd.DeptCode = Dept.DeptCode
	--							AND
	--								(@ServiceCode is null OR ders.serviceCode IN (SELECT IntField FROM dbo.SplitString(@ServiceCode)) )
	--							)
	--	)
	)
AND	( (@OpenAtHour_Str is null AND @OpenFromHour_Str is null AND @OpenToHour_Str is null)
	OR exists 
								(SELECT employeeID 
								 FROM deptEmployeeReception as der
								 INNER JOIN deptEmployeeReceptionServices ders ON der.receptionID = ders.receptionID
								 INNER JOIN x_Dept_Employee xd ON der.DeptEmployeeID = xd.DeptEmployeeID
								 WHERE x_Dept_Employee.employeeID = xd.employeeID
								 AND xd.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID								 
								 AND	( der.openingHour < @OpenToHour_var AND der.closingHour > @OpenFromHour_var )
								 AND (@ReceptionDays is null
										OR
										der.receptionDay IN (SELECT IntField FROM dbo.SplitString(@ReceptionDays))
									)
								 AND
									( @OpenAtHour_Str is null 
										OR 
										( der.openingHour < @OpenAtHour_var AND der.closingHour > @OpenAtHour_var )
									)
								 AND
									( @ServiceCode is null OR ders.serviceCode IN (SELECT IntField FROM dbo.SplitString(@ServiceCode)) )
								 )
	--OR x_Dept_Employee.employeeID IN 
	--							(SELECT employeeID 
	--							 FROM deptEmployeeReception as der
	--							 INNER JOIN deptEmployeeReceptionServices ders ON der.receptionID = ders.receptionID
	--							 INNER JOIN x_Dept_Employee xd ON der.DeptEmployeeID = xd.DeptEmployeeID
	--							 WHERE xd.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID								 
	--							 AND	( der.openingHour < @OpenToHour_var AND der.closingHour > @OpenFromHour_var )
	--							 AND (@ReceptionDays is null
	--									OR
	--									der.receptionDay IN (SELECT IntField FROM dbo.SplitString(@ReceptionDays))
	--								)
	--							 AND
	--								( @OpenAtHour_Str is null 
	--									OR 
	--									( der.openingHour < @OpenAtHour_var AND der.closingHour > @OpenAtHour_var )
	--								)
	--							 AND
	--								( @ServiceCode is null OR ders.serviceCode IN (SELECT IntField FROM dbo.SplitString(@ServiceCode)) )
	--							 )
							) 
AND( @CoordinateX is null OR (xcoord is NOT null AND ycoord is NOT null))
AND( @licenseNumber is null OR Employee.licenseNumber = @licenseNumber)
AND(@userIsRegistered = 1 OR x_Dept_Employee.deptCode is NOT null)
AND(@userIsRegistered = 1 or dept.status = 1)
) as innerSelection
) as middleSelection


SELECT TOP (@PageSise) * INTO #tempTable FROM #tempTableAllRows
WHERE RowNumber > @StartingPosition
	AND RowNumber <= @StartingPosition + @PageSise
ORDER BY RowNumber


SELECT * FROM #tempTable


SELECT eqom.QueueOrderMethod, #tempTable.deptCode, #tempTable.employeeID , DIC_ReceptionDays.receptionDayName, eqoh.FromHour, eqoh.ToHour
FROM EmployeeQueueOrderMethod eqom
INNER JOIN #tempTable ON eqom.DeptEmployeeID = #tempTable.DeptEmployeeID 
LEFT JOIN EmployeeQueueOrderHours eqoh ON eqom.QueueOrderMethodID = eqoh.QueueOrderMethodID
LEFT JOIN DIC_ReceptionDays ON eqoh.receptionDay = DIC_ReceptionDays.ReceptionDayCode


SELECT #tempTable.deptCode, #tempTable.employeeID,  
	dbo.fun_ParsePhoneNumberWithExtension(DeptPhones.prePrefix, DeptPhones.prefix, DeptPhones.phone, DeptPhones.extension) as Phone
FROM #tempTable  
INNER JOIN EmployeeQueueOrderMethod eqom ON #tempTable.DeptEmployeeID = eqom.DeptEmployeeID
INNER JOIN DIC_QueueOrderMethod ON eqom.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
INNER JOIN DeptPhones ON #tempTable.deptCode = DeptPhones.deptCode
WHERE phoneType = 1 AND phoneOrder = 1 AND SpecialPhoneNumberRequired = 0 AND ShowPhonePicture = 1


SELECT #tempTable.deptCode, #tempTable.employeeID, 
dbo.fun_ParsePhoneNumberWithExtension(eqop.prePrefix, eqop.prefix, eqop.phone, eqop.extension) as Phone
FROM #tempTable  
INNER JOIN EmployeeQueueOrderMethod eqom ON #tempTable.DeptEmployeeID = eqom.DeptEmployeeID
INNER JOIN DeptEmployeeQueueOrderPhones eqop ON eqom.QueueOrderMethodID = eqop.QueueOrderMethodID


DROP TABLE #tempTable

		
-- select with same joins and conditions as above
-- just to get count of all the records in select
SET @Count =	
		(SELECT COUNT(*)
		FROM #tempTableAllRows)



IF(@NumberOfRecordsToShow is NOT null)
BEGIN
	IF(@Count > @NumberOfRecordsToShow)
	BEGIN
		SET @Count = @NumberOfRecordsToShow
	END
END
	
SELECT @Count

if ( @isGetEmployeesReceptionHours = 1 )
begin
	SELECT v.[deptCode]
		  ,v.[receptionID]
		  ,v.[EmployeeID]
		  ,v.[receptionDay]
		  ,v.[openingHour]
		  ,v.[closingHour]
		  ,v.[ReceptionDayName]
		  ,v.[OpeningHourText]
		  ,v.[EmployeeSectorCode]
		  ,v.[ServiceDescription]
		  ,DERR.RemarkText
	  FROM [dbo].[vEmployeeReceptionHours] v
	  left join deptEmployeeReception dER on v.receptionID = dER.receptionID
	  left join DeptEmployeeReceptionRemarks DERR on dER.receptionID = DERR.EmployeeReceptionID
	  inner join #tempTableAllRows tbl
	  on tbl.deptCode = v.deptCode
	  and tbl.EmployeeID = v.EmployeeID
	  order by v.[EmployeeID],v.[deptCode],v.[ServiceDescription]


	--Remarks
	SELECT distinct
		v_DE_ER.EmployeeID,
		v_DE_ER.DeptCode,
		dbo.rfn_GetFotmatedRemark(v_DE_ER.RemarkTextFormated) as RemarkText,
		CONVERT(VARCHAR(2),DAY(v_DE_ER.ValidTo)) + '/' + CONVERT(VARCHAR(2),MONTH(v_DE_ER.ValidTo)) + '/' + CONVERT(VARCHAR(4),YEAR(v_DE_ER.ValidTo)) as ValidTo
	from View_DeptEmployee_EmployeeRemarks v_DE_ER
		inner join #tempTableAllRows tbl
		on tbl.deptCode = v_DE_ER.deptCode
		and tbl.EmployeeID = v_DE_ER.EmployeeID
		where GETDATE() between ISNULL(v_DE_ER.validFrom,'1900-01-01') 
						and ISNULL(v_DE_ER.validTo,'2079-01-01')

	UNION

	SELECT
	xde.EmployeeID,
	xde.DeptCode,
	dbo.rfn_GetFotmatedRemark(desr.RemarkText),
	CONVERT(VARCHAR(2),DAY(desr.ValidTo)) + '/' + CONVERT(VARCHAR(2),MONTH(desr.ValidTo)) + '/' + CONVERT(VARCHAR(4),YEAR(desr.ValidTo))
	FROM DeptEmployeeServiceRemarks desr
	INNER JOIN x_dept_employee_service xdes ON desr.x_dept_employee_serviceID = xdes.x_Dept_Employee_ServiceID AND xdes.Status = 1
	inner join x_dept_employee xde on xdes.DeptEmployeeID = xde.DeptEmployeeID
	inner join #tempTableAllRows tbl on tbl.deptCode = xde.deptCode
	and tbl.EmployeeID = xde.EmployeeID
	where GETDATE() between ISNULL(desr.validFrom,'1900-01-01') 
						and ISNULL(desr.validTo,'2079-01-01')

	DROP TABLE #tempTableAllRows
end
GO

GRANT EXEC ON rpc_getDoctorList_PagedSorted TO PUBLIC

GO

--**** Yaniv - End rpc_getDoctorList_PagedSorted ----------- 


-- **********************************************************************************************************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_GetDeptEmployeeServiceFaxes')
	BEGIN
		DROP  function  fun_GetDeptEmployeeServiceFaxes
	END
GO

CREATE FUNCTION [dbo].[fun_GetDeptEmployeeServiceFaxes]
(
	@DeptEmployeeID int,
	@ServiceCode int
)
RETURNS varchar(500)
AS
BEGIN
 
    DECLARE @p_str VARCHAR(500)
    SET @p_str = ''
    
	-- employee service phones
    SELECT @p_str = @p_str + dbo.fun_ParsePhoneNumberWithExtension(esp.prePrefix, esp.prefix, esp.phone, esp.extension ) + ','
	FROM x_Dept_Employee_Service xdes 
	INNER JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID  
	INNER JOIN EmployeeServicePhones esp on xdes.x_Dept_Employee_ServiceID = esp.x_Dept_Employee_ServiceID
	WHERE xdes.DeptEmployeeID = @DeptEmployeeID
	AND xdes.ServiceCode = @serviceCode
	AND esp.PhoneType = 2



	-- employee dept phones
	IF (@p_str = '')
	BEGIN
		SELECT @p_str = @p_str + CASE WHEN dep.phone is not null THEN
										dbo.fun_ParsePhoneNumberWithExtension(dep.prePrefix, dep.prefix, dep.phone, dep.extension )
									  END + ','				
		FROM DeptEmployeePhones dep 
		INNER JOIN x_dept_employee xd ON dep.DeptEmployeeID = xd.DeptEmployeeID
		WHERE xd.DeptEmployeeID = @DeptEmployeeID
		AND dep.PhoneType = 2
	END


	-- dept phones
	IF (@p_str = '')
	BEGIN
		SELECT @p_str = @p_str + dbo.fun_ParsePhoneNumberWithExtension(dp.prePrefix, dp.prefix, dp.phone, dp.extension ) + ','				
		FROM x_dept_employee xd
		INNER JOIN DeptPhones dp ON xd.deptCode = dp.deptCode AND xd.CascadeUpdateDeptEmployeePhonesFromClinic = 1	
		WHERE xd.DeptEmployeeID = @DeptEmployeeID
		AND dp.PhoneType = 2
	END


	IF len(@p_str) > 1
	-- remove last comma
	BEGIN
		SET @p_str = SUBSTRING(@p_str, 0, len(@p_str))
	END
	
    RETURN @p_str

END

GO

grant exec on fun_GetDeptEmployeeServiceFaxes to public 
GO    



-- **********************************************************************************************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_GetDeptEmployeeServicePhones')
	BEGIN
		DROP  function  fun_GetDeptEmployeeServicePhones
	END
GO

CREATE FUNCTION [dbo].[fun_GetDeptEmployeeServicePhones]
(
	@DeptEmployeeID int,
	@ServiceCode int
)
RETURNS varchar(500)
AS
BEGIN
 
    DECLARE @p_str VARCHAR(500)
    SET @p_str = ''
    
	-- employee service phones
    SELECT @p_str = @p_str + dbo.fun_ParsePhoneNumberWithExtension(esp.prePrefix, esp.prefix, esp.phone, esp.extension ) + ','
	FROM x_Dept_Employee_Service xdes 
	INNER JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID  
	INNER JOIN EmployeeServicePhones esp on xdes.x_Dept_Employee_ServiceID = esp.x_Dept_Employee_ServiceID
	WHERE xdes.DeptEmployeeID = @DeptEmployeeID
	AND xdes.ServiceCode = @serviceCode
	AND esp.PhoneType = 1


	-- employee dept phones
	IF (@p_str = '')
	BEGIN
		SELECT @p_str = @p_str + CASE WHEN dep.phone is not null THEN
										dbo.fun_ParsePhoneNumberWithExtension(dep.prePrefix, dep.prefix, dep.phone, dep.extension )
									  END + ','				
		FROM DeptEmployeePhones dep 
		INNER JOIN x_dept_employee xd ON dep.DeptEmployeeID = xd.DeptEmployeeID
		WHERE xd.DeptEmployeeID = @DeptEmployeeID
		AND dep.PhoneType = 1
	END


	-- dept phones
	IF (@p_str = '')
	BEGIN
		SELECT @p_str = @p_str + dbo.fun_ParsePhoneNumberWithExtension(dp.prePrefix, dp.prefix, dp.phone, dp.extension ) + ','				
		FROM x_dept_employee xd
		INNER JOIN DeptPhones dp ON xd.deptCode = dp.deptCode AND xd.CascadeUpdateDeptEmployeePhonesFromClinic = 1	
		WHERE xd.DeptEmployeeID = @DeptEmployeeID
		AND dp.PhoneType = 1
	END


	IF len(@p_str) > 1
	-- remove last comma
	BEGIN
		SET @p_str = SUBSTRING(@p_str, 0, len(@p_str))
	END
	
    RETURN @p_str

END

GO

grant exec on fun_GetDeptEmployeeServicePhones to public 
GO    

-- **********************************************************************************************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_GetDeptEmployeeServiceQueueOrderDescription')
	BEGIN
		DROP  function  fun_GetDeptEmployeeServiceQueueOrderDescription
	END
GO

CREATE FUNCTION [dbo].[fun_GetDeptEmployeeServiceQueueOrderDescription]
(
	@deptEmployeeID int,
	@serviceCode int
)
RETURNS varchar(100)
AS
BEGIN
 
    DECLARE @p_str VARCHAR(100)
    SET @p_str = ''

	SELECT @p_str = IsNull(dic.QueueOrderDescription,'')
					FROM x_dept_employee_service xdes
					LEFT JOIN DIC_QueueOrder dic ON xdes.QueueOrder = dic.QueueOrder
					WHERE xdes.DeptEmployeeID = @deptEmployeeID
					AND xdes.ServiceCode = @serviceCode
					AND PermitOrderMethods = 0

	IF @p_str = ''
		SELECT @p_str = IsNull(dic.QueueOrderDescription,'')
					FROM x_dept_employee xd
					LEFT JOIN DIC_QueueOrder dic ON xd.QueueOrder = dic.QueueOrder
					WHERE xd.DeptEmployeeID = @deptEmployeeID					
					AND PermitOrderMethods = 0


    RETURN @p_str

END
GO

grant exec on fun_GetDeptEmployeeServiceQueueOrderDescription to public 
GO    
 
-- **********************************************************************************************************************
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'fun_GetEmployeeServiceQueueOrderMethod')
	BEGIN
		DROP  FUNCTION  fun_GetEmployeeServiceQueueOrderMethod
	END
GO

CREATE FUNCTION [dbo].[fun_GetEmployeeServiceQueueOrderMethod] (@DeptEmployeeID int, @ServiceCode int)
RETURNS VARCHAR(100)
WITH EXECUTE AS CALLER
AS
BEGIN

DECLARE @queueMethod VARCHAR(100)

SET @queueMethod = ''

SELECT @queueMethod =   @queueMethod + CONVERT(VARCHAR,esqom.QueueOrderMethod) + ',' 
						FROM x_dept_employee_service xdes
						INNER JOIN EmployeeServiceQueueOrderMethod esqom ON xdes.x_dept_employee_ServiceID = esqom.x_dept_employee_ServiceID
						LEFT JOIN EmployeeQueueOrderMethod eqom ON xdes.DeptEmployeeID = eqom.DeptEmployeeID
						LEFT JOIN DeptEmployeeQueueOrderPhones eqop ON eqom.QueueOrderMethodID = eqop.QueueOrderMethodID

						WHERE xdes.DeptEmployeeID = @DeptEmployeeID
						AND xdes.serviceCode = @ServiceCode
						ORDER BY esqom.QueueOrderMethod

IF LEN(@queueMethod) > 1
-- remove last comma
BEGIN
	SET @queueMethod = SUBSTRING(@queueMethod, 0, len(@queueMethod))
END
		

RETURN @queueMethod


END

GO

grant exec on fun_GetEmployeeServiceQueueOrderMethod to public 
go 


-- **********************************************************************************************************************
------- Reports - by Maria
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_HelperLongPrint]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].rpc_HelperLongPrint
GO

CREATE PROCEDURE dbo.rpc_HelperLongPrint( @string nvarchar(max) )
AS
SET NOCOUNT ON
	set @string = rtrim( @string )
	declare @cr char(1), @lf char(1)
	set @cr = char(13)
	set @lf = char(10)

	declare @len int, @cr_index int, @lf_index int, @crlf_index int, @has_cr_and_lf bit, @left nvarchar(4000), @reverse nvarchar(4000)

	set @len = 4000

	while ( len( @string ) > @len )
	begin

	set @left = left( @string, @len )
	set @reverse = reverse( @left )
	set @cr_index = @len - charindex( @cr, @reverse ) + 1
	set @lf_index = @len - charindex( @lf, @reverse ) + 1
	set @crlf_index = case when @cr_index < @lf_index then @cr_index else @lf_index end

	set @has_cr_and_lf = case when @cr_index < @len and @lf_index < @len then 1 else 0 end

	print left( @string, @crlf_index - 1 )

	set @string = right( @string, len( @string ) - @crlf_index - @has_cr_and_lf )

	end

	print @string

go

GRANT EXEC ON rpc_HelperLongPrint TO PUBLIC
go
---------------

 
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'TF' AND name = 'rfn_GetDeptEmployeeQueueOrderDetails')
	BEGIN
		DROP  FUNCTION  dbo.rfn_GetDeptEmployeeQueueOrderDetails
	END

GO

create function dbo.rfn_GetDeptEmployeeQueueOrderDetails
 (
	@deptCode INT,
	@employeeCode INT
 ) 

RETURNS @ResultTable table
(
QueueOrderDescription		varchar(50),
QueueOrderClinicTelephone	varchar(100),
QueueOrderSpecialTelephone	varchar(100),
QueueOrderTelephone2700		varchar(5),
QueueOrderInternet			varchar(5)
)
as

begin

declare @specPhones varchar(200)
set @specPhones = ''


insert into @ResultTable

SELECT dic.QueueOrderDescription as EmpQueueOrderDescription,
case when OrderMethod1.QueueOrderMethod is not null  
	then(	SELECT TOP 1 dbo.fun_ParsePhoneNumberWithExtension(DeptPhones.preprefix,DeptPhones.prefix,DeptPhones.phone,DeptPhones.extension) 
			FROM DeptPhones 
			WHERE DeptCode = @deptCode 
			AND DeptPhones.PhoneType = 1 
			ORDER BY PhoneOrder)
	else '' END AS QueueOrderClinicTelephone,

case when OrderMethod2.QueueOrderMethod is not null 
	then dbo.rfn_GetDeptEmployeeQueueOrderSpecialPhones(OrderMethod2.QueueOrderMethodID)
	else '' end as QueueOrderSpecialTelephone,

case when de.QueueOrder <> 3 then ''
	 when de.QueueOrder = 3 and OrderMethod3.QueueOrderMethod is not null then 'כן' 
	 when de.QueueOrder = 3 and OrderMethod3.QueueOrderMethod is null then 'לא'
	end as QueueOrderTelephone2700, 
case when de.QueueOrder <> 3 then ''
	 when de.QueueOrder = 3 and OrderMethod4.QueueOrderMethod is not null then 'כן' 
	 when de.QueueOrder = 3 and OrderMethod4.QueueOrderMethod is null then 'לא'
	 end as QueueOrderInternet 

FROM x_Dept_Employee as de  
join x_Dept_Employee on  x_Dept_Employee.DeptEmployeeID = de.DeptEmployeeID 
	and de.deptCode = @deptCode
	and de.employeeID = @employeeCode
left JOIN DIC_QueueOrder as dic ON de.QueueOrder = dic.QueueOrder

left join EmployeeQueueOrderMethod as OrderMethod1 on de.DeptEmployeeID = OrderMethod1.DeptEmployeeID	
	and OrderMethod1.QueueOrderMethod = 1 
left join EmployeeQueueOrderMethod as OrderMethod2 on de.DeptEmployeeID = OrderMethod2.DeptEmployeeID	
	and OrderMethod2.QueueOrderMethod = 2

left join EmployeeQueueOrderMethod as OrderMethod3 on de.DeptEmployeeID = OrderMethod3.DeptEmployeeID
	and OrderMethod3.QueueOrderMethod = 3 
left join EmployeeQueueOrderMethod as OrderMethod4 on de.DeptEmployeeID = OrderMethod4.DeptEmployeeID
	and OrderMethod4.QueueOrderMethod = 4 

return
end

go

----------------

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'IF' AND name = 'rfn_GetReportServiceDetailsForDeptsByServicesTypes')
	BEGIN
		DROP  FUNCTION  dbo.rfn_GetReportServiceDetailsForDeptsByServicesTypes
	END

GO


create  function dbo.rfn_GetReportServiceDetailsForDeptsByServicesTypes
 (
	@DeptCode int
 ) 
RETURNS TABLE

as

return 	
(

--=======
-- doctors services details 
--=======
-------------Services of Doctors in Clinic --------------------------------------
SELECT
x_D_E_S.serviceCode,
x_dept_employee.deptCode,
Services.serviceDescription,
'phones' = '',

QueueOrderDetails.QueueOrderDescription as QueueOrderDescription, 
QueueOrderDetails.QueueOrderClinicTelephone as QueueOrderClinicTelephone, 
QueueOrderDetails.QueueOrderSpecialTelephone as QueueOrderSpecialTelephone ,
QueueOrderDetails.QueueOrderTelephone2700 as QueueOrderTelephone2700 ,
QueueOrderDetails.QueueOrderInternet as QueueOrderInternet ,
	
'serviceIsGivenByPerson' = x_dept_employee.employeeID,
'PersonsName' = DegreeName + ' ' + lastName + ' ' + firstName,
Services.showOrder,
viaPerson = 1,
'employeeID' = x_dept_employee.employeeID ,
replace(dbo.fun_getRemarkByServiceByEmployee(x_dept_employee.deptCode,x_dept_employee.employeeID , x_D_E_S.serviceCode), '&quot;', char(34))
 as remark

FROM x_dept_employee
INNER JOIN Employee ON x_dept_employee.employeeID = Employee.employeeID and x_dept_employee.deptCode = @DeptCode
INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode
INNER JOIN x_Dept_Employee_Service as x_D_E_S 
	ON x_dept_employee.DeptEmployeeID = x_D_E_S.DeptEmployeeID
INNER JOIN Services	
	ON x_D_E_S.serviceCode = Services.serviceCode
	and Services.IsService = 1 
cross apply rfn_GetDeptEmployeeQueueOrderDetails(x_dept_employee.deptCode, x_dept_employee.employeeID) as QueueOrderDetails

) 

/*GO
grant exec on dbo.rfn_GetReportServiceDetailsForDeptsByServicesTypes to public 
*/
go


------------
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_getRemarkByServiceByEmployee')
	BEGIN
		DROP  FUNCTION  fun_getRemarkByServiceByEmployee
	END

GO

create  function [dbo].[fun_getRemarkByServiceByEmployee]
 (
	@DeptCode int , 
	@EmployeeID	int,
	@serviceCode int
 ) 
RETURNS varchar(500)
WITH EXECUTE AS CALLER

AS
BEGIN

declare @RemarkStr varchar(5000) 
	set @RemarkStr = ''
--=======
-- doctors services details 
--=======
SELECT @RemarkStr = @RemarkStr + RemarkText + ' ; ' FROM
(
	SELECT  
		REPLACE(desr.RemarkText,'#','') as RemarkText 

		FROM x_Dept_Employee_Service as xdes
		INNER JOIN x_dept_employee xde
			ON xdes.DeptEmployeeID = xde.DeptEmployeeID
		INNER JOIN EmployeeServices ON xde.employeeID = EmployeeServices.employeeID
										AND xdes.serviceCode = EmployeeServices.serviceCode	
		INNER JOIN service ON xdes.serviceCode = service.serviceCode
		LEFT JOIN serviceParentChild ON service.serviceCode = serviceParentChild.childCode
		LEFT JOIN DeptEmployeeServiceRemarks desr ON xdes.DeptEmployeeServiceRemarkID = desr.DeptEmployeeServiceRemarkID

	WHERE xde.deptCode = @DeptCode and 
			xde.employeeID = @EmployeeID and 
			xdes.serviceCode = @serviceCode

	UNION

	SELECT 

	REPLACE(desr.RemarkText,'3','') as RemarkText 

	FROM x_Dept_Employee_Service as xdes
	INNER JOIN x_dept_employee xde
				ON xdes.DeptEmployeeID = xde.DeptEmployeeID
	INNER JOIN EmployeeServices ON xde.employeeID = EmployeeServices.employeeID
									AND xdes.serviceCode = EmployeeServices.serviceCode	
	INNER JOIN service ON xdes.serviceCode = service.serviceCode
	LEFT JOIN serviceParentChild ON service.serviceCode = serviceParentChild.childCode
	INNER JOIN service as S ON serviceParentChild.parentCode = s.serviceCode
	LEFT JOIN DeptEmployeeServiceRemarks desr ON xdes.DeptEmployeeServiceRemarkID = desr.DeptEmployeeServiceRemarkID

	WHERE xde.deptCode =  @DeptCode and 
			xde.employeeID = @EmployeeID and 
			xdes.serviceCode = @serviceCode

) as d 

return (@RemarkStr);
	
end 

go

------------
IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rfn_GetDeptServicesReception')
	BEGIN
		DROP  function  dbo.rfn_GetDeptServicesReception
	END

GO

create function dbo.rfn_GetDeptServicesReception
 (
	@DeptCode int,
	@ValidFrom_str varchar(15),
	@ValidTo_str varchar(15),
	@ObjectType_cond varchar(10),
	@ServiceGivenBy_cond varchar(10)
 ) 
RETURNS 
@ResultTable table
(
--  ObjectType = 3 - service is clinic office; ObjectType = 2 - regular service (is not office); ObjectType = 1 - clinic 
	ObjectType varchar(10), 
	deptCode int,
	serviceCode int,
	serviceDescription varchar(100),
	serviceGivenByPersonCode int,
	serviceGivenByPerson varchar(50),
	receptionID int,
	receptionDay int,
	ReceptionDayName varchar(50),
	openingHour varchar(5),
	closingHour	varchar(5),
	totalHours	float,
	validFrom smalldateTime,
	validTo smalldateTime,
	remarkText varchar(500)
)
as

begin

----------parameters casting------------------------
declare @ValidFrom smallDateTime
declare @ValidTo smallDateTime

if (isdate(@ValidTo_str)= 0 )
	set @ValidTo = null
else
	set @ValidTo = convert(smallDateTime, @ValidTo_str, 103 )

if (isdate(@ValidFrom_str) = 0)
	set @ValidFrom = convert(smallDateTime, '1900-01-01', 103 )
else
	set @ValidFrom = convert(smallDateTime, @ValidFrom_str, 103 )



-------------Services of Doctors in Clinic --------------------------------------
if (@ServiceGivenBy_cond ='-1' or 
	'1' IN (SELECT IntField FROM dbo.SplitString( @ServiceGivenBy_cond )))--@ServiceGivenBy_cond
begin

insert into @ResultTable
SELECT

--  ObjectType = 3 - service is clinic office; ObjectType = 2 - regular service (is not office); ObjectType = 1 - clinic 
ObjectType = 2, 
x_dept_employee.deptCode,
RecServ.serviceCode,
Services.serviceDescription,
'serviceGivenByPersonCode' = x_dept_employee.employeeID,
'serviceGivenByPerson' = DegreeName + ' ' + lastName + ' ' + firstName,
recep.receptionID,
recep.receptionDay,
DIC_ReceptionDays.ReceptionDayName,
recep.openingHour,
recep.closingHour,
'totalHours' =  [dbo].rfn_TimeInterval_float(recep.openingHour, recep.closingHour),
recep.validFrom,
recep.validTo,
RecRemarks.remarkText

FROM x_dept_employee

inner join [dbo].DeptEmployeeReception as Recep  
	on x_dept_employee.deptCode = @DeptCode
	and	x_dept_employee.DeptEmployeeID = recep.DeptEmployeeID 

inner join dbo.deptEmployeeReceptionServices as RecServ on recep.receptionID = RecServ.receptionID  

INNER JOIN Services	ON RecServ.serviceCode = Services.serviceCode and 
	(@ObjectType_cond = '-1' or
	2 IN (SELECT IntField FROM dbo.SplitString( @ObjectType_cond )))-- @ObjectType_cond
	
INNER JOIN Employee ON x_dept_employee.employeeID = Employee.employeeID
INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode

left JOIN DIC_ReceptionDays on recep.receptionDay = DIC_ReceptionDays.ReceptionDayCode
left join DeptEmployeeReceptionRemarks as RecRemarks on Recep.receptionID = RecRemarks.DeptEmployeeReceptionRemarkID

WHERE 	[x_dept_employee].deptCode = @DeptCode
		and(@ValidTo is null and recep.validTo is null
		
		or	@ValidTo is not null and recep.validTo is not null
			and @ValidFrom <= recep.validTo and	 recep.validFrom <=  @ValidTo 
		
		or  @ValidTo is not null and recep.validTo is null
			and  recep.validFrom <=  @ValidTo
		
		or	@ValidTo is null and recep.validTo is not null
			and @ValidFrom <= recep.validTo
		)
	
end

return
end
go 
grant select on rfn_GetDeptServicesReception to public 
go

------------
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_getRemarkByServiceByEmployee')
	BEGIN
		DROP  FUNCTION  fun_getRemarkByServiceByEmployee
	END

GO

create  function [dbo].[fun_getRemarkByServiceByEmployee]
 (
	@DeptCode int , 
	@EmployeeID	int,
	@serviceCode int
 ) 
RETURNS varchar(500)
WITH EXECUTE AS CALLER

AS
BEGIN

declare @RemarkStr varchar(5000) 
	set @RemarkStr = ''
--=======
-- doctors services details 
--=======
SELECT @RemarkStr = @RemarkStr + RemarkText + ' ; ' FROM
(
	SELECT  
		REPLACE(desr.RemarkText,'#','') as RemarkText 

		FROM x_Dept_Employee_Service as xdes
		INNER JOIN x_dept_employee xde
			ON xdes.DeptEmployeeID = xde.DeptEmployeeID
		INNER JOIN EmployeeServices ON xde.employeeID = EmployeeServices.employeeID
										AND xdes.serviceCode = EmployeeServices.serviceCode	
		INNER JOIN Services ON xdes.serviceCode = Services.serviceCode
		LEFT JOIN serviceParentChild ON Services.serviceCode = serviceParentChild.childCode
		LEFT JOIN DeptEmployeeServiceRemarks desr ON xdes.DeptEmployeeServiceRemarkID = desr.DeptEmployeeServiceRemarkID

	WHERE xde.deptCode = @DeptCode and 
			xde.employeeID = @EmployeeID and 
			xdes.serviceCode = @serviceCode

	UNION

	SELECT 

	REPLACE(desr.RemarkText,'3','') as RemarkText 

	FROM x_Dept_Employee_Service as xdes
	INNER JOIN x_dept_employee xde
				ON xdes.DeptEmployeeID = xde.DeptEmployeeID
	INNER JOIN EmployeeServices ON xde.employeeID = EmployeeServices.employeeID
									AND xdes.serviceCode = EmployeeServices.serviceCode	
	INNER JOIN Services ON xdes.serviceCode = Services.serviceCode
	LEFT JOIN serviceParentChild ON Services.serviceCode = serviceParentChild.childCode
	INNER JOIN Services as S ON serviceParentChild.parentCode = s.serviceCode
	LEFT JOIN DeptEmployeeServiceRemarks desr ON xdes.DeptEmployeeServiceRemarkID = desr.DeptEmployeeServiceRemarkID

	WHERE xde.deptCode =  @DeptCode and 
			xde.employeeID = @EmployeeID and 
			xdes.serviceCode = @serviceCode

) as d 

return (@RemarkStr);
	
end 

go

------------
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'rfn_GetDeptEmployeeProfessionCodes')
	BEGIN
		DROP  function  rfn_GetDeptEmployeeProfessionCodes
	END

GO
--case @deptCode = -1  -- means all depts
--case @employeeID = -1  -- means all employees
CREATE function [dbo].rfn_GetDeptEmployeeProfessionCodes(@deptCode bigint, @employeeID bigint) 
RETURNS varchar(500)
WITH EXECUTE AS CALLER

AS
BEGIN

	declare @ProfessionsStr varchar(500) 
	set @ProfessionsStr = ''
	
SELECT @ProfessionsStr = @ProfessionsStr + convert(varchar(50), d.ServiceCode) + '; ' 
FROM
	(select distinct Services.ServiceDescription, Services.ServiceCode
	from x_Dept_Employee_Service as xDEP
	inner join x_Dept_Employee as xde
		on xDEP.DeptEmployeeID = xde.DeptEmployeeID
	inner join Services on xDEP.ServiceCode = Services.ServiceCode
		and (@deptCode = -1 or xde.deptCode = @deptCode)
		and (@employeeID = -1 or xde.employeeID = @employeeID)
		and Services.IsProfession = 1
	)
	as d
order by  d.ServiceDescription

IF(LEN(@ProfessionsStr)) > 0 -- to remove last ','
		BEGIN
			SET @ProfessionsStr = Left( @ProfessionsStr, LEN(@ProfessionsStr) -1 )
		END

return (@ProfessionsStr);
end 
go 

grant exec on dbo.rfn_GetDeptEmployeeProfessionCodes to public 
go  

-------------
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_DeptsByServicesTypes')
	BEGIN
		DROP  Procedure  rprt_DeptsByServicesTypes
	END

GO

CREATE Procedure dbo.rprt_DeptsByServicesTypes
(
	 @ProfessionCodes varchar(max)=null,
	 @DistrictCodes varchar(max)=null,
	 @AdminClinicCode varchar(max)=null,
	 @CitiesCodes varchar(max)=null,
	 @StatusCodes varchar(max)=null, 
	 @UnitTypeCodes varchar(max)=null,
	 @SubUnitTypeCodes varchar(max)=null,
	 @SectorCodes varchar(max)=null,
	 @ServiceCodes varchar(max)=null,  
	 @ServiceGivenBy_cond varchar(max)=null, 
	 @Membership_cond varchar(max)=null, 
	 
	
	@district varchar (2)= null,	
	@adminClinic varchar (2) = null ,	
	@subAdminClinic varchar (2)=null, 
	@unitType varchar (2)=null,		
	@subUnitType varchar (2)=null,	
	@simul varchar (2)=null,	
	@city varchar (2)=null,	
	@address varchar (2)=null,	
	@Phone1 varchar (2)=null,
	@Phone2 varchar (2)=null,
	@Fax varchar (2)=null,
	@Email varchar (2)=null,
	--@SectorCode varchar (2)=null,	 
	@deptLevelDesc varchar (2)=null,
	@MangerName varchar (2)=null,
	@AdminMangerName varchar (2)=null,
	@serviceDescription varchar (2)=null,
	@serviceIsGivenByPersons varchar (2)=null,
	@QueueOrderDescription varchar (2)=null,
	--@phonesForQueueOrder varchar (2)=null,
	@remark varchar (2)=null,
	@professions varchar (2)=null,
	@ClinicName varchar (2)=null,	
	@ClinicCode varchar (2)=null,	
	@sector varchar (2)=null,
	@Membership  varchar (2)=null,
	@DeptCoordinates varchar (2)=null,
	@IsExcelVersion varchar (2)= null,
	
	@ErrCode VARCHAR(max) OUTPUT
-----------------------------------------
)with recompile

AS
--------------------------------------

DECLARE @NewLineChar AS CHAR(2) 
set @NewLineChar = CHAR(13) + CHAR(10)

declare  @sql nvarchar(max)-- nvarchar type supports hebrew lenguage
declare  @sqlEnd nvarchar(max)
declare  @sqlFrom varchar(max)

set @sql = 'SELECT distinct *  from
			(select ' + @NewLineChar;
set @sqlEnd = ') as resultTable' + @NewLineChar;

set @sqlFrom = 
'from dept  as d    
join dept as d2 on d.deptCode = d2.deptCode	
	AND (''' + @Membership_cond + ''' = ''-1'' 
		or d.IsCommunity = 1 and 1 in (SELECT IntField FROM dbo.SplitString( ''' + @Membership_cond + '''))
		or d.IsMushlam = 1 and 2 in (SELECT IntField FROM dbo.SplitString( ''' + @Membership_cond + '''))
		or d.IsHospital = 1 and 3 in (SELECT IntField FROM dbo.SplitString( ''' + @Membership_cond  + '''))
		)
	AND (''' + @AdminClinicCode + ''' = ''-1'' or d.administrationCode  in (SELECT IntField FROM dbo.SplitString( ''' + @AdminClinicCode + ''')))
	AND (''' + @DistrictCodes + ''' = ''-1'' or  d.districtCode IN (SELECT IntField FROM dbo.SplitString( ''' + @DistrictCodes + ''')) or d.DeptCode IN (SELECT x_Dept_District.DeptCode FROM dbo.SplitString(''' + @DistrictCodes + ''') as T JOIN  x_Dept_District ON T.IntField = x_Dept_District.districtCode) )
	AND (''' + @UnitTypeCodes + ''' = ''-1'' or d.typeUnitCode  in (SELECT IntField FROM dbo.SplitString( ''' + @UnitTypeCodes + ''')) )
	AND (''' + @SubUnitTypeCodes + ''' = ''-1'' or d.subUnitTypeCode in (SELECT IntField FROM dbo.SplitString( ''' + @SubUnitTypeCodes + ''')) )
	AND (''' + @SectorCodes + ''' = ''-1'' or d.populationSectorCode IN (SELECT IntField FROM dbo.SplitString( ''' + @SectorCodes + ''')) )
	
 left join dept as dAdmin on d.administrationCode = dAdmin.deptCode   
 left join dept as dDistrict on d.districtCode = dDistrict.deptCode    
 left join dept as dSubAdmin on d.subAdministrationCode = dSubAdmin.deptCode 
 left join View_UnitType as UnitType on d.typeUnitCode =  UnitType.UnitTypeCode  
 left join View_SubUnitTypes as SubUnitType on d.subUnitTypeCode =  SubUnitType.subUnitTypeCode and  d.typeUnitCode =  SubUnitType.UnitTypeCode  
 left join PopulationSectors as ps on d.populationSectorCode = ps.PopulationSectorID  
 left join deptSimul on d.DeptCode = deptSimul.DeptCode 
 left join Cities on d.CityCode =  Cities.CityCode  
 
 left join DeptStatus on d.DeptCode = DeptStatus.DeptCode 
 join dept as d3 on d.deptCode = d3.deptCode
	AND (''' + @StatusCodes + ''' = ''-1'' or DeptStatus.Status IN (SELECT IntField FROM dbo.SplitString( ''' + @StatusCodes + ''')) )
	AND (''' + @CitiesCodes + ''' = ''-1'' or d.CityCode IN (SELECT IntField FROM dbo.SplitString( ''' + @CitiesCodes + ''')) )
	and (''' + @ProfessionCodes + ''' = ''-1'' or
		(	
			SELECT count(*) 
			FROM x_Dept_Employee_Service 
			join x_Dept_Employee
			on x_Dept_Employee_Service.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
			WHERE x_Dept_Employee.deptCode = d.deptCode									
			AND serviceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ProfessionCodes + ''' ))) > 0
		)
	AND (
	''' + @ServiceCodes + ''' = ''-1'' or
		(SELECT count(*) 
		FROM x_Dept_Employee_Service 
		join x_Dept_Employee
		on x_Dept_Employee_Service.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
		WHERE x_Dept_Employee.deptCode = d.deptCode									
		AND ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ServiceCodes + ''' ))) > 0
		)
	

 left join DIC_ActivityStatus on DeptStatus.Status = DIC_ActivityStatus.status  
 left join DIC_deptLevel as ddl on d.DeptLevel = ddl.deptLevelCode 
 
 left join DeptPhones dp1 on d.DeptCode = dp1.DeptCode and dp1.PhoneType = 1 and dp1.phoneOrder = 1  
 left join DeptPhones dp2 on d.DeptCode = dp2.DeptCode and dp2.PhoneType = 1 and dp2.phoneOrder = 2 
 left join DeptPhones dp3 on d.DeptCode = dp3.DeptCode and dp3.PhoneType = 2 and dp3.phoneOrder = 1 
 left join x_dept_XY on d.deptCode =  x_dept_XY.deptCode
  
  CROSS APPLY dbo.rfn_GetReportServiceDetailsForDeptsByServicesTypes(d.deptCode) AS [ServiceDetails]
  where ''' + @ServiceGivenBy_cond + ''' = ''-1''
		or
		(''' + @ServiceGivenBy_cond + ''' = ''0''
		and [ServiceDetails].serviceIsGivenByPerson = 0)
		or
		(''' + @ServiceGivenBy_cond + ''' = ''1''
		and [ServiceDetails].serviceIsGivenByPerson <> 0)
 '
 if(@adminClinic = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dAdmin.DeptName as AdminClinicName ,
				 dAdmin.DeptCode as AdminClinicCode '+ @NewLineChar;
	end	
	
if(@district = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
		set @sql = @sql + ' dDistrict.DeptName as DistrictName , isNull(dDistrict.deptCode , -1) as DeptCode '+ @NewLineChar;
	end

if(@unitType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' UnitType.UnitTypeCode as UnitTypeCode , UnitType.UnitTypeName as UnitTypeName '+ @NewLineChar;
	end	
	
if(@subUnitType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
		' subUnitType.subUnitTypeCode as subUnitTypeCode , subUnitType.subUnitTypeName as subUnitTypeName '+ 
		@NewLineChar;
	end 

if( @ClinicName= '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'd.DeptName as ClinicName ' + @NewLineChar;	
end

if( @ClinicCode= '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' d.deptCode as ClinicCode ' + @NewLineChar;	
end

if(@simul = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'deptSimul.Simul228 as Code228 '+ @NewLineChar;
end 

if(@city = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);			
		set @sql = @sql + ' Cities.CityCode as CityCode, Cities.CityName as CityName'+ @NewLineChar;
	end

if(@Membership = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);			
		set @sql = @sql + 
		'case when d.IsCommunity = 1 then ''כן'' else ''לא'' end as IsCommunity, 
		case when d.IsMushlam = 1 then ''כן'' else ''לא'' end as 	IsMushlam,
		case when d.IsHospital = 1 then ''כן'' else ''לא'' end as IsHospital	
		'+ @NewLineChar;
	end
	 
--if(@status = '1')
--	begin 
		--set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		--set @sql = @sql + ' DeptStatus.Status as StatusCode , DIC_ActivityStatus.statusDescription as StatusName '+ @NewLineChar;
--	end 

if (@address = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'dbo.GetAddress(d.deptCode) as ClinicAddress '+ @NewLineChar;
	end	
 
if(@subAdminClinic = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'dSubAdmin.DeptCode as SubAdminClinicCode , dSubAdmin.DeptName as SubAdminClinicName '+ @NewLineChar;
end 

if(@MangerName = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_getManagerName(d.deptCode) as MangerName '+ @NewLineChar;							   
end

if(@adminMangerName = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_getAdminManagerName(d.deptCode) as AdminMangerName '+ @NewLineChar;
end

if(@Phone1 = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp1.prePrefix, dp1.Prefix,dp1.Phone, dp1.extension ) as Phone1 '+ @NewLineChar;;
end

if(@Phone2 = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp2.prePrefix, dp2.Prefix, dp2.Phone, dp2.extension) as Phone2 '+ @NewLineChar;;
end 

if(@Fax = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp3.prePrefix, dp3.Prefix, dp3.Phone, dp3.extension) as Fax '+ @NewLineChar;
end

if(@Email = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' d.Email as Email '+ @NewLineChar;
end		


if(@sector = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' ps.PopulationSectorID as SectorCode ,ps.PopulationSectorDescription as SectorName'+ @NewLineChar;
end 


--if(@showUnitInInternet = '1')
--begin 
--	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
--	set @sql = @sql + 'case 
--		when d.showUnitInInternet = ''1'' then ''כן''
--		else ''לא''
--	end as showUnitInInternet '+ @NewLineChar;		
--end

if(@deptLevelDesc = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'isNull(ddl.deptLevelCode , -1)	as deptLevelCode ,	 
		ddl.deptLevelDescription as deptLevelDesc '+ @NewLineChar;
end


if(@professions = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.rfn_GetDeptEmployeeProfessionDescriptions(d.DeptCode, -1) as professionDescription
			 ,dbo.rfn_GetDeptEmployeeProfessionCodes(d.DeptCode, -1) as professionCode ' 
		+ @NewLineChar;
end
---------------------
if(@serviceDescription = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + '[ServiceDetails].serviceDescription  as serviceDescription, [ServiceDetails].serviceCode  as serviceCode  ' + @NewLineChar;
end 
	
if(@serviceIsGivenByPersons = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + '[ServiceDetails].PersonsName  as ''serviceIsGivenByPerson''' + @NewLineChar;
end 

if(@QueueOrderDescription = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);

set @sql = @sql 
	+ ' [ServiceDetails].QueueOrderDescription as QueueOrderDescription '
	+ @NewLineChar 
	+ ' ,[ServiceDetails].QueueOrderClinicTelephone as QueueOrderClinicTelephone '
	+ @NewLineChar 
	+ ' ,[ServiceDetails].QueueOrderSpecialTelephone as QueueOrderSpecialTelephone '
	+ @NewLineChar
	+ ' ,[ServiceDetails].QueueOrderTelephone2700 as QueueOrderTelephone2700 '
	+ @NewLineChar
	+ ' ,[ServiceDetails].QueueOrderInternet as QueueOrderInternet '
	+ @NewLineChar
end

---remarkToService --------------------------
if(@remark = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + '[ServiceDetails].remark  as ''serviceRemark''' + @NewLineChar;	
end


if(@DeptCoordinates = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 
		'CONVERT(decimal(10,3), x_dept_XY.xcoord ) as XCoord  
		,CONVERT(decimal(10,3), x_dept_XY.ycoord ) as YCoord '  -- todo: create function fun_GetDeptServiceCodes
		+ @NewLineChar;
end


--=================================================================
set @sql = @sql + @sqlFrom+ @sqlEnd

print '--------- sql query full ----------'
print '--===== @sql string length = ' + str(len(@sql))
exec rpc_HelperLongPrint @sql 


EXECUTE sp_executesql @sql 
SET @ErrCode = @sql 
RETURN  
 
GO
GRANT EXEC ON [dbo].rprt_DeptsByServicesTypes TO PUBLIC
GO
-------------------
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_DeptAndServicesReceptions')
	BEGIN
		DROP  Procedure  rprt_DeptAndServicesReceptions
	END

GO

CREATE Procedure dbo.rprt_DeptAndServicesReceptions
(
	 @DistrictCodes varchar(max)=null,
	 @AdminClinicCode varchar(max)=null,	
	 @ServiceCodes varchar(max)=null, ---!
	 @UnitTypeCodes varchar(max)=null,
	 @SubUnitTypeCodes varchar(max)=null,
	 @StatusCodes varchar(max)=null,	---!
	 @SectorCodes varchar(max)=null,
	 @CitiesCodes varchar(max)=null, ---!
	 @ServiceGivenBy_cond varchar(max)=null, ---!
	 --  ObjectType = 3 - service is clinic office; ObjectType = 2 - regular service (is not office); ObjectType = 1 - clinic 
	 @ObjectType_cond varchar(max)=null, 
	 @ValidFrom_cond varchar(max)=null,
	 @ValidTo_cond varchar(max)=null,
	 @Membership_cond varchar(max)=null, 
	 
	@district varchar (2)= null,	
	@adminClinic varchar (2) = null ,		
	@subAdminClinic varchar (2)=null, 
	@unitType varchar (2)=null,		
	@subUnitType varchar (2)=null,	
	@ClinicName varchar (2)=null,
	@ClinicCode varchar (2)=null,
	@simul varchar (2)=null,
	@city varchar (2)=null,
	@address varchar (2)=null,
	@Phone1 varchar (2)=null,
	@Phone2 varchar (2)=null,
	@Fax varchar (2)=null,
	@Email varchar (2)=null,
	@sector varchar (2)=null,
	@MangerName varchar (2)=null,
	@adminMangerName varchar (2)=null,	
	@ServiceDescription varchar (2)=null,	
	@ServiceGivenByPersons varchar (2)=null,
	@RecepDay varchar (2)=null,	
	@RecepOpeningHour varchar (2)=null,
	@RecepClosingHour varchar (2)=null,
	@RecepTotalHours varchar (2)=null,
	@RecepValidFrom varchar (2)=null,
	@RecepValidTo varchar (2)=null,
	@RecepRemark varchar (2)=null,
	@Membership  varchar (2)=null,
	
	@IsExcelVersion varchar (2)= null,
	@ErrCode varchar(max) OUTPUT
	
-----------------------------------------
)with recompile

AS
--------------------------------------

DECLARE @NewLineChar AS CHAR(2) 
set @NewLineChar = CHAR(13) + CHAR(10)

declare  @sql nvarchar(max)-- nvarchar type supports hebrew lenguage
declare  @sqlEnd nvarchar(max)
declare  @sqlFrom varchar(max)

set @sql = 'SELECT distinct *  from
			(select ' + @NewLineChar;
set @sqlEnd = ') as resultTable' + @NewLineChar;

set @sqlFrom = 
'from dept  as d    
join dept as d2 on d.deptCode = d2.deptCode	
	AND d.status = 1
	AND (''' + @Membership_cond + ''' = ''-1'' 
		or d.IsCommunity = 1 and 1 in (SELECT IntField FROM dbo.SplitString( ''' + @Membership_cond + '''))
		or d.IsMushlam = 1 and 2 in (SELECT IntField FROM dbo.SplitString( ''' + @Membership_cond + '''))
		or d.IsHospital = 1 and 3 in (SELECT IntField FROM dbo.SplitString( ''' + @Membership_cond  + '''))
		)
	AND (''' + @AdminClinicCode + ''' = ''-1'' or d.administrationCode  in (SELECT IntField FROM dbo.SplitString( ''' + @AdminClinicCode + ''')))
	AND (''' + @DistrictCodes + ''' = ''-1'' or  d.districtCode IN (SELECT IntField FROM dbo.SplitString( ''' + @DistrictCodes + ''')) or d.DeptCode IN (SELECT x_Dept_District.DeptCode FROM dbo.SplitString(''' + @DistrictCodes + ''') as T JOIN  x_Dept_District ON T.IntField = x_Dept_District.districtCode) )
	AND (''' + @UnitTypeCodes + ''' = ''-1'' or d.typeUnitCode  in (SELECT IntField FROM dbo.SplitString( ''' + @UnitTypeCodes + ''')) )
	AND (''' + @SubUnitTypeCodes + ''' = ''-1'' or d.subUnitTypeCode in (SELECT IntField FROM dbo.SplitString( ''' + @SubUnitTypeCodes + ''')) )
	AND (''' + @SectorCodes + ''' = ''-1'' or d.populationSectorCode IN (SELECT IntField FROM dbo.SplitString( ''' + @SectorCodes + ''')) )

AND (
	''' + @ServiceCodes + ''' = ''-1'' or
		(SELECT count(*) 
		FROM x_Dept_Employee_Service 
		join x_Dept_Employee
		on x_Dept_Employee_Service.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
		WHERE x_Dept_Employee.deptCode = d.deptCode									
		AND ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ServiceCodes + ''' ))) > 0
	)
		 
 left join dept as dAdmin on d.administrationCode = dAdmin.deptCode   
 left join dept as dDistrict on d.districtCode = dDistrict.deptCode    
 left join dept as dSubAdmin on d.subAdministrationCode = dSubAdmin.deptCode 
 left join View_UnitType as UnitType on d.typeUnitCode =  UnitType.UnitTypeCode  
 left join View_SubUnitTypes as SubUnitType on d.subUnitTypeCode =  SubUnitType.subUnitTypeCode and  d.typeUnitCode =  SubUnitType.UnitTypeCode  
 left join PopulationSectors as ps on d.populationSectorCode = ps.PopulationSectorID  
 left join deptSimul on d.DeptCode = deptSimul.DeptCode 
 left join Cities on d.CityCode =  Cities.CityCode  
 
 left join DeptStatus on d.DeptCode = DeptStatus.DeptCode 
 join dept as d3 on d.deptCode = d3.deptCode
	AND (''' + @StatusCodes + ''' = ''-1'' or DeptStatus.Status IN (SELECT IntField FROM dbo.SplitString( ''' + @StatusCodes + ''')) )
	AND (''' + @CitiesCodes + ''' = ''-1'' or d.CityCode IN (SELECT IntField FROM dbo.SplitString( ''' + @CitiesCodes + ''')) )

 left join DIC_ActivityStatus on DeptStatus.Status = DIC_ActivityStatus.status  
 
 left join DeptPhones dp1 on d.DeptCode = dp1.DeptCode and dp1.PhoneType = 1 and dp1.phoneOrder = 1  
 left join DeptPhones dp2 on d.DeptCode = dp2.DeptCode and dp2.PhoneType = 1 and dp2.phoneOrder = 2 
 left join DeptPhones dp3 on d.DeptCode = dp3.DeptCode and dp3.PhoneType = 2 and dp3.phoneOrder = 1 

cross APPLY dbo.rfn_GetDeptAndServicesReception(d.deptCode,''' + 
		isNull(@ValidFrom_cond, 'null') +''', ''' +
		IsNull(@ValidTo_cond, 'null')+ ''', ''' + 
		@ObjectType_cond + ''', '''+ 
		@ServiceGivenBy_cond + ''') AS [DeptReception]

where	(''' + 	@ServiceGivenBy_cond + '''= ''-1''
	or ''' + 	@ServiceGivenBy_cond + '''= ''0'' and [DeptReception].serviceGivenByPersonCode = 0
	or ''' + @ServiceGivenBy_cond + ''' = ''1'' and [DeptReception].serviceGivenByPersonCode  > 0 
	)
	and (''' + 	@ObjectType_cond + '''= ''-1'' or [DeptReception].ObjectType IN (SELECT IntField FROM dbo.SplitString( ''' + @ObjectType_cond + ''')) )
 ' 
 
 
-----------------------------------------------------------
 if(@adminClinic = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dAdmin.DeptName as AdminClinicName ,
				 dAdmin.DeptCode as AdminClinicCode '+ @NewLineChar;
	end	
	
if(@district = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
		set @sql = @sql + ' dDistrict.DeptName as DistrictName , isNull(dDistrict.deptCode , -1) as DeptCode '+ @NewLineChar;
	end

if(@unitType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' UnitType.UnitTypeCode as UnitTypeCode , UnitType.UnitTypeName as UnitTypeName '+ @NewLineChar;
	end	
	
if(@subUnitType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
		' subUnitType.subUnitTypeCode as subUnitTypeCode , subUnitType.subUnitTypeName as subUnitTypeName '+ 
		@NewLineChar;
	end 

if( @ClinicName= '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'd.DeptName as ClinicName ' + @NewLineChar;	
end

if( @ClinicCode= '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' d.deptCode as ClinicCode ' + @NewLineChar;	
end

if(@simul = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'deptSimul.Simul228 as Code228 '+ @NewLineChar;
end 

if(@Membership = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);			
		set @sql = @sql + 
		'case when d.IsCommunity = 1 then ''כן'' else ''לא'' end as IsCommunity, 
		case when d.IsMushlam = 1 then ''כן'' else ''לא'' end as 	IsMushlam,
		case when d.IsHospital = 1 then ''כן'' else ''לא'' end as IsHospital	
		'+ @NewLineChar;
	end

if(@city = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);			
		set @sql = @sql + ' Cities.CityCode as CityCode, Cities.CityName as CityName'+ @NewLineChar;
	end

if (@address = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'dbo.GetAddress(d.deptCode) as ClinicAddress '+ @NewLineChar;
	end	
 
if(@subAdminClinic = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'dSubAdmin.DeptCode as SubAdminClinicCode , dSubAdmin.DeptName as SubAdminClinicName '+ @NewLineChar;
end 

if(@MangerName = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_getManagerName(d.deptCode) as MangerName '+ @NewLineChar;							   
end

if(@adminMangerName = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_getAdminManagerName(d.deptCode) as AdminMangerName '+ @NewLineChar;
end

if(@Phone1 = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp1.prePrefix, dp1.Prefix,dp1.Phone, dp1.extension ) as Phone1 '+ @NewLineChar;;
end
if(@Phone2 = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp2.prePrefix, dp2.Prefix, dp2.Phone, dp2.extension) as Phone2 '+ @NewLineChar;;
end 
if(@Fax = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp3.prePrefix, dp3.Prefix, dp3.Phone, dp3.extension) as Fax '+ @NewLineChar;
end
if(@Email = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' d.Email as Email '+ @NewLineChar;
end		


if(@sector = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' ps.PopulationSectorID as SectorCode ,ps.PopulationSectorDescription as SectorName'+ @NewLineChar;
end 
------------ serviceDescription -------------------------------------------------------------------------------------

if(@serviceDescription = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + '[DeptReception].serviceDescription  as serviceDescription,
	 [DeptReception].serviceCode  as serviceCode  ' + @NewLineChar;
end 

----------- serviceIsGivenByPerson-------------------------------------
if(@serviceGivenByPersons = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + '[DeptReception].serviceGivenByPerson  as ''serviceGivenByPerson'', 
	[DeptReception].serviceGivenByPersonCode  as ''serviceGivenByPersonCode''' + @NewLineChar;
end 

------------ RecepDay --------------------------------------------
if(@RecepDay = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' [DeptReception].ReceptionDayName  as ReceptionDayName ' + @NewLineChar;
	end 
		

----------- RecepOpeningHour --------------------------------------------------
if(@RecepOpeningHour = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' [DeptReception].openingHour  as openingHour ' + @NewLineChar;
end 

----------- RecepClosingHour --------------------------------------------------
if(@RecepClosingHour = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' [DeptReception].closingHour  as closingHour ' + @NewLineChar;
end 

----------- RecepTotalHours --------------------------------------------------
if(@RecepTotalHours = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' [DeptReception].totalHours  as totalHours ' + @NewLineChar;
end 

----------- RecepValidFrom --------------------------------------------------
if(@RecepValidFrom = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' CONVERT(varchar(max), [DeptReception].validFrom, 103)  as  validFrom  ' + @NewLineChar;
end 

----------- RecepValidTo --------------------------------------------------
if(@RecepValidTo = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' CONVERT(varchar(max), [DeptReception].validTo, 103) as  validTo ' + @NewLineChar;
end 

----------- RecepRemark --------------------------------------------------
if(@RecepRemark = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' [DeptReception].remarkText  as RecepRemark ' + @NewLineChar;
end 


--=================================================================
set @sql = @sql + @sqlFrom + @sqlEnd
print '--------- sql query full ----------'
Exec Helper_LongPrint @sql

EXECUTE sp_executesql @sql 
SET @ErrCode = @sql 
RETURN 

GO
GRANT EXEC ON [dbo].rprt_DeptAndServicesReceptions TO PUBLIC
GO
------------------

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'rfn_GetDeptEmployeesServiceCodes')
	BEGIN
		DROP  function  rfn_GetDeptEmployeesServiceCodes
	END

GO
--case @deptCode = -1  -- means all depts
--case @employeeID = -1  -- means all employees
create FUNCTION [dbo].rfn_GetDeptEmployeesServiceCodes(@deptCode bigint, @employeeID bigint)
RETURNS varchar(500)
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @strServices varchar(500)
	SET @strServices = ''
	
	SELECT @strServices = @strServices + convert(varchar(50), s.serviceCode) + '; '
	from
		(select distinct Services.serviceDescription, Services.serviceCode
		FROM x_Dept_Employee_Service AS xDES
		join x_Dept_Employee xde
		on xDES.DeptEmployeeID = xde.DeptEmployeeID
		inner join Services 
			ON xDES.serviceCode = Services.serviceCode
			and (@deptCode = -1 or xde.deptCode = @deptCode)
			and (@employeeID = -1 or xde.employeeID = @employeeID)
			and status = 1
			and Services.IsService = 1
		)
		as s
	order by s.serviceDescription
	
	IF(LEN(@strServices)) > 0 -- to remove last ','
	BEGIN
		SET @strServices = left( @strServices, LEN(@strServices) -1 )
	END
	
	RETURN( @strServices )
END

go 

grant exec on dbo.rfn_GetDeptEmployeesServiceCodes to public 
go  
---------
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'rfn_GetDeptServiceCodes')
	BEGIN
		DROP  function  rfn_GetDeptServiceCodes
	END
GO

create FUNCTION [dbo].rfn_GetDeptServiceCodes (@DeptCode int)
RETURNS varchar(500)
WITH EXECUTE AS CALLER
AS
BEGIN

	RETURN( '' )
END;
go 

grant exec on dbo.rfn_GetDeptServiceCodes to public 
go  
---------
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'rfn_GetDeptServiceDescriptions')
	BEGIN
		DROP  function  rfn_GetDeptServiceDescriptions
	END
GO

create FUNCTION [dbo].rfn_GetDeptServiceDescriptions (@DeptCode int)
RETURNS varchar(500)
WITH EXECUTE AS CALLER
AS
BEGIN
	RETURN( '' )
END;
go 

grant exec on dbo.rfn_GetDeptServiceDescriptions to public 
go  

------------

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_DeptsByProfessionsTypes')
	BEGIN
		DROP  Procedure  dbo.rprt_DeptsByProfessionsTypes
	END

GO

CREATE Procedure dbo.rprt_DeptsByProfessionsTypes
(
	 @DistrictCodes varchar(max)=null,
	 @AdminClinicCode varchar(max)=null,	
	 @ServiceCodes varchar(max)=null,
	 @UnitTypeCodes varchar(max)=null,
	 @SubUnitTypeCodes varchar(max)=null,
	 @StatusCodes varchar(max)=null,	
	 @SectorCodes varchar(max)=null,
	 @ProfessionCodes varchar(max)=null,  
	 @CitiesCodes varchar(max)=null,
	 @Membership_cond varchar(max)=null, 
	 
	@district varchar (2)= null,	
	@adminClinic varchar (2) = null ,		
	@subAdminClinic varchar (2)=null, 
	@unitType varchar (2)=null,		
	@subUnitType varchar (2)=null,	
	@status varchar (2)=null,			
	@statusFromDate varchar (2)=null,	
	@ClinicName varchar (2)=null,
	@ClinicCode varchar (2)=null,
	@fromDateName varchar (2)=null,			
	@simul varchar (2)=null,
	@city varchar (2)=null,
	@address varchar (2)=null,
	@addressComment varchar (2)=null, 	
	@Phone1 varchar (2)=null,
	@Phone2 varchar (2)=null,
	@Fax varchar (2)=null,
	@Email varchar (2)=null,
	@sector varchar (2)=null,
	@MangerName varchar (2)=null,
	@adminMangerName varchar (2)=null,	
	
	@transportation varchar (2)=null,
	@deptLevelDesc varchar (2)=null,
	@professions varchar (2)=null,
	@DeptServices varchar (2)=null,	
	@EmployeeServices varchar (2)=null,	
	@DeptHandicappedFacilities varchar (2)=null, -- name changed
	@Membership  varchar (2)=null,
	@IsExcelVersion varchar (2)= null,
	@showUnitInInternet varchar (2)=null,
	@DeptCoordinates varchar (2)=null,
	
	@ErrCode VARCHAR(max) OUTPUT
	
-----------------------------------------
)with recompile

AS
--------------------------------------

DECLARE @NewLineChar AS CHAR(2) 
set @NewLineChar = CHAR(13) + CHAR(10)

declare  @sql nvarchar(max)-- nvarchar type supports hebrew lenguage
declare  @sqlEnd nvarchar(max)
declare  @sqlFrom varchar(max)

set @sql = 'SELECT distinct *  from
			(select ' + @NewLineChar;
set @sqlEnd = ') as resultTable' + @NewLineChar;

set @sqlFrom = 
'from dept  as d    
join dept as d2 on d.deptCode = d2.deptCode	
	AND (''' + @Membership_cond + ''' = ''-1'' 
		or d.IsCommunity = 1 and 1 in (SELECT IntField FROM dbo.SplitString( ''' + @Membership_cond + '''))
		or d.IsMushlam = 1 and 2 in (SELECT IntField FROM dbo.SplitString( ''' + @Membership_cond + '''))
		or d.IsHospital = 1 and 3 in (SELECT IntField FROM dbo.SplitString( ''' + @Membership_cond  + '''))
		)
	AND (''' + @AdminClinicCode + ''' = ''-1'' or d.administrationCode  in (SELECT IntField FROM dbo.SplitString( ''' + @AdminClinicCode + ''')))
	AND (''' + @DistrictCodes + ''' = ''-1'' or  d.districtCode IN (SELECT IntField FROM dbo.SplitString( ''' + @DistrictCodes + ''')) or d.DeptCode IN (SELECT x_Dept_District.DeptCode FROM dbo.SplitString(''' + @DistrictCodes + ''') as T JOIN  x_Dept_District ON T.IntField = x_Dept_District.districtCode) )
	AND (''' + @UnitTypeCodes + ''' = ''-1'' or d.typeUnitCode  in (SELECT IntField FROM dbo.SplitString( ''' + @UnitTypeCodes + ''')) )
	AND (''' + @SubUnitTypeCodes + ''' = ''-1'' or d.subUnitTypeCode in (SELECT IntField FROM dbo.SplitString( ''' + @SubUnitTypeCodes + ''')) )
	AND (''' + @SectorCodes + ''' = ''-1'' or d.populationSectorCode IN (SELECT IntField FROM dbo.SplitString( ''' + @SectorCodes + ''')) )
	 
 left join dept as dAdmin on d.administrationCode = dAdmin.deptCode   
 left join dept as dDistrict on d.districtCode = dDistrict.deptCode    
 left join dept as dSubAdmin on d.subAdministrationCode = dSubAdmin.deptCode 
 left join View_UnitType as UnitType on d.typeUnitCode =  UnitType.UnitTypeCode  
 left join View_SubUnitTypes as SubUnitType on d.subUnitTypeCode =  SubUnitType.subUnitTypeCode and  d.typeUnitCode =  SubUnitType.UnitTypeCode  
 left join PopulationSectors as ps on d.populationSectorCode = ps.PopulationSectorID  
 left join deptSimul on d.DeptCode = deptSimul.DeptCode 
 left join Cities on d.CityCode =  Cities.CityCode  
 
 left join DeptStatus on d.DeptCode = DeptStatus.DeptCode 
 join dept as d3 on d.deptCode = d3.deptCode
	AND (''' + @StatusCodes + ''' = ''-1'' or DeptStatus.Status IN (SELECT IntField FROM dbo.SplitString( ''' + @StatusCodes + ''')) )
	AND (''' + @CitiesCodes + ''' = ''-1'' or d.CityCode IN (SELECT IntField FROM dbo.SplitString( ''' + @CitiesCodes + ''')) )
	and (''' + @ProfessionCodes + ''' = ''-1'' or
		(	
			SELECT count(*) 
			FROM x_Dept_Employee_Service 
			join x_Dept_Employee
			on x_Dept_Employee_Service.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
			WHERE x_Dept_Employee.deptCode = d.deptCode									
			AND ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ProfessionCodes + ''' ))) > 0
		)
	AND (
	''' + @ServiceCodes + ''' = ''-1'' or
		(SELECT count(*) 
		FROM x_Dept_Employee_Service 
		join x_Dept_Employee
		on x_Dept_Employee_Service.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
		WHERE x_Dept_Employee.deptCode = d.deptCode									
		AND ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ServiceCodes + ''' ))) > 0
		)

 left join DIC_ActivityStatus on DeptStatus.Status = DIC_ActivityStatus.status  
 left join DIC_deptLevel as ddl on d.DeptLevel = ddl.deptLevelCode 
 
 left join DeptPhones dp1 on d.DeptCode = dp1.DeptCode and dp1.PhoneType = 1 and dp1.phoneOrder = 1  
 left join DeptPhones dp2 on d.DeptCode = dp2.DeptCode and dp2.PhoneType = 1 and dp2.phoneOrder = 2 
 left join DeptPhones dp3 on d.DeptCode = dp3.DeptCode and dp3.PhoneType = 2 and dp3.phoneOrder = 1 
 left join x_dept_XY on d.deptCode =  x_dept_XY.deptCode
 '

-----------------------------------------------------------
 if(@adminClinic = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dAdmin.DeptName as AdminClinicName ,
				 dAdmin.DeptCode as AdminClinicCode '+ @NewLineChar;
	end	
	
if(@district = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
		set @sql = @sql + ' dDistrict.DeptName as DistrictName , isNull(dDistrict.deptCode , -1) as DeptCode '+ @NewLineChar;
	end

if(@unitType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' UnitType.UnitTypeCode as UnitTypeCode , UnitType.UnitTypeName as UnitTypeName '+ @NewLineChar;
	end	
	
if(@subUnitType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
		' subUnitType.subUnitTypeCode as subUnitTypeCode , subUnitType.subUnitTypeName as subUnitTypeName '+ 
		@NewLineChar;
	end 

if( @ClinicName= '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'd.DeptName as ClinicName ' + @NewLineChar;	
end

if( @ClinicCode= '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' d.deptCode as ClinicCode ' + @NewLineChar;	
end

if(@simul = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'deptSimul.Simul228 as Code228 '+ @NewLineChar;
end 

if(@city = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);			
		set @sql = @sql + ' Cities.CityCode as CityCode, Cities.CityName as CityName'+ @NewLineChar;
	end

if(@Membership = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);			
		set @sql = @sql + 
		'case when d.IsCommunity = 1 then ''כן'' else ''לא'' end as IsCommunity, 
		case when d.IsMushlam = 1 then ''כן'' else ''לא'' end as 	IsMushlam,
		case when d.IsHospital = 1 then ''כן'' else ''לא'' end as IsHospital	
		'+ @NewLineChar;
	end

if(@status = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' DeptStatus.Status as StatusCode , DIC_ActivityStatus.statusDescription as StatusName '+ @NewLineChar;
	end 

if(@statusFromDate = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' CONVERT(varchar(max), DeptStatus.FromDate, 103) AS StatusFromDate '+ @NewLineChar;
	
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' CONVERT(varchar(max), DeptStatus.ToDate, 103) AS StatusToDate '+ @NewLineChar;
	end 

if (@address = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'dbo.GetAddress(d.deptCode) as ClinicAddress '+ @NewLineChar;
	end	
 
if(@subAdminClinic = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'dSubAdmin.DeptCode as SubAdminClinicCode , dSubAdmin.DeptName as SubAdminClinicName '+ @NewLineChar;
end 

if(@MangerName = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_getManagerName(d.deptCode) as MangerName '+ @NewLineChar;							   
end

if(@adminMangerName = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_getAdminManagerName(d.deptCode) as AdminMangerName '+ @NewLineChar;
end

if(@Phone1 = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp1.prePrefix, dp1.Prefix,dp1.Phone, dp1.extension ) as Phone1 '+ @NewLineChar;;
end

if(@Phone2 = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp2.prePrefix, dp2.Prefix, dp2.Phone, dp2.extension) as Phone2 '+ @NewLineChar;;
end 

if(@Fax = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp3.prePrefix, dp3.Prefix, dp3.Phone, dp3.extension) as Fax '+ @NewLineChar;
end

if(@Email = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' d.Email as Email '+ @NewLineChar;
end		


if(@sector = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' ps.PopulationSectorID as SectorCode ,ps.PopulationSectorDescription as SectorName'+ @NewLineChar;
end 


if(@showUnitInInternet = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'case 
		when d.showUnitInInternet = ''1'' then ''כן''
		else ''לא''
	end as showUnitInInternet '+ @NewLineChar;		
end

if(@fromDateName = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' (select top 1 
			CONVERT(VARCHAR(10), FromDate, 103)  
			from dbo.DeptNames
			where deptCode=d.DeptCode and fromDate <=getDate()
			order by fromDate desc) as fromDateName '+ @NewLineChar;
end 


if(@addressComment = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' d.addressComment as AddressComment '+ @NewLineChar;
end

										 
if(@DeptHandicappedFacilities = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 
	' dbo.rfn_GetDeptHandicappedFacilities(d.DeptCode) as DeptHandicappedFacilities '+ @NewLineChar;
				
end

if(@transportation = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' d.transportation as transportation '+ @NewLineChar;
end


if(@deptLevelDesc = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'isNull(ddl.deptLevelCode , -1)	as deptLevelCode ,	 
		ddl.deptLevelDescription as deptLevelDesc '+ @NewLineChar;
end


if(@professions = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.rfn_GetDeptEmployeeProfessionDescriptions(d.DeptCode, -1) as professionDescription
			 ,dbo.rfn_GetDeptEmployeeProfessionCodes(d.DeptCode, -1) as professionCode ' 
		+ @NewLineChar;
end


if(@EmployeeServices = '1')
begin 

	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 
		' dbo.rfn_GetDeptEmployeesServiceDescriptions(d.DeptCode, -1) as EmployeeServices 
		 ,dbo.rfn_GetDeptEmployeesServiceCodes(d.DeptCode, -1) as EmployeeServiceCode '-- todo: create function fun_GetDeptEmployeesServiceCodes
		 + @NewLineChar;
end


if(@DeptServices = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 
		'dbo.rfn_GetDeptServiceDescriptions(d.DeptCode) as DeptServices  
		,dbo.rfn_GetDeptServiceCodes(d.DeptCode) as DeptServiceCode  '  -- todo: create function fun_GetDeptServiceCodes
		+ @NewLineChar;
end

if(@DeptCoordinates = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 
		'CONVERT(decimal(10,3), x_dept_XY.xcoord ) as XCoord  
		,CONVERT(decimal(10,3), x_dept_XY.ycoord ) as YCoord '  -- todo: create function fun_GetDeptServiceCodes
		+ @NewLineChar;
end

--=================================================================

set @sql = @sql + @sqlFrom+ @sqlEnd

print '--------- sql query full ----------'
print '--===== @sql string length = ' + str(len(@sql))
Exec rpc_HelperLongPrint @sql


EXECUTE sp_executesql @sql 
SET @ErrCode = @sql 
RETURN 

GO
GRANT EXEC ON [dbo].rprt_DeptsByProfessionsTypes TO PUBLIC
GO
---------

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_DeptEmployeeProfessions')
	BEGIN
		DROP  View View_DeptEmployeeProfessions
	END
GO

CREATE VIEW [dbo].View_DeptEmployeeProfessions
AS
SELECT  x_Dept_Employee.deptCode, x_Dept_Employee.EmployeeId
			,STUFF( 
				(
					SELECT  '; ' + cast(Services.ServiceDescription as varchar(max))
					from x_Dept_Employee_Service as xDEP
					inner join Services 
						on xDEP.serviceCode = Services.ServiceCode
						and xDEP.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
						and Services.IsProfession = 1
					order by Services.ServiceDescription
					FOR XML PATH('') 
				)
				,1,2,'') as ProfessionDescriptions
			,STUFF( 
				(
					SELECT  '; ' + cast(Services.ServiceCode as varchar(max))
					from x_Dept_Employee_Service as xDEP
					inner join Services 
						on xDEP.serviceCode = Services.ServiceCode
						and xDEP.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
						and Services.IsProfession = 1
					order by Services.ServiceDescription
					FOR XML PATH('') 
				)
				,1,2,'') as ProfessionCodes
	from x_Dept_Employee 
GO

---------------
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_DeptEmployees')
	BEGIN
		DROP  Procedure  dbo.rprt_DeptEmployees
	END

GO

CREATE Procedure dbo.rprt_DeptEmployees
(
	 @DistrictCodes varchar(max)=null,
	 @AdminClinicCode varchar(max)=null,	
	 @UnitTypeCodes varchar(max)=null,
	 @EmployeeSector_cond varchar(max)=null,
	 @ServiceCodes varchar(max)=null,
	 @ProfessionCodes varchar(max)=null,
	 @ExpertProfessionCodes varchar(max)=null,
	 @CitiesCodes varchar(max)=null,
	 --@EmployeeIndependent_cond varchar(max)=null, -- Dept employee Independent condition
	 @AgreementType_cond varchar(max)=null,
	 @DeptEmployeeStatusCodes varchar(max)=null,
	 
	@district varchar (2)= null,	
	@adminClinic varchar (2) = null ,		
	@subAdminClinic varchar (2)=null, 
	@unitType varchar (2)=null,		
	@SubUnitType varchar (2)=null,	
	@ClinicName varchar (2)=null,
	@ClinicCode varchar (2)=null,
	@simul varchar (2)=null,
	@city varchar (2)=null,
	@address varchar (2)=null,
	@Phone1 varchar (2)=null,
	@Phone2 varchar (2)=null,
	@Fax varchar (2)=null,
	@Email varchar (2)=null,
	@sector varchar (2)=null,
	@MangerName varchar (2)=null,
	@adminMangerName varchar (2)=null,	
	@EmployeeName varchar (2)=null,
	@EmployeeID varchar (2)=null,
	@Position varchar (2)=null,
	@DeptEmployeePhone varchar (2)=null,
	@DeptEmployeeFax varchar (2)=null,
	@DeptEmployeeRemark varchar (2)=null,
	@DeptEmployeeEmail varchar (2)=null,
	--@DeptEmployeeIndependent varchar (2)=null,
	@AgreementType  varchar(2)= null,
	@Professions varchar (2)=null,
	@EmployeeSector varchar (2)=null,
	@EmployeeLicenseNumber varchar (2)=null,	
	@EmployeeExpert varchar (2)=null,		-- don't used now
	@EmployeeExpertProfession varchar (2)=null,	
	@DeptEmployeeServices varchar (2)=null,
	@QueueOrderDescription varchar (2)=null, 
	@EmployeeStatus		varchar(2)= null,
	@DeptEmployeeStatus varchar(2)= null,
	@EmployeeSex varchar(2)=null, 
	@EmployeeDegree varchar(2)= null,
	@IsExcelVersion varchar (2)=null,
	
	@ErrCode varchar(max) OUTPUT
-----------------------------------------
)with recompile

AS
--------------------------------------

DECLARE @NewLineChar AS CHAR(2) 
set @NewLineChar = CHAR(13) + CHAR(10)

--set variables 
declare  @sql nvarchar(max)-- nvarchar type supports hebrew lenguage
declare  @sqlEnd nvarchar(max)
declare  @sqlFrom varchar(max)
declare  @sqlWhere varchar(max)

set @sqlWhere = ' ';
---------------------------
set @sql = 'SELECT distinct *  from
			(select ' + @NewLineChar;
set @sqlEnd = ') as resultTable' + @NewLineChar;

set @sqlFrom = 
'from dept  as d    
left join x_Dept_Employee ON d.deptCode = x_Dept_Employee.deptCode 
join x_Dept_Employee as xDE ON xDE.deptCode = x_Dept_Employee.deptCode
	AND (''' + @AdminClinicCode + ''' = ''-1'' or d.administrationCode  in (SELECT IntField FROM dbo.SplitString( ''' + @AdminClinicCode + ''')))
	AND (''' + @UnitTypeCodes + ''' = ''-1'' or d.typeUnitCode  in (SELECT IntField FROM dbo.SplitString( ''' + @UnitTypeCodes + ''')) )
	AND (''' + @CitiesCodes + ''' = ''-1'' or d.CityCode IN (SELECT IntField FROM dbo.SplitString( ''' + @CitiesCodes + ''')) )
	AND (''' + @DistrictCodes + ''' = ''-1'' or  d.districtCode IN (SELECT IntField FROM dbo.SplitString( ''' + @DistrictCodes + ''')) or d.DeptCode IN (SELECT x_Dept_District.DeptCode FROM dbo.SplitString(''' + @DistrictCodes + ''') as T JOIN  x_Dept_District ON T.IntField = x_Dept_District.districtCode) )
	AND (''' + @AgreementType_cond + ''' = ''-1'' or x_Dept_Employee.AgreementType IN (SELECT IntField FROM dbo.SplitString(''' + @AgreementType_cond + ''' ))) 
	and (''' + @ProfessionCodes + ''' = ''-1'' or
	(	SELECT count(*) 
		FROM x_Dept_Employee_Service as xDEP 
		WHERE x_Dept_Employee.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID							
		AND ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ProfessionCodes + ''' ))) > 0
	)
	AND (''' + @ExpertProfessionCodes + ''' = ''-1'' or
	(	SELECT count(*) 
		FROM x_Dept_Employee_Service  as xDEP 
		left join EmployeeServices on 
					x_Dept_Employee.employeeID = EmployeeServices.employeeID 
					and xDEP.ServiceCode = EmployeeServices.ServiceCode
					and EmployeeServices.expProfession = 1
		WHERE x_Dept_Employee.DeptEmployeeID= xDEP.DeptEmployeeID	
		and EmployeeServices.ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ExpertProfessionCodes + ''' ))) > 0
	)
	AND (''' + @ServiceCodes + ''' = ''-1'' or
	(	SELECT count(*) 
		FROM x_Dept_Employee_Service as xDS
		WHERE x_Dept_Employee.DeptEmployeeID = xDS.DeptEmployeeID									
		AND ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ServiceCodes + ''' ))) > 0
	)
left join View_DeptEmployeesCurrentStatus as v_DECStatus 
	on x_Dept_Employee.deptCode = v_DECStatus.deptCode
	and x_Dept_Employee.employeeID = v_DECStatus.employeeID
JOIN Employee ON x_Dept_Employee.employeeID = Employee.employeeID 
AND (''' + @EmployeeSector_cond + ''' = ''-1'' or Employee.EmployeeSectorCode IN (SELECT IntField FROM dbo.SplitString(''' + @EmployeeSector_cond + ''' )) )
AND (''' + @DeptEmployeeStatusCodes + ''' = ''-1'' or  v_DECStatus.status IN (SELECT IntField FROM dbo.SplitString( ''' + @DeptEmployeeStatusCodes + ''')) )

join DIC_ActivityStatus as EmpStatus on EmpStatus.Status = Employee.active 
join DIC_ActivityStatus as DeptEmpStatus on DeptEmpStatus.Status = v_DECStatus.Status

join DIC_AgreementTypes on x_Dept_Employee.AgreementType = DIC_AgreementTypes.AgreementTypeID

left JOIN View_EmployeeSector on Employee.EmployeeSectorCode = View_EmployeeSector.EmployeeSectorCode

left join dept as dAdmin on d.administrationCode = dAdmin.deptCode    
left join dept as dDistrict on d.districtCode = dDistrict.deptCode  
left join View_UnitType as UnitType on d.typeUnitCode =  UnitType.UnitTypeCode   
left join View_SubUnitTypes as SubUnitType on d.subUnitTypeCode =  SubUnitType.subUnitTypeCode
	 and  d.typeUnitCode =  SubUnitType.UnitTypeCode 
left join Cities on d.CityCode =  Cities.CityCode
left join deptSimul on d.DeptCode = deptSimul.DeptCode 
left join dept as dSubAdmin on d.subAdministrationCode = dSubAdmin.deptCode 

cross apply rfn_GetDeptEmployeeQueueOrderDetails(d.deptCode, x_Dept_Employee.employeeID) as QueueOrderDetails
left join DeptEmployeePhones as  emplPh1  on  x_Dept_Employee.DeptEmployeeID = emplPh1.DeptEmployeeID 
	and emplPh1.PhoneType = 1 and emplPh1.phoneOrder = 1  
left join DeptEmployeePhones as emplPh2  on  x_Dept_Employee.DeptEmployeeID = emplPh2.DeptEmployeeID 
	and emplPh2.PhoneType = 1 and emplPh2.phoneOrder = 2 
left join DeptEmployeePhones as emplPh3  on  x_Dept_Employee.DeptEmployeeID = emplPh3.DeptEmployeeID  
	and emplPh3.PhoneType = 2 and emplPh3.phoneOrder = 1 
left join DeptPhones dp1 on d.DeptCode = dp1.DeptCode and dp1.PhoneType = 1 and dp1.phoneOrder = 1  
left join DeptPhones dp2 on d.DeptCode = dp2.DeptCode and dp2.PhoneType = 1 and dp2.phoneOrder = 2 
left join DeptPhones dp3 on d.DeptCode = dp3.DeptCode and dp3.PhoneType = 2 and dp3.phoneOrder = 1 
left  join PopulationSectors as ps on d.populationSectorCode = ps.PopulationSectorID 

left join [dbo].View_DeptEmployeeProfessions as DEProfessions	 
	on x_Dept_Employee.deptCode = DEProfessions.deptCode
	and Employee.employeeID = DEProfessions.employeeID 
	
left join [dbo].View_DeptEmployeeExpertProfessions as DEExpProfessions 
	on x_Dept_Employee.deptCode = DEExpProfessions.deptCode
	and Employee.employeeID = DEExpProfessions.employeeID 

left join [dbo].View_DeptEmployeePositions as DEPositions 
	on x_Dept_Employee.deptCode = DEPositions.deptCode
	and Employee.employeeID = DEPositions.employeeID 
	
left join [dbo].View_DeptEmployeeServices as DEServices 
	on x_Dept_Employee.deptCode = DEServices.deptCode
	and Employee.employeeID = DEServices.employeeID 
	
left join [dbo].View_DeptEmployeeRemarks as DERemarks
	on x_Dept_Employee.deptCode = DERemarks.deptCode
	and Employee.employeeID = DERemarks.employeeID
	
left JOIN DIC_EmployeeDegree on Employee.DegreeCode = DIC_EmployeeDegree.DegreeCode 
'

if(@adminClinic = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dAdmin.DeptName as AdminClinicName ,
				 isNull(dAdmin.DeptCode , -1) as AdminClinicCode '+ @NewLineChar;
	end 
	
if(@district = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
		set @sql = @sql + ' dDistrict.DeptName as DistrictName , isNull(dDistrict.deptCode , -1) as DeptCode '+ @NewLineChar;
	end	
if(@unitType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' UnitType.UnitTypeCode as UnitTypeCode , UnitType.UnitTypeName as UnitTypeName '+ @NewLineChar;
	end
if(@subUnitType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
		' subUnitType.subUnitTypeCode as subUnitTypeCode , subUnitType.subUnitTypeName as subUnitTypeName '+ 
		@NewLineChar;
	end 
	
if( @ClinicName= '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'd.DeptName as ClinicName ' + @NewLineChar;	
	end

if( @ClinicCode= '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' d.deptCode as ClinicCode ' + @NewLineChar;	
	end

if(@simul = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'deptSimul.Simul228 as Code228 '+ @NewLineChar;
	end 

if(@subAdminClinic = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'dSubAdmin.DeptCode as SubAdminClinicCode , dSubAdmin.DeptName as SubAdminClinicName '+ @NewLineChar;
	end 			
	
if(@city = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);			
		set @sql = @sql + ' Cities.CityCode as CityCode, Cities.CityName as CityName'+ @NewLineChar;
	end

if (@address = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'dbo.GetAddress(d.deptCode) as ClinicAddress '+ @NewLineChar;
	end	
	
if(@Phone1 = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp1.prePrefix, dp1.Prefix,dp1.Phone, dp1.extension ) as Phone1 '+ @NewLineChar;;
end

if(@Phone2 = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp2.prePrefix, dp2.Prefix, dp2.Phone, dp2.extension) as Phone2 '+ @NewLineChar;;
end 

if(@Fax = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp3.prePrefix, dp3.Prefix, dp3.Phone, dp3.extension) as Fax '+ @NewLineChar;
end

if(@Email = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' d.Email as Email '+ @NewLineChar;
	end

if(@MangerName = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dbo.fun_getManagerName(d.deptCode) as MangerName '+ @NewLineChar;							   
	end

if(@adminMangerName = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dbo.fun_getAdminManagerName(d.deptCode) as AdminMangerName '+ @NewLineChar;
	end

if(@sector = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' ps.PopulationSectorID as SectorCode ,ps.PopulationSectorDescription as SectorName'+ @NewLineChar;
	end 	 	

if(@EmployeeName = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'Employee.firstName as EmployeeFirstName, Employee.lastName as EmployeeLastName'+ @NewLineChar;
	end
	
if(@EmployeeID = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.EmployeeID as EmployeeID '+ @NewLineChar;
	end
	
if(@EmployeeLicenseNumber = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.licenseNumber as EmployeeLicenseNumber '+ @NewLineChar;
	end

if(@DeptEmployeeEmail = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'Employee.email as EmployeeEmail'+ @NewLineChar;
	end

if(@EmployeeSector = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.EmployeeSectorCode as EmployeeSectorCode,  
		View_EmployeeSector.EmployeeSectorDescription as EmployeeSectorDescription'+ @NewLineChar;
	end	


if(@Position = '1' ) 
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
			' DEPositions.PositionDescriptions as PositionDescription
			 ,DEPositions.PositionCodes as PositionCode' 
		+ @NewLineChar;
	end
	
if(@Professions = '1' ) 
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql +
			' DEProfessions.ProfessionDescriptions as ProfessionDescription
			 ,DEProfessions.ProfessionCodes as ProfessionCode ' 
			+ @NewLineChar;
	end

if(@EmployeeExpertProfession = '1') 
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql +
			' DEExpProfessions.ExpertProfessionDescriptions as ExpertProfessionDescription
			 ,DEExpProfessions.ExpertProfessionCodes as ExpertProfessionCode' 
		+ @NewLineChar;
	end

if(@DeptEmployeeServices = '1' ) 
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
			' DEServices.ServiceDescriptions as ServiceDescription 
			,DEServices.ServiceCodes as ServiceCode' 
		+ @NewLineChar;
	end	

if(@DeptEmployeeRemark = '1' )  -- changed
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
			' DERemarks.RemarkDescriptions as EmployeeRemarkDescription
			,DERemarks.RemarkCodes as EmployeeRemarkID'
		+ @NewLineChar;
	end

	
if(@QueueOrderDescription = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql 
		+ ' QueueOrderDetails. QueueOrderDescription as QueueOrderDescription '
		+ @NewLineChar 
		+ ' ,QueueOrderDetails.QueueOrderClinicTelephone as QueueOrderClinicTelephone '
		+ @NewLineChar 
		+ ' ,QueueOrderDetails.QueueOrderSpecialTelephone as QueueOrderSpecialTelephone '
		+ @NewLineChar
		+ ' ,QueueOrderDetails.QueueOrderTelephone2700 as QueueOrderTelephone2700 '
		+ @NewLineChar
		+ ' ,QueueOrderDetails.QueueOrderInternet as QueueOrderInternet '
		+ @NewLineChar
	end	

if(@DeptEmployeePhone = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'case when x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1
		then dbo.fun_ParsePhoneNumberWithExtension(dp1.prePrefix, dp1.Prefix, dp1.Phone, dp1.Extension )
		else dbo.fun_ParsePhoneNumberWithExtension(emplPh1.prePrefix, emplPh1.Prefix, emplPh1.Phone, emplPh1.Extension )end as EmployeePhone1 '+ @NewLineChar;;

		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'case when x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1
		then dbo.fun_ParsePhoneNumberWithExtension(dp2.prePrefix, dp2.Prefix, dp2.Phone, dp2.Extension )
		else dbo.fun_ParsePhoneNumberWithExtension(emplPh2.prePrefix, emplPh2.Prefix, emplPh2.Phone, emplPh2.Extension )end as EmployeePhone2 '+ @NewLineChar;;
	end

if(@DeptEmployeeFax = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'case when x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1
		then dbo.fun_ParsePhoneNumberWithExtension(dp3.prePrefix, dp3.Prefix, dp3.Phone, dp3.Extension ) 
		else dbo.fun_ParsePhoneNumberWithExtension(emplPh3.prePrefix, emplPh3.Prefix, emplPh3.Phone, emplPh3.Extension )end as EmployeeFax '+ @NewLineChar;;
	end

if(@AgreementType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql 
		 + 'DIC_AgreementTypes.AgreementTypeID as AgreementTypeCode,
		 DIC_AgreementTypes.AgreementTypeDescription as AgreementTypeDescription '
		+ @NewLineChar;
	end	

if(@EmployeeStatus = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' EmpStatus.Status as StatusCode, EmpStatus.StatusDescription as StatusDescription '+ @NewLineChar;
	end	
if(@DeptEmployeeStatus = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' DeptEmpStatus.Status as DeptEmployeeStatusCode, DeptEmpStatus.StatusDescription as DeptEmployeeStatusDescription '+ @NewLineChar;
	end	
if(@EmployeeDegree = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' DIC_EmployeeDegree.degreeName as EmployeeDegree, DIC_EmployeeDegree.degreeCode as EmployeeDegreeCode '+ @NewLineChar;
	end
if (@EmployeeSex = '1')
begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'case when Employee.Sex = 1 then ''זכר'' when Employee.Sex = 2 then ''נקבה'' else ''לא מוגדר'' end  as EmployeeSex'+ @NewLineChar;
end
--=================================================================
--=================================================================

set @sql = @sql + @sqlFrom + @sqlWhere + @sqlEnd

print '--------- sql query full ----------'
print '--===== @sql string length = ' + str(len(@sql))
Exec rpc_HelperLongPrint @sql 

EXECUTE sp_executesql @sql 
SET @ErrCode = @sql 
RETURN 

GO
GRANT EXEC ON [dbo].rprt_DeptEmployees TO PUBLIC
GO
----------
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_DeptEmployeeReceptions')
	BEGIN
		DROP  Procedure  dbo.rprt_DeptEmployeeReceptions
	END

GO

CREATE Procedure dbo.rprt_DeptEmployeeReceptions
(
	 @DistrictCodes varchar(max)=null,
	 @AdminClinicCode varchar(max)=null,	
	 @UnitTypeCodes varchar(max)=null,
	 @EmployeeSector_cond varchar(max)=null,
	 @ServiceCodes varchar(max)=null,
	 @ProfessionCodes varchar(max)=null,
	 @ExpertProfessionCodes varchar(max)=null,
	 @CitiesCodes varchar(max)=null,
	 @AgreementType_cond varchar(max)=null,
	 
	@district varchar (2)= null,	
	@adminClinic varchar (2) = null ,		
	@subAdminClinic varchar (2)=null, 
	@unitType varchar (2)=null,		
	@SubUnitType varchar (2)=null,	
	@ClinicName varchar (2)=null,
	@ClinicCode varchar (2)=null,
	@simul varchar (2)=null,
	@city varchar (2)=null,
	@address varchar (2)=null,
	@Phone1 varchar (2)=null,
	@Phone2 varchar (2)=null,
	@Fax varchar (2)=null,
	@Email varchar (2)=null,
	@sector varchar (2)=null,
	@MangerName varchar (2)=null, 
	@adminMangerName varchar (2)=null,	
	@EmployeeName varchar (2)=null,
	@EmployeeID varchar (2)=null,
	@Position varchar (2)=null,
	@DeptEmployeePhone varchar (2)=null,
	@DeptEmployeeFax varchar (2)=null,
	@DeptEmployeeRemark varchar (2)=null,
	@DeptEmployeeEmail varchar (2)=null,
	--@DeptEmployeeIndependent varchar (2)=null,
	@AgreementType  varchar(2)= null,
	@Professions varchar (2)=null,
	@EmployeeSector varchar (2)=null,
	@EmployeeLicenseNumber varchar (2)=null,	
	@EmployeeExpert varchar (2)=null,		-- don't used now
	@EmployeeExpertProfession varchar (2)=null,	
	@DeptEmployeeServices varchar (2)=null,
	
	@RecepDay varchar (2)=null,	
	@RecepOpeningHour varchar (2)=null,
	@RecepClosingHour varchar (2)=null,
	@RecepTotalHours varchar (2)=null,
	@RecepValidFrom varchar (2)=null,
	@RecepValidTo varchar (2)=null,
	@RecepRemark varchar (2)=null,
	
	@IsExcelVersion varchar (2)=null,
	
	@ErrCode varchar(max) OUTPUT
-----------------------------------------
)with recompile

AS
--------------------------------------

DECLARE @NewLineChar AS CHAR(2) 
set @NewLineChar = CHAR(13) + CHAR(10)
--set @NewLineChar = ''

--set variables 
--set variables 
declare  @sql nvarchar(max)-- nvarchar type supports hebrew lenguage
declare  @sqlEnd nvarchar(max)
declare  @sqlFrom varchar(max)
declare  @sqlWhere varchar(max)

set @sqlWhere = ' ';
---------------------------
set @sql = 'SELECT distinct *  from
			(select ' + @NewLineChar;
set @sqlEnd = ') as resultTable' + @NewLineChar;

set @sqlFrom = 
'from dept  as d    
left join x_Dept_Employee ON d.deptCode = x_Dept_Employee.deptCode 
join x_Dept_Employee as xDE ON xDE.deptCode = x_Dept_Employee.deptCode
	and d.IsCommunity = 1
	AND (''' + @AdminClinicCode + ''' = ''-1'' or d.administrationCode  in (SELECT IntField FROM dbo.SplitString( ''' + @AdminClinicCode + ''')))
	AND (''' + @UnitTypeCodes + ''' = ''-1'' or d.typeUnitCode  in (SELECT IntField FROM dbo.SplitString( ''' + @UnitTypeCodes + ''')) )
	AND (''' + @CitiesCodes + ''' = ''-1'' or d.CityCode IN (SELECT IntField FROM dbo.SplitString( ''' + @CitiesCodes + ''')) )
	AND (''' + @DistrictCodes + ''' = ''-1'' or d.districtCode IN (SELECT IntField FROM dbo.SplitString( ''' + @DistrictCodes + ''')) )
	AND (''' + @AgreementType_cond + ''' = ''-1'' or x_Dept_Employee.AgreementType IN (SELECT IntField FROM dbo.SplitString(''' + @AgreementType_cond + ''' ))) 
	and (''' + @ProfessionCodes + ''' = ''-1'' or
	(	SELECT count(*) 
		FROM x_Dept_Employee_Service as xDS 
		WHERE xDS.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID						
		AND ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ProfessionCodes + ''' ))) > 0
	)
	AND (''' + @ExpertProfessionCodes + ''' = ''-1'' or
	(	SELECT count(*) 
		FROM x_Dept_Employee_Service  as xDS 
		left join EmployeeServices on x_Dept_Employee.employeeID = EmployeeServices.employeeID 
					and xDS.ServiceCode = EmployeeServices.ServiceCode
					and EmployeeServices.expProfession = 1
		WHERE xDS.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID						
		and EmployeeServices.ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ExpertProfessionCodes + ''' ))) > 0
	)
	AND (''' + @ServiceCodes + ''' = ''-1'' or
	(	SELECT count(*) 
		FROM x_Dept_Employee_Service as xDS
		WHERE xDS.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID						
		AND ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ServiceCodes + ''' ))) > 0
	)
JOIN Employee ON x_Dept_Employee.employeeID = Employee.employeeID 
AND (''' + @EmployeeSector_cond + ''' = ''-1'' or Employee.EmployeeSectorCode IN (SELECT IntField FROM dbo.SplitString(''' + @EmployeeSector_cond + ''' )) )

inner join View_DeptEmployeesCurrentStatus as v_DECStatus 
	on x_Dept_Employee.deptCode = v_DECStatus.deptCode
	and Employee.employeeID = v_DECStatus.employeeID
	and v_DECStatus.status = 1

left JOIN View_EmployeeSector on Employee.EmployeeSectorCode = View_EmployeeSector.EmployeeSectorCode

join DIC_AgreementTypes on x_Dept_Employee.AgreementType = DIC_AgreementTypes.AgreementTypeID

left join dept as dAdmin on d.administrationCode = dAdmin.deptCode    
left join dept as dDistrict on d.districtCode = dDistrict.deptCode  
left join View_UnitType as UnitType on d.typeUnitCode =  UnitType.UnitTypeCode   
left join View_SubUnitTypes as SubUnitType on d.subUnitTypeCode =  SubUnitType.subUnitTypeCode
	 and  d.typeUnitCode =  SubUnitType.UnitTypeCode 
left join Cities on d.CityCode =  Cities.CityCode
left join deptSimul on d.DeptCode = deptSimul.DeptCode 
left join dept as dSubAdmin on d.subAdministrationCode = dSubAdmin.deptCode 

cross apply rfn_GetDeptEmployeeQueueOrderDetails(d.deptCode, x_Dept_Employee.employeeID) as QueueOrderDetails
left join DeptEmployeePhones as  emplPh1  on  x_Dept_Employee.DeptEmployeeID = emplPh1.DeptEmployeeID 
	and emplPh1.PhoneType = 1 and emplPh1.phoneOrder = 1  
left join DeptEmployeePhones as emplPh2  on  x_Dept_Employee.DeptEmployeeID = emplPh2.DeptEmployeeID 
	and emplPh2.PhoneType = 1 and emplPh2.phoneOrder = 2 
left join DeptEmployeePhones as emplPh3  on  x_Dept_Employee.DeptEmployeeID = emplPh3.DeptEmployeeID  
	and emplPh3.PhoneType = 2 and emplPh3.phoneOrder = 1 
left join DeptPhones dp1 on d.DeptCode = dp1.DeptCode and dp1.PhoneType = 1 and dp1.phoneOrder = 1  
left join DeptPhones dp2 on d.DeptCode = dp2.DeptCode and dp2.PhoneType = 1 and dp2.phoneOrder = 2 
left join DeptPhones dp3 on d.DeptCode = dp3.DeptCode and dp3.PhoneType = 2 and dp3.phoneOrder = 1 
left join PopulationSectors as ps on d.populationSectorCode = ps.PopulationSectorID 

left join [dbo].View_DeptEmployeeExpertProfessions as DEExpProfessions 
	on x_Dept_Employee.deptCode = DEExpProfessions.deptCode
	and Employee.employeeID = DEExpProfessions.employeeID 

left join [dbo].View_DeptEmployeePositions as DEPositions 
	on x_Dept_Employee.deptCode = DEPositions.deptCode
	and Employee.employeeID = DEPositions.employeeID 
	
left join [dbo].View_DeptEmployeeRemarks as DERemarks
	on x_Dept_Employee.deptCode = DERemarks.deptCode
	and Employee.employeeID = DERemarks.employeeID 
		
------------ Dept and services Reception --------------
left join dbo.View_DeptEmployeeReceptions   AS DeptReception on x_Dept_Employee.deptCode = DeptReception.deptCode
	and x_Dept_Employee.employeeID = DeptReception.employeeID

where (''' + @ServiceCodes + ''' = ''-1'' or
	(	
		SELECT count(*) 
		FROM x_Dept_Employee_Service 
		WHERE x_Dept_Employee.DeptEmployeeID = x_Dept_Employee_Service.DeptEmployeeID									
		AND ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ServiceCodes + ''' ))) > 0
	)	
	 and (''' + @ProfessionCodes + ''' = ''-1'' or
	(	
		SELECT count(*) 
		FROM x_Dept_Employee_Service 
		WHERE x_Dept_Employee.DeptEmployeeID = x_Dept_Employee_Service.DeptEmployeeID									
		AND ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ProfessionCodes + ''' ))) > 0
	)' + @NewLineChar;		
----------------------------------------------------------------------------------

if(@adminClinic = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dAdmin.DeptName as AdminClinicName ,
				 isNull(dAdmin.DeptCode , -1) as AdminClinicCode '+ @NewLineChar;
	end 
	
if(@district = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
		set @sql = @sql + ' dDistrict.DeptName as DistrictName , isNull(dDistrict.deptCode , -1) as DeptCode '+ @NewLineChar;
	end	
if(@unitType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' UnitType.UnitTypeCode as UnitTypeCode , UnitType.UnitTypeName as UnitTypeName '+ @NewLineChar;
	end
if(@subUnitType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
		' subUnitType.subUnitTypeCode as subUnitTypeCode , subUnitType.subUnitTypeName as subUnitTypeName '+ 
		@NewLineChar;
	end 
	
if( @ClinicName= '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'd.DeptName as ClinicName ' + @NewLineChar;	
	end

if( @ClinicCode= '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' d.deptCode as ClinicCode ' + @NewLineChar;	
	end

if(@simul = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'deptSimul.Simul228 as Code228 '+ @NewLineChar;
	end 

if(@subAdminClinic = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'dSubAdmin.DeptCode as SubAdminClinicCode , dSubAdmin.DeptName as SubAdminClinicName '+ @NewLineChar;
	end 			
	
if(@city = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);			
		set @sql = @sql + ' Cities.CityCode as CityCode, Cities.CityName as CityName'+ @NewLineChar;
	end

if (@address = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'dbo.GetAddress(d.deptCode) as ClinicAddress '+ @NewLineChar;
	end	
	
if(@Phone1 = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp1.prePrefix, dp1.Prefix,dp1.Phone, dp1.extension ) as Phone1 '+ @NewLineChar;;
end

if(@Phone2 = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp2.prePrefix, dp2.Prefix, dp2.Phone, dp2.extension) as Phone2 '+ @NewLineChar;;
end 

if(@Fax = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp3.prePrefix, dp3.Prefix, dp3.Phone, dp3.extension) as Fax '+ @NewLineChar;
end

if(@Email = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' d.Email as Email '+ @NewLineChar;
	end

if(@MangerName = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dbo.fun_getManagerName(d.deptCode) as MangerName '+ @NewLineChar;							   
	end

if(@adminMangerName = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dbo.fun_getAdminManagerName(d.deptCode) as AdminMangerName '+ @NewLineChar;
	end

if(@sector = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' ps.PopulationSectorID as SectorCode ,ps.PopulationSectorDescription as SectorName'+ @NewLineChar;
	end 	 	

if(@EmployeeName = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'Employee.firstName as EmployeeFirstName, Employee.lastName as EmployeeLastName'+ @NewLineChar;
	end
	
if(@EmployeeID = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.EmployeeID as EmployeeID '+ @NewLineChar;
	end
	
if(@EmployeeLicenseNumber = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.licenseNumber as EmployeeLicenseNumber '+ @NewLineChar;
	end

if(@DeptEmployeeEmail = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'Employee.email as EmployeeEmail'+ @NewLineChar;
	end

if(@EmployeeSector = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.EmployeeSectorCode as EmployeeSectorCode,  
		View_EmployeeSector.EmployeeSectorDescription as EmployeeSectorDescription'+ @NewLineChar;
	end	


if(@Position = '1' ) 
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
			' DEPositions.PositionDescriptions as PositionDescription
			 ,DEPositions.PositionCodes as PositionCode' 
		+ @NewLineChar;
	end

if(@EmployeeExpertProfession = '1') 
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql +
			' DEExpProfessions.ExpertProfessionDescriptions as ExpertProfessionDescription
			 ,DEExpProfessions.ExpertProfessionCodes as ExpertProfessionCode' 
		+ @NewLineChar;
	end

if(@DeptEmployeeRemark = '1' )  -- changed
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
			' DERemarks.RemarkDescriptions as EmployeeRemarkDescription
			,DERemarks.RemarkCodes as EmployeeRemarkID'
		+ @NewLineChar;
	end



if(@DeptEmployeePhone = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'case when x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1
		then dbo.fun_ParsePhoneNumberWithExtension(dp1.prePrefix, dp1.Prefix, dp1.Phone, dp1.Extension )
		else dbo.fun_ParsePhoneNumberWithExtension(emplPh1.prePrefix, emplPh1.Prefix, emplPh1.Phone, emplPh1.Extension )end as EmployeePhone1 '+ @NewLineChar;;

		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'case when x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1
		then dbo.fun_ParsePhoneNumberWithExtension(dp2.prePrefix, dp2.Prefix, dp2.Phone, dp2.Extension )
		else dbo.fun_ParsePhoneNumberWithExtension(emplPh2.prePrefix, emplPh2.Prefix, emplPh2.Phone, emplPh2.Extension )end as EmployeePhone2 '+ @NewLineChar;;
	end

if(@DeptEmployeeFax = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'case when x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1
		then dbo.fun_ParsePhoneNumberWithExtension(dp3.prePrefix, dp3.Prefix, dp3.Phone, dp3.Extension ) 
		else dbo.fun_ParsePhoneNumberWithExtension(emplPh3.prePrefix, emplPh3.Prefix, emplPh3.Phone, emplPh3.Extension )end as EmployeeFax '+ @NewLineChar;;
	end

if(@AgreementType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql 
		+ 'DIC_AgreementTypes.AgreementTypeID as AgreementTypeCode,
		 DIC_AgreementTypes.AgreementTypeDescription as AgreementTypeDescription '
		+ @NewLineChar;
	end	

------------ @DeptEmployeeServices -------------------------------------------------------------------------------------

if(@DeptEmployeeServices = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + '[DeptReception].serviceDescription  as serviceDescription,
	 [DeptReception].serviceCode  as serviceCode  ' + @NewLineChar;
end 

------------ @Professions -------------------------------------------------------

if(@Professions = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + '[DeptReception].ProfessionDescription  as ProfessionDescription,
	 [DeptReception].ProfessionCode  as ProfessionCode  ' + @NewLineChar;
end 


------------ RecepDay ------------------------------------------------------------
if(@RecepDay = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' [DeptReception].ReceptionDayName  as ReceptionDayName ' + @NewLineChar;
	end 

----------- RecepOpeningHour --------------------------------------------------
if(@RecepOpeningHour = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' [DeptReception].openingHour  as openingHour ' + @NewLineChar;
end 

----------- RecepClosingHour --------------------------------------------------
if(@RecepClosingHour = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' [DeptReception].closingHour  as closingHour ' + @NewLineChar;
end 

----------- RecepTotalHours --------------------------------------------------
if(@RecepTotalHours = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' [DeptReception].totalHours  as totalHours ' + @NewLineChar;
end 

----------- RecepValidFrom --------------------------------------------------
if(@RecepValidFrom = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' CONVERT(varchar(10), [DeptReception].validFrom, 103)  as  validFrom  ' + @NewLineChar;
end 

----------- RecepValidTo --------------------------------------------------
if(@RecepValidTo = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' CONVERT(varchar(10), [DeptReception].validTo, 103) as  validTo ' + @NewLineChar;
end 

----------- RecepRemark --------------------------------------------------
if(@RecepRemark = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' [DeptReception].remarkText  as RecepRemark ' + @NewLineChar;
end 


--=================================================================

set @sql = @sql + @sqlFrom + @sqlWhere + @sqlEnd

print '--------- sql query full ----------'
print '--===== @sql string length = ' + str(len(@sql))
Exec rpc_HelperLongPrint @sql 

EXECUTE sp_executesql @sql 
SET @ErrCode = @sql 
RETURN 

GO
GRANT EXEC ON [dbo].rprt_DeptEmployeeReceptions TO PUBLIC
GO
-------------
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_Employees')
	BEGIN
		DROP  Procedure  dbo.rprt_Employees
	END

GO

CREATE Procedure dbo.rprt_Employees
(
	 @DistrictCodes varchar(max)=null,
	 @AdminClinicCode varchar(max)=null,	
	 @CitiesCodes varchar(max)=null,
	 @EmployeeSector_cond varchar(max)=null,
	 @UnitTypeCodes varchar(max)=null,
	 @SubUnitTypeCodes varchar(max)=null,
	 @ServiceCodes varchar(max)=null,
	 @ProfessionCodes varchar(max)=null,
	 @PositionCodes varchar(max)=null,
	 @ExpertProfessionCodes varchar(max)=null,
	 --@EmployeeIndependent_cond varchar(max)=null, -- Dept employee Independent condition
	 @AgreementType_cond varchar(max)=null,
	 @EmployeeLanguage_cond varchar(max)=null, 
	 @EmployeeSex_cond varchar(max)=null, 
	 @StatusCodes varchar(max)=null,
	 @DeptEmployeeStatusCodes varchar(max)=null,
	 
	@district varchar (2)= null,	
	@ClinicDistrict varchar (2)= null,
	@adminClinic varchar (2) = null,		 
	@ClinicName varchar (2)=null,
	@ClinicCode varchar (2)=null,
	@simul varchar (2)=null,
	@city varchar (2)=null,
	@address varchar (2)=null,
	@QueueOrderDescription varchar (2)=null, --  Dept QueueOrderDescription 
	
	@EmployeeName varchar (2)=null,
	@EmployeeID varchar (2)=null,
	@EmployeeSector varchar (2)=null,
	@EmployeeLicenseNumber varchar (2)=null,	
	@EmployeeSex varchar(2)=null, 
	@DeptEmployeePhone varchar (2)=null,
	@DeptEmployeeFax varchar (2)=null,
	@EmployeeEmail varchar (2)=null,
	@ShowEmployeeEmailInInternet varchar (2)=null,
	@EmployeeHomePhone varchar (2)=null,
	@EmployeeCellPhone varchar (2)=null,
	--@EmployeeIndependent varchar(2)=null,  -- Dept employee Independent
	@AgreementType  varchar(2)= null,
	@EmployeePosition varchar (2)=null,
	@EmployeeProfessions varchar (2)=null,
	@EmployeeExpertProfession varchar (2)=null,	
	@EmployeeServices varchar (2)=null,
	@DeptEmployeeRemark varchar (2)=null,
	@EmployeeDegree varchar(2)= null,
	@EmployeeStatus varchar(2)= null,
	@DeptEmployeeStatus varchar(2)= null,
	
	@IsExcelVersion varchar (2)=null,
	@ErrCode VARCHAR(4000) OUTPUT
-----------------------------------------
)with recompile

AS
--------------------------------------

DECLARE @NewLineChar AS CHAR(2) 
set @NewLineChar = CHAR(13) + CHAR(10)

--set variables 
declare  @sql nvarchar(max)-- nvarchar type supports hebrew lenguage
declare  @sqlEnd nvarchar(max)
declare  @sqlFrom varchar(max)
declare  @sqlWhere varchar(max)

declare  @stringNotNeeded  nvarchar(max)
---------------------------
set @sql = 'SELECT distinct *  from
			(select ' + @NewLineChar;
set @sqlEnd = ') as resultTable' + @NewLineChar;
set @sqlWhere = ' ';


set @sqlFrom = 'from Employee 
join Employee as Emp on Employee.employeeID = Emp.employeeID 
 AND (''' + @DistrictCodes + ''' = ''-1'' or Employee.primaryDistrict IN (SELECT IntField FROM dbo.SplitString( ''' + @DistrictCodes + ''')) )
 AND (''' + @EmployeeSector_cond + ''' = ''-1'' or Employee.EmployeeSectorCode IN (SELECT IntField FROM dbo.SplitString(''' + @EmployeeSector_cond + ''' )) )
 AND (''' + @EmployeeSex_cond + ''' = ''-1'' or Employee.Sex IN (SELECT IntField FROM dbo.SplitString(''' + @EmployeeSex_cond + ''' )))
 AND (''' + @StatusCodes + ''' = ''-1'' or Employee.active IN (SELECT IntField FROM dbo.SplitString( ''' + @StatusCodes + ''')) )
	and (''' + @PositionCodes + ''' = ''-1'' or
	(	SELECT count(*) 
		FROM x_Dept_Employee_Position 
		inner join x_Dept_Employee xde
		on x_Dept_Employee_Position.DeptEmployeeID = xde.DeptEmployeeID
		WHERE Employee.employeeID = xde.employeeID	
		AND positionCode IN (SELECT IntField FROM dbo.SplitString( ''' + @PositionCodes + ''' ))) > 0
	)
	AND (''' + @ProfessionCodes + ''' = ''-1'' or
	(	SELECT count(*) 
		FROM EmployeeServices 
		WHERE Employee.employeeID = EmployeeServices.employeeID								
		AND EmployeeServices.serviceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ProfessionCodes + ''' ))) > 0
	)
	AND (''' + @ExpertProfessionCodes + ''' = ''-1'' or
	(	SELECT count(*) 
		FROM  EmployeeServices 
		WHERE Employee.employeeID = EmployeeServices.employeeID 	and EmployeeServices.expProfession = 1
		and EmployeeServices.serviceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ExpertProfessionCodes + ''' ))) > 0
	)
	AND (''' + @ServiceCodes + ''' = ''-1'' or
	(	SELECT count(*) 
		FROM EmployeeServices 
		WHERE Employee.employeeID = EmployeeServices.employeeID									
		AND EmployeeServices.ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ServiceCodes + ''' ))) > 0
	)
	

left join x_Dept_Employee ON x_Dept_Employee.employeeID = Employee.employeeID 
left join dept  as d   on d.deptCode = x_Dept_Employee.deptCode
left join View_DeptEmployeesCurrentStatus as v_DECStatus 
	on x_Dept_Employee.deptCode = v_DECStatus.deptCode
	and Employee.employeeID = v_DECStatus.employeeID
	 
join Employee as Emp2 on Employee.employeeID = Emp2.employeeID
	 AND (''' + @AdminClinicCode + ''' = ''-1'' or d.administrationCode  in (SELECT IntField FROM dbo.SplitString( ''' + @AdminClinicCode + ''')))
	 AND (''' + @UnitTypeCodes + ''' = ''-1'' or d.typeUnitCode  in (SELECT IntField FROM dbo.SplitString( ''' + @UnitTypeCodes + ''')) )
	 AND (''' + @SubUnitTypeCodes + ''' = ''-1'' or d.subUnitTypeCode in (SELECT IntField FROM dbo.SplitString( ''' + @SubUnitTypeCodes + ''')) )
	 AND (''' + @CitiesCodes + ''' = ''-1'' or d.CityCode IN (SELECT IntField FROM dbo.SplitString( ''' + @CitiesCodes + ''')) )
	 AND (''' + @AgreementType_cond + ''' = ''-1'' or x_Dept_Employee.AgreementType IN (SELECT IntField FROM dbo.SplitString(''' + @AgreementType_cond + ''' ))) 
	 AND (''' + @DeptEmployeeStatusCodes + ''' = ''-1'' or  v_DECStatus.status IN (SELECT IntField FROM dbo.SplitString( ''' + @DeptEmployeeStatusCodes + ''')) )
	 

join DIC_ActivityStatus as EmpStatus on EmpStatus.Status = Employee.active 
join DIC_ActivityStatus as DeptEmpStatus on DeptEmpStatus.Status = v_DECStatus.Status
join DIC_AgreementTypes on x_Dept_Employee.AgreementType = DIC_AgreementTypes.AgreementTypeID

left join EmployeeLanguages on EmployeeLanguages.EmployeeID = Employee.employeeID
join Employee as Emp3 on Employee.employeeID = Emp3.employeeID
 AND (''' + @EmployeeLanguage_cond + ''' = ''-1'' or EmployeeLanguages.LanguageCode IN (SELECT IntField FROM dbo.SplitString( ''' + @EmployeeLanguage_cond + ''')) )
left join languages on languages.languageCode = EmployeeLanguages.languageCode 

left join dept as dAdmin on d.administrationCode = dAdmin.deptCode 

left join dept as dDistrict on Employee.primaryDistrict = dDistrict.deptCode 
left join dept as deptDistrict on d.DistrictCode = deptDistrict.deptCode 

left join View_UnitType as UnitType on d.typeUnitCode =  UnitType.UnitTypeCode   
left join View_SubUnitTypes as SubUnitType on d.subUnitTypeCode =  SubUnitType.subUnitTypeCode and  d.typeUnitCode =  SubUnitType.UnitTypeCode 
left join deptSimul on d.DeptCode = deptSimul.DeptCode 
left join Cities on d.CityCode =  Cities.CityCode  
left join PopulationSectors as ps on d.populationSectorCode = ps.PopulationSectorID -- 
cross apply rfn_GetDeptEmployeeQueueOrderDetails(x_Dept_Employee.deptCode, x_Dept_Employee.employeeID) as QueueOrderDetails

left JOIN View_EmployeeSector on Employee.EmployeeSectorCode = View_EmployeeSector.EmployeeSectorCode
left JOIN DIC_EmployeeDegree on Employee.DegreeCode = DIC_EmployeeDegree.DegreeCode

left join DeptEmployeePhones as  emplPh1  on  x_Dept_Employee.DeptEmployeeID = emplPh1.DeptEmployeeID 
	and x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic <> 1 
	and emplPh1.PhoneType = 1 and emplPh1.phoneOrder = 1  

left join DeptEmployeePhones as emplPh2  on  x_Dept_Employee.DeptEmployeeID = emplPh2.DeptEmployeeID 
	and x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic <> 1 
	and emplPh2.PhoneType = 1 and emplPh2.phoneOrder = 2 

left join DeptEmployeePhones as emplPh3  on  x_Dept_Employee.DeptEmployeeID = emplPh3.DeptEmployeeID 
	and x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic <> 1 
	and emplPh3.PhoneType = 2 and emplPh3.phoneOrder = 1 

left join DeptPhones as  deptPh1  
	on  d.deptCode = deptPh1.deptCode 
	and x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1 
	and deptPh1.PhoneType = 1 and deptPh1.phoneOrder = 1  

left join DeptPhones as deptPh2  
	on  d.deptCode = deptPh2.deptCode 
	and x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1 
	and deptPh2.PhoneType = 1 and deptPh2.phoneOrder = 2 

left join DeptPhones as deptPh3  
	on  d.deptCode = deptPh3.deptCode 
	and x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1 
	and deptPh3.PhoneType = 2 and deptPh3.phoneOrder = 1 

left join EmployeePhones as  EmployeePhones1  on  Employee.employeeID = EmployeePhones1.employeeID 
and EmployeePhones1.PhoneType = 1 and EmployeePhones1.phoneOrder = 1  
left join EmployeePhones as EmployeePhones2  on Employee.employeeID = EmployeePhones2.employeeID 
and EmployeePhones2.PhoneType = 3 and EmployeePhones2.phoneOrder = 1

left join [dbo].View_EmployeeProfessions as DEProfessions	 --View_DeptEmployeeProfessions
	--on x_Dept_Employee.deptCode = DEProfessions.deptCode
	on Employee.employeeID = DEProfessions.employeeID 
	
left join [dbo].View_EmployeeExpertProfessions as DEExpProfessions --View_DeptEmployeeExpertProfessions
	--on x_Dept_Employee.deptCode = DEExpProfessions.deptCode
	on Employee.employeeID = DEExpProfessions.employeeID 

left join [dbo].View_DeptEmployeePositions as DEPositions 
	on x_Dept_Employee.deptCode = DEPositions.deptCode
	and Employee.employeeID = DEPositions.employeeID 
	
left join [dbo].View_EmployeeServices as DEServices --View_DeptEmployeeServices
	--on x_Dept_Employee.deptCode = DEServices.deptCode
	on Employee.employeeID = DEServices.employeeID 
	
left join [dbo].View_DeptEmployeeRemarks as DERemarks
	on x_Dept_Employee.deptCode = DERemarks.deptCode
	and Employee.employeeID = DERemarks.employeeID 
'

if(@district = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
		set @sql = @sql + ' dDistrict.DeptName as DistrictName , isNull(dDistrict.deptCode , -1) as DeptCode '
		+ @NewLineChar;
	end
	
if(@ClinicDistrict = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
		set @sql = @sql + 'deptDistrict.DeptName as ClinicDistrictName , isNull(deptDistrict.deptCode , -1) as ClinicDistrictCode '
		+ @NewLineChar;
	end	

if(@adminClinic = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dAdmin.DeptName as AdminClinicName ,
				 dAdmin.DeptCode as AdminClinicCode '+ @NewLineChar;
	end 	


--------------@ClinicName-------------------------------------
if( @ClinicName= '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'd.DeptName as ClinicName ' + @NewLineChar;	
end
--------------@ClinicCode-------------------------------------
if( @ClinicCode= '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' d.deptCode as ClinicCode ' + @NewLineChar;	
end
---------------Simul----------------------------------------------------------------------------------------
if(@simul = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'deptSimul.Simul228 as Code228 '+ @NewLineChar;
end 

if (@AgreementType = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 
			+ 'DIC_AgreementTypes.AgreementTypeID as AgreementTypeCode,
			DIC_AgreementTypes.AgreementTypeDescription as AgreementTypeDescription '
		+ @NewLineChar;
		
end

if(@city = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);			
		set @sql = @sql + ' Cities.CityCode as CityCode, Cities.CityName as CityName'+ @NewLineChar;
	end

if (@address = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'dbo.GetAddress(d.deptCode) as ClinicAddress '+ @NewLineChar;
	end

if(@EmployeeName = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'Employee.firstName as EmployeeFirstName, Employee.lastName as EmployeeLastName'+ @NewLineChar;
	end
	
if(@EmployeeID = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.EmployeeID as EmployeeID '+ @NewLineChar;
	end
	
if(@EmployeeLicenseNumber = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.licenseNumber as EmployeeLicenseNumber '+ @NewLineChar;
	end

if(@EmployeeSector = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.EmployeeSectorCode as EmployeeSectorCode,  
		View_EmployeeSector.EmployeeSectorDescription as EmployeeSectorDescription'+ @NewLineChar;
	end	


if(@EmployeePosition = '1' ) 
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
			' DEPositions.PositionDescriptions as PositionDescription
			 ,DEPositions.PositionCodes as PositionCode' 
		+ @NewLineChar;
	end
	
if(@EmployeeProfessions = '1' ) 
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql +
			' DEProfessions.ProfessionDescriptions as ProfessionDescription
			 ,DEProfessions.ProfessionCodes as ProfessionCode ' 
			+ @NewLineChar;
	end

if(@EmployeeExpertProfession = '1') 
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql +
			' DEExpProfessions.ExpertProfessionDescriptions as ExpertProfessionDescription
			 ,DEExpProfessions.ExpertProfessionCodes as ExpertProfessionCode' 
		+ @NewLineChar;
	end

if(@EmployeeServices = '1' ) 
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
			' DEServices.ServiceDescriptions as ServiceDescription 
			,DEServices.ServiceCodes as ServiceCode' 
		+ @NewLineChar;
	end	


if(@DeptEmployeeRemark = '1' )  -- changed
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
			' DERemarks.RemarkDescriptions as EmployeeRemarkDescription
			,DERemarks.RemarkCodes as EmployeeRemarkID'
		+ @NewLineChar;
	end

	

if (@EmployeeSex = '1')
begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'case when Employee.Sex = 1 then ''זכר'' when Employee.Sex = 2 then ''נקבה'' else ''לא מוגדר'' end  as EmployeeSex'+ @NewLineChar;
end
if(@EmployeeDegree = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' DIC_EmployeeDegree.degreeName as EmployeeDegree, DIC_EmployeeDegree.degreeCode as EmployeeDegreeCode '+ @NewLineChar;
	end
if(@EmployeeStatus = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' EmpStatus.Status as StatusCode, EmpStatus.StatusDescription as StatusDescription '+ @NewLineChar;
	end	
if(@DeptEmployeeStatus = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' DeptEmpStatus.Status as DeptEmployeeStatusCode, DeptEmpStatus.StatusDescription as DeptEmployeeStatusDescription '+ @NewLineChar;
	end	
if(@DeptEmployeePhone = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'case when x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1
	then dbo.fun_ParsePhoneNumberWithExtension(deptPh1.prePrefix, deptPh1.Prefix, deptPh1.Phone, deptPh1.Extension )
	else dbo.fun_ParsePhoneNumberWithExtension(emplPh1.prePrefix, emplPh1.Prefix, emplPh1.Phone, emplPh1.Extension )end as EmployeePhone1 '+ @NewLineChar;;

	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'case when x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1
	then dbo.fun_ParsePhoneNumberWithExtension(deptPh2.prePrefix, deptPh2.Prefix, deptPh2.Phone, deptPh2.Extension )
	else dbo.fun_ParsePhoneNumberWithExtension(emplPh2.prePrefix, emplPh2.Prefix, emplPh2.Phone, emplPh2.Extension )end as EmployeePhone2 '+ @NewLineChar;;
end

if(@DeptEmployeeFax = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'case when x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1
	then dbo.fun_ParsePhoneNumberWithExtension(deptPh3.prePrefix, deptPh3.Prefix, deptPh3.Phone, deptPh3.Extension ) 
	else dbo.fun_ParsePhoneNumberWithExtension(emplPh3.prePrefix, emplPh3.Prefix, emplPh3.Phone, emplPh3.Extension )end as EmployeeFax '+ @NewLineChar;;
end	

if(@QueueOrderDescription = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql 
	+ ' QueueOrderDetails. QueueOrderDescription as QueueOrderDescription '
	+ @NewLineChar 
	+ ' ,QueueOrderDetails.QueueOrderClinicTelephone as QueueOrderClinicTelephone '
	+ @NewLineChar 
	+ ' ,QueueOrderDetails.QueueOrderSpecialTelephone as QueueOrderSpecialTelephone '
	+ @NewLineChar
	+ ' ,QueueOrderDetails.QueueOrderTelephone2700 as QueueOrderTelephone2700 '
	+ @NewLineChar
	+ ' ,QueueOrderDetails.QueueOrderInternet as QueueOrderInternet '
	+ @NewLineChar
end	

--------- homePhone ---------------------------------------------------------------
if(@EmployeeHomePhone = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(EmployeePhones1.prePrefix, EmployeePhones1.Prefix,EmployeePhones1.Phone, EmployeePhones1.extension ) as EmployeePrivatePhone1, 
				case when EmployeePhones1.isUnlisted = 1 then ''כן'' else ''לא'' end as EmployeePrivatePhone1_isUnlisted'
				+ @NewLineChar;
end

---------- cellPhone --------------------------------------------------------------------------------
if(@EmployeeCellPhone = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(EmployeePhones2.prePrefix, EmployeePhones2.Prefix, EmployeePhones2.Phone, EmployeePhones2.extension) as EmployeePrivatePhone2, 
			case when EmployeePhones2.isUnlisted = 1 then ''כן'' else ''לא'' end as EmployeePrivatePhone2_isUnlisted'
			+ @NewLineChar;
end 
--=================================================================
set @sql = @sql + @sqlFrom 
+ @sqlWhere
 + @sqlEnd

print '--------- sql query full ----------'
print '--===== @sql string length = ' + str(len(@sql))
Exec rpc_HelperLongPrint @sql 


EXECUTE sp_executesql @sql 
SET @ErrCode = @sql 
RETURN 

GO
GRANT EXEC ON [dbo].rprt_Employees TO PUBLIC
GO
------------
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_EmployeeReceptions')
	BEGIN
		DROP  Procedure  dbo.rprt_EmployeeReceptions
	END

GO

CREATE Procedure [dbo].rprt_EmployeeReceptions
(
	 @DistrictCodes varchar(max)=null,
	 @AdminClinicCode varchar(max)=null,	
	 @CitiesCodes varchar(max)=null,
	 @EmployeeSector_cond varchar(max)=null,
	 @UnitTypeCodes varchar(max)=null,
	 @SubUnitTypeCodes varchar(max)=null,
	 @ServiceCodes varchar(max)=null,
	 @ProfessionCodes varchar(max)=null,
	 @PositionCodes varchar(max)=null,
	 @ExpertProfessionCodes varchar(max)=null,
	 --@EmployeeIndependent_cond varchar(max)=null, -- todo:change to employee Independent 
	 @AgreementType_cond varchar(max)=null,
	 @EmployeeSex_cond varchar(max)=null, 
	 @ValidFrom_cond varchar(max)=null,
	 @ValidTo_cond varchar(max)=null,
	 
	@district varchar (2)= null,
	@adminClinic varchar (2) = null,		
	@ClinicName varchar (2)=null,
	@ClinicCode varchar (2)=null,
	@simul varchar (2)=null,
	--@city varchar (2)=null,
	
	@EmployeeName varchar (2)=null,
	@EmployeeID varchar (2)=null,
	@EmployeeSector varchar (2)=null,
	@EmployeeLicenseNumber varchar (2)=null,	
	@EmployeeSex varchar(2)=null, 
	@EmployeePosition varchar (2)=null,
	@EmployeeProfessions varchar (2)=null,
	@EmployeeExpertProfession varchar (2)=null,	
	@EmployeeServices varchar (2)=null,
	
	@RecepDay varchar (2)=null,	
	@RecepOpeningHour varchar (2)=null,
	@RecepClosingHour varchar (2)=null,
	@RecepTotalHours varchar (2)=null,
	@RecepValidFrom varchar (2)=null,
	@RecepValidTo varchar (2)=null,
	@RecepRemark varchar (2)=null,
	
	@IsExcelVersion varchar (2)=null,
	@ErrCode VARCHAR(max) OUTPUT
-----------------------------------------
)with recompile

AS
--------------------------------------

DECLARE @NewLineChar AS CHAR(2) 
set @NewLineChar = CHAR(13) + CHAR(10)
--set @NewLineChar = ''

--set variables 
declare  @sql nvarchar(max)-- nvarchar type supports hebrew lenguage
declare  @sqlEnd nvarchar(max)
declare  @sqlFrom varchar(max)
--declare  @sqlWhere varchar(max)

declare  @stringNotNeeded  nvarchar(max)
---------------------------

set @sql = 'SELECT distinct *  from
			(select ' + @NewLineChar;
set @sqlEnd = ') as resultTable '
				+'order by EmployeeLastName' + @NewLineChar;
--set @sqlWhere = ' ';


set @sqlFrom = 'from Employee 
join Employee as Emp on Employee.employeeID = Emp.employeeID 
 AND (''' + @DistrictCodes + ''' = ''-1'' or Employee.primaryDistrict IN (SELECT IntField FROM dbo.SplitString( ''' + @DistrictCodes + ''')) )
 AND (''' + @EmployeeSector_cond + ''' = ''-1'' or Employee.EmployeeSectorCode IN (SELECT IntField FROM dbo.SplitString(''' + @EmployeeSector_cond + ''' )) )
 AND (''' + @EmployeeSex_cond + ''' = ''-1'' or Employee.Sex IN (SELECT IntField FROM dbo.SplitString(''' + @EmployeeSex_cond + ''' )))
	and (''' + @PositionCodes + ''' = ''-1'' or
	(	SELECT count(*) 
		FROM x_Dept_Employee_Position 
		inner join x_Dept_Employee xde
		on x_Dept_Employee_Position.DeptEmployeeID = xde.DeptEmployeeID
		WHERE Employee.employeeID = xde.employeeID	
		AND positionCode IN (SELECT IntField FROM dbo.SplitString( ''' + @PositionCodes + ''' ))) > 0
	)
	AND (''' + @ProfessionCodes + ''' = ''-1'' or
	(	SELECT count(*) 
		FROM EmployeeServices 
		WHERE Employee.employeeID = EmployeeServices.employeeID								
		AND EmployeeServices.ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ProfessionCodes + ''' ))) > 0
	)
	AND (''' + @ExpertProfessionCodes + ''' = ''-1'' or
	(	SELECT count(*) 
		FROM  EmployeeServices 
		WHERE Employee.employeeID = EmployeeServices.employeeID 	and EmployeeServices.expProfession = 1
		and EmployeeServices.ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ExpertProfessionCodes + ''' ))) > 0
	)
	AND (''' + @ServiceCodes + ''' = ''-1'' or
	(	SELECT count(*) 
		FROM EmployeeServices 
		WHERE Employee.employeeID = EmployeeServices.employeeID									
		AND EmployeeServices.ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ServiceCodes + ''' ))) > 0
	)
	
	
left join x_Dept_Employee ON x_Dept_Employee.employeeID = Employee.employeeID 
  
left join dept  as d   on d.deptCode = x_Dept_Employee.deptCode
inner join Employee as Emp2 on Employee.employeeID = Emp2.employeeID
	and d.IsCommunity = 1
	AND (''' + @AdminClinicCode + ''' = ''-1'' or d.administrationCode  in (SELECT IntField FROM dbo.SplitString( ''' + @AdminClinicCode + ''')))
	AND (''' + @UnitTypeCodes + ''' = ''-1'' or d.typeUnitCode  in (SELECT IntField FROM dbo.SplitString( ''' + @UnitTypeCodes + ''')) )
	AND (''' + @SubUnitTypeCodes + ''' = ''-1'' or d.subUnitTypeCode in (SELECT IntField FROM dbo.SplitString( ''' + @SubUnitTypeCodes + ''')) )
	AND (''' + @CitiesCodes + ''' = ''-1'' or d.CityCode IN (SELECT IntField FROM dbo.SplitString( ''' + @CitiesCodes + ''')) )
	AND (''' + @AgreementType_cond + ''' = ''-1'' or x_Dept_Employee.AgreementType IN (SELECT IntField FROM dbo.SplitString(''' + @AgreementType_cond + ''' ))) 
	
inner join View_DeptEmployeesCurrentStatus as v_DECStatus 
	on x_Dept_Employee.deptCode = v_DECStatus.deptCode
	and Employee.employeeID = v_DECStatus.employeeID
	and v_DECStatus.status = 1

left join dept as dAdmin on d.administrationCode = dAdmin.deptCode 
left join dept as dDistrict on Employee.primaryDistrict = dDistrict.deptCode 
left join View_UnitType as UnitType on d.typeUnitCode =  UnitType.UnitTypeCode   
left join View_SubUnitTypes as SubUnitType on d.subUnitTypeCode =  SubUnitType.subUnitTypeCode and  d.typeUnitCode =  SubUnitType.UnitTypeCode 
left join deptSimul on d.DeptCode = deptSimul.DeptCode 
left join Cities on d.CityCode =  Cities.CityCode  
left join PopulationSectors as ps on d.populationSectorCode = ps.PopulationSectorID -- 
left join DIC_QueueOrder ON d.QueueOrder = DIC_QueueOrder.QueueOrder
left join x_Dept_Employee_EmployeeRemarks on  x_Dept_Employee.DeptEmployeeID = x_Dept_Employee_EmployeeRemarks.DeptEmployeeID	
left join EmployeeRemarks on x_Dept_Employee_EmployeeRemarks.EmployeeRemarkID = EmployeeRemarks.EmployeeRemarkID 
INNER JOIN View_EmployeeSector on Employee.EmployeeSectorCode = View_EmployeeSector.EmployeeSectorCode
--------------------
left join DeptEmployeePhones as  emplPh1  on  x_Dept_Employee.DeptEmployeeID = emplPh1.DeptEmployeeID 
	and emplPh1.PhoneType = 1 and emplPh1.phoneOrder = 1  
left join DeptEmployeePhones as emplPh2  on  x_Dept_Employee.DeptEmployeeID = emplPh2.DeptEmployeeID 
	and emplPh2.PhoneType = 1 and emplPh2.phoneOrder = 2 
left join DeptEmployeePhones as emplPh3  on  x_Dept_Employee.DeptEmployeeID = emplPh3.DeptEmployeeID  
	and emplPh3.PhoneType = 2 and emplPh3.phoneOrder = 1 
--------------------
left join EmployeePhones as  EmployeePhones1  on  Employee.employeeID = EmployeePhones1.employeeID 
	and EmployeePhones1.PhoneType = 1 and EmployeePhones1.phoneOrder = 1  
left join EmployeePhones as EmployeePhones2  on Employee.employeeID = EmployeePhones2.employeeID 
	and EmployeePhones2.PhoneType = 3 and EmployeePhones2.phoneOrder = 1 
 
left join dbo.View_DeptEmployeeReceptions   AS V_DEReception on x_Dept_Employee.deptCode = V_DEReception.deptCode
	and x_Dept_Employee.employeeID = V_DEReception.employeeID 
join Employee as Emp3 on Employee.employeeID = Emp3.employeeID 
	 and[dbo].rfn_CheckExpirationDate_str
	(CONVERT(varchar(10), V_DEReception.validFrom, 20),
	 CONVERT(varchar(10), V_DEReception.validTo, 20), '''
	 + isNull(@ValidFrom_cond, 'null') + ''','''
	 + IsNull(@ValidTo_cond, 'null')+ ''') = 1
	 
left join [dbo].View_EmployeeExpertProfessions as DEExpProfessions --View_DeptEmployeeExpertProfessions
	--on x_Dept_Employee.deptCode = DEExpProfessions.deptCode
	on Employee.employeeID = DEExpProfessions.employeeID 

left join [dbo].View_DeptEmployeePositions as DEPositions 
	on x_Dept_Employee.deptCode = DEPositions.deptCode
	and Employee.employeeID = DEPositions.employeeID 
 ' 
 
if(@EmployeeName = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'Employee.firstName as EmployeeFirstName, Employee.lastName as EmployeeLastName'+ @NewLineChar;
	end
	
if(@EmployeeID = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.EmployeeID as EmployeeID '+ @NewLineChar;
	end
	
if(@EmployeeLicenseNumber = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.licenseNumber as EmployeeLicenseNumber '+ @NewLineChar;
	end

if(@EmployeeSector = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.EmployeeSectorCode as EmployeeSectorCode,  
		View_EmployeeSector.EmployeeSectorDescription as EmployeeSectorDescription'+ @NewLineChar;
	end	


if(@district = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
		set @sql = @sql + ' dDistrict.DeptName as DistrictName , isNull(dDistrict.deptCode , -1) as DeptCode '+ @NewLineChar;
	end
	
if(@adminClinic = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dAdmin.DeptName as AdminClinicName ,
				 dAdmin.DeptCode as AdminClinicCode '+ @NewLineChar;
	end 

--------------@ClinicName-------------------------------------
if( @ClinicName= '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'd.DeptName as ClinicName ' + @NewLineChar;	
end
--------------@ClinicCode-------------------------------------
if( @ClinicCode= '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' d.deptCode as ClinicCode ' + @NewLineChar;	
end
---------------Simul----------------------------------------------------------------------------------------
if(@simul = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'deptSimul.Simul228 as Code228 '+ @NewLineChar;
end 

if(@EmployeePosition = '1' )
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
			' DEPositions.PositionDescriptions as PositionDescription
			 ,DEPositions.PositionCodes as PositionCode' 
		+ @NewLineChar;
	end
	
if(@EmployeeExpertProfession = '1')
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql +
			' DEExpProfessions.ExpertProfessionDescriptions as ExpertProfessionDescription
			 ,DEExpProfessions.ExpertProfessionCodes as ExpertProfessionCode' 
		+ @NewLineChar;
	end

	
if (@EmployeeSex = '1')
begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'case when Employee.Sex = 1 then ''זכר'' when Employee.Sex = 2 then ''נקבה'' else ''לא מוגדר'' end  as EmployeeSex'+ @NewLineChar;
end


------------ @DeptEmployeeServices -------------------------------------------------------------------------------------

if(@EmployeeServices = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'V_DEReception.serviceDescription  as serviceDescription,
	 V_DEReception.serviceCode  as serviceCode  ' + @NewLineChar;
end 

------------ @EmployeeProfessions -------------------------------------------------------

if(@EmployeeProfessions = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'V_DEReception.ProfessionDescription  as ProfessionDescription,
	 V_DEReception.ProfessionCode  as ProfessionCode  ' + @NewLineChar;
end 


------------ RecepDay ------------------------------------------------------------
if(@RecepDay = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' V_DEReception.ReceptionDayName  as ReceptionDayName ' + @NewLineChar;
	end 
		

----------- RecepOpeningHour --------------------------------------------------
if(@RecepOpeningHour = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' V_DEReception.openingHour  as openingHour ' + @NewLineChar;
end 

----------- RecepClosingHour --------------------------------------------------
if(@RecepClosingHour = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' V_DEReception.closingHour  as closingHour ' + @NewLineChar;
end 

----------- RecepTotalHours --------------------------------------------------
if(@RecepTotalHours = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' V_DEReception.totalHours  as totalHours ' + @NewLineChar;
end 

----------- RecepValidFrom --------------------------------------------------
if(@RecepValidFrom = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' CONVERT(varchar(10), V_DEReception.validFrom, 103)  as  validFrom  ' + @NewLineChar;
end 

----------- RecepValidTo --------------------------------------------------
if(@RecepValidTo = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' CONVERT(varchar(10), V_DEReception.validTo, 103) as  validTo ' + @NewLineChar;
end 

----------- RecepRemark --------------------------------------------------
if(@RecepRemark = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' V_DEReception.remarkText  as RecepRemark ' + @NewLineChar;
end 

--=================================================================

set @sql = @sql + @sqlFrom 
 + @sqlEnd
 
set @sql = 'SET DATEFORMAT dmy ' + @NewLineChar + @sql +@NewLineChar+ 'SET DATEFORMAT mdy;'

print '--------- sql query full ----------'
print '--===== @sql string length = ' + str(len(@sql))
Exec rpc_HelperLongPrint @sql 
			 
			
SET DATEFORMAT dmy;
EXECUTE sp_executesql @sql 
SET DATEFORMAT mdy;

SET @ErrCode = @sql 
RETURN 

GO
GRANT EXEC ON [dbo].rprt_EmployeeReceptions TO PUBLIC
GO
----------------
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_DeptEvents')
	BEGIN
		DROP  Procedure  dbo.rprt_DeptEvents
	END
GO

CREATE Procedure dbo.rprt_DeptEvents
(
	 @DistrictCodes varchar(max)=null,
	 @AdminClinicCode varchar(max)=null,	
	 @CitiesCodes varchar(max)=null,
	 @StatusCodes varchar(max)=null,
	 @UnitTypeCodes varchar(max)=null,
	 @SubUnitTypeCodes varchar(max)=null,
	 @SectorCodes varchar(max)=null,
	 @DeptEvents_cond varchar(max)=null,
	 @EventStartDate_cond varchar(max)=null,
	 @EventFinishDate_cond varchar(max)=null,
	 @Membership_cond varchar(max)=null, 
	 
	@district varchar (2)= null,	
	@adminClinic varchar (2) = null ,		
	@ClinicName varchar (2)=null,
	@ClinicCode varchar (2)=null,
	@simul varchar (2)=null,
	@unitType varchar (2)=null,		
	@subUnitType varchar (2)=null,	
	@sector varchar (2)=null,
	@city varchar (2)=null,
	@address varchar (2)=null,
	@Phone1 varchar (2)=null,
	@Phone2 varchar (2)=null,
	@Fax varchar (2)=null,
	@Email varchar (2)=null,
	@MangerName varchar (2)=null,
	@adminMangerName varchar (2)=null,	
	@subAdminClinic varchar (2)=null, 
	@EventName varchar (2)=null,
	@EventDescription varchar (2)=null,
	@EventDisplayingDates varchar (2)=null,
	@EventMeetingsNumber varchar (2)=null,
	@EventMeetingsDetails varchar (2)=null,
	@EventPrice varchar (2)=null,
	@EventTargetPopulation varchar (2)=null,
	@EventPhones varchar (2)=null,
	@EventRemark varchar (2)=null,
	@Membership  varchar (2)=null,
	
	@IsExcelVersion varchar (2)=null,
	@ErrCode varchar(max) OUTPUT
-----------------------------------------
)with recompile

AS
--------------------------------------

DECLARE @NewLineChar AS CHAR(2) 
set @NewLineChar = CHAR(13) + CHAR(10)

--set variables 
declare  @sql nvarchar(max)-- nvarchar type supports hebrew lenguage
declare  @sqlEnd nvarchar(max)
declare  @sqlFrom varchar(max)

set @sql = 'SELECT distinct *  from
			(select ' + @NewLineChar;
set @sqlEnd = ') as resultTable' + @NewLineChar;

set @sqlFrom = 
'from dept  as d    
join dept as d2 on d.deptCode = d2.deptCode	
	AND (''' + @Membership_cond + ''' = ''-1'' 
		or d.IsCommunity = 1 and 1 in (SELECT IntField FROM dbo.SplitString( ''' + @Membership_cond + '''))
		or d.IsMushlam = 1 and 2 in (SELECT IntField FROM dbo.SplitString( ''' + @Membership_cond + '''))
		or d.IsHospital = 1 and 3 in (SELECT IntField FROM dbo.SplitString( ''' + @Membership_cond  + '''))
		)
	AND (''' + @AdminClinicCode + ''' = ''-1'' or d.administrationCode  in (SELECT IntField FROM dbo.SplitString( ''' + @AdminClinicCode + ''')))
	AND (''' + @DistrictCodes + ''' = ''-1'' or  d.districtCode IN (SELECT IntField FROM dbo.SplitString( ''' + @DistrictCodes + ''')) or d.DeptCode IN (SELECT x_Dept_District.DeptCode FROM dbo.SplitString(''' + @DistrictCodes + ''') as T JOIN  x_Dept_District ON T.IntField = x_Dept_District.districtCode) )
	AND (''' + @UnitTypeCodes + ''' = ''-1'' or d.typeUnitCode  in (SELECT IntField FROM dbo.SplitString( ''' + @UnitTypeCodes + ''')) )
	AND (''' + @SubUnitTypeCodes + ''' = ''-1'' or d.subUnitTypeCode in (SELECT IntField FROM dbo.SplitString( ''' + @SubUnitTypeCodes + ''')) )
	AND (''' + @CitiesCodes + ''' = ''-1'' or d.CityCode IN (SELECT IntField FROM dbo.SplitString( ''' + @CitiesCodes + ''')) )
	AND (''' + @SectorCodes + ''' = ''-1'' or d.populationSectorCode IN (SELECT IntField FROM dbo.SplitString( ''' + @SectorCodes + ''')) )
	AND (''' + @DeptEvents_cond + ''' = ''-1'' or
	(	SELECT count(*) 
		FROM DeptEvent 
		WHERE d.DeptCode = DeptEvent.DeptCode									
		AND DeptEvent.EventCode IN (SELECT IntField FROM dbo.SplitString( ''' + @DeptEvents_cond + ''' ))) > 0
	)
 left join DeptStatus on d.DeptCode = DeptStatus.DeptCode 
 join dept as d3 on d.deptCode = d3.deptCode
	AND (''' + @StatusCodes + ''' = ''-1'' or DeptStatus.Status IN (SELECT IntField FROM dbo.SplitString( ''' + @StatusCodes + ''')) )
 left join DIC_ActivityStatus on DeptStatus.Status = DIC_ActivityStatus.status  
 
 left join dept as dAdmin on d.administrationCode = dAdmin.deptCode   
 left join dept as dDistrict on d.districtCode = dDistrict.deptCode    
 left join dept as dSubAdmin on d.subAdministrationCode = dSubAdmin.deptCode 
 left join View_UnitType as UnitType on d.typeUnitCode =  UnitType.UnitTypeCode  
 left join View_SubUnitTypes as SubUnitType on d.subUnitTypeCode =  SubUnitType.subUnitTypeCode and  d.typeUnitCode =  SubUnitType.UnitTypeCode  
 left join PopulationSectors as ps on d.populationSectorCode = ps.PopulationSectorID  
 left join deptSimul on d.DeptCode = deptSimul.DeptCode 
 left join Cities on d.CityCode =  Cities.CityCode  
 
 left join DeptPhones dp1 on d.DeptCode = dp1.DeptCode and dp1.PhoneType = 1 and dp1.phoneOrder = 1  
 left join DeptPhones dp2 on d.DeptCode = dp2.DeptCode and dp2.PhoneType = 1 and dp2.phoneOrder = 2 
 left join DeptPhones dp3 on d.DeptCode = dp3.DeptCode and dp3.PhoneType = 2 and dp3.phoneOrder = 1 
 -------------

 left join DeptEvent on d.deptCode = DeptEvent.deptCode
 left join DIC_Events on DeptEvent.EventCode = DIC_Events.EventCode
 
 left join dbo.View_DeptEventParticularsStartFinish as EventParticulars on DeptEvent.DeptEventID = EventParticulars.DeptEventID
join dept as d4 on d.deptCode = d4.deptCode
	and[dbo].rfn_CheckExpirationDate_str
	(CONVERT(varchar(10), EventParticulars.startDate, 103),
	 CONVERT(varchar(10), EventParticulars.finishDate, 103), '''
	 + isNull(@EventStartDate_cond , 'null') + ''','''
	 + IsNull(@EventFinishDate_cond, 'null')+ ''') = 1 
	 
 left join DeptEventPhones as DeptEventPhones1 on DeptEvent.DeptEventID  = DeptEventPhones1.DeptEventID
			and DeptEventPhones1.PhoneType = 1 and DeptEventPhones1.phoneOrder = 1
left join DeptPhones DeptPhones1 on d.DeptCode =  DeptPhones1.DeptCode and  DeptPhones1.PhoneType = 1 and  DeptPhones1.phoneOrder = 1 
' 

if(@district = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
		set @sql = @sql + ' dDistrict.DeptName as DistrictName , isNull(dDistrict.deptCode , -1) as DeptCode '+ @NewLineChar;
	end

if(@adminClinic = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dAdmin.DeptName as AdminClinicName ,
				 dAdmin.DeptCode as AdminClinicCode '+ @NewLineChar;
	end 
	
if(@unitType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' UnitType.UnitTypeCode as UnitTypeCode , UnitType.UnitTypeName as UnitTypeName '+ @NewLineChar;
	end

if(@subUnitType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
		' subUnitType.subUnitTypeCode as subUnitTypeCode , subUnitType.subUnitTypeName as subUnitTypeName '+ 
		@NewLineChar;
	end 


--------------@ClinicName-------------------------------------
if( @ClinicName= '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'd.DeptName as ClinicName ' + @NewLineChar;	
end
--------------@ClinicCode-------------------------------------
if( @ClinicCode= '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' d.deptCode as ClinicCode ' + @NewLineChar;	
end
---------------Simul----------------------------------------------------------------------------------------
if(@simul = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'deptSimul.Simul228 as Code228 '+ @NewLineChar;
end 
---------------SubAdminClinic----------------------------------------------------------------------------
if(@subAdminClinic = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'dSubAdmin.DeptCode as SubAdminClinicCode , dSubAdmin.DeptName as SubAdminClinicName '+ @NewLineChar;
end 

if(@city = '1')
		begin 
			set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);			
			set @sql = @sql + ' Cities.CityCode as CityCode, Cities.CityName as CityName'+ @NewLineChar;
		end

if (@address = '1')
		begin 
			set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
			set @sql = @sql + 'dbo.GetAddress(d.deptCode) as ClinicAddress '+ @NewLineChar;
		end

if(@Membership = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);			
		set @sql = @sql + 
		'case when d.IsCommunity = 1 then ''כן'' else ''לא'' end as IsCommunity, 
		case when d.IsMushlam = 1 then ''כן'' else ''לא'' end as 	IsMushlam,
		case when d.IsHospital = 1 then ''כן'' else ''לא'' end as IsHospital	
		'+ @NewLineChar;
	end

if(@sector = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' ps.PopulationSectorID as SectorCode ,ps.PopulationSectorDescription as SectorName'+ @NewLineChar;
end 

---------Phone1---------------------------------------------------------------
if(@Phone1 = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp1.prePrefix, dp1.Prefix,dp1.Phone, dp1.extension ) as Phone1 '+ @NewLineChar;;
end
----------Phone2--------------------------------------------------------------------------------
if(@Phone2 = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp2.prePrefix, dp2.Prefix, dp2.Phone, dp2.extension) as Phone2 '+ @NewLineChar;;
end 
----------Fax--------------------------------------------------------------------------------
if(@Fax = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp3.prePrefix, dp3.Prefix, dp3.Phone, dp3.extension) as Fax '+ @NewLineChar;
end
----------Email--------------------------------------------------------------------------------
if(@Email = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' d.Email as Email '+ @NewLineChar;
end
 
 ---------MangerName---------------------------------------------------------------
if(@MangerName = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_getManagerName(d.deptCode) as MangerName '+ @NewLineChar;							   
end
---------AdminMangerName---------------------------------------------------------------
if(@adminMangerName = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_getAdminManagerName(d.deptCode) as AdminMangerName '+ @NewLineChar;
end

if(@EventName = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' DIC_Events.EventName as EventName, DeptEvent.EventCode  as EventCode ' + @NewLineChar;
	end
	
if(@EventDescription = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' DeptEvent.EventDescription as EventDescription ' + @NewLineChar;
	end
	
if(@EventDisplayingDates = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' CONVERT(varchar(10), DeptEvent.FromDate, 103)  as DisplayFromDate ' + ',' + @NewLineChar;
		set @sql = @sql + ' CONVERT(varchar(10), DeptEvent.ToDate, 103)   as DisplayToDate ' + @NewLineChar;
	end	

if(@EventMeetingsNumber = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' DeptEvent.MeetingsNumber as MeetingsNumber ' + @NewLineChar;
	end
	
if(@EventPrice = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' DeptEvent.MemberPrice as MemberPrice ' + ',' + @NewLineChar;
		set @sql = @sql + 'DeptEvent.FullMemberPrice as FullMemberPrice ' + ',' +@NewLineChar;
		set @sql = @sql + ' DeptEvent.CommonPrice as CommonPrice ' + @NewLineChar;
	end			
	
if(@EventTargetPopulation = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' DeptEvent.TargetPopulation as TargetPopulation ' + @NewLineChar;
	end
if(@EventPhones = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
		'case when DeptEvent.CascadeUpdatePhonesFromClinic = 1 
		then dbo.fun_ParsePhoneNumberWithExtension(DeptPhones1.prePrefix, DeptPhones1.Prefix, DeptPhones1.Phone, DeptPhones1.extension) 
		else dbo.fun_ParsePhoneNumberWithExtension(DeptEventPhones1.prePrefix, DeptEventPhones1.Prefix, DeptEventPhones1.Phone, DeptEventPhones1.extension) 
		end as EventPhone1 ';
	end
if(@EventRemark = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' DeptEvent.Remark as Remark ' + @NewLineChar;
	end			
		
------------ RecepDay --------------------------------------------
if(@EventMeetingsDetails = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' CONVERT(varchar(10), [EventParticulars].Date, 103)  as EventDate ' + ',' +@NewLineChar;
		set @sql = @sql + ' [EventParticulars].Day  as ReceptionDayName ' + ',' +@NewLineChar;
		set @sql = @sql + ' [EventParticulars].openingHour  as openingHour '+ ',' + @NewLineChar;
		set @sql = @sql + ' [EventParticulars].closingHour  as closingHour '+ ',' + @NewLineChar;
		set @sql = @sql + ' [EventParticulars].totalHours  as totalHours'+ ',' +  @NewLineChar;
		set @sql = @sql + ' CONVERT(varchar(10), [EventParticulars].startDate, 103)  as startDate '+ ',' +  @NewLineChar;
		set @sql = @sql + ' CONVERT(varchar(10), [EventParticulars].finishDate, 103)  as finishDate '+ @NewLineChar;
		
		
end 

--=================================================================

set @sql = @sql + @sqlFrom + @sqlEnd


print '--------- sql query full ----------'
print '--===== @sql string length = ' + str(len(@sql))
Exec rpc_HelperLongPrint @sql 

SET DATEFORMAT dmy;
EXECUTE sp_executesql @sql 
SET DATEFORMAT mdy;
SET @ErrCode = @sql 
RETURN 
GO
GRANT EXEC ON [dbo].rprt_DeptEvents TO PUBLIC
GO
-----------------
IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rfn_GetDeptAndEmployeeReceptionIntervalNonIntersection')
	BEGIN
		DROP  function  dbo.rfn_GetDeptAndEmployeeReceptionIntervalNonIntersection
	END

GO
-- find and returns areas where Dept Reception Intervals not intersected with Employee Reception Intervals
-- where Dept works and Employee don't works
create function dbo.rfn_GetDeptAndEmployeeReceptionIntervalNonIntersection
 (
	@deptCode int,
	@deptEmployeeId int,
	@day int,
	@span varchar(5),
	@direction int	-- @direction = 1  where Dept works without Employee 
					-- @direction = -1  where Employee works without  Dept
 ) 
RETURNS 
@ResultTable table
(
	intervalsStr varchar(200),		
	intervalsValues_str varchar(200),
	intervalsSum_minu decimal(10,2)	
)
as

begin

	declare @deptIntervals type_TimeIntervals
	declare @employeeIntervals type_TimeIntervals
	
	
	insert into @deptIntervals
	select openingHour, closingHour, 0
	from DeptReception  
	where DeptReception.deptCode = @deptCode
	and DeptReception.receptionDay = @day
	and GETDATE()>= DeptReception.validFrom
	order by DeptReception.openingHour

	insert into @employeeIntervals
	select openingHour, closingHour, 0
	from deptEmployeeReception  
	where deptEmployeeReception.DeptEmployeeId = @deptEmployeeId
	and deptEmployeeReception.receptionDay = @day
	and GETDATE()>= deptEmployeeReception.validFrom
	order by deptEmployeeReception.openingHour
	
	if(@direction = 1)
	insert into @ResultTable select * from rfn_TimeIntervalsNonIntersectedPart(@employeeIntervals, @deptIntervals,  @Span )  
	else --(@direction = -1)
	insert into @ResultTable select * from rfn_TimeIntervalsNonIntersectedPart(@deptIntervals, @employeeIntervals,  @Span )  
	
	return 
end
go
---------------
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'rfn_GetDeptEmployeeReceptionsString')
	BEGIN
		DROP  FUNCTION  rfn_GetDeptEmployeeReceptionsString
	END

GO
create function dbo.rfn_GetDeptEmployeeReceptionsString(@DeptEmployeeId int,  @day int) 
RETURNS varchar(200)
WITH EXECUTE AS CALLER

AS
BEGIN

	declare @IntervalsStr varchar(200) 
	set @IntervalsStr = ''
	
	SELECT 
	@intervalsStr = @intervalsStr + cast(t.openingHour as varchar(5))  + '-' + cast(t.closingHour as varchar(5)) + '; ' 
	
	FROM
	(	
		select openingHour, closingHour
		from deptEmployeeReception  
		where deptEmployeeReception.DeptEmployeeId = @DeptEmployeeId
			and deptEmployeeReception.receptionDay = @day
			and GETDATE()>= deptEmployeeReception.validFrom
			
	) as t 
	order by t.openingHour
	
	return (@IntervalsStr);
	
end 


go 
grant exec on rfn_GetDeptEmployeeReceptionsString to public 
go
---------
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'rfn_GetDeptReceptionsString')
	BEGIN
		DROP  FUNCTION  rfn_GetDeptReceptionsString
	END

GO
create function dbo.rfn_GetDeptReceptionsString(@DeptCode int, @day int, @ReceptionHoursType int) 
RETURNS varchar(200)
WITH EXECUTE AS CALLER

AS
BEGIN

	declare @IntervalsStr varchar(200) 
	set @IntervalsStr = ''
	
	SELECT 
	@intervalsStr = @intervalsStr + cast(t.openingHour as varchar(5))  + '-' + cast(t.closingHour as varchar(5)) + '; ' 
	
	FROM
	(	select openingHour, closingHour
		from DeptReception  
		where DeptReception.deptCode = @deptCode
		and DeptReception.receptionDay = @day
		and GETDATE()>= DeptReception.validFrom
		and DeptReception.ReceptionHoursTypeID = @ReceptionHoursType
	) as t 
	order by t.openingHour
	
	return (@IntervalsStr);
	
end 


go 
grant exec on rfn_GetDeptReceptionsString to public 
go
-----------------

----------------
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'rfn_GetDeptServiceReceptionsString')
	BEGIN
		DROP  FUNCTION  rfn_GetDeptServiceReceptionsString
	END

GO
---------------
IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rfn_GetDeptAndServiceReceptionIntervalNonIntersection')
	BEGIN
		DROP  function  dbo.rfn_GetDeptAndServiceReceptionIntervalNonIntersection
							
	END

GO
-- find and returns areas where Dept Reception Intervals not intersected with SubDept Reception Intervals
create function dbo.rfn_GetDeptAndServiceReceptionIntervalNonIntersection
 (
	@deptCode int,
	@day int,
	@span varchar(5)
 ) 
RETURNS 
@ResultTable table
(
	intervalsStr varchar(200),		
	intervalsValues_str varchar(200),
	intervalsSum_minu decimal(10,2)	
)
as

begin

	declare @deptIntervals type_TimeIntervals
	declare @serviceIntervals type_TimeIntervals
	
	
	insert into @deptIntervals
	select openingHour, closingHour, 0
	from DeptReception  as dr
	where dr.deptCode = @deptCode
	and dr.receptionDay = @day
	and GETDATE()>= dr.validFrom
	and dr.ReceptionHoursTypeID = 1
	order by dr.openingHour

	insert into @serviceIntervals
	select openingHour, closingHour, 0
	from DeptReception  as dr
	where dr.deptCode = @deptCode
	and dr.receptionDay = @day
	and GETDATE()>= dr.validFrom
	and dr.ReceptionHoursTypeID = 2 -- OfficeservicesHours
	order by dr.openingHour

	
	insert into @ResultTable select * from rfn_TimeIntervalsNonIntersectedPart(@serviceIntervals, @deptIntervals, @Span )  
	return 
end
go
------------------------------
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_DeptAndEmployeeReceptionDifferences')
	BEGIN
		DROP  Procedure  dbo.rprt_DeptAndEmployeeReceptionDifferences
	END
GO


CREATE Procedure dbo.rprt_DeptAndEmployeeReceptionDifferences
(
	@DistrictCodes varchar(max)=null,
	@AdminClinicCode varchar(max)=null,
	@ReceptionHoursSpan_cond varchar(max)=null,
	@EmployeeSector_cond varchar(max) = null,
	@AgreementType_cond varchar(max)=null,
	@IsExcelVersion varchar (2)=null,
	@ErrCode varchar(max) OUTPUT
-----------------------------------------
)with recompile

AS
--------------------------------------

DECLARE @NewLineChar AS CHAR(2) 
set @NewLineChar = CHAR(13) + CHAR(10)

DECLARE @ReceptionHoursSpan int
if (@ReceptionHoursSpan_cond is null or @ReceptionHoursSpan_cond = '-1' or ISDATE(@ReceptionHoursSpan_cond)= 0)
		set @ReceptionHoursSpan = 24*60 
		--CAST('00:00' as time(0))
	else
		set @ReceptionHoursSpan = datediff(minute,'00:00', @ReceptionHoursSpan_cond)
		--CAST(@ReceptionHoursSpan_cond as time(0))
	 
		
SET DATEFORMAT dmy;

SELECT distinct *  from
(select 
 dDistrict.DeptName as DistrictName , dDistrict.deptCode as DeptCode 
, dAdmin.DeptName as AdminClinicName , dAdmin.DeptCode as AdminClinicCode
				 
,d.DeptName as ClinicName 
,d.deptCode as ClinicCode 
,deptSimul.Simul228 as Code228 
,Employee.employeeID as employeeID
,Employee.firstName as EmployeeFirstName 
,Employee.lastName as EmployeeLastName
,View_EmployeeSector.EmployeeSectorCode -- for test
,View_EmployeeSector.EmployeeSectorDescription -- for test

,DIC_ReceptionDays.ReceptionDayName as ReceptionDayName
 
,dbo.rfn_GetDeptReceptionsString(d.DeptCode, DeptReception.receptionDay, 1) as  deptReceptions
,dbo.rfn_GetDeptEmployeeReceptionsString(x_Dept_Employee.DeptEmployeeID, DeptReception.receptionDay) as  DeptEmployeeReceptions
,Intervals.intervalsStr as nonIntersectedInterv	
,Intervals.intervalsValues_str  as intervalsValues
,Intervals.intervalsSum_minu as intervalsSum

from dept  as d    
join x_Dept_Employee on d.deptCode = x_Dept_Employee.deptCode 
	and x_Dept_Employee.active = 1
	and d.IsCommunity = 1 
	AND (@DistrictCodes = '-1' or d.districtCode IN (SELECT IntField FROM dbo.SplitString(@DistrictCodes))
							   or d.DeptCode IN (SELECT x_Dept_District.DeptCode FROM dbo.SplitString(@DistrictCodes) as T
							   JOIN  x_Dept_District ON T.IntField = x_Dept_District.districtCode) )	
	AND (@AdminClinicCode = '-1' or  d.administrationCode IN (SELECT IntField FROM dbo.SplitString( @AdminClinicCode)) )
	AND (@AgreementType_cond  = '-1' or x_Dept_Employee.AgreementType IN (SELECT IntField FROM dbo.SplitString(@AgreementType_cond ))) 

join Employee on x_Dept_Employee.employeeID = Employee.employeeID
	and Employee.active = 1
	and (@EmployeeSector_cond = '-1' or Employee.EmployeeSectorCode = @EmployeeSector_cond)
	
left join dept as dDistrict on d.districtCode = dDistrict.deptCode 
left join dept as dAdmin on d.administrationCode = dAdmin.deptCode    
left join deptSimul on d.DeptCode = deptSimul.DeptCode 	
	
INNER JOIN View_EmployeeSector on Employee.EmployeeSectorCode = View_EmployeeSector.EmployeeSectorCode

left join DeptReception on d.deptCode = DeptReception.deptCode
JOIN DIC_ReceptionDays on DeptReception.receptionDay = DIC_ReceptionDays.ReceptionDayCode

left join deptEmployeeReception  on x_Dept_Employee.DeptEmployeeID = deptEmployeeReception.DeptEmployeeID
	and DeptReception.receptionDay = deptEmployeeReception.receptionDay

cross apply rfn_GetDeptAndEmployeeReceptionIntervalNonIntersection
		(d.deptCode, x_Dept_Employee.DeptEmployeeID, 
		 DeptReception.receptionDay, @ReceptionHoursSpan_cond, 1) as Intervals

) as resultTable
order by DeptCode, ClinicCode, ReceptionDayName

RETURN 
SET DATEFORMAT mdy;
GO

GRANT EXEC ON [dbo].rprt_DeptAndEmployeeReceptionDifferences TO PUBLIC
GO
--------------------
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_DeptAndOfficeReceptionDifferences')
	BEGIN
		DROP  Procedure  dbo.rprt_DeptAndOfficeReceptionDifferences
	END
GO

CREATE Procedure dbo.rprt_DeptAndOfficeReceptionDifferences
(
	@DistrictCodes varchar(max)=null,
	@AdminClinicCode varchar(max)=null,
	@ReceptionHoursSpan_cond varchar(max)=null,
    @Membership_cond varchar(max)=null, 

	@IsExcelVersion varchar (2)=null,
	@ErrCode varchar(max) OUTPUT
-----------------------------------------
)with recompile 

AS
--------------------------------------

DECLARE @NewLineChar AS CHAR(2) 
set @NewLineChar = CHAR(13) + CHAR(10)

DECLARE @ReceptionHoursSpan int
if (@ReceptionHoursSpan_cond is null or @ReceptionHoursSpan_cond = '-1' or ISDATE(@ReceptionHoursSpan_cond)= 0)
		set @ReceptionHoursSpan = 24*60 
		--CAST('00:00' as time(0))
	else
		set @ReceptionHoursSpan = datediff(minute,'00:00', @ReceptionHoursSpan_cond)
		--CAST(@ReceptionHoursSpan_cond as time(0))
		
SET DATEFORMAT dmy;

SELECT distinct *  from
(select 
 dDistrict.DeptName as DistrictName 
, dDistrict.deptCode as DeptCode 
, dAdmin.DeptName as AdminClinicName 
, dAdmin.DeptCode as AdminClinicCode
				 
,d.DeptName as ClinicName 
,d.deptCode as ClinicCode 
,deptSimul.Simul228 as Code228 
,case when d.IsCommunity = 1 then 'כן' else 'לא' end as IsCommunity 
,case when d.IsMushlam = 1 then 'כן' else 'לא' end as 	IsMushlam
,case when d.IsHospital = 1 then 'כן' else 'לא' end as IsHospital

,(select ReceptionTypeDescription from DIC_ReceptionHoursTypes where ReceptionHoursTypeID = 2) as ServiceDescription 
,(select ReceptionHoursTypeID from DIC_ReceptionHoursTypes where ReceptionHoursTypeID = 2) as ServiceCode 

,DIC_ReceptionDays.ReceptionDayName as ReceptionDayName
-----------
,dbo.rfn_GetDeptReceptionsString(d.DeptCode, DeptReception.receptionDay, 1) as deptReceptions -- DeptreceptionHours
,dbo.rfn_GetDeptReceptionsString(d.DeptCode, DeptReception.receptionDay, 2) as ServiceReceptions -- OfficeServicesReceptionHours
,Intervals.intervalsStr as nonIntersectedInterv	
,Intervals.intervalsValues_str  as intervalsValues
,Intervals.intervalsSum_minu as intervalsSum

from dept  as d    
left join dept as dDistrict on d.districtCode = dDistrict.deptCode 
left join dept as dAdmin on d.administrationCode = dAdmin.deptCode    
left join deptSimul on d.DeptCode = deptSimul.DeptCode 	

left join DeptReception on d.deptCode = DeptReception.deptCode
	and DeptReception.ReceptionHoursTypeID = 1
JOIN DIC_ReceptionDays on DeptReception.receptionDay = DIC_ReceptionDays.ReceptionDayCode

cross apply rfn_GetDeptAndServiceReceptionIntervalNonIntersection(d.deptCode, DeptReception.receptionDay, @ReceptionHoursSpan_cond) as Intervals
where 
	d.status = 1
	AND (@Membership_cond = '-1'
		or d.IsCommunity = 1 and 1 in (SELECT IntField FROM dbo.SplitString(  @Membership_cond ))
		or d.IsMushlam = 1 and 2 in (SELECT IntField FROM dbo.SplitString(  @Membership_cond))
		or d.IsHospital = 1 and 3 in (SELECT IntField FROM dbo.SplitString( @Membership_cond ))
		)
	AND (@DistrictCodes = '-1' or d.districtCode IN (SELECT IntField FROM dbo.SplitString(@DistrictCodes))
							   or d.DeptCode IN (SELECT x_Dept_District.DeptCode FROM dbo.SplitString(@DistrictCodes) as T
							   JOIN  x_Dept_District ON T.IntField = x_Dept_District.districtCode)	)
	AND (@AdminClinicCode = '-1' or  d.administrationCode IN (SELECT IntField FROM dbo.SplitString( @AdminClinicCode)) )

) as resultTable
order by DeptCode, ClinicCode, ReceptionDayName

SET DATEFORMAT mdy;

RETURN 

GO
GRANT EXEC ON [dbo].rprt_DeptAndOfficeReceptionDifferences TO PUBLIC
GO
--------------------
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_DeptAndPharmacyReceptionDifferences')
	BEGIN
		DROP  Procedure  dbo.rprt_DeptAndPharmacyReceptionDifferences
	END
GO

CREATE Procedure dbo.rprt_DeptAndPharmacyReceptionDifferences
(
	@DistrictCodes varchar(max)=null,
	@AdminClinicCode varchar(max)=null,
	@ReceptionHoursSpan_cond varchar(max)=null,
    @Membership_cond varchar(max)=null, 

	@IsExcelVersion varchar (2)=null,
	@ErrCode varchar(max) OUTPUT
-----------------------------------------
)with recompile

AS
--------------------------------------

DECLARE @NewLineChar AS CHAR(2) 
set @NewLineChar = CHAR(13) + CHAR(10)

DECLARE @ReceptionHoursSpan int
if (@ReceptionHoursSpan_cond is null or @ReceptionHoursSpan_cond = '-1' or ISDATE(@ReceptionHoursSpan_cond)= 0)
		set @ReceptionHoursSpan = 24*60 
		--CAST('00:00' as time(0))
	else
		set @ReceptionHoursSpan = datediff(minute,'00:00', @ReceptionHoursSpan_cond)
		--CAST(@ReceptionHoursSpan_cond as time(0))
		
SET DATEFORMAT dmy;

SELECT distinct *  from
(select 
 dDistrict.DeptName as DistrictName 
, isNull(dDistrict.deptCode , -1) as DeptCode 
, dAdmin.DeptName as AdminClinicName 
, isNull(dAdmin.DeptCode , -1) as AdminClinicCode
				 
,d.DeptName as ClinicName 
,d.deptCode as ClinicCode 
,deptSimul.Simul228 as Code228 
,case when d.IsCommunity = 1 then 'כן' else 'לא' end as IsCommunity 
,case when d.IsMushlam = 1 then 'כן' else 'לא' end as 	IsMushlam
,case when d.IsHospital = 1 then 'כן' else 'לא' end as IsHospital


,SubClinics.DeptName as SubClinicName 
,SubClinics.deptCode as SubClinicCode 
,SubClinicDeptSimul.Simul228 as SubClinicCode228 
,SubClinicUnitType.UnitTypeCode as SubClinicUnitTypeCode , SubClinicUnitType.UnitTypeName as SubClinicUnitTypeName 
,case when SubClinics.IsCommunity = 1 then 'כן' else 'לא' end as SubClinicIsCommunity 
,case when SubClinics.IsMushlam = 1 then 'כן' else 'לא' end as 	SubClinicIsMushlam
,case when SubClinics.IsHospital = 1 then 'כן' else 'לא' end as SubClinicIsHospital

,DIC_ReceptionDays.ReceptionDayName as ReceptionDayName
-----------
,dbo.rfn_GetDeptReceptionsString(d.DeptCode, DeptReception.receptionDay, 1) as  deptReceptions
,dbo.rfn_GetDeptReceptionsString(SubClinics.DeptCode, DeptReception.receptionDay, 1) as  subDeptReceptions
,Intervals.intervalsStr as nonIntersectedInterv	
,Intervals.intervalsValues_str  as intervalsValues
,Intervals.intervalsSum_minu as intervalsSum

from dept  as d    
join dept as SubClinics on d.deptCode = SubClinics.subAdministrationCode 
	and d.status = 1
	and SubClinics.status = 1
	AND (@Membership_cond = '-1' 
		or d.IsCommunity = 1 and 1 in (SELECT IntField FROM dbo.SplitString(  @Membership_cond ))
		or d.IsMushlam = 1 and 2 in (SELECT IntField FROM dbo.SplitString(  @Membership_cond))
		or d.IsHospital = 1 and 3 in (SELECT IntField FROM dbo.SplitString( @Membership_cond ))
		)
	AND ( @Membership_cond = '-1' 
		or SubClinics.IsCommunity = 1 and 1 in (SELECT IntField FROM dbo.SplitString(  @Membership_cond ))
		or SubClinics.IsMushlam = 1 and 2 in (SELECT IntField FROM dbo.SplitString(  @Membership_cond))
		or SubClinics.IsHospital = 1 and 3 in (SELECT IntField FROM dbo.SplitString( @Membership_cond ))
		)
	AND (@DistrictCodes = '-1' or d.districtCode IN (SELECT IntField FROM dbo.SplitString(@DistrictCodes))
							   or d.DeptCode IN (SELECT x_Dept_District.DeptCode FROM dbo.SplitString(@DistrictCodes) as T
							   JOIN  x_Dept_District ON T.IntField = x_Dept_District.districtCode)	)	
	AND (@AdminClinicCode = '-1' or  d.administrationCode IN (SELECT IntField FROM dbo.SplitString( @AdminClinicCode)) )
	AND (SubClinics.typeUnitCode  = 401 )-- pharmacy
	
left join dept as dDistrict on d.districtCode = dDistrict.deptCode 
left join dept as dAdmin on d.administrationCode = dAdmin.deptCode    
left join deptSimul on d.DeptCode = deptSimul.DeptCode 	

left join View_UnitType as SubClinicUnitType on SubClinics.typeUnitCode =  SubClinicUnitType.UnitTypeCode  --
left join deptSimul as SubClinicDeptSimul on SubClinics.DeptCode = SubClinicDeptSimul.DeptCode 

left join DeptReception on d.deptCode = DeptReception.deptCode
JOIN DIC_ReceptionDays on DeptReception.receptionDay = DIC_ReceptionDays.ReceptionDayCode

left join DeptReception as SubClinicDeptReception on SubClinics.deptCode = SubClinicDeptReception.deptCode
and DeptReception.receptionDay = SubClinicDeptReception.receptionDay

cross apply rfn_GetDeptsReceptionIntervalNonIntersection(d.deptCode, SubClinics.deptCode,  DeptReception.receptionDay, @ReceptionHoursSpan_cond) as Intervals

) as resultTable
order by DeptCode, ClinicCode, ReceptionDayName

RETURN 
SET DATEFORMAT mdy;
GO
GRANT EXEC ON [dbo].rprt_DeptAndPharmacyReceptionDifferences TO PUBLIC
GO
-----------------
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_DeptEmployeeAndPharmacyReceptionDifferences')
	BEGIN
		DROP  Procedure  dbo.rprt_DeptEmployeeAndPharmacyReceptionDifferences
	END
GO

CREATE Procedure dbo.rprt_DeptEmployeeAndPharmacyReceptionDifferences
(
	@DistrictCodes varchar(max)=null,
	@AdminClinicCode varchar(max)=null,
	@ReceptionHoursSpan_cond varchar(max)=null,
	@EmployeeSector_cond varchar(max) = null,
	@IncludeSubClinicEmployees_cond varchar (2)=null,
	@AgreementType_cond varchar(max)=null,
	@IsExcelVersion varchar (2)=null,
	@ErrCode varchar(max) OUTPUT
--------------------------------------
)with recompile

AS
--------------------------------------

DECLARE @NewLineChar AS CHAR(2) 
set @NewLineChar = CHAR(13) + CHAR(10)

DECLARE @ReceptionHoursSpan int
if (@ReceptionHoursSpan_cond is null or @ReceptionHoursSpan_cond = '-1' or ISDATE(@ReceptionHoursSpan_cond)= 0)
		set @ReceptionHoursSpan = 24*60 
		--CAST('00:00' as time(0))
	else
		set @ReceptionHoursSpan = datediff(minute,'00:00', @ReceptionHoursSpan_cond)
		--CAST(@ReceptionHoursSpan_cond as time(0))
	 
		
SET DATEFORMAT dmy;

SELECT distinct *  from
(select 
 dDistrict.DeptName as DistrictName , isNull(dDistrict.deptCode , -1) as DeptCode 
,dAdmin.DeptName as AdminClinicName , isNull(dAdmin.DeptCode , -1) as AdminClinicCode
				 
,d.DeptName as ClinicName 
,d.deptCode as ClinicCode 
,deptSimul.Simul228 as Code228 
,d.typeUnitCode as ClinicUnitTypeCode
,d.subAdministrationCode as ClinicSubAdminCode

,SubClinics.DeptName as SubClinicName 
,SubClinics.deptCode as SubClinicCode 
,SubClinicDeptSimul.Simul228 as SubClinicCode228 
,SubClinicUnitType.UnitTypeCode as SubClinicUnitTypeCode -- for tes
,SubClinicUnitType.UnitTypeName as SubClinicUnitTypeName -- for tes
,SubClinics.subAdministrationCode as SubClinicSubAdminCode 

,Employee.employeeID as employeeID
,Employee.firstName as EmployeeFirstName 
,Employee.lastName as EmployeeLastName
,View_EmployeeSector.EmployeeSectorCode -- for test
,View_EmployeeSector.EmployeeSectorDescription -- for test

,DIC_ReceptionDays.ReceptionDayName as ReceptionDayName

,dbo.rfn_GetDeptReceptionsString(SubClinics.DeptCode, SubClinicDeptReception.receptionDay, 1) as  subDeptReceptions
,dbo.rfn_GetDeptEmployeeReceptionsString(x_Dept_Employee.DeptEmployeeID, SubClinicDeptReception.receptionDay) as  DeptEmployeeReceptions

,Intervals.intervalsStr as nonIntersectedInterv	
,Intervals.intervalsValues_str  as intervalsValues
,Intervals.intervalsSum_minu as intervalsSum

from x_Dept_Employee 
join dept  as d  on x_Dept_Employee.deptCode = d.deptCode 
	and x_Dept_Employee.active = 1
	and d.status = 1
	AND (@DistrictCodes = '-1' or d.districtCode IN (SELECT IntField FROM dbo.SplitString(@DistrictCodes))
							   or d.DeptCode IN (SELECT x_Dept_District.DeptCode FROM dbo.SplitString(@DistrictCodes) as T
							   JOIN  x_Dept_District ON T.IntField = x_Dept_District.districtCode)	)
	AND (@AdminClinicCode = '-1' or  d.administrationCode IN (SELECT IntField FROM dbo.SplitString( @AdminClinicCode)) )
	AND (@AgreementType_cond  = '-1' or x_Dept_Employee.AgreementType IN (SELECT IntField FROM dbo.SplitString(@AgreementType_cond ))) 

join dept as SubClinics on 
	 SubClinics.typeUnitCode  = 401 -- pharmacy
	and SubClinics.status = 1
	and (
	(@IncludeSubClinicEmployees_cond = '1' -- yes
	and (d.deptCode = SubClinics.subAdministrationCode -- dept is parent of pharmacy
		or d.subAdministrationCode = SubClinics.subAdministrationCode)) -- dept is brather of pharmacy 
	
	or(@IncludeSubClinicEmployees_cond = '0' -- no
	and d.deptCode = SubClinics.subAdministrationCode) -- dept is parent of pharmacy
	) 
		
join Employee on x_Dept_Employee.employeeID = Employee.employeeID
	and Employee.active = 1
	and (@EmployeeSector_cond = '-1' or Employee.EmployeeSectorCode = @EmployeeSector_cond)

join deptEmployeeReception  on x_Dept_Employee.DeptEmployeeID = deptEmployeeReception.DeptEmployeeID

left join DeptReception as SubClinicDeptReception on SubClinics.deptCode = SubClinicDeptReception.deptCode
JOIN DIC_ReceptionDays on SubClinicDeptReception.receptionDay = DIC_ReceptionDays.ReceptionDayCode
	and SubClinicDeptReception.receptionDay = deptEmployeeReception.receptionDay
	
INNER JOIN View_EmployeeSector on Employee.EmployeeSectorCode = View_EmployeeSector.EmployeeSectorCode
		
left join dept as dDistrict on d.districtCode = dDistrict.deptCode 
left join dept as dAdmin on d.administrationCode = dAdmin.deptCode    
left join deptSimul on d.DeptCode = deptSimul.DeptCode 	

left join View_UnitType as SubClinicUnitType on SubClinics.typeUnitCode =  SubClinicUnitType.UnitTypeCode  --
left join deptSimul as SubClinicDeptSimul on SubClinics.DeptCode = SubClinicDeptSimul.DeptCode 

cross apply rfn_GetDeptAndEmployeeReceptionIntervalNonIntersection
		(SubClinics.deptCode, x_Dept_Employee.DeptEmployeeID, 
		 SubClinicDeptReception.receptionDay, @ReceptionHoursSpan_cond, 1) as Intervals

) as resultTable
order by DeptCode, SubClinicCode, ClinicCode, employeeID, ReceptionDayName

RETURN 
SET DATEFORMAT mdy;
GO
GRANT EXEC ON [dbo].rprt_DeptEmployeeAndPharmacyReceptionDifferences TO PUBLIC
GO
-------------
IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rfn_GetDepServicetAndDeptEmployeeReceptionIntervalNonIntersection')
	BEGIN
		DROP  function  dbo.rfn_GetDepServicetAndDeptEmployeeReceptionIntervalNonIntersection
	END

GO
-- find and returns areas where Dept Reception Intervals not intersected with Employee Reception Intervals
-- where Dept works and Employee don't works
create function dbo.rfn_GetDepServicetAndDeptEmployeeReceptionIntervalNonIntersection
 (
	@deptCode int,
	@DeptEmployeeId int,
	@day int,
	@span varchar(5)
	--,@direction int	-- @direction = 1  where Dept works without Employee 
					-- @direction = -1  where Employee works without  Dept
 ) 
RETURNS 
@ResultTable table
(
	intervalsStr varchar(200),		
	intervalsValues_str varchar(200),
	intervalsSum_minu decimal(10,2)	
)
as

begin

	declare @deptIntervals type_TimeIntervals
	declare @employeeIntervals type_TimeIntervals
	
	insert into @deptIntervals
	select openingHour, closingHour, 0
	from DeptReception as dr 
	where dr.deptCode = @deptCode
	and dr.ReceptionHoursTypeID = 2
	and dr.receptionDay = @day
	and GETDATE()>= dr.validFrom
	order by dr.openingHour
	
	insert into @employeeIntervals
	select openingHour, closingHour, 0
	from deptEmployeeReception  
	where deptEmployeeReception.DeptEmployeeID = @DeptEmployeeId
	and deptEmployeeReception.receptionDay = @day
	and GETDATE()>= deptEmployeeReception.validFrom
	order by deptEmployeeReception.openingHour
	
	insert into @ResultTable select * from rfn_TimeIntervalsNonIntersectedPart( @deptIntervals, @employeeIntervals,  @span )  

	return 
end

go
---------------
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_DeptOfficeAndDeptEmployeeReceptionDifferences')
	BEGIN
		DROP  Procedure  dbo.rprt_DeptOfficeAndDeptEmployeeReceptionDifferences
	END
GO

CREATE Procedure dbo.rprt_DeptOfficeAndDeptEmployeeReceptionDifferences
(
	@DistrictCodes varchar(max)=null,
	@AdminClinicCode varchar(max)=null,
	@ReceptionHoursSpan_cond varchar(max)=null,
	@EmployeeSector_cond varchar(max) = null,
	@IncludeSubClinicEmployees_cond varchar (2)=null,
	@IsExcelVersion varchar (2)=null,
	@ErrCode varchar(max) OUTPUT
-----------------------------------------
)with recompile

AS
--------------------------------------

DECLARE @NewLineChar AS CHAR(2) 
set @NewLineChar = CHAR(13) + CHAR(10)

DECLARE @ReceptionHoursSpan int
if (@ReceptionHoursSpan_cond is null or @ReceptionHoursSpan_cond = '-1' or ISDATE(@ReceptionHoursSpan_cond)= 0)
		set @ReceptionHoursSpan = 24*60 
		--CAST('00:00' as time(0))
	else
		set @ReceptionHoursSpan = datediff(minute,'00:00', @ReceptionHoursSpan_cond)
		--CAST(@ReceptionHoursSpan_cond as time(0))
		
SET DATEFORMAT dmy;

SELECT distinct *  from
(select 
 dDistrict.DeptName as DistrictName 
, dDistrict.deptCode as DeptCode 
, dAdmin.DeptName as AdminClinicName 
, dAdmin.DeptCode as AdminClinicCode
				 
,d.DeptCode as ServiceDeptCode 
,x_Dept_Employee.DeptCode as EmployeeDeptCode 

,(select ReceptionTypeDescription from DIC_ReceptionHoursTypes where ReceptionHoursTypeID = 2) as ServiceDescription 
,(select ReceptionHoursTypeID from DIC_ReceptionHoursTypes where ReceptionHoursTypeID = 2) as ServiceCode 

,Employee.employeeID as employeeID
,Employee.firstName as EmployeeFirstName 
,Employee.lastName as EmployeeLastName 
,View_EmployeeSector.EmployeeSectorCode -- for test
,View_EmployeeSector.EmployeeSectorDescription -- for test

,DIC_ReceptionDays.ReceptionDayName as ReceptionDayName

,dbo.rfn_GetDeptReceptionsString(d.deptCode, DIC_ReceptionDays.ReceptionDayCode, 2)
	 as  DeptServiceReceptions
,dbo.rfn_GetDeptEmployeeReceptionsString(x_Dept_Employee.DeptEmployeeID, DIC_ReceptionDays.ReceptionDayCode)
	 as  DeptEmployeeReceptions

,Intervals.intervalsStr as nonIntersectedInterv	
,Intervals.intervalsValues_str  as intervalsValues
,Intervals.intervalsSum_minu as intervalsSum

---------------------------------
from dept  as d
left join dept as chieldDept on d.deptCode = chieldDept.subAdministrationCode   
join dept as d1 on d.deptCode = d1.deptCode
	and d.IsCommunity = 1
	AND (@DistrictCodes = '-1' or d.districtCode IN (SELECT IntField FROM dbo.SplitString(@DistrictCodes))
							   or d.DeptCode IN (SELECT x_Dept_District.DeptCode FROM dbo.SplitString(@DistrictCodes) as T
							   JOIN  x_Dept_District ON T.IntField = x_Dept_District.districtCode)	)
	AND (@AdminClinicCode = '-1' or  d.administrationCode IN (SELECT IntField FROM dbo.SplitString( @AdminClinicCode)) )
	and d.status = 1
	
join x_Dept_Employee on
(
	 (@IncludeSubClinicEmployees_cond = '1'
	 and (x_Dept_Employee.deptCode = d.deptCode
	or x_Dept_Employee.deptCode = chieldDept.deptCode))
	or
	(@IncludeSubClinicEmployees_cond <> '1'
	 and x_Dept_Employee.deptCode = d.deptCode
	) 
)
and x_Dept_Employee.active = 1

join Employee on x_Dept_Employee.employeeID = Employee.employeeID
	and Employee.active = 1
	and (@EmployeeSector_cond = '-1' or Employee.EmployeeSectorCode = @EmployeeSector_cond)

JOIN View_EmployeeSector on Employee.EmployeeSectorCode = View_EmployeeSector.EmployeeSectorCode
------------------
left join dept as dDistrict on d.districtCode = dDistrict.deptCode 
left join dept as dAdmin on d.administrationCode = dAdmin.deptCode    
left join deptSimul on d.DeptCode = deptSimul.DeptCode 	

join deptEmployeeReception  on x_Dept_Employee.DeptEmployeeID = deptEmployeeReception.DeptEmployeeID

JOIN DIC_ReceptionDays on deptEmployeeReception.receptionDay = DIC_ReceptionDays.ReceptionDayCode

cross apply rfn_GetDepServicetAndDeptEmployeeReceptionIntervalNonIntersection
	(d.deptCode, x_Dept_Employee.DeptEmployeeID, 
	deptEmployeeReception.receptionDay, @ReceptionHoursSpan_cond) as Intervals

) as resultTable
order by DeptCode, ServiceDeptCode, EmployeeDeptCode,  ReceptionDayName

SET DATEFORMAT mdy;

RETURN 

GO
GRANT EXEC ON [dbo].rprt_DeptOfficeAndDeptEmployeeReceptionDifferences TO PUBLIC
GO

------------ End Reports changes - by Maria
-- **********************************************************************************************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_CascadeEmployeeServiceQueueOrderFromDept')
    BEGIN
	    DROP  Procedure  rpc_CascadeEmployeeServiceQueueOrderFromDept
    END

GO

CREATE Procedure dbo.rpc_CascadeEmployeeServiceQueueOrderFromDept
(
	@x_dept_employee_serviceID INT,
	@updateUser VARCHAR(100)
)

AS


DELETE EmployeeServiceQueueOrderMethod
WHERE x_dept_employee_serviceID = @x_dept_employee_serviceID


UPDATE x_dept_employee_service
SET QueueOrder = null, UpdateDate = GETDATE(), UpdateUser = @updateUser
WHERE x_dept_employee_serviceID = @x_dept_employee_serviceID

                
GO


GRANT EXEC ON rpc_CascadeEmployeeServiceQueueOrderFromDept TO PUBLIC

GO            

-- **********************************************************************************************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertDeptEmployeeService')
	BEGIN
		DROP  Procedure  rpc_insertDeptEmployeeService
	END

GO

CREATE Procedure dbo.rpc_insertDeptEmployeeService
	(
		@deptEmployeeID INT,
		@ServiceCodes varchar(50),
		@UpdateUser varchar(50),
		@ErrCode int OUTPUT
	)

AS

DECLARE @count int, @currentCount int, @OrderNumber int
DECLARE @CurrServiceCode int
DECLARE @employeeID BIGINT
DECLARE @deptEmployeeServiceID INT
SET @OrderNumber = 1

SET @count = IsNull((SELECT COUNT(IntField) FROM SplitString(@ServiceCodes)), 0)
IF (@count = 0)
BEGIN
	RETURN
END

	
SET @employeeID =  (SELECT EmployeeID
					FROM x_dept_employee
					WHERE DeptEmployeeID = @deptEmployeeID
					)					
		
	
	SET @currentCount = @count
	
	WHILE(@currentCount > 0)
		BEGIN
		
			SET @CurrServiceCode = (SELECT IntField FROM SplitString(@ServiceCodes) WHERE OrderNumber = @OrderNumber) 
			
			-- first of all, insert as employee service if not exists
			IF NOT EXISTS (SELECT ServiceCode 
						   FROM EmployeeServices
						   WHERE ServiceCode = @CurrServiceCode AND EmployeeID = @employeeID
						   )
					INSERT INTO EmployeeServices (EmployeeID, serviceCode, updateUser)
					VALUES (@EmployeeID, @CurrServiceCode, @UpdateUser)
							   
			
			IF NOT EXISTS (SELECT ServiceCode
						   FROM x_Dept_Employee_Service xdes						   
						   WHERE ServiceCode = @CurrServiceCode 
						   AND DeptEmployeeID = @deptEmployeeID						   
						   )
				BEGIN				
					
					INSERT INTO x_Dept_Employee_Service
					( serviceCode, UpdateDate, updateUser, CascadeUpdateEmployeeServicePhones, DeptEmployeeID)
					VALUES
					(@CurrServiceCode, GETDATE(), @UpdateUser, 1, @deptEmployeeID)
					
					SET @deptEmployeeServiceID = @@IDENTITY

					INSERT INTO DeptEmployeeServiceStatus 
					(Status, FromDate, UpdateUser, UpdateDate, x_dept_employee_serviceID)
					VALUES 
					(1, GETDATE(), @UpdateUser, GETDATE(), @deptEmployeeServiceID) 					
				END
	
			SET @OrderNumber = @OrderNumber + 1
			SET @currentCount = @currentCount - 1
		END
		
		
	-- Delete all the receptions of the services that were just deleted
	SELECT der.receptionid
	INTO #tempServiceIds
	FROM DeptEmployeeReception der 	
	INNER JOIN deptEmployeeReceptionServices ders	
	ON der.ReceptionID = ders.ReceptionID
	WHERE der.DeptEmployeeID = @deptEmployeeID
	AND ServiceCode NOT IN	(
									SELECT ServiceCode
									FROM x_Dept_Employee_Service
									WHERE DeptEmployeeID = @deptEmployeeID
								)
	
	
	DELETE FROM DeptEmployeeReceptionServices
	WHERE ReceptionID IN 
			(
				SELECT ReceptionID
				FROM #tempServiceIds  
			)
			
	DELETE DeptEmployeeReceptionRemarks
	WHERE EmployeeReceptionID IN
	(
		SELECT ReceptionID
		FROM #tempServiceIds  
	)
	
	
	DELETE DeptEmployeeReception
	WHERE ReceptionID IN 
	(
		SELECT ReceptionID
		FROM #tempServiceIds  
	)		
						
	SET @ErrCode = @@Error
	


GO

GRANT EXEC ON rpc_insertDeptEmployeeService TO PUBLIC

GO


-- **********************************************************************************************************************

--**** Yaniv - Start rfn_GetDeptEmployeeRemarkDescriptionsHTML **************************
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'rfn_GetDeptEmployeeRemarkDescriptionsHTML')
	BEGIN
		DROP  FUNCTION  rfn_GetDeptEmployeeRemarkDescriptionsHTML
	END

GO

CREATE function [dbo].[rfn_GetDeptEmployeeRemarkDescriptionsHTML](@DeptEmployeeID bigint) 
RETURNS varchar(500)
WITH EXECUTE AS CALLER

AS
BEGIN

	declare @RemarksStr varchar(500) 
	set @RemarksStr = ''
	
	SELECT @RemarksStr = @RemarksStr +  CASE @RemarksStr WHEN '' THEN '' ELSE '<br>' END + REPLACE(RemarkText, '#', '') 
	FROM
		(select distinct EmployeeRemarks.EmployeeRemarkID, EmployeeRemarks.RemarkText
		from x_Dept_Employee_EmployeeRemarks as xDER
		inner join EmployeeRemarks on xDER.EmployeeRemarkID = EmployeeRemarks.EmployeeRemarkID
			and xDER.DeptEmployeeID = @DeptEmployeeID 
			
		) as d 
	order by d.RemarkText
	
	return (@RemarksStr);
end 

go 
grant exec on rfn_GetDeptEmployeeRemarkDescriptionsHTML to public 
go

--**** Yaniv - End rfn_GetDeptEmployeeRemarkDescriptionsHTML **************************

--**** Yaniv - Start vEmployeeProfessionalDetails ***********************

 
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'vEmployeeProfessionalDetails')
	BEGIN
		DROP  view  vEmployeeProfessionalDetails
	END

GO

CREATE VIEW [dbo].[vEmployeeProfessionalDetails]
AS
SELECT  	dbo.x_Dept_Employee.deptCode, dbo.rfn_GetDeptEmployeeRemarkDescriptionsHTML(x_Dept_Employee.deptEmployeeID) 
					  AS EmployeeRemark, dbo.Employee.employeeID, 
					  dbo.DIC_EmployeeDegree.DegreeName + ' ' + dbo.Employee.lastName + ' ' + dbo.Employee.firstName AS EmployeeName, 
					  dbo.fun_GetEmployeeExpert(dbo.Employee.employeeID) AS Experties, 
					  dbo.rfn_GetDeptEmployeeProfessionDescriptions(dbo.x_Dept_Employee.deptCode, dbo.x_Dept_Employee.employeeID) AS ProfessionDescriptions, 
					  dbo.rfn_GetDeptEmployeesServiceDescriptions(dbo.x_Dept_Employee.deptCode, dbo.x_Dept_Employee.employeeID) AS ServiceDescriptions, 
					  dbo.rfn_GetDeptEmployeeQueueOrderDescriptionsHTML(dbo.x_Dept_Employee.deptCode, dbo.x_Dept_Employee.employeeID) 
					  AS QueueOrderDescriptions, dbo.rfn_GetDeptEmployeeRemarkDescriptionsHTML(x_Dept_Employee.deptEmployeeID) AS HTMLRemarks, dbo.Employee.EmployeeSectorCode,
					  orderNumber = dbo.fun_getEmployeeOrderByProfessionInDept(dbo.x_Dept_Employee.deptCode ,dbo.x_Dept_Employee.employeeID),
					  CASE CascadeUpdateDeptEmployeePhonesFromClinic 
						WHEN 0 THEN [dbo].[fun_GetDeptEmployeePhonesOnly](x_Dept_Employee.employeeID,x_Dept_Employee.deptCode) ELSE '' END as Phones,
					  Employee.IsMedicalTeam
FROM         dbo.x_Dept_Employee 
INNER JOIN dbo.Employee ON dbo.x_Dept_Employee.employeeID = dbo.Employee.employeeID 
INNER JOIN dbo.DIC_EmployeeDegree ON dbo.Employee.degreeCode = dbo.DIC_EmployeeDegree.DegreeCode 
LEFT OUTER JOIN dbo.DIC_QueueOrder ON dbo.x_Dept_Employee.QueueOrder = dbo.DIC_QueueOrder.QueueOrder
WHERE x_Dept_Employee.active <> 0

GO
  
grant select on vEmployeeProfessionalDetails to public 

go
--**** Yaniv - End vEmployeeProfessionalDetails ***********************

--**** Yaniv - Start rpc_GetEmployeeServiceInDeptStatus *****************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetEmployeeServiceInDeptStatus')
	BEGIN
		DROP  Procedure  rpc_GetEmployeeServiceInDeptStatus
	END

GO

CREATE Procedure dbo.rpc_GetEmployeeServiceInDeptStatus
(
	@employeeID  BIGINT,
	@deptCode	 INT,
	@serviceCode INT
)

AS


SELECT dess.Status, statusDescription, FromDate, ToDate
FROM DeptEmployeeServiceStatus dess
INNER JOIN DIC_ActivityStatus dic ON dess.Status = dic.Status
join x_Dept_Employee_Service xDES on dess.x_dept_employee_serviceID=xDES.x_Dept_Employee_ServiceID
join x_Dept_Employee xDE on xDES.DeptEmployeeID=xDE.DeptEmployeeID
WHERE xDE.EmployeeID = @employeeID
AND xDE.DeptCode = @deptCode
AND ServiceCode = @serviceCode
ORDER BY FromDate


GO


GRANT EXEC ON rpc_GetEmployeeServiceInDeptStatus TO PUBLIC

GO

--**** Yaniv - End rpc_GetEmployeeServiceInDeptStatus *****************


----- 19/02/2012 julia --------------
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_DeptOfficeAndDeptEmployeeReceptionDifferences')
	BEGIN
		DROP  Procedure  dbo.rprt_DeptOfficeAndDeptEmployeeReceptionDifferences
	END
GO

CREATE Procedure dbo.rprt_DeptOfficeAndDeptEmployeeReceptionDifferences
(
	@DistrictCodes varchar(max)=null,
	@AdminClinicCode varchar(max)=null,
	@ReceptionHoursSpan_cond varchar(max)=null,
	@EmployeeSector_cond varchar(max) = null,
	@IncludeSubClinicEmployees_cond varchar (2)=null,
	@IsExcelVersion varchar (2)=null,
	@ErrCode varchar(max) OUTPUT
-----------------------------------------
)with recompile

AS
--------------------------------------

DECLARE @NewLineChar AS CHAR(2) 
set @NewLineChar = CHAR(13) + CHAR(10)

DECLARE @ReceptionHoursSpan int
if (@ReceptionHoursSpan_cond is null or @ReceptionHoursSpan_cond = '-1' or ISDATE(@ReceptionHoursSpan_cond)= 0)
		set @ReceptionHoursSpan = 24*60 
		--CAST('00:00' as time(0))
	else
		set @ReceptionHoursSpan = datediff(minute,'00:00', @ReceptionHoursSpan_cond)
		--CAST(@ReceptionHoursSpan_cond as time(0))
		
SET DATEFORMAT dmy;

SELECT distinct *  from
(select 
 dDistrict.DeptName as DistrictName 
, dDistrict.deptCode as DeptCode 
, dAdmin.DeptName as AdminClinicName 
, dAdmin.DeptCode as AdminClinicCode
				 
,d.DeptCode as ServiceDeptCode 
,x_Dept_Employee.DeptCode as EmployeeDeptCode 

,(select ReceptionTypeDescription from DIC_ReceptionHoursTypes where ReceptionHoursTypeID = 2) as ServiceDescription 
,(select ReceptionHoursTypeID from DIC_ReceptionHoursTypes where ReceptionHoursTypeID = 2) as ServiceCode 

,Employee.employeeID as employeeID
,Employee.firstName as EmployeeFirstName 
,Employee.lastName as EmployeeLastName 
,View_EmployeeSector.EmployeeSectorCode -- for test
,View_EmployeeSector.EmployeeSectorDescription -- for test

,DIC_ReceptionDays.ReceptionDayName as ReceptionDayName

,dbo.rfn_GetDeptReceptionsString(d.deptCode, DIC_ReceptionDays.ReceptionDayCode, 2)
	 as  DeptServiceReceptions
,dbo.rfn_GetDeptEmployeeReceptionsString(x_Dept_Employee.DeptEmployeeID, DIC_ReceptionDays.ReceptionDayCode)
	 as  DeptEmployeeReceptions

,Intervals.intervalsStr as nonIntersectedInterv	
,Intervals.intervalsValues_str  as intervalsValues
,Intervals.intervalsSum_minu as intervalsSum

---------------------------------
from dept  as d
left join dept as chieldDept on d.deptCode = chieldDept.subAdministrationCode   
join dept as d1 on d.deptCode = d1.deptCode
	and d.IsCommunity = 1
	AND (@DistrictCodes = '-1' or  d.districtCode IN (SELECT IntField FROM dbo.SplitString( @DistrictCodes)) )
	AND (@AdminClinicCode = '-1' or  d.administrationCode IN (SELECT IntField FROM dbo.SplitString( @AdminClinicCode)) )
	and d.status = 1
	
join x_Dept_Employee on
(
	 (@IncludeSubClinicEmployees_cond = '1'
	 and (x_Dept_Employee.deptCode = d.deptCode
	or x_Dept_Employee.deptCode = chieldDept.deptCode))
	or
	(@IncludeSubClinicEmployees_cond <> '1'
	 and x_Dept_Employee.deptCode = d.deptCode
	) 
)
and x_Dept_Employee.active = 1

join Employee on x_Dept_Employee.employeeID = Employee.employeeID
	and Employee.active = 1
	and (@EmployeeSector_cond = '-1' or Employee.EmployeeSectorCode = @EmployeeSector_cond)

JOIN View_EmployeeSector on Employee.EmployeeSectorCode = View_EmployeeSector.EmployeeSectorCode
------------------
left join dept as dDistrict on d.districtCode = dDistrict.deptCode 
left join dept as dAdmin on d.administrationCode = dAdmin.deptCode    
left join deptSimul on d.DeptCode = deptSimul.DeptCode 	

join deptEmployeeReception  on x_Dept_Employee.DeptEmployeeID = deptEmployeeReception.DeptEmployeeID

JOIN DIC_ReceptionDays on deptEmployeeReception.receptionDay = DIC_ReceptionDays.ReceptionDayCode

cross apply rfn_GetDepServicetAndDeptEmployeeReceptionIntervalNonIntersection
	(d.deptCode, x_Dept_Employee.DeptEmployeeID, 
	deptEmployeeReception.receptionDay, @ReceptionHoursSpan_cond) as Intervals

) as resultTable
order by DeptCode, ServiceDeptCode, EmployeeDeptCode,  ReceptionDayName

SET DATEFORMAT mdy;

RETURN 

GO
GRANT EXEC ON [dbo].rprt_DeptOfficeAndDeptEmployeeReceptionDifferences TO PUBLIC
GO



-- **********************************************************************************************************************

--**** Yaniv - Start vDeptEvents ***********************************

 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'vDeptEvents')
	BEGIN
		DROP  view  vDeptEvents
	END

GO



create VIEW [dbo].[vDeptEvents]
AS
SELECT     dbo.DeptEvent.DeptEventID, dbo.DIC_Events.EventCode, dbo.DIC_Events.EventName, dbo.DIC_RegistrationStatus.registrationStatusDescription, dbo.DeptEvent.MeetingsNumber,
                          fromDate,toDate,
                          (SELECT     TOP (1) Date
                            FROM          dbo.DeptEventParticulars
                            WHERE      (DeptEventID = dbo.DeptEvent.DeptEventID)
                            ORDER BY Date) AS FirstEventDate, dbo.DeptEvent.deptCode
FROM         dbo.DeptEvent INNER JOIN
                      dbo.DIC_Events ON dbo.DeptEvent.EventCode = dbo.DIC_Events.EventCode INNER JOIN
                      dbo.DIC_RegistrationStatus ON dbo.DeptEvent.RegistrationStatus = dbo.DIC_RegistrationStatus.registrationStatus
					  where (DATEDIFF(dd, FromDate, GetDate()) >= 0 AND DATEDIFF(dd, ToDate, GetDate()) <= 0 )
GO


grant select on vDeptEvents to public 

go


--**** Yaniv - End vDeptEvents ***********************************  

-- **********************************************************************************************************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteEmployeeServiceInDeptStatus')
	BEGIN
		DROP  Procedure  rpc_DeleteEmployeeServiceInDeptStatus
	END

GO

CREATE Procedure dbo.rpc_DeleteEmployeeServiceInDeptStatus
(	
	@employeeID BIGINT,
	@deptCode INT,
	@serviceCode INT
)

AS

DELETE DeptEmployeeServiceStatus 
FROM DeptEmployeeServiceStatus dess
INNER JOIN x_dept_employee_service xdes ON dess.x_dept_employee_serviceID = xdes.x_dept_employee_serviceID
INNER JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
WHERE xd.EmployeeID = @employeeID
AND xd.DeptCode = @deptCode
AND xdes.ServiceCode = @serviceCode


GO


GRANT EXEC ON rpc_DeleteEmployeeServiceInDeptStatus TO PUBLIC

GO

-- **********************************************************************************************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetMushlamModelsForService')
    BEGIN
	    DROP  Procedure  rpc_GetMushlamModelsForService
    END

GO

CREATE Procedure dbo.rpc_GetMushlamModelsForService
(
	@serviceCode INT
)

AS

SELECT models.GroupCode, models.SubGroupCode, models.ModelDescription, models.Remark, 
		models.ParticipationAmount, IsNull(models.WaitingPeriod, 0) as WaitingPeriod
FROM MushlamModels models
INNER JOIN MushlamServicesInformation msi 
ON models.GroupCode = msi.GroupCode AND models.SubGroupCode = msi.SubGroupCode
WHERE msi.ServiceCode = @serviceCode
AND msi.HasModels <> 0
AND ServiceType <> 4

                
GO


GRANT EXEC ON rpc_GetMushlamModelsForService TO PUBLIC

GO            

-- **********************************************************************************************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertEmployeeServiceInDeptStatus')
	BEGIN
		DROP  Procedure  rpc_InsertEmployeeServiceInDeptStatus
	END

GO

CREATE Procedure dbo.rpc_InsertEmployeeServiceInDeptStatus
(
	@employeeID BIGINT,
	@deptCode INT, 
	@serviceCode INT, 
	@status SMALLINT, 
	@fromDate DATETIME, 
	@toDate DATETIME,
	@userName VARCHAR(30)
)

AS

INSERT INTO DeptEmployeeServiceStatus (Status, FromDate, ToDate, UpdateUser, UpdateDate, x_dept_employee_serviceID)
SELECT @status , @fromDate , @toDate , @userName , GETDATE(), x_dept_employee_serviceID
FROM x_dept_employee xd
INNER JOIN x_dept_employee_service xdes ON xd.DeptEmployeeID = xdes.DeptEmployeeID
WHERE xd.EmployeeID = @employeeID
AND xd.DeptCode = @deptCode
AND xdes.ServiceCode = @serviceCode


GO


GRANT EXEC ON rpc_InsertEmployeeServiceInDeptStatus TO PUBLIC

GO

-- **********************************************************************************************************************

--**** Yaniv - Satrt rpc_getEmployeeListForSpotting_MF *******************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeeListForSpotting_MF')
	BEGIN
		DROP  Procedure  rpc_getEmployeeListForSpotting_MF
	END

GO

CREATE Procedure dbo.rpc_getEmployeeListForSpotting_MF
	(
	@FirstName varchar(50)=null,
	@LastName varchar(50)=null,
	@LicenseNumber int = null,
	@EmployeeID int=null
	)

AS

SELECT DISTINCT T226.* FROM
(SELECT
	FirstName,
	FamilyName as lastName,
	Gender,
	EmployeeID = CAST( CAST(PersonID as varchar(10)) + CAST(IDControlDigit as varchar(1)) as bigint),
	CASE WHEN DocLicenseNumber <> 0 THEN DocLicenseNumber
		 WHEN DocLicenseNumber = 0 AND DentalLicenseNumber <> 0 THEN DentalLicenseNumber
		 ELSE 0 END as licenseNumber,
	CASE WHEN DocLicenseNumber <> 0 THEN ''
		 WHEN DocLicenseNumber = 0 AND DentalLicenseNumber <> 0 THEN '(שיניים)'
		 ELSE '' END as IsDental,
	CASE WHEN DocLicenseNumber <> 0 THEN 0
		 WHEN DocLicenseNumber = 0 AND DentalLicenseNumber <> 0 THEN 1
		 ELSE 0 END as IsDentalBit

	FROM TR_DoctorsInfo226 WHERE delFlag = 0 AND DeadDate is null
) as T226
LEFT JOIN Employee E ON T226.licenseNumber = E.licenseNumber
	AND T226.IsDentalBit = E.IsDental

WHERE T226.EmployeeID NOT IN (SELECT EmployeeID FROM Employee WHERE IsInCommunity = 1)
AND (@EmployeeID is null OR T226.employeeID = @EmployeeID)
AND (@LicenseNumber is null OR T226.licenseNumber = @LicenseNumber)
AND (@FirstName is null OR T226.firstName LIKE @FirstName + '%')
AND (@LastName is null OR T226.lastName LIKE @LastName + '%')
 
 
GO

GRANT EXEC ON rpc_getEmployeeListForSpotting_MF TO PUBLIC

GO


--**** Yaniv - End rpc_getEmployeeListForSpotting_MF *******************

--**** Yaniv - Start vServicesReceptionWithRemarks ***************************
  IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'vServicesReceptionWithRemarks')
	BEGIN
		DROP  view  vServicesReceptionWithRemarks
	END

GO

CREATE VIEW [dbo].[vServicesReceptionWithRemarks]
AS
SELECT     TOP (100) PERCENT DERS.receptionID, xDE.deptCode, DERS.serviceCode, DER.receptionDay, DER.openingHour, DER.closingHour, 
                      CASE closingHour WHEN '00:00' THEN CASE openingHour WHEN '00:01' THEN '24' WHEN '01:00' THEN '24' WHEN '00:00' THEN '24' ELSE openingHour
                       + '-' END WHEN '23:59' THEN CASE openingHour WHEN '00:01' THEN '24' WHEN '01:00' THEN '24' WHEN '00:00' THEN '24' ELSE openingHour + '-' END
                       ELSE openingHour + '-' END + CASE closingHour WHEN '00:00' THEN CASE openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN
                       '00:00' THEN 'שעות' ELSE closingHour END WHEN '23:59' THEN CASE openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN '00:00'
                       THEN 'שעות' ELSE closingHour END ELSE closingHour END + CASE dbo.fun_GetDeptServiceHoursRemarks(DER.receptionID) 
                      WHEN '' THEN '' ELSE '<br>' + dbo.fun_GetDeptServiceHoursRemarks(DER.receptionID) END AS OpeningHourText,
					  Employee.IsMedicalTeam                      
FROM
	deptEmployeeReceptionServices DERS join [Services]
	on dERS.serviceCode = [Services].ServiceCode
	join deptEmployeeReception DER on DERS.receptionID = DER.receptionID
	join x_Dept_Employee xDE on DER.DeptEmployeeID = xDE.DeptEmployeeID
	join Employee on Employee.employeeID = xDE.employeeID
WHERE (DER.validFrom IS NOT NULL) AND (DER.validTo IS NULL) AND (GETDATE() >= DER.validFrom) OR
                      (DER.validFrom IS NULL) AND (DER.validTo IS NOT NULL) AND (DER.validTo >= GETDATE()) OR
                      (DER.validFrom IS NOT NULL) AND (DER.validTo IS NOT NULL) AND (GETDATE() >= DER.validFrom) AND (DER.validTo >= GETDATE()) OR
                      (DER.validFrom IS NULL) AND (DER.validTo IS NULL)
ORDER BY DERS.serviceCode, DER.receptionDay, DER.openingHour

GO

grant select on vServicesReceptionWithRemarks to public 
GO
  
  
--**** Yaniv - End vServicesReceptionWithRemarks ***************************

--**** Yaniv - Start vDeptReceptionHours *************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'vDeptReceptionHours')
BEGIN
	DROP  view  vDeptReceptionHours
END
GO

create VIEW [dbo].[vDeptReceptionHours]
AS
SELECT     TOP (100) PERCENT dbo.DeptReception.receptionID, dbo.DeptReception.deptCode, dbo.DeptReception.receptionDay, dbo.DeptReception.openingHour, 
                      dbo.DeptReception.closingHour, dbo.fun_getDeptReceptionRemarksValid(dbo.DeptReception.receptionID) AS RemarkText, 
                      CASE closingHour WHEN '00:00' THEN CASE openingHour WHEN '00:01' THEN '24 ' WHEN '01:00' THEN '24 ' WHEN '00:00' THEN '24 ' ELSE openingHour
                       + '-' END WHEN '23:59' THEN CASE openingHour WHEN '00:01' THEN '24 ' WHEN '01:00' THEN '24 ' WHEN '00:00' THEN '24 ' ELSE openingHour + '-'
                       END ELSE openingHour + '-' END + CASE closingHour WHEN '00:00' THEN CASE openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN
                       '00:00' THEN 'שעות' ELSE closingHour END WHEN '23:59' THEN CASE openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN '00:00'
                       THEN 'שעות' ELSE closingHour END ELSE closingHour END + CASE dbo.fun_getDeptReceptionRemarksValid(receptionID) 
                      WHEN '' THEN '' ELSE '<br>' + dbo.fun_getDeptReceptionRemarksValid(receptionID) END AS 'openingHourText',
                      DeptReception.ReceptionHoursTypeID,
                      dRH.ReceptionTypeDescription
FROM         dbo.DeptReception INNER JOIN
                      dbo.DIC_ReceptionDays ON dbo.DeptReception.receptionDay = dbo.DIC_ReceptionDays.ReceptionDayCode AND 
                      (dbo.DeptReception.validFrom IS NOT NULL AND dbo.DeptReception.validTo IS NULL AND GETDATE() >= dbo.DeptReception.validFrom OR
                      dbo.DeptReception.validFrom IS NULL AND dbo.DeptReception.validTo IS NOT NULL AND dbo.DeptReception.validTo >= GETDATE() OR
                      dbo.DeptReception.validFrom IS NOT NULL AND dbo.DeptReception.validTo IS NOT NULL AND GETDATE() >= dbo.DeptReception.validFrom AND 
                      dbo.DeptReception.validTo >= GETDATE() OR
                      dbo.DeptReception.validFrom IS NULL AND dbo.DeptReception.validTo IS NULL)
                      join DIC_ReceptionHoursTypes dRH on DeptReception.ReceptionHoursTypeID = dRH.ReceptionHoursTypeID
ORDER BY dbo.DeptReception.receptionDay, dbo.DeptReception.openingHour


GO


  
grant select on vDeptReceptionHours to public 

go
--**** Yaniv - End vDeptReceptionHours *************************



--**** Yaniv - Start rpc_GetZoomClinicTemplate *****************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetZoomClinicTemplate')
	BEGIN
		DROP  Procedure  rpc_GetZoomClinicTemplate
	END

GO

CREATE Procedure [dbo].[rpc_GetZoomClinicTemplate]
(
	@DeptCode int,
	@IsInternal bit, -- true internal, false external
	@DeptCodesInArea varchar(max)
)

AS


--****** deptUpdateDate   ********

DECLARE @LastUpdateDateOfRemarks smalldatetime
DECLARE @LastUpdateDateOfDept smalldatetime
DECLARE @CurrentDate smalldatetime

SET @LastUpdateDateOfDept = (SELECT updateDate FROM dept WHERE deptCode = @DeptCode)
SET @LastUpdateDateOfRemarks = IsNull((SELECT MAX(updateDate) FROM View_Remarks WHERE deptCode = @deptCode), '01/01/1900')
SET @CurrentDate = GETDATE()

IF(@LastUpdateDateOfDept >= @LastUpdateDateOfRemarks)
	BEGIN
		SELECT  @LastUpdateDateOfDept as 'LastUpdateDateOfDept'	
	END
ELSE
	BEGIN
		SELECT  @LastUpdateDateOfRemarks as 'LastUpdateDateOfDept'
	END




--*****   dept All Details  *****
SELECT 
deptCode,
deptName,
UnitTypeName,
subUnitTypeName,
managerName, 
administrativeManagerName,
geriatricsManagerName,
pharmacologyManagerName,
districtName,
cityName,
addressComment,
email,
'phones' = REPLACE(phones,',','<br />'),
faxes,
simpleAddress,
parking,
PopulationSectorDescription,
statusDescription,
transportation,
AdministrationName,
subAdministrationName,
Simul228,
deptLevelDescription,
handicappedFacilities
 FROM vAllDeptDetails WHERE DeptCode = @DeptCode

----------------------------- Dept Reception Hours 
SELECT [receptionID]
      ,[deptCode]
      ,[receptionDay]
      ,[openingHour]
      ,[closingHour]
      ,[RemarkText] = dbo.rfn_GetFotmatedRemark(RemarkText)
      ,[openingHourText]
      ,ReceptionHoursTypeID
      ,ReceptionTypeDescription
  FROM [dbo].[vDeptReceptionHours]
  WHERE DeptCode = @DeptCode
  order by ReceptionHoursTypeID
  --******  dept Remarks   ********
SELECT remarkID,
RemarkText = dbo.rfn_GetFotmatedRemark(RemarkText),
validFrom,
validTo,
displayInInternet, 
RemarkDeptCode as deptCode,
--View_DeptRemarks.IsSharedRemark as 'sweeping', 
ShowOrder
FROM View_DeptRemarks
WHERE deptCode = @deptCode
AND (@IsInternal = 1 OR displayInInternet = 1)
AND (validFrom is null OR validFrom <= @CurrentDate)
AND (validTo is null OR validTo >= @CurrentDate)
ORDER BY IsSharedRemark desc ,ShowOrder asc 

------------ sub unit/dept All Details
SELECT
V.deptCode,
V.deptName,
V.UnitTypeName,
V.subUnitTypeName,
V.managerName, 
V.administrativeManagerName,
V.geriatricsManagerName,
V.pharmacologyManagerName,
V.districtName,
V.cityName,
V.addressComment,
V.email,
V.phones,
V.faxes,
V.simpleAddress,
V.parking,
V.PopulationSectorDescription,
V.statusDescription,
V.transportation,
V.AdministrationName,
V.subAdministrationName,
V.Simul228,
V.deptLevelDescription,
V.handicappedFacilities
FROM vAllDeptDetails V 
 JOIN Dept D ON V.deptCode = D.deptCode
 WHERE V.DeptCode in ( SELECT [deptCode]      
  FROM [dbo].[Dept]
where subAdministrationCode = @DeptCode) 
AND D.status = 1
----- sub unit/dept Reception Hours of  

SELECT V.[receptionID]
      ,V.[deptCode]
      ,V.[receptionDay]
      ,V.[openingHour]
      ,V.[closingHour]
      ,V.[RemarkText]
      ,V.[openingHourText]
      ,V.ReceptionHoursTypeID
      ,V.ReceptionTypeDescription
  FROM [dbo].[vDeptReceptionHours] V
  JOIN Dept D ON V.deptCode = D.deptCode
  WHERE V.DeptCode in ( SELECT [deptCode]      
  FROM [dbo].[Dept]
where subAdministrationCode = @DeptCode)
AND D.status = 1

-----sub depts/units remarks
SELECT remarkID,
RemarkText = dbo.rfn_GetFotmatedRemark(RemarkText),
validFrom,
validTo,
displayInInternet, 
V.deptCode,
--View_DeptRemarks.IsSharedRemark as 'sweeping', 
ShowOrder
FROM View_DeptRemarks V
JOIN Dept D ON V.deptCode = D.deptCode
where V.deptCode in
( SELECT [deptCode]      
  FROM [dbo].[Dept]
where subAdministrationCode = @DeptCode)
AND (validFrom is null OR validFrom <= @CurrentDate)
AND (validTo is null OR validTo >= @CurrentDate)
AND (@IsInternal = 1 OR displayInInternet = 1)
AND D.status = 1
ORDER BY IsSharedRemark desc ,ShowOrder asc 


------------IN AREA -  unit/dept All Details 

SELECT 
deptCode,
deptName,
UnitTypeName,
subUnitTypeName,
managerName, 
administrativeManagerName,
geriatricsManagerName,
pharmacologyManagerName,
districtName,
cityName,
addressComment,
email,
'phones' = REPLACE(phones,',','<br />'),
faxes,
simpleAddress,
parking,
PopulationSectorDescription,
statusDescription,
transportation,
AdministrationName,
subAdministrationName,
Simul228,
deptLevelDescription,
handicappedFacilities
 FROM vAllDeptDetails 
 WHERE DeptCode in (  select ItemID from dbo.rfn_SplitStringValues(@DeptCodesInArea))
----- IN AREA -  unit/dept Reception Hours of  

SELECT [receptionID]
      ,[deptCode]
      ,[receptionDay]
      ,[openingHour]
      ,[closingHour]
      ,[RemarkText] = dbo.rfn_GetFotmatedRemark(RemarkText)
      ,[openingHourText]
      ,ReceptionHoursTypeID
      ,ReceptionTypeDescription
  FROM [dbo].[vDeptReceptionHours]
  WHERE DeptCode in (  select ItemID from dbo.rfn_SplitStringValues(@DeptCodesInArea))
  order by ReceptionHoursTypeID
----- IN AREA - depts/units remarks
SELECT remarkID,
RemarkText = dbo.rfn_GetFotmatedRemark(RemarkText),
validFrom,
validTo,
displayInInternet, 
deptCode,
--View_DeptRemarks.IsSharedRemark as 'sweeping', 
ShowOrder
FROM View_DeptRemarks
where deptCode in (  select ItemID from dbo.rfn_SplitStringValues(@DeptCodesInArea))
AND (validFrom is null OR validFrom <= @CurrentDate)
AND (validTo is null OR validTo >= @CurrentDate)
AND (@IsInternal = 1 OR displayInInternet = 1)
ORDER BY IsSharedRemark desc ,ShowOrder asc 


---------------------- Employee ReceptionHours
SELECT     deptCode, receptionID, EmployeeID,
 receptionDay, openingHour, closingHour, ReceptionDayName,
  OpeningHourText,EmployeeSectorCode
FROM         dbo.vEmployeeReceptionHours
where deptCode = @DeptCode

--employee reception hours remarks
SELECT TOP 1000 [RemarkText]
      ,[EmployeeID]
      ,[EmployeeSectorCode]
      ,[receptionID]
      ,[deptCode]
  FROM [dbo].[vEmployeeReceptionRemarks]
where deptCode = @DeptCode

------------------ Employee services, Experties in the given dept
SELECT [deptCode]
      ,[EmployeeRemark]
      ,[employeeID]
      ,[EmployeeName]
      ,[Experties] = '<br/>' + [Experties]
      ,[ProfessionDescriptions]
	  ,ServiceDescriptions = 
			REPLACE( [ProfessionDescriptions] + CASE WHEN LEN([ProfessionDescriptions]) > 0 AND LEN([ServiceDescriptions]) > 0 THEN ', ' ELSE '' END + [ServiceDescriptions], ';', ',')
      ,[QueueOrderDescriptions]
      ,[HTMLRemarks]
      ,[EmployeeSectorCode]
	  ,Phones
  FROM [dbo].[vEmployeeProfessionalDetails]
  WHERE DeptCode = @DeptCode
  and IsMedicalTeam = 0 
  ORDER BY orderNumber, ProfessionDescriptions	

-----------------------------------
------------------ Employee remarks in dept

SELECT [EmployeeRemarkID]
      ,[EmployeeID]
      ,[DicRemarkID]
      ,[RemarkText] = dbo.rfn_GetFotmatedRemark(RemarkText)
      ,[displayInInternet]
      ,[AttributedToAllClinics]
      ,[ValidFrom]
      ,[ValidTo]
      ,[DeptCode]
      ,EmployeeSectorCode
  FROM [dbo].[vEmployeeDeptRemarks]
  WHERE DeptCode = @DeptCode
	AND (@IsInternal = 1 OR displayInInternet = 1)

-----------------------------event details
SELECT V.[EventCode]
      ,V.[EventName]
      ,V.[registrationStatusDescription]
      ,V.[MeetingsNumber]
      ,V.[FirstEventDate]
      ,V.[deptCode]
  FROM [dbo].[vDeptEvents] V
  JOIN DeptEvent DE ON V.DeptEventID = DE.DeptEventID
  WHERE V.DeptCode = @DeptCode
  AND (DE.FromDate <= GETDATE() AND DE.ToDate >= GETDATE())

------------------------- Dept Services 

SELECT [DeptCode]
      ,[serviceCode]
      ,[serviceDescription]
  FROM [dbo].[vDeptServices]
  WHERE DeptCode = @DeptCode
  
------------------------- Services Reception details and Remarks
SELECT [receptionID]
      ,[deptCode]
      ,[serviceCode]
      ,[receptionDay]
      ,[openingHour]
      ,[closingHour]
      ,[OpeningHourText]
  FROM [dbo].[vServicesReceptionWithRemarks]
  WHERE DeptCode = @DeptCode
  and IsMedicalTeam = 1
  ------------------------------ QueueOrder - way of order
  SELECT TOP 1000 [deptCode]
      ,[serviceCode]
      ,[ServiceDescription]
      ,[QueueOrder]
  FROM [dbo].[vServicesAndQueueOrder]
  WHERE DeptCode = @DeptCode
  and IsMedicalTeam = 1

 SELECT DeptCode,
	 ServiceCode,
	 RemarkID,
	 RemarkText = dbo.rfn_GetFotmatedRemark(RemarkText),
	 displayInInternet,
	 ValidFrom,
	 ValidTo
 FROM vDeptServicesRemarks 
 WHERE DeptCode = @DeptCode
	AND (@IsInternal = 1 OR displayInInternet = 1)
	and IsMedicalTeam = 1
GO 

GRANT EXEC ON rpc_GetZoomClinicTemplate TO PUBLIC

GO




--**** Yaniv - End rpc_GetZoomClinicTemplate *****************

--- External views
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vDeptServices]'))
DROP VIEW [dbo].[vDeptServices]
GO

CREATE VIEW [dbo].[vDeptServices]
AS
SELECT  Dept.DeptCode, x_Dept_Employee_Service.serviceCode,
 [Services].serviceDescription, [Services].IsService
FROM    Dept 
INNER JOIN x_Dept_Employee ON Dept.deptCode = x_Dept_Employee.deptCode
INNER JOIN x_Dept_Employee_Service ON x_Dept_Employee.DeptEmployeeID = x_Dept_Employee_Service.DeptEmployeeID 
INNER JOIN [Services] ON x_Dept_Employee_Service.serviceCode = [Services].serviceCode
INNER JOIN Employee on x_Dept_Employee.employeeID = Employee.employeeID
where Employee.IsMedicalTeam = 1
GO
--------------------
/*
VIEW עבור זימונט באינטרנט הכולל את השדות הבאים בלבד :

•	קוד מרפאה ישן
•	שם מרפאה
•	כתובת
•	סוג מרפאה ( UnitType)
•	מס' טלפון.

יש לשלוף רק יחידות פעילות, כל הסוגים, רק קהילה
*/

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[VZimunetDeptData]'))
	DROP VIEW [dbo].VZimunetDeptData
GO


CREATE VIEW [dbo].VZimunetDeptData  
AS  

select d.deptCode , ds.Simul228 as OldSimul ,d.deptName as DeptName, 
		c.cityName, case when d.StreetCode is null then d.streetName else s.Name end as Street,
		d.house as HouseNo, d.addressComment as AddressComment, 
		d.zipCode,d.typeUnitCode as UnitType,
		dbo.fun_ParsePhoneNumberWithExtension(dp.prePrefix, dp.prefix, dp.phone, dp.extension) AS PhoneNumber,
		d.IsCommunity, d.IsMushlam, d.IsHospital
from Dept d
join deptSimul ds
on d.deptCode = ds.deptCode
join Cities c
on d.cityCode = c.cityCode
left join Streets s
on s.CityCode = d.cityCode
and s.StreetCode = d.StreetCode
left join DeptPhones dp
on dp.deptCode = d.deptCode
and dp.phoneType = 1
and dp.phoneOrder = 1
where d.status = 1

GO

GRANT SELECT ON [dbo].VZimunetDeptData TO [public] AS [dbo]
GO

----External Views - end -----------------------------------------------

--**** Yaniv - Start rpc_getDIC_GeneralRemarks ************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDIC_GeneralRemarks')
	BEGIN
		DROP  Procedure  rpc_getDIC_GeneralRemarks
	END

GO

CREATE Procedure dbo.rpc_getDIC_GeneralRemarks
	
	@linkedToDept bit = 0,
	@linkedToDoctor bit = 0,
	@linkedToDoctorInClinic bit = 0,
	@linkedToServiceInClinic bit = 0,
	@linkedToReceptionHours bit = 0,
	@userIsAdmin bit = 0,
	@RemarkCategoryID	int = -1 --  all Categories = -1 
	
AS

	Select
	remarkID,
	remark,
	active,
	EnableOverlappingHours,
	EnableOverMidnightHours,
	cat.RemarkCategoryName, 
	cat.RemarkCategoryID,
	rem.linkedToDept,
	rem.linkedToDoctor,
	rem.linkedToDoctorInClinic,
	rem.linkedToServiceInClinic,
	rem.linkedToReceptionHours,
	'InUseCount' = (SELECT COUNT(*) FROM DeptRemarks WHERE DicRemarkID = rem.remarkID) +
	(SELECT COUNT(*) FROM DeptEmployeeReceptionRemarks WHERE RemarkID = rem.remarkID) +
	(SELECT COUNT(*) FROM DeptEmployeeServiceRemarks WHERE RemarkID = rem.remarkID) +
	(SELECT COUNT(*) FROM DeptReceptionRemarks WHERE RemarkID = rem.remarkID) +
	(SELECT COUNT(*) FROM DeptEmployeeReceptionRemarks WHERE RemarkID = rem.remarkID) +
	(SELECT COUNT(*) FROM DeptEmployeeServiceRemarks WHERE RemarkID = rem.remarkID) +
	(SELECT COUNT(*) FROM EmployeeRemarks WHERE DicRemarkID = rem.remarkID)


	from 
	DIC_GeneralRemarks as rem
	left join DIC_RemarkCategory  as cat
	on rem.RemarkCategoryID =  cat.RemarkCategoryID

	where
	(
		(@linkedToDept = 0 and @linkedToDoctor = 0 and @linkedToDoctorInClinic = 0 and
		 @linkedToServiceInClinic= 0 and @linkedToReceptionHours = 0)
		 or
		(@linkedToDept = 1 and linkedToDept=1) or
		(@linkedToDoctor = 1 and linkedToDoctor=1) or
		(@linkedToDoctorInClinic = 1 and linkedToDoctorInClinic=1) or
		(@linkedToServiceInClinic= 1 and linkedToServiceInClinic= 1) or
		(@linkedToReceptionHours = 1 and linkedToReceptionHours = 1)
	)
	and(@RemarkCategoryID = -1 or rem.RemarkCategoryID = @RemarkCategoryID)
	and (@userIsAdmin = 1 or RelevantForSystemManager is null or RelevantForSystemManager <> 1)
	order by
	remarkID

GO

GRANT EXEC ON rpc_getDIC_GeneralRemarks TO PUBLIC

GO



--**** Yaniv - End rpc_getDIC_GeneralRemarks ************************

--**** Yaniv - Start rpc_getServiceRemarks ************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getServiceRemarks')
	BEGIN
		DROP  Procedure  rpc_getServiceRemarks
	END

GO

CREATE Procedure rpc_getServiceRemarks
	(
		@DeptCode int,
		@ServiceCode int
	)

AS

SELECT
DESR.DeptEmployeeServiceRemarkID,
xDE.DeptCode,
ServiceCode,
RemarkId,
DESR.RemarkText,
displayInInternet,
ValidFrom,
'validTo' =  CASE CAST(isNull(validTo,0) as varchar(20)) WHEN 'Jan  1 1900 12:00AM' THEN 'ללא הגבלת' else CONVERT(varchar(20), validTo, 103) end
FROM DeptEmployeeServiceRemarks DESR
join x_Dept_Employee_Service xDES on DESR.x_dept_employee_serviceID = xDES.x_Dept_Employee_ServiceID
join x_Dept_Employee xDE on xDES.DeptEmployeeID = xDE.DeptEmployeeID
WHERE xDE.DeptCode = @DeptCode
	AND ServiceCode = @ServiceCode

GO


GRANT EXEC ON rpc_getServiceRemarks TO PUBLIC

GO



--**** Yaniv - End rpc_getServiceRemarks ************************


--**** Yaniv - Start vDeptServicesRemarks ************************
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vDeptServicesRemarks]'))
DROP VIEW [dbo].[vDeptServicesRemarks]
GO

CREATE VIEW [dbo].[vDeptServicesRemarks]
AS

SELECT
DESR.DeptEmployeeServiceRemarkID,
DeptCode,
ServiceCode,
RemarkID,
RemarkText = REPLACE( DESR.RemarkText, '#', ''),
displayInInternet,
ValidFrom,
ValidTo,
IsMedicalTeam
FROM DeptEmployeeServiceRemarks DESR
join x_Dept_Employee_Service xDES on DESR.x_dept_employee_serviceID = xDES.x_Dept_Employee_ServiceID
join x_Dept_Employee xDE on xDES.DeptEmployeeID = xDE.DeptEmployeeID
join Employee on Employee.employeeID = xDE.employeeID
WHERE 
	  (DESR.ValidFrom IS NULL OR
	  DESR.ValidFrom <= GETDATE()) AND (DESR.ValidTo IS NULL OR
	  DESR.ValidTo >= GETDATE())

GO

grant select on vDeptServicesRemarks to public 

GO


--**** Yaniv - End vDeptServicesRemarks ************************


--**** Yaniv - Start View_DeptAndServicesRemarks ************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_DeptAndServicesRemarks')
	BEGIN
		DROP  View View_DeptAndServicesRemarks
	END
GO

CREATE VIEW [dbo].[View_DeptAndServicesRemarks]
AS
SELECT *
FROM         
(
-------------- dept Remarks ---------------
select 
View_DeptRemarks.deptCode,
serviceCode = null, 
serviceDescription = '',
View_DeptRemarks.DicRemarkID as remarkID,
replace(replace(View_DeptRemarks.RemarkText,'#', ''), '&quot;', char(34)) as RemarkText,
View_DeptRemarks.validFrom,
View_DeptRemarks.validTo,

RemarkType = 1, -- dept Remarks
View_DeptRemarks.IsSharedRemark as IsSharedRemark,
case when View_DeptRemarks.validTo is null then 1 else 0 end as IsConstantRemark, 
View_DeptRemarks.displayInInternet,
case when  View_DeptRemarks.validFrom >= GETDATE() then 1 else 0 end as IsFutureRemark

from View_DeptRemarks
	
union

-------------- dept Services Remarks ---------------	
select 
xDE.deptCode,
xDES.ServiceCode,
Services.serviceDescription,
DESR.remarkID,
replace(replace(DESR.RemarkText,'#', ''), '&quot;', char(34))as RemarkText,
DESR.ValidFrom,
DESR.ValidTo,

RemarkType = 4, -- dept Services Remarks
IsSharedRemark = 0,
case when DESR.validTo is null then 1 else 0 end as IsConstantRemark, 
DESR.displayInInternet,
case when  DESR.validFrom >= GETDATE() then 1 else 0 end as IsFutureRemark

from x_Dept_Employee xDE
 join x_Dept_Employee_Service xDES on xDE.DeptEmployeeID = xDES.DeptEmployeeID
 join Services on xDES.serviceCode = Services.serviceCode
 join DeptEmployeeServiceRemarks DESR on xDES.x_Dept_Employee_ServiceID = DESR.x_dept_employee_serviceID
) as resultTable

GO

grant select on View_DeptAndServicesRemarks to public 

GO




--**** Yaniv - End View_DeptAndServicesRemarks ************************

----------- 28/02/2012 --------- julia

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_EmployeeReceptions')
	BEGIN
		DROP  Procedure  dbo.rprt_EmployeeReceptions
	END

GO

CREATE Procedure [dbo].rprt_EmployeeReceptions
(
	 @DistrictCodes varchar(max)=null,
	 @AdminClinicCode varchar(max)=null,	
	 @CitiesCodes varchar(max)=null,
	 @EmployeeSector_cond varchar(max)=null,
	 @UnitTypeCodes varchar(max)=null,
	 @SubUnitTypeCodes varchar(max)=null,
	 @ServiceCodes varchar(max)=null,
	 @ProfessionCodes varchar(max)=null,
	 @PositionCodes varchar(max)=null,
	 @ExpertProfessionCodes varchar(max)=null,
	 --@EmployeeIndependent_cond varchar(max)=null, -- todo:change to employee Independent 
	 @AgreementType_cond varchar(max)=null,
	 @EmployeeSex_cond varchar(max)=null, 
	 @ValidFrom_cond varchar(max)=null,
	 @ValidTo_cond varchar(max)=null,
	 
	@district varchar (2)= null,
	@adminClinic varchar (2) = null,		
	@ClinicName varchar (2)=null,
	@ClinicCode varchar (2)=null,
	@simul varchar (2)=null,
	--@city varchar (2)=null,
	
	@EmployeeName varchar (2)=null,
	@EmployeeID varchar (2)=null,
	@EmployeeSector varchar (2)=null,
	@EmployeeLicenseNumber varchar (2)=null,	
	@EmployeeSex varchar(2)=null, 
	@EmployeePosition varchar (2)=null,
	@EmployeeProfessions varchar (2)=null,
	@EmployeeExpertProfession varchar (2)=null,	
	@EmployeeServices varchar (2)=null,
	
	@RecepDay varchar (2)=null,	
	@RecepOpeningHour varchar (2)=null,
	@RecepClosingHour varchar (2)=null,
	@RecepTotalHours varchar (2)=null,
	@RecepValidFrom varchar (2)=null,
	@RecepValidTo varchar (2)=null,
	@RecepRemark varchar (2)=null,
	
	@IsExcelVersion varchar (2)=null,
	@ErrCode VARCHAR(max) OUTPUT
-----------------------------------------
)with recompile

AS
--------------------------------------

DECLARE @NewLineChar AS CHAR(2) 
set @NewLineChar = CHAR(13) + CHAR(10)
--set @NewLineChar = ''

--set variables 
declare  @sql nvarchar(max)-- nvarchar type supports hebrew lenguage
declare  @sqlEnd nvarchar(max)
declare  @sqlFrom varchar(max)
--declare  @sqlWhere varchar(max)

declare  @stringNotNeeded  nvarchar(max)
---------------------------

set @sql = 'SELECT distinct *  from
			(select ' + @NewLineChar;
set @sqlEnd = ') as resultTable '
				+'order by EmployeeLastName' + @NewLineChar;
--set @sqlWhere = ' ';


set @sqlFrom = 'from Employee 
join Employee as Emp on Employee.employeeID = Emp.employeeID 
 AND (''' + @DistrictCodes + ''' = ''-1'' or Employee.primaryDistrict IN (SELECT IntField FROM dbo.SplitString( ''' + @DistrictCodes + ''')) )
 AND (''' + @EmployeeSector_cond + ''' = ''-1'' or Employee.EmployeeSectorCode IN (SELECT IntField FROM dbo.SplitString(''' + @EmployeeSector_cond + ''' )) )
 AND (''' + @EmployeeSex_cond + ''' = ''-1'' or Employee.Sex IN (SELECT IntField FROM dbo.SplitString(''' + @EmployeeSex_cond + ''' )))
	and (''' + @PositionCodes + ''' = ''-1'' or
	(	SELECT count(*) 
		FROM x_Dept_Employee_Position 
		inner join x_Dept_Employee xde
		on x_Dept_Employee_Position.DeptEmployeeID = xde.DeptEmployeeID
		WHERE Employee.employeeID = xde.employeeID	
		AND positionCode IN (SELECT IntField FROM dbo.SplitString( ''' + @PositionCodes + ''' ))) > 0
	)
	AND (''' + @ProfessionCodes + ''' = ''-1'' or
	(	SELECT count(*) 
		FROM EmployeeServices 
		WHERE Employee.employeeID = EmployeeServices.employeeID								
		AND EmployeeServices.ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ProfessionCodes + ''' ))) > 0
	)
	AND (''' + @ExpertProfessionCodes + ''' = ''-1'' or
	(	SELECT count(*) 
		FROM  EmployeeServices 
		WHERE Employee.employeeID = EmployeeServices.employeeID 	and EmployeeServices.expProfession = 1
		and EmployeeServices.ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ExpertProfessionCodes + ''' ))) > 0
	)
	AND (''' + @ServiceCodes + ''' = ''-1'' or
	(	SELECT count(*) 
		FROM EmployeeServices 
		WHERE Employee.employeeID = EmployeeServices.employeeID									
		AND EmployeeServices.ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ServiceCodes + ''' ))) > 0
	)
	
	
left join x_Dept_Employee ON x_Dept_Employee.employeeID = Employee.employeeID 
  
left join dept  as d   on d.deptCode = x_Dept_Employee.deptCode
inner join Employee as Emp2 on Employee.employeeID = Emp2.employeeID
	AND (''' + @AdminClinicCode + ''' = ''-1'' or d.administrationCode  in (SELECT IntField FROM dbo.SplitString( ''' + @AdminClinicCode + ''')))
	AND (''' + @UnitTypeCodes + ''' = ''-1'' or d.typeUnitCode  in (SELECT IntField FROM dbo.SplitString( ''' + @UnitTypeCodes + ''')) )
	AND (''' + @SubUnitTypeCodes + ''' = ''-1'' or d.subUnitTypeCode in (SELECT IntField FROM dbo.SplitString( ''' + @SubUnitTypeCodes + ''')) )
	AND (''' + @CitiesCodes + ''' = ''-1'' or d.CityCode IN (SELECT IntField FROM dbo.SplitString( ''' + @CitiesCodes + ''')) )
	AND (''' + @AgreementType_cond + ''' = ''-1'' or x_Dept_Employee.AgreementType IN (SELECT IntField FROM dbo.SplitString(''' + @AgreementType_cond + ''' ))) 
	
inner join View_DeptEmployeesCurrentStatus as v_DECStatus 
	on x_Dept_Employee.deptCode = v_DECStatus.deptCode
	and Employee.employeeID = v_DECStatus.employeeID
	and v_DECStatus.status = 1

left join dept as dAdmin on d.administrationCode = dAdmin.deptCode 
left join dept as dDistrict on Employee.primaryDistrict = dDistrict.deptCode 
left join View_UnitType as UnitType on d.typeUnitCode =  UnitType.UnitTypeCode   
left join View_SubUnitTypes as SubUnitType on d.subUnitTypeCode =  SubUnitType.subUnitTypeCode and  d.typeUnitCode =  SubUnitType.UnitTypeCode 
left join deptSimul on d.DeptCode = deptSimul.DeptCode 
left join Cities on d.CityCode =  Cities.CityCode  
left join PopulationSectors as ps on d.populationSectorCode = ps.PopulationSectorID -- 
left join DIC_QueueOrder ON d.QueueOrder = DIC_QueueOrder.QueueOrder
left join x_Dept_Employee_EmployeeRemarks on  x_Dept_Employee.DeptEmployeeID = x_Dept_Employee_EmployeeRemarks.DeptEmployeeID	
left join EmployeeRemarks on x_Dept_Employee_EmployeeRemarks.EmployeeRemarkID = EmployeeRemarks.EmployeeRemarkID 
INNER JOIN View_EmployeeSector on Employee.EmployeeSectorCode = View_EmployeeSector.EmployeeSectorCode
--------------------
left join DeptEmployeePhones as  emplPh1  on  x_Dept_Employee.DeptEmployeeID = emplPh1.DeptEmployeeID 
	and emplPh1.PhoneType = 1 and emplPh1.phoneOrder = 1  
left join DeptEmployeePhones as emplPh2  on  x_Dept_Employee.DeptEmployeeID = emplPh2.DeptEmployeeID 
	and emplPh2.PhoneType = 1 and emplPh2.phoneOrder = 2 
left join DeptEmployeePhones as emplPh3  on  x_Dept_Employee.DeptEmployeeID = emplPh3.DeptEmployeeID  
	and emplPh3.PhoneType = 2 and emplPh3.phoneOrder = 1 
--------------------
left join EmployeePhones as  EmployeePhones1  on  Employee.employeeID = EmployeePhones1.employeeID 
	and EmployeePhones1.PhoneType = 1 and EmployeePhones1.phoneOrder = 1  
left join EmployeePhones as EmployeePhones2  on Employee.employeeID = EmployeePhones2.employeeID 
	and EmployeePhones2.PhoneType = 3 and EmployeePhones2.phoneOrder = 1 
 
left join dbo.View_DeptEmployeeReceptions   AS V_DEReception on x_Dept_Employee.deptCode = V_DEReception.deptCode
	and x_Dept_Employee.employeeID = V_DEReception.employeeID 
join Employee as Emp3 on Employee.employeeID = Emp3.employeeID 
	 and[dbo].rfn_CheckExpirationDate_str
	(CONVERT(varchar(10), V_DEReception.validFrom, 20),
	 CONVERT(varchar(10), V_DEReception.validTo, 20), '''
	 + isNull(@ValidFrom_cond, 'null') + ''','''
	 + IsNull(@ValidTo_cond, 'null')+ ''') = 1
	 
left join [dbo].View_EmployeeExpertProfessions as DEExpProfessions --View_DeptEmployeeExpertProfessions
	--on x_Dept_Employee.deptCode = DEExpProfessions.deptCode
	on Employee.employeeID = DEExpProfessions.employeeID 

left join [dbo].View_DeptEmployeePositions as DEPositions 
	on x_Dept_Employee.deptCode = DEPositions.deptCode
	and Employee.employeeID = DEPositions.employeeID 
 ' 
 
if(@EmployeeName = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'Employee.firstName as EmployeeFirstName, Employee.lastName as EmployeeLastName'+ @NewLineChar;
	end
	
if(@EmployeeID = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.EmployeeID as EmployeeID '+ @NewLineChar;
	end
	
if(@EmployeeLicenseNumber = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.licenseNumber as EmployeeLicenseNumber '+ @NewLineChar;
	end

if(@EmployeeSector = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.EmployeeSectorCode as EmployeeSectorCode,  
		View_EmployeeSector.EmployeeSectorDescription as EmployeeSectorDescription'+ @NewLineChar;
	end	


if(@district = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
		set @sql = @sql + ' dDistrict.DeptName as DistrictName , isNull(dDistrict.deptCode , -1) as DeptCode '+ @NewLineChar;
	end
	
if(@adminClinic = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dAdmin.DeptName as AdminClinicName ,
				 dAdmin.DeptCode as AdminClinicCode '+ @NewLineChar;
	end 

--------------@ClinicName-------------------------------------
if( @ClinicName= '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'd.DeptName as ClinicName ' + @NewLineChar;	
end
--------------@ClinicCode-------------------------------------
if( @ClinicCode= '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' d.deptCode as ClinicCode ' + @NewLineChar;	
end
---------------Simul----------------------------------------------------------------------------------------
if(@simul = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'deptSimul.Simul228 as Code228 '+ @NewLineChar;
end 

if(@EmployeePosition = '1' )
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
			' DEPositions.PositionDescriptions as PositionDescription
			 ,DEPositions.PositionCodes as PositionCode' 
		+ @NewLineChar;
	end
	
if(@EmployeeExpertProfession = '1')
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql +
			' DEExpProfessions.ExpertProfessionDescriptions as ExpertProfessionDescription
			 ,DEExpProfessions.ExpertProfessionCodes as ExpertProfessionCode' 
		+ @NewLineChar;
	end

	
if (@EmployeeSex = '1')
begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'case when Employee.Sex = 1 then ''זכר'' when Employee.Sex = 2 then ''נקבה'' else ''לא מוגדר'' end  as EmployeeSex'+ @NewLineChar;
end


------------ @DeptEmployeeServices -------------------------------------------------------------------------------------

if(@EmployeeServices = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'V_DEReception.serviceDescription  as serviceDescription,
	 V_DEReception.serviceCode  as serviceCode  ' + @NewLineChar;
end 

------------ @EmployeeProfessions -------------------------------------------------------

if(@EmployeeProfessions = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + 'V_DEReception.ProfessionDescription  as ProfessionDescription,
	 V_DEReception.ProfessionCode  as ProfessionCode  ' + @NewLineChar;
end 


------------ RecepDay ------------------------------------------------------------
if(@RecepDay = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' V_DEReception.ReceptionDayName  as ReceptionDayName ' + @NewLineChar;
	end 
		

----------- RecepOpeningHour --------------------------------------------------
if(@RecepOpeningHour = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' V_DEReception.openingHour  as openingHour ' + @NewLineChar;
end 

----------- RecepClosingHour --------------------------------------------------
if(@RecepClosingHour = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' V_DEReception.closingHour  as closingHour ' + @NewLineChar;
end 

----------- RecepTotalHours --------------------------------------------------
if(@RecepTotalHours = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' V_DEReception.totalHours  as totalHours ' + @NewLineChar;
end 

----------- RecepValidFrom --------------------------------------------------
if(@RecepValidFrom = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' CONVERT(varchar(10), V_DEReception.validFrom, 103)  as  validFrom  ' + @NewLineChar;
end 

----------- RecepValidTo --------------------------------------------------
if(@RecepValidTo = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' CONVERT(varchar(10), V_DEReception.validTo, 103) as  validTo ' + @NewLineChar;
end 

----------- RecepRemark --------------------------------------------------
if(@RecepRemark = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' V_DEReception.remarkText  as RecepRemark ' + @NewLineChar;
end 

--=================================================================

set @sql = @sql + @sqlFrom 
 + @sqlEnd
 
set @sql = 'SET DATEFORMAT dmy ' + @NewLineChar + @sql +@NewLineChar+ 'SET DATEFORMAT mdy;'

print '--------- sql query full ----------'
print '--===== @sql string length = ' + str(len(@sql))
Exec rpc_HelperLongPrint @sql 
			 
			
SET DATEFORMAT dmy;
EXECUTE sp_executesql @sql 
SET DATEFORMAT mdy;

SET @ErrCode = @sql 
RETURN 

GO
GRANT EXEC ON [dbo].rprt_EmployeeReceptions TO PUBLIC
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_DeptEmployees')
	BEGIN
		DROP  Procedure  dbo.rprt_DeptEmployees
	END

GO

CREATE Procedure dbo.rprt_DeptEmployees
(
	 @DistrictCodes varchar(max)=null,
	 @AdminClinicCode varchar(max)=null,	
	 @UnitTypeCodes varchar(max)=null,
	 @EmployeeSector_cond varchar(max)=null,
	 @ServiceCodes varchar(max)=null,
	 @ProfessionCodes varchar(max)=null,
	 @ExpertProfessionCodes varchar(max)=null,
	 @CitiesCodes varchar(max)=null,
	 --@EmployeeIndependent_cond varchar(max)=null, -- Dept employee Independent condition
	 @AgreementType_cond varchar(max)=null,
	 @DeptEmployeeStatusCodes varchar(max)=null,
	 
	@district varchar (2)= null,	
	@adminClinic varchar (2) = null ,		
	@subAdminClinic varchar (2)=null, 
	@unitType varchar (2)=null,		
	@SubUnitType varchar (2)=null,	
	@ClinicName varchar (2)=null,
	@ClinicCode varchar (2)=null,
	@simul varchar (2)=null,
	@city varchar (2)=null,
	@address varchar (2)=null,
	@Phone1 varchar (2)=null,
	@Phone2 varchar (2)=null,
	@Fax varchar (2)=null,
	@Email varchar (2)=null,
	@sector varchar (2)=null,
	@MangerName varchar (2)=null,
	@adminMangerName varchar (2)=null,	
	@EmployeeName varchar (2)=null,
	@EmployeeID varchar (2)=null,
	@Position varchar (2)=null,
	@DeptEmployeePhone varchar (2)=null,
	@DeptEmployeeFax varchar (2)=null,
	@DeptEmployeeRemark varchar (2)=null,
	@DeptEmployeeEmail varchar (2)=null,
	--@DeptEmployeeIndependent varchar (2)=null,
	@AgreementType  varchar(2)= null,
	@Professions varchar (2)=null,
	@EmployeeSector varchar (2)=null,
	@EmployeeLicenseNumber varchar (2)=null,	
	@EmployeeExpert varchar (2)=null,		-- don't used now
	@EmployeeExpertProfession varchar (2)=null,	
	@DeptEmployeeServices varchar (2)=null,
	@QueueOrderDescription varchar (2)=null, 
	@EmployeeStatus		varchar(2)= null,
	@DeptEmployeeStatus varchar(2)= null,
	@EmployeeSex varchar(2)=null, 
	@EmployeeDegree varchar(2)= null,
	@IsExcelVersion varchar (2)=null,
	
	@ErrCode varchar(max) OUTPUT
-----------------------------------------
)with recompile

AS
--------------------------------------

DECLARE @NewLineChar AS CHAR(2) 
set @NewLineChar = CHAR(13) + CHAR(10)

--set variables 
declare  @sql nvarchar(max)-- nvarchar type supports hebrew lenguage
declare  @sqlEnd nvarchar(max)
declare  @sqlFrom varchar(max)
declare  @sqlWhere varchar(max)

set @sqlWhere = ' ';
---------------------------
set @sql = 'SELECT distinct *  from
			(select ' + @NewLineChar;
set @sqlEnd = ') as resultTable' + @NewLineChar;

set @sqlFrom = 
'from dept  as d    
left join x_Dept_Employee ON d.deptCode = x_Dept_Employee.deptCode 
join x_Dept_Employee as xDE ON xDE.deptCode = x_Dept_Employee.deptCode
	AND (''' + @AdminClinicCode + ''' = ''-1'' or d.administrationCode  in (SELECT IntField FROM dbo.SplitString( ''' + @AdminClinicCode + ''')))
	AND (''' + @UnitTypeCodes + ''' = ''-1'' or d.typeUnitCode  in (SELECT IntField FROM dbo.SplitString( ''' + @UnitTypeCodes + ''')) )
	AND (''' + @CitiesCodes + ''' = ''-1'' or d.CityCode IN (SELECT IntField FROM dbo.SplitString( ''' + @CitiesCodes + ''')) )
	AND (''' + @DistrictCodes + ''' = ''-1'' or d.districtCode IN (SELECT IntField FROM dbo.SplitString( ''' + @DistrictCodes + ''')) )
	AND (''' + @AgreementType_cond + ''' = ''-1'' or x_Dept_Employee.AgreementType IN (SELECT IntField FROM dbo.SplitString(''' + @AgreementType_cond + ''' ))) 
	and (''' + @ProfessionCodes + ''' = ''-1'' or
	(	SELECT count(*) 
		FROM x_Dept_Employee_Service as xDEP 
		WHERE x_Dept_Employee.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID							
		AND ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ProfessionCodes + ''' ))) > 0
	)
	AND (''' + @ExpertProfessionCodes + ''' = ''-1'' or
	(	SELECT count(*) 
		FROM x_Dept_Employee_Service  as xDEP 
		left join EmployeeServices on 
					x_Dept_Employee.employeeID = EmployeeServices.employeeID 
					and xDEP.ServiceCode = EmployeeServices.ServiceCode
					and EmployeeServices.expProfession = 1
		WHERE x_Dept_Employee.DeptEmployeeID= xDEP.DeptEmployeeID	
		and EmployeeServices.ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ExpertProfessionCodes + ''' ))) > 0
	)
	AND (''' + @ServiceCodes + ''' = ''-1'' or
	(	SELECT count(*) 
		FROM x_Dept_Employee_Service as xDS
		WHERE x_Dept_Employee.DeptEmployeeID = xDS.DeptEmployeeID									
		AND ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ServiceCodes + ''' ))) > 0
	)
left join View_DeptEmployeesCurrentStatus as v_DECStatus 
	on x_Dept_Employee.deptCode = v_DECStatus.deptCode
	and x_Dept_Employee.employeeID = v_DECStatus.employeeID
JOIN Employee ON x_Dept_Employee.employeeID = Employee.employeeID 
AND (''' + @EmployeeSector_cond + ''' = ''-1'' or Employee.EmployeeSectorCode IN (SELECT IntField FROM dbo.SplitString(''' + @EmployeeSector_cond + ''' )) )
AND (''' + @DeptEmployeeStatusCodes + ''' = ''-1'' or  v_DECStatus.status IN (SELECT IntField FROM dbo.SplitString( ''' + @DeptEmployeeStatusCodes + ''')) )

join DIC_ActivityStatus as EmpStatus on EmpStatus.Status = Employee.active 
join DIC_ActivityStatus as DeptEmpStatus on DeptEmpStatus.Status = v_DECStatus.Status

join DIC_AgreementTypes on x_Dept_Employee.AgreementType = DIC_AgreementTypes.AgreementTypeID

left JOIN View_EmployeeSector on Employee.EmployeeSectorCode = View_EmployeeSector.EmployeeSectorCode

left join dept as dAdmin on d.administrationCode = dAdmin.deptCode    
left join dept as dDistrict on d.districtCode = dDistrict.deptCode  
left join View_UnitType as UnitType on d.typeUnitCode =  UnitType.UnitTypeCode   
left join View_SubUnitTypes as SubUnitType on d.subUnitTypeCode =  SubUnitType.subUnitTypeCode
	 and  d.typeUnitCode =  SubUnitType.UnitTypeCode 
left join Cities on d.CityCode =  Cities.CityCode
left join deptSimul on d.DeptCode = deptSimul.DeptCode 
left join dept as dSubAdmin on d.subAdministrationCode = dSubAdmin.deptCode 

cross apply rfn_GetDeptEmployeeQueueOrderDetails(d.deptCode, x_Dept_Employee.employeeID) as QueueOrderDetails
left join DeptEmployeePhones as  emplPh1  on  x_Dept_Employee.DeptEmployeeID = emplPh1.DeptEmployeeID 
	and emplPh1.PhoneType = 1 and emplPh1.phoneOrder = 1  
left join DeptEmployeePhones as emplPh2  on  x_Dept_Employee.DeptEmployeeID = emplPh2.DeptEmployeeID 
	and emplPh2.PhoneType = 1 and emplPh2.phoneOrder = 2 
left join DeptEmployeePhones as emplPh3  on  x_Dept_Employee.DeptEmployeeID = emplPh3.DeptEmployeeID  
	and emplPh3.PhoneType = 2 and emplPh3.phoneOrder = 1 
left join DeptPhones dp1 on d.DeptCode = dp1.DeptCode and dp1.PhoneType = 1 and dp1.phoneOrder = 1  
left join DeptPhones dp2 on d.DeptCode = dp2.DeptCode and dp2.PhoneType = 1 and dp2.phoneOrder = 2 
left join DeptPhones dp3 on d.DeptCode = dp3.DeptCode and dp3.PhoneType = 2 and dp3.phoneOrder = 1 
left  join PopulationSectors as ps on d.populationSectorCode = ps.PopulationSectorID 

left join [dbo].View_DeptEmployeeProfessions as DEProfessions	 
	on x_Dept_Employee.deptCode = DEProfessions.deptCode
	and Employee.employeeID = DEProfessions.employeeID 
	
left join [dbo].View_DeptEmployeeExpertProfessions as DEExpProfessions 
	on x_Dept_Employee.deptCode = DEExpProfessions.deptCode
	and Employee.employeeID = DEExpProfessions.employeeID 

left join [dbo].View_DeptEmployeePositions as DEPositions 
	on x_Dept_Employee.deptCode = DEPositions.deptCode
	and Employee.employeeID = DEPositions.employeeID 
	
left join [dbo].View_DeptEmployeeServices as DEServices 
	on x_Dept_Employee.deptCode = DEServices.deptCode
	and Employee.employeeID = DEServices.employeeID 
	
left join [dbo].View_DeptEmployeeRemarks as DERemarks
	on x_Dept_Employee.deptCode = DERemarks.deptCode
	and Employee.employeeID = DERemarks.employeeID
	
left JOIN DIC_EmployeeDegree on Employee.DegreeCode = DIC_EmployeeDegree.DegreeCode 
'

if(@adminClinic = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dAdmin.DeptName as AdminClinicName ,
				 isNull(dAdmin.DeptCode , -1) as AdminClinicCode '+ @NewLineChar;
	end 
	
if(@district = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
		set @sql = @sql + ' dDistrict.DeptName as DistrictName , isNull(dDistrict.deptCode , -1) as DeptCode '+ @NewLineChar;
	end	
if(@unitType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' UnitType.UnitTypeCode as UnitTypeCode , UnitType.UnitTypeName as UnitTypeName '+ @NewLineChar;
	end
if(@subUnitType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
		' subUnitType.subUnitTypeCode as subUnitTypeCode , subUnitType.subUnitTypeName as subUnitTypeName '+ 
		@NewLineChar;
	end 
	
if( @ClinicName= '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'd.DeptName as ClinicName ' + @NewLineChar;	
	end

if( @ClinicCode= '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' d.deptCode as ClinicCode ' + @NewLineChar;	
	end

if(@simul = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'deptSimul.Simul228 as Code228 '+ @NewLineChar;
	end 

if(@subAdminClinic = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'dSubAdmin.DeptCode as SubAdminClinicCode , dSubAdmin.DeptName as SubAdminClinicName '+ @NewLineChar;
	end 			
	
if(@city = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);			
		set @sql = @sql + ' Cities.CityCode as CityCode, Cities.CityName as CityName'+ @NewLineChar;
	end

if (@address = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'dbo.GetAddress(d.deptCode) as ClinicAddress '+ @NewLineChar;
	end	
	
if(@Phone1 = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp1.prePrefix, dp1.Prefix,dp1.Phone, dp1.extension ) as Phone1 '+ @NewLineChar;;
end

if(@Phone2 = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp2.prePrefix, dp2.Prefix, dp2.Phone, dp2.extension) as Phone2 '+ @NewLineChar;;
end 

if(@Fax = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp3.prePrefix, dp3.Prefix, dp3.Phone, dp3.extension) as Fax '+ @NewLineChar;
end

if(@Email = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' d.Email as Email '+ @NewLineChar;
	end

if(@MangerName = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dbo.fun_getManagerName(d.deptCode) as MangerName '+ @NewLineChar;							   
	end

if(@adminMangerName = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dbo.fun_getAdminManagerName(d.deptCode) as AdminMangerName '+ @NewLineChar;
	end

if(@sector = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' ps.PopulationSectorID as SectorCode ,ps.PopulationSectorDescription as SectorName'+ @NewLineChar;
	end 	 	

if(@EmployeeName = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'Employee.firstName as EmployeeFirstName, Employee.lastName as EmployeeLastName'+ @NewLineChar;
	end
	
if(@EmployeeID = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.EmployeeID as EmployeeID '+ @NewLineChar;
	end
	
if(@EmployeeLicenseNumber = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.licenseNumber as EmployeeLicenseNumber '+ @NewLineChar;
	end

if(@DeptEmployeeEmail = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'Employee.email as EmployeeEmail'+ @NewLineChar;
	end

if(@EmployeeSector = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.EmployeeSectorCode as EmployeeSectorCode,  
		View_EmployeeSector.EmployeeSectorDescription as EmployeeSectorDescription'+ @NewLineChar;
	end	


if(@Position = '1' ) 
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
			' DEPositions.PositionDescriptions as PositionDescription
			 ,DEPositions.PositionCodes as PositionCode' 
		+ @NewLineChar;
	end
	
if(@Professions = '1' ) 
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql +
			' DEProfessions.ProfessionDescriptions as ProfessionDescription
			 ,DEProfessions.ProfessionCodes as ProfessionCode ' 
			+ @NewLineChar;
	end

if(@EmployeeExpertProfession = '1') 
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql +
			' DEExpProfessions.ExpertProfessionDescriptions as ExpertProfessionDescription
			 ,DEExpProfessions.ExpertProfessionCodes as ExpertProfessionCode' 
		+ @NewLineChar;
	end

if(@DeptEmployeeServices = '1' ) 
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
			' DEServices.ServiceDescriptions as ServiceDescription 
			,DEServices.ServiceCodes as ServiceCode' 
		+ @NewLineChar;
	end	

if(@DeptEmployeeRemark = '1' )  -- changed
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
			' DERemarks.RemarkDescriptions as EmployeeRemarkDescription
			,DERemarks.RemarkCodes as EmployeeRemarkID'
		+ @NewLineChar;
	end

	
if(@QueueOrderDescription = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql 
		+ ' QueueOrderDetails. QueueOrderDescription as QueueOrderDescription '
		+ @NewLineChar 
		+ ' ,QueueOrderDetails.QueueOrderClinicTelephone as QueueOrderClinicTelephone '
		+ @NewLineChar 
		+ ' ,QueueOrderDetails.QueueOrderSpecialTelephone as QueueOrderSpecialTelephone '
		+ @NewLineChar
		+ ' ,QueueOrderDetails.QueueOrderTelephone2700 as QueueOrderTelephone2700 '
		+ @NewLineChar
		+ ' ,QueueOrderDetails.QueueOrderInternet as QueueOrderInternet '
		+ @NewLineChar
	end	

if(@DeptEmployeePhone = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'case when x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1
		then dbo.fun_ParsePhoneNumberWithExtension(dp1.prePrefix, dp1.Prefix, dp1.Phone, dp1.Extension )
		else dbo.fun_ParsePhoneNumberWithExtension(emplPh1.prePrefix, emplPh1.Prefix, emplPh1.Phone, emplPh1.Extension )end as EmployeePhone1 '+ @NewLineChar;;

		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'case when x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1
		then dbo.fun_ParsePhoneNumberWithExtension(dp2.prePrefix, dp2.Prefix, dp2.Phone, dp2.Extension )
		else dbo.fun_ParsePhoneNumberWithExtension(emplPh2.prePrefix, emplPh2.Prefix, emplPh2.Phone, emplPh2.Extension )end as EmployeePhone2 '+ @NewLineChar;;
	end

if(@DeptEmployeeFax = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'case when x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1
		then dbo.fun_ParsePhoneNumberWithExtension(dp3.prePrefix, dp3.Prefix, dp3.Phone, dp3.Extension ) 
		else dbo.fun_ParsePhoneNumberWithExtension(emplPh3.prePrefix, emplPh3.Prefix, emplPh3.Phone, emplPh3.Extension )end as EmployeeFax '+ @NewLineChar;;
	end

if(@AgreementType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql 
		 + 'DIC_AgreementTypes.AgreementTypeID as AgreementTypeCode,
		 DIC_AgreementTypes.AgreementTypeDescription as AgreementTypeDescription '
		+ @NewLineChar;
	end	

if(@EmployeeStatus = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' EmpStatus.Status as StatusCode, EmpStatus.StatusDescription as StatusDescription '+ @NewLineChar;
	end	
if(@DeptEmployeeStatus = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' DeptEmpStatus.Status as DeptEmployeeStatusCode, DeptEmpStatus.StatusDescription as DeptEmployeeStatusDescription '+ @NewLineChar;
	end	
if(@EmployeeDegree = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' DIC_EmployeeDegree.degreeName as EmployeeDegree, DIC_EmployeeDegree.degreeCode as EmployeeDegreeCode '+ @NewLineChar;
	end
if (@EmployeeSex = '1')
begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'case when Employee.Sex = 1 then ''זכר'' when Employee.Sex = 2 then ''נקבה'' else ''לא מוגדר'' end  as EmployeeSex'+ @NewLineChar;
end
--=================================================================
--=================================================================

set @sql = @sql + @sqlFrom + @sqlWhere + @sqlEnd

print '--------- sql query full ----------'
print '--===== @sql string length = ' + str(len(@sql))
Exec rpc_HelperLongPrint @sql 

EXECUTE sp_executesql @sql 
SET @ErrCode = @sql 
RETURN 

GO
GRANT EXEC ON [dbo].rprt_DeptEmployees TO PUBLIC
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_DeptEmployeeReceptions')
	BEGIN
		DROP  Procedure  dbo.rprt_DeptEmployeeReceptions
	END

GO

CREATE Procedure dbo.rprt_DeptEmployeeReceptions
(
	 @DistrictCodes varchar(max)=null,
	 @AdminClinicCode varchar(max)=null,	
	 @UnitTypeCodes varchar(max)=null,
	 @EmployeeSector_cond varchar(max)=null,
	 @ServiceCodes varchar(max)=null,
	 @ProfessionCodes varchar(max)=null,
	 @ExpertProfessionCodes varchar(max)=null,
	 @CitiesCodes varchar(max)=null,
	 @AgreementType_cond varchar(max)=null,
	 
	@district varchar (2)= null,	
	@adminClinic varchar (2) = null ,		
	@subAdminClinic varchar (2)=null, 
	@unitType varchar (2)=null,		
	@SubUnitType varchar (2)=null,	
	@ClinicName varchar (2)=null,
	@ClinicCode varchar (2)=null,
	@simul varchar (2)=null,
	@city varchar (2)=null,
	@address varchar (2)=null,
	@Phone1 varchar (2)=null,
	@Phone2 varchar (2)=null,
	@Fax varchar (2)=null,
	@Email varchar (2)=null,
	@sector varchar (2)=null,
	@MangerName varchar (2)=null, 
	@adminMangerName varchar (2)=null,	
	@EmployeeName varchar (2)=null,
	@EmployeeID varchar (2)=null,
	@Position varchar (2)=null,
	@DeptEmployeePhone varchar (2)=null,
	@DeptEmployeeFax varchar (2)=null,
	@DeptEmployeeRemark varchar (2)=null,
	@DeptEmployeeEmail varchar (2)=null,
	--@DeptEmployeeIndependent varchar (2)=null,
	@AgreementType  varchar(2)= null,
	@Professions varchar (2)=null,
	@EmployeeSector varchar (2)=null,
	@EmployeeLicenseNumber varchar (2)=null,	
	@EmployeeExpert varchar (2)=null,		-- don't used now
	@EmployeeExpertProfession varchar (2)=null,	
	@DeptEmployeeServices varchar (2)=null,
	
	@RecepDay varchar (2)=null,	
	@RecepOpeningHour varchar (2)=null,
	@RecepClosingHour varchar (2)=null,
	@RecepTotalHours varchar (2)=null,
	@RecepValidFrom varchar (2)=null,
	@RecepValidTo varchar (2)=null,
	@RecepRemark varchar (2)=null,
	
	@IsExcelVersion varchar (2)=null,
	
	@ErrCode varchar(max) OUTPUT
-----------------------------------------
)with recompile

AS
--------------------------------------

DECLARE @NewLineChar AS CHAR(2) 
set @NewLineChar = CHAR(13) + CHAR(10)
--set @NewLineChar = ''

--set variables 
--set variables 
declare  @sql nvarchar(max)-- nvarchar type supports hebrew lenguage
declare  @sqlEnd nvarchar(max)
declare  @sqlFrom varchar(max)
declare  @sqlWhere varchar(max)

set @sqlWhere = ' ';
---------------------------
set @sql = 'SELECT distinct *  from
			(select ' + @NewLineChar;
set @sqlEnd = ') as resultTable' + @NewLineChar;

set @sqlFrom = 
'from dept  as d    
left join x_Dept_Employee ON d.deptCode = x_Dept_Employee.deptCode 
join x_Dept_Employee as xDE ON xDE.deptCode = x_Dept_Employee.deptCode
	AND (''' + @AdminClinicCode + ''' = ''-1'' or d.administrationCode  in (SELECT IntField FROM dbo.SplitString( ''' + @AdminClinicCode + ''')))
	AND (''' + @UnitTypeCodes + ''' = ''-1'' or d.typeUnitCode  in (SELECT IntField FROM dbo.SplitString( ''' + @UnitTypeCodes + ''')) )
	AND (''' + @CitiesCodes + ''' = ''-1'' or d.CityCode IN (SELECT IntField FROM dbo.SplitString( ''' + @CitiesCodes + ''')) )
	AND (''' + @DistrictCodes + ''' = ''-1'' or  d.districtCode IN (SELECT IntField FROM dbo.SplitString( ''' + @DistrictCodes + ''')) or d.DeptCode IN (SELECT x_Dept_District.DeptCode FROM dbo.SplitString(''' + @DistrictCodes + ''') as T JOIN  x_Dept_District ON T.IntField = x_Dept_District.districtCode) )
	AND (''' + @AgreementType_cond + ''' = ''-1'' or x_Dept_Employee.AgreementType IN (SELECT IntField FROM dbo.SplitString(''' + @AgreementType_cond + ''' ))) 
	and (''' + @ProfessionCodes + ''' = ''-1'' or
	(	SELECT count(*) 
		FROM x_Dept_Employee_Service as xDS 
		WHERE xDS.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID						
		AND ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ProfessionCodes + ''' ))) > 0
	)
	AND (''' + @ExpertProfessionCodes + ''' = ''-1'' or
	(	SELECT count(*) 
		FROM x_Dept_Employee_Service  as xDS 
		left join EmployeeServices on x_Dept_Employee.employeeID = EmployeeServices.employeeID 
					and xDS.ServiceCode = EmployeeServices.ServiceCode
					and EmployeeServices.expProfession = 1
		WHERE xDS.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID						
		and EmployeeServices.ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ExpertProfessionCodes + ''' ))) > 0
	)
	AND (''' + @ServiceCodes + ''' = ''-1'' or
	(	SELECT count(*) 
		FROM x_Dept_Employee_Service as xDS
		WHERE xDS.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID						
		AND ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ServiceCodes + ''' ))) > 0
	)
JOIN Employee ON x_Dept_Employee.employeeID = Employee.employeeID 
AND (''' + @EmployeeSector_cond + ''' = ''-1'' or Employee.EmployeeSectorCode IN (SELECT IntField FROM dbo.SplitString(''' + @EmployeeSector_cond + ''' )) )

inner join View_DeptEmployeesCurrentStatus as v_DECStatus 
	on x_Dept_Employee.deptCode = v_DECStatus.deptCode
	and Employee.employeeID = v_DECStatus.employeeID
	and v_DECStatus.status = 1

left JOIN View_EmployeeSector on Employee.EmployeeSectorCode = View_EmployeeSector.EmployeeSectorCode

join DIC_AgreementTypes on x_Dept_Employee.AgreementType = DIC_AgreementTypes.AgreementTypeID

left join dept as dAdmin on d.administrationCode = dAdmin.deptCode    
left join dept as dDistrict on d.districtCode = dDistrict.deptCode  
left join View_UnitType as UnitType on d.typeUnitCode =  UnitType.UnitTypeCode   
left join View_SubUnitTypes as SubUnitType on d.subUnitTypeCode =  SubUnitType.subUnitTypeCode
	 and  d.typeUnitCode =  SubUnitType.UnitTypeCode 
left join Cities on d.CityCode =  Cities.CityCode
left join deptSimul on d.DeptCode = deptSimul.DeptCode 
left join dept as dSubAdmin on d.subAdministrationCode = dSubAdmin.deptCode 

cross apply rfn_GetDeptEmployeeQueueOrderDetails(d.deptCode, x_Dept_Employee.employeeID) as QueueOrderDetails
left join DeptEmployeePhones as  emplPh1  on  x_Dept_Employee.DeptEmployeeID = emplPh1.DeptEmployeeID 
	and emplPh1.PhoneType = 1 and emplPh1.phoneOrder = 1  
left join DeptEmployeePhones as emplPh2  on  x_Dept_Employee.DeptEmployeeID = emplPh2.DeptEmployeeID 
	and emplPh2.PhoneType = 1 and emplPh2.phoneOrder = 2 
left join DeptEmployeePhones as emplPh3  on  x_Dept_Employee.DeptEmployeeID = emplPh3.DeptEmployeeID  
	and emplPh3.PhoneType = 2 and emplPh3.phoneOrder = 1 
left join DeptPhones dp1 on d.DeptCode = dp1.DeptCode and dp1.PhoneType = 1 and dp1.phoneOrder = 1  
left join DeptPhones dp2 on d.DeptCode = dp2.DeptCode and dp2.PhoneType = 1 and dp2.phoneOrder = 2 
left join DeptPhones dp3 on d.DeptCode = dp3.DeptCode and dp3.PhoneType = 2 and dp3.phoneOrder = 1 
left join PopulationSectors as ps on d.populationSectorCode = ps.PopulationSectorID 

left join [dbo].View_DeptEmployeeExpertProfessions as DEExpProfessions 
	on x_Dept_Employee.deptCode = DEExpProfessions.deptCode
	and Employee.employeeID = DEExpProfessions.employeeID 

left join [dbo].View_DeptEmployeePositions as DEPositions 
	on x_Dept_Employee.deptCode = DEPositions.deptCode
	and Employee.employeeID = DEPositions.employeeID 
	
left join [dbo].View_DeptEmployeeRemarks as DERemarks
	on x_Dept_Employee.deptCode = DERemarks.deptCode
	and Employee.employeeID = DERemarks.employeeID 
		
------------ Dept and services Reception --------------
left join dbo.View_DeptEmployeeReceptions   AS DeptReception on x_Dept_Employee.deptCode = DeptReception.deptCode
	and x_Dept_Employee.employeeID = DeptReception.employeeID

where (''' + @ServiceCodes + ''' = ''-1'' or
	(	
		SELECT count(*) 
		FROM x_Dept_Employee_Service 
		WHERE x_Dept_Employee.DeptEmployeeID = x_Dept_Employee_Service.DeptEmployeeID									
		AND ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ServiceCodes + ''' ))) > 0
	)	
	 and (''' + @ProfessionCodes + ''' = ''-1'' or
	(	
		SELECT count(*) 
		FROM x_Dept_Employee_Service 
		WHERE x_Dept_Employee.DeptEmployeeID = x_Dept_Employee_Service.DeptEmployeeID									
		AND ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ProfessionCodes + ''' ))) > 0
	)' + @NewLineChar;		
----------------------------------------------------------------------------------

if(@adminClinic = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dAdmin.DeptName as AdminClinicName ,
				 isNull(dAdmin.DeptCode , -1) as AdminClinicCode '+ @NewLineChar;
	end 
	
if(@district = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
		set @sql = @sql + ' dDistrict.DeptName as DistrictName , isNull(dDistrict.deptCode , -1) as DeptCode '+ @NewLineChar;
	end	
if(@unitType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' UnitType.UnitTypeCode as UnitTypeCode , UnitType.UnitTypeName as UnitTypeName '+ @NewLineChar;
	end
if(@subUnitType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
		' subUnitType.subUnitTypeCode as subUnitTypeCode , subUnitType.subUnitTypeName as subUnitTypeName '+ 
		@NewLineChar;
	end 
	
if( @ClinicName= '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'd.DeptName as ClinicName ' + @NewLineChar;	
	end

if( @ClinicCode= '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' d.deptCode as ClinicCode ' + @NewLineChar;	
	end

if(@simul = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'deptSimul.Simul228 as Code228 '+ @NewLineChar;
	end 

if(@subAdminClinic = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'dSubAdmin.DeptCode as SubAdminClinicCode , dSubAdmin.DeptName as SubAdminClinicName '+ @NewLineChar;
	end 			
	
if(@city = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);			
		set @sql = @sql + ' Cities.CityCode as CityCode, Cities.CityName as CityName'+ @NewLineChar;
	end

if (@address = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'dbo.GetAddress(d.deptCode) as ClinicAddress '+ @NewLineChar;
	end	
	
if(@Phone1 = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp1.prePrefix, dp1.Prefix,dp1.Phone, dp1.extension ) as Phone1 '+ @NewLineChar;;
end

if(@Phone2 = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp2.prePrefix, dp2.Prefix, dp2.Phone, dp2.extension) as Phone2 '+ @NewLineChar;;
end 

if(@Fax = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp3.prePrefix, dp3.Prefix, dp3.Phone, dp3.extension) as Fax '+ @NewLineChar;
end

if(@Email = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' d.Email as Email '+ @NewLineChar;
	end

if(@MangerName = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dbo.fun_getManagerName(d.deptCode) as MangerName '+ @NewLineChar;							   
	end

if(@adminMangerName = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dbo.fun_getAdminManagerName(d.deptCode) as AdminMangerName '+ @NewLineChar;
	end

if(@sector = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' ps.PopulationSectorID as SectorCode ,ps.PopulationSectorDescription as SectorName'+ @NewLineChar;
	end 	 	

if(@EmployeeName = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'Employee.firstName as EmployeeFirstName, Employee.lastName as EmployeeLastName'+ @NewLineChar;
	end
	
if(@EmployeeID = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.EmployeeID as EmployeeID '+ @NewLineChar;
	end
	
if(@EmployeeLicenseNumber = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.licenseNumber as EmployeeLicenseNumber '+ @NewLineChar;
	end

if(@DeptEmployeeEmail = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'Employee.email as EmployeeEmail'+ @NewLineChar;
	end

if(@EmployeeSector = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' Employee.EmployeeSectorCode as EmployeeSectorCode,  
		View_EmployeeSector.EmployeeSectorDescription as EmployeeSectorDescription'+ @NewLineChar;
	end	


if(@Position = '1' ) 
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
			' DEPositions.PositionDescriptions as PositionDescription
			 ,DEPositions.PositionCodes as PositionCode' 
		+ @NewLineChar;
	end

if(@EmployeeExpertProfession = '1') 
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql +
			' DEExpProfessions.ExpertProfessionDescriptions as ExpertProfessionDescription
			 ,DEExpProfessions.ExpertProfessionCodes as ExpertProfessionCode' 
		+ @NewLineChar;
	end

if(@DeptEmployeeRemark = '1' )  -- changed
	begin
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
			' DERemarks.RemarkDescriptions as EmployeeRemarkDescription
			,DERemarks.RemarkCodes as EmployeeRemarkID'
		+ @NewLineChar;
	end



if(@DeptEmployeePhone = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'case when x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1
		then dbo.fun_ParsePhoneNumberWithExtension(dp1.prePrefix, dp1.Prefix, dp1.Phone, dp1.Extension )
		else dbo.fun_ParsePhoneNumberWithExtension(emplPh1.prePrefix, emplPh1.Prefix, emplPh1.Phone, emplPh1.Extension )end as EmployeePhone1 '+ @NewLineChar;;

		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'case when x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1
		then dbo.fun_ParsePhoneNumberWithExtension(dp2.prePrefix, dp2.Prefix, dp2.Phone, dp2.Extension )
		else dbo.fun_ParsePhoneNumberWithExtension(emplPh2.prePrefix, emplPh2.Prefix, emplPh2.Phone, emplPh2.Extension )end as EmployeePhone2 '+ @NewLineChar;;
	end

if(@DeptEmployeeFax = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'case when x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1
		then dbo.fun_ParsePhoneNumberWithExtension(dp3.prePrefix, dp3.Prefix, dp3.Phone, dp3.Extension ) 
		else dbo.fun_ParsePhoneNumberWithExtension(emplPh3.prePrefix, emplPh3.Prefix, emplPh3.Phone, emplPh3.Extension )end as EmployeeFax '+ @NewLineChar;;
	end

if(@AgreementType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql 
		+ 'DIC_AgreementTypes.AgreementTypeID as AgreementTypeCode,
		 DIC_AgreementTypes.AgreementTypeDescription as AgreementTypeDescription '
		+ @NewLineChar;
	end	

------------ @DeptEmployeeServices -------------------------------------------------------------------------------------

if(@DeptEmployeeServices = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + '[DeptReception].serviceDescription  as serviceDescription,
	 [DeptReception].serviceCode  as serviceCode  ' + @NewLineChar;
end 

------------ @Professions -------------------------------------------------------

if(@Professions = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + '[DeptReception].ProfessionDescription  as ProfessionDescription,
	 [DeptReception].ProfessionCode  as ProfessionCode  ' + @NewLineChar;
end 


------------ RecepDay ------------------------------------------------------------
if(@RecepDay = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' [DeptReception].ReceptionDayName  as ReceptionDayName ' + @NewLineChar;
	end 

----------- RecepOpeningHour --------------------------------------------------
if(@RecepOpeningHour = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' [DeptReception].openingHour  as openingHour ' + @NewLineChar;
end 

----------- RecepClosingHour --------------------------------------------------
if(@RecepClosingHour = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' [DeptReception].closingHour  as closingHour ' + @NewLineChar;
end 

----------- RecepTotalHours --------------------------------------------------
if(@RecepTotalHours = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' [DeptReception].totalHours  as totalHours ' + @NewLineChar;
end 

----------- RecepValidFrom --------------------------------------------------
if(@RecepValidFrom = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' CONVERT(varchar(10), [DeptReception].validFrom, 103)  as  validFrom  ' + @NewLineChar;
end 

----------- RecepValidTo --------------------------------------------------
if(@RecepValidTo = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' CONVERT(varchar(10), [DeptReception].validTo, 103) as  validTo ' + @NewLineChar;
end 

----------- RecepRemark --------------------------------------------------
if(@RecepRemark = '1' )
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' [DeptReception].remarkText  as RecepRemark ' + @NewLineChar;
end 


--=================================================================

set @sql = @sql + @sqlFrom + @sqlWhere + @sqlEnd

print '--------- sql query full ----------'
print '--===== @sql string length = ' + str(len(@sql))
Exec rpc_HelperLongPrint @sql 

EXECUTE sp_executesql @sql 
SET @ErrCode = @sql 
RETURN 

GO
GRANT EXEC ON [dbo].rprt_DeptEmployeeReceptions TO PUBLIC
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_DeptEmployeeAndPharmacyReceptionDifferences')
	BEGIN
		DROP  Procedure  dbo.rprt_DeptEmployeeAndPharmacyReceptionDifferences
	END
GO

CREATE Procedure dbo.rprt_DeptEmployeeAndPharmacyReceptionDifferences
(
	@DistrictCodes varchar(max)=null,
	@AdminClinicCode varchar(max)=null,
	@ReceptionHoursSpan_cond varchar(max)=null,
	@EmployeeSector_cond varchar(max) = null,
	@IncludeSubClinicEmployees_cond varchar (2)=null,
	@AgreementType_cond varchar(max)=null,
	@IsExcelVersion varchar (2)=null,
	@ErrCode varchar(max) OUTPUT
--------------------------------------
)with recompile

AS
--------------------------------------

DECLARE @NewLineChar AS CHAR(2) 
set @NewLineChar = CHAR(13) + CHAR(10)

DECLARE @ReceptionHoursSpan int
if (@ReceptionHoursSpan_cond is null or @ReceptionHoursSpan_cond = '-1' or ISDATE(@ReceptionHoursSpan_cond)= 0)
		set @ReceptionHoursSpan = 24*60 
		--CAST('00:00' as time(0))
	else
		set @ReceptionHoursSpan = datediff(minute,'00:00', @ReceptionHoursSpan_cond)
		--CAST(@ReceptionHoursSpan_cond as time(0))
	 
		
SET DATEFORMAT dmy;

SELECT distinct *  from
(select 
 dDistrict.DeptName as DistrictName , isNull(dDistrict.deptCode , -1) as DeptCode 
,dAdmin.DeptName as AdminClinicName , isNull(dAdmin.DeptCode , -1) as AdminClinicCode
				 
,d.DeptName as ClinicName 
,d.deptCode as ClinicCode 
,deptSimul.Simul228 as Code228 
,d.typeUnitCode as ClinicUnitTypeCode
,d.subAdministrationCode as ClinicSubAdminCode

,SubClinics.DeptName as SubClinicName 
,SubClinics.deptCode as SubClinicCode 
,SubClinicDeptSimul.Simul228 as SubClinicCode228 
,SubClinicUnitType.UnitTypeCode as SubClinicUnitTypeCode -- for tes
,SubClinicUnitType.UnitTypeName as SubClinicUnitTypeName -- for tes
,SubClinics.subAdministrationCode as SubClinicSubAdminCode 

,Employee.employeeID as employeeID
,Employee.firstName as EmployeeFirstName 
,Employee.lastName as EmployeeLastName
,View_EmployeeSector.EmployeeSectorCode -- for test
,View_EmployeeSector.EmployeeSectorDescription -- for test

,DIC_ReceptionDays.ReceptionDayName as ReceptionDayName

,dbo.rfn_GetDeptReceptionsString(SubClinics.DeptCode, SubClinicDeptReception.receptionDay, 1) as  subDeptReceptions
,dbo.rfn_GetDeptEmployeeReceptionsString(x_Dept_Employee.DeptEmployeeID, SubClinicDeptReception.receptionDay) as  DeptEmployeeReceptions

,Intervals.intervalsStr as nonIntersectedInterv	
,Intervals.intervalsValues_str  as intervalsValues
,Intervals.intervalsSum_minu as intervalsSum

from x_Dept_Employee 
join dept  as d  on x_Dept_Employee.deptCode = d.deptCode 
	and x_Dept_Employee.active = 1
	and d.status = 1
	AND (@DistrictCodes = '-1' or  d.districtCode IN (SELECT IntField FROM dbo.SplitString( @DistrictCodes)) )
	AND (@AdminClinicCode = '-1' or  d.administrationCode IN (SELECT IntField FROM dbo.SplitString( @AdminClinicCode)) )
	AND (@AgreementType_cond  = '-1' or x_Dept_Employee.AgreementType IN (SELECT IntField FROM dbo.SplitString(@AgreementType_cond ))) 

join dept as SubClinics on 
	 SubClinics.typeUnitCode  = 401 -- pharmacy
	and SubClinics.status = 1
	and (
	(@IncludeSubClinicEmployees_cond = '1' -- yes
	and (d.deptCode = SubClinics.subAdministrationCode -- dept is parent of pharmacy
		or d.subAdministrationCode = SubClinics.subAdministrationCode)) -- dept is brather of pharmacy 
	
	or(@IncludeSubClinicEmployees_cond = '0' -- no
	and d.deptCode = SubClinics.subAdministrationCode) -- dept is parent of pharmacy
	) 
		
join Employee on x_Dept_Employee.employeeID = Employee.employeeID
	and Employee.active = 1
	and (@EmployeeSector_cond = '-1' or Employee.EmployeeSectorCode = @EmployeeSector_cond)

join deptEmployeeReception  on x_Dept_Employee.DeptEmployeeID = deptEmployeeReception.DeptEmployeeID

left join DeptReception as SubClinicDeptReception on SubClinics.deptCode = SubClinicDeptReception.deptCode
JOIN DIC_ReceptionDays on SubClinicDeptReception.receptionDay = DIC_ReceptionDays.ReceptionDayCode
	and SubClinicDeptReception.receptionDay = deptEmployeeReception.receptionDay
	
INNER JOIN View_EmployeeSector on Employee.EmployeeSectorCode = View_EmployeeSector.EmployeeSectorCode
		
left join dept as dDistrict on d.districtCode = dDistrict.deptCode 
left join dept as dAdmin on d.administrationCode = dAdmin.deptCode    
left join deptSimul on d.DeptCode = deptSimul.DeptCode 	

left join View_UnitType as SubClinicUnitType on SubClinics.typeUnitCode =  SubClinicUnitType.UnitTypeCode  --
left join deptSimul as SubClinicDeptSimul on SubClinics.DeptCode = SubClinicDeptSimul.DeptCode 

cross apply rfn_GetDeptAndEmployeeReceptionIntervalNonIntersection
		(SubClinics.deptCode, x_Dept_Employee.DeptEmployeeID, 
		 SubClinicDeptReception.receptionDay, @ReceptionHoursSpan_cond, 1) as Intervals

) as resultTable
order by DeptCode, SubClinicCode, ClinicCode, employeeID, ReceptionDayName

RETURN 
SET DATEFORMAT mdy;
GO
GRANT EXEC ON [dbo].rprt_DeptEmployeeAndPharmacyReceptionDifferences TO PUBLIC
GO


--**** Yaniv - Start fun_getDeptServiceQueueOrderPhones_All *******************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_getDeptServiceQueueOrderPhones_All')
	BEGIN
		DROP  FUNCTION  fun_getDeptServiceQueueOrderPhones_All
	END
GO

CREATE FUNCTION [dbo].fun_getDeptServiceQueueOrderPhones_All(@ServiceCode int, @DeptCode int)
RETURNS varchar(1000)
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @ThereIsQueueOrderViaClinicPhone int
	SET @ThereIsQueueOrderViaClinicPhone = 0

	DECLARE @strPhones varchar(1000)
	SET @strPhones = ''

	SELECT @strPhones = @strPhones + dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) + '<br>'
	FROM EmployeeServiceQueueOrderPhones ESQOP
	INNER JOIN EmployeeServiceQueueOrderMethod ESQOM ON ESQOP.EmployeeServiceQueueOrderMethodID = ESQOM.EmployeeServiceQueueOrderMethodID
	join x_Dept_Employee_Service xDES on ESQOM.x_dept_employee_serviceID = xDES.x_Dept_Employee_ServiceID
	join x_Dept_Employee xDE on xDES.DeptEmployeeID = xDE.DeptEmployeeID
	WHERE xDE.deptCode  = @DeptCode
	AND xDES.serviceCode = @ServiceCode
	
SET @ThereIsQueueOrderViaClinicPhone =	
	(SELECT Count(*)
	FROM EmployeeServiceQueueOrderMethod ESQOM
	INNER JOIN DIC_QueueOrderMethod ON ESQOM.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
	join x_Dept_Employee_Service xDES on ESQOM.x_dept_employee_serviceID = xDES.x_Dept_Employee_ServiceID
	join x_Dept_Employee xDE on xDES.DeptEmployeeID = xDE.DeptEmployeeID
	WHERE xDE.deptCode  = @DeptCode
	AND xDES.serviceCode = @ServiceCode
	AND ShowPhonePicture = 1 AND SpecialPhoneNumberRequired = 0)
	
	IF(@ThereIsQueueOrderViaClinicPhone = 1)
	BEGIN
		SELECT TOP 1 @strPhones = @strPhones + dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) + '<br>'
		FROM DeptPhones
		WHERE deptCode = @DeptCode AND DeptPhones.phoneType = 1
		ORDER BY phoneOrder
		
	END
	
	
	IF(LEN(@strPhones) = 0)	
		BEGIN
			SET @strPhones = ''--'&nbsp;'
		END
	RETURN( @strPhones )
	
END

GO 

grant exec on fun_getDeptServiceQueueOrderPhones_All to public 
GO

 
--**** Yaniv - End fun_getDeptServiceQueueOrderPhones_All *******************

--**** Yaniv - Start rpc_insertServiceQueueOrderMethod **************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertServiceQueueOrderMethod')
	BEGIN
		DROP  Procedure  rpc_insertServiceQueueOrderMethod
	END

GO

CREATE Procedure rpc_insertServiceQueueOrderMethod
	(
		@DeptCode int,
		@ServiceCode int,
		@QueueOrderMethod int,
		@UpdateUser varchar(50),
		@ErrCode int = 0 OUTPUT,
		@QueueOrderMethodID int = 0 OUTPUT
	)

AS

	declare @xDeptEmployeeServiceID int

	set @xDeptEmployeeServiceID = (select xDES.x_Dept_Employee_ServiceID from x_Dept_Employee_Service xDES
			join x_Dept_Employee xDE on xDES.DeptEmployeeID = xDE.DeptEmployeeID 
			WHERE deptCode  = @DeptCode
				AND serviceCode = @ServiceCode)
	INSERT INTO EmployeeServiceQueueOrderMethod
	(QueueOrderMethod, updateDate, UpdateUser, x_dept_employee_serviceID)
	VALUES
	(@QueueOrderMethod, getdate(), @UpdateUser, @xDeptEmployeeServiceID)
	
	SET @ErrCode = @@Error
	SET @QueueOrderMethodID = @@IDENTITY
	
	IF(@QueueOrderMethodID is null)
	BEGIN
		SET @QueueOrderMethodID = 0
	END

GO

GRANT EXEC ON rpc_insertServiceQueueOrderMethod TO PUBLIC

GO


--**** Yaniv - End rpc_insertServiceQueueOrderMethod **************************

--**** Yaniv - Start rpc_deleteServiceQueueOrderMethods **************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteServiceQueueOrderMethods')
	BEGIN
		DROP  Procedure  rpc_deleteServiceQueueOrderMethods
	END

GO

CREATE Procedure dbo.rpc_deleteServiceQueueOrderMethods
	(
		@DeptCode int,
		@ServiceCode int,
		@ErrCode int OUTPUT
	)

AS

		DELETE FROM EmployeeServiceQueueOrderHours
		WHERE EmployeeServiceQueueOrderMethodID IN (SELECT ESQOM.EmployeeServiceQueueOrderMethodID
									FROM EmployeeServiceQueueOrderMethod ESQOM
									join x_Dept_Employee_Service xDES on ESQOM.x_dept_employee_serviceID = xDES.x_Dept_Employee_ServiceID
										join x_Dept_Employee xDE on xDES.DeptEmployeeID = xDE.DeptEmployeeID
										WHERE xDE.deptCode  = @DeptCode
										AND xDES.serviceCode = @ServiceCode)
									
		DELETE FROM EmployeeServiceQueueOrderPhones
		WHERE EmployeeServiceQueueOrderMethodID IN (SELECT ESQOM.EmployeeServiceQueueOrderMethodID
									FROM EmployeeServiceQueueOrderMethod ESQOM
									join x_Dept_Employee_Service xDES on ESQOM.x_dept_employee_serviceID = xDES.x_Dept_Employee_ServiceID
										join x_Dept_Employee xDE on xDES.DeptEmployeeID = xDE.DeptEmployeeID
										WHERE xDE.deptCode  = @DeptCode
										AND xDES.serviceCode = @ServiceCode)
									
		DELETE FROM EmployeeServiceQueueOrderMethod
		WHERE EmployeeServiceQueueOrderMethodID in
		(
			SELECT ESQOM.EmployeeServiceQueueOrderMethodID
				FROM EmployeeServiceQueueOrderMethod ESQOM
				join x_Dept_Employee_Service xDES on ESQOM.x_dept_employee_serviceID = xDES.x_Dept_Employee_ServiceID
					join x_Dept_Employee xDE on xDES.DeptEmployeeID = xDE.DeptEmployeeID
					WHERE xDE.deptCode  = @DeptCode
					AND xDES.serviceCode = @ServiceCode
		)

		SET @ErrCode = @@Error

GO

GRANT EXEC ON rpc_deleteServiceQueueOrderMethods TO PUBLIC

GO


--**** Yaniv - End rpc_deleteServiceQueueOrderMethods **************************


--**** Yaniv - Start rpc_insertServiceQueueOrderHours **************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertServiceQueueOrderHours')
	BEGIN
		DROP  Procedure  rpc_insertServiceQueueOrderHours
	END

GO

CREATE PROCEDURE dbo.rpc_insertServiceQueueOrderHours
	(
		@EmployeeServiceQueueOrderMethodID int,
		@ReceptionDay int,
		@FromHour varchar(5),
		@ToHour varchar(5),
		@UpdateUser varchar(50),
		@ErrCode int = 0 OUTPUT
	)

AS

	INSERT INTO EmployeeServiceQueueOrderHours
	(EmployeeServiceQueueOrderMethodID, receptionDay, FromHour, ToHour, updateDate, UpdateUser)
	VALUES
	(@EmployeeServiceQueueOrderMethodID, @ReceptionDay, @FromHour, @ToHour, getdate(), @UpdateUser)

	SET @ErrCode = @@Error

GO

GRANT EXEC ON rpc_insertServiceQueueOrderHours TO PUBLIC

GO



--**** Yaniv - End rpc_insertServiceQueueOrderHours **************************


--**** Yaniv - Start rpc_insertServiceQueueOrderPhone **************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertServiceQueueOrderPhone')
	BEGIN
		DROP  Procedure  rpc_insertServiceQueueOrderPhone
	END

GO

CREATE PROCEDURE dbo.rpc_insertServiceQueueOrderPhone
(
		@E_ServiceQueueOrderMethodID int,
		@prePrefix int,
		@prefix int,
		@phone int,
		@extension int,
		@updateUser varchar(50),
		@ErrCode int OUTPUT
	)

AS

IF(@prefix = -1)
	BEGIN
		SET @prefix = null
	END
	
IF(@prePrefix = -1)	
	BEGIN
		SET @prePrefix = null
	END
	
IF(@extension = -1)	
	BEGIN
		SET @extension = null
	END	

DECLARE @PhoneOrder int

SET @PhoneOrder = (SELECT MAX(PhoneOrder) + 1 
					FROM EmployeeServiceQueueOrderPhones 
					WHERE EmployeeServiceQueueOrderMethodID = @E_ServiceQueueOrderMethodID)
SET @PhoneOrder = IsNull(@PhoneOrder,1)


	INSERT INTO EmployeeServiceQueueOrderPhones
	(
		EmployeeServiceQueueOrderMethodID,
		phoneType,
		phoneOrder,
		prePrefix,
		prefix,
		phone,
		extension,
		updateDate,
		updateUser	
	)
	VALUES
	(
		@E_ServiceQueueOrderMethodID,
		1,
		@PhoneOrder,
		@prePrefix,
		@prefix,
		@phone,
		@extension,
		getdate(),
		@updateUser
	)
	SET @ErrCode = @@Error


GO


GRANT EXEC ON rpc_insertServiceQueueOrderPhone TO PUBLIC

GO



--**** Yaniv - End rpc_insertServiceQueueOrderPhone **************************
IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'fun_GetDeptServiceHoursRemarks')
	BEGIN
		DROP  FUNCTION  fun_GetDeptServiceHoursRemarks
	END

GO
CREATE FUNCTION [dbo].[fun_GetDeptServiceHoursRemarks]
(
	@EmployeeReceptionID int
)

RETURNS varchar(1000)
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @strRemarks varchar(1000)
	SET @strRemarks = ''

	SELECT @strRemarks = @strRemarks +  REPLACE(RemarkText,'#','') + '<br>'
		FROM DeptEmployeeReceptionRemarks 
		WHERE EmployeeReceptionID = @EmployeeReceptionID
			
	RETURN( @strRemarks )
	
END
GO

GRANT EXEC ON fun_GetDeptServiceHoursRemarks TO PUBLIC
GO

---------------------------------------------------------------

IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rpc_updateDept')
	BEGIN
		PRINT 'Dropping Procedure rpc_updateDept'
		DROP  Procedure  rpc_updateDept
	END

GO

PRINT 'Creating Procedure rpc_updateDept'
GO     

CREATE Procedure dbo.rpc_updateDept
	(
	@DeptCode int,
	@DeptType int,
	@UnitType int,
	@SubUnitType int,
	@ManagerName varchar(50),
	@AdministrativeManagerName varchar(50),		
	@DistrictCode int,
	@AdministrationCode int,
	@SubAdministrationCode int,
	@Parking int,
	@PopulationSectorCode int,
	@CityCode int,
	@StreetCode varchar(50),
	@StreetName varchar(50),
	@House varchar(50),
	@Flat varchar(50),
	@Floor varchar(10),
	@AddressComment varchar(500),
	@Transportation varchar(50),
	@Email varchar(50),
	@ShowEmailInInternet int,
	@ShowUnitInInternet int,	
	@allowQueueOrder bit,
	@CascadeUpdateSubDeptPhones tinyint,
	@CascadeUpdateEmployeeInClinicPhones tinyint,
	@UpdateUser varchar(50),
	@NeighbourhoodOrInstituteCode varchar(50),
	@IsSite int,
	@AdditionalDistricts varchar(100),

	@ErrorStatus int output
	)

AS

IF RTRIM(LTRIM(@StreetName)) = ''
BEGIN
	SET @StreetName = null
	SET @StreetCode = null
END


UPDATE dept
SET 
deptType = @DeptType,
typeUnitCode = @UnitType,
subUnitTypeCode = @SubUnitType,
managerName = @ManagerName,
administrativeManagerName = @AdministrativeManagerName,
districtCode = @DistrictCode,
administrationCode = @AdministrationCode,
subAdministrationCode = @SubAdministrationCode,
parking = @Parking,
populationSectorCode = @PopulationSectorCode,	
cityCode = @CityCode,
StreetCode = @StreetCode,
streetName = @StreetName,
NeighbourhoodOrInstituteCode = @NeighbourhoodOrInstituteCode,
IsSite = @IsSite,
house = @House,
flat = @Flat,
floor = @Floor,
addressComment = @AddressComment,
transportation = @Transportation,
email = @Email,
showEmailInInternet = @ShowEmailInInternet,
showUnitInInternet = @ShowUnitInInternet,
QueueOrder = CASE @allowQueueOrder WHEN 0 THEN NULL ELSE QueueOrder END,
updateDate = getdate(),
UpdateUser = @UpdateUser

WHERE deptCode = @DeptCode

DELETE FROM x_Dept_District WHERE deptCode = @DeptCode

INSERT INTO x_Dept_District
(deptCode, districtCode)
SELECT 
@DeptCode, IntField 
FROM dbo.SplitString(@AdditionalDistricts)
WHERE IntField <> @DistrictCode

SET @ErrorStatus = @@Error


GO

GRANT EXEC ON rpc_updateDept TO PUBLIC
GO
   
--**** Yaniv - Start rpc_DeleteDeptServiceStatus *****************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteDeptServiceStatus')
	BEGIN
		DROP  Procedure  rpc_DeleteDeptServiceStatus
	END

GO

CREATE Procedure dbo.rpc_DeleteDeptServiceStatus
(
	@deptCode INT,
	@serviceCode INT,
	@employeeID bigint
	
)

AS


DELETE DeptEmployeeServiceStatus
WHERE x_dept_employee_serviceID in
(
	select DESS.x_dept_employee_serviceID from DeptEmployeeServiceStatus DESS
	join x_Dept_Employee_Service xDES on DESS.x_dept_employee_serviceID = xDES.x_Dept_Employee_ServiceID
	join x_Dept_Employee xDE on xDES.DeptEmployeeID = xDE.DeptEmployeeID
	where xDE.deptCode = @deptCode
	and xDES.serviceCode = @serviceCode
	and xDE.employeeID = @employeeID
)

GO


GRANT EXEC ON rpc_DeleteDeptServiceStatus TO PUBLIC

GO


--**** Yaniv - End rpc_DeleteDeptServiceStatus *****************



--**** Yaniv - Start rpc_GetAllDeptServiceStatuses *****************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetAllDeptServiceStatuses')
	BEGIN
		DROP  Procedure  rpc_GetAllDeptServiceStatuses
	END

GO

CREATE Procedure dbo.rpc_GetAllDeptServiceStatuses
(	
	@deptCode INT,
	@serviceCode INT,
	@employeeID bigint
)

AS

select DESS.Status, StatusDescription, FromDate, ToDate
from DeptEmployeeServiceStatus DESS
JOIN DIC_ActivityStatus dic ON DESS.Status = dic.Status
join x_Dept_Employee_Service xDES on DESS.x_dept_employee_serviceID = xDES.x_Dept_Employee_ServiceID
join x_Dept_Employee xDE on xDES.DeptEmployeeID = xDE.DeptEmployeeID
where xDE.deptCode = @deptCode
	and xDE.employeeID = @employeeID
	and xDES.serviceCode = @serviceCode
ORDER BY FromDate ASC


GO


GRANT EXEC ON rpc_GetAllDeptServiceStatuses TO PUBLIC

GO


--**** Yaniv - End rpc_GetAllDeptServiceStatuses *****************

-- *************************************************************************************************************************

--**** Yaniv - Start rpc_GetDeptReceptionAndRemarks ***************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDeptReceptionAndRemarks')
	BEGIN
		drop procedure rpc_GetDeptReceptionAndRemarks
	END

GO



CREATE Procedure [dbo].[rpc_GetDeptReceptionAndRemarks]
(
	@DeptCode int,
	@ExpirationDate datetime
)
as


------ dept receptions ------------------------------------- OK!
SELECT 
DeptReception.receptionID,
DeptReception.receptionDay,
vReceptionDaysForDisplay.ReceptionDayName,
'openingHour' = 
	CASE DeptReception.closingHour 
		WHEN '00:00' THEN	 
			CASE DeptReception.openingHour WHEN '00:01' THEN '24' WHEN '01:00' THEN '24' WHEN '00:00' THEN '24' ELSE DeptReception.openingHour END
		WHEN '23:59' THEN	
			CASE DeptReception.openingHour WHEN '00:01' THEN '24' WHEN '01:00' THEN '24' WHEN '00:00' THEN '24' ELSE DeptReception.openingHour END
		ELSE DeptReception.openingHour END,
'closingHour' =
	CASE DeptReception.closingHour 
		WHEN '00:00' THEN	
			CASE DeptReception.openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN '00:00' THEN 'שעות' ELSE DeptReception.closingHour END
		WHEN '23:59' THEN	
			CASE DeptReception.openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN '00:00' THEN 'שעות' ELSE DeptReception.closingHour END
		ELSE DeptReception.closingHour END,

'ReceptionDaysCount' = 
	(select count(receptionDay) 
		FROM DeptReception
		where deptCode = @DeptCode
		and ((
		(validFrom is not null AND @ExpirationDate >= validFrom )
		and (validTo is not null and DATEDIFF(dd, validTo , @ExpirationDate) <= 0) )
		OR (validFrom IS NULL AND validTo IS NULL) )
	),	
'remarks' = dbo.fun_getDeptReceptionRemarksValid(receptionID),
'ExpirationDate' = ValidTo,
'WillExpireIn' = DATEDIFF(dd, GETDATE(), IsNull(ValidTo,'01/01/2050')),
ReceptionHoursTypeID

FROM DeptReception
INNER JOIN vReceptionDaysForDisplay on DeptReception.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode

WHERE deptCode = @DeptCode
AND (validFrom is null OR @ExpirationDate >= validFrom )
AND (validTo is null OR DATEDIFF(dd, validTo , @ExpirationDate) <= 0) 
ORDER BY receptionDay, openingHour

--------- Clinic General Remarks ------------------------- OK!
SELECT remarkID
--, REPLACE(RemarkText,'#','') as RemarkText
, dbo.rfn_GetFotmatedRemark(RemarkText) as RemarkText
, validFrom
, validTo
, displayInInternet
--, 1 as ComprehensiveRemark
, RemarkDeptCode as deptCode
, View_DeptRemarks.IsSharedRemark -- as 'sweeping' 
, ShowOrder
FROM View_DeptRemarks
WHERE deptCode = @deptCode
--AND validFrom < @DateAfterExpiration AND ( validTo is null OR validTo >= @ExpirationDate )
AND DATEDIFF(dd, validFrom , @ExpirationDate) >= 0
AND ( validTo is null OR DATEDIFF(dd, validTo , @ExpirationDate) <= 0 ) 
ORDER BY IsSharedRemark desc ,ShowOrder asc 

-- Clinic name & District name
SELECT 
dept.deptName, 
View_AllDistricts.districtName,
cityName,
'address' = dbo.GetAddress(@DeptCode),
'phone' = (
	SELECT TOP 1 dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension)
	FROM DeptPhones
	WHERE deptCode = @DeptCode
	AND phoneType = 1
	ORDER BY phoneOrder)
FROM dept
INNER JOIN View_AllDistricts ON dept.districtCode = View_AllDistricts.districtCode
INNER JOIN Cities ON dept.cityCode = Cities.cityCode
WHERE dept.deptCode = @DeptCode



--------- Dept Reception Remarks   -------------------------------------------------
SELECT
ReceptionID,
RemarkText
FROM DeptReceptionRemarks
WHERE ReceptionID IN (SELECT receptionID FROM DeptReception WHERE deptCode = @DeptCode)
AND validFrom <= @ExpirationDate 
AND ( validTo is null OR DATEDIFF(dd, validTo , @ExpirationDate) <= 0) 

-- ReceptionDaysUnited for ClinicReception and OfficeServicesReception
-- it's useful to build synchronised GridView for both receptions
SELECT deptEmployeeReception.receptionDay, ReceptionDayName
FROM deptEmployeeReceptionServices
join deptEmployeeReception on deptEmployeeReceptionServices.receptionID = deptEmployeeReception.receptionID
INNER JOIN [Services] ON deptEmployeeReceptionServices.serviceCode = [Services].serviceCode
INNER JOIN vReceptionDaysForDisplay ON deptEmployeeReception.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode
join x_Dept_Employee on deptEmployeeReception.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID


AND x_Dept_Employee.deptCode = @DeptCode
AND (
		(   
			 ((validFrom IS not NULL and  validTo IS NULL) and (@ExpirationDate >= validFrom ))			
		  or ((validFrom IS NULL and validTo IS not NULL) and validTo >= @ExpirationDate)
		  or ((validFrom IS not NULL and  validTo IS not NULL) and (@ExpirationDate >= validFrom and validTo >= @ExpirationDate))
		
	     )
	  OR (validFrom IS NULL AND validTo IS NULL)
	)

UNION

SELECT DeptReception.receptionDay, ReceptionDayName
FROM DeptReception
INNER JOIN vReceptionDaysForDisplay ON DeptReception.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode
WHERE DeptReception.deptCode = @DeptCode
AND (
			(   
				((validFrom IS not NULL and  validTo IS NULL) and (@ExpirationDate >= validFrom ))			
				or ((validFrom IS NULL and validTo IS not NULL) and validTo >= @ExpirationDate)
				or ((validFrom IS not NULL and  validTo IS not NULL) and (@ExpirationDate >= validFrom and validTo >= @ExpirationDate))
		
			)
			OR (validFrom IS NULL AND validTo IS NULL)
		)

ORDER BY receptionDay


-- closest dept reception change
SELECT MIN(ValidFrom)
FROM DeptReception
WHERE deptCode = @deptCode
AND DATEDIFF(dd, ValidFrom, GETDATE()) < 0
AND DATEDIFF(dd, ValidFrom, GETDATE()) >= -14

-- closest office reception change
SELECT MIN(ValidFrom)
FROM DeptReception
WHERE ReceptionHoursTypeID = 2
AND deptCode = @deptCode
AND DATEDIFF(dd, ValidFrom, GETDATE()) < 0
AND DATEDIFF(dd, ValidFrom, GETDATE()) >= -14

-- ReceptionHoursType
SELECT distinct DIC_ReceptionHoursTypes.ReceptionHoursTypeID,DIC_ReceptionHoursTypes.ReceptionTypeDescription FROM DeptReception
join DIC_ReceptionHoursTypes on DeptReception.ReceptionHoursTypeID = DIC_ReceptionHoursTypes.ReceptionHoursTypeID
where deptCode = @DeptCode

-- DefaultReceptionHoursType
SELECT DefaultReceptionHoursTypeID,DIC_ReceptionHoursTypes.ReceptionTypeDescription from subUnitType
join Dept on subUnitType.UnitTypeCode = Dept.typeUnitCode
and subUnitType.subUnitTypeCode = Dept.subUnitTypeCode
join DIC_ReceptionHoursTypes on subUnitType.DefaultReceptionHoursTypeID = DIC_ReceptionHoursTypes.ReceptionHoursTypeID
where Dept.deptCode = @DeptCode

-- Closest reception change for each ReceptionType
select min(d.validFrom) as nextDateChange, d.ReceptionHoursTypeID 
from DeptReception d
where (d.validFrom between GETDATE() and dateadd(day, 14, GETDATE())
	and deptCode = @DeptCode)
group by d.ReceptionHoursTypeID
GO


GRANT EXEC ON rpc_GetDeptReceptionAndRemarks TO PUBLIC
GO


--**** Yaniv - End rpc_GetDeptReceptionAndRemarks ***************************


--**** Yaniv - Start rpc_InsertDeptServiceStatus ***************************


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertDeptServiceStatus')
	BEGIN
		DROP  Procedure  rpc_InsertDeptServiceStatus
	END

GO

CREATE Procedure dbo.rpc_InsertDeptServiceStatus
(	
	@deptCode INT,
	@serviceCode INT,
	@employeeID bigint,
	@status SMALLINT,
	@fromDate DATETIME,
	@toDate DATETIME,
	@userName VARCHAR(30)
)

AS

declare @xDeptEmployeeServiceID int

set @xDeptEmployeeServiceID = (select x_dept_employee_serviceID
	from x_Dept_Employee_Service xDES join x_Dept_Employee xDE
	on xDES.DeptEmployeeID = xDE.DeptEmployeeID
	where xDES.serviceCode = @serviceCode 
	and xDE.deptCode = @deptCode and xDE.employeeID = @employeeID)

INSERT INTO DeptEmployeeServiceStatus(Status, FromDate, ToDate, UpdateUser,
	UpdateDate, x_dept_employee_serviceID)
	values(@status, @fromDate, @toDate, @userName, GETDATE(), @xDeptEmployeeServiceID)


GO


GRANT EXEC ON rpc_InsertDeptServiceStatus TO PUBLIC

GO
--**** Yaniv - End rpc_InsertDeptServiceStatus ***************************



--**** Yaniv - Start rpc_DeleteEmployeeStatusInDept ***************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteEmployeeStatusInDept')
	BEGIN
		DROP  Procedure  rpc_DeleteEmployeeStatusInDept
	END

GO

CREATE Procedure dbo.rpc_DeleteEmployeeStatusInDept
(
	@employeeID BIGINT,
	@deptCode	INT
)

AS

declare @deptEmployeeID bigint
set @deptEmployeeID = 
(
	select DeptEmployeeID from x_Dept_Employee
	where deptCode = @deptCode and employeeID = @employeeID
)

DELETE EmployeeStatusInDept
WHERE DeptEmployeeID = @deptEmployeeID


GO


GRANT EXEC ON rpc_DeleteEmployeeStatusInDept TO PUBLIC

GO



--**** Yaniv - End rpc_DeleteEmployeeStatusInDept ***************************


--**** Yaniv - Start rpc_insertEmployeeStatusInDept ***************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertEmployeeStatusInDept')
	BEGIN
		DROP  Procedure  rpc_insertEmployeeStatusInDept
	END

GO

CREATE Procedure dbo.rpc_insertEmployeeStatusInDept
(
	@employeeID BIGINT,
	@deptCode	INT,
	@status		INT,
	@fromDate	DATETIME,
	@toDate		DATETIME,
	@updateUser	VARCHAR(50)
)

AS

declare @deptEmployeeID bigint
set @deptEmployeeID = 
(
	select DeptEmployeeID from x_Dept_Employee
	where deptCode = @deptCode and employeeID = @employeeID
)

INSERT INTO EmployeeStatusInDept (Status, FromDate, ToDate, UpdateUser, UpdateDate, DeptEmployeeID)
VALUES ( @status, @fromDate, @toDate, @updateUser, GETDATE(), @deptEmployeeID )


GO


GRANT EXEC ON rpc_insertEmployeeStatusInDept TO PUBLIC

GO


--**** Yaniv - End rpc_insertEmployeeStatusInDept ***************************


--**** Yaniv - Start rpc_DeleteEmployeeReceptionInDept ***************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteEmployeeReceptionInDept')
	BEGIN
		DROP  Procedure  rpc_DeleteEmployeeReceptionInDept
	END

GO

CREATE Procedure dbo.rpc_DeleteEmployeeReceptionInDept
(
	@employeeID BIGINT,
	@deptCode INT
	
)

AS
declare @deptEmployeeID bigint
set @deptEmployeeID = 
(
	select DeptEmployeeID from x_Dept_Employee
	where deptCode = @deptCode and employeeID = @employeeID
)

DELETE DeptEmployeeReception
WHERE DeptEmployeeID = @deptEmployeeID


GO




GRANT EXEC ON rpc_DeleteEmployeeReceptionInDept TO PUBLIC

GO



--**** Yaniv - End rpc_DeleteEmployeeReceptionInDept ***************************



--**** Yaniv - Start rpc_deleteDeptEmployeeReceptionRemarks ***************************
  

IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rpc_deleteDeptEmployeeReceptionRemarks')
	BEGIN
		DROP  Procedure  rpc_deleteDeptEmployeeReceptionRemarks
	END

GO


CREATE Procedure dbo.rpc_deleteDeptEmployeeReceptionRemarks
	(
		@DeptEmployeeReceptionRemarkID int,
		@errorCode int = 0 OUTPUT
	)

AS

SET @errorCode = 0

DECLARE @EnableOverlappingHours int

DECLARE @EmployeeReceptionID int
DECLARE	@DeptCode int
DECLARE	@EmployeeID int
DECLARE @cityCode int
DECLARE @StreetCode varchar(50)

DECLARE @disableBecauseOfOverlapping int


SET @EnableOverlappingHours = (SELECT EnableOverlappingHours FROM DeptEmployeeReceptionRemarks WHERE DeptEmployeeReceptionRemarkID = @DeptEmployeeReceptionRemarkID)

-- If the remark is NOT of "EnableOverlappingHours" sort then there is no problem to delete it
IF (@EnableOverlappingHours = 0)
BEGIN
	DELETE FROM DeptEmployeeReceptionRemarks
	WHERE DeptEmployeeReceptionRemarkID = @DeptEmployeeReceptionRemarkID
	
	RETURN
END
-- If the remark to be removed is the sort of "EnableOverlappingHours"
-- we have to check what will happen with overlapping and, consequently, to permit or not permit the deletion
IF (@EnableOverlappingHours = 1)
BEGIN

	SET @EmployeeReceptionID = (SELECT EmployeeReceptionID FROM DeptEmployeeReceptionRemarks WHERE DeptEmployeeReceptionRemarkID = @DeptEmployeeReceptionRemarkID)

-- If there are more remarks of "EnableOverlappingHours" sort but this one, then it's enough to just delete it
	IF((SELECT COUNT(*) FROM DeptEmployeeReceptionRemarks 
		WHERE EmployeeReceptionID = @EmployeeReceptionID AND DeptEmployeeReceptionRemarkID <> @DeptEmployeeReceptionRemarkID
		AND EnableOverlappingHours = 1 ) > 0)
	BEGIN
		DELETE FROM DeptEmployeeReceptionRemarks
		WHERE DeptEmployeeReceptionRemarkID = @DeptEmployeeReceptionRemarkID
		
		RETURN
	END
	-- Then we try to check if the overlaping situation will occur
	-- and if "yes" then @disableBecauseOfOverlapping = 1
	SET @disableBecauseOfOverlapping =
	
	(SELECT COUNT(*)
	FROM
		(SELECT receptionID, dept.deptCode, EmployeeID, receptionDay, openingHour, closingHour, cityCode, StreetCode, disableBecauseOfOverlapping
		FROM deptEmployeeReception D_ER
		JOIN x_Dept_Employee xDE on D_ER.DeptEmployeeID = xDE.DeptEmployeeID 
		join Dept on xDE.deptCode = Dept.deptCode
		WHERE receptionID = @EmployeeReceptionID) AS DER

	INNER JOIN 
		(SELECT receptionID, dept.deptCode, EmployeeID, receptionDay, openingHour, closingHour, cityCode, StreetCode, disableBecauseOfOverlapping
		FROM deptEmployeeReception D_ER
		JOIN x_Dept_Employee xDE on D_ER.DeptEmployeeID = xDE.DeptEmployeeID 
		join Dept on xDE.deptCode = Dept.deptCode
		WHERE receptionID <> @EmployeeReceptionID) AS DER2
		
		ON DER.EmployeeID = DER2.EmployeeID
		
	WHERE (DER.deptCode = DER2.deptCode 
		OR
		(DER.StreetCode IS NOT NULL AND DER2.StreetCode IS NOT NULL AND (DER.cityCode = DER2.cityCode AND DER.StreetCode = DER2.StreetCode))
		)
	AND DER.receptionDay = DER2.receptionDay
	AND NOT (
		(DER2.openingHour <= dER.openingHour AND DER2.closingHour <= dER.openingHour)
		OR 
		(DER2.openingHour >= dER.closingHour AND DER2.closingHour >= dER.closingHour)
		)
	AND DER2.disableBecauseOfOverlapping = 0
	)	
	+
	(SELECT COUNT(*)
	FROM
		(SELECT receptionID, dept.deptCode, EmployeeID, receptionDay, openingHour, closingHour, cityCode, StreetCode, disableBecauseOfOverlapping
		FROM deptEmployeeReception D_ER
		JOIN x_Dept_Employee xDE on D_ER.DeptEmployeeID = xDE.DeptEmployeeID 
		join Dept on xDE.deptCode = Dept.deptCode
		WHERE receptionID = @EmployeeReceptionID) AS DER

	INNER JOIN 
		(SELECT receptionID, dept.deptCode, EmployeeID, receptionDay, openingHour, closingHour, cityCode, StreetCode, disableBecauseOfOverlapping
		FROM deptEmployeeReception D_ER
		JOIN x_Dept_Employee xDE on D_ER.DeptEmployeeID = xDE.DeptEmployeeID 
		join Dept on xDE.deptCode = Dept.deptCode
		WHERE receptionID <> @EmployeeReceptionID) AS DER2
		
		ON DER.EmployeeID = DER2.EmployeeID
		
	WHERE (DER.deptCode <> DER2.deptCode 
			OR
			(DER.StreetCode IS NOT NULL AND DER2.StreetCode IS NOT NULL AND (DER.cityCode = DER2.cityCode AND DER.StreetCode <> DER2.StreetCode))
		)
	AND DER.receptionDay = DER2.receptionDay
	AND NOT (
		(DER2.openingHour < DER.openingHour AND 
			DATEDIFF(mi, CAST((CASE DER2.closingHour WHEN '24:00' THEN '23:59' ELSE DER2.closingHour END)as smalldatetime), CAST(DER.openingHour as smalldatetime) )>= 30 )
		OR 
		( DATEDIFF(mi, CAST((CASE DER.closingHour WHEN '24:00' THEN '23:59' ELSE DER.closingHour END)as smalldatetime), CAST(DER2.openingHour as smalldatetime) )>= 30 
			AND DER2.closingHour > DER.closingHour)
		)
	AND DER2.disableBecauseOfOverlapping = 0
	)	
	-- If "overlapping"	will take place then we DELETE from "DeptEmployeeReceptionRemarks"
	-- and UDATE "deptEmployeeReception": SET disableBecauseOfOverlapping = 1 
	IF(@disableBecauseOfOverlapping = 1)
		BEGIN
			UPDATE deptEmployeeReception
			SET disableBecauseOfOverlapping = @disableBecauseOfOverlapping
			WHERE receptionID = @EmployeeReceptionID
			
			DELETE FROM DeptEmployeeReceptionRemarks
			WHERE DeptEmployeeReceptionRemarkID = @DeptEmployeeReceptionRemarkID
		END 
	ELSE
		BEGIN
			DELETE FROM DeptEmployeeReceptionRemarks
			WHERE DeptEmployeeReceptionRemarkID = @DeptEmployeeReceptionRemarkID
		END	

	
END


GO


GRANT EXEC ON rpc_deleteDeptEmployeeReceptionRemarks TO PUBLIC
GO
   
--**** Yaniv - End rpc_deleteDeptEmployeeReceptionRemarks ***************************




--**** Yaniv - Start rfn_GetDeptServiceQueueOrderDescriptionsHTML ***************************
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rfn_GetDeptServiceQueueOrderDescriptionsHTML]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rfn_GetDeptServiceQueueOrderDescriptionsHTML]
GO

create  FUNCTION [dbo].[rfn_GetDeptServiceQueueOrderDescriptionsHTML](@deptCode int, @serviceCode int, @employeeID bigint) 
RETURNS varchar(500)

WITH EXECUTE AS CALLER

AS
BEGIN

	declare @Str varchar(500) 
	set @Str = ''
	
	SELECT @Str = @Str + CASE @Str WHEN '' THEN '' ELSE ' | ' END +
		 CASE QueueOrderMethod WHEN 3 THEN '<span dir="ltr">*2700</span>' WHEN 4 THEN '@' ELSE '<span style=' + CHAR(39)+ 'font-family:"Wingdings 2"; font-size:16px' + CHAR(39) + '>' + CHAR(39) + '</span>' END  
	FROM
		-- Using "distinct" because methods "1" & "2" both require "phone picture", but only one picture is needed
		(
		select DISTINCT  CASE  WHEN  DIC_QOM.QueueOrderMethod <= 2 THEN 1 ELSE DIC_QOM.QueueOrderMethod END as 'QueueOrderMethod'
		FROM x_Dept_Employee_Service as xDES
		join x_Dept_Employee xDE on xDES.DeptEmployeeID = xDE.DeptEmployeeID
		join EmployeeServiceQueueOrderMethod ESOM
			on xDES.x_Dept_Employee_ServiceID = ESOM.x_dept_employee_serviceID
		join DIC_QueueOrderMethod DIC_QOM
			on ESOM.QueueOrderMethod = DIC_QOM.QueueOrderMethod
		where xDE.deptCode = @deptCode and xDE.employeeID = @employeeID
			and xDES.serviceCode = @serviceCode
			and xDES.QueueOrder = 3
		) 
		as d 
	order by d.QueueOrderMethod
	
	IF (@Str = '')
	BEGIN
		SELECT @Str = @Str + QueueOrderDescription
		FROM x_Dept_Employee_Service as xDES
		join x_Dept_Employee xDE on xDES.DeptEmployeeID = xDE.DeptEmployeeID
		join DIC_QueueOrder DIC_QO on xDES.QueueOrder = DIC_QO.QueueOrder
		where xDES.QueueOrder <> 3
			and xDES.serviceCode = @serviceCode
			and xDE.deptCode = @deptCode
			and xDE.employeeID = @employeeID
	END
	
	IF (@Str = '')
	BEGIN
		SET @Str = '&nbsp;'
	END
	return (@Str)
end 


GO

grant exec on dbo.rfn_GetDeptServiceQueueOrderDescriptionsHTML to public 
go

--**** Yaniv - End rfn_GetDeptServiceQueueOrderDescriptionsHTML ***************************



--**** Yaniv - Start vServicesAndQueueOrder ***************************
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vServicesAndQueueOrder]'))
DROP VIEW [dbo].[vServicesAndQueueOrder]
GO

CREATE VIEW [dbo].[vServicesAndQueueOrder]
AS
SELECT  xDE.deptCode, xDES.serviceCode, dbo.[Services].ServiceDescription,
	 dbo.rfn_GetDeptServiceQueueOrderDescriptionsHTML(xDE.deptCode,
	  xDES.serviceCode, xDE.employeeID) AS QueueOrder,
	  Employee.IsMedicalTeam
FROM x_Dept_Employee_Service AS xDES 
join x_Dept_Employee xDE on xDES.DeptEmployeeID = xDE.DeptEmployeeID
JOIN [Services] ON xDES.serviceCode = dbo.[Services].ServiceCode
join Employee on Employee.employeeID = xDE.employeeID
GO

grant select on vServicesAndQueueOrder to public 
go


--**** Yaniv - End vServicesAndQueueOrder ***************************

-- *****************************************************************************************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertMushlamToSeferServiceMapping')
    BEGIN
	    DROP  Procedure  rpc_insertMushlamToSeferServiceMapping
    END

GO

CREATE Procedure dbo.rpc_insertMushlamToSeferServiceMapping
(
	@tableCode INT, 
	@mushlamServiceCode INT, 
	@parentCode INT, 
	@seferServiceCode INT,
	@updateUser VARCHAR(50)
)

AS

IF @parentCode IS NULL
	INSERT INTO MushlamSpecialityToSefer
	(MushlamTableCode, MushlamServiceCode, SeferServiceCode, UpdateUser, UpdateDate)
	VALUES (@tableCode, @mushlamServiceCode, @seferServiceCode, @updateUser, GETDATE())
ELSE
	INSERT INTO MushlamSubSpecialityToSefer
	(MushlamTableCode, MushlamServiceCode, ParentCode, SeferServiceCode, UpdateUser, UpdateDate)
	VALUES (@tableCode, @mushlamServiceCode, @parentCode, @seferServiceCode, @updateUser, GETDATE())


                
GO


GRANT EXEC ON rpc_insertMushlamToSeferServiceMapping TO PUBLIC

GO            


-- *****************************************************************************************************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateMushlamToSeferMapping')
    BEGIN
	    DROP  Procedure  rpc_updateMushlamToSeferMapping
    END

GO

CREATE Procedure dbo.rpc_updateMushlamToSeferMapping
(
	 @mappingID INT, 
	 @newMushlamTableCode INT, 
	 @newMushlamServiceCode INT, 
	 @newParentCode INT, 
	 @newSeferServiceCode INT
)

AS

IF @newParentCode IS NULL
	UPDATE  MushlamSpecialityToSefer
	SET MushlamTableCode = @newMushlamTableCode, 
		MushlamServiceCode = @newMushlamServiceCode, 		
		SeferServiceCode = @newSeferServiceCode
	WHERE ID = @mappingID
ELSE
	UPDATE MushlamSubSpecialityToSefer
	SET MushlamTableCode = @newMushlamTableCode, 
		MushlamServiceCode = @newMushlamServiceCode, 
		ParentCode = @newParentCode,
		SeferServiceCode = @newSeferServiceCode
	WHERE ID = @mappingID

                
GO


GRANT EXEC ON rpc_updateMushlamToSeferMapping TO PUBLIC

GO            

-- *****************************************************************************************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteMushlamToSeferMapping')
    BEGIN
	    DROP  Procedure  rpc_deleteMushlamToSeferMapping
    END

GO

CREATE Procedure dbo.rpc_deleteMushlamToSeferMapping
(
	@mushlamTableCode INT,
	@mushlamServiceCode INT,
	@seferServiceCode INT
)

AS


DELETE MushlamSpecialityToSefer
WHERE MushlamTableCode = @mushlamTableCode
AND MushlamServiceCode = @mushlamServiceCode
AND SeferServiceCode = @seferServiceCode


DELETE MushlamSubSpecialityToSefer
WHERE MushlamTableCode = @mushlamTableCode
AND MushlamServiceCode = @mushlamServiceCode
AND SeferServiceCode = @seferServiceCode

                
GO


GRANT EXEC ON rpc_deleteMushlamToSeferMapping TO PUBLIC

GO            

-- *****************************************************************************************************************
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'fun_GetEmployeeServiceQueueOrderPhones')
	BEGIN
		DROP  FUNCTION  fun_GetEmployeeServiceQueueOrderPhones
	END
GO

CREATE FUNCTION [dbo].[fun_GetEmployeeServiceQueueOrderPhones] (@DeptEmployeeID int, @ServiceCode int)
RETURNS VARCHAR(100)
WITH EXECUTE AS CALLER
AS
BEGIN

	DECLARE @phones VARCHAR(100)
	DECLARE @phones1 VARCHAR(100)	
	DECLARE @phones2 VARCHAR(100)
	DECLARE @phones3 VARCHAR(100)		
	SET @phones = ''
	SET @phones1 = ''
	SET @phones2 = ''
	SET @phones3 = ''
			
	-- employee service queue order phone
	SELECT @phones = CASE WHEN esqop.PhoneType IS NOT NULL THEN 
								dbo.fun_ParsePhoneNumberWithExtension(esqop.PrePrefix, esqop.Prefix, esqop.Phone, esqop.Extension)				  
						  ELSE 
								dbo.fun_ParsePhoneNumberWithExtension(dp.PrePrefix, dp.Prefix, dp.Phone, dp.Extension)				  
					 END
	FROM x_dept_employee_service xdes
	LEFT JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
	LEFT JOIN EmployeeServiceQueueOrderMethod esqom ON xdes.x_dept_employee_ServiceID = esqom.x_dept_employee_ServiceID
	LEFT JOIN EmployeeServiceQueueOrderPhones esqop ON esqom.EmployeeServiceQueueOrderMethodID = esqop.EmployeeServiceQueueOrderMethodID
	LEFT JOIN dic_queueOrderMethod dic ON esqom.QueueOrderMethod = dic.QueueOrderMethod
	LEFT JOIN DeptPhones dp ON xd.DeptCode = dp.DeptCode
	WHERE xdes.DeptEmployeeID = @DeptEmployeeID
	AND xdes.serviceCode = @ServiceCode
	AND dic.ShowPhonePicture = 1 AND SpecialPhoneNumberRequired = 1
	AND dp.PhoneType = 1 
	AND dp.PhoneOrder = 1

	SELECT @phones1 = CASE WHEN dp.PhoneType IS NOT NULL THEN	
								dbo.fun_ParsePhoneNumberWithExtension(dp.PrePrefix, dp.Prefix, dp.Phone, dp.Extension)
								ELSE ''
						END
	FROM x_dept_employee_service xdes
	INNER JOIN x_dept_employee xd on xdes.DeptEmployeeID = xd.DeptEmployeeID
	INNER JOIN EmployeeQueueOrderMethod eqom ON xdes.DeptEmployeeID = eqom.DeptEmployeeID
	INNER JOIN dic_queueOrderMethod dic ON eqom.QueueOrderMethod = dic.QueueOrderMethod
	INNER JOIN DeptPhones dp ON xd.DeptCode = dp.DeptCode
	WHERE xdes.DeptEmployeeID = @DeptEmployeeID
	AND xdes.serviceCode = @ServiceCode
	AND dic.ShowPhonePicture = 1 AND SpecialPhoneNumberRequired = 0
	AND dp.PhoneType = 1 
	AND dp.PhoneOrder = 1

	SELECT @phones2 = dbo.fun_ParsePhoneNumberWithExtension(PrePrefix, Prefix, Phone, Extension)

	FROM x_Dept_Employee_Service x_DES
	JOIN x_Dept_Employee x_DE ON x_DES.DeptEmployeeID = x_DE.DeptEmployeeID
	JOIN EmployeeServiceQueueOrderMethod ESQOM ON x_DES.x_Dept_Employee_ServiceID = ESQOM.x_dept_employee_serviceID 
	JOIN DeptPhones ON x_DE.deptCode = DeptPhones.deptCode

	WHERE x_DES.serviceCode = @ServiceCode
	AND x_DES.DeptEmployeeID = @DeptEmployeeID
	AND ESQOM.QueueOrderMethod = 1 -- טלפון במרפאה
	AND DeptPhones.phoneType = 1
	AND DeptPhones.phoneOrder = 1

	IF (@phones <> '' AND @phones1 <> '')
		SET @phones	= @phones + '<br>' + @phones1
	ELSE 
		SET @phones = @phones + @phones1

	-- dept employee queue order phone



	IF (@phones <> '' AND @phones2 <> '')
		SET @phones	= @phones + '<br>' + @phones2
	ELSE 
		SET @phones = @phones + @phones2

	
RETURN @phones	


END

GO

grant exec on fun_GetEmployeeServiceQueueOrderPhones to public 
go 
       

-- *****************************************************************************************************************

--**** Yaniv - Start rpc_getClinicByName_DistrictDepended *********************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getClinicByName_DistrictDepended')
	BEGIN
		DROP  Procedure  rpc_getClinicByName_DistrictDepended
	END

GO

CREATE Procedure dbo.rpc_getClinicByName_DistrictDepended
	(
	@SearchString varchar(50),
	@DistrictCodes varchar(50),
	@status tinyint,
	@isCommunity bit,
	@isMushlam bit,
	@isHospital bit
	)

AS
IF(@DistrictCodes = '')
	BEGIN SET @DistrictCodes = null END
	
SELECT deptCode, ClinicName FROM
(	
Select deptCode, rtrim(ltrim(deptName)) as ClinicName, showOrder = 0
FROM dept
WHERE deptName like @SearchString + '%'
AND (@DistrictCodes is null
	OR
	districtCode in (SELECT IntField FROM dbo.SplitString(@DistrictCodes)))
AND status >= @status
and(@isCommunity = 1 and dept.IsCommunity = 1
			or @isMushlam = 1 and  dept.isMushlam = 1
			or @isHospital = 1 and dept.isHospital = 1)

UNION

Select deptCode, rtrim(ltrim(deptName)) as ClinicName, showOrder = 1
FROM dept
WHERE (deptName like '%'+ @SearchString + '%' AND deptName NOT like @SearchString + '%')
AND (@DistrictCodes is null
	OR
	districtCode in (SELECT IntField FROM dbo.SplitString(@DistrictCodes)))
AND status >= @status
and(@isCommunity = 1 and dept.IsCommunity = 1
			or @isMushlam = 1 and  dept.isMushlam = 1
			or @isHospital = 1 and dept.isHospital = 1)
) as T1
ORDER BY showOrder, ClinicName

GO

GRANT EXEC ON dbo.rpc_getClinicByName_DistrictDepended TO PUBLIC

GO

--**** Yaniv - End rpc_getClinicByName_DistrictDepended *********************

--**** Yaniv - Start rpc_getUnitTypesByName **************************

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_getUnitTypesByName]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[rpc_getUnitTypesByName]
GO



/* The procedure check if the unit type has subUnitTypes, if yes it returns 
   the unit types according to the subUnitType aggrement types(isCommunity,isMushlam,isHospital).
   If the unit type has no subUnitTypes, it returns the unit types according to
   the DefaultSubUnitTypeCode aggrement types.
 */
CREATE Procedure [dbo].[rpc_getUnitTypesByName]
	(
		@SearchString varchar(50),
		@isCommunity bit,
		@isMushlam bit,
		@isHospital bit
	)

AS

SELECT UnitTypeCode, UnitTypeName FROM
(
	SELECT
	UnitTypeCode, UnitTypeName, showOrder = 0
	FROM UnitType
	WHERE UnitTypeName like @SearchString + '%'
	AND IsActive = 1
	and
	(
		UnitTypeCode in
		(
			select UT.UnitTypeCode from UnitType UT
			join subUnitType SUT on UT.UnitTypeCode = SUT.UnitTypeCode
			join DIC_SubUnitTypes dSUT on SUT.subUnitTypeCode = dSUT.subUnitTypeCode
			where UT.UnitTypeName like @SearchString + '%'
			and(@isCommunity = 1 and dSUT.IsCommunity = 1
				or @isMushlam = 1 and  dSUT.isMushlam = 1
				or @isHospital = 1 and dSUT.IsHospitals = 1)
			
		)
		or
		(	-- Looking for the DefaultSubUnitTypeCode
			UnitTypeCode in
			(
				select UT.UnitTypeCode from UnitType UT
				join DIC_SubUnitTypes dSUT on UT.DefaultSubUnitTypeCode = dSUT.subUnitTypeCode
				where UT.UnitTypeName like @SearchString + '%'
				and(@isCommunity = 1 and dSUT.IsCommunity = 1
					or @isMushlam = 1 and  dSUT.isMushlam = 1
					or @isHospital = 1 and dSUT.IsHospitals = 1)
			)
		)
	)
				
	UNION
	
	SELECT
	UnitTypeCode, UnitTypeName, showOrder = 1
	FROM UnitType
	WHERE (UnitTypeName like '%' + @SearchString + '%' AND UnitTypeName NOT like @SearchString + '%')
	AND IsActive = 1
	and
	(
		UnitTypeCode in
		(
			select UT.UnitTypeCode from UnitType UT
			join subUnitType SUT on UT.UnitTypeCode = SUT.UnitTypeCode
			join DIC_SubUnitTypes dSUT on SUT.subUnitTypeCode = dSUT.subUnitTypeCode
			where UT.UnitTypeName like '%' + @SearchString + '%'
			and(@isCommunity = 1 and dSUT.IsCommunity = 1
				or @isMushlam = 1 and  dSUT.isMushlam = 1
				or @isHospital = 1 and dSUT.IsHospitals = 1)
		)
		or
		(
			UnitTypeCode in
			(
				select UT.UnitTypeCode from UnitType UT
				join DIC_SubUnitTypes dSUT on UT.DefaultSubUnitTypeCode = dSUT.subUnitTypeCode
				where UT.UnitTypeName like '%' + @SearchString + '%'
				and(@isCommunity = 1 and dSUT.IsCommunity = 1
					or @isMushlam = 1 and  dSUT.isMushlam = 1
					or @isHospital = 1 and dSUT.IsHospitals = 1)
			)
		)
	)
	
) as T1

ORDER BY showOrder, UnitTypeName

GRANT EXEC ON rpc_getUnitTypesByName TO PUBLIC


GO

--**** Yaniv - End rpc_getUnitTypesByName **************************

--**** Yaniv - Start rpc_getUnitTypesExtended **********************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getUnitTypesExtended')
	BEGIN
		DROP  Procedure  rpc_getUnitTypesExtended
	END

GO

/* The procedure check if the unit type has subUnitTypes, if yes it returns 
   the unit types according to the subUnitType aggrement types(isCommunity,isMushlam,isHospital).
   If the unit type has no subUnitTypes, it returns the unit types according to
   the DefaultSubUnitTypeCode aggrement types.
 */

CREATE Procedure dbo.rpc_getUnitTypesExtended
	(
		@SelectedUnitTypeCodes varchar(100),
		@isCommunity bit,
		@isMushlam bit,
		@isHospital bit
	)

AS

SELECT
UnitTypeCode,
UnitTypeName,
'selected' = CASE IsNull(sel.IntField, 0) WHEN 0 THEN 0 ELSE 1 END
FROM UnitType
LEFT JOIN (SELECT IntField FROM dbo.SplitString(@SelectedUnitTypeCodes)) as sel ON UnitType.UnitTypeCode = sel.IntField
WHERE IsActive = 1
and
	(
		UnitTypeCode in
		(
			select UT.UnitTypeCode from UnitType UT
			join subUnitType SUT on UT.UnitTypeCode = SUT.UnitTypeCode
			join DIC_SubUnitTypes dSUT on SUT.subUnitTypeCode = dSUT.subUnitTypeCode
			where
			(@isCommunity = 1 and dSUT.IsCommunity = 1
				or @isMushlam = 1 and  dSUT.isMushlam = 1
				or @isHospital = 1 and dSUT.IsHospitals = 1)
			
		)
		or
		(	-- Looking for the DefaultSubUnitTypeCode
			UnitTypeCode in
			(
				select UT.UnitTypeCode from UnitType UT
				join DIC_SubUnitTypes dSUT on UT.DefaultSubUnitTypeCode = dSUT.subUnitTypeCode
				where
				(@isCommunity = 1 and dSUT.IsCommunity = 1
					or @isMushlam = 1 and  dSUT.isMushlam = 1
					or @isHospital = 1 and dSUT.IsHospitals = 1)
			)
		)
	)
ORDER BY UnitTypeName

GO

GRANT EXEC ON rpc_getUnitTypesExtended TO PUBLIC

GO


--**** Yaniv - End rpc_getUnitTypesExtended **********************

--**** Yaniv - Start rpc_getServicesByNameAndSector ***************
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getServicesByNameAndSector')
	BEGIN
		DROP  Procedure  rpc_getServicesByNameAndSector
	END

GO

CREATE Procedure dbo.rpc_getServicesByNameAndSector
	(
		@SearchString varchar(50)
		,@sectorCode INT
		,@IsInCommunity bit
		,@IsInMushlam bit
		,@IsInHospitals bit
	)

AS

	SELECT serviceCode, serviceDescription FROM
	(
		SELECT s.serviceCode, rtrim(ltrim(s.serviceDescription)) as serviceDescription, showOrder = 0
		FROM [Services] as s
		left join x_Services_EmployeeSector as Se_EmSec
			on s.ServiceCode = Se_EmSec.ServiceCode
		WHERE 
			(	@sectorCode = -1
			or (Se_EmSec.EmployeeSectorCode is null 
				or Se_EmSec.EmployeeSectorCode = @sectorCode)
			)
			and(@IsInCommunity = 1 and s.IsInCommunity = 1
				or @IsInMushlam = 1 and  s.IsInMushlam = 1
				or @IsInHospitals = 1 and s.IsInHospitals = 1)
			
			and s.serviceDescription like @SearchString + '%'

		UNION

		SELECT s.serviceCode, rtrim(ltrim(s.serviceDescription)) as serviceDescription, showOrder = 0
		FROM ServiceSynonym syn 
		INNER JOIN [Services] as s ON syn.serviceCode = s.ServiceCode
		LEFT JOIN x_Services_EmployeeSector as Se_EmSec ON s.ServiceCode = Se_EmSec.ServiceCode
		WHERE 
			(	@sectorCode = -1
			or (Se_EmSec.EmployeeSectorCode is null 
				or Se_EmSec.EmployeeSectorCode = @sectorCode)
			)
			and(@IsInCommunity = 1 and s.IsInCommunity = 1
				or @IsInMushlam = 1 and  s.IsInMushlam = 1
				or @IsInHospitals = 1 and s.IsInHospitals = 1)
			
			and syn.ServiceSynonym like @SearchString + '%'

		UNION
		
		SELECT s.serviceCode, rtrim(ltrim(s.serviceDescription)) as serviceDescription, showOrder = 1
		FROM [Services] as s
		left join x_Services_EmployeeSector as Se_EmSec
			on s.ServiceCode = Se_EmSec.ServiceCode
		WHERE
			 (	@sectorCode = -1
			or (Se_EmSec.EmployeeSectorCode is null 
				or Se_EmSec.EmployeeSectorCode = @sectorCode)
			)
			and(@IsInCommunity = 1 and s.IsInCommunity = 1
				or @IsInMushlam = 1 and  s.IsInMushlam = 1
				or @IsInHospitals = 1 and s.IsInHospitals = 1)
			
			AND (s.serviceDescription like '%' + @SearchString + '%' 
			AND serviceDescription NOT like @SearchString + '%')

		UNION

		SELECT s.serviceCode, rtrim(ltrim(s.serviceDescription)) as serviceDescription, showOrder = 1
		FROM ServiceSynonym syn 
		INNER JOIN [Services] as s ON syn.serviceCode = s.ServiceCode
		LEFT JOIN x_Services_EmployeeSector as Se_EmSec ON s.ServiceCode = Se_EmSec.ServiceCode
		WHERE 
			(	@sectorCode = -1
			or (Se_EmSec.EmployeeSectorCode is null 
				or Se_EmSec.EmployeeSectorCode = @sectorCode)
			)
			and(@IsInCommunity = 1 and s.IsInCommunity = 1
				or @IsInMushlam = 1 and  s.IsInMushlam = 1
				or @IsInHospitals = 1 and s.IsInHospitals = 1)
			
			AND syn.ServiceSynonym like '%' + @SearchString + '%'
			AND syn.ServiceSynonym NOT like @SearchString + '%'

	) as T1
	ORDER BY showOrder, ServiceDescription
GO

GRANT EXEC ON rpc_getServicesByNameAndSector TO PUBLIC

GO


--**** Yaniv - End rpc_getServicesByNameAndSector ***************


--**** Yaniv - Start rpc_getServicesAndEventsByName ***************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getServicesAndEventsByName')
	BEGIN
		DROP  Procedure  rpc_getServicesAndEventsByName
	END

GO
 
CREATE Procedure dbo.rpc_getServicesAndEventsByName
	(
	@SearchString varchar(50),
	@IsInCommunity bit,
	@IsInMushlam bit, 
	@IsInHospitals bit
	)

AS
SELECT code, description FROM
(
	SELECT code, description, showOrder FROM
	(
		SELECT serviceCode as code, rtrim(ltrim(serviceDescription)) as description, showOrder = 0
		FROM [Services] as s
		WHERE 
			(@IsInCommunity = 1 and s.IsInCommunity = 1
				or @IsInMushlam = 1 and  s.IsInMushlam = 1
				or @IsInHospitals = 1 and s.IsInHospitals = 1)
			AND serviceDescription like @SearchString + '%'

		UNION

		SELECT EventCode as code, rtrim(ltrim(EventName)) as description, showOrder = 0
		FROM DIC_Events
		WHERE 
			IsActive = 1
			
			and EventName like @SearchString + '%'

		UNION 

		SELECT s.serviceCode as code, rtrim(ltrim(s.serviceDescription)) as description, showOrder = 0
		FROM ServiceSynonym as syn
		INNER JOIN [services] s ON syn.serviceCode = s.ServiceCode
		WHERE 
			(@IsInCommunity = 1 and s.IsInCommunity = 1
				or @IsInMushlam = 1 and  s.IsInMushlam = 1
				or @IsInHospitals = 1 and s.IsInHospitals = 1)
			AND ServiceSynonym like @SearchString + '%'
		
	) as T1
	
	UNION

	SELECT code, description, showOrder FROM
	(
		SELECT serviceCode as code, rtrim(ltrim(serviceDescription)) as description, showOrder = 1
		FROM [Services] as s
		WHERE 
			(@IsInCommunity = 1 and s.IsInCommunity = 1
				or @IsInMushlam = 1 and  s.IsInMushlam = 1
				or @IsInHospitals = 1 and s.IsInHospitals = 1)
			and (serviceDescription like '%' + @SearchString + '%' AND serviceDescription NOT like @SearchString + '%')

		UNION

		SELECT EventCode as code, rtrim(ltrim(EventName)) as description, showOrder = 1
		FROM DIC_Events
		WHERE 
			IsActive = 1
			AND(EventName like '%' + @SearchString + '%' AND EventName NOT like @SearchString + '%')

		UNION

		SELECT s.serviceCode as code, rtrim(ltrim(s.serviceDescription)) as description, showOrder = 0
		FROM ServiceSynonym as syn
		INNER JOIN [services] s ON syn.serviceCode = s.ServiceCode
		WHERE 
			(@IsInCommunity = 1 and s.IsInCommunity = 1
				or @IsInMushlam = 1 and  s.IsInMushlam = 1
				or @IsInHospitals = 1 and s.IsInHospitals = 1)
			AND ServiceSynonym like '%' + @SearchString + '%' 
			AND ServiceSynonym NOT like @SearchString + '%'
		 
	) as T2
) as T3
ORDER BY showOrder, description

GO

GRANT EXEC ON rpc_getServicesAndEventsByName TO PUBLIC

GO


--**** Yaniv - End rpc_getServicesAndEventsByName ***************



--*************************************************************************************************************************************

--*** Yaniv - Start rpc_GetMushlamForms ***************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetMushlamForms')
	BEGIN
		DROP  Procedure  rpc_GetMushlamForms
	END
GO
CREATE PROCEDURE [dbo].[rpc_GetMushlamForms]
	
AS
	select * from MushlamForms

GO

GRANT EXEC ON rpc_GetMushlamForms TO PUBLIC
GO


--*** Yaniv - End rpc_GetMushlamForms ***************************

--**** Yaniv - Start rpc_GetMushlamBrochures ****************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetMushlamBrochures')
	BEGIN
		DROP  Procedure  rpc_GetMushlamBrochures
	END

GO

CREATE Procedure dbo.rpc_GetMushlamBrochures
	
AS
	select DisplayName,FileName,displayDescription
	,'tbl' = case ROW_NUMBER() over(order by brochureID)%2 
				when 1 then '1'
				else '2' end
	from MushlamBrochures
	join languages on MushlamBrochures.languageCode = languages.languageCode

GO

GRANT EXEC ON rpc_GetMushlamBrochures TO PUBLIC

GO
--**** Yaniv - End rpc_GetMushlamBrochures ****************************

-- ************************************************************************************************
--**** Yaniv - End rpc_GetMushlamBrochures ****************************


--**** Yaniv - Start deleting View_Services **************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_Services')
BEGIN
	DROP  view  View_Services
END
--**** Yaniv - Start deleting View_Services **************************

/****** Object:  StoredProcedure [dbo].[Helper_LongPrint]    Script Date: 03/28/2012 14:54:37 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Helper_LongPrint]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Helper_LongPrint]
GO

CREATE PROCEDURE [dbo].[Helper_LongPrint]( @string nvarchar(max) )
AS
SET NOCOUNT ON
set @string = rtrim( @string )
declare @cr char(1), @lf char(1)
set @cr = char(13)
set @lf = char(10)

declare @len int, @cr_index int, @lf_index int, @crlf_index int, @has_cr_and_lf bit, @left nvarchar(4000), @reverse nvarchar(4000)

set @len = 4000

while ( len( @string ) > @len )
begin

set @left = left( @string, @len )
set @reverse = reverse( @left )
set @cr_index = @len - charindex( @cr, @reverse ) + 1
set @lf_index = @len - charindex( @lf, @reverse ) + 1
set @crlf_index = case when @cr_index < @lf_index then @cr_index else @lf_index end

set @has_cr_and_lf = case when @cr_index < @len and @lf_index < @len then 1 else 0 end

print left( @string, @crlf_index - 1 )

set @string = right( @string, len( @string ) - @crlf_index - @has_cr_and_lf )

end

print @string
GO

--------------------------------------------------------------------------

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptEventsAndServicesList_Paged')
	BEGIN
		DROP  Procedure  rpc_getDeptEventsAndServicesList_Paged
		PRINT 'DROP  Procedure  rpc_getDeptEventsAndServicesList_Paged'
	END

GO
---------------------------------------------------------------------------

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptServiceForUpdate')
	BEGIN
		drop procedure rpc_getDeptServiceForUpdate
	END

GO
-----------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[View_DeptEmployeeReceptionCount]'))
DROP VIEW [dbo].[View_DeptEmployeeReceptionCount]
GO

create VIEW [dbo].[View_DeptEmployeeReceptionCount]
AS
select COUNT(*) as ReceptionCount, deptEmployeeReception.DeptEmployeeID, deptEmployeeReceptionServices.serviceCode
		FROM deptEmployeeReception
		INNER JOIN deptEmployeeReceptionServices 
			ON deptEmployeeReception.receptionID = deptEmployeeReceptionServices.receptionID
		where disableBecauseOfOverlapping <> 1
		and (GETDATE() between ISNULL(validFrom,'1900-01-01') and ISNULL(validTo,'2079-01-01'))
group by deptEmployeeReception.DeptEmployeeID, deptEmployeeReceptionServices.serviceCode

go


GRANT SELECT ON [dbo].[View_DeptEmployeeReceptionCount] TO [public] AS [dbo]
GO

-----------------------------------------------------------------------------

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_getDeptServicePhones')
	BEGIN
		DROP  FUNCTION  fun_getDeptServicePhones
	END
GO
-----------------------------------------------------------------------------


-- **********************************************************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptList_PagedSorted')
	BEGIN
		DROP  Procedure  rpc_getDeptList_PagedSorted
	END

GO

CREATE Procedure [dbo].[rpc_getDeptList_PagedSorted]
	(
	@DistrictCodes varchar(max)=null,
	@CityCode int=null,
	@typeUnitCode varchar(max)=null,
	@subUnitTypeCode varchar(max) = null,
	@ServiceCodes varchar(max) = null,
	@DeptName varchar(max)=null,
	@DeptCode int=null,
	@ReceptionDays varchar(max)=null,
	@OpenAtHour varchar(5)=null,
	@OpenFromHour varchar(5)=null,
	@OpenToHour varchar(5)=null,
	@isCommunity bit,
	@isMushlam bit,
	@isHospital bit,
	@status int = null,
	@populationSectorCode int = null,
	@deptHandicappedFacilities varchar(max),
	
	@PageSise int,
	@StartingPage int,
	@SortedBy varchar(max),
	@IsOrderDescending int,
	
	@CoordinateX float=null,
	@CoordinateY float=null,
	@MaxNumberOfRecords int=null
	)

with recompile

AS

DECLARE @params nvarchar(max)
DECLARE @Declarations nvarchar(max)
DECLARE @Sql1 nvarchar(max)
DECLARE @Sql2 nvarchar(max)
DECLARE @SqlEnd nvarchar(max)

DECLARE @SqlWhere1 nvarchar(max)
DECLARE @SqlWhere2 nvarchar(max)

declare @OrganizationSectorIDList varchar(5) = ''
set @OrganizationSectorIDList = case when @isCommunity is null then '0' else '1' end
set @OrganizationSectorIDList = @OrganizationSectorIDList + ',' + case when @isMushlam is null then '0' else '2' end
set @OrganizationSectorIDList = @OrganizationSectorIDList + ',' + case when @isHospital is null then '0' else '3' end

DECLARE @AgreementTypeList [tbl_UniqueIntArray]   
INSERT INTO @AgreementTypeList
select AgreementTypeID from DIC_AgreementTypes
where OrganizationSectorID in (Select IntField from dbo.SplitString(@OrganizationSectorIDList))

DECLARE @ServiceCodesList [tbl_UniqueIntArray]   
IF @ServiceCodes is NOT null
	INSERT INTO @ServiceCodesList SELECT DISTINCT * FROM dbo.SplitStringNoOrder(@ServiceCodes) 

DECLARE @ReceptionDaysList [tbl_UniqueIntArray] 
IF @ReceptionDays is NOT null
	INSERT INTO @ReceptionDaysList SELECT DISTINCT * FROM dbo.SplitStringNoOrder(@ReceptionDays) 

SET @Declarations =
'	
	SET @xStartingPage = @xStartingPage - 1

	DECLARE @xStartingPosition int
	SET @xStartingPosition = (@xStartingPage * @xPageSise)
	
	DECLARE @xHandicappedFacilitiesCount int
	SET @xHandicappedFacilitiesCount = IsNull((SELECT COUNT(IntField) FROM dbo.SplitString(@xDeptHandicappedFacilities)), 0)
	
	DECLARE @xOpenAtHour_real real
	DECLARE @xOpenFromHour_real real
	DECLARE @xOpenToHour_real real
	IF @xOpenFromHour IS NOT NULL
		SET @xOpenFromHour_real = CAST (LEFT(@xOpenFromHour,2) as real) + CAST (RIGHT(@xOpenFromHour,2) as real)/60
		
	IF @xOpenToHour IS NOT NULL
		SET @xOpenToHour_real = CAST (LEFT(@xOpenToHour,2) as real) + CAST (RIGHT(@xOpenToHour,2) as real)/60 

	IF (@xOpenAtHour is not null)
		SET @xOpenAtHour_real = CAST (LEFT(@xOpenAtHour,2) as real) + CAST (RIGHT(@xOpenAtHour,2) as real)/60 
		
	DECLARE @xCount int	
	
	DECLARE @xSortedByDefault varchar(50)
	SET @xSortedByDefault = '+CHAR(39)+'deptLevel'+CHAR(39) +	
	
	'IF(@xSortedBy = '+CHAR(39) +CHAR(39) +' OR @xSortedBy IS NULL)
		SET @xSortedBy = @xSortedByDefault 		

	IF (@xCoordinateX = -1)
	BEGIN
		SET @xCoordinateX = null
		SET @xCoordinateY = null
	END
	
	IF(@xMaxNumberOfRecords <> -1)
		BEGIN
		IF(@xMaxNumberOfRecords < @xPageSise)
			BEGIN
				SET @xPageSise = @xMaxNumberOfRecords
			END
		END	
	'
	
SET @params = 
'	@xDistrictCodes varchar(max)=null,
	@xCityCode int=null,
	@xtypeUnitCode varchar(max)=null,
	@xsubUnitTypeCode varchar(max) = null,
	@xServiceCodes varchar(max) = null,
	@xServiceCodesList [tbl_UniqueIntArray] READONLY,
	@xDeptName varchar(max)=null,
	@xDeptCode int=null,
	@xReceptionDaysList [tbl_UniqueIntArray] READONLY,
	@xOpenAtHour varchar(5)=null,
	@xOpenFromHour varchar(5)=null,
	@xOpenToHour varchar(5)=null,
	@xIsCommunity bit,
	@xIsMushlam bit,
	@xIsHospital bit,
	@xStatus int = null,
	@xPopulationSectorCode int = null,
	@xDeptHandicappedFacilities varchar(max),
	@xAgreementTypeList [tbl_UniqueIntArray] READONLY,
	
	@xPageSise int,
	@xStartingPage int,
	@xSortedBy varchar(max),
	@xIsOrderDescending int,
	
	@xCoordinateX float=null,
	@xCoordinateY float=null,
	@xMaxNumberOfRecords int=null
'

SET @Sql1 = 
' declare @codesCopy VARCHAR(1000)
  SET @codesCopy = ' + char(39) + '658' + char(39) + '
	
SELECT * INTO #tempTableAllRows FROM '

-- middle selection - "dept itself" + RowNumber
SET @Sql1 = @Sql1 +
'(SELECT *, ' +
	CHAR(39)+ 'RowNumber' +CHAR(39)+ '= CASE @xSortedBy ' +  
			'WHEN ' +CHAR(39)+ 'deptName' +CHAR(39)+  ' THEN ' +
				'CASE @xIsOrderDescending ' + 
				'WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY deptName DESC ) ' +
				'WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY deptName ) ' +
				'END ' +
			'WHEN ' +CHAR(39)+ 'cityName' +CHAR(39)+ ' THEN ' +
				'CASE @xIsOrderDescending ' + 
				'WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY cityName DESC ) ' +
				'WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY cityName )' +
				'END ' +
			'WHEN ' +CHAR(39)+ 'phone' +CHAR(39)+  ' THEN ' +
				'CASE @xIsOrderDescending ' +
				'WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY phone DESC ) ' +
				'WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY phone ) ' +
				'END ' +
			'WHEN ' +CHAR(39)+ 'address' +CHAR(39)+ ' THEN ' +
				'CASE @xIsOrderDescending ' +
				'WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY address DESC ) ' +
				'WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY address ) ' +
				'END ' +
			'WHEN ' +CHAR(39)+ 'doctorName' +CHAR(39)+ ' THEN ' +
				'CASE @xIsOrderDescending ' + 
				'WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY doctorName DESC ) ' +
				'WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY doctorName ) ' +
				'END ' +
			'WHEN ' +CHAR(39)+ 'ServiceDescription' +CHAR(39)+ ' THEN 
				CASE @xIsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY ServiceDescription DESC ) 
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY ServiceDescription ) 
				END ' +
			'WHEN ' +CHAR(39)+ 'subUnitTypeCode' +CHAR(39)+ ' THEN 
				CASE @xIsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY IsCommunity ASC, IsMushlam DESC, IsHospital DESC, subUnitTypeCode DESC) 
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY IsCommunity DESC, IsMushlam ASC, IsHospital ASC, subUnitTypeCode ASC) 
				END ' +
			'WHEN ' +CHAR(39)+ 'distance' +CHAR(39)+ ' THEN 
				CASE @xIsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY distance DESC ) 
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY distance, deptCode ) 
				END '+ 
			'ELSE 
				CASE @xIsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY deptLevel, IsNull(DisplayPriority,99) , orderDeptNameLike, deptName DESC ) 
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY deptLevel, IsNull(DisplayPriority,99), orderDeptNameLike, deptName ) 
				END ' +
			'END '
SET @Sql1 = @Sql1 +				
' FROM ' +
-- inner selection - "dept itself"
'(
SELECT distinct
dept.deptCode,
dept.deptName,
dept.deptType,
dept.deptLevel,
dept.displayPriority,
dept.ShowUnitInInternet,
DIC_DeptTypes.deptTypeDescription,
dept.typeUnitCode, 
	CASE IsNull(dept.subUnitTypeCode, -1) 
					WHEN -1 THEN UnitType.DefaultSubUnitTypeCode
					ELSE dept.subUnitTypeCode END
as 	subUnitTypeCode,
SubUnitTypeSubstituteName.SubstituteName,
dept.IsCommunity,
dept.IsMushlam,
dept.IsHospital,
UnitType.UnitTypeName,
dept.cityCode,
Cities.cityName,
dept.streetName as street,
dept.house,
dept.flat,
dept.addressComment, 
dbo.GetAddress(dept.deptCode) as address,
dbo.GetDeptPhoneNumber(dept.deptCode, 1, 1) as phone,
	(SELECT COUNT(*) 
	from View_DeptRemarks
	WHERE deptCode = dept.deptCode
	AND (GETDATE() between ISNULL(ValidFrom,' +CHAR(39)+ '1900-01-01' +CHAR(39)+ ') and ISNULL(ValidTo,' +CHAR(39)+ '2079-01-01' +CHAR(39)+ '))
	AND (IsSharedRemark = 0 OR dept.IsCommunity = 1) 
	)
as countDeptRemarks,
	(select count(receptionID) 
	from DeptReception
	where deptCode = dept.deptCode
	AND (GETDATE() between ISNULL(ValidFrom,' +CHAR(39)+ '1900-01-01' +CHAR(39)+ ') and ISNULL(ValidTo,' +CHAR(39)+ '2079-01-01' +CHAR(39)+ '))
	)
as 	countReception,
Simul228,
	(xcoord - @xCoordinateX)*(xcoord - @xCoordinateX) + (ycoord - @xCoordinateY)*(ycoord - @xCoordinateY)
as distance,
dept.status,
	CASE WHEN @xDeptName is NOT null AND dept.DeptName like @xDeptName + ' +CHAR(39)+ '%' +CHAR(39)+ ' THEN 0
		 WHEN @xDeptName is NOT null AND dept.DeptName like' +CHAR(39)+'%'+CHAR(39)+ ' + @xDeptName + ' +CHAR(39)+'%'+CHAR(39)+ 'THEN 1
		 ELSE 0 END
as orderDeptNameLike,
dbo.x_dept_XY.xcoord,
dbo.x_dept_XY.ycoord, 
'

IF(@ServiceCodes is null)
BEGIN
	SET @Sql1 = @Sql1 + 
	 CHAR(39)+CHAR(39)+ ' as ServiceDescription, ' +
	 CHAR(39)+CHAR(39)+ ' as ServiceID,
0 as IsMedicalTeam, ' +
	 CHAR(39)+CHAR(39)+ ' as doctorName, ' +
	 CHAR(39)+CHAR(39)+ ' as employeeID,  
0 as ShowHoursPicture, 
0 as ShowRemarkPicture, ' +
	 CHAR(39)+CHAR(39)+ ' as ServicePhones, 
1 as serviceStatus,
1 as employeeStatus, 
0 as AgreementType, 
'
	 
END
ELSE
BEGIN
	SET @Sql1 = @Sql1 + 
'[Services].ServiceDescription as ServiceDescription, 
[Services].ServiceCode as ServiceID, 
Employee.IsMedicalTeam as IsMedicalTeam, 
DegreeName + space(1) + Employee.lastName + space(1) + Employee.firstName as doctorName, 
Employee.employeeID as employeeID, 
  CASE WHEN isNull([View_DeptEmployeeReceptionCount].ReceptionCount, 0) = 0 then 0 else 1 end
as ShowHoursPicture, 
  CASE
	(select COUNT(*) from DeptEmployeeServiceRemarks DESR
		where xDES.x_dept_employee_serviceID = DESR.x_dept_employee_serviceID
		)WHEN 0 THEN 0 ELSE 1 END 
as ShowRemarkPicture,
  stuff((SELECT ' + CHAR(39) + ',' + CHAR(39) + ' + convert(varchar(10), x.phone)
		FROM (select dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) as phone
			FROM x_Dept_Employee_Service join EmployeeServicePhones
			on EmployeeServicePhones.x_Dept_Employee_ServiceID = x_Dept_Employee_Service.x_Dept_Employee_ServiceID
			join x_Dept_Employee on x_Dept_Employee_Service.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
			where x_Dept_Employee_Service.serviceCode = xDES.serviceCode
			and x_Dept_Employee.DeptEmployeeID = xDE.DeptEmployeeID
			and x_Dept_Employee.AgreementType in (select * from @xAgreementTypeList)
		) x
		for xml path('+ CHAR(39) + CHAR(39) +')
	),1,1,'+ CHAR(39) + CHAR(39) +')
as ServicePhones,
xDES.status as serviceStatus,
xDE.active as employeeStatus,
xDE.agreementType,
' 	
		 
END	

SET @Sql1 = @Sql1 + 
	' 1 as ServiceOrEvent /* 1 for service, 0 for event */

FROM dept
INNER JOIN DIC_DeptTypes on Dept.deptType = DIC_DeptTypes.deptType
INNER JOIN UnitType on dept.typeUnitCode = UnitType.UnitTypeCode
INNER JOIN Cities on dept.cityCode = Cities.cityCode
LEFT JOIN DeptSimul on dept.deptCode = deptSimul.deptCode
LEFT JOIN x_dept_XY ON dept.deptCode = x_dept_XY.deptCode
LEFT JOIN SubUnitTypeSubstituteName ON dept.typeUnitCode = SubUnitTypeSubstituteName.UnitTypeCode
			AND (IsNull(dept.subUnitTypeCode, 0) + UnitType.DefaultSubUnitTypeCode) = SubUnitTypeSubstituteName.SubUnitTypeCode
'

IF(@ServiceCodes is NOT null)
	SET @Sql1 = @Sql1 +	
'INNER JOIN x_dept_employee xDE on Dept.deptCode = xDE.deptCode
INNER JOIN Employee on Employee.employeeID = xDE.employeeID
LEFT JOIN DIC_EmployeeDegree on DIC_EmployeeDegree.DegreeCode = Employee.degreeCode  
INNER JOIN x_Dept_Employee_Service xDES on xDE.DeptEmployeeID = xDES.DeptEmployeeID
INNER JOIN [Services] on [Services].ServiceCode = xDES.serviceCode 
LEFT JOIN [View_DeptEmployeeReceptionCount] on [View_DeptEmployeeReceptionCount].DeptEmployeeID = xDE.DeptEmployeeID
			and [View_DeptEmployeeReceptionCount].serviceCode = xDES.serviceCode
			and xDE.AgreementType in (select * from @xAgreementTypeList)
			
			
'
	
SET @SqlWhere1 = ' WHERE 1=1 
'

IF(@DistrictCodes is NOT null)
	
		SET @SqlWhere1 = @SqlWhere1 + 
		' AND (
					exists (SELECT IntField FROM dbo.SplitString(@xDistrictCodes) where dept.districtCode = IntField) 
					OR
					exists (SELECT IntField FROM dbo.SplitString(@xDistrictCodes) as T
							JOIN  x_Dept_District ON T.IntField = x_Dept_District.districtCode
							WHERE x_Dept_District.DeptCode = dept.DeptCode)
					OR (deptLevel = 1 AND dept.IsHospital = 0)
			  ) 
		'
	
IF(@CityCode is NOT null AND @CoordinateX is null)
	SET @SqlWhere1 = @SqlWhere1 + 
	' AND  (dept.CityCode = @xCityCode
			OR (
				(@xTypeUnitCode is NOT null OR @xServiceCodes is NOT null)
				AND 
				(dept.deptLevel = 1 OR (dept.deptLevel = 2 AND exists (SELECT districtCode FROM Cities WHERE cityCode = @xCityCode)))
				)
			)
			'
IF(@typeUnitCode is NOT null)
	SET @SqlWhere1 = @SqlWhere1 + 
	' AND (typeUnitCode in (Select IntField from dbo.SplitString(@xTypeUnitCode)) )
	'
IF(@subUnitTypeCode is NOT null)	
	SET @SqlWhere1 = @SqlWhere1 + 
	' AND (dept.subUnitTypeCode in (Select IntField from dbo.SplitString(@xSubUnitTypeCode)))
	'
	
IF(@DeptName is NOT null)	
	SET @SqlWhere1 = @SqlWhere1 + 	
	' AND (dept.DeptName like '+CHAR(39)+'%'+CHAR(39)+ ' + @xDeptName + ' +CHAR(39)+'%'+CHAR(39)+ 
	' OR dept.DeptName like @xDeptName + ' +CHAR(39)+ '%' +CHAR(39)+
	' OR dept.DeptName = @xDeptName	) 
	'
	
IF(@DeptCode is NOT null)	
	SET @SqlWhere1 = @SqlWhere1 + 	
	' AND (dept.deptCode = @xDeptCode OR deptSimul.Simul228 = @xDeptCode) 
	'
	
/* Check the reception days for Services	*/

IF(@ReceptionDays is NOT null)
	BEGIN
		IF(@ServiceCodes is NOT null)
			SET @SqlWhere1 = @SqlWhere1 + 
				' AND EXISTS (SELECT deptCode
							 FROM x_Dept_Employee xDE
							 JOIN deptEmployeeReception dER on xDE.DeptEmployeeID = dER.DeptEmployeeID
							 JOIN deptEmployeeReceptionServices dERS on dER.receptionID = dERS.receptionID
							 WHERE exists (select * from @xReceptionDaysList where IntVal = receptionDay)
								AND exists (select * from @xServiceCodesList where IntVal = dERS.serviceCode)
								AND xDE.deptCode = Dept.deptCode
								AND xDE.employeeID = Employee.employeeID
								and xDE.AgreementType in (select * from @xAgreementTypeList)
							)
							'
		ELSE
			SET @SqlWhere1 = @SqlWhere1 + 
				' AND EXISTS (SELECT deptCode 
							FROM DeptReception 
							WHERE dept.deptCode = deptCode
							AND exists (select * from @xReceptionDaysList where IntVal = receptionDay)
							)
							'		
			
	END
--	Check the reception hours for Services

IF(@OpenAtHour is NOT null OR @OpenFromHour is NOT null OR @OpenToHour is NOT null)
BEGIN
	IF( @ServiceCodes is NOT null )
	BEGIN
		SET @SqlWhere1 = @SqlWhere1 + 	
		' AND EXISTS (SELECT deptCode
					 FROM x_Dept_Employee xDE
					 JOIN deptEmployeeReception dER on xDE.DeptEmployeeID = dER.DeptEmployeeID
					 JOIN deptEmployeeReceptionServices dERS on dER.receptionID = dERS.receptionID
					 WHERE xDE.AgreementType in (select * from @xAgreementTypeList)
					 '
				IF( @ReceptionDays is NOT null )
				BEGIN
					SET @SqlWhere1 = @SqlWhere1 + 					 
					' AND exists (select * from @xReceptionDaysList where IntVal = receptionDay) 
					'
				END
				SET @SqlWhere1 = @SqlWhere1 + 						
					'AND exists (select * from @xServiceCodesList where IntVal = dERS.serviceCode)
					AND xDE.deptCode = Dept.deptCode
					AND xDE.employeeID = Employee.employeeID 
					'
				IF(	@OpenToHour IS NOT NULL OR @OpenFromHour IS NOT NULL )
				BEGIN
					SET @SqlWhere1 = @SqlWhere1 + 
					  ' AND (
								(Cast(Left(openingHour,2) as real) + Cast(Right(openingHour,2) as real)/60) <= @xOpenFromHour_real 
								AND 
								(Cast(Left(closingHour,2) as real) + Cast(Right(closingHour,2) as real)/60) >= @xOpenToHour_real 
							)
						   OR (openingHour = '+CHAR(39)+'00:00'+CHAR(39)+' AND closingHour = '+CHAR(39)+'00:00'+CHAR(39)+')
						   OR
						   (
							(Cast(Left(closingHour,2) as real) + Cast(Right(closingHour,2) as real)/60) >= @xOpenToHour_real 
							AND
							(Cast(Left(closingHour,2) as real) + Cast(Right(closingHour,2) as real)/60) < 
																	(Cast(Left(openingHour,2) as real) + Cast(Right(openingHour,2) as real)/60) 
						   ) 
					'						
				END

				IF(	@OpenAtHour IS NOT NULL )
				BEGIN
					SET @SqlWhere1 = @SqlWhere1 + 
					 ' AND (
								(
									(Cast(Left(openingHour,2) as real) + Cast(Right(openingHour,2) as real)/60) <= @xOpenAtHour_real 
									AND
									(Cast(Left(closingHour,2) as real) + Cast(Right(closingHour,2) as real)/60) > @xOpenAtHour_real 
								)	
							  OR -- close at midnight
								(
									(Cast(Left(openingHour,2) as real) + Cast(Right(openingHour,2) as real)/60) <= @xOpenAtHour_real 
									AND
									closingHour = '+CHAR(39)+'00:00'+CHAR(39)+ 
								')						  	
							  OR -- 24 hours
							   (
									openingHour = '+CHAR(39)+'00:00'+CHAR(39)+
									' AND
									closingHour = '+CHAR(39)+'00:00'+CHAR(39)+
							   ')
							  OR -- starts before midnight and close after midnight
							   (
								   (Cast(Left(closingHour,2) as real) + Cast(Right(closingHour,2) as real)/60) > @xOpenAtHour_real 
									AND
								   (Cast(Left(closingHour,2) as real) + Cast(Right(closingHour,2) as real)/60) < 
																			(Cast(Left(openingHour,2) as real) + Cast(Right(openingHour,2) as real)/60) 
							   ) 		  
							)
					'
				END
						
					IF(	@ReceptionDays IS NOT NULL )
					BEGIN
						SET @SqlWhere1 = @SqlWhere1 + 
							' AND exists (select * from @xReceptionDaysList where IntVal = receptionDay) 
							'
					END

	END
--	Check the reception hours for Dept	
	IF(@ServiceCodes is null)
	BEGIN
		SET @SqlWhere1 = @SqlWhere1 + 
		' AND exists 
				(SELECT deptCode FROM DeptReception as T 
				  WHERE T.deptCode = dept.deptCode 
		'
			IF(	@OpenToHour IS NOT NULL OR @OpenFromHour IS NOT NULL )
			BEGIN
				SET @SqlWhere1 = @SqlWhere1 +
				' AND (
						(
							(Cast(Left(T.openingHour,2) as real) + Cast(Right(T.openingHour,2) as real)/60) <= @xOpenFromHour_real 
							AND 
							(Cast(Left(T.closingHour,2) as real) + Cast(Right(T.closingHour,2) as real)/60) >= @xOpenToHour_real 
						)
					   OR (T.openingHour = '+CHAR(39)+'00:00'+CHAR(39)+' AND T.closingHour = '+CHAR(39)+'00:00'+CHAR(39)+')
					   OR
					   (
						(Cast(Left(T.closingHour,2) as real) + Cast(Right(T.closingHour,2) as real)/60) >= @xOpenToHour_real 
						AND
						(Cast(Left(T.closingHour,2) as real) + Cast(Right(T.closingHour,2) as real)/60) < 
																(Cast(Left(T.openingHour,2) as real) + Cast(Right(T.openingHour,2) as real)/60) 
					   )						   
				)
				' 
			END	
			IF(	@OpenAtHour IS NOT NULL )
			BEGIN
				SET @SqlWhere1 = @SqlWhere1 +	
				' AND (
	  					(
							(Cast(Left(T.openingHour,2) as real) + Cast(Right(T.openingHour,2) as real)/60) <= @xOpenAtHour_real 
							AND
							(Cast(Left(T.closingHour,2) as real) + Cast(Right(T.closingHour,2) as real)/60) > @xOpenAtHour_real 
						)	
					  OR -- close at midnight
						(
							(Cast(Left(T.openingHour,2) as real) + Cast(Right(T.openingHour,2) as real)/60) <= @xOpenAtHour_real 
							AND
							T.closingHour = '+CHAR(39)+'00:00'+CHAR(39)+ 
						')						  	
					  OR -- 24 hours
					   (
							T.openingHour = '+CHAR(39)+'00:00'+CHAR(39)+
							' AND
							T.closingHour = '+CHAR(39)+'00:00'+CHAR(39)+
					   ')
					  OR -- starts before midnight and close after midnight
					   (
						   (Cast(Left(T.closingHour,2) as real) + Cast(Right(T.closingHour,2) as real)/60) > @xOpenAtHour_real 
							AND
						   (Cast(Left(T.closingHour,2) as real) + Cast(Right(T.closingHour,2) as real)/60) < 
																	(Cast(Left(T.openingHour,2) as real) + Cast(Right(T.openingHour,2) as real)/60) 
					   )					  
				)
				'
			END		
			IF(	@ReceptionDays IS NOT NULL )
			BEGIN
				SET @SqlWhere1 = @SqlWhere1 +	
				' AND exists (select * from @xReceptionDaysList where IntVal = T.receptionDay)
				'
			END
			
	END
	SET @SqlWhere1 = @SqlWhere1 + ') '
END	
IF(	@deptHandicappedFacilities IS NOT NULL )
BEGIN
	SET @SqlWhere1 = @SqlWhere1 +	
	' AND exists (SELECT deptCode FROM dept as New
				  WHERE dept.deptCode = New.deptCode
				  AND (SELECT COUNT(deptCode) FROM DeptHandicappedFacilities as T
						WHERE FacilityCode IN (SELECT IntField FROM dbo.SplitString(@xDeptHandicappedFacilities))
						AND T.deptCode = New.deptCode) = @xHandicappedFacilitiesCount )	
						'		
END

IF(	@isCommunity IS NOT NULL OR @isMushlam IS NOT NULL OR @isHospital IS NOT NULL )
BEGIN
	SET @SqlWhere1 = @SqlWhere1 +	
	' AND ( @xIsCommunity = dept.IsCommunity OR @xIsMushlam = dept.isMushlam OR @xIsHospital = dept.isHospital ) 
	'
END		

IF(	@status is NOT null )
BEGIN
	IF(@ServiceCodes is null)
	BEGIN
		SET @SqlWhere1 = @SqlWhere1 +	
		' AND	((@xStatus = 0 AND dept.status = 0)
				OR (@xStatus = 1 AND (dept.status = 1 OR dept.status = 2 ))
				OR (@xStatus = 2 AND dept.status = 2 )
				) 
				'		
	END
	
	IF(@ServiceCodes is NOT null)
	BEGIN
		SET @SqlWhere1 = @SqlWhere1 +
		' AND	((@xStatus = 0 AND dept.status = 0)
				OR (@xStatus = 1 AND (dept.status = 1 OR dept.status = 2 ))
				OR (@xStatus = 2 AND dept.status = 2 )
		) 

		AND	((@xStatus = 0 AND xDE.active = 0)
				OR (@xStatus = 1 AND (xDE.active = 1 OR xDE.active = 2 ))
				OR (@xStatus = 2 AND (xDE.active = 1 ))
				)

		AND	((@xStatus = 0 AND xDES.status = 0)
				OR (@xStatus = 1 AND (xDES.status = 1 OR xDES.status = 2 ))
				OR (@xStatus = 2 AND (xDES.status = 1 ))
				) 

				'		
	END	
END	

IF(	@populationSectorCode IS NOT NULL )
BEGIN
	SET @SqlWhere1 = @SqlWhere1 +	
	' AND (dept.populationSectorCode = @xPopulationSectorCode) 
	'	
END	

IF(	@ServiceCodes IS NOT NULL )
BEGIN
	SET @SqlWhere1 = @SqlWhere1 +	
	' AND (
			(SELECT count(serviceCode) 
			FROM x_Dept_Employee  xd 
			INNER JOIN x_Dept_Employee_Service xdes ON xd.DeptEmployeeID = xdes.DeptEmployeeID	
			WHERE xd.deptCode = dept.deptCode
			AND exists (select * from @xServiceCodesList where IntVal = serviceCode)
			and xDE.AgreementType in (select * from @xAgreementTypeList)
			)
		 > 0 ) 
	'	
END
	
IF(	@CoordinateX IS NOT NULL )
BEGIN
	SET @SqlWhere1 = @SqlWhere1 +	
	' AND xcoord is NOT null AND ycoord is NOT null 
	'
END	

IF(	@ServiceCodes IS NOT NULL )
BEGIN
	SET @SqlWhere1 = @SqlWhere1 +	
	' AND exists (select * from @xServiceCodesList where IntVal = xDES.ServiceCode) 
	'
	END
	
/*********** EVENTS ***********/
SET @Sql2 = ''
SET @SqlWhere2 = ''

IF(	@ServiceCodes IS NOT NULL )
BEGIN
	SET @Sql2 =

	' UNION


	SELECT
	dept.deptCode,
	dept.deptName,
	dept.deptType,
	dept.deptLevel,
	dept.displayPriority,
	dept.ShowUnitInInternet,
	DIC_DeptTypes.deptTypeDescription,
	dept.typeUnitCode,
		CASE IsNull(dept.subUnitTypeCode, -1) 
						WHEN -1 THEN UnitType.DefaultSubUnitTypeCode
						ELSE dept.subUnitTypeCode END
	as subUnitTypeCode,
	SubstituteName = ' +CHAR(39)+CHAR(39)+ ',
	dept.IsCommunity,
	dept.IsMushlam,
	dept.IsHospital,
	UnitType.UnitTypeName,
	dept.cityCode,
	Cities.cityName,
	dept.streetName as street,
	dept.house,
	dept.flat,
	dept.addressComment,
		dbo.GetAddress(dept.deptCode)
	as address,
	dbo.GetDeptPhoneNumber(dept.deptCode, 1, 1) as phone,
		(SELECT COUNT(*) 
		from View_DeptRemarks
		WHERE deptCode = dept.deptCode
		AND GETDATE() between ISNULL(validFrom,'+CHAR(39)+'1900-01-01'+CHAR(39)+') and ISNULL(validTo,'+CHAR(39)+'2079-01-01'+CHAR(39)+')
		AND (IsSharedRemark = 0 OR dept.IsCommunity = 1) 
		)
	as countDeptRemarks,
		(select count(receptionID) 
		from DeptReception
		where deptCode = dept.deptCode
		AND (GETDATE() between ISNULL(validFrom,'+CHAR(39)+'1900-01-01'+CHAR(39)+') and ISNULL(validTo,'+CHAR(39)+'2079-01-01'+CHAR(39)+')))
	as countReception,
	Simul228 = null,
		(xcoord - @xCoordinateX)*(xcoord - @xCoordinateX) + (ycoord - @xCoordinateY)*(ycoord - @xCoordinateY)
	as distance,
	dept.status,
		CASE --WHEN @xDeptName is null THEN 0 
			 WHEN @xDeptName is NOT null AND dept.DeptName like @xDeptName +' +CHAR(39)+ '%'+CHAR(39)+ ' THEN 0
			 WHEN @xDeptName is NOT null AND dept.DeptName like '+CHAR(39)+'%'+CHAR(39)+ '+ @xDeptName + '+CHAR(39)+'%'+CHAR(39)+' THEN 1
			 ELSE 0 END
	as orderDeptNameLike, 
	dbo.x_dept_XY.xcoord,
	dbo.x_dept_XY.ycoord,					
		DIC_Events.EventName
	as ServiceDescription,
		DeptEvent.DeptEventID
	as ServiceID,'
	+CHAR(39)+CHAR(39)+' as IsMedicalTeam, '
	+CHAR(39)+CHAR(39)+' as doctorName, 
	0000 as employeeID,
	1 as ShowHoursPicture,
	0 as ShowRemarkPicture, '
	+CHAR(39)+CHAR(39)+' as ServicePhones,
	1 as serviceStatus,
	1 as employeeStatus,
	0 as AgreementType,
	0 as ServiceOrEvent -- 1 for service, 0 for event 

	FROM DeptEvent
	INNER JOIN dept ON DeptEvent.deptCode = dept.deptCode
	INNER JOIN DIC_DeptTypes on Dept.deptType = DIC_DeptTypes.deptType
	INNER JOIN UnitType on dept.typeUnitCode = UnitType.UnitTypeCode
	INNER JOIN Cities on dept.cityCode = Cities.cityCode
	INNER JOIN DIC_Events ON DeptEvent.EventCode = DIC_Events.EventCode
	LEFT JOIN x_dept_XY ON dept.deptCode = x_dept_XY.deptCode 
	'

	SET @SqlWhere2 = ' WHERE 1=1 '

	IF(	@DistrictCodes IS NOT NULL )
	BEGIN
		SET @SqlWhere2 = @SqlWhere2 +	
		' AND (
				dept.districtCode IN (Select IntField from dbo.SplitString(@xDistrictCodes))
			    OR 
				dept.DeptCode IN (SELECT x_Dept_District.DeptCode FROM dbo.SplitString(@xDistrictCodes) as T
								JOIN  x_Dept_District ON T.IntField = x_Dept_District.districtCode) 
			  )'
	END

	IF(	@ServiceCodes is NOT null )	
		SET @SqlWhere2 = @SqlWhere2 +
		' AND exists (select * from @xServiceCodesList where IntVal = DIC_Events.EventCode) '

	IF(	@CityCode is NOT null AND @CoordinateX is null)
	BEGIN
		SET @SqlWhere2 = @SqlWhere2 +
		' AND (dept.CityCode = @xCityCode '
	
		IF(	@typeUnitCode is NOT null )
		BEGIN
			SET @SqlWhere2 = @SqlWhere2 +	
				' OR (
					(dept.deptLevel = 1 OR (dept.deptLevel = 2 AND exists (SELECT districtCode FROM Cities WHERE cityCode = @CityCode and  dept.districtCode = districtCode)))
					)'		
		END
				
		SET @SqlWhere2 = @SqlWhere2 + ') '
	
	END	
	
	SET @SqlWhere2 = @SqlWhere2 + ' AND DIC_Events.IsActive = 1 '

	IF(	@typeUnitCode is NOT null )
	BEGIN
		SET @SqlWhere2 = @SqlWhere2 +	
		' AND typeUnitCode in (Select IntField from  dbo.SplitString(@xTypeUnitCode)) '
	END 	
	
	IF(	@subUnitTypeCode is NOT null )
	BEGIN
		SET @SqlWhere2 = @SqlWhere2 +	
		' AND subUnitTypeCode = @xSubUnitTypeCode '
	END 
	IF(	@DeptName is NOT null )
	BEGIN
		SET @SqlWhere2 = @SqlWhere2 +	
		' AND (dept.DeptName like @xDeptName + '+CHAR(39)+'%'+CHAR(39)+ ') '
	END 

	IF(	@OpenAtHour is NOT null OR @OpenFromHour is NOT null OR @OpenToHour is NOT null)
	BEGIN
		SET @SqlWhere2 = @SqlWhere2 +	
		' AND exists
			(SELECT DeptEventID FROM DeptEventParticulars as T 
				WHERE 
					T.DeptEventID = DeptEvent.DeptEventID '
				
			IF(	@OpenToHour is NOT null OR @OpenFromHour is NOT null)
				SET @SqlWhere2 = @SqlWhere2 +					
				' AND (
						(Cast(Left(T.openingHour,2) as real) + Cast(Right(T.openingHour,2) as real)/60) < @xOpenToHour_real 
							AND
						(Cast(Left(T.closingHour,2) as real) + Cast(Right(T.closingHour,2) as real)/60) > @xOpenFromHour_real
					) '
				
			IF(	@OpenAtHour is NOT null )
			BEGIN
				SET @SqlWhere2 = @SqlWhere2 +					
				' AND
					( 
						(
						(Cast(Left(T.openingHour,2) as real) + Cast(Right(T.openingHour,2) as real)/60) < @xOpenAtHour_real 
							AND
						(Cast(Left(T.closingHour,2) as real) + Cast(Right(T.closingHour,2) as real)/60) > @xOpenAtHour_real
						)
					) 
				' 
			END				
		IF(	@ReceptionDays is NOT null )
		BEGIN
			SET @SqlWhere2 = @SqlWhere2 +					
				' AND exists (select * from @xReceptionDaysList where IntVal = T.Day)'
		END
	
		SET @SqlWhere2 = @SqlWhere2 + ') /**/'
	END 

	IF(	@deptHandicappedFacilities is NOT null )
	BEGIN
		SET @SqlWhere2 = @SqlWhere2 +
		' AND 
		exists (SELECT deptCode FROM dept as New
							WHERE dept.deptCode = New.deptCode
								and (SELECT COUNT(deptCode) FROM DeptHandicappedFacilities as T
									WHERE FacilityCode IN (SELECT IntField FROM dbo.SplitString(@xDeptHandicappedFacilities))
									AND T.deptCode = New.deptCode) = @xHandicappedFacilitiesCount ) '
	END	

	IF(	@deptCode is NOT null )
	BEGIN
		SET @SqlWhere2 = @SqlWhere2 +
		' AND Dept.deptCode = @xDeptCode 
		'
	END

	IF(	@CoordinateX is NOT null )
	BEGIN
		SET @SqlWhere2 = @SqlWhere2 +
		' AND xcoord is NOT null AND ycoord is NOT null 
		'
	END

	SET @SqlWhere2 = @SqlWhere2 +	
		' AND ( (GETDATE() between ISNULL(DeptEvent.FromDate,'+CHAR(39)+'1900-01-01'+CHAR(39)+') and ISNULL(DeptEvent.ToDate,'+CHAR(39)+'2079-01-01'+CHAR(39)+') AND @xStatus = 1)
			  OR
			  (DeptEvent.FromDate > getdate() OR DeptEvent.ToDate < getdate() AND @xStatus = 0)
			  ) 
		  
		  AND (Dept.Status != 0) '
		  
	IF(	@isCommunity is NOT null OR @isMushlam is NOT null OR @isHospital is NOT null) 
	BEGIN
		SET @SqlWhere2 = @SqlWhere2 +
		' AND (    (@xIsCommunity IS NOT NULL AND dept.IsCommunity = @xIsCommunity)
				OR (@xIsMushlam IS NOT NULL AND dept.IsMushlam = @xIsMushlam)
				OR (@xIsHospital IS NOT NULL AND dept.IsHospital = @xIsHospital)
			   ) '
	END
		  
END
--------------------------------------------
SET @SqlEnd =

'
) as innerDeptSelection
) as middleSelection



SELECT TOP (@xPageSise) * 
FROM #tempTableAllRows
WHERE RowNumber > @xStartingPosition
	AND RowNumber <= @xStartingPosition + @xPageSise
ORDER BY RowNumber



-- select with same joins and conditions as above
-- just to get count of all the records in select

SET @xCount =	
		(SELECT COUNT(*)
		FROM #tempTableAllRows)

DROP TABLE #tempTableAllRows
	

IF(@xMaxNumberOfRecords is NOT null)
BEGIN
	IF(@xCount > @xMaxNumberOfRecords)
	BEGIN
		SET @xCount = @xMaxNumberOfRecords
	END
END
	
SELECT @xCount
'
------------------------------------------------------------------------

SET @Sql1 = @Declarations + @Sql1 + @SqlWhere1 + @Sql2 + @SqlWhere2 + @SqlEnd

--Exec rpc_HelperLongPrint @Sql1 

exec sp_executesql @Sql1, @params,		  
	@xDistrictCodes = @DistrictCodes,
	@xCityCode = @CityCode,
	@xTypeUnitCode = @typeUnitCode,
	@xsubUnitTypeCode = @subUnitTypeCode,
	@xServiceCodes = @ServiceCodes,
	@xServiceCodesList = @ServiceCodesList,
	@xDeptName = @DeptName,
	@xDeptCode = @DeptCode,
	@xReceptionDaysList = @ReceptionDaysList,
	@xOpenAtHour = @OpenAtHour,
	@xOpenFromHour = @OpenFromHour,
	@xOpenToHour = @OpenToHour,
	@xIsCommunity = @IsCommunity,
	@xIsMushlam = @IsMushlam,
	@xIsHospital = @IsHospital,
	@xStatus = @Status,
	@xPopulationSectorCode = @PopulationSectorCode,
	@xDeptHandicappedFacilities = @DeptHandicappedFacilities,
	@xAgreementTypeList = @AgreementTypeList,
	@xPageSise = @PageSise,
	@xStartingPage = @StartingPage,
	@xSortedBy = @SortedBy,
	@xIsOrderDescending = @IsOrderDescending,
	
	@xCoordinateX = @CoordinateX,
	@xCoordinateY = @CoordinateY,
	@xMaxNumberOfRecords = @MaxNumberOfRecords	


GO


GRANT EXEC ON dbo.rpc_getDeptList_PagedSorted TO PUBLIC

GO

-- **********************************************************************************


--**** Yaniv - Start rpc_getDeptDetailsForPopUp *****************************


IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rpc_getDeptDetailsForPopUp')
	BEGIN
		DROP  Procedure  rpc_getDeptDetailsForPopUp
	END

GO


CREATE Procedure [dbo].[rpc_getDeptDetailsForPopUp]
	(
		@deptCode int
	)
AS

--- DeptDetails --------------------------------------------------------
SELECT
D.deptName,
D.deptType, -- 1, 2, 3
D.deptLevel,
D.managerName,
'substituteManagerName' = IsNull((SELECT TOP 1 DegreeName + ' ' + lastName + ' ' + firstName
							FROM employee
							INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode
							INNER JOIN x_dept_employee ON employee.employeeID = x_dept_employee.employeeID
							INNER JOIN x_Dept_Employee_Position ON x_dept_employee.DeptEmployeeID = x_Dept_Employee_Position.DeptEmployeeID							
							INNER JOIN mappingPositions ON x_Dept_Employee_Position.positionCode = mappingPositions.positionCode
							WHERE mappingPositions.mappedToManager = 1
							AND x_dept_employee.deptCode = D.deptCode
							), ''),
D.administrativeManagerName,
'substituteAdministrativeManagerName' = IsNull((SELECT TOP 1 DegreeName + ' ' + lastName + ' ' + firstName
							FROM employee
							INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode
							INNER JOIN x_dept_employee ON employee.employeeID = x_dept_employee.employeeID
							INNER JOIN x_Dept_Employee_Position ON x_dept_employee.DeptEmployeeID = x_Dept_Employee_Position.DeptEmployeeID							
							INNER JOIN mappingPositions ON x_Dept_Employee_Position.positionCode = mappingPositions.positionCode
							WHERE mappingPositions.mappedToAdministrativeManager = 1
							AND x_dept_employee.deptCode = D.deptCode
							), ''),
'address' = dbo.GetAddress(@DeptCode),
D.cityCode,
Cities.cityName,
D.StreetCode,
'streetName' = RTRIM(LTRIM(D.streetName)),
D.house,
D.flat,
D.floor,
D.entrance,
D.addressComment,
D.zipCode,
D.email,
'showEmailInInternet' = CAST(IsNull(D.showEmailInInternet, 0) as bit),

'districtCode' = IsNull(D.districtCode, -1),
'districtName' = (select districtName from View_AllDistricts where districtCode=D.districtCode),
'administrationCode' = IsNull(D.administrationCode, -1),				-- "מנהלות" 
'subAdministrationCode' = IsNull(D.subAdministrationCode, -1),
'subAdministrationName' = (SELECT dept.deptName 
							FROM dept
							WHERE dept.deptCode = D.subAdministrationCode),
'populationSectorCode' = IsNull(D.populationSectorCode, -1),
D.deptCode,
DIC_ActivityStatus.statusDescription,
'phone1' = (SELECT dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension)
			FROM DeptPhones
			WHERE deptCode = @deptCode
			AND phoneType = 1 -- (Phone)
			AND phoneOrder = 1 ),
'phone2' = (SELECT dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension)
			FROM DeptPhones
			WHERE deptCode = @deptCode
			AND phoneType = 1 -- (Phone)
			AND phoneOrder = 2 ),
'fax' = (SELECT dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension)
			FROM DeptPhones
			WHERE deptCode = @deptCode
			AND phoneType = 2 -- (Fax)
			AND phoneOrder = 1 )

FROM dept as D
INNER JOIN DIC_DeptTypes ON D.deptType = DIC_DeptTypes.deptType	-- ??
INNER JOIN Cities ON D.cityCode = Cities.cityCode
INNER JOIN DIC_ActivityStatus ON D.status = DIC_ActivityStatus.status

WHERE D.deptCode = @deptCode

GO


GRANT EXEC ON rpc_getDeptDetailsForPopUp TO PUBLIC
GO
         
         
--**** Yaniv - End rpc_getDeptDetailsForPopUp *****************************




-- ***************************************************************************************************************


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_DoctorOverView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[rpc_DoctorOverView]
GO


CREATE Procedure [dbo].[rpc_DoctorOverView]
(
	@employeeID int
)

AS

SELECT 
IsNull(Employee.primaryDistrict, -1) as primaryDistrict,
View_AllDistricts.districtName,
EmployeeSectorDescription,
Employee.employeeID,
Employee.badgeID,
'EmployeeName' = DIC_EmployeeDegree.DegreeName + ' ' + Employee.firstName + ' ' + Employee.lastName,
Employee.firstName,
Employee.lastName,
CAST(Employee.licenseNumber as varchar(10)) + CASE WHEN IsDental = 1 THEN ' (שיניים) ' ELSE '' END  as licenseNumber,
'active' = IsNull(statusDescription, 'לא מוגדר'),
'sex' = isNull(sexDescription, ''),
'languages' = dbo.fun_GetEmployeeLanguages(employeeID),
'professions' = dbo.fun_GetEmployeeProfessions(employeeID),
'expert' = CASE WHEN Employee.IsVirtualDoctor = 1 THEN '' 
				WHEN Employee.IsMedicalTeam = 1 THEN ''
				ELSE dbo.fun_GetEmployeeExpert(employeeID) END,
'sevices' = dbo.fun_GetEmployeeServices(employeeID),
'homePhone' = (	SELECT TOP 1 dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) 
				FROM EmployeePhones
				WHERE employeeID = @employeeID AND phoneType = 1 AND phoneOrder = 1),
'cellPhone' = (	SELECT TOP 1 dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) 
				FROM EmployeePhones
				WHERE employeeID = @employeeID AND phoneType = 3 AND phoneOrder = 1),
'isUnlisted_Home' = IsNull((SELECT TOP 1 isUnlisted FROM EmployeePhones
				WHERE employeeID = @employeeID AND phoneType = 1 AND phoneOrder = 1), 0),
'isUnlisted_Cell' = IsNull((SELECT TOP 1 isUnlisted FROM EmployeePhones
				WHERE employeeID = @employeeID AND phoneType = 3 AND phoneOrder = 1), 0),
Employee.email,
'showEmailInInternet' = isNull(Employee.showEmailInInternet, 0),
IsSurgeon,
PrivateHospital,
PrivateHospitalPosition

FROM Employee
INNER JOIN DIC_EmployeeDegree ON Employee.degreeCode = DIC_EmployeeDegree.DegreeCode
INNER JOIN EmployeeSector ON Employee.EmployeeSectorCode = EmployeeSector.EmployeeSectorCode
LEFT JOIN View_AllDistricts ON Employee.primaryDistrict = View_AllDistricts.districtCode
LEFT JOIN DIC_Gender ON Employee.sex = DIC_Gender.sex
LEFT JOIN DIC_ActivityStatus ON Employee.active = DIC_ActivityStatus.status

WHERE employeeID = @employeeID

-- Clinics where the doctor works --------------------------------
SELECT ISNULL(GrOuter.EmployeeServiceQueueOrderGroup, '00000000000000') as EmployeeServiceQueueOrderGroup,  
MainSelect.*,
GrOuter3.QueueOrderDescription
FROM
(
SELECT
Dept.deptCode,
Dept.deptName,
Dept.cityCode,
DeptEmployeeID,
Cities.cityName,
'address' = dbo.GetAddress(Dept.deptCode),
'ShowPhonesFromClinic' = CascadeUpdateDeptEmployeePhonesFromClinic,
'phones' = dbo.fun_GetDeptEmployeePhones(x_Dept_Employee.employeeID, x_Dept_Employee.deptCode),	
'phonesOnly' = dbo.fun_GetDeptEmployeePhonesOnly(x_Dept_Employee.employeeID, x_Dept_Employee.deptCode),	
'fax' = dbo.fun_GetDeptEmployeeFax(x_Dept_Employee.employeeID, x_Dept_Employee.deptCode),	
'professions' = dbo.fun_GetEmployeeInDeptProfessions(x_Dept_Employee.employeeID, x_Dept_Employee.deptCode, 1),
'positions' = dbo.fun_GetEmployeeInDeptPositions(x_Dept_Employee.employeeID, x_Dept_Employee.deptCode, Employee.sex ),
'services' = dbo.fun_GetEmployeeInDeptServices(x_Dept_Employee.employeeID, x_Dept_Employee.deptCode, 1),
'phonesForQueueOrder' = dbo.fun_getEmployeeQueueOrderPhones_All(x_Dept_Employee.employeeID, x_Dept_Employee.deptCode),
x_Dept_Employee.AgreementType,
'ReceptionDaysCount' = 
	(select count(*) FROM
	(
	SELECT receptionDay
	FROM deptEmployeeReception der
	INNER JOIN deptEmployeeReceptionServices ders ON der.receptionID = ders.receptionID
	INNER JOIN x_dept_employee_service xdes ON der.DeptEmployeeID = xdes.DeptEmployeeID					
	WHERE der.DeptEmployeeID = x_dept_employee.DeptEmployeeID	
	AND xdes.Status = 1
	AND (
			(   
				((validFrom IS not NULL and  validTo IS NULL) and (getDate() >= validFrom ))			
				or ((validFrom IS NULL and validTo IS not NULL) and validTo >= getDate())
				or ((validFrom IS not NULL and  validTo IS not NULL) and (getDate() >= validFrom and validTo >= getDate()))
			)
			OR (validFrom IS NULL AND validTo IS NULL)
		)	
	
	) as t),

--using  View_DeptEmployee_EmployeeRemarks includes EmployeeRemarks  per clinic
-- and EmployeeRemarks Attributed ToAll Clinics InCommunity, ..InMushlam, ..InHospitals 
-- according to Dept Membership Type
										
'RemarksCount' = 
	(SELECT distinct COUNT(*) from View_DeptEmployee_EmployeeRemarks as v_DE_ER
		where v_DE_ER.EmployeeID = @EmployeeID
		and v_DE_ER.DeptCode = Dept.deptCode
		AND (v_DE_ER.ValidFrom is null OR DATEDIFF(dd, v_DE_ER.ValidFrom ,getdate()) >= 0)
		AND (v_DE_ER.ValidTo is null OR DATEDIFF(dd, v_DE_ER.ValidTo ,getdate()) <= 0)
	)
	
	+
	
	(SELECT COUNT(*)
	 FROM DeptEmployeeServiceRemarks desr
	 INNER JOIN x_Dept_Employee_Service xdes ON desr.x_dept_employee_serviceID = xdes.x_dept_employee_serviceID	 
	 WHERE xdes.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
	 AND (ValidFrom is NULL OR DATEDIFF(dd, ValidFrom ,getdate()) >= 0 )
	 AND (ValidTo is NULL OR  DATEDIFF(dd, ValidTo ,getdate()) <= 0 ) 
	),
'PermitOrderMethods' = IsNull(DIC_QueueOrder.PermitOrderMethods, 0),
x_Dept_Employee.active as status

FROM x_Dept_Employee 
INNER JOIN Dept ON x_Dept_Employee.deptCode = Dept.deptCode
INNER JOIN Employee ON x_Dept_Employee.employeeID = Employee.employeeID
INNER JOIN Cities ON Dept.cityCode = Cities.cityCode
LEFT JOIN DIC_QueueOrder ON x_dept_employee.QueueOrder = DIC_QueueOrder.QueueOrder
WHERE x_Dept_Employee.employeeID = @employeeID
) as MainSelect
LEFT JOIN
(SELECT * FROM
	(
		SELECT DeptCode
		, dbo.fun_GetEmployeeServiceQueueOrderGroup(xd.DeptEmployeeID, xdes.serviceCode ) as EmployeeServiceQueueOrderGroup
		FROM x_Dept_Employee_Service xdes
		INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
		WHERE xd.employeeID = @employeeID 
		) as GrInner
		GROUP BY DeptCode, EmployeeServiceQueueOrderGroup
	) as GrOuter 
	ON MainSelect.DeptCode = GrOuter.DeptCode
LEFT JOIN	
(SELECT * FROM
	(
		SELECT dbo.fun_GetEmployeeServiceGroup_QueueOrderDescription(xd.DeptEmployeeID, serviceCode) as QueueOrderDescription,
		dbo.fun_GetEmployeeServiceQueueOrderGroup(xd.DeptEmployeeID, xdes.serviceCode ) as EmployeeServiceQueueOrderGroup
		FROM x_Dept_Employee_Service xdes
		INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
		WHERE xd.employeeID = @employeeID 
		) as GrInner3
		GROUP BY EmployeeServiceQueueOrderGroup, QueueOrderDescription
	) as GrOuter3 
	ON GrOuter.EmployeeServiceQueueOrderGroup = GrOuter3.EmployeeServiceQueueOrderGroup	

ORDER BY deptName


-------- Doctor's Hours in Clinics (doctorReceptionHours) -------------------
SELECT DISTINCT
xd.deptCode,
Dept.deptName,
deptEmployeeReception.receptionID,
xd.EmployeeID,
deptEmployeeReception.receptionDay,
vReceptionDaysForDisplay.ReceptionDayName, 

'openingHour' = 
	CASE closingHour 
		WHEN '00:00' THEN	
			CASE openingHour WHEN '00:01' THEN '24' WHEN '01:00' THEN '24' WHEN '00:00' THEN '24' ELSE openingHour END
		WHEN '23:59' THEN	
			CASE openingHour WHEN '00:01' THEN '24' WHEN '01:00' THEN '24' WHEN '00:00' THEN '24' ELSE openingHour END
		ELSE openingHour END,
'closingHour' =
	CASE closingHour 
		WHEN '00:00' THEN	
			CASE openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN '00:00' THEN 'שעות' ELSE closingHour END
		WHEN '23:59' THEN	
			CASE openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN '00:00' THEN 'שעות' ELSE closingHour END
		ELSE closingHour END,
deptEmployeeReception.closingHour,
'receptionRemarks' = dbo.fun_GetEmployeeRemarksForReception(deptEmployeeReception.receptionID),
'professions' = dbo.fun_GetProfessionsForEmployeeReception(deptEmployeeReception.receptionID),
'services' = dbo.fun_GetServicesForEmployeeReception(deptEmployeeReception.receptionID),
'willExpireIn' = DATEDIFF(day, getdate(), IsNull(validTo,'01/01/2050')),
'expirationDate' = validTo

FROM deptEmployeeReception
INNER JOIN vReceptionDaysForDisplay ON deptEmployeeReception.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode
INNER JOIN x_Dept_Employee xd ON deptEmployeeReception.DeptEmployeeID = xd.DeptEmployeeID
INNER JOIN dept ON xd.deptCode = dept.deptCode
LEFT JOIN DeptEmployeeReceptionServices ders ON deptEmployeeReception.ReceptionID = ders.ReceptionID
LEFT JOIN x_dept_employee_service xdes ON ders.ServiceCode = xdes.ServiceCode
WHERE xd.employeeID = @employeeID
AND (
		(   
			((validFrom IS not NULL and  validTo IS NULL) and (getDate() >= validFrom ))			
			or ((validFrom IS NULL and validTo IS not NULL) and validTo >= getDate())
			or ((validFrom IS not NULL and  validTo IS not NULL) and (getDate() >= validFrom and validTo >= getDate()))
		)
		OR (validFrom IS NULL AND validTo IS NULL)
	)
AND disableBecauseOfOverlapping <> 1		
AND (ders.ReceptionID IS NULL OR xdes.Status = 1)
ORDER BY receptionDay,openingHour,xd.deptCode


-- doctor closest reception add date
SELECT MIN(ValidFrom)
FROM deptEmployeeReception der
INNER JOIN vReceptionDaysForDisplay on der.receptionDay = ReceptionDayCode
INNER JOIN x_Dept_Employee xd ON der.DeptEmployeeID = xd.DeptEmployeeID
WHERE xd.EmployeeID = @employeeID
AND disableBecauseOfOverlapping <> 1
AND DATEDIFF(dd, ValidFrom, GETDATE()) < 0
AND DATEDIFF(dd, ValidFrom, GETDATE()) >= -14


-------- "doctorProfessionsAndServicesForReception"
Select *,
'ReceptionDaysInDept' = (Select count(*) 
							FROM deptEmployeeReception as dER2
							LEFT JOIN deptEmployeeReceptionServices as dERs2 ON dER2.receptionID = dERs2.receptionID
							WHERE dER2.DeptEmployeeID = tbl.DeptEmployeeID AND tbl.professionOrServiceCode = ders2.ServiceCode
						 )
FROM ( 



SELECT xd.EmployeeID, 
dER.receptionID,
xd.deptCode,
xd.DeptEmployeeID,
ders.serviceCode as professionOrServiceCode,
[Services].ServiceDescription as professionOrServiceDescription,
dER.receptionDay,
vReceptionDaysForDisplay.ReceptionDayName,
dER.openingHour,
dER.closingHour,
'receptionRemarks' = dbo.fun_GetEmployeeRemarksForReception(dER.receptionID)   
FROM deptEmployeeReception as dER
LEFT JOIN deptEmployeeReceptionServices as dERs ON dER.receptionID = dERs.receptionID
INNER JOIN x_Dept_Employee xd ON dER.DeptEmployeeID = xd.DeptEmployeeID
LEFT JOIN [Services] ON dERs.serviceCode = [Services].ServiceCode
INNER JOIN vReceptionDaysForDisplay on dER.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode
WHERE xd.EmployeeID = @employeeID
AND (
      (validFrom is null OR getDate() >= validFrom )
      and 
      (validTo is null OR validTo>=getDate()) 
      )

AND disableBecauseOfOverlapping <> 1
) as tbl 
ORDER BY ReceptionDaysInDept DESC, ProfessionOrserviceCode, ReceptionDay, OpeningHour

------- "doctorUpdateDate" ---------------
SELECT
MAX(updateDate) AS employeeUpdateDate
FROM Employee 
WHERE employeeID = @employeeID

------- Last UpdateDate of Doctors in Clinic ---------------
SELECT 
MAX(updateDate) AS x_dept_employeeUpdateDate
FROM x_dept_employee
WHERE x_dept_employee.employeeID = @employeeID

------- Last UpdateDate of Doctor receptions ---------------
SELECT 
MAX(der.updateDate) AS employeeReceptionUpdateDate
FROM deptEmployeeReception der
INNER JOIN x_Dept_Employee xd ON der.DeptEmployeeID = xd.DeptEmployeeID
WHERE xd.EmployeeID = @employeeID
AND (
		(   
			((validFrom IS not NULL and  validTo IS NULL) and (getDate() >= validFrom ))			
			or ((validFrom IS NULL and validTo IS not NULL) and validTo >= getDate())
			or ((validFrom IS not NULL and  validTo IS not NULL) and (getDate() >= validFrom and validTo >= getDate()))
	
		)
		OR (validFrom IS NULL AND validTo IS NULL)
	)
	

------ doctorRemarks (Employee remarks) -------------

--using  View_DeptEmployee_EmployeeRemarks includes EmployeeRemarks  per dept 
-- and EmployeeRemarks Attributed ToAll Clinics InCommunity, ..InMushlam, ..InHospitals 
-- according to Dept Membership Type
SELECT distinct
v_DE_ER.EmployeeRemarkID,
v_DE_ER.EmpRemarkDeptCode as DeptCode,
v_DE_ER.RemarkTextFormated as RemarkText,
case when (v_DE_ER.EmpRemarkDeptCode = 0) then 1 else 0 end as AttributedToAllClinics,
v_DE_ER.displayInInternet

from View_DeptEmployee_EmployeeRemarks as v_DE_ER
		where v_DE_ER.EmployeeID = @EmployeeID
		AND (v_DE_ER.ValidFrom is null OR DATEDIFF(dd, v_DE_ER.ValidFrom ,getdate()) >= 0)
		AND (v_DE_ER.ValidTo is null OR DATEDIFF(dd, v_DE_ER.ValidTo ,getdate()) <= 0)
		and(v_DE_ER.EmpRemarkDeptCode > 0
		or v_DE_ER.AttributedToAllClinicsInCommunity = 1)

------ "clinicsForRemarks" 

--using  View_DeptEmployee_EmployeeRemarks includes EmployeeRemarks  per dept 
-- and EmployeeRemarks Attributed ToAll Clinics InCommunity, ..InMushlam, ..InHospitals 
-- according to Dept Membership Type
SELECT distinct
case when (v_DE_ER.EmpRemarkDeptCode > 0) 
	then 0 else 1 end as remarkIsGlobal,
v_DE_ER.EmpRemarkDeptCode as DeptCode,
case when (v_DE_ER.EmpRemarkDeptCode > 0)
	then Dept.deptName else 'כל היחידות' end as deptName

from View_DeptEmployee_EmployeeRemarks as v_DE_ER
left JOIN dept ON v_DE_ER.EmpRemarkDeptCode = dept.DeptCode
		where v_DE_ER.EmployeeID = @EmployeeID
		AND (v_DE_ER.ValidFrom is null OR DATEDIFF(dd, v_DE_ER.ValidFrom ,getdate()) >= 0)
		AND (v_DE_ER.ValidTo is null OR DATEDIFF(dd, v_DE_ER.ValidTo ,getdate()) <= 0)
		and(v_DE_ER.EmpRemarkDeptCode > 0
		or v_DE_ER.AttributedToAllClinicsInCommunity = 1)
ORDER BY remarkIsGlobal DESC


------- EmployeeQueueOrderMethods (Employee Queue Order Methods) --------------
SELECT 
EmployeeQueueOrderMethod.QueueOrderMethodID,
EmployeeQueueOrderMethod.QueueOrderMethod,
xd.deptCode,
xd.employeeID,
DIC_QueueOrderMethod.QueueOrderMethodDescription,
DIC_QueueOrderMethod.ShowPhonePicture,
DIC_QueueOrderMethod.SpecialPhoneNumberRequired

FROM EmployeeQueueOrderMethod
INNER JOIN DIC_QueueOrderMethod ON EmployeeQueueOrderMethod.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
INNER JOIN x_Dept_Employee xd ON EmployeeQueueOrderMethod.DeptEmployeeID = xd.DeptEmployeeID
WHERE xd.employeeID = @EmployeeID
ORDER BY QueueOrderMethod

------- HoursForEmployeeQueueOrder (Hours for Employee Queue Order via Phone) --------------
SELECT
xd.deptCode,
xd.employeeID,
EmployeeQueueOrderHoursID,
EmployeeQueueOrderHours.QueueOrderMethodID,
EmployeeQueueOrderHours.receptionDay,
ReceptionDayName,
FromHour,
ToHour
FROM EmployeeQueueOrderHours
INNER JOIN vReceptionDaysForDisplay ON EmployeeQueueOrderHours.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode
INNER JOIN EmployeeQueueOrderMethod eqom ON EmployeeQueueOrderHours.QueueOrderMethodID = eqom.QueueOrderMethodID
INNER JOIN x_Dept_Employee xd ON eqom.DeptEmployeeID = xd.DeptEmployeeID
WHERE xd.employeeID = @EmployeeID
ORDER BY vReceptionDaysForDisplay.ReceptionDayCode, FromHour



GO


GRANT EXEC ON dbo.rpc_DoctorOverView TO PUBLIC
GO
-- ***************************************
-- *** Internet views
/*
1.	דוח שעות פעילות ביחידות:
הדוח יכלול נתוני יחידות פעילות מסוג:
בית מרקחת,יחידה במרפאה,מוקד רפואה דחופה,מכון התפתחות הילד,מכון פיזיותרפיה
,מכון קרדיולוגי,מכון ריפוי בעיסוק,מכון רנטגן/הדמיה,מכון רפואי
,מכון שמיעה ודיבור,מרכז בריאות האישה,מרכז בריאות הילד,מרכז בריאות הנפש
,מרפאה באוניברסיטה,מרפאה יועצת,מרפאה כפרית,מרפאה למטייל
,מרפאה משולבת,מרפאה ראשונית,מרפאת אסתטיקה,מרפאת ספורט
,מרפאת רפואה משלימה,מרפאת שיניים,רופא עצמאי 
ובתנאי שהן אינן מסומנות לא לתצוגה באינטרנט. יופיעו גם מרפאות שאין להן שעות פעילות ביחידה
השדות:
שם יחידה, סוג יחידה, שיוך, קוד סימול, כתובת, הערה לכתובת, טלפון 1, טלפון 2, יום, משעה, עד שעה, הערה לשעות
-----------------------------------------------------

select * from UnitType u
where u.UnitTypeName in ('בית מרקחת','יחידה במרפאה','מוקד רפואה דחופה','מכון התפתחות הילד',
'מכון פיזיותרפיה','מכון קרדיולוגי','מכון ריפוי בעיסוק','מכון רנטגן/הדמיה',
'מכון רפואי','מכון שמיעה ודיבור','מרכז בריאות האישה','מרכז בריאות הילד',
'מרכז בריאות הנפש','מרפאה באוניברסיטה','מרפאה יועצת','מרפאה כפרית',
'מרפאה למטייל','מרפאה משולבת','מרפאה ראשונית','מרפאת אסתטיקה',
'מרפאת ספורט','מרפאת רפואה משלימה','מרפאת שיניים','רופא עצמאי')

*/

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[VMobileDeptReception]'))
	DROP VIEW [dbo].VMobileDeptReception
GO


CREATE VIEW [dbo].VMobileDeptReception  
AS  
select d.deptCode as 'DeptCode',--'קוד סימול', 
		d.deptName as 'DeptName', --'שם יחידה', 
		ut.UnitTypeName as 'DeptType', -- 'סוג יחידה', 
		sut.subUnitTypeName 'DeptSubType',--'שיוך', 
		dbo.GetAddress(d.deptCode) as 'Address',-- 'הערה לכתובת' + 'כתובת', 
		--d.addressComment as 'הערה לכתובת',
		dbo.GetDeptPhoneNumber(d.deptCode, 1, 1) as 'Phone1', -- 'טלפון 1',
		dbo.GetDeptPhoneNumber(d.deptCode, 1, 2) as 'Phone2', -- 'טלפון 2',
		rd.ReceptionDayName as 'ReceptionDay', --'יום',
		dr.openingHour as 'OpeningHour', -- 'משעה', 
		dr.closingHour as 'ClosingHour', -- 'עד שעה',
		drr.RemarkText as 'ReceptionRemark' -- 'הערה לשעות'
from Dept d
join UnitType ut
on d.typeUnitCode = ut.UnitTypeCode
left join DIC_SubUnitTypes sut
on d.subUnitTypeCode = sut.subUnitTypeCode
left join DeptReception dr
on dr.deptCode = d.deptCode
and dr.ReceptionHoursTypeID = 1
left join DIC_ReceptionDays rd
on dr.receptionDay = rd.ReceptionDayCode
left join DeptReceptionRemarks drr
on dr.ReceptionID = drr.ReceptionID
where d.status = 1
and d.showUnitInInternet = 1
and d.typeUnitCode in (101, 102, 103, 104, 107, 111, 112, 114, 115, 202, 203, 204, 205, 207, 208, 212, 301, 303, 401, 501, 502, 503, 917, 918)
--order by d.deptCode, dr.receptionDay

GO

GRANT SELECT ON [dbo].VMobileDeptReception TO [public] AS [dbo]
GO
---------------------
/*
2.	דוח שעות פעילות נותני שירות ביחידות:
הדוח יכלול נותני שירות פעילים מסקטור רופאים ביחידות מסוג:
מרכז בריאות האישה,מרכז בריאות הילד
,מרכז בריאות הנפש,מרפאה באוניברסיטה,מרפאה יועצת,מרפאה כפרית
,מרפאה משולבת,מרפאה ראשונית,מרפאת שיניים,רופא עצמאי
ובתנאי שאינם מסוג: צוות רפואי/מרפאה. יופיעו גם רופאים שאין להם שעות פעילות ביחידה
השדות:
שם יחידה, קוד סימול, ת.ז נותן שירות, רשיון רופא, תואר,
שם פרטי, שם משפחה, מגדר, תחום שירות,
יום, משעה, עד שעה, הערה לשעות,
טלפון נותן שירות ביחידה
----------------------------------------------------------

select * from UnitType u
where u.UnitTypeName in ('מרכז בריאות האישה','מרכז בריאות הילד'
,'מרכז בריאות הנפש','מרפאה באוניברסיטה','מרפאה יועצת','מרפאה כפרית'
,'מרפאה משולבת','מרפאה ראשונית','מרפאת שיניים','רופא עצמאי')

*/


IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[VMobileEmployeeReception]'))
	DROP VIEW [dbo].VMobileEmployeeReception
GO


CREATE VIEW [dbo].VMobileEmployeeReception  
AS  
select d.deptCode as 'DeptCode',--'קוד סימול', 
		d.deptName as 'DeptName', --'שם יחידה'
		e.employeeID as 'EmployeeID',
		e.licenseNumber as 'LicenseNumber',
		ed.DegreeName as 'Degree',
		e.firstName as 'FirstName',
		e.lastName as 'LastName',
		g.sexDescription as 'Sex',
		s.ServiceDescription as 'Service',
		rd.ReceptionDayName as 'ReceptionDay', --'יום'
		der.openingHour as 'OpeningHour', -- 'משעה'
		CASE WHEN der.closingHour NOT like '%:%' AND der.closingHour is NOT null
				THEN LEFT(der.closingHour, 2) + ':' + RIGHT(der.closingHour, 2) 
				ELSE der.closingHour END as 'ClosingHour', -- 'עד שעה'
		drr.RemarkText as 'ReceptionRemark' -- 'הערה לשעות'		
from x_Dept_Employee xde
join Dept d
on xde.deptCode = d.deptCode
join Employee e
on xde.employeeID = e.employeeID
and e.IsMedicalTeam = 0 -- Not a medical team
left join DIC_EmployeeDegree ed
on e.degreeCode = ed.DegreeCode
left join DIC_Gender g
on e.sex = g.sex
left join x_Dept_Employee_Service xdes
on xde.DeptEmployeeID = xdes.DeptEmployeeID
left join deptEmployeeReception der
on der.DeptEmployeeID = xde.DeptEmployeeID
left join DIC_ReceptionDays rd
on der.receptionDay = rd.ReceptionDayCode
left join DeptEmployeeReceptionRemarks drr
on der.receptionID = drr.EmployeeReceptionID
left join deptEmployeeReceptionServices ders
on der.receptionID = ders.receptionID
and xdes.serviceCode = ders.serviceCode
left join Services s
on xdes.serviceCode = s.ServiceCode
where d.status = 1
and e.active = 1
and e.EmployeeSectorCode = 7 -- Doctor
and d.typeUnitCode in (101, 102, 103, 104, 107, 111, 112, 501, 502, 503)
--order by d.deptCode, xde.employeeID, der.receptionDay


GO

GRANT SELECT ON [dbo].VMobileEmployeeReception TO [public] AS [dbo]
GO
-------------------------
/****** Object:  View [dbo].[VFastDeptServiceShift]    Script Date: 10/04/2011 16:06:35 ******/
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'VFastDeptServiceShift')
	DROP VIEW [dbo].[VFastDeptServiceShift]
GO

/*
	שולף את החלוקה למשמרות עבור שעות קבלה של שירותים בכל היחידה 
	Owner : Internet Team
*/
CREATE view [dbo].[VFastDeptServiceShift]    
as    
select     
	stuff(case when MAX(shifts&1)=1 then ';בוקר' else '' end    
			+case when MAX(shifts&2)=2 then ';צהריים' else '' end    
			+case when MAX(shifts&4)=4 then ';ערב' else '' end    
			+case when MAX(shifts&8)=8 then ';לילה' else '' end,1,1,''
	) shift    
	,deptCode
	,servicecode    
	from (select '' + 
			case when (openingDateHour between '1900-01-01 06:00' and '1900-01-01 12:00')     
					or (closingDateHour between '1900-01-01 06:00' and '1900-01-01 12:00')     
					or (openingDateHour<'1900-01-01 06:00' and closingDateHour>'1900-01-01 12:00')    
			then 1 else 0 end +    
			case when (openingDateHour between '1900-01-01 12:01' and '1900-01-01 16:00')     
					or (closingDateHour between '1900-01-01 12:01' and '1900-01-01 16:00')     
					or (openingDateHour<'1900-01-01 12:01' and closingDateHour>'1900-01-01 16:00')    
			then 2 else 0 end +    
			case when (openingDateHour between '1900-01-01 16:01' and '1900-01-01 22:00')     
					or (closingDateHour between '1900-01-01 16:01' and '1900-01-01 22:00')     
					or (openingDateHour<'1900-01-01 16:01' and closingDateHour>'1900-01-01 22:00')    
			then 4 else 0 end +    
			(case when (openingDateHour between '1900-01-01 22:01' and '1900-01-02 00:00')     
				or (closingDateHour between  '1900-01-01 22:01' and '1900-01-02 00:00')     
				or (openingDateHour<'1900-01-01 22:01' and closingDateHour>'1900-01-02 00:00')    
			then 8 else 0 end    
			|    
			case when (openingDateHour between '1900-01-01 00:00' and '1900-01-01 05:59')     
				or (closingDateHour between  '1900-01-01 00:00' and '1900-01-01  05:59')     
				or (openingDateHour<'1900-01-01 00:00' and closingDateHour>'1900-01-01  05:59')    
			then 8 else 0 end 
		) shifts
		,deptCode
		,servicecode
		,openingDateHour
		,closingDateHour
		from (select	cast(openingDateHour as datetime) openingDateHour,    
						cast(closingDateHour  as datetime) + case when cast(openingDateHour as datetime)>=cast(closingDateHour  as datetime) then 1 else 0 end closingDateHour    
						,deptCode
						,servicecode    
				from (select	REPLACE(openingHour,'24:','00:') openingDateHour
								,REPLACE(closingHour,'24:','00:') closingDateHour
								,deptCode
								,ders.serviceCode    
						from deptEmployeeReception der
						join deptEmployeeReceptionServices ders
						on der.receptionID = ders.receptionID
						join x_Dept_Employee xde 
						on der.DeptEmployeeID = xde.DeptEmployeeID
						join x_Dept_Employee_Service xdes
						on xde.DeptEmployeeID = xdes.DeptEmployeeID
						and ders.serviceCode = xdes.serviceCode
						join Employee e
						on xde.employeeID = e.employeeID
						and e.IsMedicalTeam = 1
						where  GETDATE() between ISNULL(der.validFrom,'1900-01-01') and ISNULL(der.validTo,'2079-01-01')  
				) deptservicereception    
		)deptservicereception    
	) deptservicereception    
group by deptCode,servicecode    
    
     
GO

GRANT SELECT ON [dbo].[VFastDeptServiceShift] TO [public] AS [dbo]
GO

------------------
/****** Object:  View [dbo].[VFastDeptShift]    Script Date: 10/04/2011 16:06:47 ******/
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'VFastDeptShift')
	DROP VIEW [dbo].[VFastDeptShift]
GO


/*
	שולף את החלוקה למשמרות עבור שעות קבלה לכל יחידה 
	Owner : Internet Team
*/
CREATE view [dbo].[VFastDeptShift]    
as    

select     
	stuff(case when MAX(shifts&1)=1 then ';בוקר' else '' end    
		+case when MAX(shifts&2)=2 then ';צהריים' else '' end    
		+case when MAX(shifts&4)=4 then ';ערב' else '' end    
		+case when MAX(shifts&8)=8 then ';לילה' else '' end,1,1,''
	) shift    
	,deptCode     
	from (select ''+    
		case when (openingDateHour between '1900-01-01 06:00' and '1900-01-01 12:00')     
				or (closingDateHour between '1900-01-01 06:00' and '1900-01-01 12:00')     
				or (openingDateHour<'1900-01-01 06:00' and closingDateHour>'1900-01-01 12:00')    
		then 1 else 0 end +    
		case when (openingDateHour between '1900-01-01 12:01' and '1900-01-01 16:00')     
				or (closingDateHour between '1900-01-01 12:01' and '1900-01-01 16:00')     
				or (openingDateHour<'1900-01-01 12:01' and closingDateHour>'1900-01-01 16:00')    
		then 2 else 0 end +    
		case when (openingDateHour between '1900-01-01 16:01' and '1900-01-01 22:00')     
				or (closingDateHour between '1900-01-01 16:01' and '1900-01-01 22:00')     
				or (openingDateHour<'1900-01-01 16:01' and closingDateHour>'1900-01-01 22:00')    
		then 4 else 0 end +    
		(case when (openingDateHour between '1900-01-01 22:01' and '1900-01-02 00:00')     
				or (closingDateHour between  '1900-01-01 22:01' and '1900-01-02 00:00')     
				or (openingDateHour<'1900-01-01 22:01' and closingDateHour>'1900-01-02 00:00')    
		then 8 else 0 end 
		|    
		case when (openingDateHour between '1900-01-01 00:00' and '1900-01-01 05:59')     
				or (closingDateHour between  '1900-01-01 00:00' and '1900-01-01  05:59')     
				or (openingDateHour<'1900-01-01 00:00' and closingDateHour>'1900-01-01  05:59')    
		then 8 else 0 end 
		)  shifts
		,deptCode
		,openingDateHour
		,closingDateHour    
		from (select cast(openingDateHour as datetime) openingDateHour
					,cast(closingDateHour as datetime) + case when cast(openingDateHour as datetime)>=cast(closingDateHour as datetime) then 1 else 0 end closingDateHour    
					,deptCode    
					from (select REPLACE(openingHour,'24:','00:') openingDateHour
								,REPLACE(closingHour,'24:','00:') closingDateHour,deptCode, RemarkID
								from DeptReception  
								left join DeptReceptionRemarks
								on DeptReception.receptionID = DeptReceptionRemarks.ReceptionID
								where GETDATE() between ISNULL(deptreception.validFrom,'1900-01-01') and ISNULL(deptreception.validTo,'2079-01-01')
								and (DeptReceptionRemarks.RemarkID is null or DeptReceptionRemarks.RemarkID <> 72) -- ישיבת צוות
								and DeptReception.ReceptionHoursTypeID = 1 -- שעות קבלה
					) deptreception    
		) deptreception    
	) deptreception    
group by deptCode    

GO


GRANT SELECT ON [dbo].[VFastDeptShift] TO [public] AS [dbo]
GO
---------------------------------
/****** Object:  View [dbo].[VFastDeptEmployeeProfessionShift]    Script Date: 10/24/2011 11:28:46 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[VFastDeptEmployeeProfessionShift]'))
DROP VIEW [dbo].[VFastDeptEmployeeProfessionShift]
GO

CREATE view [dbo].[VFastDeptEmployeeProfessionShift]    
as    
	select stuff(case when MAX(shifts&1)=1 then ';בוקר' else '' end    
				+case when MAX(shifts&2)=2 then ';צהריים' else '' end    
				+case when MAX(shifts&4)=4 then ';ערב' else '' end    
				+case when MAX(shifts&8)=8 then ';לילה' else '' end,1,1,''
			) shift
			,DeptEmployeeID
			,ServiceCode
			from (select '' + 
					case when (openingDateHour between '1900-01-01 06:00' and '1900-01-01 12:00')     
							or (closingDateHour between '1900-01-01 06:00' and '1900-01-01 12:00')     
							or (openingDateHour<'1900-01-01 06:00' and closingDateHour>'1900-01-01 12:00')    
					then 1 else 0 end +    
					case when (openingDateHour between '1900-01-01 12:01' and '1900-01-01 16:00')     
							or (closingDateHour between '1900-01-01 12:01' and '1900-01-01 16:00')     
							or (openingDateHour<'1900-01-01 12:01' and closingDateHour>'1900-01-01 16:00')    
					then 2 else 0 end + 
					case when (openingDateHour between '1900-01-01 16:01' and '1900-01-01 22:00')     
							or (closingDateHour between '1900-01-01 16:01' and '1900-01-01 22:00')     
							or (openingDateHour<'1900-01-01 16:01' and closingDateHour>'1900-01-01 22:00')    
					then 4 else 0 end + 
					(case when (openingDateHour between '1900-01-01 22:01' and '1900-01-02 00:00')     
							or (closingDateHour between  '1900-01-01 22:01' and '1900-01-02 00:00')     
							or (openingDateHour<'1900-01-01 22:01' and closingDateHour>'1900-01-02 00:00')    
					then 8 else 0 end    
					|    
					case when (openingDateHour between '1900-01-01 00:00' and '1900-01-01 05:59')     
							or (closingDateHour between  '1900-01-01 00:00' and '1900-01-01  05:59')     
							or (openingDateHour<'1900-01-01 00:00' and closingDateHour>'1900-01-01  05:59')    
					then 8 else 0 end 
					) shifts
					,DeptEmployeeID
					,ServiceCode
					,openingDateHour
					,closingDateHour    
					from (select cast(openingDateHour as datetime) openingDateHour    
								,cast(closingDateHour  as datetime) + case when cast(openingDateHour as datetime)>=cast(closingDateHour  as datetime) then 1 else 0 end closingDateHour    
								,DeptEmployeeID
								,ServiceCode  
							from (select REPLACE(openingHour,'24:','00:') openingDateHour
										,REPLACE(closingHour,'24:','00:') closingDateHour
										,DeptEmployeeID
										,ServiceCode
										from (SELECT  DeptEmployeeID, ders.serviceCode ,openingHour,closingHour,validFrom,validTo
												FROM DeptEmployeeReception der
												INNER JOIN deptEmployeeReceptionServices ders
												ON der.receptionID = ders.receptionID
												INNER JOIN Services s
												on ders.serviceCode = s.ServiceCode
												and s.IsProfession = 1 -- רוצים לקבל רק מקצועות, ללא שירותים
										) deptservicereception  
										where  GETDATE() between ISNULL(deptservicereception.validFrom,'1900-01-01') and ISNULL(deptservicereception.validTo,'2079-01-01')  
							) deptservicereception    
					) deptservicereception    
			) deptservicereception    
group by DeptEmployeeID,ServiceCode

GO


GRANT SELECT ON [dbo].[VFastDeptEmployeeProfessionShift] TO [public] AS [dbo]
GO


------------------------------------------
/****** Object:  View [dbo].[VFastDept]    Script Date: 11/06/2011 08:47:48 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[VFastDept]'))
	DROP VIEW [dbo].[VFastDept]
GO

/*
	Select all Depts data that needed for Fast engine 
	Owner : Internet Team
*/
CREATE view [dbo].[VFastDept]        
as   

SELECT uniqueKey, deptCode, deptName, cityCode, cityName, StreetName, house, flat, 
		entrance, floor, parkingInClinic, addresscomment, typeUnitCode, UnitTypeName, 
		administrationCode, SubAdministrationCode, showUnitInInternet, ShowInInternet, 
		email, IsCommunity, IsMushlam, IsHospital, deptType, deptLevel, deptLevelDescription, 
		subUnitTypeCode, subUnitTypeName, managerName, administrativemanagerName, FacilityDescription, 
		FacilityDescription as FacilityDescriptionList,
		Transportation, DeptRemarks, updatedate, phones, ReceptionHours, shift, serviceCode, 
		replace(serviceDescription,'"','``') serviceDescription, 
		isInCommunity, isInMushlam, IsInHospitals, DeptServiceRemarks, 
		CASE WHEN showPhonesFromDept=1 THEN phones else servicePhones END servicePhones, 
		ServiceReceptionHours, Serviceshift, showPhonesFromDept, ReceptionServiceHours, 
		ServiceQueueOrders,	replace(ServiceList,'"','``') ServiceList, DeptDistinct
	FROM
	(select 
		ISNULL(right('0000000'+cast(dept.deptCode as varchar(20)),7)+right('0000000'+cast(ISNULL(services.serviceCode,'') as varchar(20)),7),'0') uniqueKey        
		,dept.deptCode  
		,dept.deptName        
		,dept.cityCode        
		,cities.cityName        
		,dept.StreetName        
		,dept.house        
		,dept.flat        
		,dept.entrance        
		,dept.floor        
		,dept.addresscomment        
		,dept.typeUnitCode        
		,UnitType.UnitTypeName   
		,dept.administrationCode 
		,dept.SubAdministrationCode  
		,dept.showUnitInInternet
		,UnitType.ShowInInternet
		,CASE WHEN dept.showEmailInInternet=1 THEN dept.email ELSE '' END email
		,dept.IsCommunity
		,dept.IsMushlam
		,dept.IsHospital
		,dept.deptType
		,dept.deptLevel
		,DIC_deptLevel.deptLevelDescription
		,dept.subUnitTypeCode
		,DIC_SubUnitTypes.subUnitTypeName
		,DIC_ParkingInClinic.parkingInClinicDescription as parkingInClinic
		,ISNULL((SELECT TOP 1 DegreeName + ' ' + lastName + ' ' + firstName
					from employee  
					INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode  
					INNER JOIN x_dept_employee ON employee.employeeID = x_dept_employee.employeeID  
					INNER JOIN x_Dept_Employee_Position ON x_dept_employee.DeptEmployeeID = x_Dept_Employee_Position.DeptEmployeeID  
					and x_Dept_Employee.deptCode = dept.deptCode
					INNER JOIN mappingPositions ON x_Dept_Employee_Position.positionCode = mappingPositions.positionCode  
					WHERE mappingPositions.mappedToManager = 1 AND employee.active<>0 AND x_dept_employee.active<>0
					and dept.showUnitInInternet =1 and UnitType.ShowInInternet=1
				) ,dept.managerName 
		) managerName  
		,ISNULL((SELECT TOP 1 DegreeName + ' ' + lastName + ' ' + firstName  
					from employee  
					INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode  
					INNER JOIN x_dept_employee ON employee.employeeID = x_dept_employee.employeeID  
					INNER JOIN x_Dept_Employee_Position ON x_dept_employee.DeptEmployeeID = x_Dept_Employee_Position.DeptEmployeeID  
					and x_Dept_Employee.deptCode = dept.deptCode
					INNER JOIN mappingPositions ON x_Dept_Employee_Position.positionCode = mappingPositions.positionCode  
					WHERE mappingPositions.mappedToAdministrativeManager = 1 AND employee.active<>0 AND x_dept_employee.active<>0
					and dept.showUnitInInternet =1 and UnitType.ShowInInternet=1 
				) ,dept.administrativemanagerName 
		) administrativemanagerName   
		,case when 0 < (select count(*) from DeptHandicappedFacilities 
						join DIC_HandicappedFacilities
						on DeptHandicappedFacilities.FacilityCode = DIC_HandicappedFacilities.FacilityCode
						and DIC_HandicappedFacilities.Active = 1
						where DeptHandicappedFacilities.DeptCode=dept.deptCode) then 
			 stuff((select ';'+DIC_HandicappedFacilities.FacilityDescription         
					from dbo.DeptHandicappedFacilities        
					inner join dbo.DIC_HandicappedFacilities        
					on  DIC_HandicappedFacilities.FacilityCode=DeptHandicappedFacilities.FacilityCode        
					where DeptHandicappedFacilities.DeptCode=dept.deptCode and DIC_HandicappedFacilities.active=1       
					for xml path('')),1,1,'')
			else 'ללא' end 
		FacilityDescription        
		,(SELECT REPLACE( dept.Transportation,'#','')) Transportation
		,(SELECT dbo.rfn_GetFotmatedRemark(View_DeptRemarks.RemarkText) RemarkText
		  	   ,View_DeptRemarks.ShowOrder
			FROM View_DeptRemarks WHERE dept.deptCode=View_DeptRemarks.deptCode 
			and  GETDATE() between ISNULL(View_DeptRemarks.validFrom,'1900-01-01') and ISNULL(View_DeptRemarks.validTo,'2079-01-01')
			AND View_DeptRemarks.displayInInternet =CAST(1 AS BIT) 
			FOR XML PATH ('Remark'),ROOT('Remarks'),type 
		) DeptRemarks
		,dept.updatedate      
		,(select  DIC_PhoneTypes.PhoneTypeName [Type]        
				 ,case when DeptPhones.Preprefix = 2 
					   then '*' else CONVERT(varchar(10), DeptPhones.Preprefix) end as  Preprefix       
				 ,DIC_PhonePrefix.prefixValue Prefix       
				 ,DeptPhones.Phone Number        
				 ,DeptPhones.PhoneOrder [Order]        
				 ,DeptPhones.UpdateDate UpdateDate        
			from   dbo.deptPhones        
			inner join dbo.DIC_PhoneTypes        
			on DIC_PhoneTypes.phoneTypeCode=deptPhones.phoneType
			left join dbo.DIC_PhonePrefix   
			on DIC_PhonePrefix.prefixCode=deptPhones.prefix 
			where dept.deptCode=deptPhones.DeptCode for xml path('Phone'),root('Phones'),type        
		) phones
		,(select receptiondayName Day, receptionDay DayCode,    
				(select OpeningHour 
						,ClosingHour
						,(select RemarkText         
							from DeptReceptionRemarks where DpRec.receptionID=DeptReceptionRemarks.ReceptionID   
							and  GETDATE() between ISNULL(DeptReceptionRemarks.validFrom,'1900-01-01') and ISNULL(deptreceptionremarks.validTo,'2079-01-01')  
							AND ISNULL(deptreceptionremarks.DisplayInInternet, 0) = CAST(1 AS BIT)
							for XML path ('Remark'),type)
					from DeptReception DpRec   
					left join DeptReceptionRemarks 
					on DpRec.ReceptionID = DeptReceptionRemarks.ReceptionID
					where DpRec.deptCode=Gdays.Deptcode and DpRec.receptionDay=Gdays.receptionDay  
					and DpRec.ReceptionHoursTypeID = 1 -- שעות קבלה
					and GETDATE() between ISNULL(DpRec.validFrom,'1900-01-01') and ISNULL(DpRec.validTo,'2079-01-01')     
					and (DeptReceptionRemarks.RemarkID is null or DeptReceptionRemarks.RemarkID <> 72) -- ישיבת צוות
					order by DpRec.receptionDay, DpRec.openingHour
					for XML path('Reception'),type) 
			from (select distinct Deptcode
						,receptiondayName
						,receptionDay 
					from dbo.DeptReception        
					inner join  dbo.DIC_ReceptionDays        
					on DIC_ReceptionDays.receptiondayCode=DeptReception.receptionDay         
					where dept.Deptcode = DeptReception.deptCode  
					and DeptReception.ReceptionHoursTypeID = 1 -- שעות קבלה
					and GETDATE() between ISNULL(deptreception.validFrom,'1900-01-01') and ISNULL(deptreception.validTo,'2079-01-01')  
				) Gdays 
			for XML path ('DayInfo'),root('ReceptionHours'),type        
		) ReceptionHours
		,VFastDeptShift.shift as shift
		,ISNULL(x_Dept_Employee_Service.serviceCode,0) serviceCode
		,services.serviceDescription
		,ISNULL(services.isInCommunity, 0) isInCommunity
		,ISNULL(services.isInMushlam, 0) isInMushlam
		,ISNULL(services.IsInHospitals, 0) IsInHospitals
		,(SELECT REPLACE(DeptEmployeeServiceRemarks.RemarkText,'#','') RemarkText	
			FROM DeptEmployeeServiceRemarks
			where x_Dept_Employee_Service.DeptEmployeeServiceRemarkID=DeptEmployeeServiceRemarks.DeptEmployeeServiceRemarkID 
			and GETDATE() between ISNULL(DeptEmployeeServiceRemarks.ValidFrom,'1900-01-01') and ISNULL(DeptEmployeeServiceRemarks.ValidTo,'2079-01-01')  
			AND DeptEmployeeServiceRemarks.displayInInternet=CAST(1 AS BIT)
			for XML path ('Remark'),root('Remarks'),type
		) DeptServiceRemarks
		,(select DIC_PhoneTypes.PhoneTypeName Type,        
				case when EmployeeServicePhones.Preprefix = 2 then '*' 
					 else CONVERT(varchar(10), EmployeeServicePhones.Preprefix) end as  Preprefix,
				DIC_PhonePrefix.prefixValue Prefix,        
				EmployeeServicePhones.Phone Number,        
				EmployeeServicePhones.PhoneOrder [Order],        
				EmployeeServicePhones.UpdateDate        
			from dbo.EmployeeServicePhones         
			inner join DIC_PhoneTypes         
			on DIC_PhoneTypes.phoneTypeCode=EmployeeServicePhones.phoneType  
			left join dbo.DIC_PhonePrefix   
			on DIC_PhonePrefix.prefixCode=EmployeeServicePhones.prefix
			where x_Dept_Employee_Service.x_Dept_Employee_ServiceID=EmployeeServicePhones.x_Dept_Employee_ServiceID  
			for xml path('Phone'),root('Phones'),type
		) servicePhones 
		,(select Gdays.ReceptionDayName Day, 
				Gdays.receptionDay DayCode,
				(select OpeningHour ,ClosingHour        
						,(select REPLACE(derr.RemarkText,'#','') RemarkText       
							from DeptEmployeeReceptionRemarks derr      
							where derr.EmployeeReceptionID= der2.receptionID     
							and GETDATE() between ISNULL(derr.ValidFrom,'1900-01-01') and ISNULL(derr.ValidTo,'2079-01-01')       
							for XML path ('Remark'),type )        
					from deptEmployeeReception der2          
					where der2.receptionID = Gdays.receptionID   
					and GETDATE() between ISNULL(der2.validFrom,'1900-01-01') and ISNULL(der2.validTo,'2079-01-01')      
					order by Gdays.receptionDay, OpeningHour
					for XML path('Reception'),type 
				)
			from
				(select distinct DIC_ReceptionDays.ReceptionDayName, der.ReceptionDay,
								der.receptionID,der.DeptEmployeeID        
				from deptEmployeeReception  der
				join deptEmployeeReceptionServices ders
				on der.receptionID = ders.receptionID
				and ders.serviceCode = x_Dept_Employee_Service.serviceCode
				join DIC_ReceptionDays
				on der.receptionDay = DIC_ReceptionDays.ReceptionDayCode
				where der.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
				and ders.serviceCode = x_Dept_Employee_Service.serviceCode
			) Gdays        
			order by receptionDay
			for XML path ('DayInfo'),root('ReceptionHours') ,type 
		) ServiceReceptionHours  
		,VFastDeptServiceShift.shift as Serviceshift   
		,ISNULL(x_Dept_Employee_Service.CascadeUpdateEmployeeServicePhones, 1) as showPhonesFromDept		
		,(select receptiondayName Day, receptionDay DayCode,    
				(select OpeningHour 
						,ClosingHour
						,(select RemarkText         
							from DeptReceptionRemarks where DpRec.receptionID=DeptReceptionRemarks.ReceptionID   
							and  GETDATE() between ISNULL(DeptReceptionRemarks.validFrom,'1900-01-01') and ISNULL(deptreceptionremarks.validTo,'2079-01-01')  
							AND deptreceptionremarks.DisplayInInternet=CAST(1 AS BIT)
							for XML path ('Remark'),type)
					from DeptReception DpRec   
					left join DeptReceptionRemarks 
					on DpRec.ReceptionID = DeptReceptionRemarks.ReceptionID
					where DpRec.deptCode=Gdays.Deptcode and DpRec.receptionDay=Gdays.receptionDay  
					and DpRec.ReceptionHoursTypeID = 2 -- שעות משרד
					and GETDATE() between ISNULL(DpRec.validFrom,'1900-01-01') and ISNULL(DpRec.validTo,'2079-01-01')     
					and (DeptReceptionRemarks.RemarkID is null or DeptReceptionRemarks.RemarkID <> 72) -- ישיבת צוות
					order by DpRec.receptionDay, DpRec.openingHour
					for XML path('Reception'),type) 
			from (select distinct Deptcode
						,receptiondayName
						,receptionDay 
					from dbo.DeptReception        
					inner join  dbo.DIC_ReceptionDays        
					on DIC_ReceptionDays.receptiondayCode=DeptReception.receptionDay         
					where dept.Deptcode = DeptReception.deptCode  
					and DeptReception.ReceptionHoursTypeID = 2 -- שעות משרד
					and GETDATE() between ISNULL(deptreception.validFrom,'1900-01-01') and ISNULL(deptreception.validTo,'2079-01-01')  
				) Gdays 
			order by receptionDay
			for XML path ('DayInfo'),root('ReceptionHours'),type        
		) ReceptionServiceHours
		,(SELECT DIC_QueueOrder.QueueOrder QueueOrderCode,DIC_QueueOrder.QueueOrderDescription QueueOrderDesc,
				(select DIC_QueueOrderMethod.QueueOrderMethod,DIC_QueueOrderMethod.QueueOrderMethodDescription,
						case when EmployeeServiceQueueOrderPhones.Preprefix = 2 then '*' 
							 else CONVERT(varchar(10), EmployeeServiceQueueOrderPhones.Preprefix) end as  PrePrefix,
						DIC_PhonePrefix.prefixValue Prefix,
						EmployeeServiceQueueOrderPhones.phone Phone,
						(select receptiondayName DAY        
						,(select DpRec.FromHour ,DpRec.ToHour
							from EmployeeServiceQueueOrderHours DpRec          
							where DpRec.EmployeeServiceQueueOrderMethodID=Gdays.EmployeeServiceQueueOrderMethodID 
							and DpRec.receptionDay=Gdays.receptionDay     
							for XML path('Reception'),type) 
						from (select distinct EmployeeServiceQueueOrderMethodID,receptiondayName,receptionDay 
								from dbo.EmployeeServiceQueueOrderHours        
								inner join  dbo.DIC_ReceptionDays        
								on DIC_ReceptionDays.receptiondayCode=dbo.EmployeeServiceQueueOrderHours.receptionDay         
								where EmployeeServiceQueueOrderHours.EmployeeServiceQueueOrderMethodID=dbo.EmployeeServiceQueueOrderMethod.EmployeeServiceQueueOrderMethodID
								) Gdays for XML path ('DayInfo'),root('ReceptionHours'),type  )
					FROM EmployeeServiceQueueOrderMethod 
					INNER JOIN dbo.DIC_QueueOrderMethod ON dbo.EmployeeServiceQueueOrderMethod.QueueOrderMethod = dbo.DIC_QueueOrderMethod.QueueOrderMethod
					LEFT JOIN dbo.EmployeeServiceQueueOrderPhones 
					ON EmployeeServiceQueueOrderPhones.EmployeeServiceQueueOrderMethodID = EmployeeServiceQueueOrderMethod.EmployeeServiceQueueOrderMethodID
					INNER JOIN dbo.DIC_PhonePrefix ON EmployeeServiceQueueOrderPhones.prefix = dbo.DIC_PhonePrefix.prefixCode
						and DIC_PhonePrefix.phoneType=EmployeeServiceQueueOrderPhones.phoneType 
					WHERE x_Dept_Employee_Service.x_Dept_Employee_ServiceID = EmployeeServiceQueueOrderMethod.x_dept_employee_serviceID
					AND DIC_QueueOrder.PermitOrderMethods=1
					FOR XML path ('QueueOrderMethod'),root('QueueOrderMethods'),type    )
			FROM dbo.DIC_QueueOrder
			WHERE x_Dept_Employee_Service.QueueOrder=DIC_QueueOrder.QueueOrder
			FOR XML path ('QueueOrder'),root('QueueOrders'),type    
		) ServiceQueueOrders
		,stuff((select ';'+ vDeptServices.serviceDescription        
				from dbo.vDeptServices        
				where vDeptServices.DeptCode = Dept.deptCode
				and vDeptServices.IsService = 1
				for xml path('')),1,1,''
		) ServiceList
		, case when (ROW_NUMBER() OVER(PARTITION BY Dept.deptCode order by Dept.deptCode) = 1)
				then 1
				else 0 end as DeptDistinct 
	from dbo.Dept         
	inner join  dbo.cities        
		on cities.cityCode=dept.cityCode        
	inner join dbo.UnitType        
		on dept.typeUnitCode =UnitType.UnitTypeCode        
	left join x_Dept_Employee
		on x_Dept_Employee.deptCode = Dept.deptCode     
		and exists (select employeeID from dbo.Employee 
					where employeeID = x_Dept_Employee.employeeID
					and IsMedicalTeam = 1)
	left join Employee
		on x_Dept_Employee.employeeID = Employee.employeeID
		and Employee.IsMedicalTeam = 1
	left join x_Dept_Employee_Service
		on x_Dept_Employee.DeptEmployeeID = x_Dept_Employee_Service.DeptEmployeeID
		and exists (select serviceCode from dbo.Services 
					where serviceCode = x_Dept_Employee_Service.serviceCode 
					and Services.IsService = 1)
	left join dbo.Services        
		on x_Dept_Employee_Service.serviceCode=Services.serviceCode 
	left join dbo.VFastDeptShift       
		on dept.deptCode=VFastDeptShift.deptCode      
	left join VFastDeptServiceShift      
		on x_Dept_Employee.deptCode=VFastDeptServiceShift.deptCode      
		and x_Dept_Employee_Service.serviceCode=VFastDeptServiceShift.servicecode      
	LEFT JOIN  dbo.DIC_deptLevel
		ON dept.deptLevel=DIC_deptLevel.deptLevelCode
	LEFT JOIN DIC_SubUnitTypes
		ON dept.SubUnitTypeCode=DIC_SubUnitTypes.SubUnitTypeCode
	LEFT JOIN DIC_ParkingInClinic
		ON dept.parking=DIC_ParkingInClinic.parkingInClinicCode
	WHERE  dept.showUnitInInternet=1  
	and dept.status=1 
	and UnitType.ShowInInternet=1
	and (Dept.IsCommunity = 1 or Dept.IsMushlam = 1)
	--and dept.deptCode in (43300, 123953)
   )  
 a  


GO


GRANT SELECT ON [dbo].[VFastDept] TO [public] AS [dbo]
GO


---------------------------

/****** Object:  View [dbo].[VFastEmployee]    Script Date: 12/15/2011 08:33:14 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[VFastEmployee]'))
DROP VIEW [dbo].[VFastEmployee]
GO

/****** Object:  View [dbo].[VFastEmployee]    Script Date: 12/15/2011 08:33:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[VFastEmployee]  
AS  

SELECT 	RIGHT('0000000000' + cast(employee.employeeID AS varchar(20)), 10) 
			+ RIGHT('0000000' + ISNULL(cast(x_Dept_Employee.deptCode AS varchar(10)), ''), 7)   
			+ RIGHT('0000' + cast(ISNULL(services.serviceCode, 0) AS varchar(10)), 4) DoctoRKey
		,employee.employeeID
		,DIC_EmployeeDegree.DegreeName
		,employee.firstName
		,employee.lastName
		,DIC_Gender.sexDescription
		,STUFF ((SELECT ';' + languages.languageDescription  
					FROM dbo.EmployeeLanguages 
					JOIN dbo.languages 
					ON EmployeeLanguages.languagecode = languages.languagecode
					WHERE     employee.employeeID = EmployeeLanguages.EmployeeID FOR XML path('')), 1, 1, ''
		) AS Languages
		,cast(employee.IsInCommunity AS char(1)) as empIsInCommunity
        ,cast(employee.IsInMushlam AS char(1)) as empIsInMushlam
		,employee.IsInHospitals as empIsInHospitals
		,employee.IsSurgeon as empIsSurgeon
		,case when (x_Dept_Employee.AgreementType in (1,2) and employee.IsInCommunity = 1) then 'community'
				when (x_Dept_Employee.AgreementType in (3,4) and employee.IsInMushlam = 1) then 'mushlam'
				else 'community' end as empAgreement
		,case when (x_Dept_Employee.AgreementType in (1,2) and employee.IsInCommunity = 1) then 'קהילה'
				when (x_Dept_Employee.AgreementType in (3,4) and employee.IsInMushlam = 1) then 'מושלם'
				else 'community' end as empAgreementHeb
		,employee.IsVirtualDoctor
		,employee.IsMedicalTeam
		,employee.PrivateHospitalPosition as empPrivateHospitalPosition
		,employee.PrivateHospital as empPrivateHospital
		,dept.deptCode
		,services.serviceCode
		,dept.deptName
		,dept.administrationCode as AdministrationCode
		,(SELECT	dbo.rfn_GetFotmatedRemark(x_Employee_EmployeeRemarks.RemarkText) [Text]
					,x_Employee_EmployeeRemarks.ValidFrom
					,x_Employee_EmployeeRemarks.ValidTo  
			FROM (SELECT EmployeeRemarks.EmployeeID,
						x_Dept_Employee_EmployeeRemarks.DeptEmployeeID,
						 EmployeeRemarks.RemarkText
						,EmployeeRemarks.validFrom
						,EmployeeRemarks.ValidTo
						,AttributedToAllClinicsInCommunity
						,AttributedToAllClinicsInMushlam
						,AttributedToAllClinicsInHospitals
					FROM x_Dept_Employee_EmployeeRemarks 
					JOIN EmployeeRemarks ON x_Dept_Employee_EmployeeRemarks.EmployeeRemarkID = EmployeeRemarks.EmployeeRemarkID
					WHERE GETDATE() BETWEEN ISNULL(EmployeeRemarks.validFrom, '1900-01-01') AND ISNULL(EmployeeRemarks.validTo, '2079-01-01') 
					AND   EmployeeRemarks.displayInInternet = 1
			) x_Employee_EmployeeRemarks
			WHERE      x_Employee_EmployeeRemarks.EmployeeID = Employee.employeeID 
			AND ((x_Employee_EmployeeRemarks.AttributedToAllClinicsInCommunity = 1 and x_Dept_Employee.AgreementType in (1, 2))
					OR (x_Employee_EmployeeRemarks.AttributedToAllClinicsInMushlam = 1 and x_Dept_Employee.AgreementType in (3, 4))
					OR (x_Employee_EmployeeRemarks.AttributedToAllClinicsInHospitals = 1 and x_Dept_Employee.AgreementType > 4)
					OR (x_Employee_EmployeeRemarks.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID)
				) FOR XML path('Remark'), root('Remarks'), type
		) Remarks
		,stuff ((SELECT ',' + position.positionDescription  
					FROM x_Dept_Employee_Position 
					INNER JOIN position 
					ON position.positionCode = x_Dept_Employee_Position.positionCode
					WHERE     x_Dept_Employee_Position.DeptEmployeeID = x_dept_employee.DeptEmployeeID
					AND position.gender = Employee.sex 
					--AND x_Dept_Employee_Position.deptCode = dept.deptCode 
					FOR XML path('')), 1, 1, ''
		) Position
		,(SELECT	DIC_PhoneTypes.PhoneTypeName Type
					,case when DeptEmployeePhones.Preprefix = 2 
							then '*' else CONVERT(varchar(10), DeptEmployeePhones.Preprefix) end as  Preprefix
					,DIC_PhonePrefix.prefixValue as [Prefix]
					,DeptEmployeePhones.Phone Number
					,DeptEmployeePhones.PhoneOrder[Order]
					,DeptEmployeePhones.UpdateDate
			FROM dbo.DeptEmployeePhones 
			INNER JOIN dbo.DIC_PhoneTypes 
			ON DIC_PhoneTypes.phoneTypeCode = DeptEmployeePhones.phoneType
			left join dbo.DIC_PhonePrefix   
			on DIC_PhonePrefix.prefixCode=DeptEmployeePhones.prefix 
			WHERE DeptEmployeePhones.DeptEmployeeID = x_dept_employee.DeptEmployeeID			
			FOR xml path('Phone'), root('Phones'), type
		) Phones
		,services.serviceDescription
		,services.isInCommunity
		,services.isInMushlam
		,EmployeeServices.expProfession
		,case when EmployeeServices.expProfession = 1 
				then 'מומחה' else 'לא מומחה' end as ExpProfessionDesc
		,(SELECT	DIC_ReceptionDays.ReceptionDayName[Day]
					,DIC_ReceptionDays.ReceptionDayCode[DayCode]
					,(SELECT	DeptEmployeeReception.openingHour[OpeningHour] 
								,DeptEmployeeReception.closingHour[ClosingHour]
								,DeptEmployeeReception.ValidFrom
								,DeptEmployeeReception.ValidTo
								,(SELECT	DeptEmployeeReceptionRemarks.RemarkText [Text]
											,DeptEmployeeReceptionRemarks.ValidFrom
											,DeptEmployeeReceptionRemarks.ValidTo  
									FROM DeptEmployeeReceptionRemarks  
									WHERE DeptEmployeeReceptionremarks.EmployeeReceptionID = DeptEmployeeReception.receptionID 
									AND GETDATE() BETWEEN ISNULL(DeptEmployeeReceptionremarks.validFrom, '1900-01-01') AND ISNULL(DeptEmployeeReceptionremarks.validTo, '2079-01-01') 
									FOR XML path('Remark'), type
								)
						FROM deptEmployeeReception
						WHERE deptEmployeeReception.receptionID = receptionDay.receptionID 
						AND deptEmployeeReception.receptionDay = receptionDay.receptionDay 
						AND GETDATE() BETWEEN ISNULL(deptEmployeeReception.validFrom,'1900-01-01') AND ISNULL(deptEmployeeReception.validTo, '2079-01-01') 
						FOR XML PATH('Reception'), type
					)  
			FROM (SELECT DISTINCT receptionDay
								, receptionID  
					FROM deptEmployeeReception
					WHERE deptEmployeeReception.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID 					
					AND GETDATE() BETWEEN ISNULL(deptEmployeeReception.validFrom,'1900-01-01') AND ISNULL(deptEmployeeReception.validTo, '2079-01-01') 
			) receptionDay 
			JOIN DIC_ReceptionDays 
			ON DIC_ReceptionDays.receptiondayCode = receptionDay.ReceptionDay
			JOIN deptEmployeeReceptionServices ders
			on receptionDay.receptionID = ders.receptionID
			and ders.serviceCode = emp_Service.serviceCode
			--WHERE EXISTS (SELECT 1 FROM x_Dept_Employee_Service  
			--				WHERE x_Dept_Employee_Service.DeptEmployeeID = dbo.x_Dept_Employee.DeptEmployeeID							
			--				AND x_Dept_Employee_Service.serviceCode = emp_Service.serviceCode
			--			)  
						FOR XML PATH('DayInfo'), ROOT('ReceptionHours'), TYPE
		) ReceptionHours
		,(SELECT	DIC_QueueOrder.QueueOrder QueueOrderCode
					,DIC_QueueOrder.QueueOrderDescription QueueOrderDesc
					,(select DIC_QueueOrderMethod.QueueOrderMethod
							,DIC_QueueOrderMethod.QueueOrderMethodDescription
							,case when DeptEmployeeQueueOrderPhones.Preprefix = 2 
									then '*' else CONVERT(varchar(10), DeptEmployeeQueueOrderPhones.Preprefix) end as  Preprefix
							,DIC_PhonePrefix.prefixValue as [Prefix]
							,DeptEmployeeQueueOrderPhones.phone Phone
							,(select receptiondayName DAY        
									,(select EmpRec.FromHour ,EmpRec.ToHour
										from EmployeeQueueOrderHours EmpRec          
										where EmpRec.QueueOrderMethodID=Gdays.QueueOrderMethodID 
										and EmpRec.receptionDay=Gdays.receptionDay
										for XML path('Reception'),type
									) 
								from (select distinct QueueOrderMethodID
													,ReceptiondayName
													,ReceptionDay 
										from dbo.EmployeeQueueOrderHours        
										inner join  dbo.DIC_ReceptionDays        
										on DIC_ReceptionDays.receptiondayCode=dbo.EmployeeQueueOrderHours.receptionDay         
										where EmployeeQueueOrderHours.QueueOrderMethodID=dbo.EmployeeQueueOrderMethod.QueueOrderMethodID
								) Gdays for XML path ('DayInfo'),root('ReceptionHours'),type  
							)
						FROM EmployeeQueueOrderMethod 
						INNER JOIN dbo.DIC_QueueOrderMethod 
						ON dbo.EmployeeQueueOrderMethod.QueueOrderMethod = dbo.DIC_QueueOrderMethod.QueueOrderMethod
						LEFT JOIN dbo.DeptEmployeeQueueOrderPhones 
						ON DeptEmployeeQueueOrderPhones.QueueOrderMethodID=EmployeeQueueOrderMethod.QueueOrderMethodID
						left join dbo.DIC_PhonePrefix   
						on DIC_PhonePrefix.prefixCode=DeptEmployeeQueueOrderPhones.prefix 
						WHERE EmployeeQueueOrderMethod.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID						
						AND DIC_QueueOrder.PermitOrderMethods=1
						FOR XML path ('QueueOrderMethod'),root('QueueOrderMethods'),type    
					)
			FROM dbo.DIC_QueueOrder
			WHERE x_Dept_Employee.QueueOrder=DIC_QueueOrder.QueueOrder
			FOR XML path ('QueueOrder'),root('QueueOrders'),type    
		) QueueOrderMethodHours
		,VFastDeptEmployeeProfessionShift.shift
		,cities.cityName
		,cities.cityCode 
		,dept.StreetName
		,dept.house
		,dept.flat
		,dept.entrance
		,dept.FLOOR
		,dept.addresscomment
		, dept.transportation
		,stuff((select ';'+DIC_HandicappedFacilities.FacilityDescription
					from dbo.DeptHandicappedFacilities
					inner join dbo.DIC_HandicappedFacilities
					on DIC_HandicappedFacilities.FacilityCode=DeptHandicappedFacilities.FacilityCode
					where DeptHandicappedFacilities.DeptCode=dept.deptCode
					for xml path('')),1,1,''
		) FacilityDescription
		,(select DIC_PhoneTypes.PhoneTypeName [Type]
				,case when DeptPhones.Preprefix = 2 
					   then '*' else CONVERT(varchar(10), DeptPhones.Preprefix) end as  Preprefix
				,DIC_PhonePrefix.prefixValue [Prefix]
				,DeptPhones.Phone Number    
				,DeptPhones.PhoneOrder [Order]       
				,DeptPhones.UpdateDate UpdateDate
			from dbo.deptPhones
			inner join dbo.DIC_PhoneTypes
			on DIC_PhoneTypes.phoneTypeCode=deptPhones.phoneType
			left join dbo.DIC_PhonePrefix   
			on DIC_PhonePrefix.prefixCode=deptPhones.prefix 
			where dept.deptCode=deptPhones.DeptCode for xml path('Phone'),root('Phones'),type
	) Deptphones
	,UnitType.UnitTypeName
	,UnitType.UnitTypeCode
	,DIC_AgreementTypes.AgreementTypeID as AgreementType
	,DIC_AgreementTypes.AgreementTypeDescription
	,EmployeeSector.EmployeeSectorCode
	,EmployeeSector.EmployeeSectorDescriptionForCaption as  EmployeeSectorDescription
	,x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic as CascadePhonesFromDept
FROM dbo.employee 
INNER JOIN dbo.DIC_EmployeeDegree ON DIC_EmployeeDegree.DegreeCode = employee.DegreeCode 
LEFT JOIN DIC_Gender ON employee.sex = DIC_Gender.sex 
LEFT JOIN dbo.x_Dept_Employee ON Employee.employeeID = x_Dept_Employee.employeeID and x_dept_employee.active=1 
LEFT JOIN dbo.DIC_AgreementTypes on x_Dept_Employee.AgreementType=DIC_AgreementTypes.AgreementTypeID 
LEFT JOIN dbo.dept ON x_Dept_Employee.deptCode = dept.deptCode 
LEFT JOIN x_Dept_Employee_Service as emp_Service ON x_Dept_Employee.DeptEmployeeID = emp_Service.DeptEmployeeID
LEFT JOIN services ON emp_Service.serviceCode = services.serviceCode 
LEFT JOIN EmployeeServices 
	ON emp_Service.serviceCode = EmployeeServices.serviceCode
	AND employee.employeeID = EmployeeServices.EmployeeID 
LEFT JOIN dbo.VFastDeptEmployeeProfessionShift 
	ON emp_Service.DeptEmployeeID = VFastDeptEmployeeProfessionShift.DeptEmployeeID 
	AND emp_Service.serviceCode = VFastDeptEmployeeProfessionShift.ServiceCode
LEFT JOIN dbo.cities ON cities.cityCode=dept.cityCode 
LEFT JOIN dbo.UnitType on dept.typeUnitCode =UnitType.UnitTypeCode  
LEFT JOIN dbo.EmployeeSector on Employee.EmployeeSectorCode =EmployeeSector.EmployeeSectorCode
LEFT JOIN dbo.x_Services_EmployeeSector ON  EmployeeSector.EmployeeSectorCode=x_Services_EmployeeSector.EmployeeSectorCode and x_Services_EmployeeSector.ServiceCode=Services.serviceCode 
LEFT JOIN dbo.VFastDept ON VFastDept.deptCode = dept.deptCode AND VFastDept.serviceCode = ISNULL(emp_Service.serviceCode, 0)    
WHERE	Employee.EmployeeSectorCode IN (2, 7)  and Employee.active = 1
		and dept.showUnitInInternet = 1  and dept.status = 1
		and UnitType.ShowInInternet = 1 and UnitType.IsActive = 1
		and IsVirtualDoctor <> 1 and IsMedicalTeam <> 1
		and x_Dept_Employee.AgreementType <> 4
		and (Dept.IsCommunity = 1 or Dept.IsMushlam = 1)

GO


GRANT SELECT ON [dbo].[VFastEmployee] TO [public] AS [dbo]
GO

--------------------------
-- **** Integration views


/*-------------------------------------------------------------------------
Get all doctors receptions data for integration team
-------------------------------------------------------------------------*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vIngr_DoctorReceptions]'))
	DROP VIEW [dbo].vIngr_DoctorReceptions
GO


CREATE VIEW [dbo].vIngr_DoctorReceptions
AS
select xde.deptCode as ClinicCode, xde.employeeID as DoctorID, ders.serviceCode, 
		der.receptionDay, der.openingHour, der.closingHour,
		derr.RemarkID, derr.RemarkText
from deptEmployeeReception der
join deptEmployeeReceptionServices ders
on der.receptionID = ders.receptionID
join x_Dept_Employee xde
on der.DeptEmployeeID = xde.DeptEmployeeID
left join DeptEmployeeReceptionRemarks derr
on der.receptionID = derr.EmployeeReceptionID
where GETDATE() between ISNULL(der.validFrom, '1900-01-01') and ISNULL(der.validTo, '2079-01-01')

GO


GRANT SELECT ON [dbo].vIngr_DoctorReceptions TO [public] AS [dbo]
GO

-----------------

/*-------------------------------------------------------------------------
Get all doctors receptions data for integration team
-------------------------------------------------------------------------*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vIngr_DoctorLanguages]'))
	DROP VIEW [dbo].vIngr_DoctorLanguages
GO


CREATE VIEW [dbo].vIngr_DoctorLanguages
AS
select el.EmployeeID as DoctorID, el.languageCode, l.languageDescription
from EmployeeLanguages el
join languages l
on el.languageCode = l.languageCode

GO

GRANT SELECT ON [dbo].vIngr_DoctorLanguages TO [public] AS [dbo]
GO

-------------------

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vIngr_DeptReceptionHoursForShivuk]'))
	DROP VIEW [dbo].[vIngr_DeptReceptionHoursForShivuk]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*
שליפת פרטי יחידות עבור שיווק
א.	קוד יחידה
ב.	 שם מרפאה
ג.	סוג יחידה + שיוך
ד.	מחוז
ה.	כתובת (עיר, רחוב, מיקוד קואורדינאטות, הערה לכתובת)
ו.	טלפון
ז.	שעות קבלה 
ח.	הערות לשעות
*/


CREATE VIEW [dbo].[vIngr_DeptReceptionHoursForShivuk]
AS

select deptcode, deptName,deptTypeName, 
				deptSubTypeName,
				districtName, cityName, 
				street,
				house, addressComment, zipCode, xcoord, ycoord,
				phone,
max([א-1]) as [א-1],max([א-2]) as [א-2],max([א-3]) as [א-3],max([ב-1]) as [ב-1],max([ב-2]) as [ב-2],max([ב-3]) as [ב-3],max([ג-1]) as [ג-1],max([ג-2]) as [ג-2],max([ג-3]) as [ג-3],max([ד-1]) as [ד-1],max([ד-2]) as [ד-2],max([ד-3]) as [ד-3],max([ה-1]) as [ה-1],max([ה-2]) as [ה-2],max([ה-3]) as [ה-3],max([ו-1]) as [ו-1],max([ו-2]) as [ו-2],max([ו-3]) as [ו-3],max([חג-1]) as [חג-1],max([חג-2]) as [חג-2],max([חוה"מ-1]) as [חוה"מ-1],max([חוה"מ-2]) as [חוה"מ-2],max([חוה"מ-3]) as [חוה"מ-3],max([ערב חג-1]) as [ערב חג-1],max([ערב חג-2]) as [ערב חג-2],max([ש-1]) as [ש-1],max([ש-2]) as [ש-2],
max([הערה-א-1]) as [הערה-א-1],max([הערה-א-2]) as [הערה-א-2],max([הערה-א-3]) as [הערה-א-3],max([הערה-ב-1]) as [הערה-ב-1],max([הערה-ב-2]) as [הערה-ב-2],max([הערה-ב-3]) as [הערה-ב-3],max([הערה-ג-1]) as [הערה-ג-1],max([הערה-ג-2]) as [הערה-ג-2],max([הערה-ג-3]) as [הערה-ג-3],max([הערה-ד-1]) as [הערה-ד-1],max([הערה-ד-2]) as [הערה-ד-2],max([הערה-ד-3]) as [הערה-ד-3],max([הערה-ה-1]) as [הערה-ה-1],max([הערה-ה-2]) as [הערה-ה-2],max([הערה-ה-3]) as [הערה-ה-3],max([הערה-ו-1]) as [הערה-ו-1],max([הערה-ו-2]) as [הערה-ו-2],max([הערה-ו-3]) as [הערה-ו-3],max([הערה-חג-1]) as [הערה-חג-1],max([הערה-חג-2]) as [הערה-חג-2],max([הערה-חוה"מ-1]) as [הערה-חוה"מ-1],max([הערה-חוה"מ-2]) as [הערה-חוה"מ-2],max([הערה-חוה"מ-3]) as [הערה-חוה"מ-3],max([הערה-ערב חג-1]) as [הערה-ערב חג-1],max([הערה-ערב חג-2]) as [הערה-ערב חג-2],max([הערה-ש-1]) as [הערה-ש-1],max([הערה-ש-2]) as [הערה-ש-2]
from 
(select
d.deptCode, d.deptName, 
ut.UnitTypeName as deptTypeName, 
				sut.subUnitTypeName as deptSubTypeName,
				distr.deptName as districtName, c.cityName, 
				case when d.StreetCode is null then d.streetName else s.Name end as street,
				d.house, d.addressComment, d.zipCode, dxy.xcoord, dxy.ycoord,
				dbo.GetDeptPhoneNumber(d.deptCode, 1, 1) as phone,
dr.receptionDay,
dr.openingHour ,
dr.closingHour ,
[DIC_ReceptionDays].ReceptionDayName,
openingHour + '-'+closingHour as Hours,
derp.RemarkText,
row_number() over (partition by d.deptCode,dr.receptionDay 
order by dr.openingHour --,DeptReception.closingHour 
)rn,
[DIC_ReceptionDays].ReceptionDayName+'-'+cast(row_number() over (partition by d.deptCode,dr.receptionDay order by dr.openingHour /*,dr.closingHour*/ ) as varchar(10)) shift ,
'הערה-'+[DIC_ReceptionDays].ReceptionDayName+'-'+cast(row_number() over (partition by d.deptCode,dr.receptionDay 
												order by dr.openingHour) as varchar(10)) shift2
from dept d 
join DeptReception dr
on d.deptCode = dr.deptCode 
and dr.ReceptionHoursTypeID = 1
left join [DIC_ReceptionDays]
on dr.receptionDay = [DIC_ReceptionDays].ReceptionDayCode  
join UnitType ut
on d.typeUnitCode = ut.UnitTypeCode
left join DIC_SubUnitTypes sut
on d.subUnitTypeCode = sut.subUnitTypeCode
left join Dept distr
on d.districtCode = distr.deptCode
join Cities c
on d.cityCode = c.cityCode
left join Streets s
on d.cityCode = s.CityCode 
	and d.StreetCode = s.StreetCode
left join x_dept_XY dxy
on d.deptCode = dxy.deptCode
left join DeptReceptionRemarks derp
on derp.ReceptionID = dr.receptionID
where d.status = 1
and GETDATE() between ISNULL(dr.validFrom,'1900-01-01') 
and ISNULL(dr.validTo,'2079-01-01')  
) a
pivot 
(max(Hours) for shift in ([א-1],[א-2],[א-3],[ב-1],[ב-2],[ב-3],[ג-1],[ג-2],[ג-3],[ד-1],[ד-2],[ד-3],[ה-1],[ה-2],[ה-3],[ו-1],[ו-2],[ו-3],[ש-1],[ש-2],[חג-1],[חג-2],[חוה"מ-1],[חוה"מ-2],[חוה"מ-3],[ערב חג-1],[ערב חג-2])
) AS PivotTable
pivot 
(max(RemarkText) for shift2 in ([הערה-א-1],[הערה-א-2],[הערה-א-3],[הערה-ב-1],[הערה-ב-2],[הערה-ב-3],[הערה-ג-1],[הערה-ג-2],[הערה-ג-3],[הערה-ד-1],[הערה-ד-2],[הערה-ד-3],[הערה-ה-1],[הערה-ה-2],[הערה-ה-3],[הערה-ו-1],[הערה-ו-2],[הערה-ו-3],[הערה-ש-1],[הערה-ש-2],[הערה-חג-1],[הערה-חג-2],[הערה-חוה"מ-1],[הערה-חוה"מ-2],[הערה-חוה"מ-3],[הערה-ערב חג-1],[הערה-ערב חג-2])
) AS PivotTable2
group by deptcode, deptName, deptTypeName, 
				deptSubTypeName,
				districtName, cityName, 
				street,
				house, addressComment, zipCode, xcoord, ycoord,
				phone
union
select d.deptcode, d.deptName,
ut.UnitTypeName as deptTypeName, 
				sut.subUnitTypeName as deptSubTypeName,
				distr.deptName as districtName, c.cityName, 
				case when d.StreetCode is null then d.streetName else s.Name end as street,
				d.house, d.addressComment, d.zipCode, dxy.xcoord, dxy.ycoord,
				dbo.GetDeptPhoneNumber(d.deptCode, 1, 1) as phone,
'' as [א-1],'' as [א-2],'' as [א-3],'' as [ב-1],'' as [ב-2],'' as [ב-3],'' as [ג-1],'' as [ג-2],'' as [ג-3],'' as [ד-1],'' as [ד-2],'' as [ד-3],'' as [ה-1],'' as [ה-2],'' as [ה-3],'' as [ו-1],'' as [ו-2],'' as [ו-3],
'' as [חג-1],'' as [חג-2], '' as [חוה"מ-1],'' as [חוה"מ-2],'' as [חוה"מ-3],'' as [ערב חג-1],'' as [ערב חג-2],'' as [ש-1],'' as [ש-2],
'' as [הערה-א-1],'' as [הערה-א-2],'' as [הערה-א-3],'' as [הערה-ב-1],'' as [הערה-ב-2],'' as [הערה-ב-3],'' as [הערה-ג-1],'' as [הערה-ג-2],'' as [הערה-ג-3],'' as [הערה-ד-1],'' as [הערה-ד-2],'' as [הערה-ד-3],'' as [הערה-ה-1],'' as [הערה-ה-2],'' as [הערה-ה-3],'' as [הערה-ו-1],'' as [הערה-ו-2],'' as [הערה-ו-3],'' as [הערה-חג-1],'' as [הערה-חג-2],'' as [הערה-חוה"מ-1],'' as [הערה-חוה"מ-2],'' as [הערה-חוה"מ-3],'' as [הערה-ערב חג-1],'' as [הערה-ערב חג-2],'' as [הערה-ש-1],'' as [הערה-ש-2]
from Dept d
join UnitType ut
on d.typeUnitCode = ut.UnitTypeCode
left join DIC_SubUnitTypes sut
on d.subUnitTypeCode = sut.subUnitTypeCode
left join Dept distr
on d.districtCode = distr.deptCode
join Cities c
on d.cityCode = c.cityCode
left join Streets s
on d.cityCode = s.CityCode 
	and d.StreetCode = s.StreetCode
left join x_dept_XY dxy
on d.deptCode = dxy.deptCode
where d.deptCode not in (select deptCode from DeptReception where ReceptionHoursTypeID = 1)
and d.status = 1

GO


GRANT SELECT ON [dbo].[vIngr_DeptReceptionHoursForShivuk] TO [public] AS [dbo]
GO
-----------------------------

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vIngr_DeptReceptionHours]'))
	DROP VIEW [dbo].[vIngr_DeptReceptionHours]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*
	Select Depts reception hours for specific dept types & only for 'regular' days of week 
	Owner : Integration Team
*/
CREATE VIEW [dbo].[vIngr_DeptReceptionHours]
AS
SELECT     deptCode,
                          (SELECT	SUM(dbo.rfn_TimeInterval_float(openingHour, closingHour)) AS Expr1
                            FROM	dbo.DeptReception AS dr
                            WHERE	(deptCode = d.deptCode) AND (receptionDay < 8)
                            and		GETDATE() between ISNULL(dr.validFrom,'1900-01-01') and ISNULL(dr.validTo,'2079-01-01')  
                            GROUP BY deptCode) AS ReceptionHours
FROM         dbo.Dept AS d
WHERE     ((typeUnitCode IN (102, 103, 104, 107, 101, 501, 502, 503)) OR
          (typeUnitCode IN (202, 203, 204, 205, 207, 208, 212) AND (subUnitTypeCode = 0)))
          AND (status = 1)

GO


GRANT SELECT ON [dbo].[vIngr_DeptReceptionHours] TO [public] AS [dbo]
GO
---------------------------
/*
	לצורך עדכון נתוני מרפאות באופן שוטף לצורף הקלטתן למערכת זימון תורים בזיהוי דיבור (ASR)
	נבקש גזירה יומית של נתוני מרפאות ראשוניות, משולבות, יועצות, כפריות ועצמאיות

	Owner : Integration Team
*/


IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vIngr_DeptDataForASR]'))
	DROP VIEW [dbo].[vIngr_DeptDataForASR]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vIngr_DeptDataForASR]
AS
SELECT d.deptCode, ds.Simul228 as oldDeptCode, deptName, d.cityCode, c.cityName, streetName, house, addressComment
FROM dbo.Dept AS d
join Cities c
on d.cityCode = c.cityCode
join deptSimul ds
on d.deptCode = ds.deptCode
WHERE	typeUnitCode IN (101, 102, 103, 104, 112)
		AND (status = 1)

GO


GRANT SELECT ON [dbo].[vIngr_DeptDataForASR] TO [public] AS [dbo]
GO
-----------------------------

/*-------------------------------------------------------------------------
Get all dept reception data for integration team
-------------------------------------------------------------------------*/

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vIngr_ClinicReceptionHours]'))
	DROP VIEW [dbo].vIngr_ClinicReceptionHours
GO


CREATE VIEW [dbo].vIngr_ClinicReceptionHours
AS

select	dr.deptCode as ClinicCode, dr.receptionDay, drd.ReceptionDayName, 
		dr.ReceptionHoursTypeID, drh.ReceptionTypeDescription,
		dr.openingHour, dr.closingHour, dr.validFrom, dr.validTo, 
		drr.RemarkID, drr.RemarkText
from DeptReception dr
join DIC_ReceptionDays drd
on dr.receptionDay = drd.ReceptionDayCode
join DIC_ReceptionHoursTypes drh
on dr.ReceptionHoursTypeID = drh.ReceptionHoursTypeID
left join DeptReceptionRemarks drr
on dr.receptionID = drr.ReceptionID
where GETDATE() between ISNULL(dr.validFrom, '1900-01-01') and ISNULL(dr.validTo, '2079-01-01')

GO


GRANT SELECT ON [dbo].vIngr_ClinicReceptionHours TO [public] AS [dbo]
GO

-------------------


/*-------------------------------------------------------------------------
Get all employee dept phones for integration team
-------------------------------------------------------------------------*/

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vIngr_DoctorClinicPhones]'))
	DROP VIEW [dbo].vIngr_DoctorClinicPhones
GO


CREATE VIEW [dbo].vIngr_DoctorClinicPhones
AS

select xde.employeeID as DoctorID, xde.deptCode as ClinicCode, 
		dp.phoneType, dp.phoneOrder, dpt.phoneTypeName,
		dbo.fun_ParsePhoneNumberWithExtension(dp.prePrefix, dp.prefix, dp.phone, dp.extension) AS PhoneNumber
from x_Dept_Employee xde
join DeptPhones dp
on xde.deptCode = dp.deptCode
join DIC_PhoneTypes dpt
on dp.phoneType = dpt.phoneTypeCode
where (xde.CascadeUpdateDeptEmployeePhonesFromClinic = 1 or 
		xde.CascadeUpdateDeptEmployeePhonesFromClinic is null)
union
select xde.employeeID as DoctorID, xde.deptCode as ClinicCode, 
		dp.phoneType, dp.phoneOrder, dpt.phoneTypeName,
		dbo.fun_ParsePhoneNumberWithExtension(dp.prePrefix, dp.prefix, dp.phone, dp.extension) AS PhoneNumber
from x_Dept_Employee xde
join DeptEmployeePhones dp
on xde.DeptEmployeeID = dp.DeptEmployeeID
join DIC_PhoneTypes dpt
on dp.phoneType = dpt.phoneTypeCode
where xde.CascadeUpdateDeptEmployeePhonesFromClinic = 0
--order by DoctorID, ClinicCode

GO


GRANT SELECT ON [dbo].vIngr_DoctorClinicPhones TO [public] AS [dbo]
GO

-------------------
/*-------------------------------------------------------------------------
Get all dept phones for integration team
-------------------------------------------------------------------------*/

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vIngr_ClinicPhones]'))
	DROP VIEW [dbo].vIngr_ClinicPhones
GO


CREATE VIEW [dbo].vIngr_ClinicPhones
AS

select dp.deptCode as ClinicCode, 
		dp.phoneType, dp.phoneOrder, dpt.phoneTypeName,
		dbo.fun_ParsePhoneNumberWithExtension(dp.prePrefix, dp.prefix, dp.phone, dp.extension) AS PhoneNumber
from DeptPhones dp
join DIC_PhoneTypes dpt
on dp.phoneType = dpt.phoneTypeCode

GO


GRANT SELECT ON [dbo].vIngr_ClinicPhones TO [public] AS [dbo]
GO

----------------------


/*-------------------------------------------------------------------------
Get all dept doctors data for integration team
-------------------------------------------------------------------------*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vIngr_ClinicDoctorsData]'))
	DROP VIEW [dbo].vIngr_ClinicDoctorsData
GO


CREATE VIEW [dbo].vIngr_ClinicDoctorsData
AS
select e.employeeID as DoctorID, e.licenseNumber as DoctorLicenceNo, 
		e.badgeID as EmployeeCode, e.firstName as DoctorFirstName, 
		e.lastName as DoctorLastName, e.sex as DoctorGenderCode, 
		e.degreeCode as DoctorTitleCode, ISNULL(e.email, '') as DoctorEmail, 
		e.showEmailInInternet as EmailIsUnlisted, e.IsMedicalTeam as IsDeptService, 
		xde.deptCode as ClinicCode, xde.AgreementType, 
		xdes.serviceCode, s.ServiceDescription, isnull(es.expProfession, 0) as IsExpert,
		s.IsProfession, s.IsService,
		case when ISNULL(ISNULL(esqm.queueOrderMethod, eqm.QueueOrderMethod), 0) = 1 then 1 else 0 end as OrderByClinicPhoneNumber,
		case when ISNULL(ISNULL(esqm.queueOrderMethod, eqm.QueueOrderMethod), 0) = 2 then 
			case when ISNULL(esqm.queueOrderMethod, 0) = 2 then 
     			(select dbo.fun_ParsePhoneNumberWithExtension(SPH.prePrefix, 
     								SPH.prefix, SPH.phone, SPH.extension)                 
				FROM EmployeeServiceQueueOrderPhones SPH 
				WHERE esqm.EmployeeServiceQueueOrderMethodID = SPH.EmployeeServiceQueueOrderMethodID
				AND SPH.phoneType = 1 and SPH.phoneOrder = 1
				) 
			else
     			(select top 1 dbo.fun_ParsePhoneNumberWithExtension(DEPH.prePrefix, 
     								DEPH.prefix, DEPH.phone, DEPH.extension)                 
				FROM DeptEmployeeQueueOrderPhones DEPH 
				WHERE eqm.QueueOrderMethodID = DEPH.QueueOrderMethodID
				AND DEPH.phoneType = 1 and DEPH.phoneOrder = 1
				) 
			end 
		else '' end	as OrderBySpecialPhoneNumber ,
		case when ISNULL(ISNULL(esqm.queueOrderMethod, eqm.QueueOrderMethod), 0) = 3 then '*2700' else '' end as OrderByTelemarketingCenter,
		case when ISNULL(ISNULL(esqm.queueOrderMethod, eqm.QueueOrderMethod), 0) = 4 then 1 else 0 end as OrderByInternet,
		case when ISNULL(ISNULL(xdes.QueueOrder, xde.QueueOrder), 0) = 4 then 1 else 0 end as OrderByClientClinic
		
from x_Dept_Employee xde
join Employee e
on xde.employeeID = e.employeeID
left join x_Dept_Employee_Service xdes
on xde.DeptEmployeeID = xdes.DeptEmployeeID
left join Services s
on xdes.serviceCode = s.ServiceCode
left join EmployeeServices es
on xdes.serviceCode = es.serviceCode
and xde.employeeID = es.EmployeeID
left join EmployeeQueueOrderMethod eqm
on xde.DeptEmployeeID = eqm.DeptEmployeeID
left join EmployeeServiceQueueOrderMethod esqm
on xdes.x_Dept_Employee_ServiceID = esqm.x_dept_employee_serviceID
join Dept d
on xde.deptCode = d.deptCode
where e.EmployeeSectorCode = 7
and e.active = 1
and xde.active = 1
and d.status = 1
--and xde.deptCode = 43300 
--and e.employeeID = 27062850 
--and e.employeeID = 1000000019

GO


GRANT SELECT ON [dbo].vIngr_ClinicDoctorsData TO [public] AS [dbo]
GO
-----------------------


/*-------------------------------------------------------------------------
Get all dept facilities for integration team
-------------------------------------------------------------------------*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vIngr_ClinicFacilities]'))
	DROP VIEW [dbo].vIngr_ClinicFacilities
GO


CREATE VIEW [dbo].vIngr_ClinicFacilities
AS
	select dhf.DeptCode as ClinicCode, dhf.FacilityCode, hf.FacilityDescription
	from DeptHandicappedFacilities dhf
	join DIC_HandicappedFacilities hf
	on dhf.FacilityCode = hf.FacilityCode
	where hf.Active = 1

GO


GRANT SELECT ON [dbo].vIngr_ClinicFacilities TO [public] AS [dbo]
GO

-----------------------

/*-------------------------------------------------------------------------
Get all dept data for integration team
-------------------------------------------------------------------------*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vIngr_ClinicData]'))
	DROP VIEW [dbo].vIngr_ClinicData
GO


CREATE VIEW [dbo].vIngr_ClinicData
AS

select d.deptCode as ClinicCode, ds.Simul228 as OldClinicCode, d.deptName as ClinicName, 
		d.typeUnitCode as TypeUnitCode, ut.UnitTypeName as UnitTypeName, 
		ISNULL(d.subUnitTypeCode, 0) as IsIndependent, sut.subUnitTypeName,
		d.districtCode as District, d.administrationCode as AdministrationCode, 
		d.cityCode as TownCode, c.cityName as TownName, 
		case when d.StreetCode is null then d.streetName else s.Name end as Street,
		d.house as HouseNo, d.addressComment as AddressComment, 
		d.zipCode, d.transportation as Bus, ISNULL(d.showUnitInInternet, ut.ShowInInternet) as ShowUnitInInternet,
		d.IsCommunity, d.IsMushlam,d.IsHospital, 
		case when dq.queueOrderMethod = 1 then 1 else 0 end as OrderByClinicPhoneNumber,
		case when dq.queueOrderMethod = 2 then 
     		(select dbo.fun_ParsePhoneNumberWithExtension(DPH.prePrefix, DPH.prefix, DPH.phone, DPH.extension) AS ClinicPhoneNumber                  
			FROM DeptQueueOrderPhones DPH 
			WHERE dq.queueOrderMethodID = DPH.queueOrderMethodID
			AND DPH.phoneType = 1 and DPH.phoneOrder = 1
			) else '' end as OrderBySpecialPhoneNumber ,
		case when dq.queueOrderMethod = 3 then '*2700' else '' end as  OrderByTelemarketingCenter,
		case when dq.queueOrderMethod = 4 then 1 else 0 end as OrderByInternet,
		case when d.QueueOrder = 4 then 1 else 0 end as OrderByClientClinic

from Dept d 
left join deptSimul ds
on d.deptCode = ds.deptCode
join UnitType ut
on d.typeUnitCode = ut.UnitTypeCode
left join DIC_SubUnitTypes sut
on ISNULL(d.subUnitTypeCode, 0) = sut.subUnitTypeCode
left join Cities c
on d.cityCode = c.cityCode
left join Streets s
on d.StreetCode = s.StreetCode
left join DeptQueueOrderMethod dq
on d.deptCode = dq.deptCode
where d.status = 1

GO


GRANT SELECT ON [dbo].vIngr_ClinicData TO [public] AS [dbo]
GO

----------------------------
/*

View for internal system - view not in use in SeferNet!
Do not change without Maria's permition!!!


מערכת מר"ע (רופאים עצמאיים) צריכה לקבל אינפורמציה באופן 
שוטף לגבי רופאים שנותנים שירות 1600 – רפואת ילדים בערב
יש להחזיר להם את הנתונים הבאים:
קוד סימול ישן, קוד סימול חדש, רישיון רופא
*/
/****** Object:  View [dbo].[View_DeptEmployeeService1600]    Script Date: 02/07/2011 15:35:01 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[View_DeptEmployeeService1600]'))
DROP VIEW [dbo].[View_DeptEmployeeService1600]
GO

/****** Object:  View [dbo].[View_DeptEmployeeService1600]    Script Date: 02/07/2011 15:35:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[View_DeptEmployeeService1600]
AS
SELECT     xd.deptCode, dbo.deptSimul.Simul228, dbo.Dept.districtCode, dbo.Employee.licenseNumber
FROM         dbo.x_Dept_Employee_Service xdes
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID 
INNER JOIN dbo.Employee ON xd.employeeID = dbo.Employee.employeeID 
INNER JOIN dbo.deptSimul ON dbo.deptSimul.deptCode = xd.deptCode 
AND dbo.deptSimul.openDateSimul <= GETDATE() 
AND (dbo.deptSimul.closingDateSimul > GETDATE() OR dbo.deptSimul.closingDateSimul IS NULL) 
INNER JOIN dbo.Dept ON dbo.deptSimul.deptCode = dbo.Dept.deptCode
WHERE     (xdes.serviceCode = 1600)


GO
---------------




-- ***** end inegration / external views
-- ***************************************

-- ***************************************************************************************************************


--**** Yaniv - Start rpc_GetDepSubClinics *****************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDepSubClinics')
	BEGIN
		drop procedure rpc_GetDepSubClinics
	END

GO

CREATE Procedure [dbo].[rpc_GetDepSubClinics]
(
	@DeptCode int
)
as

DECLARE @CurrentDate datetime = getdate()



---------------- SubClinics List    ***************************
SELECT 
Dept.deptCode,
Dept.deptName,
dept.deptLevel,
Dept.typeUnitCode,
UnitType.UnitTypeName,
'subUnitTypeCode' = CASE IsNull(dept.subUnitTypeCode, -1) 
					WHEN -1 THEN  (SELECT DefaultSubUnitTypeCode FROM UnitType WHERE UnitTypeCode = dept.TypeUnitCode)
					ELSE dept.subUnitTypeCode END,
Dept.IsCommunity,
Dept.IsMushlam,
Dept.IsHospital,
'address' = dbo.GetAddress(Dept.deptCode),
Dept.cityCode,
Cities.cityName,
'phone' = (SELECT TOP 1 
			dbo.fun_ParsePhoneNumberWithExtension(DeptPhones.prePrefix, DeptPhones.prefix, DeptPhones.phone, DeptPhones.extension )
			FROM DeptPhones
			WHERE deptCode = Dept.deptCode AND DeptPhones.PhoneType = 1 and phoneOrder = 1),
-- julia
'countDeptRemarks' = 
	(SELECT COUNT(*) 
	from View_DeptRemarks
	WHERE deptCode = dept.deptCode
		AND validFrom <= @CurrentDate 
		AND ( validTo is null OR validTo >= @CurrentDate ) 
		AND (IsSharedRemark = 0 OR dept.IsCommunity = 1) 		 
	),
-- end block julia 
'countReception' = 
	(select count(receptionID) 
	from DeptReception
	where deptCode = dept.deptCode
	AND (validFrom <= @CurrentDate AND (validTo is null OR validTo >= @CurrentDate)))

FROM Dept
inner join Cities on Dept.CityCode = Cities.CityCode
inner join UnitType on  Dept.typeUnitCode = UnitType.UnitTypeCode

WHERE Dept.deptCode in
(SELECT deptCode from dept where subAdministrationCode = @DeptCode and status = 1)
ORDER BY Dept.deptName


GRANT EXEC ON rpc_GetDepSubClinics TO PUBLIC
GO
--**** Yaniv - End rpc_GetDepSubClinics *****************************





--**** Yaniv - Start rpc_DeleteOldDeptAndEmployeeRemarks ***************
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_DeleteOldDeptAndEmployeeRemarks]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[rpc_DeleteOldDeptAndEmployeeRemarks]
GO


CREATE Procedure [dbo].[rpc_DeleteOldDeptAndEmployeeRemarks]

AS

	delete from DeptRemarks where validTo is not null
	and validTo < DATEADD(year, -1, GETDATE())

	delete from x_Dept_Employee_EmployeeRemarks
	where EmployeeRemarkID in(
	select EmployeeRemarkID from EmployeeRemarks 
	where validTo is not null
	and validTo < DATEADD(year, -1, GETDATE()))

	delete from EmployeeRemarks 
	where validTo is not null
	and validTo < DATEADD(year, -1, GETDATE())

GO


GRANT EXEC ON rpc_DeleteOldDeptAndEmployeeRemarks TO PUBLIC

GO


--**** Yaniv - End rpc_DeleteOldDeptAndEmployeeRemarks ***************

--**** Yaniv - Start rpc_DailyUpdate *********************************
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_updateDeptFromDeptStatus]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[rpc_updateDeptFromDeptStatus]
GO

CREATE Procedure [dbo].[rpc_updateDeptFromDeptStatus]

AS

declare @currentDate datetime SET @currentDate = GETDATE()
declare @autoUpdateUser varchar(50) SET @autoUpdateUser = 'DailyAutoUpdate'

UPDATE dept 
SET dept.status = T2.Status,
dept.updateUser = @autoUpdateUser + ' ' + REPLACE(T2.updateUser, @autoUpdateUser + ' ', ''),
dept.updateDate = @currentDate
FROM dept INNER JOIN
	(SELECT 
		deptCode, 
		'Status' = IsNull((SELECT TOP 1 Status FROM DeptStatus
		WHERE deptCode = T1.deptCode
		AND fromDate < @currentDate
		ORDER BY fromDate desc), -1),
		'updateUser' = (SELECT TOP 1 updateUser FROM DeptStatus
		WHERE deptCode = T1.deptCode
		AND fromDate < @currentDate
		ORDER BY fromDate desc)
	FROM 
	(SELECT distinct deptCode 
	FROM DeptStatus 
	WHERE fromDate < @currentDate) as T1
	) as T2 
ON dept.deptCode = T2.deptCode 
AND dept.status <> T2.Status -- involve only those whose status has really changed
AND T2.Status <> -1


DELETE FROM DeptReception
WHERE deptCode IN (SELECT DeptCode FROM dept WHERE dept.status = 0)

DELETE FROM x_dept_service
WHERE deptCode IN (SELECT DeptCode FROM dept WHERE dept.status = 0)

DELETE FROM x_Dept_Employee
WHERE deptCode IN (SELECT DeptCode FROM dept WHERE dept.status = 0)


GO


GRANT EXEC ON [rpc_updateDeptFromDeptStatus] TO PUBLIC

GO
-------------------------

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_UpdateDeptServiceStatus]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[rpc_UpdateDeptServiceStatus]
GO


CREATE Procedure [dbo].[rpc_UpdateDeptServiceStatus]

AS


declare @currentDate datetime SET @currentDate = GETDATE()
declare @autoUpdateUser varchar(50) SET @autoUpdateUser = 'DailyAutoUpdate'

UPDATE x_Dept_Service 
SET status = T.Status,
	updateUserName = @autoUpdateUser  + ' ' + REPLACE(T.updateUser, @autoUpdateUser + ' ', ''),
	updateDate = @currentDate
FROM x_Dept_Service  
INNER JOIN
	(SELECT
	deptCode,
	ServiceCode,
	'Status' = IsNull((SELECT TOP 1 Status FROM DeptServiceStatus
				WHERE x_Dept_Service.DeptCode = DeptServiceStatus.DeptCode
				AND x_Dept_Service.ServiceCode = DeptServiceStatus.ServiceCode
				AND fromDate < @currentDate
				ORDER BY fromDate desc), x_dept_service.status),
	'updateUser' = IsNull((SELECT TOP 1 UpdateUser FROM DeptServiceStatus
				WHERE x_Dept_Service.DeptCode = DeptServiceStatus.DeptCode
				AND x_Dept_Service.ServiceCode = DeptServiceStatus.ServiceCode
				AND fromDate < @currentDate
				ORDER BY fromDate desc), x_Dept_Service.UpdateUserName)			
	FROM x_Dept_Service) as T 
ON x_Dept_Service.DeptCode = T.DeptCode
AND x_Dept_Service.ServiceCode = T.ServiceCode
AND x_Dept_Service.status <> T.Status -- involve only those whose status has really changed


DELETE DeptServiceReception
from DeptServiceReception dsr
inner join x_Dept_service xds
	on dsr.deptCode = xds.DeptCode
	and dsr.ServiceCode = xds.ServiceCode
WHERE xds.status = 0


GO


GRANT EXEC ON rpc_UpdateDeptServiceStatus TO PUBLIC

GO

------------------------

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_DailyUpdate]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[rpc_DailyUpdate]
GO


CREATE Procedure [dbo].[rpc_DailyUpdate]

AS

	exec rpc_updateDeptNames
	exec rpc_updateDeptFromDeptStatus
	exec rpc_UpdateEmployeeStatus
	exec rpc_updateX_D_Emp_FromEmployeeStatusInDept
	exec rpc_UpdateDeptServiceStatus
	exec rpc_UpdateEmployeeServiceInDeptStatus
	exec rpc_DeleteOldDeptAndEmployeeRemarks

GO


GRANT EXEC ON [rpc_DailyUpdate] TO PUBLIC

GO


--**** Yaniv - End rpc_DailyUpdate *********************************



           
-- ********************************************************************************************************************************
  
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getReceptionTypesByGeneralBelongings')
	BEGIN
		DROP  Procedure  rpc_getReceptionTypesByGeneralBelongings
	END

GO

CREATE Procedure [dbo].[rpc_getReceptionTypesByGeneralBelongings]
	(
		@IsCommunity bit,
		@IsMushlam bit,
		@IsHospital bit
	)

AS

SELECT ReceptionHoursTypeID, ReceptionTypeDescription, EnumName
FROM DIC_ReceptionHoursTypes
WHERE (@IsCommunity = 1 AND IsCommunity = @IsCommunity)
OR (@IsMushlam = 1 AND IsMushlam = @IsMushlam)
OR (@IsHospital = 1 AND IsHospital = @IsHospital)

GO

GRANT EXEC ON rpc_getReceptionTypesByGeneralBelongings TO PUBLIC
GO


-------------------------
/****** Object:  StoredProcedure [dbo].[Helper_LongPrint]    Script Date: 04/24/2012 13:37:15 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Helper_LongPrint]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Helper_LongPrint]
GO

CREATE PROCEDURE [dbo].[Helper_LongPrint]( @string nvarchar(max) )
AS
SET NOCOUNT ON
set @string = rtrim( @string )
declare @cr char(1), @lf char(1)
set @cr = char(13)
set @lf = char(10)

declare @len int, @cr_index int, @lf_index int, @crlf_index int, @has_cr_and_lf bit, @left nvarchar(4000), @reverse nvarchar(4000)

set @len = 4000

while ( len( @string ) > @len )
begin

set @left = left( @string, @len )
set @reverse = reverse( @left )
set @cr_index = @len - charindex( @cr, @reverse ) + 1
set @lf_index = @len - charindex( @lf, @reverse ) + 1
set @crlf_index = case when @cr_index < @lf_index then @cr_index else @lf_index end

set @has_cr_and_lf = case when @cr_index < @len and @lf_index < @len then 1 else 0 end

print left( @string, @crlf_index - 1 )

set @string = right( @string, len( @string ) - @crlf_index - @has_cr_and_lf )

end

print @string

GO


-------------------------

-- ****************************************************************************************************************
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_GetMushlamServiceExtendedSearch]') AND type in (N'P', N'PC'))
    BEGIN
	    DROP  Procedure  rpc_GetMushlamServiceExtendedSearch
    END

GO

CREATE Procedure dbo.rpc_GetMushlamServiceExtendedSearch
(
	@searchText VARCHAR(100),
    @deptName VARCHAR(100),
    @cityCode INT,
    @districtCodes VARCHAR(100),
    @openAtHour VARCHAR(10),    
    @openFromHour VARCHAR(10),
    @openToHour VARCHAR(10),
    @receptionDays VARCHAR(30),
    @deptCode int 
)

AS

DECLARE @str VARCHAR(MAX)


-- services
SELECT * INTO #tempServices
FROM
(
	SELECT distinct msi.ServiceCode, msi.ServiceCode as ParentCode, msi.MushlamServiceName, msi.PrivateRemark, msi.AgreementRemark
	FROM [Services] ser
	INNER JOIN MushlamServicesToSefer msts  ON ser.ServiceCode = msts.SeferCode
	INNER JOIN MushlamServicesInformation msi ON msts.GroupCode = msi.GroupCode AND msts.SubGroupCode = msi.SubGroupCode
	WHERE IsInMushlam = 1
	AND (ServiceDescription LIKE '%' + @searchText + '%' 
		 OR ShowExpert LIKE '%' + @searchText + '%'
		 OR GeneralRemark LIKE '%' + @searchText + '%'
		 OR MushlamServiceName LIKE '%' + @searchText + '%')


	UNION

	-- synonyms
	SELECT msi.ServiceCode, msi.ServiceCode as parentCode, msi.MushlamServiceName, msi.PrivateRemark, msi.AgreementRemark
	FROM MushlamServiceSynonyms syn
	INNER JOIN MushlamServicesInformation msi ON syn.GroupCode = msi.GroupCode AND syn.SubGroupCode = msi.SubGroupCode
	WHERE syn.ServiceSynonym like '%' + @searchText + '%'

	UNION

	-- treatment types
	SELECT treat.SeferCode as serviceCode, treat.ParentServiceID as ParentCode, msi.MushlamServiceName + ' - ' + treat.Description, msi.PrivateRemark, msi.AgreementRemark
	FROM MushlamTreatmentTypesToSefer treat
	INNER JOIN MushlamServicesInformation msi ON  Treat.ParentServiceID = msi.ServiceCode 
	WHERE Treat.Description like '%' + @searchText + '%'   

) as x



SET @str =	'SELECT t.*, COUNT(' + CASE WHEN @openAtHour <> '' OR  @openFromHour <> '' OR @openToHour <> '' OR @receptionDays <> '' 
											THEN 'der.DeptEmployeeID'
										ELSE 
											CASE WHEN @cityCode <> '' OR @districtCodes <> '' OR @deptName <> '' OR @deptCode IS NOT NULL
													THEN 'd.DeptCode'
												 ELSE '*'
											END
										END + ') as NumOfSuppliers
			FROM #tempServices t
			LEFT JOIN x_dept_employee_service xdes ON t.ServiceCode = xdes.ServiceCode 			
			LEFT JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID 
			LEFT JOIN Dept d ON xd.DeptCode = d.DeptCode ' 


IF @deptName <> ''
SET @str = @str +  ' AND d.DeptName LIKE ' + CHAR(39) + '%' + CHAR(39) + ' + ''' + @deptName + ''' + ' + CHAR(39) + '%' + CHAR(39)


IF @cityCode <> ''
SET @str = @str +  ' AND d.CityCode = ' + CONVERT(VARCHAR,@cityCode)


IF @districtCodes <> ''
SET @str = @str +  ' AND d.districtCode IN (Select IntField from dbo.SplitString(' + @districtCodes + ')) '

if @deptCode is not null
SET @str = @str +  ' AND d.deptCode = ' + CONVERT(VARCHAR,@deptCode)


IF (@openAtHour <> '') OR (@openFromHour <> '') OR (@openToHour <> '') OR (@receptionDays <> '')
BEGIN
	SET @str = @str + 
			' LEFT JOIN 
			( SELECT der.DeptEmployeeID 
			  FROM DeptEmployeeReception der 
			  WHERE (1=1) ' 


	IF @openAtHour <> ''
	BEGIN
		DECLARE @openAtHour_real REAL
		SET @openAtHour_real = CAST (LEFT(@openAtHour,2) as real) + CAST (RIGHT(@openAtHour,2) as real)/60 
		SET @str = @str + ' 
					AND (Cast(Left(der.openingHour,2) as real) + Cast(Right(der.openingHour,2) as real)/60) <= ' + CHAR(39) + CONVERT(VARCHAR,@openAtHour_real) + CHAR(39) + '
					AND (Cast(Left(der.closingHour,2) as real) + Cast(Right(der.closingHour,2) as real)/60) >= ' + CHAR(39) + CONVERT(VARCHAR,@openAtHour_real) + CHAR(39) 
	END


	IF (@openFromHour <> '') AND (@openToHour <> '')
	BEGIN
		DECLARE @openFromHour_real REAL
		DECLARE @openToHour_real REAL
		SET @openFromHour_real = CAST (LEFT(@openFromHour,2) as real) + CAST (RIGHT(@openFromHour,2) as real)/60 
		SET @openToHour_real = CAST (LEFT(@openToHour,2) as real) + CAST (RIGHT(@openToHour,2) as real)/60 
		SET @str = @str +  ' AND (Cast(Left(der.openingHour,2) as real) + Cast(Right(der.openingHour,2) as real)/60) <= ' + CHAR(39) + CONVERT(VARCHAR,@openFromHour_real) + CHAR(39)
						+  ' AND (Cast(Left(der.closingHour,2) as real) + Cast(Right(der.closingHour,2) as real)/60) >= ' + CHAR(39) + CONVERT(VARCHAR,@openToHour_real) + CHAR(39)
	END

	IF @receptionDays <> ''
		SET @str = @str + ' AND der.ReceptionDay IN (SELECT IntField FROM dbo.SplitString(' + @receptionDays + '))'


	SET @str = @str + ' GROUP BY der.DeptEmployeeID) as der ON xdes.DeptEmployeeID = der.DeptEmployeeID ' 
END


			  
			

SET @str = @str + ' WHERE xd.AgreementType IN (3,4)'




SET @str = @str  + ' GROUP BY t.serviceCode, t.ParentCode, t.MushlamServiceName, t.PrivateRemark, t.AgreementRemark
					ORDER BY MushlamServiceName'

EXEC (@str) 



                
GO


GRANT EXEC ON rpc_GetMushlamServiceExtendedSearch TO PUBLIC

GO            
 


-- ****************************************************************************************************************  

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getUserPermittedDistrictsForReports')
	BEGIN
		DROP  Procedure  rpc_getUserPermittedDistrictsForReports
	END

GO

CREATE Procedure dbo.rpc_getUserPermittedDistrictsForReports
	(
		@UserID bigint,
		@unitCodes varchar(20)
	)

AS

IF (@unitCodes = '')
	SET @unitCodes = '65'

select distinct * from
(SELECT 
'districtCode' = dept.deptCode, 'districtName' = dept.deptName
FROM dept
WHERE (deptCode IN (SELECT deptCode FROM UserPermissions WHERE UserID = @UserID AND PermissionType in(1, 6))
	OR (SELECT MAX(PermissionType) FROM UserPermissions WHERE UserID = @UserID) = 5)
AND typeUnitCode in (SELECT IntField FROM dbo.SplitString(@unitCodes))
)
as temp
ORDER BY districtName
GO

GRANT EXEC ON rpc_getUserPermittedDistrictsForReports TO PUBLIC

GO

 
-- *******************************************************************************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetMushlamServicesByCodesSearch')
    BEGIN
	    DROP  Procedure  rpc_GetMushlamServicesByCodesSearch
    END

GO

CREATE Procedure dbo.rpc_GetMushlamServicesByCodesSearch
(
	@serviceCodes VARCHAR(100),
    @deptName VARCHAR(100),
    @cityCode INT,
    @districtCodes VARCHAR(100),
    @openAtHour VARCHAR(10),    
    @openFromHour VARCHAR(10),
    @openToHour VARCHAR(10),
    @receptionDays VARCHAR(30)
)

AS

DECLARE @str VARCHAR(max)


SELECT * INTO #tempServices
FROM
(
	SELECT distinct ser.ServiceCode, MushlamServiceName + ' - ' + mtt.Description as MushlamServiceName, msi.PrivateRemark, msi.AgreementRemark, mtt.Description as TreatmentDescription
	FROM [Services] ser 
	INNER JOIN MushlamTreatmentTypesToSefer mtt ON ser.ServiceCode = mtt.SeferCode
	INNER JOIN MushlamServicesInformation msi ON mtt.ParentServiceID = msi.ServiceCode
	WHERE IsInMushlam = 1
	AND ser.ServiceCode IN
	(
		SELECT IntField
		FROM dbo.SplitString(@serviceCodes)
	)


	UNION

	SELECT distinct ser.ServiceCode, MushlamServiceName + ' - ' + ser.ServiceDescription, msi.PrivateRemark, msi.AgreementRemark, '' as TreatmentDescription
	FROM [Services] ser 
	INNER JOIN MushlamServicesToSefer mss on ser.ServiceCode = mss.SeferCode
	INNER JOIN MushlamServicesInformation msi ON mss.GroupCode = msi.GroupCode and mss.SubGroupCode = msi.SubGroupCode
	WHERE IsInMushlam = 1
	AND ser.ServiceCode IN
	(
		SELECT IntField
		FROM dbo.SplitString(@serviceCodes)
	)
) as t



SET @str =	'SELECT t.*, COUNT(*) as NumOfSuppliers
			FROM #tempServices t
			LEFT JOIN x_dept_employee_service xdes ON t.ServiceCode = xdes.ServiceCode 
			LEFT JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID 
			LEFT JOIN Dept d ON xd.DeptCode = d.DeptCode ' 


IF (@openAtHour <> '') OR (@openFromHour <> '') OR (@openToHour <> '') OR (@receptionDays <> '')
	SET @str = @str + 
			' LEFT JOIN DeptEmployeeReception der ON xdes.DeptEmployeeID = der.DeptEmployeeID 
			  LEFT JOIN DeptEmployeeReceptionServices ders ON der.ReceptionID = ders.ReceptionID AND xdes.ServiceCode = ders.ServiceCode ' 
			

SET @str = @str + 'WHERE (1=1) '


IF @deptName <> '' 
SET @str = @str +  ' AND d.DeptName LIKE ' + CHAR(39) + '%' + CHAR(39) + ' + ''' + @deptName + ''' + ' + CHAR(39) + '%' + CHAR(39)


IF @cityCode IS NOT NULL 
SET @str = @str +  ' AND d.CityCode = ' + CONVERT(VARCHAR,@cityCode)

IF @districtCodes <> ''
SET @str = @str +  ' AND d.districtCode IN (Select IntField from dbo.SplitString(' + @districtCodes + ')) '


IF @openAtHour <> ''
BEGIN
	DECLARE @openAtHour_real REAL
	SET @openAtHour_real = CAST (LEFT(@openAtHour,2) as real) + CAST (RIGHT(@openAtHour,2) as real)/60 
	SET @str = @str + ' 
				AND (Cast(Left(der.openingHour,2) as real) + Cast(Right(der.openingHour,2) as real)/60) <= ' + CHAR(39) + CONVERT(VARCHAR,@openAtHour_real) + CHAR(39) + '
				AND (Cast(Left(der.closingHour,2) as real) + Cast(Right(der.closingHour,2) as real)/60) >= ' + CHAR(39) + CONVERT(VARCHAR,@openAtHour_real) + CHAR(39) 
END


IF (@openFromHour <> '') AND (@openToHour <> '')
BEGIN
	DECLARE @openFromHour_real REAL
	DECLARE @openToHour_real REAL
	SET @openFromHour_real = CAST (LEFT(@openFromHour,2) as real) + CAST (RIGHT(@openFromHour,2) as real)/60 
	SET @openToHour_real = CAST (LEFT(@openToHour,2) as real) + CAST (RIGHT(@openToHour,2) as real)/60 
	SET @str = @str +  ' AND (Cast(Left(der.openingHour,2) as real) + Cast(Right(der.openingHour,2) as real)/60) <= ' + CHAR(39) + CONVERT(VARCHAR,@openFromHour_real) + CHAR(39)
					+  ' AND (Cast(Left(der.closingHour,2) as real) + Cast(Right(der.closingHour,2) as real)/60) >= ' + CHAR(39) + CONVERT(VARCHAR,@openToHour_real) + CHAR(39)
END

IF @receptionDays <> ''
	SET @str = @str + ' AND der.ReceptionDay IN (SELECT IntField FROM dbo.SplitString(' + @receptionDays + '))'



SET @str = @str  + ' AND (xd.AgreementType IN (3,4) OR xd.AgreementType IS NULL)
					GROUP BY  t.ServiceCode, t.MushlamServiceName, treatmentDescription, t.PrivateRemark, t.AgreementRemark
					ORDER BY treatmentDescription, MushlamServiceName'



EXEC(@str)
		        
GO



GRANT EXEC ON rpc_GetMushlamServicesByCodesSearch TO PUBLIC

GO            
            

-- *******************************************************************************************************
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_GetMushlamServiceExtendedSearch]') AND type in (N'P', N'PC'))
    BEGIN
	    DROP  Procedure  rpc_GetMushlamServiceExtendedSearch
    END

GO

CREATE Procedure dbo.rpc_GetMushlamServiceExtendedSearch
(
	@searchText VARCHAR(100),
    @deptName VARCHAR(100),
    @cityCode INT,
    @districtCodes VARCHAR(100),
    @openAtHour VARCHAR(10),    
    @openFromHour VARCHAR(10),
    @openToHour VARCHAR(10),
    @receptionDays VARCHAR(30),
    @deptCode int 
)

AS

DECLARE @str VARCHAR(MAX)


-- services
SELECT * INTO #tempServices
FROM
(
	SELECT distinct msi.ServiceCode, msi.ServiceCode as ParentCode, msi.MushlamServiceName, msi.PrivateRemark, msi.AgreementRemark
	FROM [Services] ser
	INNER JOIN MushlamServicesToSefer msts  ON ser.ServiceCode = msts.SeferCode
	INNER JOIN MushlamServicesInformation msi ON msts.GroupCode = msi.GroupCode AND msts.SubGroupCode = msi.SubGroupCode
	WHERE IsInMushlam = 1
	AND (ServiceDescription LIKE '%' + @searchText + '%' 
		 OR ShowExpert LIKE '%' + @searchText + '%'
		 OR GeneralRemark LIKE '%' + @searchText + '%'
		 OR MushlamServiceName LIKE '%' + @searchText + '%')


	UNION

	-- synonyms
	SELECT msi.ServiceCode, msi.ServiceCode as parentCode, msi.MushlamServiceName, msi.PrivateRemark, msi.AgreementRemark
	FROM MushlamServiceSynonyms syn
	INNER JOIN MushlamServicesInformation msi ON syn.GroupCode = msi.GroupCode AND syn.SubGroupCode = msi.SubGroupCode
	WHERE syn.ServiceSynonym like '%' + @searchText + '%'

	UNION

	-- treatment types
	SELECT treat.SeferCode as serviceCode, treat.ParentServiceID as ParentCode, msi.MushlamServiceName + ' - ' + treat.Description, msi.PrivateRemark, msi.AgreementRemark
	FROM MushlamTreatmentTypesToSefer treat
	INNER JOIN MushlamServicesInformation msi ON  Treat.ParentServiceID = msi.ServiceCode 
	WHERE Treat.Description like '%' + @searchText + '%'   

) as x



SET @str =	'SELECT t.*, COUNT(' + CASE WHEN @openAtHour <> '' OR  @openFromHour <> '' OR @openToHour <> '' OR @receptionDays <> '' 
											THEN 'der.DeptEmployeeID'
										ELSE 
											CASE WHEN @cityCode <> '' OR @districtCodes <> '' OR @deptName <> '' OR @deptCode IS NOT NULL
													THEN 'd.DeptCode'
												 ELSE '*'
											END
										END + ') as NumOfSuppliers
			FROM #tempServices t
			LEFT JOIN x_dept_employee_service xdes ON t.ServiceCode = xdes.ServiceCode 			
			LEFT JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID 
			LEFT JOIN Dept d ON xd.DeptCode = d.DeptCode ' 


IF @deptName <> ''
SET @str = @str +  ' AND d.DeptName LIKE ' + CHAR(39) + '%' + CHAR(39) + ' + ''' + @deptName + ''' + ' + CHAR(39) + '%' + CHAR(39)


IF @cityCode <> ''
SET @str = @str +  ' AND d.CityCode = ' + CONVERT(VARCHAR,@cityCode)


IF @districtCodes <> ''
SET @str = @str +  ' AND d.districtCode IN (Select IntField from dbo.SplitString(' + @districtCodes + ')) '

if @deptCode is not null
SET @str = @str +  ' AND d.deptCode = ' + CONVERT(VARCHAR,@deptCode)


IF (@openAtHour <> '') OR (@openFromHour <> '') OR (@openToHour <> '') OR (@receptionDays <> '')
BEGIN
	SET @str = @str + 
			' LEFT JOIN 
			( SELECT der.DeptEmployeeID 
			  FROM DeptEmployeeReception der 
			  WHERE (1=1) ' 


	IF @openAtHour <> ''
	BEGIN
		DECLARE @openAtHour_real REAL
		SET @openAtHour_real = CAST (LEFT(@openAtHour,2) as real) + CAST (RIGHT(@openAtHour,2) as real)/60 
		SET @str = @str + ' 
					AND (Cast(Left(der.openingHour,2) as real) + Cast(Right(der.openingHour,2) as real)/60) <= ' + CHAR(39) + CONVERT(VARCHAR,@openAtHour_real) + CHAR(39) + '
					AND (Cast(Left(der.closingHour,2) as real) + Cast(Right(der.closingHour,2) as real)/60) >= ' + CHAR(39) + CONVERT(VARCHAR,@openAtHour_real) + CHAR(39) 
	END


	IF (@openFromHour <> '') AND (@openToHour <> '')
	BEGIN
		DECLARE @openFromHour_real REAL
		DECLARE @openToHour_real REAL
		SET @openFromHour_real = CAST (LEFT(@openFromHour,2) as real) + CAST (RIGHT(@openFromHour,2) as real)/60 
		SET @openToHour_real = CAST (LEFT(@openToHour,2) as real) + CAST (RIGHT(@openToHour,2) as real)/60 
		SET @str = @str +  ' AND (Cast(Left(der.openingHour,2) as real) + Cast(Right(der.openingHour,2) as real)/60) <= ' + CHAR(39) + CONVERT(VARCHAR,@openFromHour_real) + CHAR(39)
						+  ' AND (Cast(Left(der.closingHour,2) as real) + Cast(Right(der.closingHour,2) as real)/60) >= ' + CHAR(39) + CONVERT(VARCHAR,@openToHour_real) + CHAR(39)
	END

	IF @receptionDays <> ''
		SET @str = @str + ' AND der.ReceptionDay IN (SELECT IntField FROM dbo.SplitString(' + @receptionDays + '))'


	SET @str = @str + ' GROUP BY der.DeptEmployeeID) as der ON xdes.DeptEmployeeID = der.DeptEmployeeID ' 
END


			  
			

SET @str = @str + ' WHERE xd.AgreementType IN (3,4) OR xd.AgreementType IS NULL'




SET @str = @str  + ' GROUP BY t.serviceCode, t.ParentCode, t.MushlamServiceName, t.PrivateRemark, t.AgreementRemark
					ORDER BY MushlamServiceName'

EXEC (@str) 






                
GO


GRANT EXEC ON rpc_GetMushlamServiceExtendedSearch TO PUBLIC

GO            

-- *******************************************************************************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetMushlamServiceByCode')
    BEGIN
	    DROP  Procedure  rpc_GetMushlamServiceByCode
    END

GO

CREATE Procedure dbo.rpc_GetMushlamServiceByCode
(
	@serviceCode INT
)

AS


SELECT ser.ServiceCode, msi.MushlamServiceName, GeneralRemark, AgreementRemark, PrivateRemark,
'LinkedSalServices' = (	SELECT ';' + CONVERT(VARCHAR,ServiceCode) + '#' + ServiceName
						FROM MushlamServicesToSal msts						
						INNER JOIN SalServices ON msts.SalServiceCode = SalServices.serviceCode
						WHERE msts.MushlamGroupCode = msi.GroupCode AND msts.MushlamSubGroupCode = msi.SubGroupCode
						FOR XML PATH('')
					   ),
RepRemark
FROM [Services] ser
INNER JOIN MushlamTreatmentTypesToSefer mtt ON ser.ServiceCode = mtt.SeferCode
INNER JOIN MushlamServicesInformation msi ON mtt.ParentServiceID = msi.ServiceCode
WHERE ser.ServiceCode = @serviceCode
AND ser.IsInMushlam = 1

UNION

SELECT ser.ServiceCode, msi.MushlamServiceName, GeneralRemark, AgreementRemark, PrivateRemark,
'LinkedSalServices' = (	SELECT ';' + CONVERT(VARCHAR,ServiceCode) + '#' + ServiceName
						FROM MushlamServicesToSal msts						
						INNER JOIN SalServices ON msts.SalServiceCode = SalServices.serviceCode
						WHERE msts.MushlamGroupCode = msi.GroupCode AND msts.MushlamSubGroupCode = msi.SubGroupCode
						FOR XML PATH('')
					   ),
RepRemark
FROM [Services] ser 
INNER JOIN MushlamServicesToSefer mss on ser.ServiceCode = mss.SeferCode
INNER JOIN MushlamServicesInformation msi ON mss.GroupCode = msi.GroupCode and mss.SubGroupCode = msi.SubGroupCode
WHERE IsInMushlam = 1
AND ser.ServiceCode = @serviceCode



    
GO


GRANT EXEC ON rpc_GetMushlamServiceByCode TO PUBLIC

GO            

-- *******************************************************************************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeptOverView')
	BEGIN
		DROP  Procedure  rpc_DeptOverView		
	END

GO

create Procedure [dbo].[rpc_DeptOverView]
(
	@DeptCode int
)

AS

    DECLARE @p_str VARCHAR(500)
    SET @p_str = ''

DECLARE @CurrentDate datetime = getdate()
DECLARE @ExpirationDate datetime = DATEADD(day, DATEDIFF(day, 0, @CurrentDate), 0) 
DECLARE @DateAfterExpiration datetime = DATEADD(day, 1, DATEADD(day, DATEDIFF(day, 0, @CurrentDate), 0))


SELECT 
Dept.deptCode,
Dept.deptName,
Dept.typeUnitCode,
Dept.subUnitTypeCode,
Dept.IsCommunity,
Dept.IsMushlam,
Dept.IsHospital,
UnitType.UnitTypeName,
'subUnitTypeName' = '(' + View_SubUnitTypes.subUnitTypeName + ')' ,
'managerName' = dbo.fun_getManagerName(Dept.deptCode) , 
'administrativeManagerName' = dbo.fun_getAdminManagerName(Dept.deptCode),
Dept.districtCode,
'additionaDistrictNames' = dbo.fun_GetAdditionalDistrictNames(@deptCode), 
View_AllDistricts.districtName,
Cities.cityName,
Dept.streetName as 'street',
Dept.house,
Dept.floor,
Dept.flat,
Dept.addressComment,
Dept.email,
'showEmailInInternet' = isNull(Dept.showEmailInInternet, 0),
'address' = dbo.GetAddress(Dept.deptCode),
--'simpleAddress' = CASE RTRIM(LTRIM(isNull(house, ''))) 
--	WHEN '' THEN isNull(streetName,'') ELSE (isNull(streetName + ', ', '') + CAST(house as varchar(3)) ) END 
--	+
--	ISNULL(CASE WHEN Dept.IsSite = 1 THEN Atarim.InstituteName ELSE Neighbourhoods.NybName END, ''),

'simpleAddress' = isNull(streetName,'')  
	+ CASE WHEN house IS NULL THEN '' WHEN house = '0' THEN '' ELSE ', ' + CAST(house as varchar(5)) END
	+ ISNULL(CASE WHEN Dept.IsSite = 1 THEN Atarim.InstituteName ELSE Neighbourhoods.NybName END, ''),

DIC_ParkingInClinic.parkingInClinicDescription as 'parking',
PopulationSectors.PopulationSectorDescription,
DIC_ActivityStatus.statusDescription,
Dept.transportation,
Dept.administrationCode,
View_AllAdministrations.AdministrationName,
Dept.subAdministrationCode,
subAdmin.SubAdministrationName as subAdministrationName,
DeptSimul.Simul228, 
'phonesForQueueOrder' = dbo.fun_getDeptQueueOrderPhones_All(@DeptCode),
'QueueOrderDescription' = IsNull(DIC_QueueOrder.QueueOrderDescription, '&nbsp;'),					
'HasQueueOrder' = CASE IsNull(Dept.QueueOrder,0) WHEN 0 THEN 0 ELSE 1 END,
deptLevelDescription,
View_SubUnitTypes.DefaultReceptionHoursTypeID

FROM Dept 
INNER JOIN UnitType on Dept.typeUnitCode = UnitType.UnitTypeCode
INNER JOIN DIC_deptLevel on Dept.deptLevel = DIC_deptLevel.deptLevelCode
LEFT JOIN View_SubUnitTypes on Dept.subUnitTypeCode = View_SubUnitTypes.subUnitTypeCode
	AND Dept.typeUnitCode = View_SubUnitTypes.UnitTypeCode
LEFT JOIN View_AllDistricts on Dept.districtCode = View_AllDistricts.districtCode
INNER JOIN Cities on Dept.cityCode = Cities.cityCode
INNER JOIN DIC_ActivityStatus on Dept.status = DIC_ActivityStatus.status
LEFT JOIN View_AllAdministrations on Dept.administrationCode = View_AllAdministrations.AdministrationCode --!!
LEFT JOIN View_SubAdministrations  as subAdmin on Dept.subAdministrationCode = subAdmin.SubAdministrationCode
LEFT JOIN DeptSimul on dept.deptCode = deptSimul.deptCode
LEFT JOIN DIC_ParkingInClinic ON dept.parking = DIC_ParkingInClinic.parkingInClinicCode
LEFT JOIN PopulationSectors ON dept.populationSectorCode = PopulationSectors.PopulationSectorID
LEFT JOIN DIC_QueueOrder ON Dept.QueueOrder = DIC_QueueOrder.QueueOrder
LEFT JOIN Atarim ON Dept.NeighbourhoodOrInstituteCode = Atarim.InstituteCode
LEFT JOIN Neighbourhoods ON Dept.NeighbourhoodOrInstituteCode = Neighbourhoods.NeighbourhoodCode

WHERE dept.deptCode= @DeptCode

-- closest added reception dates   ***************************

SELECT 
'LastUpdateDateOfDept' = 
(
	SELECT MAX(d)
	FROM
	(SELECT updateDate as d FROM dept WHERE deptCode = @DeptCode 
	 UNION
	 SELECT ISNULL(MAX(updateDate),'01/01/1900') as d FROM View_Remarks WHERE deptCode = @deptCode
	) as x
),
'DeptReceptionUpdateDate' = 
(SELECT 
MAX(updateDate) AS deptReceptionUpdateDate
FROM DeptReception
WHERE deptCode = @deptCode
and (
			(   
				((validFrom IS not NULL and  validTo IS NULL) and (@CurrentDate >= validFrom ))			
				or ((validFrom IS NULL and validTo IS not NULL) and validTo >= @CurrentDate)
				or ((validFrom IS not NULL and  validTo IS not NULL) and (@CurrentDate >= validFrom and validTo >= @CurrentDate))
		
			)
			OR (validFrom IS NULL AND validTo IS NULL)
	 )
)
FROM 
		(SELECT MIN(ValidFrom) as ValidFrom FROM DeptReception 
		 inner join vReceptionDaysForDisplay on receptionDay = ReceptionDayCode
		 WHERE DeptCode = @deptCode 
		 AND DATEDIFF(dd, ValidFrom, @CurrentDate) < 0 
		 AND DATEDIFF(dd, ValidFrom, @CurrentDate) >= -14
		 ) as dr


-- Clinic HandicappedFacilities ***************************
SELECT
DIC_HandicappedFacilities.FacilityDescription
FROM DIC_HandicappedFacilities
INNER JOIN DeptHandicappedFacilities 
	ON DIC_HandicappedFacilities.FacilityCode = DeptHandicappedFacilities.FacilityCode
WHERE DeptHandicappedFacilities.deptCode = @DeptCode

--------- generalRemarks (Clinic General Remarks) ***************************

--- julia
SELECT remarkID
, dbo.rfn_GetFotmatedRemark(RemarkText) as RemarkText
, validFrom
, validTo
, displayInInternet
, RemarkDeptCode as deptCode
, View_DeptRemarks.IsSharedRemark as 'sweeping' 
, ShowOrder
FROM View_DeptRemarks
LEFT JOIN Dept ON View_DeptRemarks.deptCode = Dept.deptCode
WHERE View_DeptRemarks.deptCode = @deptCode
AND validFrom < @DateAfterExpiration AND ( validTo is null OR validTo >= @ExpirationDate )
AND (IsSharedRemark = 0 OR Dept.IsCommunity = 1) 
ORDER BY sweeping desc ,ShowOrder asc 
--- end block julia

------- "DeptQueueOrderMethods" (Employee Queue Order Methods) ***************************
SELECT 
DeptQueueOrderMethod.QueueOrderMethodID,
DeptQueueOrderMethod.QueueOrderMethod,
DIC_QueueOrderMethod.QueueOrderMethodDescription,
DIC_QueueOrderMethod.ShowPhonePicture,
DIC_QueueOrderMethod.SpecialPhoneNumberRequired

FROM DeptQueueOrderMethod
INNER JOIN DIC_QueueOrderMethod ON DeptQueueOrderMethod.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
WHERE deptCode = @DeptCode
ORDER BY QueueOrderMethod

------- "HoursForDeptQueueOrder" (Hours for Dept Queue Order via Phone) ***************************
SELECT
--DeptQueueOrderMethod.deptCode,
DeptQueueOrderHoursID,
DeptQueueOrderHours.QueueOrderMethodID,
DeptQueueOrderHours.receptionDay,
ReceptionDayName,
FromHour,
ToHour
FROM DeptQueueOrderHours
INNER JOIN vReceptionDaysForDisplay ON DeptQueueOrderHours.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode
INNER JOIN DeptQueueOrderMethod ON DeptQueueOrderHours.QueueOrderMethodID = DeptQueueOrderMethod.QueueOrderMethodID
WHERE DeptQueueOrderMethod.deptCode = @DeptCode
ORDER BY vReceptionDaysForDisplay.ReceptionDayCode, FromHour

-- mushlam services
SELECT msi.ServiceCode, msi.MushlamServiceName as ServiceName
FROM x_dept_employee_service xdes
INNER JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID 
INNER JOIN MushlamServicesToSefer msts on xdes.ServiceCode = msts.SeferCode
INNER JOIN MushlamServicesInformation msi on msts.SeferCode = msi.ServiceCode
WHERE xd.DeptCode = @deptCode
AND xd.AgreementType IN (3,4)

UNION 

SELECT msi.ServiceCode, msi.MushlamServiceName + ' - ' + mtts.Description as ServiceName
FROM x_dept_employee_service xdes
INNER JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID 
INNER JOIN MushlamTreatmentTypesToSefer mtts ON xdes.serviceCode = mtts.SeferCode
INNER JOIN MushlamServicesInformation msi on mtts.ParentServiceID = msi.ServiceCode
WHERE xd.DeptCode = @deptCode
AND xd.AgreementType IN (3,4)
ORDER BY msi.MushlamServiceName



-- DeptPhones   ***************************
SELECT
deptCode, DeptPhones.phoneType, phoneOrder, 
'phone' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension),
'ShortPhoneTypeName' = CASE DeptPhones.phoneType WHEN 2 THEN 'פקס' ELSE 'טל`' END
FROM DeptPhones
WHERE deptCode = @DeptCode
ORDER BY DeptPhones.phoneType, phoneOrder



GO


GRANT EXEC ON rpc_DeptOverView TO PUBLIC
GO


-- *******************************************************************************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDeptServices')
	BEGIN
		drop procedure rpc_GetDeptServices
	END

GO

CREATE Procedure [dbo].[rpc_GetDeptServices]
(
	@DeptCode int
)
as

DECLARE @CurrentDate datetime = getdate()
DECLARE @ExpirationDate datetime = DATEADD(day, DATEDIFF(day, 0, @CurrentDate), 0) 
DECLARE @DateAfterExpiration datetime = DATEADD(day, 1, DATEADD(day, DATEDIFF(day, 0, @CurrentDate), 0))
------ DeptEmployeePositions  ***************************
SELECT
xd.employeeID,
xd.DeptEmployeeID,
xdep.positionCode,
position.positionDescription

FROM x_Dept_Employee_Position as xdep
INNER JOIN x_Dept_Employee xd ON xdep.deptEmployeeID = xd.deptEmployeeID	
INNER JOIN position ON xdep.positionCode = position.positionCode
INNER JOIN employee ON xd.employeeID = employee.employeeID
WHERE xd.deptCode = @deptCode
AND ((employee.sex = 0 AND position.gender = 1) OR ( employee.sex <> 0 AND employee.sex = position.gender))

------ DeptEmployeeProfessions
SELECT
xd.employeeID,
xd.DeptEmployeeID,
xdes.ServiceCode as 'professionCode',
[Services].ServiceDescription as professionDescription,
--Employee.EmployeeSectorCode as EmployeeSector,

'EmployeeSector' = CASE 
WHEN (SELECT TOP 1 EmployeeSectorCode		
		FROM x_Services_EmployeeSector xses
		WHERE Employee.EmployeeSectorCode <> xses.EmployeeSectorCode
		AND xses.ServiceCode = xdes.ServiceCode) IS NULL 
THEN Employee.EmployeeSectorCode
ELSE (SELECT TOP 1 CASE WHEN [Services].SectorToShowWith IS NULL THEN EmployeeSectorCode ELSE [Services].SectorToShowWith END
		FROM x_Services_EmployeeSector xSES
		JOIN [Services] ON xSES.ServiceCode = [Services].ServiceCode
		WHERE Employee.EmployeeSectorCode <> xSES.EmployeeSectorCode
		AND xSES.ServiceCode = xdes.ServiceCode)
END,

dbo.fun_GetEmployeeServiceSector(xd.employeeID, xdes.serviceCode) as Sector
FROM x_Dept_Employee_Service as xdes
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
INNER JOIN Employee ON xd.EmployeeId = Employee.EmployeeID
INNER JOIN [Services] ON xdes.ServiceCode = [Services].ServiceCode
WHERE xd.deptCode = @DeptCode
AND [Services].IsProfession = 1

ORDER BY employeeID, ServiceDescription

-- DeptEmployeeServices (Employee's services) ***************************
SELECT 
employeeID, xdes.serviceCode, serviceDescription, xd.DeptEmployeeID,
dbo.fun_GetEmployeeServiceSector(xd.employeeID, xdes.serviceCode) as Sector
FROM x_Dept_Employee_Service as xdes
INNER JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
INNER JOIN [Services] ON xdes.serviceCode = [Services].serviceCode
WHERE xd.deptCode = @DeptCode
AND Status = 1
AND [Services].IsService = 1

------- "EmployeeQueueOrderMethods" (Employee Queue Order Methods) ***************************
SELECT 
EQOM.QueueOrderMethod,
xd.DeptEmployeeID,
'serviceCode' = 0,
DIC_QueueOrderMethod.QueueOrderMethodDescription,
DIC_QueueOrderMethod.ShowPhonePicture,
DIC_QueueOrderMethod.SpecialPhoneNumberRequired

FROM EmployeeQueueOrderMethod EQOM
INNER JOIN DIC_QueueOrderMethod ON EQOM.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
INNER JOIN x_dept_employee xd ON EQOM.DeptEmployeeID = xd.DeptEmployeeID	
WHERE xd.deptCode = @DeptCode

UNION

SELECT 
esqom.QueueOrderMethod,
xd.DeptEmployeeID,
xdes.serviceCode,
DIC_QueueOrderMethod.QueueOrderMethodDescription,
DIC_QueueOrderMethod.ShowPhonePicture,
DIC_QueueOrderMethod.SpecialPhoneNumberRequired

FROM EmployeeServiceQueueOrderMethod esqom
INNER JOIN x_Dept_Employee_Service xdes ON esqom.x_dept_employee_serviceID = xdes.x_dept_employee_serviceID
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
INNER JOIN DIC_QueueOrderMethod ON esqom.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
WHERE xd.deptCode = @DeptCode

UNION

-- get all cases where queue order is regular, but need to display with special icon
SELECT 
'5' as 'QueueOrderMethod',
xd.DeptEmployeeID,
xdes.serviceCode,
null,
null,
null


FROM x_Dept_Employee_Service xdes 
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
WHERE xd.deptCode = @DeptCode
AND xd.QueueOrder = 4 


ORDER BY QueueOrderMethod

------- "HoursForEmployeeQueueOrder" (Hours for Employee Queue Order via Phone) ***************************
SELECT
xd.deptCode,
xd.employeeID,
xd.DeptEmployeeID,
0 as serviceCode,
eqoh.receptionDay,
ReceptionDayName,
FromHour,
ToHour,
vReceptionDaysForDisplay.ReceptionDayCode

FROM EmployeeQueueOrderHours eqoh
INNER JOIN vReceptionDaysForDisplay ON eqoh.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode
INNER JOIN EmployeeQueueOrderMethod eqom ON eqoh.QueueOrderMethodID = eqom.QueueOrderMethodID
INNER JOIN x_dept_employee xd ON eqom.DeptEmployeeID = xd.DeptEmployeeID
WHERE xd.deptCode = @DeptCode

UNION

SELECT 
xd.deptCode,
xd.employeeID,
xd.DeptEmployeeID,
xdes.serviceCode,
esqoh.ReceptionDay,
ReceptionDayName,
FromHour,
ToHour,
vReceptionDaysForDisplay.ReceptionDayCode

FROM EmployeeServiceQueueOrderHours esqoh
INNER JOIN vReceptionDaysForDisplay ON esqoh.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode
INNER JOIN EmployeeServiceQueueOrderMethod esqom ON esqoh.EmployeeServiceQueueOrderMethodID = esqom.EmployeeServiceQueueOrderMethodID
INNER JOIN x_Dept_Employee_Service xdes ON esqom.x_Dept_Employee_ServiceID = xdes.x_Dept_Employee_ServiceID
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
WHERE xd.deptCode = @DeptCode
ORDER BY ReceptionDayCode, FromHour

-- "EmployeeOtherPlaces" (Employee's Other work places)  ************************************
SELECT
'ToggleID' = x_dept_employee.deptCode + x_dept_employee.employeeID,
x_dept_employee.deptCode, 
Dept.deptName, 
x_dept_employee.employeeID, 
'DoctorName' = DegreeName + ' ' + lastName + ' ' + firstName,
'deptCodePlusEmployeeID' = x_dept_employee.deptCode + x_dept_employee.employeeID,
x_dept_employee.AgreementType,
'ReceptionDaysCount' = 
	(select count(receptionDay)
	FROM deptEmployeeReception
	WHERE deptEmployeeReception.DeptEmployeeID = x_dept_employee.DeptEmployeeID	
	and (
			(   
				((validFrom IS not NULL and  validTo IS NULL) and (@CurrentDate >= validFrom ))			
				or ((validFrom IS NULL and validTo IS not NULL) and validTo >= @CurrentDate)
				or ((validFrom IS not NULL and  validTo IS not NULL) and (@CurrentDate >= validFrom and validTo >= @CurrentDate))
		
			)
			OR (validFrom IS NULL AND validTo IS NULL)
		)
	),				
'PermitOrderMethods' = IsNull(DIC_QueueOrder.PermitOrderMethods, 0),
'HasRemarks' = (SELECT CASE MAX(x) WHEN 0 THEN 0 ELSE 1 END
				FROM
				(SELECT COUNT(*) as x 
				FROM View_DeptEmployee_EmployeeRemarks v
				WHERE v.employeeID = x_dept_employee.EmployeeID
				AND (DeptCode = dept.deptCode OR AttributedToAllClinicsInCommunity = 1)
				AND (v.ValidFrom is NULL OR v.ValidFrom < @DateAfterExpiration)
				AND (v.ValidTo is NULL OR v.ValidTo >= @ExpirationDate) 
				UNION
				SELECT COUNT(*) as x
				FROM DeptEmployeeServiceRemarks desr
				INNER JOIN x_Dept_Employee_Service xdes ON desr.x_dept_employee_serviceID = xdes.x_dept_employee_serviceID
				WHERE xdes.DeptEmployeeID = x_dept_employee.DeptEmployeeID
				AND (ValidFrom is NULL OR ValidFrom < @DateAfterExpiration)
				AND (ValidTo is NULL OR ValidTo >= @ExpirationDate)
				) as t
				)
FROM
x_dept_employee
INNER JOIN employee ON x_dept_employee.employeeID = employee.employeeID
INNER JOIN dept ON x_dept_employee.deptCode = dept.deptCode
INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode
LEFT JOIN DIC_QueueOrder ON x_dept_employee.QueueOrder = DIC_QueueOrder.QueueOrder

WHERE x_dept_employee.employeeID IN (SELECT employeeID FROM x_dept_employee WHERE deptCode = @DeptCode)
AND (employee.IsMedicalTeam = 0 OR employee.IsMedicalTeam IS NULL)
AND dept.status <> 0


-- EmployeeProfessionsAtOtherPlaces (Professions for Doctor's Other work places) ***************************
SELECT
xd.employeeID,
xd.deptCode,
xdes.ServiceCode,
[Services].ServiceDescription as professionDescription
FROM x_Dept_Employee_Service as xdes
INNER JOIN [Services] ON xdes.ServiceCode = [Services].ServiceCode
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
INNER JOIN Employee e ON xd.employeeID = e.employeeID
WHERE exists (SELECT employeeID FROM x_dept_employee WHERE deptCode = @DeptCode
				and x_dept_employee.employeeID = xd.employeeID)
AND [Services].IsProfession = 1
and e.IsMedicalTeam <> 1


-- EmployeeServicesAtOtherPlaces  ***************************
SELECT 
xd.deptCode, 
xd.employeeID, 
xdes.serviceCode, 
serviceDescription
FROM x_Dept_Employee_Service as xdes
INNER JOIN [Services] ON xdes.serviceCode = [Services].serviceCode
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID  = xd.DeptEmployeeID 
INNER JOIN Employee e ON xd.employeeID = e.employeeID
WHERE exists (SELECT employeeID FROM x_dept_employee WHERE deptCode = @DeptCode 
					and x_dept_employee.employeeID = xd.employeeID)
AND [Services].IsProfession = 0
and e.IsMedicalTeam <> 1


------------- "deptDoctors" (Doctors in Clinic) ***************************

SELECT	DISTINCT e.employeeID,
			xd.DeptEmployeeID, 
			xdes.ServiceCode,
			IsMedicalTeam,
			IsVirtualDoctor,
			AgreementType,
			'DoctorName' = LTRIM(RTRIM(DegreeName + ' ' + lastName + ' ' + firstName)),
			'expert' = dbo.fun_GetEmployeeExpert(xd.employeeID),
			'Phones' = dbo.fun_GetDeptEmployeeServicePhones(xd.DeptEmployeeID,xdes.serviceCode),
			'Faxes' = dbo.fun_GetDeptEmployeeServiceFaxes(xd.DeptEmployeeID,xdes.serviceCode),
			'active' = xd.active,
			'ActiveForSort' = CASE WHEN xd.active = 0 THEN 10 ELSE xd.active END,
			'EmployeeSectorCode' = CASE WHEN e.IsMedicalTeam = 1 
							then (SELECT TOP 1 CASE WHEN [Services].SectorToShowWith IS NULL 
											THEN e.EmployeeSectorCode 
											ELSE [Services].SectorToShowWith END
								FROM [Services]
								WHERE [Services].ServiceCode = xdes.ServiceCode)
							else e.EmployeeSectorCode
					   END,
			'QueueOrderDescription' = dbo.fun_GetDeptEmployeeServiceQueueOrderDescription(xdes.DeptEmployeeID, xdes.serviceCode),
			'hasAnotherWorkPlace' = IsNull((SELECT COUNT(*) 
											FROM x_Dept_Employee as xd2 
											INNER JOIN dept ON xd.deptCode = dept.deptCode 
											WHERE xd2.deptCode <> @DeptCode AND xd2.EmployeeID = xd.employeeID 
											AND e.IsMedicalTeam = 0 AND dept.status <> 0), 0),
			'HasRemarks' = (SELECT CASE MAX(x) WHEN 0 THEN 0 ELSE 1 END
							FROM
							(SELECT COUNT(*) as x 
							FROM View_DeptEmployee_EmployeeRemarks v
							WHERE v.employeeID = xd.EmployeeID
							AND (v.DeptCode = @DeptCode OR AttributedToAllClinicsInCommunity = 1)
							AND (v.ValidFrom is NULL OR v.ValidFrom < @DateAfterExpiration)
							AND (v.ValidTo is NULL OR v.ValidTo >= @ExpirationDate) 
							UNION
							SELECT COUNT(*) as x
							FROM DeptEmployeeServiceRemarks desr
							INNER JOIN x_Dept_Employee_Service xdes on desr.x_dept_employee_serviceID = xdes.x_Dept_Employee_ServiceID
							WHERE xdes.DeptEmployeeID = xd.DeptEmployeeID
							AND (ValidFrom is NULL OR ValidFrom < @DateAfterExpiration)
							AND (ValidTo is NULL OR ValidTo >= @ExpirationDate)
							) as t
							),
			'ReceptionDaysCount' = (SELECT Count(*) 
									FROM 
									(	
										SELECT receptionDay
										FROM deptEmployeeReception der
										INNER JOIN DeptEmployeeReceptionServices ders ON der.receptionID = ders.receptionID
										INNER JOIN x_dept_employee_service xdes2 ON ders.serviceCode = xdes2.serviceCode 
													AND xdes2.DeptEmployeeID = xd.DeptEmployeeID 
										WHERE der.DeptEmployeeID = xd.DeptEmployeeid
										AND xdes2.status = 1
										AND (
												(   
													((validFrom IS NOT NULL and  validTo IS NULL) and (@CurrentDate >= validFrom ))			
													or ((validFrom IS NULL and validTo IS not NULL) and validTo >= @CurrentDate)
													or ((validFrom IS NOT NULL and  validTo IS not NULL) and (@CurrentDate >= validFrom and validTo >= @CurrentDate))
		
												)
												OR (validFrom IS NULL AND validTo IS NULL)
											)
									) as t)
	INTO #tempDoctors			
	FROM x_Dept_Employee xd
	INNER JOIN Employee e on xd.employeeID = e.employeeID
	INNER JOIN DIC_EmployeeDegree ON e.degreeCode = DIC_EmployeeDegree.DegreeCode
	LEFT JOIN x_Dept_Employee_Service xdes on xd.DeptEmployeeID = xdes.DeptEmployeeID
	WHERE deptCode = @deptCode
	
	
	SELECT	DISTINCT xd.DeptEmployeeID, 
			 xdes.ServiceCode,
			'Phones' = dbo.fun_GetDeptEmployeeServicePhones(xd.DeptEmployeeID,xdes.serviceCode),
			'QueueOrderDescription' = dbo.fun_GetDeptEmployeeServiceQueueOrderDescription(xdes.DeptEmployeeID, xdes.serviceCode),
			'QueueOrderMethod' = dbo.fun_GetEmployeeServiceQueueOrderMethod(xdes.DeptEmployeeID, xdes.serviceCode),
			'QueueOrderPhone' = dbo.fun_GetEmployeeServiceQueueOrderPhones(xdes.DeptEmployeeID , xdes.serviceCode),
			'EmployeeSectorCode' = CASE WHEN e.IsMedicalTeam = 1 
						then (SELECT TOP 1 CASE WHEN [Services].SectorToShowWith IS NULL 
											THEN e.EmployeeSectorCode 
											ELSE [Services].SectorToShowWith END
							FROM [Services]
							WHERE [Services].ServiceCode = xdes.ServiceCode)
						else e.EmployeeSectorCode
					   END
	INTO #tempGroup
	FROM x_Dept_Employee xd
	INNER JOIN Employee e on xd.employeeID = e.employeeID
	INNER JOIN DIC_EmployeeDegree ON e.degreeCode = DIC_EmployeeDegree.DegreeCode
	LEFT JOIN x_Dept_Employee_Service xdes on xd.DeptEmployeeID = xdes.DeptEmployeeID
	WHERE deptCode = @deptCode		
	

	SELECT	DeptEmployeeID, 
			 stuff((SELECT ',' + CONVERT(VARCHAR,ServiceCode) 
			 FROM #tempGroup tgd2
			 WHERE tgd2.DeptEmployeeID = tgd.DeptEmployeeID
			 AND tgd2.Phones = tgd.Phones
			 AND tgd2.QueueOrderPhone = tgd.QueueOrderPhone
			 AND tgd2.EmployeeSectorCode = tgd.EmployeeSectorCode
			 AND tgd2.QueueOrderDescription = tgd.QueueOrderDescription
			 AND tgd2.QueueOrderMethod = tgd.QueueOrderMethod
			 for xml path ('')
			 ), 1, 1, '') as 'Services', 

			 stuff((SELECT ',' + CONVERT(VARCHAR,ServiceDescription) 
			 FROM #tempGroup tgd2
			 INNER JOIN [services] ser on tgd2.ServiceCode = ser.serviceCode
			 WHERE tgd2.DeptEmployeeID = tgd.DeptEmployeeID
			 AND tgd2.Phones = tgd.Phones
			 AND tgd2.QueueOrderPhone = tgd.QueueOrderPhone
			 AND tgd2.EmployeeSectorCode = tgd.EmployeeSectorCode
			 AND tgd2.QueueOrderDescription = tgd.QueueOrderDescription
			 AND tgd2.QueueOrderMethod = tgd.QueueOrderMethod
			 AND ser.IsService = 1
			 order by serviceDescription
			 for xml path ('')
			 ), 1, 1, '') as 'ServiceDescription', 

			 stuff((SELECT ',' + CONVERT(VARCHAR,ServiceDescription) 
			 FROM #tempGroup tgd2
			 INNER JOIN [services] ser on tgd2.ServiceCode = ser.serviceCode
			 WHERE tgd2.DeptEmployeeID = tgd.DeptEmployeeID
			 AND tgd2.Phones = tgd.Phones
			 AND tgd2.QueueOrderPhone = tgd.QueueOrderPhone
			 AND tgd2.EmployeeSectorCode = tgd.EmployeeSectorCode
			 AND tgd2.QueueOrderDescription = tgd.QueueOrderDescription
			 AND tgd2.QueueOrderMethod = tgd.QueueOrderMethod
			 AND ser.IsProfession = 1
			 order by serviceDescription
			 for xml path ('')
			 ), 1, 1, '') as 'Professions', 

			Phones, QueueOrderDescription, QueueOrderPhone, EmployeeSectorCode					
	INTO #tempGroupingDoctors		
	FROM #tempGroup tgd
	GROUP BY DeptEmployeeID , Phones, QueueOrderDescription, QueueOrderPhone, QueueOrderMethod, EmployeeSectorCode




	-- actual select
	SELECT	DISTINCT td.employeeID, td.DeptEmployeeID, 
			'ToggleID' = REPLACE(CONVERT(VARCHAR,td.DeptEmployeeID) + CONVERT(VARCHAR,tgd.[Services]), ',',  ''), 
			td.DoctorName, td.expert, td.Phones, td.Faxes,
			td.EmployeeSectorCode, td.Active, td.ActiveForSort, td.IsMedicalTeam, td.IsVirtualDoctor, 
			tgd.[Services], tgd.ServiceDescription, tgd.Professions,
			td.QueueOrderDescription, QueueOrderPhone, HasAnotherWorkPlace, AgreementType, ReceptionDaysCount, HasRemarks
	FROM #tempDoctors td
	INNER JOIN #tempGroupingDoctors tgd on td.DeptEmployeeID = tgd.DeptEmployeeID
	AND td.Phones = tgd.Phones
	AND td.EmployeeSectorCode = tgd.EmployeeSectorCode
	AND (td.ServiceCode in (SELECT IntField FROM dbo.SplitString(tgd.[Services])) OR td.ServiceCode IS NULL)
	ORDER BY EmployeeSectorCode DESC, DoctorName
	
------- deptEventPhones (Dept Event Phones) ***************************
SELECT
DeptEventID,
phoneOrder,
'phone' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension),
'shortPhoneTypeName' = CASE DeptEventPhones.phoneType WHEN 2 THEN 'פקס' ELSE 'טל`' END

FROM DeptEventPhones
WHERE DeptEventID IN 
	(SELECT DeptEventID FROM DeptEvent 
	WHERE deptCode = @deptCode
	--AND ( @CurrentDate >= FromDate and ToDate >= @CurrentDate)
	)
	
-- DeptPhones   ***************************
SELECT
deptCode, DeptPhones.phoneType, phoneOrder, 
'phone' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension),
'ShortPhoneTypeName' = CASE DeptPhones.phoneType WHEN 2 THEN 'פקס' ELSE 'טל`' END
FROM DeptPhones
WHERE deptCode = @DeptCode
ORDER BY DeptPhones.phoneType, phoneOrder

----- deptEvents (Clinic Events) ***************************
SELECT
DeptEventID,
DIC_Events.EventName,
MeetingsNumber,
EventDescription,
'RepeatingEvent' = CAST(RepeatingEvent as bit),
'RegistrationStatus' = registrationStatusDescription,
'Active' = CASE WHEN (DATEDIFF(dd, FromDate, @CurrentDate) >= 0 AND DATEDIFF(dd, ToDate, @CurrentDate) <= 0 )
		   THEN 1
		   ELSE 0
		   END,
DIC_DeptEventPayOrder.PayOrderDescription,
DIC_DeptEventPayOrder.Free,
CommonPrice,
MemberPrice,
FullMemberPrice,
'TargetPopulation' = CASE IsNull(TargetPopulation, '') WHEN '' THEN '&nbsp;' ELSE TargetPopulation END,
Remark,
displayInInternet,
CascadeUpdatePhonesFromClinic as 'ShowPhonesFromDept'
FROM DeptEvent
LEFT JOIN DIC_DeptEventPayOrder ON DeptEvent.PayOrder = DIC_DeptEventPayOrder.PayOrder
INNER JOIN DIC_Events ON DeptEvent.EventCode = DIC_Events.EventCode
INNER JOIN DIC_RegistrationStatus ON DeptEvent.registrationStatus = DIC_RegistrationStatus.registrationStatus
WHERE deptCode = @DeptCode 
AND DIC_Events.IsActive = 1
ORDER BY Active DESC, DIC_Events.EventName ASC

GO

GRANT EXEC ON rpc_GetDeptServices TO PUBLIC
GO

-- *******************************************************************************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_DeptAndServicesRemarks')
	BEGIN
		DROP  Procedure  dbo.rprt_DeptAndServicesRemarks
	END
GO

CREATE Procedure dbo.rprt_DeptAndServicesRemarks
(
	 @DistrictCodes varchar(max)=null,
	 @AdminClinicCode varchar(max)=null,	
	 @UnitTypeCodes varchar(max)=null,
	 @SubUnitTypeCodes varchar(max)=null,
	 @SectorCodes varchar(max)=null,
	 @RemarkType_cond varchar(max)=null,
	 @Remark_cond varchar(max)=null,
	 @IsConstantRemark_cond varchar(max)=null,
	 @IsSharedRemark_cond varchar(max)=null,
	 @ShowRemarkInInternet_cond varchar(max)=null,
	 @IsFutureRemark_cond varchar(max)=null,
	 @Membership_cond varchar(max)=null, 
	 
	@district varchar (2)= null,	
	@adminClinic varchar (2) = null ,		
	@ClinicName varchar (2)= null,
	@ClinicCode varchar (2)= null,
	@simul varchar (2)=null,
	@unitType varchar (2)=null,		
	@subUnitType varchar (2)=null,	
	@sector varchar (2)=null,
	@city varchar (2)=null,
	@address varchar (2)=null,
	@MangerName varchar (2)=null,
	@adminMangerName varchar (2)=null,	
	@Remark varchar (2)=null,
	@IsSharedRemark varchar (2)=null,
	@ShowRemarkInInternet varchar (2)=null,
	@RemarkValidFrom varchar (2)=null,
	@RemarkValidTo varchar (2)=null,
	@Membership  varchar (2)=null,
	@IsExcelVersion varchar (2)=null,
	
	@ErrCode varchar(max) OUTPUT
-----------------------------------------
)with recompile

AS
--------------------------------------

DECLARE @NewLineChar AS CHAR(2) 
set @NewLineChar = CHAR(13) + CHAR(10)

--set variables 
declare  @sql nvarchar(max)-- nvarchar type supports hebrew lenguage
declare  @sqlEnd nvarchar(max)
declare  @sqlFrom varchar(max)
declare  @sqlJoin varchar(max)
declare  @sqlWhere varchar(max)

declare  @stringNotNeeded  nvarchar(max)
---------------------------
set @sql = 'SELECT distinct *  from
			(select ' + @NewLineChar;
set @sqlEnd = ') as resultTable' + @NewLineChar;
set @sqlJoin = ' ';
set @sqlWhere = ' ';

set @sqlFrom = 
'from dept  as d    
join dept as d2 on d.deptCode = d2.deptCode	
	AND d.status = 1
	AND (''' + @Membership_cond + ''' = ''-1'' 
		or d.IsCommunity = 1 and 1 in (SELECT IntField FROM dbo.SplitString( ''' + @Membership_cond + '''))
		or d.IsMushlam = 1 and 2 in (SELECT IntField FROM dbo.SplitString( ''' + @Membership_cond + '''))
		or d.IsHospital = 1 and 3 in (SELECT IntField FROM dbo.SplitString( ''' + @Membership_cond  + '''))
		)
	AND (''' + @AdminClinicCode + ''' = ''-1'' or d.administrationCode  in (SELECT IntField FROM dbo.SplitString( ''' + @AdminClinicCode + ''')))
	AND (''' + @DistrictCodes + ''' = ''-1'' or  d.districtCode IN (SELECT IntField FROM dbo.SplitString( ''' + @DistrictCodes + ''')) or d.DeptCode IN (SELECT x_Dept_District.DeptCode FROM dbo.SplitString(''' + @DistrictCodes + ''') as T JOIN  x_Dept_District ON T.IntField = x_Dept_District.districtCode) )
	AND (''' + @UnitTypeCodes + ''' = ''-1'' or d.typeUnitCode  in (SELECT IntField FROM dbo.SplitString( ''' + @UnitTypeCodes + ''')) )
	AND (''' + @SubUnitTypeCodes + ''' = ''-1'' or d.subUnitTypeCode in (SELECT IntField FROM dbo.SplitString( ''' + @SubUnitTypeCodes + ''')) )
	AND (''' + @SectorCodes + ''' = ''-1'' or d.populationSectorCode IN (SELECT IntField FROM dbo.SplitString( ''' + @SectorCodes + ''')) )
	 
 left join dept as dAdmin on d.administrationCode = dAdmin.deptCode   
 left join dept as dDistrict on d.districtCode = dDistrict.deptCode    
 left join dept as dSubAdmin on d.subAdministrationCode = dSubAdmin.deptCode 
 left join View_UnitType as UnitType on d.typeUnitCode =  UnitType.UnitTypeCode  
 left join View_SubUnitTypes as SubUnitType on d.subUnitTypeCode =  SubUnitType.subUnitTypeCode and  d.typeUnitCode =  SubUnitType.UnitTypeCode  
 left join PopulationSectors as ps on d.populationSectorCode = ps.PopulationSectorID  
 left join deptSimul on d.DeptCode = deptSimul.DeptCode 
 left join Cities on d.CityCode =  Cities.CityCode  
 
 join View_DeptAndServicesRemarks as VRemarks on d.deptCode = VRemarks.deptCode
 AND (''' + @RemarkType_cond + ''' = ''-1'' or VRemarks.RemarkType IN (SELECT IntField FROM dbo.SplitString( ''' + @RemarkType_cond + ''')) )
 AND (''' + @Remark_cond + ''' = ''-1'' or VRemarks.remarkID IN (SELECT IntField FROM dbo.SplitString( ''' + @Remark_cond + ''')) )
 AND (''' + @IsConstantRemark_cond + ''' = ''-1'' or VRemarks.IsConstantRemark = ''' + @IsConstantRemark_cond + ''' )
 AND (''' + @IsSharedRemark_cond + ''' = ''-1'' or VRemarks.IsSharedRemark = ''' + @IsSharedRemark_cond + ''' )
 AND (''' + @ShowRemarkInInternet_cond + ''' = ''-1'' or VRemarks.displayInInternet = ''' + @ShowRemarkInInternet_cond + ''' )
 AND (''' + @IsFutureRemark_cond + ''' = ''-1'' or VRemarks.IsFutureRemark = ''' + @IsFutureRemark_cond + ''' )
	' 

----------------------------------------------	
if(@adminClinic = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dAdmin.DeptName as AdminClinicName ,
				 dAdmin.DeptCode as AdminClinicCode '+ @NewLineChar;
	end	
	
if(@district = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
		set @sql = @sql + ' dDistrict.DeptName as DistrictName , isNull(dDistrict.deptCode , -1) as DeptCode '+ @NewLineChar;
	end

if(@unitType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' UnitType.UnitTypeCode as UnitTypeCode , UnitType.UnitTypeName as UnitTypeName '+ @NewLineChar;
	end	
	
if(@subUnitType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
		' subUnitType.subUnitTypeCode as subUnitTypeCode , subUnitType.subUnitTypeName as subUnitTypeName '+ 
		@NewLineChar;
	end 
	
if( @ClinicName= '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'd.DeptName as ClinicName ' + @NewLineChar;	
	end

if( @ClinicCode= '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' d.deptCode as ClinicCode ' + @NewLineChar;	
	end

if(@simul = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'deptSimul.Simul228 as Code228 '+ @NewLineChar;
	end 

if(@city = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);			
		set @sql = @sql + ' Cities.CityCode as CityCode, Cities.CityName as CityName'+ @NewLineChar;
	end

if (@address = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'dbo.GetAddress(d.deptCode) as ClinicAddress '+ @NewLineChar;
	end	

if(@Membership = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);			
		set @sql = @sql + 
		'case when d.IsCommunity = 1 then ''כן'' else ''לא'' end as IsCommunity, 
		case when d.IsMushlam = 1 then ''כן'' else ''לא'' end as 	IsMushlam,
		case when d.IsHospital = 1 then ''כן'' else ''לא'' end as IsHospital	
		'+ @NewLineChar;
	end
 
if(@MangerName = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_getManagerName(d.deptCode) as MangerName '+ @NewLineChar;							   
end

if(@adminMangerName = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_getAdminManagerName(d.deptCode) as AdminMangerName '+ @NewLineChar;
end		

if(@sector = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' ps.PopulationSectorID as SectorCode ,ps.PopulationSectorDescription as SectorName'+ @NewLineChar;
end 

--------- Remarks ---------------------------
if(@Remark = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'replace( VRemarks.RemarkText,''#'', '''')  as RemarkText, 
		VRemarks.remarkID as RemarkID '+ @NewLineChar;
	end	
	
if(@IsSharedRemark = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'case when VRemarks.IsSharedRemark = 1 then ''כן'' else ''לא'' end as IsSharedRemark'+ @NewLineChar;
		
	end		
	
if(@ShowRemarkInInternet = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'case when VRemarks.displayInInternet = 1 then ''כן'' else ''לא'' end as ShowRemarkInInternet'+ @NewLineChar;
	end	

if(@RemarkValidFrom = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' VRemarks.ValidFrom as RemarkValidFrom '+ @NewLineChar;
	end		
	
if(@RemarkValidTo = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' VRemarks.ValidTo as RemarkValidTo '+ @NewLineChar;
	end	
	


--=================================================================
print '--===== @sql ========'
print '--===== @sql length====' + str(len(@sql))
print @sql


print '--===== @sqlFrom ========'
print '--===== @sqlFrom length====' + str(len(@sqlFrom))
print @sqlFrom 


print '--===== sqlWhere ======== ' 
print '--===== sqlWhere length====' + str(len(@sqlWhere))
print  @sqlWhere 

 print '--===== @sqlEnd ========'
print '--===== @sqlEnd length====' + str(len(@sqlEnd))
print @sqlEnd

set @sql = @sql + @sqlFrom 
+ @sqlWhere
 + @sqlEnd

print '--------- sql query full ----------'
print '--===== @sql string length = ' + str(len(@sql))
print @sql 

SET DATEFORMAT dmy;
EXECUTE sp_executesql @sql 
SET DATEFORMAT mdy;
SET @ErrCode = @sql 
RETURN 
SET DATEFORMAT mdy;
GO

GRANT EXEC ON [dbo].rprt_DeptAndServicesRemarks TO PUBLIC
GO

-- *******************************************************************************************************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_DeptSubAdminClinics')
	BEGIN
		DROP  Procedure  dbo.rprt_DeptSubAdminClinics
	END
GO

CREATE Procedure dbo.rprt_DeptSubAdminClinics
(
	 @DistrictCodes varchar(max)=null,
	 @AdminClinicCode varchar(max)=null,	
	 @CitiesCodes varchar(max)=null,
	 @UnitTypeCodes varchar(max)=null,
	 @SubClinicUnitTypeCodes varchar(max)=null,
	 @Membership_cond varchar(max)=null,
	 @StatusCodes varchar(max)=null,
	 @SubClinicStatusCodes varchar(max)=null,
	 	 
	@district varchar (2)= null,	
	@adminClinic varchar (2) = null ,		
	@ClinicName varchar (2)=null,
	@ClinicCode varchar (2)=null,
	@simul varchar (2)=null,
	@unitType varchar (2)=null,		
	@subUnitType varchar (2)=null,	
	@sector varchar (2)=null,
	@city varchar (2)=null,
	@address varchar (2)=null,
	@Phone1 varchar (2)=null,
	@Phone2 varchar (2)=null,
	@Fax varchar (2)=null,
	@Email varchar (2)=null,
	@MangerName varchar (2)=null,
	@adminMangerName varchar (2)=null,	
	@subAdminClinic varchar (2)=null, 
	
	@SubClinicName varchar (2)=null,
	@SubClinicCode varchar (2)=null,
	@SubClinicSimul varchar (2)=null,
	@SubClinicUnitType varchar (2)=null,		
	@SubClinicSubUnitType varchar (2)=null,	
	@SubClinicCity varchar (2)=null,
	@SubClinicAddress varchar (2)=null,
	@SubClinicPhone1 varchar (2)=null,
	@SubClinicPhone2 varchar (2)=null,
	@SubClinicFax varchar (2)=null,
	@SubClinicEmail varchar (2)=null,
	@Membership  varchar (2)=null,
	@status  varchar (2)=null,
	@SubClinicStatus  varchar (2)=null,
	
	--@SubClinicMembership  varchar (2)=null,
	
	@IsExcelVersion varchar (2)=null,
	@ErrCode VARCHAR(max) OUTPUT
-----------------------------------------
)with recompile

AS
--------------------------------------

DECLARE @NewLineChar AS CHAR(2) 
set @NewLineChar = CHAR(13) + CHAR(10)
--set @NewLineChar = ''

--set variables 
declare  @sql nvarchar(max)-- nvarchar type supports hebrew lenguage
declare  @sqlEnd nvarchar(max)
declare  @sqlFrom varchar(max)
declare  @sqlJoin varchar(max)
declare  @sqlWhere varchar(max)

declare  @stringNotNeeded  nvarchar(max)
---------------------------
--set @sql = ' SELECT distinct ';
set @sql = 'SELECT distinct *  from
			(select ' + @NewLineChar;
set @sqlEnd = ') as resultTable' + @NewLineChar;
set @sqlJoin = ' ';
set @sqlWhere = ' ';
SET DATEFORMAT dmy;

set @sqlFrom = 
'from dept  as d    
join dept as d2 on d.deptCode = d2.deptCode	
 	AND (''' + @Membership_cond + ''' = ''-1'' 
		or d.IsCommunity = 1 and 1 in (SELECT IntField FROM dbo.SplitString( ''' + @Membership_cond + '''))
		or d.IsMushlam = 1 and 2 in (SELECT IntField FROM dbo.SplitString( ''' + @Membership_cond + '''))
		or d.IsHospital = 1 and 3 in (SELECT IntField FROM dbo.SplitString( ''' + @Membership_cond  + '''))
		)
	AND (''' + @AdminClinicCode + ''' = ''-1'' or d.administrationCode  in (SELECT IntField FROM dbo.SplitString( ''' + @AdminClinicCode + ''')))
	AND (''' + @DistrictCodes + ''' = ''-1'' or  d.districtCode IN (SELECT IntField FROM dbo.SplitString( ''' + @DistrictCodes + ''')) or d.DeptCode IN (SELECT x_Dept_District.DeptCode FROM dbo.SplitString(''' + @DistrictCodes + ''') as T JOIN  x_Dept_District ON T.IntField = x_Dept_District.districtCode) )
	AND (''' + @UnitTypeCodes + ''' = ''-1'' or d.typeUnitCode  in (SELECT IntField FROM dbo.SplitString( ''' + @UnitTypeCodes + ''')) )
	AND (''' + @CitiesCodes + ''' = ''-1'' or d.CityCode IN (SELECT IntField FROM dbo.SplitString( ''' + @CitiesCodes + ''')) )

	---and d.status = 1
 left join DeptStatus on d.DeptCode = DeptStatus.DeptCode 
 join dept as d3 on d.deptCode = d3.deptCode
	AND (''' + @StatusCodes + ''' = ''-1'' or DeptStatus.Status IN (SELECT IntField FROM dbo.SplitString( ''' + @StatusCodes + ''')) )
	
 left join dept as dAdmin on d.administrationCode = dAdmin.deptCode   
 left join dept as dDistrict on d.districtCode = dDistrict.deptCode    
 left join dept as dSubAdmin on d.subAdministrationCode = dSubAdmin.deptCode 
 left join View_UnitType as UnitType on d.typeUnitCode =  UnitType.UnitTypeCode  --
 left join View_SubUnitTypes as SubUnitType on d.subUnitTypeCode =  SubUnitType.subUnitTypeCode and  d.typeUnitCode =  SubUnitType.UnitTypeCode  
 left join PopulationSectors as ps on d.populationSectorCode = ps.PopulationSectorID  
 left join deptSimul on d.DeptCode = deptSimul.DeptCode 
 left join Cities on d.CityCode =  Cities.CityCode  
 left join DIC_ActivityStatus on DeptStatus.Status = DIC_ActivityStatus.status  

 left join DeptPhones dp1 on d.DeptCode = dp1.DeptCode and dp1.PhoneType = 1 and dp1.phoneOrder = 1  
 left join DeptPhones dp2 on d.DeptCode = dp2.DeptCode and dp2.PhoneType = 1 and dp2.phoneOrder = 2 
 left join DeptPhones dp3 on d.DeptCode = dp3.DeptCode and dp3.PhoneType = 2 and dp3.phoneOrder = 1 
 -------------
join dept as SubClinics on d.deptCode = SubClinics.subAdministrationCode 
	AND (''' + @Membership_cond + ''' = ''-1'' 
		or SubClinics.IsCommunity = 1 and 1 in (SELECT IntField FROM dbo.SplitString( ''' + @Membership_cond + '''))
		or SubClinics.IsMushlam = 1 and 2 in (SELECT IntField FROM dbo.SplitString( ''' + @Membership_cond + '''))
		or SubClinics.IsHospital = 1 and 3 in (SELECT IntField FROM dbo.SplitString( ''' + @Membership_cond  + '''))
		)
	AND (''' + @SubClinicUnitTypeCodes + ''' = ''-1'' or SubClinics.typeUnitCode  in (SELECT IntField FROM dbo.SplitString( ''' + @SubClinicUnitTypeCodes + ''')) )
	---and SubClinics.status = 1

left join DeptStatus as SubClinicDeptStatus on SubClinics.DeptCode = SubClinicDeptStatus.DeptCode 
join dept as d4 on d.deptCode = d4.deptCode
	AND (''' + @SubClinicStatusCodes + ''' = ''-1'' or SubClinicDeptStatus.Status IN (SELECT IntField FROM dbo.SplitString( ''' + @SubClinicStatusCodes + ''')) )
	
left join View_UnitType as SubClinicUnitType on SubClinics.typeUnitCode =  SubClinicUnitType.UnitTypeCode  --
left join View_SubUnitTypes as SubClinicSubUnitType on SubClinics.subUnitTypeCode =  SubClinicSubUnitType.subUnitTypeCode
	and  SubClinics.typeUnitCode =  SubClinicSubUnitType.UnitTypeCode  
left join deptSimul as SubClinicDeptSimul on SubClinics.DeptCode = SubClinicDeptSimul.DeptCode 
left join Cities  as SubClinicCities on SubClinics.CityCode =  SubClinicCities.CityCode
left join DIC_ActivityStatus as SubClinicDIC_ActivityStatus on SubClinicDeptStatus.Status = SubClinicDIC_ActivityStatus.status  
 
left join DeptPhones SubClinic_dp1 on SubClinics.DeptCode = SubClinic_dp1.DeptCode and SubClinic_dp1.PhoneType = 1 and SubClinic_dp1.phoneOrder = 1  
left join DeptPhones SubClinic_dp2 on SubClinics.DeptCode = SubClinic_dp2.DeptCode and SubClinic_dp2.PhoneType = 1 and SubClinic_dp2.phoneOrder = 2 
left join DeptPhones SubClinic_dp3 on SubClinics.DeptCode = SubClinic_dp3.DeptCode and SubClinic_dp3.PhoneType = 2 and SubClinic_dp3.phoneOrder = 1 
 
 ' 

---------------------------
if(@adminClinic = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dAdmin.DeptName as AdminClinicName ,
				 isNull(dAdmin.DeptCode , -1) as AdminClinicCode '+ @NewLineChar;
	end	
	
if(@district = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
		set @sql = @sql + ' dDistrict.DeptName as DistrictName , isNull(dDistrict.deptCode , -1) as DeptCode '+ @NewLineChar;
	end

if(@unitType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' UnitType.UnitTypeCode as UnitTypeCode , UnitType.UnitTypeName as UnitTypeName '+ @NewLineChar;
	end	
	
if(@subUnitType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
		' subUnitType.subUnitTypeCode as subUnitTypeCode , subUnitType.subUnitTypeName as subUnitTypeName '+ 
		@NewLineChar;
	end 
	
if( @ClinicName= '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'd.DeptName as ClinicName ' + @NewLineChar;	
	end

if( @ClinicCode= '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' d.deptCode as ClinicCode ' + @NewLineChar;	
	end

if(@simul = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'deptSimul.Simul228 as Code228 '+ @NewLineChar;
	end 

if(@status = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' DeptStatus.Status as StatusCode , DIC_ActivityStatus.statusDescription as StatusName '+ @NewLineChar;
	end 

if(@subAdminClinic = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'dSubAdmin.DeptCode as SubAdminClinicCode , dSubAdmin.DeptName as SubAdminClinicName '+ @NewLineChar;
	end 

if(@city = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);			
		set @sql = @sql + ' Cities.CityCode as CityCode, Cities.CityName as CityName'+ @NewLineChar;
	end

if (@address = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'dbo.GetAddress(d.deptCode) as ClinicAddress '+ @NewLineChar;
	end	
	
if(@Phone1 = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp1.prePrefix, dp1.Prefix,dp1.Phone, dp1.extension) as Phone1 '+ @NewLineChar;;
end

if(@Phone2 = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp2.prePrefix, dp2.Prefix, dp2.Phone, dp2.extension) as Phone2 '+ @NewLineChar;;
end 

if(@Fax = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(dp3.prePrefix, dp3.Prefix, dp3.Phone, dp3.extension) as Fax '+ @NewLineChar;
end

if(@Email = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' d.Email as Email '+ @NewLineChar;
end
 
if(@MangerName = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_getManagerName(d.deptCode) as MangerName '+ @NewLineChar;							   
end

if(@adminMangerName = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_getAdminManagerName(d.deptCode) as AdminMangerName '+ @NewLineChar;
end		

if(@sector = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' ps.PopulationSectorID as SectorCode ,ps.PopulationSectorDescription as SectorName'+ @NewLineChar;
end 

if(@Membership = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);			
		set @sql = @sql + 
		'case when d.IsCommunity = 1 then ''כן'' else ''לא'' end as IsCommunity, 
		case when d.IsMushlam = 1 then ''כן'' else ''לא'' end as 	IsMushlam,
		case when d.IsHospital = 1 then ''כן'' else ''לא'' end as IsHospital	
		'+ @NewLineChar;
	end



---------------- SubClinics -----------------------------------


if( @SubClinicName= '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'SubClinics.DeptName as SubClinicName ' + @NewLineChar;	
	end

if( @SubClinicCode= '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' SubClinics.deptCode as SubClinicCode , SubClinics.[subAdministrationCode] as SubClinics_subAdministrationCode' + @NewLineChar;	
	end

if(@SubClinicSimul = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'SubClinicDeptSimul.Simul228 as SubClinicCode228 '+ @NewLineChar;

	end 
	
if(@SubClinicUnitType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' SubClinicUnitType.UnitTypeCode as SubClinicUnitTypeCode , SubClinicUnitType.UnitTypeName as SubClinicUnitTypeName '+ @NewLineChar;
	end	
	
if(@SubClinicSubUnitType = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
		' SubClinicSubUnitType.subUnitTypeCode as SubClinicSubUnitTypeCode , SubClinicSubUnitType.subUnitTypeName as SubClinicSubUnitTypeName '+ 
		@NewLineChar;
	end 
	
if(@SubClinicCity = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);			
		set @sql = @sql + ' SubClinicCities.CityCode as SubClinicCityCode, SubClinicCities.CityName as SubClinicCityName'+ @NewLineChar;
	end

if(@SubClinicStatus = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' SubClinicDeptStatus.Status as SubClinicStatusCode , SubClinicDIC_ActivityStatus.statusDescription as SubClinicStatusName '+ @NewLineChar;
	end 

if (@SubClinicAddress = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 'dbo.GetAddress(SubClinics.deptCode) as SubClinicAddress '+ @NewLineChar;
		set @sql = @sql + ',case when (Cities.CityName = SubClinicCities.CityName
		and d.streetName  = SubClinics.streetName 
		and d.house = SubClinics.house )
        then ''כן'' else ''לא'' end  as SubClinicEqualClinicAddress'
        + @NewLineChar;
	end	
	
if(@SubClinicPhone1 = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(SubClinic_dp1.prePrefix, SubClinic_dp1.Prefix, SubClinic_dp1.Phone, SubClinic_dp1.extension ) as SubClinicPhone1 '+ @NewLineChar;;
	set @sql = @sql + ',case when (dp1.prePrefix = SubClinic_dp1.prePrefix
		and dp1.Prefix  = SubClinic_dp1.Prefix 
		and dp1.Phone = SubClinic_dp1.Phone)
        then ''כן'' else ''לא'' end  as SubClinicEqualClinicPhone1'
        + @NewLineChar;
end

if(@SubClinicPhone2 = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(SubClinic_dp2.prePrefix, SubClinic_dp2.Prefix, SubClinic_dp2.Phone, SubClinic_dp2.extension) as SubClinicPhone2 '+ @NewLineChar;;
	set @sql = @sql + ',case when (dp2.prePrefix = SubClinic_dp2.prePrefix
		and dp2.Prefix  = SubClinic_dp2.Prefix 
		and dp2.Phone = SubClinic_dp2.Phone)
        then ''כן'' else ''לא'' end  as SubClinicEqualClinicPhone2'
        + @NewLineChar;
end 

if(@SubClinicFax = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' dbo.fun_ParsePhoneNumberWithExtension(SubClinic_dp3.prePrefix, SubClinic_dp3.Prefix, SubClinic_dp3.Phone, SubClinic_dp3.extension) as SubClinicFax '+ @NewLineChar;
	set @sql = @sql + ',case when (dp3.prePrefix = SubClinic_dp3.prePrefix
		and dp3.Prefix  = SubClinic_dp3.Prefix 
		and dp3.Phone = SubClinic_dp3.Phone)
        then ''כן'' else ''לא'' end  as SubClinicEqualClinicFax'
        + @NewLineChar;
end

if(@SubClinicEmail = '1')
begin 
	set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
	set @sql = @sql + ' SubClinics.Email as SubClinicEmail '+ @NewLineChar;
	set @sql = @sql + ',case when d.Email = SubClinics.Email then ''כן'' else ''לא'' end  as SubClinicEqualClinicEmail'
		+ @NewLineChar;
end

if(@Membership = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);			
		set @sql = @sql + 
		'case when SubClinics.IsCommunity = 1 then ''כן'' else ''לא'' end as SubClinicIsCommunity, 
		case when SubClinics.IsMushlam = 1 then ''כן'' else ''לא'' end as 	SubClinicIsMushlam,
		case when SubClinics.IsHospital = 1 then ''כן'' else ''לא'' end as SubClinicIsHospital	
		'+ @NewLineChar;
	end
		


--=================================================================
print '--===== @sql ========'
print '--===== @sql length====' + str(len(@sql))
print @sql


print '--===== @sqlFrom ========'
print '--===== @sqlFrom length====' + str(len(@sqlFrom))
print @sqlFrom 


print '--===== sqlWhere ======== ' 
print '--===== sqlWhere length====' + str(len(@sqlWhere))
print  @sqlWhere 

 print '--===== @sqlEnd ========'
print '--===== @sqlEnd length====' + str(len(@sqlEnd))
print @sqlEnd

set @sql = @sql + @sqlFrom 
+ @sqlWhere
 + @sqlEnd

print '--------- sql query full ----------'
print '--===== @sql string length = ' + str(len(@sql))
print @sql 


--SET DATEFORMAT dmy;
EXECUTE sp_executesql @sql 
--SET DATEFORMAT mdy;

SET @ErrCode = @sql 
RETURN 
SET DATEFORMAT mdy;
GO
GRANT EXEC ON [dbo].rprt_DeptSubAdminClinics TO PUBLIC
GO
