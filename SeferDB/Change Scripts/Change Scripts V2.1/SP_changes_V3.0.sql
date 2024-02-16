-- *****************************************************
--					SP CHANGES V2.1
-- *****************************************************
--  DROP OBSOLETE *********************************************************************************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getServiceForPopUp_ViaClinic')
	BEGIN
		drop procedure rpc_getServiceForPopUp_ViaClinic
	END
GO

--**** Yaniv - Start fun_GetDeptEmployeeCurrentStatus ----------------

IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'fun_GetDeptEmployeeCurrentStatus')
	BEGIN
		DROP  FUNCTION  fun_GetDeptEmployeeCurrentStatus
	END

GO

CREATE FUNCTION [dbo].fun_GetDeptEmployeeCurrentStatus 
(
	@deptCode bigint,
	@employeeID bigint,
	@agreementType tinyint
)
RETURNS tinyint

AS
BEGIN
declare @deptEmplState tinyint
if(@deptCode is null)
		set @deptEmplState=	
		(select Employee.active 
		from Employee 
		where Employee.employeeID = @employeeID)
else
		set @deptEmplState=								
		(select dept.status 
		from dept 
		where dept.deptCode = @deptCode)
		*
		(select Employee.active 
		from Employee 
		where Employee.employeeID = @employeeID)
		*
		(select x_dept_Employee.active 
		from x_dept_Employee 
		where x_dept_Employee.employeeID = @employeeID
			and x_dept_Employee.deptCode = @deptCode
			and x_dept_Employee.AgreementType = @agreementType);
			
if @deptEmplState > 2 
	set @deptEmplState = 2	
	
	return @deptEmplState		 
END

go

grant exec on fun_GetDeptEmployeeCurrentStatus to public 
GO 

--**** Yaniv - End fun_GetDeptEmployeeCurrentStatus ---------------- 


--**** Yaniv - Start View_DeptEmployeesCurrentStatus ----------------
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_DeptEmployeesCurrentStatus')
	BEGIN
		DROP  View View_DeptEmployeesCurrentStatus
	END
GO

CREATE VIEW [dbo].View_DeptEmployeesCurrentStatus
AS

-------------- dept Remarks ---------------
select 
x_dept_Employee.deptCode
,x_dept_Employee.employeeID
,dbo.fun_GetDeptEmployeeCurrentStatus(x_dept_Employee.deptCode, x_dept_Employee.employeeID,x_dept_Employee.AgreementType) as status

from x_dept_Employee
	
GO

grant select on View_DeptEmployeesCurrentStatus to public 
GO


--**** Yaniv - End View_DeptEmployeesCurrentStatus ----------------

-- FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS **************************************************
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'fun_GetEmployeeServiceGroup_QueueOrderDescription')
	BEGIN
		DROP  FUNCTION  fun_GetEmployeeServiceGroup_QueueOrderDescription
	END
GO

CREATE FUNCTION [dbo].[fun_GetEmployeeServiceGroup_QueueOrderDescription] (@DeptCode int, @employeeID bigint, @ServiceCode int)
RETURNS varchar(100)
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @QueueOrderDescription varchar(50) SET @QueueOrderDescription = ''
		
	IF(@ServiceCode <> 0)
	BEGIN
		SELECT @QueueOrderDescription = DIC_QueueOrder.QueueOrderDescription
		FROM x_Dept_Employee_Service x_D_E_S 
		INNER JOIN DIC_QueueOrder ON x_D_E_S.QueueOrder = DIC_QueueOrder.QueueOrder
		WHERE x_D_E_S.deptCode = @DeptCode
		AND x_D_E_S.employeeID = @EmployeeID
		AND x_D_E_S.ServiceCode = @ServiceCode
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
		WHERE x_D_E.deptCode = @DeptCode
		AND x_D_E.employeeID = @EmployeeID
		
		IF( @QueueOrderDescription is null)
			SET @QueueOrderDescription = ''
	END

	RETURN @QueueOrderDescription

END
GO

grant exec on fun_GetEmployeeServiceGroup_QueueOrderDescription to public 
go 


IF EXISTS (SELECT * FROM sysobjects WHERE name = 'fun_GetProfessionsForEmployeeReception')
	BEGIN
		DROP  FUNCTION  fun_GetProfessionsForEmployeeReception
	END
GO

CREATE FUNCTION [dbo].[fun_GetProfessionsForEmployeeReception]
(
	@ReceptionID int
)
RETURNS varchar(500)
AS
BEGIN
 
    DECLARE @p_str VARCHAR(500)
    SET @p_str = ''

	SELECT @p_str = @p_str + ServiceDescription + ','
	FROM deptEmployeeReceptionServices
	INNER JOIN [Services] ON deptEmployeeReceptionServices.ServiceCode = [Services].ServiceCode
	WHERE receptionID = @ReceptionID
	AND [Services].IsProfession = 1

	IF len(@p_str) > 1
	-- remove last comma
	BEGIN
		SET @p_str = SUBSTRING(@p_str, 0, len(@p_str))
	END
	
    RETURN @p_str

END
GO
 
grant exec on fun_GetProfessionsForEmployeeReception to public 
go 


IF EXISTS (SELECT * FROM sysobjects WHERE name = 'fun_GetServicesForEmployeeReception')
	BEGIN
		DROP  FUNCTION  fun_GetServicesForEmployeeReception
	END
GO

CREATE FUNCTION [dbo].[fun_GetServicesForEmployeeReception]
(
	@ReceptionID int
)
RETURNS varchar(500)
AS
BEGIN
 
    DECLARE @p_str VARCHAR(500)
    SET @p_str = ''

	SELECT @p_str = @p_str + ServiceDescription + ','
	FROM deptEmployeeReceptionServices
	INNER JOIN [Services] ON deptEmployeeReceptionServices.serviceCode = [Services].serviceCode
	WHERE receptionID = @ReceptionID
	AND [Services].IsProfession = 0

	IF len(@p_str) > 1
	-- remove last comma
	BEGIN
		SET @p_str = SUBSTRING(@p_str, 0, len(@p_str))
	END
	
    RETURN @p_str

END
GO

grant exec on fun_GetServicesForEmployeeReception to public 
go 

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_GetEmployeeExpert')
	BEGIN
		DROP  FUNCTION  fun_GetEmployeeExpert
	END
GO

CREATE FUNCTION [dbo].[fun_GetEmployeeExpert]
(
	@EmployeeID int
)

RETURNS varchar(500)
AS
BEGIN
    DECLARE @p_str VARCHAR(500)
    DECLARE @p_strTitle VARCHAR(50)
    SET @p_str = ''
    SET @p_strTitle = ''

    SELECT @p_strTitle = @p_strTitle +
		CASE isNull(employee.sex, 0) WHEN 1 THEN 'מומחה ב' WHEN 2 THEN 'מומחית ב' ELSE 'מומחה ב' END 	
    FROM employee WHERE employeeID = @EmployeeID
    
    SELECT @p_str = @p_str +
		RTRIM(LTRIM([Services].ShowExpert)) + ' וב'
		
	FROM [Services]
	INNER JOIN EmployeeServices ON [Services].ServiceCode = EmployeeServices.ServiceCode
	WHERE EmployeeServices.employeeID = @EmployeeID
	AND EmployeeServices.expProfession = 1

	IF len(@p_str) > 1
	-- remove last comma OR 'וב'
	BEGIN
		SET @p_str = @p_strTitle + @p_str
		
		SET @p_str = SUBSTRING(@p_str, 0, len(@p_str)-2)
	END
	
    RETURN @p_str

END
GO

grant exec on fun_GetEmployeeExpert to public 
go 

IF EXISTS (SELECT * FROM sysobjects WHERE name = 'fun_GetEmployeeInDeptProfessions')
	BEGIN
		DROP  FUNCTION  fun_GetEmployeeInDeptProfessions
		PRINT 'DROP  FUNCTION  fun_GetEmployeeInDeptProfessions'
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
    WHERE x_Dept_Employee_Service.employeeID = @EmployeeID
    AND x_Dept_Employee_Service.deptCode = @DeptCode
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

  
IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[dbo].[fun_GetEmployeeInDeptServices]') and xtype in (N'FN', N'IF', N'TF'))
	DROP FUNCTION [dbo].[fun_GetEmployeeInDeptServices]
	PRINT 'DROP FUNCTION [dbo].[fun_GetEmployeeInDeptServices]'
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
    WHERE x_Dept_Employee_Service.employeeID = @EmployeeID
    AND x_Dept_Employee_Service.deptCode = @DeptCode
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


IF EXISTS (SELECT * FROM sysobjects WHERE name = 'fun_GetEmployeeProfessions')
	BEGIN
		DROP  FUNCTION  fun_GetEmployeeProfessions
		PRINT 'DROP  FUNCTION  fun_GetEmployeeProfessions'
	END
GO

CREATE FUNCTION [dbo].[fun_GetEmployeeProfessions] (@employeeID int)
RETURNS varchar(500)
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @strServices varchar(500)

	SET @strServices = ''

	SELECT	@strServices = @strServices + RTRIM([Services].ServiceDescription) + ', ' 
	FROM EmployeeServices AS ES
	INNER JOIN [Services] ON ES.serviceCode = [Services].serviceCode
	WHERE ES.EmployeeID = @employeeID	
	AND [Services].IsProfession = 1

	IF(LEN(@strServices) > 0)
	BEGIN
		SET @strServices = LEFT( @strServices, LEN(@strServices) -1 )
	END

	RETURN( ISNULL(@strServices, ''))
		
END;
GO

grant exec on fun_GetEmployeeProfessions to public 
go 


IF EXISTS (SELECT * FROM sysobjects WHERE name = 'fun_GetEmployeeServiceQueueOrderGroup')
	BEGIN
		DROP  FUNCTION  fun_GetEmployeeServiceQueueOrderGroup
		PRINT 'DROP  FUNCTION  fun_GetEmployeeServiceQueueOrderGroup'
	END
GO

CREATE FUNCTION [dbo].[fun_GetEmployeeServiceQueueOrderGroup] (@DeptCode int, @employeeID bigint, @ServiceCode int)
RETURNS varchar(100)
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @ESQOGroup varchar(50) SET @ESQOGroup = ''
	DECLARE @Temp int SET @Temp = 0
	DECLARE @TempStr varchar(50) SET @TempStr = ''
	DECLARE @EmptyGroup varchar(50) SET @EmptyGroup = '00000000000000'
	DECLARE @EmployeeIDPrefix varchar(50) SET @EmployeeIDPrefix = RIGHT('00000000000' + CAST(@employeeID as varchar(11)), 11)
	DECLARE @ServicePhone varchar(50) SET @ServicePhone = '00000000000'
			
	IF(@ServiceCode <> 0)
	BEGIN
		SELECT @ESQOGroup = @ESQOGroup + CAST(IsNull(x_D_E_S.QueueOrder, 0) as varchar(1))
		FROM x_Dept_Employee_Service x_D_E_S 
		WHERE x_D_E_S.deptCode = @DeptCode
		AND x_D_E_S.employeeID = @EmployeeID
		AND x_D_E_S.ServiceCode = @ServiceCode

		IF( @ESQOGroup is null OR @ESQOGroup = '')
			SET @ESQOGroup = '0'
			
		SELECT @Temp = @Temp + (ESQOM.QueueOrderMethod * ESQOM.QueueOrderMethod)
		FROM EmployeeServiceQueueOrderMethod ESQOM
		WHERE ESQOM.deptCode = @DeptCode
		AND ESQOM.employeeID = @EmployeeID
		AND ESQOM.ServiceCode = @ServiceCode
		
		
		SELECT TOP 1 @TempStr = --@TempStr +
			CAST(ISNULL(prePrefix, 0) as varchar(1)) + 
			RIGHT('000' + CAST(ISNULL(prefixValue, 0) as varchar(3)), 3) +
			RIGHT('0000000' + CAST(ISNULL(phone, 0) as varchar(7)), 7)
		FROM EmployeeServiceQueueOrderPhones ESQOPh
		INNER JOIN DIC_PhonePrefix ON ESQOPh.prefix = DIC_PhonePrefix.prefixCode
		INNER JOIN EmployeeServiceQueueOrderMethod ESQOM
			ON ESQOPh.EmployeeServiceQueueOrderMethodID = ESQOM.EmployeeServiceQueueOrderMethodID
		WHERE ESQOM.deptCode = @DeptCode
		AND ESQOM.employeeID = @EmployeeID
		AND ESQOM.ServiceCode = @ServiceCode

		IF( @TempStr is null OR @TempStr = '')
			SET @TempStr = '00000000000'

		SET @ESQOGroup = @ESQOGroup + RIGHT('00' + CAST(ISNULL(@Temp, 0) as varchar(2)), 2) + 
						ISNULL(@TempStr, '00000000000')

		SELECT TOP 1 @ServicePhone = 
			CAST(ISNULL(prePrefix, 0) as varchar(1)) + 
			RIGHT('000' + CAST(ISNULL(prefixValue, 0) as varchar(3)), 3) +
			RIGHT('0000000' + CAST(ISNULL(phone, 0) as varchar(7)), 7)
		FROM EmployeeServicePhones ESPh
		INNER JOIN DIC_PhonePrefix ON ESPh.prefix = DIC_PhonePrefix.prefixCode
		INNER JOIN x_Dept_Employee_Service x_DES ON ESPh.x_Dept_Employee_ServiceID = x_DES.x_Dept_Employee_ServiceID
		WHERE x_DES.deptCode = @DeptCode
		AND x_DES.employeeID = @EmployeeID
		AND x_DES.ServiceCode = @ServiceCode 

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
		WHERE x_D_E.deptCode = @DeptCode
		AND x_D_E.employeeID = @EmployeeID
		
		IF( @ESQOGroup is null OR @ESQOGroup = '')
			SET @ESQOGroup = '0'
		
		SELECT @Temp = @Temp + (EQOM.QueueOrderMethod * EQOM.QueueOrderMethod)
		FROM EmployeeQueueOrderMethod EQOM
		WHERE EQOM.deptCode = @DeptCode
		AND EQOM.employeeID = @EmployeeID

		SELECT TOP 1 @TempStr = 
			CAST(ISNULL(prePrefix, 0) as varchar(1)) + 
			RIGHT('000' + CAST(ISNULL(prefixValue, 0) as varchar(3)), 3) +
			RIGHT('0000000' + CAST(ISNULL(phone, 0) as varchar(7)), 7)
		FROM DeptEmployeeQueueOrderPhones DEQOPh
		INNER JOIN DIC_PhonePrefix ON DEQOPh.prefix = DIC_PhonePrefix.prefixCode
		INNER JOIN EmployeeQueueOrderMethod EQOM
			ON DEQOPh.QueueOrderMethodID = EQOM.QueueOrderMethodID
		WHERE EQOM.deptCode = @DeptCode
		AND EQOM.employeeID = @EmployeeID

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
 
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_getEmployeeServiceQueueOrderPhones_All')
	BEGIN
		DROP  FUNCTION  fun_getEmployeeServiceQueueOrderPhones_All
		PRINT 'FUNCTION  fun_getEmployeeServiceQueueOrderPhones_All'
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

	SELECT @strPhones = @strPhones + dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) + '<br>'
	FROM EmployeeServiceQueueOrderPhones
	INNER JOIN EmployeeServiceQueueOrderMethod ON EmployeeServiceQueueOrderPhones.EmployeeServiceQueueOrderMethodID = EmployeeServiceQueueOrderMethod.EmployeeServiceQueueOrderMethodID
	WHERE EmployeeServiceQueueOrderMethod.deptCode  = @DeptCode
	AND EmployeeServiceQueueOrderMethod.employeeID = @EmployeeID
	AND EmployeeServiceQueueOrderMethod.serviceCode = @ServiceCode

SET @ThereIsQueueOrderViaClinicPhone =	
	(SELECT Count(*)
	FROM EmployeeServiceQueueOrderMethod
	INNER JOIN DIC_QueueOrderMethod ON EmployeeServiceQueueOrderMethod.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
	WHERE deptCode = @DeptCode
	AND employeeID = @EmployeeID
	AND serviceCode = @ServiceCode
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

grant exec on fun_getEmployeeServiceQueueOrderPhones_All to public 
GO

IF EXISTS (SELECT * FROM sysobjects WHERE name = 'fun_getEmployeeQueueOrderPhones_ByQueueOrderGroup')
	BEGIN
		DROP  FUNCTION  fun_getEmployeeQueueOrderPhones_ByQueueOrderGroup
	END
GO

CREATE FUNCTION [dbo].[fun_getEmployeeQueueOrderPhones_ByQueueOrderGroup] (@DeptCode int, @employeeID bigint, @ServiceCode int)
RETURNS varchar(100)
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @strPhones varchar(1000) SET @strPhones = ''

	SELECT @strPhones = @strPhones + dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) + '<br>'
	FROM EmployeeServiceQueueOrderPhones
	INNER JOIN EmployeeServiceQueueOrderMethod ON EmployeeServiceQueueOrderPhones.EmployeeServiceQueueOrderMethodID = EmployeeServiceQueueOrderMethod.EmployeeServiceQueueOrderMethodID
	WHERE EmployeeServiceQueueOrderMethod.deptCode  = @DeptCode
	AND EmployeeServiceQueueOrderMethod.employeeID = @EmployeeID
	AND EmployeeServiceQueueOrderMethod.serviceCode = @ServiceCode

	--SELECT @strPhones = @strPhones + dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) + '<br>'
	--FROM DeptEmployeeQueueOrderPhones
	--INNER JOIN EmployeeQueueOrderMethod ON DeptEmployeeQueueOrderPhones.QueueOrderMethodID = EmployeeQueueOrderMethod.QueueOrderMethodID
	--WHERE EmployeeQueueOrderMethod.deptCode  = @DeptCode
	--AND EmployeeQueueOrderMethod.employeeID = @EmployeeID


	IF(LEN(@strPhones) = 0)	
		BEGIN
			SET @strPhones = ''--'&nbsp;'
		END

	RETURN( @strPhones )

END
GO

grant exec on fun_getEmployeeQueueOrderPhones_ByQueueOrderGroup to public 
go 

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_GetEmployeeServices')
	BEGIN
		DROP  FUNCTION  fun_GetEmployeeServices
		PRINT 'DROP  FUNCTION  fun_GetEmployeeServices'
	END
GO

CREATE FUNCTION [dbo].[fun_GetEmployeeServices] (@employeeID int)
RETURNS varchar(500)
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @strServices varchar(500)

	SET @strServices = ''

	SELECT	@strServices = @strServices + RTRIM([Services].ServiceDescription) + ', ' 
	FROM EmployeeServices AS ES
	INNER JOIN [Services] ON ES.serviceCode = [Services].serviceCode
	WHERE ES.EmployeeID = @employeeID	
	AND [Services].IsService = 1

	IF(LEN(@strServices) > 0)
	BEGIN
		SET @strServices = LEFT( @strServices, LEN(@strServices) -1 )
	END

	RETURN( ISNULL(@strServices, '') )
	
END;
GO 

grant exec on fun_GetEmployeeServices to public 
GO

-- VIEWS VIEWS VIEWS VIEWS VIEWS VIEWS VIEWS VIEWS VIEWS VIEWS VIEWS *****************************************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'v_EmployeeReceptionByServiceAndProfession')
	BEGIN
		DROP  view  v_EmployeeReceptionByServiceAndProfession
	END
GO

CREATE VIEW [dbo].[v_EmployeeReceptionByServiceAndProfession]
AS 

SELECT DISTINCT 
        der.EmployeeID, der.receptionID, der.deptCode, dbo.Dept.deptName, dbo.Dept.cityCode, dbo.Cities.cityName, der.receptionDay, der.openingHour, 
        der.closingHour, der.validFrom, der.validTo, derr.RemarkID, derr.RemarkText, 
		CASE WHEN s.IsService = 1 THEN 'service' ELSE 'profession' END AS ItemType, 
 		s.ServiceDescription AS ItemDesc,	 
		s.servicecode AS ItemID,
		deptEmployeeReceptionServicesID AS ItemRecID
FROM    dbo.deptEmployeeReception AS der 
		LEFT JOIN dbo.DeptEmployeeReceptionRemarks AS derr ON der.receptionID = derr.EmployeeReceptionID 
		INNER JOIN dbo.Dept ON der.deptCode = dbo.Dept.deptCode 
		INNER JOIN dbo.Cities ON dbo.Dept.cityCode = dbo.Cities.cityCode 
		LEFT JOIN dbo.deptEmployeeReceptionServices AS ders ON der.receptionID = ders.receptionID 
		LEFT JOIN dbo.x_Dept_Employee_Service AS xdes 
			ON (ders.serviceCode = xdes.serviceCode OR ders.serviceCode IS NULL) 
			AND dbo.Dept.deptCode = xdes.deptCode 
			AND der.EmployeeID = xdes.employeeID 
        INNER JOIN dbo.[Services] AS s ON ders.serviceCode = s.ServiceCode OR ders.serviceCode IS NULL 
WHERE     (ders.receptionID IS NOT NULL) AND (xdes.serviceCode IS NOT NULL) --OR

GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_DeptEmployeeExpertProfessions')
	BEGIN
		DROP  View View_DeptEmployeeExpertProfessions
	END
GO

CREATE VIEW [dbo].View_DeptEmployeeExpertProfessions
AS
SELECT  x_Dept_Employee.deptCode, x_Dept_Employee.EmployeeId
			,STUFF( 
				(
					SELECT  '; ' + cast([Services].ServiceDescription as varchar(max))
					from x_Dept_Employee_Service as xDES
					inner join EmployeeServices 
						on  xDES.deptCode = x_Dept_Employee.deptCode
						and xDES.employeeID = x_Dept_Employee.employeeID
						and xDES.employeeID = EmployeeServices.employeeID 
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
						on  xDES.deptCode = x_Dept_Employee.deptCode
						and xDES.employeeID = x_Dept_Employee.employeeID
						and xDES.employeeID = EmployeeServices.employeeID 
						and xDES.serviceCode = EmployeeServices.serviceCode
						and EmployeeServices.expProfession = 1
					inner join [Services]
						on xDES.ServiceCode = [Services].ServiceCode
						and [Services].IsProfession = 1
					order by [Services].ServiceDescription
					FOR XML PATH('') 
				)
				,1,2,'') as ExpertProfessionCodes
	from x_Dept_Employee 
GO

 
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_DeptProfessions')
	BEGIN
		DROP  View View_DeptProfessions
	END
GO
 
create view [dbo].[View_DeptProfessions] as

Select distinct deptCode as DeptCode , vProfs.professionCode as ProfessionCode, vProfs.professionDescription  as ProfessionName  
from x_Dept_Employee as DeptEmployee
inner join EmployeeServices
		on DeptEmployee.EmployeeID = EmployeeServices.EmployeeID 
inner join View_Professions as vProfs 
on EmployeeServices.serviceCode  = vProfs.professionCode

GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_EmployeeExpertProfessions')
	BEGIN
		DROP  View View_EmployeeExpertProfessions
	END
GO

CREATE VIEW [dbo].View_EmployeeExpertProfessions
AS
SELECT Employee.employeeID
			,STUFF( 
				(
					SELECT  '; ' + [Services].ServiceDescription
					from EmployeeServices as ES
					inner join [Services] 
						on ES.employeeID = Employee.employeeID
						and ES.serviceCode = [Services].ServiceCode
						and ES.expProfession = 1
						and [Services].IsProfession = 1
					order by [Services].ServiceDescription
					FOR XML PATH('') 
				)
				,1,2,'') as ExpertProfessionDescriptions
			,STUFF( 
				(
					SELECT  '; ' + cast(ES.serviceCode as varchar(max))
					from EmployeeServices as ES
					inner join [Services] 
						on ES.employeeID = Employee.employeeID
						and ES.serviceCode = [Services].ServiceCode
						and ES.expProfession = 1
						and [Services].IsProfession = 1
					order by [Services].ServiceDescription
					FOR XML PATH('') 
				)
				,1,2,'') as ExpertProfessionCodes
	from Employee 
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_EmployeeProfessions')
	BEGIN
		DROP  View View_EmployeeProfessions
	END
GO

CREATE VIEW [dbo].View_EmployeeProfessions
AS
SELECT  Employee.EmployeeId
			,STUFF( 
				(
					SELECT  '; ' + [Services].ServiceDescription
					from EmployeeServices as ES
					inner join [Services] 
						on ES.ServiceCode = [Services].ServiceCode
						and ES.employeeID = Employee.employeeID
						and [Services].IsProfession = 1
					order by ServiceDescription
					FOR XML PATH('') 
				)
				,1,2,'') as ProfessionDescriptions
			,STUFF( 
				(
					SELECT  '; ' + cast([Services].ServiceCode as varchar(max))
					from EmployeeServices as ES
					inner join [Services] 
						on ES.ServiceCode = [Services].ServiceCode
						and ES.employeeID = Employee.employeeID
						and [Services].IsProfession = 1
					order by ServiceDescription
					FOR XML PATH('') 
				)
				,1,2,'') as ProfessionCodes
	from Employee 
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_Professions')
	BEGIN
		DROP  view  View_Professions
	END

GO

create view [dbo].[View_Professions]
as
select ServiceCode as professionCode, ServiceDescription as professionDescription 
from dbo.[Services]
WHERE [Services].IsProfession = 1


GO

 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'vEmployeeProfessionalDetails')
	BEGIN
		DROP  view  vEmployeeProfessionalDetails
	END

GO

CREATE VIEW [dbo].[vEmployeeProfessionalDetails]
AS
SELECT  	dbo.x_Dept_Employee.deptCode, dbo.rfn_GetDeptEmployeeRemarkDescriptionsHTML(dbo.x_Dept_Employee.deptCode, dbo.Employee.employeeID) 
					  AS EmployeeRemark, dbo.Employee.employeeID, 
					  dbo.DIC_EmployeeDegree.DegreeName + ' ' + dbo.Employee.lastName + ' ' + dbo.Employee.firstName AS EmployeeName, 
					  dbo.fun_GetEmployeeExpert(dbo.Employee.employeeID) AS Experties, 
					  dbo.rfn_GetDeptEmployeeProfessionDescriptions(dbo.x_Dept_Employee.deptCode, dbo.x_Dept_Employee.employeeID) AS ProfessionDescriptions, 
					  dbo.rfn_GetDeptEmployeesServiceDescriptions(dbo.x_Dept_Employee.deptCode, dbo.x_Dept_Employee.employeeID) AS ServiceDescriptions, 
					  dbo.rfn_GetDeptEmployeeQueueOrderDescriptionsHTML(dbo.x_Dept_Employee.deptCode, dbo.x_Dept_Employee.employeeID) 
					  AS QueueOrderDescriptions, dbo.rfn_GetDeptEmployeeRemarkDescriptionsHTML(dbo.x_Dept_Employee.deptCode, 
					  dbo.x_Dept_Employee.employeeID) AS HTMLRemarks, dbo.Employee.EmployeeSectorCode,
					  orderNumber = dbo.fun_getEmployeeOrderByProfessionInDept(dbo.x_Dept_Employee.deptCode ,dbo.x_Dept_Employee.employeeID),
					  CASE CascadeUpdateDeptEmployeePhonesFromClinic 
						WHEN 0 THEN [dbo].[fun_GetDeptEmployeePhonesOnly](x_Dept_Employee.employeeID,x_Dept_Employee.deptCode) ELSE '' END as Phones
FROM         dbo.x_Dept_Employee 
INNER JOIN dbo.Employee ON dbo.x_Dept_Employee.employeeID = dbo.Employee.employeeID 
INNER JOIN dbo.DIC_EmployeeDegree ON dbo.Employee.degreeCode = dbo.DIC_EmployeeDegree.DegreeCode 
LEFT OUTER JOIN dbo.DIC_QueueOrder ON dbo.x_Dept_Employee.QueueOrder = dbo.DIC_QueueOrder.QueueOrder
WHERE x_Dept_Employee.active <> 0

GO
  
grant select on vEmployeeProfessionalDetails to public 

go

-- SP CHANGES SP CHANGES SP CHANGES SP CHANGES SP CHANGES SP CHANGES *****************************************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetEmployeeRemarksForUpdate')
	BEGIN
		drop procedure rpc_GetEmployeeRemarksForUpdate
	END

GO


--*************************  YANIV  ****************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getReceptionDays')
	BEGIN
		DROP  Procedure  rpc_getReceptionDays
	END

GO

CREATE Procedure [dbo].[rpc_getReceptionDays]
	(
		-- If byDisplay = false it will return all days
		@byDisplay tinyint
	)

AS

IF @byDisplay = 0
	select * from DIC_ReceptionDays
ELSE
	select * from DIC_ReceptionDays where Display=1

GRANT EXEC ON rpc_getReceptionDays TO PUBLIC
GO

GRANT EXEC ON rpc_getReceptionDays TO PUBLIC
GO
--********************************************************


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateDIC_ReceptionDays')
	BEGIN
		DROP  Procedure  rpc_updateDIC_ReceptionDays
	END

GO

CREATE Procedure [dbo].[rpc_updateDIC_ReceptionDays]
	(
		@receptionDayCode int,
		@byDisplay tinyint
	)

AS

update DIC_ReceptionDays set Display = @byDisplay
		where ReceptionDayCode = @receptionDayCode

GO

GRANT EXEC ON rpc_updateDIC_ReceptionDays TO PUBLIC
GO




--*****************************************************************




IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetCurrentStatusForEmployee')
	BEGIN
		DROP  Procedure  rpc_GetCurrentStatusForEmployee
	END

GO

CREATE PROCEDURE dbo.rpc_GetCurrentStatusForEmployee
 	@employeeID BIGINT
AS
SELECT es.StatusID, StatusDescription, dic.[status]
FROM EmployeeStatus es
INNER JOIN DIC_ActivityStatus dic
ON es.status = dic.status
WHERE DATEDIFF(dd, GETDATE(), es.FromDate) <= 0 
AND (DATEDIFF(dd, GETDATE(), es.ToDate) >= 0  OR ToDate IS NULL)
AND EmployeeID = @employeeID

GRANT EXEC ON rpc_GetCurrentStatusForEmployee TO PUBLIC

GO

--************ END YANIV ******************------------

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateDeptLevelAndShowInInternet')
	BEGIN
		DROP  Procedure  rpc_UpdateDeptLevelAndShowInInternet
	END
GO

CREATE Procedure dbo.rpc_UpdateDeptLevelAndShowInInternet
(
	@DeptCode int,
	@DeptLevel int,
	@DisplayPriority int,	
	@UpdateUser varchar(50)
)

AS

BEGIN 

	UPDATE dept
	SET 
	deptLevel = @DeptLevel,
	DisplayPriority = @DisplayPriority,
	updateDate = getdate(),
	UpdateUser = @UpdateUser
	WHERE deptCode = @DeptCode
END 


GO

GRANT EXEC ON rpc_UpdateDeptLevelAndShowInInternet TO PUBLIC
GO


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
	@AddressComment varchar(50),
	@Transportation varchar(50),
	@Email varchar(50),
	@ShowEmailInInternet int,
	@allowQueueOrder bit,
	@ShowUnitInInternet int,
	@CascadeUpdateSubDeptPhones tinyint,
	@CascadeUpdateEmployeeInClinicPhones tinyint,
	@UpdateUser varchar(50),

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

SET @ErrorStatus = @@Error


GO


GRANT EXEC ON rpc_updateDept TO PUBLIC
GO
      


--********************* START rpc_DoctorOverView ********************************


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
SELECT
Dept.deptCode,
Dept.deptName,
Dept.cityCode,
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
	INNER JOIN x_dept_employee_service xdes ON ders.ServiceCode = xdes.ServiceCode AND xdes.EmployeeID = @employeeID
					AND xdes.DeptCode = x_dept_employee.deptCode
	WHERE der.deptCode = x_dept_employee.deptCode
	AND der.employeeid = @employeeID
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
		--and(v_DE_ER.EmpRemarkDeptCode > 0
		--	or v_DE_ER.AttributedToAllClinicsInCommunity = 1)
	)
	
	+
	
	(SELECT COUNT(*)
	 FROM DeptEmployeeServiceRemarks
	 INNER JOIN [Services] ON DeptEmployeeServiceRemarks.ServiceCode = [Services].ServiceCode
	 WHERE EmployeeID = @EmployeeID 
	 AND DeptCode = Dept.deptCode
	 AND (ValidFrom is NULL OR DATEDIFF(dd, ValidFrom ,getdate()) >= 0 )
	 AND (ValidTo is NULL OR  DATEDIFF(dd, ValidTo ,getdate()) <= 0 ) 
	),
	
'QueueOrderDescription' = IsNull(DIC_QueueOrder.QueueOrderDescription, ' '),					
'PermitOrderMethods' = IsNull(DIC_QueueOrder.PermitOrderMethods, 0),
x_Dept_Employee.active as status

FROM Dept 
INNER JOIN x_Dept_Employee ON Dept.deptCode = x_Dept_Employee.deptCode
INNER JOIN Employee ON x_Dept_Employee.employeeID = Employee.employeeID
INNER JOIN Cities ON Dept.cityCode = Cities.cityCode
LEFT JOIN DIC_QueueOrder ON x_dept_employee.QueueOrder = DIC_QueueOrder.QueueOrder

WHERE x_Dept_Employee.employeeID = @employeeID
--AND Employee.IsVirtualDoctor <> 1
ORDER BY deptName

-------- Doctor's Hours in Clinics (doctorReceptionHours) -------------------
SELECT DISTINCT
deptEmployeeReception.deptCode,
Dept.deptName,
deptEmployeeReception.receptionID,
deptEmployeeReception.EmployeeID,
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
INNER JOIN dept ON deptEmployeeReception.deptCode = dept.deptCode
LEFT JOIN DeptEmployeeReceptionServices ders ON deptEmployeeReception.ReceptionID = ders.ReceptionID
LEFT JOIN x_dept_employee_service xdes ON ders.ServiceCode = xdes.ServiceCode
WHERE deptEmployeeReception.employeeID = @employeeID
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
ORDER BY receptionDay,openingHour,deptEmployeeReception.deptCode


-- doctor closest reception add date
SELECT MIN(ValidFrom)
FROM deptEmployeeReception inner join vReceptionDaysForDisplay on receptionDay = ReceptionDayCode
WHERE EmployeeID = @employeeID
AND disableBecauseOfOverlapping <> 1
AND DATEDIFF(dd, ValidFrom, GETDATE()) < 0
AND DATEDIFF(dd, ValidFrom, GETDATE()) >= -14


-------- "doctorProfessionsAndServicesForReception"
Select *,
'ReceptionDaysInDept' = (Select count(*) 
							FROM deptEmployeeReception as dER2
							LEFT JOIN deptEmployeeReceptionServices as dERs2 ON dER2.receptionID = dERs2.receptionID
							WHERE dER2.EmployeeID = tbl.EmployeeID AND 
								der2.deptCode = tbl.deptCode AND tbl.professionOrServiceCode = ders2.ServiceCode
						 )
FROM ( 



SELECT dER.EmployeeID, 
dER.receptionID,
dER.deptCode,
ders.serviceCode as professionOrServiceCode,
[Services].ServiceDescription as professionOrServiceDescription,
dER.receptionDay,
vReceptionDaysForDisplay.ReceptionDayName,
dER.openingHour,
dER.closingHour,
'receptionRemarks' = dbo.fun_GetEmployeeRemarksForReception(dER.receptionID)   
FROM deptEmployeeReception as dER
--LEFT JOIN deptEmployeeReceptionProfessions as dERP ON dER.receptionID = dERP.receptionID
LEFT JOIN deptEmployeeReceptionServices as dERs ON dER.receptionID = dERs.receptionID
LEFT JOIN [Services] ON dERs.serviceCode = [Services].ServiceCode
--LEFT JOIN [Services] P ON dERP.professionCode = P.ServiceCode
INNER JOIN vReceptionDaysForDisplay on dER.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode
WHERE dER.EmployeeID = @employeeID
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
MAX(updateDate) AS employeeReceptionUpdateDate
FROM deptEmployeeReception
WHERE EmployeeID = @employeeID
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
EmployeeQueueOrderMethod.deptCode,
EmployeeQueueOrderMethod.employeeID,
DIC_QueueOrderMethod.QueueOrderMethodDescription,
DIC_QueueOrderMethod.ShowPhonePicture,
DIC_QueueOrderMethod.SpecialPhoneNumberRequired

FROM EmployeeQueueOrderMethod
INNER JOIN DIC_QueueOrderMethod ON EmployeeQueueOrderMethod.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
WHERE EmployeeQueueOrderMethod.employeeID = @EmployeeID
ORDER BY QueueOrderMethod

------- HoursForEmployeeQueueOrder (Hours for Employee Queue Order via Phone) --------------
SELECT
EmployeeQueueOrderMethod.deptCode,
EmployeeQueueOrderMethod.employeeID,
EmployeeQueueOrderHoursID,
EmployeeQueueOrderHours.QueueOrderMethodID,
EmployeeQueueOrderHours.receptionDay,
ReceptionDayName,
FromHour,
ToHour
FROM EmployeeQueueOrderHours
INNER JOIN vReceptionDaysForDisplay ON EmployeeQueueOrderHours.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode
INNER JOIN EmployeeQueueOrderMethod ON EmployeeQueueOrderHours.QueueOrderMethodID = EmployeeQueueOrderMethod.QueueOrderMethodID
WHERE EmployeeQueueOrderMethod.employeeID = @EmployeeID
ORDER BY vReceptionDaysForDisplay.ReceptionDayCode, FromHour



GO



GRANT EXEC ON dbo.rpc_DoctorOverView TO PUBLIC
GO

--**************** END rpc_DoctorOverView *************************************




-- *******************************************************************************************



IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDicQueueOrderMethods')
	BEGIN
		DROP  Procedure  rpc_getDicQueueOrderMethods
	END

GO

CREATE Procedure dbo.rpc_getDicQueueOrderMethods

AS

SELECT *
FROM DIC_QueueOrder
ORDER BY PermitOrderMethods


SELECT *
FROM DIC_QueueOrderMethod
ORDER BY SpecialPhoneNumberRequired, QueueOrderMethodDescription


GO


GRANT EXEC ON rpc_getDicQueueOrderMethods TO PUBLIC

GO



-- *******************************************************************************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetEmployeeProfessionsExtended')
	BEGIN
		DROP  Procedure  rpc_GetEmployeeProfessionsExtended
		PRINT 'DROP  Procedure  rpc_GetEmployeeProfessionsExtended'
	END

GO

CREATE Procedure [dbo].[rpc_GetEmployeeProfessionsExtended]
(
		@employeeID INT,
		@deptCode INT,					 -- in case @deptCode = null or @deptCode <= 0  -- all depts
		@IsLinkedToEmployeeOnly bit	 -- in case = 0 returns with whole profession list;
										-- = 1 returns only professions Linked To this Employee
)

AS 

select distinct
ServiceCode 
,ServiceDescription
,ServiceCategoryID 
,LinkedToEmployee
,LinkedToEmployeeInDept
,LinkedToEmployeeInDeptOrExpert
,ExpertProfession
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
,0 as 'LinkedToEmployeeInDeptOrExpert'
,0 as 'ExpertProfession'
,0 as 'HasReceptionInDept'
,ISNULL(SerCatSer.ServiceCategoryID, -1)as 'CategoryIDForSort'
,ISNULL(SerCat.ServiceCategoryDescription, 'תתתת') AS 'CategoryDescrForSort'
,null as 'AgreementType'
,Ser.IsProfession

--"ServiceCategory-From" - block begin ---"ServiceCategory-From" - block  equal to "Professions-From" block 
FROM [Services] as Ser
INNER JOIN x_Services_EmployeeSector xSerEmSec 
	ON Ser.ServiceCode = xSerEmSec.ServiceCode
	and Ser.IsProfession  = 1

-- filter by Employee.EmployeeSectorCode of this Employee(@employeeID)
inner JOIN Employee 
	ON xSerEmSec.EmployeeSectorCode = Employee.EmployeeSectorCode
	 AND Employee.EmployeeID = @employeeID

left JOIN EmployeeServices EmpServ
	ON Ser.ServiceCode = EmpServ.ServiceCode 
	AND EmpServ.EmployeeID = @employeeID

left JOIN X_Dept_Employee_Service DeEmpServ
	ON DeEmpServ.EmployeeID = @employeeID 
	AND DeEmpServ.ServiceCode = Ser.ServiceCode
	and (@deptCode is null 
		or @deptCode <= 0
		or DeEmpServ.deptCode = @deptCode)

left JOIN  x_ServiceCategories_Services as SerCatSer
	ON 	SerCatSer.ServiceCode = Ser.ServiceCode
	
left join ServiceCategories SerCat 
	on  SerCat.ServiceCategoryID = SerCatSer.ServiceCategoryID

left join x_Dept_Employee as DepEmp 
	ON DepEmp.EmployeeID = @employeeID 
	and (DepEmp.deptCode = @deptCode)
	
where (@IsLinkedToEmployeeOnly = 0 or EmpServ.ServiceCode is not null)
AND 
	(
		( @deptCode <> -1
			and
			(DepEmp.AgreementType is null
			or DepEmp.AgreementType in (1,2) and Ser.IsInCommunity = 1
			or DepEmp.AgreementType in (3,4) and Ser.IsInMushlam = 1
			or DepEmp.AgreementType in (5,6) and Ser.IsInHospitals = 1)	
		)
		
		OR
		
		( @deptCode = -1
			and 
			((Employee.IsInCommunity = Ser.IsInCommunity )
				or
			 (Employee.IsInMushlam = Ser.IsInMushlam )
				or
			 (Employee.IsInHospitals = Ser.IsInHospitals)		
			)
		)
	)--- end from block
/* The last condition is to hide Service Category when open PopUp for updating Employees' professions in clinic*/
and @IsLinkedToEmployeeOnly = 0 

union

------------- Professions table
SELECT 
Ser.ServiceCode
,Ser.ServiceDescription
,ISNULL(SerCatSer.ServiceCategoryID, -1) AS 'ServiceCategoryID'
,CASE IsNull(EmpServ.ServiceCode,0) WHEN 0 THEN 0 ELSE 1 END as 'LinkedToEmployee' 
,CASE IsNull(DeEmpServ.ServiceCode, 0) WHEN 0 THEN 0 ELSE 1 END as 'LinkedToEmployeeInDept'
,CASE (IsNull(EmpServ.ExpProfession,0)+ IsNull(DeEmpServ.ServiceCode,0)) 
	WHEN 0 THEN 0 else 1 END AS 'LinkedToEmployeeInDeptOrExpert'
,EmpServ.ExpProfession	as 'ExpertProfession'
--,CASE IsNull(derp.ProfessionCode,0) WHEN 0 THEN 0 ELSE 1 END 'HasReceptionInDept'
,'HasReceptionInDept' = 
(case
(
select COUNT(*) 
from deptEmployeeReception DeEmpRec 
inner JOIN deptEmployeeReceptionServices ders 
	ON DeEmpRec.ReceptionID = ders.ReceptionID 
	AND ders.ServiceCode = Ser.ServiceCode
	and DeEmpRec.DeptCode = DeEmpServ.DeptCode 
	AND DeEmpRec.EmployeeID = DeEmpServ.EmployeeID
	and (DeEmpRec.ValidTo IS NULL 
		OR DATEDIFF(dd, DeEmpRec.ValidTo, GETDATE()) <= 0)
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

------ "Professions-From" block 
FROM [Services] as Ser
INNER JOIN x_Services_EmployeeSector xSerEmSec 
	ON Ser.ServiceCode = xSerEmSec.ServiceCode
	and Ser.IsProfession  = 1

-- filter by Employee.EmployeeSectorCode of this Employee(@employeeID)
inner JOIN Employee 
	ON xSerEmSec.EmployeeSectorCode = Employee.EmployeeSectorCode
	 AND Employee.EmployeeID = @employeeID

left JOIN EmployeeServices EmpServ
	ON Ser.ServiceCode = EmpServ.ServiceCode 
	AND EmpServ.EmployeeID = @employeeID

left JOIN X_Dept_Employee_Service DeEmpServ
	ON DeEmpServ.EmployeeID = @employeeID 
	AND DeEmpServ.ServiceCode = Ser.ServiceCode
	and (@deptCode is null 
		or @deptCode <= 0
		or DeEmpServ.deptCode = @deptCode)

left JOIN  x_ServiceCategories_Services as SerCatSer
	ON 	SerCatSer.ServiceCode = Ser.ServiceCode
	
left join ServiceCategories SerCat 
	on  SerCat.ServiceCategoryID = SerCatSer.ServiceCategoryID

-- if @deptCode is null DepEmp.AgreementType = null
left join x_Dept_Employee as DepEmp 
	ON DepEmp.EmployeeID = @employeeID 
	and (DepEmp.deptCode = @deptCode)
	
where (@IsLinkedToEmployeeOnly = 0 or EmpServ.ServiceCode is not null)
AND 
	(
		( @deptCode <> -1
			and
			(DepEmp.AgreementType is null
			or DepEmp.AgreementType in (1,2) and Ser.IsInCommunity = 1
			or DepEmp.AgreementType in (3,4) and Ser.IsInMushlam = 1
			or DepEmp.AgreementType in (5,6) and Ser.IsInHospitals = 1)	
		)
		
		OR
		
		( @deptCode = -1
			and 
			((Employee.IsInCommunity = Ser.IsInCommunity )
				or
			 (Employee.IsInMushlam = Ser.IsInMushlam )
				or
			 (Employee.IsInHospitals = Ser.IsInHospitals)		
			)
		)
	)	
----- "Professions-From" block end
) as temp     -- end union


ORDER BY CategoryDescrForSort, ServiceCategoryID, ServiceDescription

GO


GRANT EXEC ON rpc_GetEmployeeProfessionsExtended TO PUBLIC

GO
-- *******************************************************************************************
----------- 23/08/2011    julia ---------------------

GO
IF NOT EXISTS (SELECT * FROM ADM_QueriesFields WHERE FieldName = 'DeptCoordinates' AND QueryNumber = 1)
begin
INSERT INTO [SeferNet].[dbo].[ADM_QueriesFields]
           ([QueryNumber] ,[FieldTitle] ,[FieldName],[Mandatory] ,[Visible] ,[FieldOrder])
VALUES ( 1,'קורדינאטות', 'DeptCoordinates', 0, 1,123)
end


GO
IF NOT EXISTS (SELECT * FROM ADM_QueriesFields WHERE FieldName = 'DeptCoordinates' AND QueryNumber = 2)
begin
INSERT INTO [SeferNet].[dbo].[ADM_QueriesFields]
           ([QueryNumber] ,[FieldTitle] ,[FieldName],[Mandatory] ,[Visible] ,[FieldOrder])
VALUES ( 2,'קורדינאטות', 'DeptCoordinates', 0, 1,123)
end
GO

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
	AND (''' + @DistrictCodes + ''' = ''-1'' or  d.districtCode IN (SELECT IntField FROM dbo.SplitString( ''' + @DistrictCodes + ''')) )
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
			FROM x_Dept_Employee_Profession 
			WHERE deptCode = d.deptCode									
			AND professionCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ProfessionCodes + ''' ))) > 0
		)
	AND (
	''' + @ServiceCodes + ''' = ''-1'' or
		(SELECT count(*) 
		FROM x_Dept_Employee_Service 
		WHERE d.deptCode = x_Dept_Employee_Service.deptCode									
		AND ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ServiceCodes + ''' ))) > 0
		or
		(SELECT count(*) 
		FROM x_Dept_Service 
		WHERE d.deptCode = x_Dept_Service.deptCode								
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
		set @sql = @sql + 'dbo.rfn_FormatAddress(d.streetName, d.house, d.flat, d.floor, Cities.CityName ) as ClinicAddress '+ @NewLineChar;
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

print '--===== @sql ========'
print '--===== @sql length====' + str(len(@sql))
print @sql


print '--===== @sqlFrom ========'
print '--===== @sqlFrom length====' + str(len(@sqlFrom))
print @sqlFrom 


 print '--===== @sqlEnd ========'
print '--===== @sqlEnd length====' + str(len(@sqlEnd))
print @sqlEnd


set @sql = @sql + @sqlFrom+ @sqlEnd

print '--------- sql query full ----------'
print '===== @sql string length = ' + str(len(@sql))
print @sql 


EXECUTE sp_executesql @sql 
SET @ErrCode = @sql 
RETURN 

GO
GRANT EXEC ON [dbo].rprt_DeptsByProfessionsTypes TO PUBLIC
GO

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
	@deptLevelDesc varchar (2)=null,
	@MangerName varchar (2)=null,
	@AdminMangerName varchar (2)=null,
	@serviceDescription varchar (2)=null,
	@serviceIsGivenByPersons varchar (2)=null,
	@QueueOrderDescription varchar (2)=null,
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
	AND (''' + @DistrictCodes + ''' = ''-1'' or  d.districtCode IN (SELECT IntField FROM dbo.SplitString( ''' + @DistrictCodes + ''')) )
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
			FROM x_Dept_Employee_Profession 
			WHERE deptCode = d.deptCode									
			AND professionCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ProfessionCodes + ''' ))) > 0
		)
	AND (
	''' + @ServiceCodes + ''' = ''-1'' or
		(SELECT count(*) 
		FROM x_Dept_Employee_Service 
		WHERE d.deptCode = x_Dept_Employee_Service.deptCode									
		AND ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ServiceCodes + ''' ))) > 0
		or
		(SELECT count(*) 
		FROM x_Dept_Service 
		WHERE d.deptCode = x_Dept_Service.deptCode								
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
		set @sql = @sql + 'dbo.rfn_FormatAddress(d.streetName, d.house, d.flat, d.floor, Cities.CityName ) as ClinicAddress '+ @NewLineChar;
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
print '--===== @sql ========'
print '--===== @sql length====' + str(len(@sql))
print @sql


print '--===== @sqlFrom ========'
print '--===== @sqlFrom length====' + str(len(@sqlFrom))
print @sqlFrom 


 print '--===== @sqlEnd ========'
print '--===== @sqlEnd length====' + str(len(@sqlEnd))
print @sqlEnd


set @sql = @sql + @sqlFrom+ @sqlEnd

print '--------- sql query full ----------'
print '===== @sql string length = ' + str(len(@sql))
print @sql 


EXECUTE sp_executesql @sql 
SET @ErrCode = @sql 
RETURN  
 
GO
GRANT EXEC ON [dbo].rprt_DeptsByServicesTypes TO PUBLIC
GO

-- ****************************************************************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDeptQueueOrderMethods')
	BEGIN
		DROP  Procedure  rpc_GetDeptQueueOrderMethods
	END

GO

CREATE Procedure dbo.rpc_GetDeptQueueOrderMethods
(
	@deptCode INT
)

AS

SELECT  qo.QueueOrder, dqom.QueueOrderMethod,
'DeptPhone' = dbo.fun_ParsePhoneNumberWithExtension(deptPhones.prePrefix,deptPhones.prefix,deptPhones.phone,deptPhones.extension),
queuePhones.prePrefix, dic.prefixCode, dic.prefixValue as PrefixText, queuePhones.phone, queuePhones.extension
 
FROM Dept 
LEFT JOIN Dic_QueueOrder qo ON Dept.QueueOrder = qo.QueueOrder
LEFT JOIN DeptQueueOrderMethod dqom ON Dept.deptCode = dqom.DeptCode 
LEFT JOIN DeptPhones ON dqom.deptCode =  deptPhones.DeptCode  AND PhoneType = 1 AND PhoneOrder = 1 AND dqom.QueueOrderMethod = 1
LEFT JOIN DeptQueueOrderPhones queuePhones ON dqom.QueueOrderMethodID = queuePhones.QueueOrderMethodID
LEFT JOIN DIC_PhonePrefix dic ON queuePhones.Prefix = dic.prefixCode
WHERE Dept.deptCode = @deptCode





SELECT DeptQueueOrderHoursID AS QueueOrderHoursID, receptionDay, FromHour as OpeningHour, ToHour as ClosingHour, 
'NumOfSessionsPerDay' = (
			SELECT count(*)
			FROM DeptQueueOrderMethod dqom2
			INNER JOIN DeptQueueOrderHours hours2 ON dqom2.QueueOrderMethodID = hours2.QueueOrderMethodID 
			AND hours.ReceptionDay = hours2.ReceptionDay
			GROUP BY receptionDay
		)
FROM DeptQueueOrderMethod dqom
INNER JOIN DeptQueueOrderHours hours ON dqom.QueueOrderMethodID = hours.QueueOrderMethodID
WHERE dqom.DeptCode = @DeptCode 
ORDER BY FromHour,ToHour




GO


GRANT EXEC ON rpc_GetDeptQueueOrderMethods TO PUBLIC

GO

-- ****************************************************************************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getServicesByName')
	BEGIN
		DROP  Procedure  rpc_getServicesByName
	END

GO

CREATE Procedure rpc_getServicesByName
	(
	@SearchString varchar(50)
	)

AS

	SELECT serviceCode, serviceDescription FROM
	(
		SELECT serviceCode, rtrim(ltrim(serviceDescription)) as serviceDescription, showOrder = 0
		FROM services
		WHERE serviceDescription like @SearchString + '%'

		UNION
		
		SELECT serviceCode, rtrim(ltrim(serviceDescription)) as serviceDescription, showOrder = 1
		FROM services
		WHERE (serviceDescription like '%' + @SearchString + '%' AND serviceDescription NOT like @SearchString + '%')

	) as T1
	ORDER BY showOrder
GO

GRANT EXEC ON rpc_getServicesByName TO PUBLIC

GO


-- ****************************************************************************************************
  

  IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteServiceSynonym')
    BEGIN
	    DROP  Procedure  rpc_DeleteServiceSynonym
    END

GO

CREATE Procedure dbo.rpc_DeleteServiceSynonym
(
	@synoymID INT
)

AS


DELETE ServiceSynonym
WHERE SynonymID = @synoymID

                
GO


GRANT EXEC ON rpc_DeleteServiceSynonym TO PUBLIC

GO            

-- ****************************************************************************************************

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

		SELECT s.serviceCode as code, rtrim(ltrim(syn.ServiceSynonym)) as description, showOrder = 0
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

		SELECT s.serviceCode as code, rtrim(ltrim(syn.ServiceSynonym)) as description, showOrder = 0
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

-- ****************************************************************************************************
/*
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getServicesByNameAndSector')
	BEGIN
		DROP  Procedure  rpc_getServicesNewByName
	END

GO
*/
-- ****************************************************************************************************

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

		SELECT s.serviceCode, rtrim(ltrim(syn.ServiceSynonym)) as serviceDescription, showOrder = 0
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

		SELECT s.serviceCode, rtrim(ltrim(syn.ServiceSynonym)) as serviceDescription, showOrder = 1
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

-- ****************************************************************************************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetSynonymsToService')
    BEGIN
	    DROP  Procedure  rpc_GetSynonymsToService
    END

GO

CREATE Procedure dbo.rpc_GetSynonymsToService
(
	@serviceCode INT,
	@serviceName VARCHAR(50)
)

AS

SELECT syn.SynonymID, ser.ServiceCode, ser.ServiceDescription, syn.ServiceSynonym
FROM ServiceSynonym syn
INNER JOIN [Services] ser ON syn.ServiceCode = ser.ServiceCode
WHERE (ser.ServiceCode = @serviceCode OR @serviceCode IS NULL)
AND (ser.ServiceDescription like '%' + @serviceName + '%' OR @serviceName IS NULL)
ORDER BY ser.ServiceCode

                
GO


GRANT EXEC ON rpc_GetSynonymsToService TO PUBLIC

GO            

-- ****************************************************************************************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertSynonymToService')
    BEGIN
	    DROP  Procedure  rpc_InsertSynonymToService
    END

GO

CREATE Procedure dbo.rpc_InsertSynonymToService
(	
	@serviceCode INT,
	@synonym VARCHAR(100),
	@userName VARCHAR(50)
)

AS

IF NOT EXISTS 
(
	SELECT *
	FROM ServiceSynonym
	WHERE ServiceCode = @serviceCode
	AND ServiceSynonym = @synonym
)

	INSERT INTO ServiceSynonym
	(ServiceCode, ServiceSynonym, UpdateDate, UpdateUser)

	VALUES
	(@serviceCode, @synonym, GETDATE(), @userName)



                
GO


GRANT EXEC ON rpc_InsertSynonymToService TO PUBLIC

GO

-- ****************************************************************************************************************


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
S403.City,
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

-- ****************************************************************************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateDeptGeneralBelongings')
    BEGIN
	    DROP  Procedure  rpc_UpdateDeptGeneralBelongings
    END
GO

CREATE Procedure dbo.rpc_UpdateDeptGeneralBelongings
(
	@deptCode int,
	@IsCommunity bit,
	@IsMushlam bit,
	@IsHospital bit
)

AS

UPDATE Dept
SET IsCommunity = ISNULL(@IsCommunity, d.IsCommunity),
IsMushlam = ISNULL(@IsMushlam, d.IsMushlam),
IsHospital = ISNULL(@IsHospital, d.IsHospital)
FROM Dept d
WHERE d.deptCode = @deptCode

GO


GRANT EXEC ON rpc_UpdateDeptGeneralBelongings TO PUBLIC
GO          

-- ****************************************************************************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getNewClinicsList')
	BEGIN
		DROP  Procedure  rpc_getNewClinicsList
	END

GO

CREATE Procedure [dbo].[rpc_getNewClinicsList]

AS

SELECT SimulDeptId as deptCode, d.DeptName as districtName, SimulDeptName as deptName, 
'SimulManageDescription' = IsNull(Int1.SimulManageDescription, '0'), 
Int1.SugSimul501, t501.SimulDesc, Int1.TatSugSimul502, 
't502_descr' = (SELECT TatSugSimulDesc FROM TatSugSimul502 
WHERE TatSugSimul502.SugSimul = Int1.SugSimul501 
	AND TatSugSimul502.TatSugSimulId = Int1.TatSugSimul502), 
Int1.TatHitmahut503, 
't503_descr' = (SELECT HitmahutDesc FROM TatHitmahut503 
WHERE TatHitmahut503.SugSimul = Int1.SugSimul501 
	AND TatHitmahut503.TatSugSimulId = Int1.TatSugSimul502 
	AND TatHitmahut503.TatHitmahut = Int1.TatHitmahut503), 
Int1.RamatPeilut504, 
't504_descr' = (SELECT Teur FROM RamatPeilut504 
WHERE RamatPeilut504.SugSimul = Int1.SugSimul501 
	AND RamatPeilut504.TatSugSimul = Int1.TatSugSimul502 
	AND RamatPeilut504.TatHitmahut = Int1.TatHitmahut503 
	AND RamatPeilut504.RamatPeilut = Int1.RamatPeilut504), 
Int1.Key_typUnit, UnitType.UnitTypeName, Int1.OpenDateSimul, Int1.PopSectorID, 
PopulationSectors.PopulationSectorDescription,
Int1.updateDate,
'ExistsInDept' = CASE IsNull(dept.deptCode, 0) WHEN 0 THEN 0 ELSE 1 END,
'UpdateToCommunity' = CASE IsNull(dept.IsCommunity, -1) WHEN 0 THEN 1 ELSE 0 END
FROM InterfaceFromSimulNewDepts as Int1 
LEFT JOIN dept as d ON Int1.DistrictId = d.deptCode 
LEFT JOIN SugSimul501 as t501 ON t501.SugSimul = Int1.SugSimul501 
LEFT JOIN UnitType ON UnitType.UnitTypeCode = Int1.Key_typUnit 
LEFT JOIN PopulationSectors ON PopulationSectors.PopulationSectorId = Int1.PopSectorID
LEFT JOIN dept ON Int1.SimulDeptId = dept.deptCode
ORDER BY SimulDeptId 


GO

GRANT EXEC ON rpc_getNewClinicsList TO PUBLIC

GO

-- ****************************************************************************************************


--********************* rpc_UpdateEmployeeServiceInDeptStatus ******************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateEmployeeServiceInDeptStatus')
	BEGIN
		DROP  Procedure  rpc_UpdateEmployeeServiceInDeptStatus
	END
GO

CREATE Procedure dbo.rpc_UpdateEmployeeServiceInDeptStatus

AS

declare @currentDate datetime SET @currentDate = GETDATE()
declare @autoUpdateUser varchar(50) SET @autoUpdateUser = 'DailyAutoUpdate'

UPDATE x_Dept_Employee_Service 
SET status = T.Status,
	updateUser = @autoUpdateUser  + ' ' + REPLACE(T.updateUser, @autoUpdateUser + ' ', ''),
	updateDate = @currentDate
FROM x_Dept_Employee_Service   
INNER JOIN
	(SELECT
	deptCode,
	ServiceCode,
	EmployeeID,
	'Status' = IsNull((SELECT TOP 1 Status FROM DeptEmployeeServiceStatus
				WHERE x_Dept_Employee_Service.DeptCode = DeptEmployeeServiceStatus.DeptCode
				AND x_Dept_Employee_Service.ServiceCode = DeptEmployeeServiceStatus.ServiceCode
				AND x_Dept_Employee_Service.EmployeeID = DeptEmployeeServiceStatus.EmployeeID
				AND fromDate < @currentDate
				ORDER BY fromDate desc), x_Dept_Employee_Service.status),
	'updateUser' = IsNull((SELECT TOP 1 UpdateUser FROM DeptEmployeeServiceStatus
				WHERE x_Dept_Employee_Service.DeptCode = DeptEmployeeServiceStatus.DeptCode
				AND x_Dept_Employee_Service.ServiceCode = DeptEmployeeServiceStatus.ServiceCode
				AND x_Dept_Employee_Service.EmployeeID = DeptEmployeeServiceStatus.EmployeeID				
				AND fromDate < @currentDate
				ORDER BY fromDate desc), '')			
	FROM x_Dept_Employee_Service) as T 
ON x_Dept_Employee_Service.DeptCode = T.DeptCode
AND x_Dept_Employee_Service.ServiceCode = T.ServiceCode
AND x_Dept_Employee_Service.EmployeeID = T.EmployeeID
AND x_Dept_Employee_Service.status <> T.Status -- involve only those whose status has really changed


DELETE deptEmployeeReception
FROM deptEmployeeReception der
INNER JOIN x_dept_employee_service xdes ON der.DeptCode = xdes.DeptCode AND der.EmployeeID = xdes.EmployeeID
INNER JOIN deptEmployeeReceptionServices ders ON xdes.ServiceCode = ders.ServiceCode
WHERE xdes.status = 0


GO

GRANT EXEC ON rpc_UpdateEmployeeServiceInDeptStatus TO PUBLIC
GO

--********************* END rpc_UpdateEmployeeServiceInDeptStatus ******************************

--********************* rpc_UpdateDeptServiceStatus ******************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateDeptServiceStatus')
	BEGIN
		DROP  Procedure  rpc_UpdateDeptServiceStatus
	END
GO

CREATE Procedure dbo.rpc_UpdateDeptServiceStatus

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

--********************* END rpc_UpdateDeptServiceStatus ******************************

--*********************  rpc_updateX_D_Emp_FromEmployeeStatusInDept ******************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateX_D_Emp_FromEmployeeStatusInDept')
	BEGIN
		DROP  Procedure  rpc_updateX_D_Emp_FromEmployeeStatusInDept
	END
GO

CREATE Procedure dbo.rpc_updateX_D_Emp_FromEmployeeStatusInDept

AS

declare @currentDate datetime SET @currentDate = GETDATE()
declare @autoUpdateUser varchar(50) SET @autoUpdateUser = 'DailyAutoUpdate'

-- update all statuses that has been changed except "not active"
UPDATE x_Dept_Employee 
SET x_Dept_Employee.active = T.Status,
	x_Dept_Employee.updateUserName = @autoUpdateUser  + ' ' +  REPLACE(T.updateUser, @autoUpdateUser + ' ', ''),
	x_Dept_Employee.updateDate = @currentDate
FROM x_Dept_Employee 
INNER JOIN
	(SELECT
	x_Dept_Employee.employeeID,
	x_Dept_Employee.deptCode,
	x_Dept_Employee.updateUserName,
	'Status' = IsNull((SELECT TOP 1 Status 
				FROM EmployeeStatusInDept
				WHERE x_Dept_Employee.EmployeeID = EmployeeStatusInDept.EmployeeID
				AND x_Dept_Employee.DeptCode = EmployeeStatusInDept.DeptCode
				AND fromDate < @currentDate
				ORDER BY fromDate desc), x_Dept_Employee.active),
	'updateUser' = IsNull((SELECT TOP 1 UpdateUser FROM EmployeeStatusInDept
				WHERE x_Dept_Employee.EmployeeID = EmployeeStatusInDept.EmployeeID
				AND x_Dept_Employee.DeptCode = EmployeeStatusInDept.DeptCode
				AND fromDate < @currentDate
				ORDER BY fromDate desc), '')			
	FROM x_Dept_Employee) as T 
	ON x_Dept_Employee.employeeID = T.employeeID
	AND x_Dept_Employee.DeptCode = T.DeptCode AND x_Dept_Employee.Active <> T.Status AND T.Status <> 0


-- update not active status
SELECT DISTINCT EmployeeID, DeptCode, UpdateUser
INTO #tempEmployeeTable
FROM EmployeeStatusInDept st
WHERE 
(
	(DATEDIFF(dd, FromDate, GetDate()) >= 0 AND DATEDIFF(dd, FromDate, GetDate()) <= 1)
		OR st.Status <> (select active from x_Dept_Employee xde 
						 where xde.deptCode = st.DeptCode and xde.employeeID = st.EmployeeID)
		and (st.ToDate is null 
			 or (DATEDIFF(dd, st.FromDate, GetDate()) >= 0 and DATEDIFF(dd, st.ToDate, GetDate()) <= 0) 
			)
)
AND st.Status = 0


UPDATE x_Dept_Employee
SET active = 0,
	updateUserName = @autoUpdateUser  + ' ' + updateUserName,
	QueueOrder = NULL,
	updateDate = @currentDate
FROM x_Dept_Employee xde
INNER JOIN #tempEmployeeTable t
ON xde.EmployeeID = t.EmployeeID
AND xde.DeptCode = t.DeptCode


-- delete all receptions for not active doctors
DELETE DeptEmployeeReception
FROM DeptEmployeeReception der
INNER JOIN #tempEmployeeTable t
ON der.deptCode = t.deptCode
AND der.EmployeeID = t.employeeID

-- delete all queue order methods for not active doctors
DELETE EmployeeQueueOrderMethod
FROM EmployeeQueueOrderMethod eqom
INNER JOIN #tempEmployeeTable t
ON eqom.deptCode = t.deptCode
AND eqom.EmployeeID = t.employeeID

-- delete positions for not active doctors
DELETE x_Dept_Employee_Position
FROM x_Dept_Employee_Position xDEP 
INNER JOIN x_Dept_Employee xDE
	ON xDEP.deptCode = xDE.deptCode
	AND xDEP.employeeID = xDE.employeeID
	AND xDE.active = 0

GO

GRANT EXEC ON rpc_updateX_D_Emp_FromEmployeeStatusInDept TO PUBLIC

GO
--********************* END rpc_updateX_D_Emp_FromEmployeeStatusInDept ******************************

--*********************  rpc_UpdateEmployeeStatus ******************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateEmployeeStatus')
	BEGIN
		DROP  Procedure  rpc_UpdateEmployeeStatus
	END

GO

CREATE Procedure dbo.rpc_UpdateEmployeeStatus

AS

declare @currentDate datetime SET @currentDate = GETDATE()
declare @autoUpdateUser varchar(50) SET @autoUpdateUser = 'DailyAutoUpdate'

UPDATE Employee 
SET Employee.active = T2.Status,
Employee.updateUser = @autoUpdateUser + ' ' + REPLACE(T2.updateUser, @autoUpdateUser + ' ', ''),
Employee.updateDate = @currentDate
--select * 
FROM Employee INNER JOIN
	(SELECT 
		EmployeeID, 
		'Status' = IsNull((SELECT TOP 1 Status FROM EmployeeStatus
		WHERE EmployeeID = T1.EmployeeID
		AND fromDate < @currentDate
		ORDER BY fromDate desc), -1),
		'updateUser' = (SELECT TOP 1 updateUser FROM EmployeeStatus
		WHERE EmployeeID = T1.EmployeeID
		AND fromDate < @currentDate
		ORDER BY fromDate desc)
	FROM 
	(SELECT distinct EmployeeID
	FROM EmployeeStatus 
	WHERE fromDate < @currentDate) as T1
	) as T2 
ON Employee.employeeID = T2.EmployeeID 
AND Employee.active <> T2.Status -- involve only those whose status has really changed
AND T2.Status <> -1

DELETE FROM x_dept_employee
WHERE EmployeeID IN (SELECT employeeID FROM Employee WHERE Employee.active = 0)

GO

GRANT EXEC ON rpc_UpdateEmployeeStatus TO PUBLIC

GO

--********************* END rpc_UpdateEmployeeStatus ******************************

--*********************  rpc_updateDeptFromDeptStatus ******************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateDeptFromDeptStatus')
	BEGIN
		DROP  Procedure  rpc_updateDeptFromDeptStatus
	END

GO

CREATE Procedure dbo.rpc_updateDeptFromDeptStatus

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

GRANT EXEC ON rpc_updateDeptFromDeptStatus TO PUBLIC

GO

--********************* END rpc_updateDeptFromDeptStatus ******************************

--*********************  rpc_updateDeptNames ******************************
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_updateDeptNames]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[rpc_updateDeptNames]
GO

CREATE Procedure rpc_updateDeptNames

AS

declare @currentDate datetime SET @currentDate = GETDATE()
declare @autoUpdateUser varchar(50) SET @autoUpdateUser = 'DailyAutoUpdate'

UPDATE dept 
SET dept.deptName = T2.deptName,
dept.updateUser = @autoUpdateUser + ' ' + REPLACE(T2.updateUser, @autoUpdateUser + ' ', ''),
dept.updateDate = @currentDate
FROM dept 
INNER JOIN
	(SELECT 
		deptCode, 
		'deptName' = IsNull((SELECT TOP 1 deptName FROM DeptNames
		WHERE deptCode = T1.deptCode
		AND fromDate < @currentDate
		ORDER BY fromDate desc), ''),
		'updateUser' = (SELECT TOP 1 updateUser FROM DeptNames
		WHERE deptCode = T1.deptCode
		AND fromDate < @currentDate
		ORDER BY fromDate desc)
	FROM 
	(SELECT distinct deptCode 
	FROM DeptNames 
	WHERE fromDate < @currentDate) as T1
	) as T2 
ON dept.deptCode = T2.deptCode 
AND dept.deptName <> T2.deptName -- involve only those whose name has changed
AND RTRIM(LTRIM(T2.deptName)) <> ''

GO

GRANT EXEC ON rpc_updateDeptNames TO PUBLIC

GO


--********************* END rpc_updateDeptNames ******************************
--*********************  rpc_insertDept ******************************
IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rpc_insertDept')
	BEGIN
		PRINT 'Dropping Procedure rpc_insertDept'
		DROP  Procedure  rpc_insertDept
	END

GO

CREATE Procedure [dbo].[rpc_insertDept]
	(
		@DeptCode int,
		@UpdateUser varchar(50),
		@ErrorCode int = 0 OUTPUT
	)

AS
	
DECLARE @populationSectorCode int 
SET @populationSectorCode = null
SET @populationSectorCode = CASE (SELECT SugSimul FROM SimulOld731 WHERE KodSimulOld = @DeptCode)
	WHEN 1 THEN 3 /*מיעוטים*/ WHEN 2 THEN 2 /*חרדים*/ WHEN 3 THEN 4 /*עולים*/ ELSE 1 /*כללי*/ END
	

INSERT INTO dept
(deptCode, deptName, deptType, districtCode, deptLevel, typeUnitCode, subUnitTypeCode, administrationCode, subAdministrationCode, managerName, cityCode, zipCode, StreetCode, streetName, house, flat, entrance, floor, email, status, independent, populationSectorCode, updateUser,
MFStreetName,MFStreetCode, showUnitInInternet)
SELECT
SimulDeptId, SimulDeptName, DeptType, 
'DistrictId' = CASE 
				WHEN (SELECT COUNT(*) FROM View_AllDistricts WHERE districtCode = DistrictId) > 0 
				THEN DistrictId 
				ELSE (SELECT TOP 1 districtCode FROM View_AllDistricts) END,
3, Key_typUnit, 
'subUnitTypeCode' = (SELECT TOP 1 subUnitTypeCode FROM subUnitType SUT
					INNER JOIN UnitType ON SUT.UnitTypeCode = UnitType.UnitTypeCode AND SUT.subUnitTypeCode = UnitType.DefaultSubUnitTypeCode
					WHERE SUT.UnitTypeCode = Key_typUnit),
ManageId, null, Menahel, 
'City' = CASE WHEN exists (select * from Cities where cityCode = IFS.City) THEN City ELSE 9999 END,		zip, 
Streets.StreetCode, IFS.street, house, flat, entrance, null, Email, 1/*StatusSimul*/, null, @populationSectorCode, @UpdateUser,
IFS.street, MF_Streets340.StreetCode, 1
FROM InterfaceFromSimulNewDepts IFS
LEFT JOIN Cities ON IFS.City = Cities.cityCode
LEFT JOIN Streets ON IFS.street = Streets.Name
	AND Cities.cityCode = Streets.CityCode
LEFT JOIN MF_Streets340 ON IFS.street = MF_Streets340.Name
	AND IFS.City = MF_Streets340.CityCode 
WHERE SimulDeptId = @DeptCode

SET @ErrorCode = @@ERROR

GO

GRANT EXEC ON rpc_insertDept TO PUBLIC
GO
--********************* END rpc_insertDept ******************************     



--******** YANIV - rpc_getEmployeeReceptionAndRemarks **************************************************

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
INNER JOIN [Services] ON desr.ServiceCode = [Services].ServiceCode
INNER JOIN x_dept_employee_service xdes ON [Services].serviceCode = xdes.serviceCode AND xdes.Status = 1
WHERE desr.EmployeeID = @EmployeeID AND desr.DeptCode = @deptCode
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
SELECT MIN(ValidFrom) as ChangeDate
,s.serviceCode AS ServiceOrProfessionCode, 
s.ServiceDescription as professionOrServiceDescription
FROM deptEmployeeReception der
INNER JOIN deptEmployeeReceptionServices  ders on der.receptionID = ders.receptionID
INNER JOIN [Services] s ON dERS.serviceCode = s.serviceCode
WHERE DeptCode = @DeptCode
AND EmployeeID = @EmployeeID
AND DATEDIFF(dd, ValidFrom ,@ExpirationDate) < 0 
AND DATEDIFF(dd, ValidFrom ,@ExpirationDate) >= -14
GROUP BY s.serviceCode, s.serviceDescription
/*
UNION 

SELECT MIN(ValidFrom) as ChangeDate
,p.ServiceCode AS ServiceOrProfessionCode, 
p.ServiceDescription as professionOrServiceDescription
FROM deptEmployeeReception der
INNER JOIN deptEmployeeReceptionProfessions derp on der.receptionID = derp.receptionID
INNER JOIN [Services] p ON dERP.professionCode = p.ServiceCode
WHERE DeptCode = @DeptCode
AND EmployeeID = @EmployeeID
AND DATEDIFF(dd, ValidFrom ,@ExpirationDate) < 0 
AND DATEDIFF(dd, ValidFrom ,@ExpirationDate) >= -14
GROUP BY p.ServiceCode, p.ServiceDescription
*/




--------  "doctorReception" (Doctor's Hours in Clinic) -------------------
/*
SELECT
dER.receptionID,
dER.EmployeeID,
dER.deptCode,
IsNull(dERP.professionCode, 0) as professionOrServiceCode,
IsNull([Services].ServiceDescription, 'NoData') as professionOrServiceDescription,
DER.validFrom,
DER.validTo,
'expirationDate' = DER.validTo,
'willExpireIn' = DATEDIFF(day, getdate(), IsNull(validTo,'01/01/2050')),
dER.receptionDay,
vReceptionDaysForDisplay.ReceptionDayName,
--dER.openingHour,
'openingHour' = 
	CASE closingHour 
		WHEN '00:00' THEN	
			CASE openingHour WHEN '00:01' THEN '24' WHEN '01:00' THEN '24' WHEN '00:00' THEN '24' ELSE openingHour END
		WHEN '23:59' THEN	
			CASE openingHour WHEN '00:01' THEN '24' WHEN '01:00' THEN '24' WHEN '00:00' THEN '24' ELSE openingHour END			
		ELSE openingHour END,

--dER.closingHour,
'closingHour' =
	CASE closingHour 
		WHEN '00:00' THEN	
			CASE openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN '00:00' THEN 'שעות' ELSE closingHour END
		WHEN '23:59' THEN	
			CASE openingHour WHEN '00:01' THEN 'שעות' WHEN '01:00' THEN 'שעות' WHEN '00:00' THEN 'שעות' ELSE closingHour END
		ELSE closingHour END,

'receptionRemarks' = dbo.fun_GetEmployeeRemarksForReception(dER.receptionID),
'serviceCodes' = dbo.fun_GetServiceCodesForEmployeeReception(dER.receptionID),
'receptionDaysInDept'= (SELECT COUNT(*) FROM deptEmployeeReception as dER2
						 INNER JOIN deptEmployeeReceptionServices as dERS2 ON dER2.receptionID = dERS2.receptionID
						 WHERE deptCode = @deptCode AND dER2.EmployeeID = @employeeID
						 AND dERP.professionCode = dERS2.serviceCode
		)

FROM deptEmployeeReception as dER
INNER JOIN deptEmployeeReceptionProfessions as dERP ON dER.receptionID = dERP.receptionID
INNER JOIN [Services] ON dERP.professionCode = [Services].ServiceCode
INNER JOIN vReceptionDaysForDisplay on dER.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode

WHERE deptCode = @DeptCode
AND dER.EmployeeID = @EmployeeID
AND (
	(validFrom is null OR DATEDIFF(dd, ValidFrom ,@ExpirationDate) >= 0 )
	and 
	(validTo is null OR  DATEDIFF(dd, ValidTo ,@ExpirationDate) <= 0 ) 
	)

UNION
*/
SELECT
dER.receptionID,
dER.EmployeeID,
dER.deptCode,
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
						 WHERE deptCode = @deptCode AND der2.EmployeeID = @EmployeeID
						 AND ders2.serviceCode = ders.serviceCode
		)

FROM deptEmployeeReception as dER
INNER JOIN deptEmployeeReceptionServices as dERS ON dER.receptionID = dERS.receptionID
INNER JOIN [Services] ON dERS.serviceCode = [Services].serviceCode
INNER JOIN x_dept_employee_service xdes 
	ON dER.deptCode = xdes.deptCode
	AND dER.EmployeeID = xdes.employeeID
	AND [Services].serviceCode = xdes.serviceCode 
	AND xdes.Status = 1
INNER JOIN vReceptionDaysForDisplay on dER.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode

WHERE der.deptCode = @DeptCode
AND dER.EmployeeID = @EmployeeID
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

FROM DeptEmployeePhones
INNER JOIN DIC_PhoneTypes ON DeptEmployeePhones.phoneType = DIC_PhoneTypes.phoneTypeCode
WHERE deptCode = @DeptCode
AND employeeID = @EmployeeID




GO



GRANT EXEC ON rpc_getEmployeeReceptionAndRemarks TO PUBLIC
GO


--**** AND rpc_getEmployeeReceptionAndRemarks **********************************


--**** YANIV - rpc_getServiceForPopUp_ViaClinic *******************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getServiceForPopUp_ViaClinic')
	BEGIN
		drop procedure rpc_getServiceForPopUp_ViaClinic
	END

GO




CREATE Procedure [dbo].[rpc_getServiceForPopUp_ViaClinic]
	(
		@DeptCode int,
		@ServiceCode int,
		@ExpirationDate datetime
	)

AS

DECLARE @DateAfterExpiration datetime

IF (@ExpirationDate is null OR @ExpirationDate <= cast('1/1/1900 12:00:00 AM' as datetime))
BEGIN
	SET  @DateAfterExpiration = GETDATE()
END	
ELSE
	SET @DateAfterExpiration = DATEADD(day, 1, @ExpirationDate)
	

----- serviceAndClinic
SELECT
dept.deptName,
'address' = dbo.GetAddress(Dept.deptCode),
cityName,
x_D_S.serviceCode,
x_D_S.deptCode,
[Services].serviceDescription,
'phones' = dbo.fun_getDeptServicePhones(@DeptCode, x_D_S.serviceCode),
'phonesForQueueOrder' = dbo.fun_getDeptServiceQueueOrderPhones_All(x_D_S.serviceCode, @DeptCode)

FROM x_dept_service AS x_D_S
INNER JOIN dept ON x_D_S.deptCode = dept.deptCode
INNER JOIN Cities ON Dept.cityCode = Cities.cityCode
INNER JOIN	[Services]	ON x_D_S.serviceCode = [Services].serviceCode

WHERE x_D_S.deptCode = @DeptCode
AND x_D_S.serviceCode = @ServiceCode

-- closest reception change date within 14 days
SELECT MIN(ValidFrom)
FROM DeptServiceReception
inner join vReceptionDaysForDisplay on receptionDay = ReceptionDayCode
WHERE deptCode = @DeptCode
AND	  serviceCode = @ServiceCode
AND DATEDIFF(dd, ValidFrom , GETDATE()) < 0 
AND DATEDIFF(dd, ValidFrom , GETDATE()) >= -14 


------ serviceReception  --------------------------------------
SELECT 
A.receptionID,
A.deptCode,
A.receptionDay,
vReceptionDaysForDisplay.ReceptionDayName,
A.validFrom,
'expirationDate' = A.validTo,
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

'receptionRemarks' = dbo.fun_GetDeptServiceHoursRemarks(A.receptionID)

FROM DeptServiceReception A
INNER JOIN vReceptionDaysForDisplay on A.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode

WHERE A.deptCode = @DeptCode
AND A.serviceCode = @ServiceCode
and (
		(   
			 ((validFrom IS not NULL and  validTo IS NULL) and (validFrom <= @DateAfterExpiration ))			
		  or ((validFrom IS NULL and validTo IS not NULL) and validTo >= @DateAfterExpiration)
		  or ((validFrom IS not NULL and  validTo IS not NULL) and (validFrom <= @DateAfterExpiration and validTo >= @DateAfterExpiration))
		
	     )
	  OR (validFrom IS NULL AND validTo IS NULL)
	)
ORDER BY receptionDay, openingHour

------- deptPhones ----------------
SELECT
phoneOrder,
'phone' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension)

FROM DeptPhones
WHERE deptCode = @DeptCode
AND phoneType <> 2 -- not fax


------ Service remarks -------------------------------------------------------------
SELECT 'remark' = dbo.rfn_GetFotmatedRemark(RemarkText), displayInInternet
FROM x_dept_service 
INNER JOIN DeptServiceRemarks ON x_dept_service.serviceCode= DeptServiceRemarks.serviceCode 
and x_dept_service.deptCode= DeptServiceRemarks.deptCode

WHERE x_dept_service.serviceCode = @ServiceCode
AND x_dept_service.DeptCode = @DeptCode
AND (ValidFrom is NULL OR ValidFrom <= @DateAfterExpiration)
AND (ValidTo is NULL OR ValidTo >= @DateAfterExpiration)





GO


GRANT EXEC ON rpc_getServiceForPopUp_ViaClinic TO PUBLIC
GO

--**** AND - rpc_getServiceForPopUp_ViaClinic *********************************




--**** YANIV - rpc_getEmployeeServicesInDept *********************************


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeeServicesInDept')
	BEGIN
		drop procedure rpc_getEmployeeServicesInDept
	END

GO


CREATE Procedure [dbo].[rpc_getEmployeeServicesInDept]
(
	@EmployeeID int,
	@DeptCode int
)

AS

SELECT
'ToggleID' = xdes.serviceCode,
xdes.x_Dept_Employee_ServiceID, 
xdes.deptCode,
xdes.employeeID,
xdes.serviceCode,
ServiceDescription,
StatusDescription,
desr.RemarkID,
dbo.rfn_GetFotmatedRemark(desr.RemarkText) as RemarkText,
'parentCode' = 0,
'QueueOrderDescription' = IsNull(DIC_QueueOrder.QueueOrderDescription, '&nbsp;'),
'phonesForQueueOrder' = [dbo].fun_getEmployeeServiceQueueOrderPhones_All(xdes.employeeID, xdes.deptCode, xdes.serviceCode),
IsService,
IsProfession

FROM x_Dept_Employee_Service as xdes
INNER JOIN EmployeeServices ON xdes.employeeID = EmployeeServices.employeeID
	AND xdes.serviceCode = EmployeeServices.serviceCode
INNER JOIN DIC_ActivityStatus dic ON xdes.Status = dic.Status
	
INNER JOIN [Services] ON xdes.serviceCode = [Services].ServiceCode
LEFT JOIN DeptEmployeeServiceRemarks desr ON xdes.DeptEmployeeServiceRemarkID = desr.DeptEmployeeServiceRemarkID
LEFT JOIN DIC_QueueOrder ON xdes.QueueOrder = DIC_QueueOrder.QueueOrder
--QueueOrder
WHERE xdes.deptCode = @DeptCode 
AND xdes.employeeID = @EmployeeID
ORDER BY  IsService, ServiceDescription

SELECT 
ESQOM.EmployeeServiceQueueOrderMethodID,
ESQOM.QueueOrderMethod,
--ESQOM.deptCode,
ESQOM.serviceCode,
--ESQOM.employeeID,
DIC_QueueOrderMethod.QueueOrderMethodDescription,
DIC_QueueOrderMethod.ShowPhonePicture,
DIC_QueueOrderMethod.SpecialPhoneNumberRequired,
x_Dept_Employee_ServiceID

FROM EmployeeServiceQueueOrderMethod ESQOM
INNER JOIN DIC_QueueOrderMethod ON ESQOM.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
INNER JOIN x_Dept_Employee_Service xDES 
	ON ESQOM.deptCode = xDES.deptCode
	AND ESQOM.EmployeeID = xDES.EmployeeID
	AND ESQOM.serviceCode = xDES.serviceCode
	
WHERE ESQOM.deptCode = @DeptCode
AND ESQOM.employeeID = @EmployeeID
ORDER BY QueueOrderMethod


SELECT 
x_Dept_Employee_ServiceID,
'shortPhoneTypeName' = CASE phoneType WHEN 2 THEN 'פקס' ELSE 'טל`' END,
phoneOrder,
'phoneNumber' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension)
FROM EmployeeServicePhones
WHERE x_Dept_Employee_ServiceID in
	(SELECT x_Dept_Employee_ServiceID 
	FROM x_Dept_Employee_Service 
	WHERE deptCode = @DeptCode 
	AND employeeID = @EmployeeID)

UNION

SELECT
x_Dept_Employee_ServiceID,
'shortPhoneTypeName' = CASE phoneType WHEN 2 THEN 'פקס' ELSE 'טל`' END,
phoneOrder,
'phoneNumber' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension)

FROM x_Dept_Employee_Service x_D_E_S
INNER JOIN DeptEmployeePhones 
	ON x_D_E_S.deptCode = DeptEmployeePhones.deptCode
	AND x_D_E_S.employeeID = DeptEmployeePhones.employeeID
	AND DeptEmployeePhones.phoneType <> 2
WHERE x_D_E_S.CascadeUpdateEmployeeServicePhones = 1

UNION

SELECT
x_Dept_Employee_ServiceID,
'shortPhoneTypeName' = CASE phoneType WHEN 2 THEN 'פקס' ELSE 'טל`' END,
phoneOrder,
'phoneNumber' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension)

FROM x_Dept_Employee_Service x_D_E_S
INNER JOIN x_Dept_Employee x_D_E
	ON x_D_E_S.deptCode = x_D_E.deptCode
	AND x_D_E_S.employeeID = x_D_E.employeeID
INNER JOIN DeptPhones
	ON x_D_E.deptCode = DeptPhones.deptCode
	AND DeptPhones.phoneType <> 2

WHERE x_D_E_S.CascadeUpdateEmployeeServicePhones = 1
AND x_D_E.CascadeUpdateDeptEmployeePhonesFromClinic = 1

SELECT
xdes.x_Dept_Employee_ServiceID,
EmployeeServiceQueueOrderMethod.employeeID,
EmployeeServiceQueueOrderMethod.deptCode,
EmployeeServiceQueueOrderMethod.serviceCode,
EmployeeServiceQueueOrderHoursID,
EmployeeServiceQueueOrderHours.EmployeeServiceQueueOrderMethodID,
EmployeeServiceQueueOrderHours.receptionDay,
ReceptionDayName,
FromHour,
ToHour
FROM EmployeeServiceQueueOrderHours 
INNER JOIN vReceptionDaysForDisplay ON EmployeeServiceQueueOrderHours.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode
INNER JOIN EmployeeServiceQueueOrderMethod ON EmployeeServiceQueueOrderHours.EmployeeServiceQueueOrderMethodID = EmployeeServiceQueueOrderMethod.EmployeeServiceQueueOrderMethodID
INNER JOIN x_Dept_Employee_Service as xdes 
	ON EmployeeServiceQueueOrderMethod.deptCode = xdes.deptCode
	AND EmployeeServiceQueueOrderMethod.serviceCode = xdes.serviceCode
	AND EmployeeServiceQueueOrderMethod.employeeID = xdes.employeeID

WHERE EmployeeServiceQueueOrderMethod.deptCode = @DeptCode
	AND EmployeeServiceQueueOrderMethod.employeeID = @EmployeeID
ORDER BY vReceptionDaysForDisplay.ReceptionDayCode, FromHour

GO


GRANT EXEC ON rpc_getEmployeeServicesInDept TO PUBLIC
GO

--**** END - rpc_getEmployeeServicesInDept *********************************

--**** YANIV - rpc_getDeptServiceForUpdate *****************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptServiceForUpdate')
	BEGIN
		drop procedure rpc_getDeptServiceForUpdate
	END

GO


CREATE Procedure [dbo].[rpc_getDeptServiceForUpdate]
	(
		@deptCode int,
		@serviceCode int 
	)

AS
/* "DeptService" */
SELECT
x_dept_service.deptCode, 
x_dept_service.serviceCode,
StatusDescription as Status,
x_dept_service.QueueOrder,
x_dept_service.ShowPhonesFromDept,
DIC_QueueOrder.QueueOrderDescription,
'PermitOrderMethods' = IsNull(DIC_QueueOrder.PermitOrderMethods, 0),
[Services].ServiceDescription,
[Services].officeServices

FROM x_dept_service
INNER JOIN [Services] ON x_dept_service.serviceCode = [Services].ServiceCode
INNER JOIN DIC_ActivityStatus ON x_dept_service.Status = DIC_ActivityStatus.Status
LEFT JOIN DIC_QueueOrder ON x_dept_service.QueueOrder = DIC_QueueOrder.QueueOrder
WHERE x_dept_service.deptCode = @deptCode
AND x_dept_service.serviceCode = @serviceCode

/* "ServiceReception_Original" */
SELECT
--'DepartCode' = @deptCode,
DSR.receptionID,
receptionDay,
openingHour,
closingHour,
DSR.validFrom,
DSR.validTo,
dsrr.RemarkID,
--'RemarkText' = REPLACE(RemarkText, '#',''),
'RemarkText' = dbo.rfn_GetFotmatedRemark(RemarkText),
EnableOverMidnightHours

FROM DeptServiceReception as DSR
LEFT JOIN DeptServiceReceptionRemarks as DSRr ON DSR.receptionID = DSRr.ServiceReceptionID
LEFT JOIN DIC_GeneralRemarks rem ON dsrr.RemarkID = rem.RemarkID
WHERE deptCode = @deptCode
AND serviceCode = @serviceCode 
 
SELECT 
openinghour, CLOSINGhour, receptionDay, dense_rank() over (order by  
openinghour, CLOSINGhour,dayGroup) as RecRank,
validFrom, validTo
from 
(
Select 
openinghour, CLOSINGhour , receptionDay,
sum(power(2,receptionDay-1)) over (partition by openinghour,  CLOSINGhour ) dayGroup, 
COUNT(*) as nrecs, validFrom, validTo
 
FROM v_ServiceReception--DeptServiceReception
where deptCode =  @deptCode AND serviceCode = @serviceCode    --     --
group by  DeptCode, openinghour, CLOSINGhour, receptionDay, validFrom, validTo) as a 


/* "DeptServicePhones" */
IF EXISTS 
(
	SELECT *
	FROM x_dept_service
	WHERE x_dept_service.deptCode = @deptCode
	AND x_dept_service.serviceCode = @serviceCode
	AND ShowPhonesFromDept = 0
)

	SELECT
	--phoneType,
	prePrefix,
	prefixCode,
	prefixValue as PrefixText,
	phone,
	null as phoneID,
	phoneOrder,
	extension

	FROM DeptServicePhones
	INNER JOIN DIC_PhonePrefix dic ON DeptServicePhones.Prefix = dic.prefixCode
	WHERE DeptCode = @deptCode
	AND ServiceCode = @serviceCode
ELSE
	SELECT
	--phoneType,
	prePrefix,
	prefixCode,
	prefixValue as PrefixText,
	phone,
	null as phoneID,
	phoneOrder,
	extension

	FROM DeptPhones
	INNER JOIN DIC_PhonePrefix dic ON DeptPhones.Prefix = dic.prefixCode
	WHERE DeptCode = @deptCode
	AND DeptPhones.PhoneType = 1 
	AND PhoneOrder = 1

/* "DeptServiceRemarks" */
SELECT TOP 1
RemarkID,
--'RemarkText' = REPLACE(RemarkText, '#',''),
'RemarkText' = dbo.rfn_GetFotmatedRemark(RemarkText),
ValidFrom,
ValidTo,
displayInInternet

FROM DeptServiceRemarks
WHERE DeptCode = @deptCode
AND ServiceCode = @serviceCode

/* "ServiceQueueOrderMethods_ForHeadline" */
DECLARE @QueueOrderMethods varchar(100)
SET @QueueOrderMethods = ''

SELECT @QueueOrderMethods = QueueOrderMethodDescription + ', ' + @QueueOrderMethods
FROM ServiceQueueOrderMethod
INNER JOIN DIC_QueueOrderMethod ON ServiceQueueOrderMethod.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
WHERE deptCode = @deptCode AND serviceCode = @serviceCode AND ShowPhonePicture = 0

SELECT @QueueOrderMethods = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) + ', '+ @QueueOrderMethods
FROM DeptPhones
INNER JOIN ServiceQueueOrderMethod ON DeptPhones.deptCode = ServiceQueueOrderMethod.deptCode
INNER JOIN DIC_QueueOrderMethod ON ServiceQueueOrderMethod.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
AND SpecialPhoneNumberRequired = 0 AND ShowPhonePicture = 1

WHERE DeptPhones.deptCode = @deptCode AND ServiceCode = @serviceCode AND phoneType = 1 AND phoneOrder = 1

SELECT @QueueOrderMethods = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) + ', '+ @QueueOrderMethods
FROM DeptServiceQueueOrderPhones
INNER JOIN ServiceQueueOrderMethod ON DeptServiceQueueOrderPhones.QueueOrderMethodID = ServiceQueueOrderMethod.QueueOrderMethodID
INNER JOIN DIC_QueueOrderMethod ON DIC_QueueOrderMethod.QueueOrderMethod = ServiceQueueOrderMethod.QueueOrderMethod
WHERE deptCode = @deptCode AND serviceCode = @serviceCode 
AND SpecialPhoneNumberRequired = 1

IF len(@QueueOrderMethods) > 1
-- remove last comma
BEGIN
	SET @QueueOrderMethods = SUBSTRING(@QueueOrderMethods, 0, len(@QueueOrderMethods))
END

SELECT TOP 1 @QueueOrderMethods FROM ServiceQueueOrderMethod

/* "ClinicPhones" */
SELECT TOP 1
prePrefix,
prefix,
phone,
extension
FROM DeptPhones
WHERE deptCode = @deptCode


GO


GRANT EXEC ON rpc_getDeptServiceForUpdate TO PUBLIC
GO

--**** END - rpc_getDeptServiceForUpdate *****************************

--**** YANIV - rpc_getDeptDetailsForUpdate ***************************

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
							INNER JOIN x_Dept_Employee_Position ON x_dept_employee.employeeID = x_Dept_Employee_Position.employeeID
								AND x_dept_employee.deptCode = x_Dept_Employee_Position.deptCode
							INNER JOIN mappingPositions ON x_Dept_Employee_Position.positionCode = mappingPositions.positionCode
							WHERE mappingPositions.mappedToManager = 1
							AND x_Dept_Employee_Position.deptCode = D.deptCode
							), ''),
D.administrativeManagerName,
'substituteAdministrativeManagerName' = IsNull((SELECT TOP 1 DegreeName + ' ' + lastName + ' ' + firstName
							FROM employee
							INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode
							INNER JOIN x_dept_employee ON employee.employeeID = x_dept_employee.employeeID
							INNER JOIN x_Dept_Employee_Position ON x_dept_employee.employeeID = x_Dept_Employee_Position.employeeID
								AND x_dept_employee.deptCode = x_Dept_Employee_Position.deptCode
							INNER JOIN mappingPositions ON x_Dept_Employee_Position.positionCode = mappingPositions.positionCode
							WHERE mappingPositions.mappedToAdministrativeManager = 1
							AND x_Dept_Employee_Position.deptCode = D.deptCode
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

-- THIRD SECTION --------------------------------------------------------
D.transportation,
D.parking,

-- FORTH SECTION --------------------------------------------------------
'districtCode' = IsNull(D.districtCode, -1),
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
x_dept_XY.ycoord

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

SELECT TOP 1 @QueueOrderMethods FROM ServiceQueueOrderMethod



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


--**** END - rpc_getDeptDetailsForUpdate *************************** 

-- **********************************************************************************************************************


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getPermissionTypeListPerUser')
	BEGIN
		DROP  Procedure  rpc_getPermissionTypeListPerUser
	END

GO

-- **********************************************************************************************************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getMainMenuData')
	BEGIN
		DROP  Procedure  rpc_getMainMenuData
	END

GO


CREATE Procedure [dbo].[rpc_getMainMenuData]
(
	@UserPermissions varchar(50), /* user's permissions comma delimited */
	@CurrentPageName varchar(100)
)
AS

DECLARE @Table_Base TABLE (ItemID int, Title varchar(100), Description varchar(100), Url varchar(200), ParentID int, OrderNumber int, HasRestrictions int)
DECLARE @Table_Parent TABLE (ItemID int, Title varchar(100), Description varchar(100), Url varchar(200), ParentID int, HasRestrictions int)
DECLARE @Table_Child TABLE (ItemID int, Title varchar(100), Description varchar(100), Url varchar(200), ParentID int, HasRestrictions int)
DECLARE @Recordsleft int
SET @Recordsleft = 0

SET @UserPermissions = IsNull(@UserPermissions, 0)

INSERT INTO @Table_Base (ItemID, Title, Description, Url, ParentID, OrderNumber, HasRestrictions)
SELECT DISTINCT ItemID, Title, Description, Url, ParentID, OrderNumber, 
'HasRestrictions' = CASE IsNull((SELECT COUNT(*) FROM MainMenuRestrictions WHERE MainMenuItemID = ItemID), 0) WHEN 0 THEN 0 ELSE 1 END 
FROM MainMenuItems mmi
INNER JOIN MainMenuItemsPermissions mmip ON mmi.ItemID = mmip.MenuItemID 
INNER JOIN (SELECT IntField FROM dbo.SplitString(@UserPermissions)) as sel ON mmip.RoleID = sel.IntField
WHERE (dbo.fun_ShowMenuItem(ItemID, @CurrentPageName) = 1 OR @CurrentPageName = '')
ORDER BY OrderNumber

INSERT INTO @Table_Parent (ItemID, Title, Description, Url, ParentID, HasRestrictions)
SELECT DISTINCT ItemID, Title, Description, Url, ParentID, HasRestrictions 
FROM @Table_Base WHERE ParentID is NULL

-- 1-st select
SELECT ItemID, Title, Description, Url, ParentID, HasRestrictions FROM @Table_Parent

SET @Recordsleft = (SELECT COUNT(*) FROM @Table_Base WHERE ParentID IN (SELECT ItemID FROM @Table_Parent) )

WHILE(@Recordsleft > 0)
	BEGIN
	
		DELETE @Table_Child
		
		INSERT INTO @Table_Child (ItemID, Title, Description, Url, ParentID, HasRestrictions)
		SELECT ItemID, Title, Description, Url, ParentID, HasRestrictions FROM @Table_Base	
																				 WHERE ParentID IN (SELECT ItemID FROM @Table_Parent) 
																				 ORDER BY OrderNumber
		
		-- (n + 1) select
		SELECT ItemID, Title, Description, Url, ParentID, HasRestrictions FROM @Table_Child
		
		DELETE @Table_Parent
		
		INSERT INTO @Table_Parent (ItemID, Title, Description, Url, ParentID, HasRestrictions)
		SELECT ItemID, Title, Description, Url, ParentID, HasRestrictions FROM @Table_Child
		
		SET @Recordsleft = (SELECT COUNT(*) FROM @Table_Base	WHERE ParentID IN (SELECT ItemID FROM @Table_Parent) )
		
	END

GO

GRANT EXEC ON rpc_getMainMenuData TO PUBLIC

GO

-- **********************************************************************************************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_getRolesForMenuItem')
	BEGIN
		DROP  FUNCTION  fun_getRolesForMenuItem
	END

GO

CREATE FUNCTION [dbo].fun_getRolesForMenuItem(@itemID INT)
RETURNS varchar(100)
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @strRoles VARCHAR(100)
	SET @strRoles = ''

	SELECT @strRoles = @strRoles + CONVERT(VARCHAR,RoleID) + ','
	FROM MainMenuItemsPermissions mmip 
	WHERE MenuItemID = @itemID
	
	
	IF (LEN(@strRoles) = 0)
		RETURN NULL
	ELSE	
		SET @strRoles = SUBSTRING(@strRoles, 1, LEN(@strRoles) -1)

	RETURN( @strRoles )
	
END

GO 

grant exec on fun_getRolesForMenuItem to public 
GO

-- **********************************************************************************************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getMainMenuItem')
	BEGIN
		DROP  Procedure  rpc_getMainMenuItem
	END

GO

CREATE Procedure dbo.rpc_getMainMenuItem
	(
		@ItemID int
	)


AS

	SELECT 
	MMI.ItemID,
	MMI.Title,
	MMI.Description,
	MMI.Url,
	'Roles' = dbo.fun_getRolesForMenuItem(@ItemID),
	MMI.ParentID,
	MMI.OrderNumber,
	'parentTitle' = IsNull(parMMI.Title, '')
	FROM MainMenuItems as MMI
	LEFT JOIN MainMenuItems as parMMI ON MMI.ParentID = parMMI.ItemID
	WHERE MMI.ItemID = @ItemID
	
	SELECT
	MainMenuRestrictionsID, MainMenuItemID, PageName
	FROM MainMenuRestrictions
	WHERE MainMenuItemID = @ItemID
	
GO

GRANT EXEC ON rpc_getMainMenuItem TO PUBLIC

GO

-- **********************************************************************************************************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertMainMenuItem')
	BEGIN
		DROP  Procedure  rpc_InsertMainMenuItem
	END

GO

CREATE PROCEDURE dbo.rpc_InsertMainMenuItem
	(
		@Title varchar(100),
		@Description varchar(100),
		@Url varchar(100),
		@Roles varchar(50),
		@ParentID int,
		
		@ItemID int OUTPUT
	)

AS

IF @ParentID = -1
BEGIN
	SET @ParentID = null
END

DECLARE @OrderNumber int

SET @OrderNumber = (SELECT MAX(OrderNumber) FROM MainMenuItems WHERE (@ParentID is NOT null AND ParentID = @ParentID) OR (@ParentID is null AND ParentID is null) )
SET @OrderNumber = IsNull(@OrderNumber, 0) + 1

SET @ItemID = IsNull((SELECT MAX(ItemID) FROM MainMenuItems), 0) + 1

INSERT INTO MainMenuItems
(ItemID, Title, Description, Url, ParentID, OrderNumber)
VALUES
(@ItemID, @Title, @Description, @Url, @ParentID, @OrderNumber)


INSERT INTO MainMenuItemsPermissions
SELECT @ItemID, IntField
FROM dbo.SplitString(@Roles)

	

GO


GRANT EXEC ON rpc_InsertMainMenuItem TO PUBLIC

GO

-- **********************************************************************************************************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateMainMenuItem')
	BEGIN
		DROP  Procedure  rpc_UpdateMainMenuItem
	END

GO

CREATE PROCEDURE dbo.rpc_UpdateMainMenuItem
	(
		@ItemID int,
		@Title varchar(100),
		@Description varchar(100),
		@Url varchar(100),
		@Roles varchar(50),
		
		@ErrorStatus int OUTPUT
	)

AS


SET @ErrorStatus = 0
	

	UPDATE MainMenuItems
	SET Title = @Title,
	Description = @Description,
	Url = @Url
	WHERE ItemID = @ItemID

	DELETE MainMenuItemsPermissions
	WHERE MenuItemID = @ItemID

	INSERT INTO MainMenuItemsPermissions
	SELECT @itemID, IntField
	FROM dbo.SplitString(@Roles)

	
	SET @ErrorStatus = @@Error
	
GO

GRANT EXEC ON rpc_UpdateMainMenuItem TO PUBLIC

GO

-- **********************************************************************************************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDeptsForTextFile')
	BEGIN
		DROP  Procedure  rpc_GetDeptsForTextFile
	END

GO

CREATE Procedure dbo.rpc_GetDeptsForTextFile

AS

SELECT deptCode, teur,city,streetName,house,entrance,flat,doarna,zipCode,preprefix1,prefix1,nphone1,preprefix2,prefix2,nphone2,faxpreprefix,FaxPrefix, nfax,menahel,email,
GEO_X,GEO_Y, filler + char(13) + char(10) as 'filler'
FROM (

SELECT   1  as UnionID ,

 	('SEFER-') AS deptCode,
	('SHERUT' +  space(8)  
		+ CAST( Datepart(yyyy,GETDATE()) as varchar(4)) 
		+ right('0' + CAST(Datepart(mm,GETDATE()) as varchar(2)), 2) 
		+ right('0' + CAST(Datepart(dd,GETDATE()) as varchar(2)),2)
		+ space(28)
	)as teur,
           space(4) AS city,
           space(17) AS streetName,
           space(4) AS house,
           space(1) AS entrance,
           space(3) AS flat,
           space(17) AS doarna,
           space(5) AS zipCode,
           space(2) AS preprefix1,
           space(3) AS prefix1,
           space(7) AS nphone1,
           space(2) AS preprefix2,
           space(3) AS prefix2,
           space(7) AS nphone2,
           space(2) AS faxpreprefix,
           space(3) AS FaxPrefix,
           space(7) AS nfax,
           space(20) AS menahel,
           space(40) AS email,
           space(10) AS GEO_X,
           space(10) AS GEO_Y,           
           space(7) as filler

UNION
SELECT   2  as UnionID ,
     right('000000' + CAST(dept.deptCode AS varchar(6)),6) AS deptCode, 
	   left(CAST(deptName AS varchar(50)) + space(50) ,50)as teur,
           right('0000' + CAST(cityCode AS varchar(4)),4) AS city,
           'street'=
           case 
              when streetName is not null then left(CAST(streetName AS varchar(17)) + space(17) ,17)
              else space(17) end,
			'house'= case
              when house is not null then right('0000' + CAST(house AS varchar(4)),4)
              else '0000' end,
			'entrance'= case 
              when entrance is not null then CAST(entrance AS char(1)) 
              else space(1) end,
			'flat'= case 
              when flat is not null then left(CAST(flat AS varchar(3)) + space(3) ,3)
              else space(3) end,
			'doarna'= space(17),
			'zipCode'= case
              when zipCode is not null then right('00000' + CAST(zipCode AS varchar(5)),5)
              else '00000' end,
			'preprefix1'= case 
              when DP1.prePrefix is not null and DP1.prePrefix = 2 then '90'
              when DP1.prePrefix is not null and DP1.prePrefix <> 2 then right('00' + CAST(DP1.prePrefix AS varchar(2)),2)
              else '00' end,
			'prefix1'= case 
              when PP1.prefixValue is not null  then right('000' + CAST(PP1.prefixValue AS varchar(3)),3)
              else '000' end,
			'nphone1'= case 
              when DP1.phone is not null then right('0000000' + CAST(DP1.phone AS varchar(7)),7)
              else '0000000' end,     
			'preprefix2'= case 
              when DP2.prePrefix is not null and DP2.prePrefix = 2 then '90'
              when DP2.prePrefix is not null and DP2.prePrefix <> 2 then right('00' + CAST(DP2.prePrefix AS varchar(2)),2)
              else '00' end,
			'prefix2'= case 
              when PP2.prefixValue is not null  then right('000' + CAST(PP2.prefixValue AS varchar(3)),3)
              else '000' end,
			'nphone2'= case 
              when DP2.phone is not null then right('0000000' + CAST(right(DP2.phone,7) AS varchar(7)),7)              
              else '0000000' end,     
			'faxpreprefix'= case 
              when DP3.prePrefix is not null then right('00' + CAST(DP3.prePrefix AS varchar(2)),2)              
              else '00' end,
			'FaxPrefix'= case 
              when PP3.prefixValue is not null  then right('000' + CAST(PP3.prefixValue AS varchar(3)),3)              
              else '000' end,
			'nfax'= case 
              when DP3.phone is not null then right('0000000' + CAST(right(DP3.phone,7) AS varchar(7)),7)
              else '0000000' end,     
			'menahel'= case 
              when managerName is not null then left(CAST(managerName AS varchar(20)) + space(20) ,20)              
              else space(20) end, 
			'email'= case 
              when email is not null then UPPER(left(CAST(email AS varchar(40)) + space(40) ,40) )                 
              when email is NULL then  space(40)
           end,
           ISNULL( RIGHT(space(10) +  CAST(CAST( xcoord as decimal(16,3)) as varchar(20)), 10), space(10)) AS GEO_X,
           ISNULL( RIGHT(space(10) +  CAST(CAST( ycoord as decimal(16,3)) as varchar(20)), 10), space(10)) AS GEO_Y, 
           space(7) as filler

FROM dept
LEFT JOIN DeptPhones DP1 ON dept.deptCode = DP1.deptCode and DP1.phoneOrder = 1 and DP1.phoneType = 1
LEFT JOIN DeptPhones DP2 ON dept.deptCode = DP2.deptCode and DP2.phoneOrder = 2 and DP2.phoneType = 1
LEFT JOIN DeptPhones DP3 ON dept.deptCode = DP3.deptCode and DP3.phoneOrder = 1 and DP2.phoneType = 2
LEFT JOIN DIC_PhonePrefix PP1 ON DP1.prefix = PP1.prefixCode
LEFT JOIN DIC_PhonePrefix PP2 ON DP2.prefix = PP2.prefixCode
LEFT JOIN DIC_PhonePrefix PP3 ON DP3.prefix = PP3.prefixCode
LEFT JOIN x_dept_XY ON dept.deptCode = x_dept_XY.deptCode
WHERE len(dept.deptCode)<7 
AND dept.IsCommunity = 1

UNION
SELECT   3  as UnionID ,
 	('SEFER-') AS deptCode,
	('SHERUT' +  space(8)  
		+ CAST( Datepart(yyyy,GETDATE()) as varchar(4)) 
		+ right('0' + CAST(Datepart(mm,GETDATE()) as varchar(2)),2) 
		+ right('0' + CAST(Datepart(dd,GETDATE()) as varchar(2)),2)
		+ right( space(7) + CAST( (SELECT Count(*) FROM dept WHERE len(deptCode)<7 ) as varchar(7)),7 )
		+ '@@@'
		+ space(18)
	)as teur,
           space(4) AS city,
           space(17) AS streetName,
           space(4) AS house,
           space(1) AS entrance,
           space(3) AS flat,
           space(17) AS doarna,
           space(5) AS zipCode,
           space(2) AS preprefix1,
           space(3) AS prefix1,
           space(7) AS nphone1,
           space(2) AS preprefix2,
           space(3) AS prefix2,
           space(7) AS nphone2,
           space(2) AS faxpreprefix,
           space(3) AS FaxPrefix,
           space(7) AS nfax,
           space(20) AS menahel,
           space(40) AS email,
           space(10) AS GEO_X,
           space(10) AS GEO_Y,           
           space(7) AS filler
) as UnionTbl 

Order by  UnionID

GO

GRANT EXEC ON rpc_GetDeptsForTextFile TO PUBLIC

GO


-- **********************************************************************************************************************



--**** Yaniv - new function fun_GetSubUnitsNames ****************************************

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fun_GetSubUnitsNames]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fun_GetSubUnitsNames]
GO


CREATE FUNCTION [dbo].[fun_GetSubUnitsNames]
(
	@UnitCode int
)
RETURNS varchar(1000)
AS
BEGIN
	declare @myTable table
	(
		UnitID INT IDENTITY(1,1),
		UnitName varchar(50)   
	    
	)

	insert into @myTable(UnitName) select DIC_subUnitTypes.subUnitTypeName from subUnitType,DIC_subUnitTypes
	 where DIC_subUnitTypes.subUnitTypeCode=subUnitType.subUnitTypeCode
	 and UnitTypeCode=@UnitCode
	declare @I int
	declare @RowCount int
	declare @Res varchar(1000)

	set @Res = ''
	set @RowCount = (Select Count(*) From @myTable)
	set @I = 1


	WHILE (@I <= @RowCount)
	BEGIN
	        
			DECLARE @iUnitName VARCHAR(50)    
	        
			SELECT @iUnitName = UnitName FROM @myTable WHERE UnitID = @I
	        
			if @iUnitName is not null
				if @Res = ''
					set @Res = @Res + @iUnitName
				else	
					set @Res = @Res + '; ' + @iUnitName
	        
	        
			SET @I = @I  + 1
	END
	return @Res

END
GO

grant exec on fun_GetSubUnitsNames to public 
GO

--**** END fun_GetSubUnitsNames ******************

--**** Yaniv - rpc_GetDeptCategory ***************
  
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDeptCategory')
BEGIN
	DROP  Procedure  rpc_GetDeptCategory
END

GO

CREATE Procedure [dbo].[rpc_GetDeptCategory]
	
AS
	SELECT * FROM DIC_DeptCategory

GRANT EXEC ON rpc_GetDeptCategory TO PUBLIC
GO

--**** END - rpc_GetDeptCategory ***************

--**** YANIV - rpc_insertUnitType **************
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_insertUnitType]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[rpc_insertUnitType]
GO

CREATE PROCEDURE [dbo].[rpc_insertUnitType]
(
	@UnitTypeCode int ,
	@UnitTypeName varchar(100), 
	@AllowQueueOrder bit,
	@ShowInInternet bit,			
	@defaultSubUnitTypeCode int,
	@UpdateUser varchar(50),
	@CategoryID tinyint,
	@ErrCode int OUTPUT	   
)


AS

INSERT INTO [dbo].[UnitType]
		   ([UnitTypeCode],
			[UnitTypeName],
			[ShowInInternet],
			[AllowQueueOrder],
			[defaultSubUnitTypeCode],
			[UpdateUser],
			[UpdateDate],
			[CategoryID])
	 VALUES
		   (@UnitTypeCode,
			@UnitTypeName ,                   
			@ShowInInternet,
			@AllowQueueOrder,  
			@defaultSubUnitTypeCode,
			@UpdateUser,
			getDate(),
			@CategoryID)

SET @ErrCode = @@Error

GO

GRANT EXEC ON rpc_insertUnitType TO PUBLIC
GO

--**** END - rpc_insertUnitType ************

--**** YANIV -rpc_updateUnitTypes **************************** 


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateUnitTypes')
	BEGIN
		DROP  Procedure  rpc_updateUnitTypes
	END

GO

CREATE PROCEDURE [dbo].[rpc_updateUnitTypes]
(	
	@code INT, 		
	@name VARCHAR(100),
	@userName VARCHAR(100),
	@showInInternet BIT,
	@allowQueueOrder BIT,
	@isActive BIT,
	@defaultSubUnitCode INT,
	@CategoryID tinyint
)
as  

UPDATE [UnitType]       
	  SET  [UnitTypeName] = @name ,
		   [ShowInInternet]= @showInInternet,
		   [AllowQueueOrder]=@allowQueueOrder,
		   [UpdateUser]=@userName,
			[UpdateDate] = getdate(),
			IsActive = @isActive,
			DefaultSubUnitTypeCode = @defaultSubUnitCode,
			CategoryID = @CategoryID
	   WHERE [UnitTypeCode] = @code  


GO

GRANT EXEC ON rpc_updateUnitTypes TO PUBLIC


--**** END - rpc_updateUnitTypes ****************************


--**** YANIV - rpc_insertSubUnitTypes *****************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertSubUnitTypes')
	BEGIN
		DROP  Procedure  rpc_insertSubUnitTypes
	END

GO


CREATE Procedure [dbo].[rpc_insertSubUnitTypes]
(  
	@subUnitTypeCodeList varchar(100), 	
	@unitTypeCode int, 	
	@userName varchar(100)		
)
as  

declare @myTable table
	(
		ID INT IDENTITY(1,1),
		UnitCode int   
	    
	)

delete from subUnitType where UnitTypeCode=@unitTypeCode

-- Get the subUnitTypeCodes from the list into the table
-- and then run a loop on it	
insert into @myTable(UnitCode)select * from rfn_SplitStringByDelimiterValuesToStr(@subUnitTypeCodeList,',')
declare @i int
declare @RowCount int

set @RowCount = (Select Count(*) From @myTable)
set @i = 1
WHILE (@i <= @RowCount)
	BEGIN
	        DECLARE @iSubUnitTypeCode int    
	        SELECT @iSubUnitTypeCode = UnitCode FROM @myTable WHERE ID = @i
	        Insert into subUnitType(subUnitTypeCode,UnitTypeCode,UpdateDate,UpdateUser)
				values(@iSubUnitTypeCode,@unitTypeCode,GETDATE(),@userName)
			SET @i = @i  + 1
	END

GO

GRANT EXEC ON rpc_insertSubUnitTypes TO PUBLIC

--**** END - rpc_insertSubUnitTypes *****************************

--**** YANIV - rpc_getServiceForPopUp_ViaEmployee **********************


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_getServiceForPopUp_ViaEmployee]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[rpc_getServiceForPopUp_ViaEmployee]
GO

CREATE Procedure [dbo].[rpc_getServiceForPopUp_ViaEmployee]
	(
		@DeptCode int,
		@EmployeeID int,
		@ServiceCode int,
		@ExpirationDate datetime
	)

AS

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
SELECT serviceDescription FROM [Services] WHERE ServiceCode = @ServiceCode

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
dER.EmployeeID,
dER.deptCode,
IsNull(dERS.serviceCode, 0) as professionOrServiceCode,
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

FROM deptEmployeeReception as dER
LEFT JOIN deptEmployeeReceptionServices as dERS ON dER.receptionID = dERS.receptionID
LEFT JOIN [Services] ON dERS.serviceCode = [Services].serviceCode
INNER JOIN DIC_ReceptionDays on dER.receptionDay = DIC_ReceptionDays.ReceptionDayCode

WHERE dER.deptCode = @DeptCode
AND dER.EmployeeID = @EmployeeID
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
WHERE der.deptCode = @DeptCode
AND der.EmployeeID = @EmployeeID
AND ders.serviceCode = @ServiceCode
AND DATEDIFF(dd, ValidFrom, GETDATE()) < 0
AND DATEDIFF(dd, ValidFrom, GETDATE()) >= -14



SELECT  
deptCode,
employeeID,
serviceCode,
REPLACE(desr.RemarkText,'#','') as Remark,
DisplayInInternet

FROM DeptEmployeeServiceRemarks desr 

WHERE deptCode = @DeptCode 
AND employeeID = @EmployeeID
AND ServiceCode = @serviceCode


GO

GRANT EXEC ON rpc_getServiceForPopUp_ViaEmployee TO PUBLIC
GO

--*** END - rpc_getServiceForPopUp_ViaEmployee **********************




------------ 10/11/2011 julia -------------------------------
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getUserPermittedDistrictsForReports')
	BEGIN
		DROP  Procedure  rpc_getUserPermittedDistrictsForReports
	END

GO

CREATE Procedure dbo.rpc_getUserPermittedDistrictsForReports
	(
		@UserID bigint
	)

AS
select distinct * from
(SELECT 
'districtCode' = dept.deptCode, 'districtName' = dept.deptName
FROM dept
WHERE (deptCode IN (SELECT deptCode FROM UserPermissions WHERE UserID = @UserID AND PermissionType in(1, 6))
	OR (SELECT MAX(PermissionType) FROM UserPermissions WHERE UserID = @UserID) = 5)
AND typeUnitCode = 65
)
as temp
ORDER BY districtName
GO

GRANT EXEC ON rpc_getUserPermittedDistrictsForReports TO PUBLIC

GO


------------------13/11/2011    julia-----------------------------
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
	AND (''' + @DistrictCodes + ''' = ''-1'' or  d.districtCode IN (SELECT IntField FROM dbo.SplitString( ''' + @DistrictCodes + ''')) )
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
		set @sql = @sql + 'dbo.rfn_FormatAddress(d.streetName, d.house, d.flat, d.floor, Cities.CityName ) as ClinicAddress '+ @NewLineChar;
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
		set @sql = @sql + 'dbo.rfn_FormatAddress(SubClinics.streetName, SubClinics.house, SubClinics.flat, SubClinics.floor, SubClinicCities.CityName ) as SubClinicAddress '+ @NewLineChar;
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


--**** Yaniv - rpc_getServiceCategories *************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getServiceCategories')
	BEGIN
		DROP  Procedure  rpc_getServiceCategories
	END

GO


CREATE PROCEDURE [dbo].[rpc_getServiceCategories]
	@ServiceCategoryID int, 
	@ServiceCategoryDescription varchar(500),
	@SubCategoryFromTableMF51 int
AS
	SELECT DISTINCT
	ServiceCategories.ServiceCategoryID,
	ServiceCategoryDescription,
	SubCategoryFromTableMF51 as 'MF_Specialities051Code',
	MF_Specialities051.Description as 'SubCategoryFromTableMF51',
	MF_Specialities051.Code as 'SubCategoryCodeFromTableMF51',
	CASE  WHEN xSCS.ServiceCode is null THEN 0 ELSE 1 END as 'HasAttributedServices'
	FROM ServiceCategories
	LEFT JOIN x_ServiceCategories_Services xSCS ON ServiceCategories.ServiceCategoryID = xSCS.ServiceCategoryID
	LEFT JOIN MF_Specialities051 ON ServiceCategories.SubCategoryFromTableMF51 = MF_Specialities051.Code
	WHERE (@ServiceCategoryID is null OR ServiceCategories.ServiceCategoryID = @ServiceCategoryID)
	AND (@ServiceCategoryDescription is null OR ServiceCategoryDescription LIKE '%'+ @ServiceCategoryDescription +'%')
	AND (@SubCategoryFromTableMF51 is null OR SubCategoryFromTableMF51 = @SubCategoryFromTableMF51)

GO


GRANT EXEC ON rpc_getServiceCategories TO PUBLIC
GO

--**** END - rpc_getServiceCategories *************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteEmployeeServicePhones')
	BEGIN
		DROP  Procedure  rpc_DeleteEmployeeServicePhones
		PRINT 'DROP  Procedure  rpc_DeleteEmployeeServicePhones'
	END
GO

CREATE PROCEDURE [dbo].[rpc_DeleteEmployeeServicePhones]
	@x_Dept_Employee_ServiceID int, 
	@phoneType int

AS
	DELETE FROM EmployeeServicePhones
	WHERE (@x_Dept_Employee_ServiceID is null OR x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID)
	AND (@phoneType is null OR phoneType = @phoneType)
GO

GRANT EXEC ON dbo.rpc_DeleteEmployeeServicePhones TO PUBLIC
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteEmployeeServiceQueueOrderMethods')
	BEGIN
		DROP  Procedure  rpc_DeleteEmployeeServiceQueueOrderMethods
		PRINT 'DROP  Procedure  rpc_DeleteEmployeeServiceQueueOrderMethods'
	END
GO

CREATE PROCEDURE [dbo].[rpc_DeleteEmployeeServiceQueueOrderMethods]
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
								 FROM EmployeeServiceQueueOrderMethod ESQOM
								 INNER JOIN x_Dept_Employee_Service xDES 
									ON ESQOM.deptCode = xDES.deptCode
									AND ESQOM.serviceCode = xDES.serviceCode
									AND ESQOM.employeeID = xDES.employeeID
								 WHERE xDES.x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID)
	
	
	UPDATE x_Dept_Employee_Service
	SET QueueOrder = -1
	WHERE x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID
END
GO

GRANT EXEC ON rpc_DeleteEmployeeServiceQueueOrderMethods TO PUBLIC
GO



--** YANIV - Update rpc_DeptOverView --**********************************


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


DECLARE @ExpirationDate datetime = DATEADD(day, DATEDIFF(day, 0, getdate()), 0) 
DECLARE @DateAfterExpiration datetime = DATEADD(day, 1, DATEADD(day, DATEDIFF(day, 0, getdate()), 0))


SELECT 
Dept.deptCode,
Dept.deptName,
Dept.typeUnitCode,
UnitType.UnitTypeName,
'subUnitTypeName' = '(' + View_SubUnitTypes.subUnitTypeName + ')',
'managerName' = dbo.fun_getManagerName(Dept.deptCode), 
'administrativeManagerName' = dbo.fun_getAdminManagerName(Dept.deptCode),
Dept.districtCode,
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
'simpleAddress' = CASE RTRIM(LTRIM(isNull(house, ''))) 
	WHEN '' THEN isNull(streetName,'') ELSE (isNull(streetName + ', ', '') + CAST(house as varchar(3)) ) END,
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
deptLevelDescription

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

WHERE dept.deptCode= @DeptCode



------ dept receptions -------------------------------------------------------------
SELECT 
DeptReception.receptionDay,
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

'ReceptionDaysCount' = 
(select count(receptionDay) 
	FROM DeptReception
	where deptCode=@DeptCode
	and (
			(   
				((validFrom IS not NULL and  validTo IS NULL) and (getDate() >= validFrom ))			
				or ((validFrom IS NULL and validTo IS not NULL) and validTo >= getDate())
				or ((validFrom IS not NULL and  validTo IS not NULL) and (getDate() >= validFrom and validTo >= getDate()))
		
			)
			OR (validFrom IS NULL AND validTo IS NULL)
		)
),
'remarks' = dbo.fun_getDeptReceptionRemarksValid(receptionID),
'willExpireIn' = DATEDIFF(day, getdate(), IsNull(validTo,'01/01/2050')),
'expirationDate' = validTo,
deptCode

FROM DeptReception
inner join vReceptionDaysForDisplay on DeptReception.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode

where deptCode=@DeptCode
and (
			(   
				((validFrom IS not NULL and  validTo IS NULL) and (getDate() >= validFrom ))			
				or ((validFrom IS NULL and validTo IS not NULL) and validTo >= getDate())
				or ((validFrom IS not NULL and  validTo IS not NULL) and (getDate() >= validFrom and validTo >= getDate()))
		
			)
			OR (validFrom IS NULL AND validTo IS NULL)
		)
order by receptionDay, openingHour


-- closest added reception dates   ***************************

SELECT dr.ValidFrom as ClosestDeptReceptionAdd, 
dsr.ValidFrom as ClosestOfficeReceptionAdd,
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
				((validFrom IS not NULL and  validTo IS NULL) and (getDate() >= validFrom ))			
				or ((validFrom IS NULL and validTo IS not NULL) and validTo >= getDate())
				or ((validFrom IS not NULL and  validTo IS not NULL) and (getDate() >= validFrom and validTo >= getDate()))
		
			)
			OR (validFrom IS NULL AND validTo IS NULL)
	 )
)
FROM 
		(SELECT MIN(ValidFrom) as ValidFrom FROM DeptReception 
		 inner join vReceptionDaysForDisplay on receptionDay = ReceptionDayCode
		 WHERE DeptCode = @deptCode 
		 AND DATEDIFF(dd, ValidFrom, GETDATE()) < 0 
		 AND DATEDIFF(dd, ValidFrom, GETDATE()) >= -14
		 ) as dr , 
		 
		 (SELECT MIN(ValidFrom) as ValidFrom 
		  FROM DeptServiceReception 
		  INNER JOIN [Services] ON DeptServiceReception.serviceCode = [Services].ServiceCode
		  inner join vReceptionDaysForDisplay on receptionDay = ReceptionDayCode
		  WHERE officeServices = 1
		  AND DeptCode = @deptCode
		  AND DATEDIFF(dd, ValidFrom, GETDATE()) < 0
          AND DATEDIFF(dd, ValidFrom, GETDATE()) >= -14
          ) as dsr

------------- "deptDoctors" (Doctors in Clinic) ***************************

SELECT ISNULL(GrOuter.EmployeeServiceQueueOrderGroup, '00000000000000') as EmployeeServiceQueueOrderGroup, 
ISNULL(GrPhones, '') as GrPhones, 
GrOuter3.QueueOrderDescription,
ToggleID_tmp + row_number() over (order by GrOuter.EmployeeServiceQueueOrderGroup desc) as ToggleID,
MainSelect.* FROM(
SELECT
'ToggleID_tmp' = x_dept_employee.employeeID,
x_dept_employee.deptCode,
x_dept_employee.employeeID,
x_dept_employee.AgreementType,
Employee.EmployeeSectorCode,
'DoctorName' = DegreeName + ' ' + lastName + ' ' + firstName,
'active' = x_dept_employee.active

,ActiveForSort = case  when x_dept_employee.active = 0 then 10 else x_dept_employee.active end
,Professions = dbo.rfn_GetDeptEmployeeProfessionDescriptions(x_dept_employee.deptCode, x_dept_employee.employeeID)
,[Services] = dbo.rfn_GetDeptEmployeesServiceDescriptions(x_dept_employee.deptCode, x_Dept_Employee.employeeID)
,QueueOrderDescriptions = dbo.rfn_GetDeptEmployeeQueueOrderDescriptions(x_dept_employee.deptCode, x_Dept_Employee.employeeID)
,Phone = dbo.rfn_GetDeptEmployeePhoneDescriptions(x_dept_employee.deptCode, x_Dept_Employee.employeeID)

,'expert' = dbo.fun_GetEmployeeExpert(x_dept_employee.employeeID),
'hasAnotherWorkPlace' = IsNull((SELECT COUNT(*) FROM x_Dept_Employee as XDE JOIN dept ON XDE.deptCode = dept.deptCode WHERE XDE.deptCode <> @DeptCode AND EmployeeID = Employee.employeeID AND Employee.IsMedicalTeam = 0 AND dept.status <> 0), 0),
'ShowPhonesFromDept' = CascadeUpdateDeptEmployeePhonesFromClinic,
'ReceptionDaysCount' = (SELECT Count(*) FROM 
	(	
	SELECT receptionDay
	FROM deptEmployeeReception der
	INNER JOIN DeptEmployeeReceptionServices ders ON der.receptionID = ders.receptionID
	INNER JOIN x_dept_employee_service xdes ON ders.serviceCode = xdes.serviceCode 
				AND xdes.EmployeeID = x_dept_employee.employeeID AND xdes.DeptCode = @deptCode
	WHERE der.deptCode = @DeptCode
	AND der.employeeid = x_dept_employee.employeeid
	AND xdes.status = 1
	AND (
			(   
				((validFrom IS not NULL and  validTo IS NULL) and (getDate() >= validFrom ))			
				or ((validFrom IS NULL and validTo IS not NULL) and validTo >= getDate())
				or ((validFrom IS not NULL and  validTo IS not NULL) and (getDate() >= validFrom and validTo >= getDate()))
		
			)
			OR (validFrom IS NULL AND validTo IS NULL)
		)
	) as t),
--'QueueOrderDescription' = IsNull(DIC_QueueOrder.QueueOrderDescription, '&nbsp;'),					
'PermitOrderMethods' = IsNull(DIC_QueueOrder.PermitOrderMethods, 0),
'phonesForQueueOrder' = dbo.fun_getEmployeeQueueOrderPhones_All(Employee.employeeID, @DeptCode),
'HasRemarks' = (SELECT CASE MAX(x) WHEN 0 THEN 0 ELSE 1 END
				FROM
				(SELECT COUNT(*) as x 
				FROM View_DeptEmployee_EmployeeRemarks v
				WHERE v.employeeID = x_dept_employee.EmployeeID
				AND (DeptCode = @DeptCode OR AttributedToAllClinicsInCommunity = 1)
				AND (v.ValidFrom is NULL OR v.ValidFrom < @DateAfterExpiration)
				AND (v.ValidTo is NULL OR v.ValidTo >= @ExpirationDate) 
				UNION
				SELECT COUNT(*) as x
				FROM DeptEmployeeServiceRemarks desr
				WHERE desr.DeptCode = @DeptCode
				AND desr.EmployeeID = x_dept_employee.EmployeeID
				AND (ValidFrom is NULL OR ValidFrom < @DateAfterExpiration)
				AND (ValidTo is NULL OR ValidTo >= @ExpirationDate)
				) as t
				),
IsMedicalTeam,
IsVirtualDoctor,
Employee.lastName

FROM x_dept_employee
INNER JOIN Employee ON x_dept_employee.employeeID = Employee.employeeID
INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode
INNER JOIN EmployeeSector ON Employee.EmployeeSectorCode = EmployeeSector.EmployeeSectorCode
LEFT JOIN DIC_QueueOrder ON x_dept_employee.QueueOrder = DIC_QueueOrder.QueueOrder
WHERE x_dept_employee.deptCode = @DeptCode
-- ORDER BY EmployeeSectorCode DESC, Employee.lastName
) as MainSelect
LEFT JOIN
(SELECT * FROM
	(
		SELECT employeeID--, x_D_E_S.serviceCode
		, dbo.fun_GetEmployeeServiceQueueOrderGroup(x_D_E_S.deptCode, x_D_E_S.employeeID, x_D_E_S.serviceCode ) as EmployeeServiceQueueOrderGroup
		FROM x_Dept_Employee_Service x_D_E_S
		WHERE x_D_E_S.deptCode = @DeptCode 
		) as GrInner
		GROUP BY employeeID, EmployeeServiceQueueOrderGroup
	) as GrOuter 
	ON MainSelect.employeeID = GrOuter.employeeID
LEFT JOIN
(SELECT * FROM
	(
		SELECT dbo.fun_getEmployeeQueueOrderPhones_ByQueueOrderGroup(deptCode, employeeID, serviceCode) as GrPhones,
		dbo.fun_GetEmployeeServiceQueueOrderGroup(x_D_E_S.deptCode, x_D_E_S.employeeID, x_D_E_S.serviceCode ) as EmployeeServiceQueueOrderGroup
		FROM x_Dept_Employee_Service x_D_E_S
		WHERE x_D_E_S.deptCode = @DeptCode 
		) as GrInner2
		GROUP BY EmployeeServiceQueueOrderGroup, GrPhones
	) as GrOuter2 
	ON GrOuter.EmployeeServiceQueueOrderGroup = GrOuter2.EmployeeServiceQueueOrderGroup
LEFT JOIN	
(SELECT * FROM
	(
		SELECT dbo.fun_GetEmployeeServiceGroup_QueueOrderDescription(deptCode, employeeID, serviceCode) as QueueOrderDescription,
		dbo.fun_GetEmployeeServiceQueueOrderGroup(x_D_E_S.deptCode, x_D_E_S.employeeID, x_D_E_S.serviceCode ) as EmployeeServiceQueueOrderGroup
		FROM x_Dept_Employee_Service x_D_E_S
		WHERE x_D_E_S.deptCode = @DeptCode 
		) as GrInner3
		GROUP BY EmployeeServiceQueueOrderGroup, QueueOrderDescription
	) as GrOuter3 
	ON GrOuter.EmployeeServiceQueueOrderGroup = GrOuter3.EmployeeServiceQueueOrderGroup	
ORDER BY EmployeeSectorCode DESC, lastName, EmployeeServiceQueueOrderGroup

----- deptServices  UNITED (Services in Clinic - "direct" services and services "via employee") ***************************


SELECT
'ToggleID' = x_D_S.serviceCode,
x_D_S.serviceCode,
x_D_S.deptCode,
[Services].serviceDescription,
'phones' = dbo.fun_getDeptServicePhones(@deptCode, x_D_S.serviceCode),
'phonesForQueueOrder' = dbo.fun_getDeptServiceQueueOrderPhones_All(x_D_S.serviceCode, @deptCode),
'ReceptionDaysCount'= 
(SELECT count(receptionDay) 
	FROM DeptServiceReception 
	WHERE deptCode = x_D_S.deptCode
	AND serviceCode = x_D_S.serviceCode
	and (
			(   
				((validFrom IS not NULL and  validTo IS NULL) and (getDate() >= validFrom ))			
				or ((validFrom IS NULL and validTo IS not NULL) and validTo >= getDate())
				or ((validFrom IS not NULL and  validTo IS not NULL) and (getDate() >= validFrom and validTo >= getDate()))
			)
			OR (validFrom IS NULL AND validTo IS NULL)
		)
),
'DeptServiceRemarksCount'=
(SELECT COUNT(DeptServiceRemarkID)
FROM DeptServiceRemarks
WHERE deptCode = x_D_S.deptCode
AND serviceCode = x_D_S.serviceCode
AND (
		(   
			 ((validFrom IS not NULL and  validTo IS NULL) and (getDate() >= validFrom ))			
		  or ((validFrom IS NULL and validTo IS not NULL) and validTo >= getDate())
		  or ((validFrom IS not NULL and  validTo IS not NULL) and (getDate() >= validFrom and validTo >= getDate()))
		
	     )
	  OR (validFrom IS NULL AND validTo IS NULL)
	)
), 
'QueueOrderDescription' = IsNull(DIC_QueueOrder.QueueOrderDescription, '&nbsp;'),					
'PermitOrderMethods' = IsNull(DIC_QueueOrder.PermitOrderMethods, 0),
'officeServices' = IsNuLL(officeServices, 0) ,
'serviceIsGivenByPerson' = 0,
'PersonsName' = '',
[Services].showOrder,
viaPerson = 0,
'employeeID' = 0,
x_d_s.ShowPhonesFromDept,
x_d_s.Status,
1 as StatusOrder

FROM x_dept_service AS x_D_S
INNER JOIN [Services] ON x_D_S.serviceCode = [Services].serviceCode
LEFT JOIN ServiceQueueOrderMethod ON x_D_S.serviceCode = ServiceQueueOrderMethod.serviceCode
	AND x_D_S.deptCode = ServiceQueueOrderMethod.deptCode
	AND ServiceQueueOrderMethod.QueueOrderMethod = 1
LEFT JOIN DIC_QueueOrder ON  x_D_S.QueueOrder = DIC_QueueOrder.QueueOrder
WHERE x_D_S.deptCode = @deptCode 
AND x_d_s.Status = 1 


UNION

SELECT 
'ToggleID' = x_D_S.serviceCode,
x_D_S.serviceCode,
x_D_S.deptCode,
[Services].serviceDescription,
'phones' = dbo.fun_getDeptServicePhones(@deptCode, x_D_S.serviceCode),
'phonesForQueueOrder' = dbo.fun_getDeptServiceQueueOrderPhones_All(x_D_S.serviceCode, @deptCode),
'ReceptionDaysCount'= 
(SELECT count(receptionDay) 
	FROM DeptServiceReception 
	WHERE deptCode = x_D_S.deptCode
	AND serviceCode = x_D_S.serviceCode
	and (
			(   
				((validFrom IS not NULL and  validTo IS NULL) and (getDate() >= validFrom ))			
				or ((validFrom IS NULL and validTo IS not NULL) and validTo >= getDate())
				or ((validFrom IS not NULL and  validTo IS not NULL) and (getDate() >= validFrom and validTo >= getDate()))
			)
			OR (validFrom IS NULL AND validTo IS NULL)
		)
),
'DeptServiceRemarksCount'=
(SELECT COUNT(DeptServiceRemarkID)
FROM DeptServiceRemarks
WHERE deptCode = x_D_S.deptCode
AND serviceCode = x_D_S.serviceCode
AND (
		(   
			 ((validFrom IS not NULL and  validTo IS NULL) and (getDate() >= validFrom ))			
		  or ((validFrom IS NULL and validTo IS not NULL) and validTo >= getDate())
		  or ((validFrom IS not NULL and  validTo IS not NULL) and (getDate() >= validFrom and validTo >= getDate()))
		
	     )
	  OR (validFrom IS NULL AND validTo IS NULL)
	)
), 
'QueueOrderDescription' = IsNull(DIC_QueueOrder.QueueOrderDescription, '&nbsp;'),					
'PermitOrderMethods' = IsNull(DIC_QueueOrder.PermitOrderMethods, 0),
'officeServices' = IsNuLL(officeServices, 0) ,
'serviceIsGivenByPerson' = 0,
'PersonsName' = '',
[Services].showOrder,
viaPerson = 0,
'employeeID' = 0,
x_d_s.ShowPhonesFromDept,
x_D_S.Status,
2 as StatusOrder

FROM x_dept_service AS x_D_S
INNER JOIN	[Services]	ON x_D_S.serviceCode = [Services].serviceCode
LEFT JOIN ServiceQueueOrderMethod ON x_D_S.serviceCode = ServiceQueueOrderMethod.serviceCode
	AND x_D_S.deptCode = ServiceQueueOrderMethod.deptCode
	AND ServiceQueueOrderMethod.QueueOrderMethod = 1
LEFT JOIN DIC_QueueOrder ON  x_D_S.QueueOrder = DIC_QueueOrder.QueueOrder
WHERE x_D_S.deptCode = @deptCode AND x_d_s.Status <> 1


UNION

-------------Services of Doctors in Clinic ***************************
SELECT
'ToggleID' = x_D_E_S.serviceCode + x_dept_employee.employeeID,
x_D_E_S.serviceCode,
x_D_E_S.deptCode,
[Services].serviceDescription,
'phones' = '',
'phonesForQueueOrder' = dbo.fun_getEmployeeQueueOrderPhones_All(x_dept_employee.employeeID, @deptCode),
'ReceptionDaysCount' = 
	(select count(receptionDay)
	FROM deptEmployeeReception
	INNER JOIN deptEmployeeReceptionServices ON deptEmployeeReception.receptionID = deptEmployeeReceptionServices.receptionID
	WHERE deptEmployeeReception.deptCode = @deptCode
	AND deptEmployeeReceptionServices.serviceCode = x_D_E_S.serviceCode
	and deptEmployeeReception.employeeid = x_dept_employee.employeeid
	and disableBecauseOfOverlapping <> 1
	and (
			(   
				((validFrom IS not NULL and  validTo IS NULL) and (getDate() >= validFrom ))			
				or ((validFrom IS NULL and validTo IS not NULL) and validTo >= getDate())
				or ((validFrom IS not NULL and  validTo IS not NULL) and (getDate() >= validFrom and validTo >= getDate()))
		
			)
			OR (validFrom IS NULL AND validTo IS NULL)
		)
	),
'DeptServiceRemarksCount'= 
	(
		SELECT COUNT(*)
		FROM DeptEmployeeServiceRemarks
		WHERE DeptCode = @deptCode
		AND ServiceCode = x_D_E_S.serviceCode
		AND EmployeeID = Employee.employeeID
	),
'QueueOrderDescription' = IsNull(DIC_QueueOrder.QueueOrderDescription, '&nbsp;'),					
'PermitOrderMethods' = IsNull(DIC_QueueOrder.PermitOrderMethods, 0),
'officeServices' = 0,
'serviceIsGivenByPerson' = CASE (Employee.IsMedicalTeam) WHEN 1 THEN 0 ELSE x_dept_employee.employeeID END,
'PersonsName' = DegreeName + ' ' + lastName + ' ' + firstName,
[Services].showOrder,
viaPerson = 1,
'employeeID' = x_dept_employee.employeeID,
'ShowPhonesFromDept' = CascadeUpdateDeptEmployeePhonesFromClinic,
x_D_E_S.Status,
1 as StatusOrder

FROM x_dept_employee
INNER JOIN Employee ON x_dept_employee.employeeID = Employee.employeeID
INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode

INNER JOIN x_Dept_Employee_Service as x_D_E_S ON x_dept_employee.deptCode = x_D_E_S.deptCode
	AND x_dept_employee.employeeID = x_D_E_S.employeeID
INNER JOIN [Services]	ON x_D_E_S.serviceCode = [Services].serviceCode
LEFT JOIN DIC_QueueOrder ON x_dept_employee.QueueOrder = DIC_QueueOrder.QueueOrder

WHERE x_dept_employee.deptCode = @deptCode
AND x_dept_Employee.Active = 1 AND x_d_e_s.Status = 1

UNION

SELECT
'ToggleID' = x_D_E_S.serviceCode + x_dept_employee.employeeID,
x_D_E_S.serviceCode,
x_D_E_S.deptCode,
[Services].serviceDescription,
'phones' = '',
'phonesForQueueOrder' = dbo.fun_getEmployeeQueueOrderPhones_All(x_dept_employee.employeeID, @deptCode),
'ReceptionDaysCount' = 
	(select count(receptionDay)
	FROM deptEmployeeReception
	INNER JOIN deptEmployeeReceptionServices ON deptEmployeeReception.receptionID = deptEmployeeReceptionServices.receptionID
	WHERE deptEmployeeReception.deptCode = @deptCode
	AND deptEmployeeReceptionServices.serviceCode = x_D_E_S.serviceCode
	and deptEmployeeReception.employeeid = x_dept_employee.employeeid
	and disableBecauseOfOverlapping <> 1
	and (
			(   
				((validFrom IS not NULL and  validTo IS NULL) and (getDate() >= validFrom ))			
				or ((validFrom IS NULL and validTo IS not NULL) and validTo >= getDate())
				or ((validFrom IS not NULL and  validTo IS not NULL) and (getDate() >= validFrom and validTo >= getDate()))
		
			)
			OR (validFrom IS NULL AND validTo IS NULL)
		)
	),
'DeptServiceRemarksCount'= 
	(
		SELECT COUNT(*)
		FROM DeptEmployeeServiceRemarks
		WHERE DeptCode = @deptCode
		AND ServiceCode = x_D_E_S.serviceCode
		AND EmployeeID = Employee.employeeID
	),
'QueueOrderDescription' = IsNull(DIC_QueueOrder.QueueOrderDescription, '&nbsp;'),					
'PermitOrderMethods' = IsNull(DIC_QueueOrder.PermitOrderMethods, 0),

'officeServices' = 0,
'serviceIsGivenByPerson' = CASE (Employee.IsMedicalTeam) WHEN 1 THEN 0 ELSE x_dept_employee.employeeID END,
'PersonsName' = DegreeName + ' ' + lastName + ' ' + firstName,
[Services].showOrder,
viaPerson = 1,
'employeeID' = x_dept_employee.employeeID,
'ShowPhonesFromDept' = CascadeUpdateDeptEmployeePhonesFromClinic,
x_D_E_S.Status,
2 as StatusOrder

FROM x_dept_employee
INNER JOIN Employee ON x_dept_employee.employeeID = Employee.employeeID
INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode

INNER JOIN x_Dept_Employee_Service as x_D_E_S ON x_dept_employee.deptCode = x_D_E_S.deptCode
	AND x_dept_employee.employeeID = x_D_E_S.employeeID
INNER JOIN [Services]	ON x_D_E_S.serviceCode = [Services].serviceCode
LEFT JOIN DIC_QueueOrder ON x_dept_employee.QueueOrder = DIC_QueueOrder.QueueOrder

WHERE x_dept_employee.deptCode = @deptCode
AND x_dept_Employee.Active = 1 AND x_d_e_s.Status <> 1


ORDER BY statusOrder, showOrder, serviceDescription

------ serviceReception  (Service Reception Hours)   ***************************
SELECT 
A.receptionID,
A.deptCode,
A.serviceCode,
A.receptionDay,
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

'receptionRemarks' = dbo.fun_GetDeptServiceHoursRemarks(A.receptionID),
[Services].officeServices,
'willExpireIn' = DATEDIFF(day, getdate(), IsNull(validTo,'01/01/2050')),
'expirationDate' = validTo,
'viaPerson' = 0,
'employeeID' = 0

FROM DeptServiceReception A
INNER JOIN vReceptionDaysForDisplay on A.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode
INNER JOIN [Services] ON A.serviceCode = [Services].serviceCode


WHERE A.deptCode = @DeptCode
and (
		(   
			 ((validFrom IS not NULL and  validTo IS NULL) and (getDate() >= validFrom ))			
		  or ((validFrom IS NULL and validTo IS not NULL) and validTo >= getDate())
		  or ((validFrom IS not NULL and  validTo IS not NULL) and (getDate() >= validFrom and validTo >= getDate()))
		
	     )
	  OR (validFrom IS NULL AND validTo IS NULL)
	)
ORDER BY serviceCode,receptionDay, openingHour

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
IsCommunity,
IsMushlam,
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
		AND validFrom <= getdate() 
		AND ( validTo is null OR validTo >= getdate() ) 
		AND (IsSharedRemark = 0 OR dept.IsCommunity = 1) 		 
	),
-- end block julia 
'countReception' = 
	(select count(receptionID) 
	from DeptReception
	where deptCode = dept.deptCode
	AND (validFrom <= getdate() AND (validTo is null OR validTo >= getdate())))

FROM Dept
inner join Cities on Dept.CityCode = Cities.CityCode
inner join UnitType on  Dept.typeUnitCode = UnitType.UnitTypeCode

WHERE Dept.deptCode in
(SELECT deptCode from dept where subAdministrationCode = @DeptCode and status = 1)
ORDER BY Dept.deptName


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

------- serviceQueueOrderMethods (Clinic Service Queue Order Methods) ***************************
SELECT
QueueOrderMethodID,
serviceCode,
ServiceQueueOrderMethod.QueueOrderMethod,
DIC_QueueOrderMethod.QueueOrderMethodDescription,
DIC_QueueOrderMethod.ShowPhonePicture,
--'phones' = dbo.fun_getDeptServiceQueueOrderPhones(QueueOrderMethodID),
'phones' = dbo.fun_getDeptServiceQueueOrderPhones_All(@DeptCode, serviceCode),
'orderHours' = dbo.fun_getDeptServiceQueueOrderHours_HTML(QueueOrderMethodID)--'<tr><td class="RegularLabel">Day</td></tr>'
FROM ServiceQueueOrderMethod
INNER JOIN DIC_QueueOrderMethod 
	ON ServiceQueueOrderMethod.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
WHERE deptCode = @DeptCode
ORDER BY serviceCode, QueueOrderMethod

------- ServiceQueueOrderHours (Hours for Clinic Service Queue Order via Phone) ***************************
SELECT
ServiceQueueOrderMethod.deptCode,
ServiceQueueOrderMethod.serviceCode,
ServiceQueueOrderHours.QueueOrderMethodID,
ServiceQueueOrderHours.receptionDay,
vReceptionDaysForDisplay.ReceptionDayName,
ServiceQueueOrderHours.FromHour,
ServiceQueueOrderHours.ToHour
FROM
ServiceQueueOrderHours
INNER JOIN vReceptionDaysForDisplay
	ON ServiceQueueOrderHours.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode
INNER JOIN ServiceQueueOrderMethod ON ServiceQueueOrderHours.QueueOrderMethodID = ServiceQueueOrderMethod.QueueOrderMethodID
WHERE ServiceQueueOrderMethod.deptCode = @DeptCode  

----- deptEvents (Clinic Events) ***************************
SELECT
DeptEventID,
DIC_Events.EventName,
MeetingsNumber,
EventDescription,
'RepeatingEvent' = CAST(RepeatingEvent as bit),
'RegistrationStatus' = registrationStatusDescription,
'Active' = CASE WHEN (DATEDIFF(dd, FromDate, GetDate()) >= 0 AND DATEDIFF(dd, ToDate, GetDate()) <= 0 )
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
	--AND ( getDate() >= FromDate and ToDate >= getDate())
	)
	
	
------ DeptEmployeeProfessions
SELECT
x_D_E_S.employeeID,
x_D_E_S.ServiceCode as 'professionCode',
[Services].ServiceDescription as professionDescription,
Employee.EmployeeSectorCode as EmployeeSector,
dbo.fun_GetEmployeeServiceQueueOrderGroup(x_D_E_S.deptCode, x_D_E_S.employeeID, x_D_E_S.serviceCode ) as EmployeeServiceQueueOrderGroup

FROM x_Dept_Employee_Service as x_D_E_S
INNER JOIN Employee ON x_D_E_S.EmployeeId = Employee.EmployeeID
INNER JOIN [Services] ON x_D_E_S.ServiceCode = [Services].ServiceCode
WHERE x_D_E_S.deptCode = @DeptCode
AND [Services].IsProfession = 1

ORDER BY employeeID, ServiceDescription



------ DeptEmployeePositions  ***************************
SELECT
x_D_E_Po.employeeID,
x_D_E_Po.positionCode,
position.positionDescription

FROM x_Dept_Employee_Position as x_D_E_Po
INNER JOIN x_Dept_Employee ON x_D_E_Po.deptCode = x_Dept_Employee.deptCode
	AND x_D_E_Po.employeeID = x_Dept_Employee.employeeID
INNER JOIN position ON x_D_E_Po.positionCode = position.positionCode
INNER JOIN employee ON x_Dept_Employee.employeeID = employee.employeeID
WHERE x_D_E_Po.deptCode = @DeptCode
AND ((employee.sex = 0 AND position.gender = 1) OR ( employee.sex <> 0 AND employee.sex = position.gender))

------ DeptEmployeePhones  ***************************

SELECT GrOuter.employeeID, ServPhones.deptCode, GrOuter.EmployeeServiceQueueOrderGroup, 
phoneOrder,
ServPhones.phoneType, 
'phone' = dbo.fun_ParsePhoneNumberWithExtension(ServPhones.prePrefix, ServPhones.prefix, ServPhones.phone, ServPhones.extension),
'shortPhoneTypeName' = CASE ISNULL(ServPhones.phoneType, 0) WHEN 2 THEN 'פקס' WHEN 0 THEN '' ELSE 'טל`' END,
phoneTypeName

FROM
(SELECT * FROM
	(
		SELECT employeeID
		, dbo.fun_GetEmployeeServiceQueueOrderGroup(x_D_E_S.deptCode, x_D_E_S.employeeID, x_D_E_S.serviceCode ) as EmployeeServiceQueueOrderGroup
		FROM x_Dept_Employee_Service x_D_E_S
		WHERE x_D_E_S.deptCode = @DeptCode 
		) as GrInner
		GROUP BY employeeID, EmployeeServiceQueueOrderGroup
	) as GrOuter 
INNER JOIN 
(SELECT ESPh.*, x_D_E_S.deptCode, DIC_PhoneTypes.phoneTypeName, dbo.fun_GetEmployeeServiceQueueOrderGroup(x_D_E_S.deptCode, x_D_E_S.employeeID, x_D_E_S.serviceCode ) as EmployeeServiceQueueOrderGroup
FROM
x_Dept_Employee_Service x_D_E_S
INNER JOIN EmployeeServicePhones ESPh ON x_D_E_S.x_Dept_Employee_ServiceID = ESPh.x_Dept_Employee_ServiceID
LEFT JOIN DIC_PhoneTypes ON ESPh.phoneType = DIC_PhoneTypes.phoneTypeCode
WHERE x_D_E_S.deptCode = @DeptCode) as ServPhones
	ON GrOuter.EmployeeServiceQueueOrderGroup = ServPhones.EmployeeServiceQueueOrderGroup

UNION
	
SELECT GrOuter.employeeID, DeptEmpPhones.deptCode, GrOuter.EmployeeServiceQueueOrderGroup, 
phoneOrder,
DeptEmpPhones.phoneType, 
'phone' = dbo.fun_ParsePhoneNumberWithExtension(DeptEmpPhones.prePrefix, DeptEmpPhones.prefix, DeptEmpPhones.phone, DeptEmpPhones.extension),
'shortPhoneTypeName' = CASE ISNULL(DeptEmpPhones.phoneType, 0) WHEN 2 THEN 'פקס' WHEN 0 THEN '' ELSE 'טל`' END,
phoneTypeName

FROM
(SELECT * FROM
	(
		SELECT employeeID
		, dbo.fun_GetEmployeeServiceQueueOrderGroup(x_D_E_S.deptCode, x_D_E_S.employeeID, x_D_E_S.serviceCode ) as EmployeeServiceQueueOrderGroup
		FROM x_Dept_Employee_Service x_D_E_S
		WHERE x_D_E_S.deptCode = @DeptCode 
		) as GrInner
		GROUP BY employeeID, EmployeeServiceQueueOrderGroup
	) as GrOuter 
INNER JOIN
	(SELECT DEPh.prePrefix, DEPh.prefix, DEPh.phone, DEPh.extension, DEPh.phoneType, DEPh.phoneOrder,
	DIC_PhoneTypes.phoneTypeName, dbo.fun_GetEmployeeServiceQueueOrderGroup(DEPh.deptCode, DEPh.employeeID, 0 ) as EmployeeServiceQueueOrderGroup,
	DEPh.deptCode
	FROM DeptEmployeePhones DEPh
	LEFT JOIN DIC_PhoneTypes ON DEPh.phoneType = DIC_PhoneTypes.phoneTypeCode
	WHERE DEPh.deptCode = @DeptCode
	
	UNION
	
	SELECT DPh.prePrefix, DPh.prefix, DPh.phone, DPh.extension, DPh.phoneType, DPh.phoneOrder, 
	DIC_PhoneTypes.phoneTypeName, dbo.fun_GetEmployeeServiceQueueOrderGroup(x_DE.deptCode, x_DE.employeeID, 0 ) as EmployeeServiceQueueOrderGroup,
	DPh.deptCode
	FROM DeptPhones DPh
	LEFT JOIN DIC_PhoneTypes ON DPh.phoneType = DIC_PhoneTypes.phoneTypeCode
	INNER JOIN x_Dept_Employee x_DE ON DPh.deptCode = x_DE.deptCode
	WHERE DPh.deptCode = @DeptCode
	AND x_DE.CascadeUpdateDeptEmployeePhonesFromClinic = 1
	) as DeptEmpPhones 
		ON GrOuter.EmployeeServiceQueueOrderGroup = DeptEmpPhones.EmployeeServiceQueueOrderGroup

ORDER BY employeeID 

------- "EmployeeQueueOrderMethods" (Employee Queue Order Methods) ***************************
SELECT 
EQOM.QueueOrderMethodID as 'EmployeeServiceQueueOrderMethodID',
EQOM.QueueOrderMethod,
EQOM.deptCode,
EQOM.employeeID,
'serviceCode' = 0,
DIC_QueueOrderMethod.QueueOrderMethodDescription,
DIC_QueueOrderMethod.ShowPhonePicture,
DIC_QueueOrderMethod.SpecialPhoneNumberRequired,
'EmployeeServiceQueueOrderGroup' = dbo.fun_GetEmployeeServiceQueueOrderGroup(EQOM.deptCode, EQOM.employeeID, 0 )

FROM EmployeeQueueOrderMethod EQOM
INNER JOIN DIC_QueueOrderMethod ON EQOM.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
INNER JOIN x_dept_employee x_D_E
	ON x_D_E.employeeID = EQOM.employeeID
	AND x_D_E.deptCode = EQOM.deptCode	
WHERE EQOM.deptCode = @DeptCode

UNION

SELECT 
ESQOM.EmployeeServiceQueueOrderMethodID,
ESQOM.QueueOrderMethod,
ESQOM.deptCode,
ESQOM.employeeID,
ESQOM.serviceCode,
DIC_QueueOrderMethod.QueueOrderMethodDescription,
DIC_QueueOrderMethod.ShowPhonePicture,
DIC_QueueOrderMethod.SpecialPhoneNumberRequired,
'EmployeeServiceQueueOrderGroup' = dbo.fun_GetEmployeeServiceQueueOrderGroup(deptCode, employeeID, serviceCode )

FROM EmployeeServiceQueueOrderMethod ESQOM
INNER JOIN DIC_QueueOrderMethod ON ESQOM.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
WHERE ESQOM.deptCode = @DeptCode

ORDER BY QueueOrderMethod

------- "HoursForEmployeeQueueOrder" (Hours for Employee Queue Order via Phone) ***************************
SELECT
EmployeeQueueOrderMethod.deptCode,
EmployeeQueueOrderMethod.employeeID,
0 as serviceCode,
EmployeeQueueOrderHours.receptionDay,
ReceptionDayName,
FromHour,
ToHour,
vReceptionDaysForDisplay.ReceptionDayCode,
dbo.fun_GetEmployeeServiceQueueOrderGroup(deptCode, employeeID, 0 ) as EmployeeServiceQueueOrderGroup

FROM EmployeeQueueOrderHours
INNER JOIN vReceptionDaysForDisplay ON EmployeeQueueOrderHours.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode
INNER JOIN EmployeeQueueOrderMethod ON EmployeeQueueOrderHours.QueueOrderMethodID = EmployeeQueueOrderMethod.QueueOrderMethodID
WHERE EmployeeQueueOrderMethod.deptCode = @DeptCode

UNION

SELECT 
ESQOM.deptCode,
ESQOM.employeeID,
ESQOM.serviceCode,
ESQOH.ReceptionDay,
ReceptionDayName,
FromHour,
ToHour,
vReceptionDaysForDisplay.ReceptionDayCode,
dbo.fun_GetEmployeeServiceQueueOrderGroup(deptCode, employeeID, serviceCode ) as EmployeeServiceQueueOrderGroup

FROM EmployeeServiceQueueOrderHours ESQOH
INNER JOIN vReceptionDaysForDisplay ON ESQOH.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode
INNER JOIN EmployeeServiceQueueOrderMethod ESQOM ON ESQOH.EmployeeServiceQueueOrderMethodID = ESQOM.EmployeeServiceQueueOrderMethodID
WHERE ESQOM.deptCode = @DeptCode

ORDER BY ReceptionDayCode, FromHour

-- DeptEmployeeServices (Employee's services) ***************************
SELECT 
employeeID, x_D_E_S.serviceCode, serviceDescription,
dbo.fun_GetEmployeeServiceQueueOrderGroup(x_D_E_S.deptCode, x_D_E_S.employeeID, x_D_E_S.serviceCode ) as EmployeeServiceQueueOrderGroup
FROM x_Dept_Employee_Service as x_D_E_S
INNER JOIN [Services] ON x_D_E_S.serviceCode = [Services].serviceCode
WHERE x_D_E_S.deptCode = @DeptCode
AND Status = 1
AND [Services].IsService = 1


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
	WHERE deptEmployeeReception.deptCode = x_dept_employee.deptCode
	and deptEmployeeReception.employeeid = x_dept_employee.employeeid
	and (
			(   
				((validFrom IS not NULL and  validTo IS NULL) and (getDate() >= validFrom ))			
				or ((validFrom IS NULL and validTo IS not NULL) and validTo >= getDate())
				or ((validFrom IS not NULL and  validTo IS not NULL) and (getDate() >= validFrom and validTo >= getDate()))
		
			)
			OR (validFrom IS NULL AND validTo IS NULL)
		)
	),
'phonesForQueueOrder' = dbo.fun_getEmployeeQueueOrderPhones_All(x_dept_employee.employeeID, x_dept_employee.deptCode),
'QueueOrderDescription' = IsNull(DIC_QueueOrder.QueueOrderDescription, '&nbsp;'),					
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
				WHERE desr.DeptCode = dept.DeptCode
				AND desr.EmployeeID = x_dept_employee.EmployeeID
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
x_D_E_S.employeeID,
x_D_E_S.deptCode,
x_D_E_S.ServiceCode,
[Services].ServiceDescription as professionDescription

FROM x_Dept_Employee_Service as x_D_E_S
INNER JOIN [Services] ON x_D_E_S.ServiceCode = [Services].ServiceCode
WHERE x_D_E_S.employeeID IN (SELECT employeeID FROM x_dept_employee WHERE deptCode = @DeptCode)
AND [Services].IsProfession = 1

-- EmployeeServicesAtOtherPlaces  ***************************
SELECT 
deptCode, employeeID, x_D_E_S.serviceCode, serviceDescription
FROM x_Dept_Employee_Service as x_D_E_S
INNER JOIN [Services] ON x_D_E_S.serviceCode = [Services].serviceCode
WHERE x_D_E_S.employeeID IN (SELECT employeeID FROM x_dept_employee WHERE deptCode = @DeptCode)
AND [Services].IsProfession = 0

------ DeptEmployeePhonesAtOtherPlaces ***************************
SELECT deptCode, employeeID, phoneOrder,
'phone' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension),
DeptEmployeePhones.phoneType,
phoneTypeName,
'shortPhoneTypeName' = CASE DeptEmployeePhones.phoneType WHEN 2 THEN 'פקס' ELSE 'טל`' END
FROM DeptEmployeePhones
INNER JOIN DIC_PhoneTypes ON DeptEmployeePhones.phoneType = DIC_PhoneTypes.phoneTypeCode
WHERE employeeID IN (SELECT employeeID FROM DeptEmployeePhones WHERE deptCode = @DeptCode)

UNION

SELECT xd.DeptCode, xd.EmployeeID, dp.PhoneOrder, 
'phone' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension),
phoneType,
phoneTypeName,
'shortPhoneTypeName' = CASE phoneType WHEN 2 THEN 'פקס' ELSE 'טל`' END
FROM x_dept_employee xd
INNER JOIN DeptPhones dp ON xd.DeptCode = dp.DeptCode
INNER JOIN DIC_PhoneTypes ON phoneType = DIC_PhoneTypes.phoneTypeCode
WHERE xd.EmployeeID IN (SELECT employeeID FROM DeptEmployeePhones WHERE deptCode = @DeptCode)
AND CascadeUpdateDeptEmployeePhonesFromClinic = 1



-- DeptPhones   ***************************
SELECT
deptCode, DeptPhones.phoneType, phoneOrder, 'phone' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension),
'ShortPhoneTypeName' = CASE DeptPhones.phoneType WHEN 2 THEN 'פקס' ELSE 'טל`' END
FROM DeptPhones
WHERE deptCode = @DeptCode
ORDER BY DeptPhones.phoneType, phoneOrder

-- DeptServicePhones  ***************************
SELECT 
deptCode,
ServiceCode,
DeptServicePhones.phoneType,
phoneOrder,
'phone' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension),
'shortPhoneTypeName' = CASE DeptServicePhones.phoneType WHEN 2 THEN 'פקס' ELSE 'טל`' END

FROM DeptServicePhones
INNER JOIN DIC_PhoneTypes ON DeptServicePhones.phoneType = DIC_PhoneTypes.phoneTypeCode
WHERE DeptCode = @DeptCode


-- ReceptionDaysUnited for ClinicReception and OfficeServicesReception  ***************************
-- it's useful to build synchronised GridView for both receptions
SELECT DeptServiceReception.receptionDay, ReceptionDayName
FROM DeptServiceReception
INNER JOIN [Services] ON DeptServiceReception.serviceCode = [Services].serviceCode
INNER JOIN vReceptionDaysForDisplay ON DeptServiceReception.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode
WHERE officeServices = 1
AND DeptServiceReception.deptCode = @DeptCode
AND (
		(   
			 ((validFrom IS not NULL and  validTo IS NULL) and (getDate() >= validFrom ))			
		  or ((validFrom IS NULL and validTo IS not NULL) and validTo >= getDate())
		  or ((validFrom IS not NULL and  validTo IS not NULL) and (getDate() >= validFrom and validTo >= getDate()))
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
				((validFrom IS not NULL and  validTo IS NULL) and (getDate() >= validFrom ))			
				or ((validFrom IS NULL and validTo IS not NULL) and validTo >= getDate())
				or ((validFrom IS not NULL and  validTo IS not NULL) and (getDate() >= validFrom and validTo >= getDate()))
			)
			OR (validFrom IS NULL AND validTo IS NULL)
		)

UNION 
-- the purpose of the 3-rd UNION is to have always 5 days (from א to ה) at least (no matter if they will be empty) ***************************
SELECT TOP 5
ReceptionDayCode as receptionDay, ReceptionDayName
FROM vReceptionDaysForDisplay

ORDER BY receptionDay



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


GO


GRANT EXEC ON rpc_DeptOverView TO PUBLIC
GO

--********************* END Update rpc_DeptOverView ******************************

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptEventsAndServicesList_Paged')
	BEGIN
		DROP  Procedure  rpc_getDeptEventsAndServicesList_Paged
		PRINT 'DROP  Procedure  rpc_getDeptEventsAndServicesList_Paged'
	END

GO

CREATE Procedure [dbo].[rpc_getDeptEventsAndServicesList_Paged]
	(
	@ServiceAndEventName varchar(max)=null,
	@ServiceAndEventCodes varchar(max)=null,
	@DistrictCode varchar(max)=null,
	@CityCode int=null,
	@typeUnitCode varchar(max)=null,
	@subUnitTypeCode varchar(5) = null,
	@DeptName varchar(max)=null,
	@status INT,
	@isCommunity BIT, 
	@isMushlam BIT, 
	@isHospital BIT, 
	@ReceptionDays varchar(max)=null,
	@OpenAtHour varchar(5)=null,
	@OpenFromHour varchar(5)=null,
	@OpenToHour varchar(5)=null,
	@deptHandicappedFacilities varchar(max)=null,
	
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

-- @StartingPage enumeration starts from 1. Here we start from  0
SET @StartingPage = @StartingPage - 1

DECLARE @StartingPosition int
SET @StartingPosition = (@StartingPage * @PageSise)

DECLARE @HandicappedFacilitiesCount int
SET @HandicappedFacilitiesCount = IsNull((SELECT COUNT(IntField) FROM dbo.SplitString(@deptHandicappedFacilities)), 0)

DECLARE @SortedByDefault varchar(50)
SET @SortedByDefault = 'deptLevel'

IF(@SortedBy is null OR @SortedBy = '')
	BEGIN SET @SortedBy = @SortedByDefault END
	
DECLARE @Count int

IF (@CoordinateX = -1)
BEGIN
	SET @CoordinateX = null
	SET @CoordinateY = null
END

IF(@MaxNumberOfRecords <> -1)
	BEGIN
	IF(@MaxNumberOfRecords < @PageSise)
		BEGIN
			SET @PageSise = @MaxNumberOfRecords
		END
	END
	
DECLARE @OpenAtHour_real real
DECLARE @OpenFromHour_real real
DECLARE @OpenToHour_real real

SET @OpenFromHour_real = CAST (LEFT(IsNull(@OpenFromHour,'00:00'),2) as real) + CAST (RIGHT(IsNull(@OpenFromHour,'00:00'),2) as real)/60
SET @OpenToHour_real = CAST (LEFT(IsNull(@OpenToHour, '24:00'),2) as real) + CAST (RIGHT(IsNull(@OpenToHour, '24:00'),2) as real)/60 
IF (@OpenAtHour is not null)
BEGIN
	SET @OpenAtHour_real = CAST (LEFT(@OpenAtHour,2) as real) + CAST (RIGHT(@OpenAtHour,2) as real)/60 
END


--SELECT TOP (@PageSise) * INTO #tempTable FROM
SELECT  * INTO #tempTableAllRows 
/*********** middle selection ***********/
FROM
(
SELECT *,
'RowNumber' = CASE @SortedBy 
			WHEN 'deptName' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY DeptName  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY DeptName   )
				END
			WHEN 'GivenBy' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY GivenBy  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY GivenBy   )
				END
			WHEN 'phone' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY phones  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY phones   )
				END
			WHEN 'cityName' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY cityName  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY cityName   )
				END
			WHEN 'independent' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY SubUnitTypeCode  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY SubUnitTypeCode   )
				END
			WHEN 'distance' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY distance  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY distance, deptCode )
				END
			ELSE
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY ServiceOrEventName  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY ServiceOrEventName   )
				END
			END	
/*********** inner selection ***********/
FROM
(
/*********** EVENTS ***********/
SELECT
dept.deptCode,
'IsService' = 0, -- it's not service - it's event
'ViaPerson' = 0, -- event is never defined via person
'ServiceOrEventName' = DIC_Events.EventName,
'ServiceOrEventCode' = DeptEvent.DeptEventID,
'DeptOrEmployeeCode' = dept.deptCode,
'GivenBy' = 'צוות המרפאה',
MeetingsNumber,
Remark,
null as QueueOrderDescription,
dept.deptName,
'ClinicCode' = dept.deptCode,
@status as Status,
dept.cityCode,
Cities.cityName,
'address' = dbo.GetAddress(dept.deptCode),
'phones' = dbo.fun_GetDeptEventPhones(DeptEvent.DeptEventID, 1), -- "1" - is phoneType
'ShowHoursPicture' = 1, -- in case of events it means we have DeptEventParticulars (meetings) to show
'distance' = (xcoord - @CoordinateX)*(xcoord - @CoordinateX) + (ycoord - @CoordinateY)*(ycoord - @CoordinateY),
'hasMapCoordinates' = CASE IsNull((xcoord + ycoord),0) WHEN 0 THEN 0 ELSE 1 END,
'subUnitTypeCode' = CASE IsNull(dept.subUnitTypeCode, -1)
						WHEN -1 THEN UnitType.DefaultSubUnitTypeCode
						ELSE dept.subUnitTypeCode END,
SubUnitTypeSubstituteName.SubstituteName,
isCommunity,
isMushlam,
isHospital,
dbo.x_dept_XY.xcoord,
dbo.x_dept_XY.ycoord	
FROM DeptEvent
INNER JOIN dept ON DeptEvent.deptCode = dept.deptCode
INNER JOIN DIC_DeptTypes on Dept.deptType = DIC_DeptTypes.deptType
INNER JOIN UnitType on dept.typeUnitCode = UnitType.UnitTypeCode
INNER JOIN Cities on dept.cityCode = Cities.cityCode
INNER JOIN DIC_Events ON DeptEvent.EventCode = DIC_Events.EventCode
LEFT JOIN x_dept_XY ON dept.deptCode = x_dept_XY.deptCode
LEFT JOIN SubUnitTypeSubstituteName ON dept.typeUnitCode = SubUnitTypeSubstituteName.UnitTypeCode
						AND (IsNull(dept.subUnitTypeCode, 0) + UnitType.DefaultSubUnitTypeCode) = SubUnitTypeSubstituteName.SubUnitTypeCode

WHERE 

(@DistrictCode is null or dept.districtCode in (Select IntField from dbo.SplitString(@DistrictCode)))
AND (@ServiceAndEventName is null or DIC_Events.EventName like '%'+ @ServiceAndEventName +'%' 
		OR DIC_Events.EventCode IN (SELECT IntField FROM dbo.SplitString(@ServiceAndEventCodes)) )
AND (@CityCode is null OR @CoordinateX is NOT null 
	OR (dept.CityCode = @CityCode
		OR (
			(@typeUnitCode is NOT null OR @ServiceAndEventName is NOT null)
			AND 
			(dept.deptLevel = 1 OR (dept.deptLevel = 2 AND dept.districtCode IN (SELECT districtCode FROM Cities WHERE cityCode = @CityCode)))
			)
		)
	)
AND DIC_Events.IsActive = 1	
AND (@typeUnitCode is null or typeUnitCode in (Select IntField from  dbo.SplitString(@typeUnitCode)) )
AND (@subUnitTypeCode is null OR dept.subUnitTypeCode = @subUnitTypeCode)
AND (@DeptName is null or dept.DeptName like @DeptName+'%')
AND	((@OpenAtHour is null AND @OpenFromHour is null AND @OpenToHour is null)
		OR	
		DeptEvent.DeptEventID IN
		(SELECT DeptEventID FROM DeptEventParticulars as T 
			WHERE 
				T.DeptEventID = DeptEvent.DeptEventID
			AND (
					(Cast(Left(T.openingHour,2) as real) + Cast(Right(T.openingHour,2) as real)/60) < @OpenToHour_real 
						AND
					(Cast(Left(T.closingHour,2) as real) + Cast(Right(T.closingHour,2) as real)/60) > @OpenFromHour_real
				)
			AND
				( @OpenAtHour is null OR 
					(
					(Cast(Left(T.openingHour,2) as real) + Cast(Right(T.openingHour,2) as real)/60) < @OpenAtHour_real 
						AND
					(Cast(Left(T.closingHour,2) as real) + Cast(Right(T.closingHour,2) as real)/60) > @OpenAtHour_real
					)
				)
			AND
				(@ReceptionDays is null OR T.Day IN (SELECT IntField FROM dbo.SplitString(@ReceptionDays)))
		)
	)
AND
	(@deptHandicappedFacilities is null
	OR
	dept.deptCode IN (SELECT deptCode FROM dept as New
						WHERE (SELECT COUNT(deptCode) FROM DeptHandicappedFacilities as T
								WHERE FacilityCode IN (SELECT IntField FROM dbo.SplitString(@deptHandicappedFacilities))
								AND T.deptCode = New.deptCode) = @HandicappedFacilitiesCount )
	)
AND( @CoordinateX is null OR (xcoord is NOT null AND ycoord is NOT null))
AND ( (DeptEvent.FromDate <= getdate() AND DeptEvent.ToDate >= getdate() AND @status = 1)
	  OR
	  (DeptEvent.FromDate > getdate() OR DeptEvent.ToDate < getdate() AND @status = 0)
	)
AND (Dept.Status != 0)
AND ( (@isCommunity IS NULL AND @isMushlam IS NULL AND @isHospital IS NULL)
		OR (@isCommunity IS NOT NULL AND IsCommunity = @isCommunity)
		OR (@isMushlam IS NOT NULL AND IsMushlam = @isMushlam)
		OR (@isHospital IS NOT NULL AND IsHospital = @isHospital)
	)
	
UNION

/*********** SERVICES ***********/

/* services via employee */
--=======================================================
SELECT
dept.deptCode,
'IsService' = 1, -- it's really service - it's not event
CASE Employee.IsMedicalTeam WHEN 1 THEN 0 ELSE 1 END as 'ViaPerson', 
'ServiceOrEventName' = [Services].serviceDescription,
'ServiceOrEventCode' = x_D_E_S.serviceCode,
'DeptOrEmployeeCode' = x_dept_employee.employeeID,
'GivenBy' = DegreeName + ' ' + lastName + ' ' + firstName,
0 as 'MeetingsNumber',
desr.RemarkText,
QueueOrderDescription,
dept.deptName,
'ClinicCode' = dept.deptCode,
'Status' = CASE (x_dept_employee.active * Employee.active * dept.Status ) 
				WHEN 0 THEN 0
				WHEN 1 THEN 1
				ELSE 2
		    END,
dept.cityCode,
Cities.cityName,
'address' = dbo.GetAddress(dept.deptCode),
'phones' = dbo.fun_GetDeptEmployeePhonesOnly(x_dept_employee.employeeID, dept.deptCode),
'ShowHoursPicture'= CASE
	(select count(receptionDay)
	FROM deptEmployeeReception
	INNER JOIN deptEmployeeReceptionServices ON deptEmployeeReception.receptionID = deptEmployeeReceptionServices.receptionID
	WHERE deptEmployeeReception.deptCode = x_D_E_S.deptCode
	AND deptEmployeeReceptionServices.serviceCode = x_D_E_S.serviceCode
	and deptEmployeeReception.employeeid = x_dept_employee.employeeid
	and disableBecauseOfOverlapping <> 1
	and (
			(   
				((validFrom IS not NULL and  validTo IS NULL) and (getDate() >= validFrom ))			
				or ((validFrom IS NULL and validTo IS not NULL) and validTo >= getDate())
				or ((validFrom IS not NULL and  validTo IS not NULL) and (getDate() >= validFrom and validTo >= getDate()))
			)
			OR (validFrom IS NULL AND validTo IS NULL)
		)
	) WHEN 0 THEN 0 ELSE 1 END,
'distance' = (xcoord - @CoordinateX)*(xcoord - @CoordinateX) + (ycoord - @CoordinateY)*(ycoord - @CoordinateY),
'hasMapCoordinates' = CASE IsNull((xcoord + ycoord),0) WHEN 0 THEN 0 ELSE 1 END,
'SubUnitTypeCode' = CASE IsNull(dept.subUnitTypeCode, -1)
						WHEN -1 THEN UnitType.DefaultSubUnitTypeCode
						ELSE dept.subUnitTypeCode END,
SubUnitTypeSubstituteName.SubstituteName,
IsCommunity,
IsMushlam,			
IsHospital,		  
dbo.x_dept_XY.xcoord,
dbo.x_dept_XY.ycoord	

FROM x_dept_employee
INNER JOIN Employee ON x_dept_employee.employeeID = Employee.employeeID
INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode
INNER JOIN x_Dept_Employee_Service as x_D_E_S ON x_dept_employee.deptCode = x_D_E_S.deptCode
	AND x_dept_employee.employeeID = x_D_E_S.employeeID
INNER JOIN [Services] ON x_D_E_S.serviceCode = [Services].serviceCode
INNER JOIN dept ON x_dept_employee.deptCode = dept.deptCode
INNER JOIN UnitType on dept.typeUnitCode = UnitType.UnitTypeCode
INNER JOIN Cities on dept.cityCode = Cities.cityCode
LEFT JOIN DeptEmployeeServiceRemarks desr ON [Services].serviceCode = desr.serviceCode AND x_dept_employee.deptCode = desr.deptCode
	AND x_dept_employee.employeeID = desr.employeeID
LEFT JOIN DIC_QueueOrder dic ON x_dept_employee.QueueOrder = dic.QueueOrder AND PermitOrderMethods = 0
LEFT JOIN x_dept_XY ON dept.deptCode = x_dept_XY.deptCode
LEFT JOIN SubUnitTypeSubstituteName ON dept.typeUnitCode = SubUnitTypeSubstituteName.UnitTypeCode
						AND (IsNull(dept.subUnitTypeCode, 0) + UnitType.DefaultSubUnitTypeCode) = SubUnitTypeSubstituteName.SubUnitTypeCode

WHERE (@DistrictCode is null or dept.districtCode in (Select IntField from dbo.SplitString(@DistrictCode)))

-- unated Services concept changes
AND (@ServiceAndEventName is null or [Services].serviceDescription like '%'+ @ServiceAndEventName +'%'
			OR [Services].serviceCode IN (SELECT IntField FROM dbo.SplitString(@ServiceAndEventCodes)) )
AND (@CityCode is null OR @CoordinateX is NOT null or dept.CityCode = @CityCode)
AND (@CityCode is null OR @CoordinateX is NOT null 
	OR (dept.CityCode = @CityCode
		OR (
			-- unated Services concept changes
			(@typeUnitCode is NOT null OR @ServiceAndEventName is NOT null)
			AND 
			(
			dept.deptLevel = 1 
			OR (dept.deptLevel = 2 AND dept.districtCode IN (SELECT districtCode FROM Cities WHERE cityCode = @CityCode)))
			)
		)
	)
AND (@status = -1 or (@status = 2 and Dept.Status * Employee.active * x_dept_employee.active >= @status) 
			      or (Dept.Status * Employee.active * x_dept_employee.active = @status))
AND (@typeUnitCode is null or typeUnitCode in (Select IntField from  dbo.SplitString(@typeUnitCode)) )
AND (@subUnitTypeCode is null OR dept.subUnitTypeCode = @subUnitTypeCode)
AND (@DeptName is null or dept.DeptName like @DeptName+'%')
AND	
( (@OpenFromHour is null AND @OpenToHour is null AND @OpenAtHour is null)
	OR
	(SELECT count(*) FROM deptEmployeeReception as T
		WHERE T.deptCode = x_D_E_S.deptCode
		AND T.employeeID = x_D_E_S.employeeID
		AND ( 
				(Cast(Left(T.openingHour,2) as real) + Cast(Right(T.openingHour,2) as real)/60) < @OpenToHour_real 
					AND
				(Cast(Left(T.closingHour,2) as real) + Cast(Right(T.closingHour,2) as real)/60) > @OpenFromHour_real
			 )
		AND
			( @OpenAtHour is null OR 
				(
				(Cast(Left(T.openingHour,2) as real) + Cast(Right(T.openingHour,2) as real)/60) < @OpenAtHour_real 
					AND
				(Cast(Left(T.closingHour,2) as real) + Cast(Right(T.closingHour,2) as real)/60) > @OpenAtHour_real
				)
			)
		AND 
			(@ReceptionDays is null OR T.receptionDay IN (SELECT IntField FROM dbo.SplitString(@ReceptionDays)))
			
		AND receptionID in (Select receptionID from deptEmployeeReceptionServices 
							WHERE receptionID = T.receptionID
							AND serviceCode = x_D_E_S.serviceCode)
	) > 0
)
	
AND( @CoordinateX is null OR (xcoord is NOT null AND ycoord is NOT null))
AND ( (@isCommunity IS NULL AND @isMushlam IS NULL AND @isHospital IS NULL)
	   OR (@isCommunity IS NOT NULL AND (Employee.IsInCommunity = @isCommunity AND Dept.IsCommunity = @isCommunity AND [Services].IsInCommunity = @isCommunity)) 
	   OR (@isMushlam IS NOT NULL AND (Employee.IsInMushlam = @isMushlam AND Dept.IsMushlam = @isMushlam AND [Services].IsInMushlam = @isMushlam)) 
	   OR (@isHospital IS NOT NULL AND (Employee.IsInHospitals = @isHospital AND Dept.IsHospital = @isHospital AND [Services].IsInHospitals = @isHospital))
	)

---- end of services ---------------

) as innerSelection
) as middleSelection


--=======================================================

SELECT TOP (@PageSise) * INTO #tempTable FROM #tempTableAllRows
WHERE RowNumber > @StartingPosition
	AND RowNumber <= @StartingPosition + @PageSise
ORDER BY RowNumber


SELECT * From #tempTable



-- queue order methods and hours
--=======================================================
SELECT #tempTable.DeptCode, #tempTable.ServiceOrEventCode, sqom.QueueOrderMethod,
sqoh.receptionDay,
ReceptionDayName,
FromHour,
ToHour
FROM #tempTable 
INNER JOIN ServiceQueueOrderMethod sqom ON #tempTable.DeptCode = sqom.DeptCode AND #tempTable.ServiceOrEventCode = sqom.ServiceCode
LEFT JOIN ServiceQueueOrderHours sqoh ON sqoh.QueueOrderMethodID = sqom.QueueOrderMethodID
LEFT JOIN DIC_ReceptionDays ON sqoh.receptionDay = DIC_ReceptionDays.ReceptionDayCode
WHERE #tempTable.ViaPerson = 0

UNION

SELECT #tempTable.DeptCode, #tempTable.ServiceOrEventCode, eqom.QueueOrderMethod,
receptionDay,
ReceptionDayName,
FromHour,
ToHour
FROM #tempTable 
INNER JOIN EmployeeQueueOrderMethod eqom ON #tempTable.DeptCode = eqom.DeptCode AND #tempTable.DeptOrEmployeeCode = eqom.EmployeeID
LEFT JOIN EmployeeQueueOrderHours eqoh ON eqoh.QueueOrderMethodID = eqom.QueueOrderMethodID
LEFT JOIN DIC_ReceptionDays ON eqoh.receptionDay = DIC_ReceptionDays.ReceptionDayCode
WHERE #tempTable.ViaPerson = 1
ORDER BY DIC_ReceptionDays.ReceptionDayName, FromHour


-- queue order dept phones
--=======================================================
SELECT #tempTable.DeptCode, #tempTable.ServiceOrEventCode, 
				dbo.fun_ParsePhoneNumberWithExtension(DeptPhones.prePrefix, DeptPhones.prefix, DeptPhones.phone, DeptPhones.extension) as Phone
FROM #tempTable  
INNER JOIN ServiceQueueOrderMethod sqom ON #tempTable.deptCode = sqom.deptCode AND #tempTable.ServiceOrEventCode = sqom.ServiceCode
INNER JOIN DIC_QueueOrderMethod ON sqom.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
INNER JOIN DeptPhones ON sqom.deptCode = DeptPhones.deptCode
WHERE DeptPhones.deptCode IN (SELECT DeptCode FROM #tempTable) 
AND phoneType = 1 AND phoneOrder = 1 AND SpecialPhoneNumberRequired = 0 AND ShowPhonePicture = 1

UNION 

SELECT #tempTable.DeptCode, #tempTable.ServiceOrEventCode, 
				dbo.fun_ParsePhoneNumberWithExtension(DeptPhones.prePrefix, DeptPhones.prefix, DeptPhones.phone, DeptPhones.extension) as Phone
FROM #tempTable  
INNER JOIN EmployeeQueueOrderMethod eqom ON #tempTable.deptCode = eqom.deptCode AND #tempTable.DeptOrEmployeeCode = eqom.EmployeeID
INNER JOIN DIC_QueueOrderMethod ON eqom.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
INNER JOIN DeptPhones ON eqom.deptCode = DeptPhones.deptCode
WHERE DeptPhones.deptCode IN (SELECT DeptCode FROM #tempTable) 
AND phoneType = 1 AND phoneOrder = 1 AND SpecialPhoneNumberRequired = 0 AND ShowPhonePicture = 1





-- queue order special phones
--=======================================================
SELECT #tempTable.DeptCode, #tempTable.ServiceOrEventCode, 
			dbo.fun_ParsePhoneNumberWithExtension(sqop.prePrefix, sqop.prefix, sqop.phone, sqop.extension) as Phone
FROM #tempTable
INNER JOIN ServiceQueueOrderMethod sqom ON #tempTable.deptCode = sqom.deptCode AND #tempTable.ServiceOrEventCode = sqom.ServiceCode
INNER JOIN DeptServiceQueueOrderPhones sqop ON sqom.QueueOrderMethodID = sqop.QueueOrderMethodID
INNER JOIN DIC_QueueOrderMethod ON DIC_QueueOrderMethod.QueueOrderMethod = sqom.QueueOrderMethod
WHERE SpecialPhoneNumberRequired = 1

UNION

SELECT #tempTable.DeptCode, #tempTable.ServiceOrEventCode, 
			dbo.fun_ParsePhoneNumberWithExtension(eqop.prePrefix, eqop.prefix, eqop.phone, eqop.extension) as Phone
FROM #tempTable
INNER JOIN EmployeeQueueOrderMethod eqom ON #tempTable.deptCode = eqom.deptCode AND #tempTable.DeptOrEmployeeCode = eqom.EmployeeID
INNER JOIN DeptEmployeeQueueOrderPhones eqop ON eqom.QueueOrderMethodID = eqop.QueueOrderMethodID
INNER JOIN DIC_QueueOrderMethod ON DIC_QueueOrderMethod.QueueOrderMethod = eqom.QueueOrderMethod
WHERE SpecialPhoneNumberRequired = 1


DROP TABLE #tempTable

	
-- select with same joins and conditions as above
-- just to get count of all the records in select
SET @Count =	
		(SELECT COUNT(*)
		FROM #tempTableAllRows)

DROP TABLE #tempTableAllRows

IF(@MaxNumberOfRecords is NOT null)
BEGIN
	IF(@Count > @MaxNumberOfRecords)
	BEGIN
		SET @Count = @MaxNumberOfRecords
	END
END
	
SELECT @Count
	
	
GO



GRANT EXEC ON rpc_getDeptEventsAndServicesList_Paged TO PUBLIC

GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptList_PagedSorted')
	BEGIN
		DROP  Procedure  rpc_getDeptList_PagedSorted
		PRINT 'DROP  Procedure  rpc_getDeptList_PagedSorted'
	END

GO

CREATE Procedure [dbo].[rpc_getDeptList_PagedSorted]
	(
	@DistrictCodes varchar(max)=null,
	@CityCode int=null,
	@CityName varchar(max)=null,
	@typeUnitCode varchar(max)=null,
	@subUnitTypeCode varchar(max) = null,
	@ServiceCodes varchar(max) = null,
	@DeptName varchar(max)=null,
	@DeptCode int=null,
	@ServiceCode int=null,
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
-- @StartingPage enumeration starts from 1. Here we start from  0
SET @StartingPage = @StartingPage - 1

DECLARE @StartingPosition int
SET @StartingPosition = (@StartingPage * @PageSise)

DECLARE @HandicappedFacilitiesCount int
SET @HandicappedFacilitiesCount = IsNull((SELECT COUNT(IntField) FROM dbo.SplitString(@deptHandicappedFacilities)), 0)

DECLARE @SortedByDefault varchar(50)
SET @SortedByDefault = 'deptLevel'

DECLARE @Count int

IF(@SortedBy = '' OR @SortedBy IS NULL)
	BEGIN SET @SortedBy = @SortedByDefault END
	
IF @CityCode <> null
BEGIN
	SET @CityName = null
END

IF (@CoordinateX = -1)
BEGIN
	SET @CoordinateX = null
	SET @CoordinateY = null
END

IF(@MaxNumberOfRecords <> -1)
	BEGIN
	IF(@MaxNumberOfRecords < @PageSise)
		BEGIN
			SET @PageSise = @MaxNumberOfRecords
		END
	END

DECLARE @OpenAtHour_real real
DECLARE @OpenFromHour_real real
DECLARE @OpenToHour_real real

IF @OpenFromHour IS NOT NULL
	SET @OpenFromHour_real = CAST (LEFT(@OpenFromHour,2) as real) + CAST (RIGHT(@OpenFromHour,2) as real)/60
	
IF @OpenToHour IS NOT NULL
	SET @OpenToHour_real = CAST (LEFT(@OpenToHour,2) as real) + CAST (RIGHT(@OpenToHour,2) as real)/60 

IF (@OpenAtHour is not null)
	SET @OpenAtHour_real = CAST (LEFT(@OpenAtHour,2) as real) + CAST (RIGHT(@OpenAtHour,2) as real)/60 



SELECT  * INTO #tempTableAllRows FROM
-- middle selection - "dept itself" + RowNumber
(SELECT *,
'RowNumber' = CASE @SortedBy 
			WHEN 'deptName' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY deptName  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY deptName   )
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
			WHEN 'subUnitTypeCode' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY subUnitTypeCode  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY subUnitTypeCode   )
				END
			WHEN 'distance' THEN
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY distance  DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY distance, deptCode  )
				END
			ELSE
				CASE @IsOrderDescending 
				WHEN 1 THEN ROW_NUMBER() OVER(ORDER BY deptLevel, IsNull(DisplayPriority,99) , orderDeptNameLike, deptName   DESC )
				WHEN 0 THEN ROW_NUMBER() OVER(ORDER BY deptLevel, IsNull(DisplayPriority,99), orderDeptNameLike, deptName   )
				END
			END	
FROM
-- inner selection - "dept itself"
(
SELECT
dept.deptCode,
dept.deptName,
dept.deptType,
dept.deptLevel,
dept.displayPriority,
dept.ShowUnitInInternet,
DIC_DeptTypes.deptTypeDescription,
DIC_QueueOrder.QueueOrderDescription,
dept.typeUnitCode,
'subUnitTypeCode' = CASE IsNull(dept.subUnitTypeCode, -1) 
					WHEN -1 THEN UnitType.DefaultSubUnitTypeCode
					ELSE dept.subUnitTypeCode END,
SubUnitTypeSubstituteName.SubstituteName,
IsCommunity,
IsMushlam,
UnitType.UnitTypeName,
dept.cityCode,
Cities.cityName,
dept.streetName as street,
dept.house,
dept.flat,
dept.addressComment,
'address' = dbo.GetAddress(dept.deptCode),
dbo.GetDeptPhoneNumber(dept.deptCode, 1, 1) as 'phone',
'countDeptRemarks' = 
	(SELECT COUNT(*) 
	from View_DeptRemarks
	WHERE deptCode = dept.deptCode
	AND DATEDIFF(dd,GETDATE(),ValidFrom) <= 0 
	AND ( validTo is null OR DATEDIFF(dd,GETDATE(),ValidTo) >= 0 )
	AND (IsSharedRemark = 0 OR dept.IsCommunity = 1) 
	),
'countReception' = 
	(select count(receptionID) 
	from DeptReception
	where deptCode = dept.deptCode
	AND (validFrom <= getdate() AND (validTo is null OR validTo >= getdate()))),
Simul228,
'distance' = (xcoord - @CoordinateX)*(xcoord - @CoordinateX) + (ycoord - @CoordinateY)*(ycoord - @CoordinateY),
dept.status,
'orderDeptNameLike' =
	CASE --WHEN @DeptName is null THEN 0 
		 WHEN @DeptName is NOT null AND dept.DeptName like @deptName + '%' THEN 0
		 WHEN @DeptName is NOT null AND dept.DeptName like '%' + @deptName + '%' THEN 1
		 ELSE 0 END, 
dbo.x_dept_XY.xcoord,
dbo.x_dept_XY.ycoord

FROM dept
INNER JOIN DIC_DeptTypes on Dept.deptType = DIC_DeptTypes.deptType
INNER JOIN UnitType on dept.typeUnitCode = UnitType.UnitTypeCode
INNER JOIN Cities on dept.cityCode = Cities.cityCode
LEFT JOIN DIC_QueueOrder on dept.queueOrder = DIC_QueueOrder.QueueOrder AND PermitOrderMethods = 0
LEFT JOIN DeptSimul on dept.deptCode = deptSimul.deptCode
LEFT JOIN x_dept_XY ON dept.deptCode = x_dept_XY.deptCode
LEFT JOIN SubUnitTypeSubstituteName ON dept.typeUnitCode = SubUnitTypeSubstituteName.UnitTypeCode
						AND (IsNull(dept.subUnitTypeCode, 0) + UnitType.DefaultSubUnitTypeCode) = SubUnitTypeSubstituteName.SubUnitTypeCode

WHERE 

(@DistrictCodes is null OR dept.districtCode IN (SELECT IntField FROM dbo.SplitString(@DistrictCodes)) OR deptLevel = 1)
AND (@CityCode is null OR @CoordinateX is NOT null
	OR (dept.CityCode = @CityCode
		OR (
			(@typeUnitCode is NOT null OR @ServiceCodes is NOT null)
			AND 
			(dept.deptLevel = 1 OR (dept.deptLevel = 2 AND dept.districtCode IN (SELECT districtCode FROM Cities WHERE cityCode = @CityCode)))
			)
		)
	)
AND (@CityName is null OR @CoordinateX is NOT null or Cities.CityName like @CityName+'%')
AND (@typeUnitCode is null or typeUnitCode in (Select IntField from  dbo.SplitString(@typeUnitCode)) )
AND (@subUnitTypeCode is null OR dept.subUnitTypeCode in (Select IntField from  dbo.SplitString(@subUnitTypeCode)))
AND (@DeptName is null 
     or dept.DeptName like '%' + @DeptName + '%' 
	 or dept.DeptName like @deptName + '%'
	 or dept.DeptName = @DeptName 	 
	)
AND (@DeptCode is null or (dept.deptCode = @DeptCode OR deptSimul.Simul228 = @DeptCode))
AND (
		@ServiceCode is null 
		OR
		( 
			dept.deptCode IN (SELECT deptCode FROM x_dept_service WHERE serviceCode = @ServiceCode)
		)

	)
and (@ReceptionDays is null 
	OR
	-- logical OR for "@ReceptionDays"
	dept.deptCode IN (SELECT deptCode 
					  FROM DeptReception 
					  WHERE receptionDay IN (SELECT IntField FROM dbo.SplitString(@ReceptionDays)) 
					 )
					
	)
	
AND (
		(@OpenAtHour is null AND @OpenFromHour is null AND @OpenToHour is null)
		OR
		(dept.deptCode IN 
			(SELECT deptCode FROM DeptReception as T 
				WHERE 
					T.deptCode = dept.deptCode
				AND (  (@OpenToHour IS NULL AND @OpenFromHour IS NULL )
					   OR
						(
							(Cast(Left(T.openingHour,2) as real) + Cast(Right(T.openingHour,2) as real)/60) <= @OpenFromHour_real 
							AND 
							(Cast(Left(T.closingHour,2) as real) + Cast(Right(T.closingHour,2) as real)/60) >= @OpenToHour_real 
						)
					   OR (T.openingHour = '00:00' AND T.closingHour = '00:00')
					   OR
					   (
						(Cast(Left(T.closingHour,2) as real) + Cast(Right(T.closingHour,2) as real)/60) >= @OpenToHour_real 
						AND
						(Cast(Left(T.closingHour,2) as real) + Cast(Right(T.closingHour,2) as real)/60) < 
																(Cast(Left(T.openingHour,2) as real) + Cast(Right(T.openingHour,2) as real)/60) 
					   )						   
					)
					-- at hour section
				AND (	
					  @OpenAtHour is null 
					  
					  OR -- regular reception hours
		  				(
							(Cast(Left(T.openingHour,2) as real) + Cast(Right(T.openingHour,2) as real)/60) <= @OpenAtHour_real 
							AND
							(Cast(Left(T.closingHour,2) as real) + Cast(Right(T.closingHour,2) as real)/60) > @OpenAtHour_real 
						)	
					  OR -- close at midnight
						(
							(Cast(Left(T.openingHour,2) as real) + Cast(Right(T.openingHour,2) as real)/60) <= @OpenAtHour_real 
							AND
							T.closingHour = '00:00' 
						)						  	
					  OR -- 24 hours
					   (
							T.openingHour = '00:00'
							AND
							T.closingHour = '00:00'
					   )
					  OR -- starts before midnight and close after midnight
					   (
						   (Cast(Left(T.closingHour,2) as real) + Cast(Right(T.closingHour,2) as real)/60) > @OpenAtHour_real 
							AND
						   (Cast(Left(T.closingHour,2) as real) + Cast(Right(T.closingHour,2) as real)/60) < 
																	(Cast(Left(T.openingHour,2) as real) + Cast(Right(T.openingHour,2) as real)/60) 
					   )					  
					)
				AND
					(@ReceptionDays is null OR T.receptionDay IN (SELECT IntField FROM dbo.SplitString(@ReceptionDays)))
				
			)
		)
	)
AND
	(@deptHandicappedFacilities is null
	OR
	dept.deptCode IN (SELECT deptCode FROM dept as New
								WHERE (SELECT COUNT(deptCode) FROM DeptHandicappedFacilities as T
										WHERE FacilityCode IN (SELECT IntField FROM dbo.SplitString(@deptHandicappedFacilities))
										AND T.deptCode = New.deptCode) = @HandicappedFacilitiesCount )
	)
AND ( @isCommunity = isCommunity OR @isMushlam = isMushlam OR @isHospital = isHospital 
		OR (@isCommunity IS NULL AND @isMushlam IS NULL AND @isHospital IS NULL) 
	)
AND (@status is null 
	OR (@status = 0 AND (dept.status = 0))
	OR (@status = 1 AND (dept.status = 1 OR dept.status = 2 ))
	OR (@status = 2 AND (dept.status = 2 ))
)
AND (@populationSectorCode is null or dept.populationSectorCode = @populationSectorCode)

-- ServiceNew  = service + Profession
AND (@ServiceCodes is null OR
	(
	(SELECT count(serviceCode) 
	FROM x_dept_service
	WHERE deptCode = dept.deptCode
		AND serviceCode IN (SELECT IntField FROM dbo.SplitString(@ServiceCodes)) )
	+(SELECT count(serviceCode) 
	FROM x_Dept_Employee_Service
	WHERE deptCode = dept.deptCode
		AND serviceCode IN (SELECT IntField FROM dbo.SplitString(@ServiceCodes)) )
	) > 0)

AND( @CoordinateX is null OR (xcoord is NOT null AND ycoord is NOT null))

) as innerDeptSelection
) as middleSelection


SELECT TOP (@PageSise) * 
FROM #tempTableAllRows
WHERE RowNumber > @StartingPosition
	AND RowNumber <= @StartingPosition + @PageSise
ORDER BY RowNumber



-- select with same joins and conditions as above
-- just to get count of all the records in select

SET @Count =	
		(SELECT COUNT(*)
		FROM #tempTableAllRows)

DROP TABLE #tempTableAllRows
		
	
IF(@MaxNumberOfRecords is NOT null)
BEGIN
	IF(@Count > @MaxNumberOfRecords)
	BEGIN
		SET @Count = @MaxNumberOfRecords
	END
END
	
SELECT @Count

GO


GRANT EXEC ON dbo.rpc_getDeptList_PagedSorted TO PUBLIC

GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeeProfessions')
	BEGIN
		DROP  Procedure  rpc_getEmployeeProfessions
		PRINT 'DROP  Procedure  rpc_getEmployeeProfessions'
	END

GO

CREATE Procedure dbo.rpc_getEmployeeProfessions
( 
	@EmployeeID bigint
)

AS

SELECT
EmployeeServices.EmployeeID,
EmployeeServices.ServiceCode as 'professionCode',
[Services].ServiceDescription as professionDescription,
EmployeeServices.mainProfession,
'expProfession' = CASE IsNull(EmployeeServices.expProfession, 0) WHEN 0 THEN NULL ELSE 1 END,
'parentCode' = 0,
'groupCode' = ServiceCategories.ServiceCategoryID,
'groupName' = ServiceCategories.ServiceCategoryDescription

FROM EmployeeServices
INNER JOIN [Services] ON EmployeeServices.ServiceCode = [Services].ServiceCode
INNER JOIN x_ServiceCategories_Services ON [Services].ServiceCode = x_ServiceCategories_Services.ServiceCode
INNER JOIN ServiceCategories ON x_ServiceCategories_Services.ServiceCategoryID = ServiceCategories.ServiceCategoryID
WHERE EmployeeID = @EmployeeID
AND [Services].IsProfession = 1

ORDER BY groupName, parentCode

GO

GRANT EXEC ON rpc_getEmployeeProfessions TO PUBLIC
GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetEmployeeServicePhones')
	BEGIN
		DROP  Procedure  rpc_GetEmployeeServicePhones
		PRINT 'DROP  Procedure  rpc_GetEmployeeServicePhones'
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
			FROM x_Dept_Employee
			INNER JOIN x_Dept_Employee_Service 
				ON x_Dept_Employee.deptCode = x_Dept_Employee_Service.deptCode
				AND x_Dept_Employee.employeeID = x_Dept_Employee_Service.employeeID
			WHERE x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID

			IF @GetCascade = 0
				BEGIN
					SELECT DeptEmployeePhones.phoneType, phoneOrder, prePrefix, prefix as 'prefixCode', prefixValue as 'prefixText', phone, extension,
						1 as 'GetCascade'
					FROM DeptEmployeePhones
					INNER JOIN DIC_PhoneTypes phoneTypes ON DeptEmployeePhones.phoneType = phoneTypes.phoneTypeCode
					INNER JOIN DIC_PhonePrefix dic ON DeptEmployeePhones.prefix = dic.prefixCode
					INNER JOIN x_Dept_Employee_Service 
						ON DeptEmployeePhones.deptCode = x_Dept_Employee_Service.deptCode
						AND DeptEmployeePhones.EmployeeID = x_Dept_Employee_Service.EmployeeID
					WHERE x_Dept_Employee_Service.x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID
					AND DeptEmployeePhones.phoneType <> 2
					ORDER BY DeptEmployeePhones.phoneType, phoneOrder
				END
			ELSE
				BEGIN
					SELECT DeptPhones.phoneType, phoneOrder, prePrefix, prefix as 'prefixCode', prefixValue as 'prefixText', phone, extension,
																													  1 as 'GetCascade'
					FROM DeptPhones
					INNER JOIN DIC_PhonePrefix dic ON DeptPhones.prefix = dic.prefixCode
					INNER JOIN x_Dept_Employee_Service 
						ON DeptPhones.deptCode = x_Dept_Employee_Service.deptCode
					WHERE x_Dept_Employee_Service.x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID
					AND DeptPhones.phoneType <> 2
								
				END	
		END
		
		SELECT CASE ISNULL(@SimulateCascadeUpdate, 0) 
			WHEN 0 THEN ISNULL(CascadeUpdateEmployeeServicePhones, 0) ELSE ISNULL(@SimulateCascadeUpdate, 0) END as CascadeUpdateEmployeeServicePhones
		FROM x_Dept_Employee_Service
		WHERE x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID

GO


GRANT EXEC ON dbo.rpc_GetEmployeeServicePhones TO PUBLIC
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetEmployeeServiceQueueOrderDescription')
	BEGIN
		DROP  Procedure  rpc_GetEmployeeServiceQueueOrderDescription
		PRINT 'DROP  Procedure  rpc_GetEmployeeServiceQueueOrderDescription'
	END

GO

CREATE Procedure dbo.rpc_GetEmployeeServiceQueueOrderDescription
(
	@x_Dept_Employee_ServiceID int
)


AS


SELECT 
xDES.deptCode,
xDES.EmployeeID,
xDES.serviceCode,
qo.QueueOrder,
qo.QueueOrderDescription,
0 as QueueOrderMethod
 
FROM x_Dept_Employee_Service xDES
INNER JOIN Dic_QueueOrder qo ON xDES.QueueOrder = qo.QueueOrder

WHERE xDES.x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID
AND permitorderMethods = 0 


UNION 

SELECT 
xDES.deptCode,
xDES.EmployeeID,
xDES.serviceCode,
qo.QueueOrder,
CASE WHEN dbo.fun_ParsePhoneNumberWithExtension(deptPhones.prePrefix,deptPhones.prefix,deptPhones.phone,deptPhones.extension) = '' THEN 
			CASE WHEN dbo.fun_ParsePhoneNumberWithExtension(queuePhones.prePrefix,queuePhones.prefix,queuePhones.phone,queuePhones.extension) = '' 
					THEN qom.QueueOrderMethodDescription 
				 ELSE dbo.fun_ParsePhoneNumberWithExtension(queuePhones.prePrefix,queuePhones.prefix,queuePhones.phone,queuePhones.extension) 
			END
	  ELSE dbo.fun_ParsePhoneNumberWithExtension(deptPhones.prePrefix,deptPhones.prefix,deptPhones.phone,deptPhones.extension) END as QueueOrderMethodDescription,
ESQOM.QueueOrderMethod
 
FROM x_Dept_Employee_Service xDES
LEFT JOIN EmployeeServiceQueueOrderMethod ESQOM 
	ON xDES.EmployeeID  = ESQOM.EmployeeID 
	AND xDES.DeptCode = ESQOM.DeptCode
	AND xDES.serviceCode = ESQOM.serviceCode
LEFT JOIN DeptPhones ON deptPhones.DeptCode = ESQOM.deptCode AND PhoneType = 1 AND PhoneOrder = 1 AND QueueOrderMethod = 1
LEFT JOIN EmployeeServiceQueueOrderPhones queuePhones ON ESQOM.EmployeeServiceQueueOrderMethodID = queuePhones.EmployeeServiceQueueOrderMethodID
INNER JOIN Dic_QueueOrder qo ON xDES.QueueOrder = qo.QueueOrder
LEFT JOIN DIC_QueueOrderMethod qom ON ESQOM.QueueOrderMethod = qom.QueueOrderMethod
WHERE xDES.x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID
AND permitOrderMethods = 1 



GO


GRANT EXEC ON rpc_GetEmployeeServiceQueueOrderDescription TO PUBLIC

GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeeServices')
	BEGIN
		DROP  Procedure  rpc_getEmployeeServices
		PRINT 'DROP  Procedure  rpc_getEmployeeServices'
	END

GO

CREATE Procedure dbo.rpc_getEmployeeServices
	(
		@EmployeeID bigint
	)

AS

SELECT DISTINCT
--EmployeeServices.EmployeeID,
EmployeeServices.serviceCode,
[Services].ServiceDescription
--'parentCode' = 0,
--'groupCode' = ServiceCategories.ServiceCategoryID,
--'groupName' = ServiceCategories.ServiceCategoryDescription

FROM EmployeeServices
INNER JOIN [Services] ON EmployeeServices.serviceCode = [Services].ServiceCode
LEFT JOIN x_ServiceCategories_Services ON [Services].ServiceCode = x_ServiceCategories_Services.ServiceCode
LEFT JOIN ServiceCategories ON x_ServiceCategories_Services.ServiceCategoryID = ServiceCategories.ServiceCategoryID
WHERE EmployeeID = @EmployeeID
AND [Services].IsService = 1

GO

GRANT EXEC ON rpc_getEmployeeServices TO PUBLIC

GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeeServicesExtended')
	BEGIN
		DROP  Procedure  rpc_getEmployeeServicesExtended
		PRINT 'DROP  Procedure  rpc_getEmployeeServicesExtended'
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
	ON (xSerEmSec.EmployeeSectorCode is null 
		or xSerEmSec.EmployeeSectorCode = Employee.EmployeeSectorCode)
	 AND Employee.EmployeeID = @employeeID
	 AND (@IsService is null OR Ser.IsService = @IsService)

left JOIN EmployeeServices EmpSer
	ON Ser.ServiceCode = EmpSer.serviceCode 
	AND EmpSer.EmployeeID = @employeeID

left JOIN x_Dept_Employee_Service DeEmpSer
	ON DeEmpSer.EmployeeID = @employeeID 
	AND DeEmpSer.serviceCode = Ser.ServiceCode
	and (@deptCode is null 
		or @deptCode <= 0
		or DeEmpSer.deptCode = @deptCode)

left JOIN  x_ServiceCategories_Services as SerCatSer
	ON 	SerCatSer.ServiceCode = Ser.ServiceCode
	
left join ServiceCategories SerCat 
	on  SerCat.ServiceCategoryID = SerCatSer.ServiceCategoryID

left join x_Dept_Employee as DepEmp 
	ON DepEmp.EmployeeID = @employeeID 
	and (DepEmp.deptCode = @deptCode)
	
where (@IsLinkedToEmployeeOnly = 0 or EmpSer.serviceCode is not null)
	and(DepEmp.AgreementType is null
		or DepEmp.AgreementType in (1,2) and Ser.IsInCommunity = 1
		or DepEmp.AgreementType in (3,4) and Ser.IsInMushlam = 1
		or DepEmp.AgreementType in (5,6) and Ser.IsInHospitals = 1)
	AND (@RelevantForProfession = 1 OR Ser.IsProfession = 0)
--- end from block

union

------------- Professions table
SELECT 
Ser.ServiceCode
,Ser.ServiceDescription
,ISNULL(SerCatSer.ServiceCategoryID, -1) AS 'ServiceCategoryID'
,CASE IsNull(EmpSer.serviceCode,0) WHEN 0 THEN 0 ELSE 1 END as 'LinkedToEmployee' 
,CASE IsNull(DeEmpSer.serviceCode, 0) WHEN 0 THEN 0 ELSE 1 END as 'LinkedToEmployeeInDept'
,'HasReceptionInDept' = 
(case
(
select COUNT(*) 
from deptEmployeeReception DeEmpRec 
inner JOIN deptEmployeeReceptionServices derp 
	ON DeEmpRec.ReceptionID = derp.ReceptionID 
	AND derp.serviceCode = Ser.ServiceCode
	and DeEmpRec.DeptCode = DeEmpSer.DeptCode 
	AND DeEmpRec.EmployeeID = DeEmpSer.EmployeeID
	and (DeEmpRec.ValidTo IS NULL 
		OR DATEDIFF(dd, DeEmpRec.ValidTo, GETDATE()) <= 0)
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
inner JOIN Employee 
	ON (xSerEmSec.EmployeeSectorCode is null 
		or xSerEmSec.EmployeeSectorCode = Employee.EmployeeSectorCode)
	 AND Employee.EmployeeID = @employeeID
	 AND (@IsService is null OR Ser.IsService = @IsService)

left JOIN EmployeeServices EmpSer
	ON Ser.ServiceCode = EmpSer.serviceCode 
	AND EmpSer.EmployeeID = @employeeID

left JOIN x_Dept_Employee_Service DeEmpSer
	ON DeEmpSer.EmployeeID = @employeeID 
	AND DeEmpSer.serviceCode = Ser.ServiceCode
	and (@deptCode is null 
		or @deptCode <= 0
		or DeEmpSer.deptCode = @deptCode)

left JOIN  x_ServiceCategories_Services as SerCatSer
	ON 	SerCatSer.ServiceCode = Ser.ServiceCode
	
left join ServiceCategories SerCat 
	on  SerCat.ServiceCategoryID = SerCatSer.ServiceCategoryID

left join x_Dept_Employee as DepEmp 
	ON DepEmp.EmployeeID = @employeeID 
	and (DepEmp.deptCode = @deptCode)
	
where (@IsLinkedToEmployeeOnly = 0 or EmpSer.serviceCode is not null)
	and(DepEmp.AgreementType is null
		or DepEmp.AgreementType in (1,2) and Ser.IsInCommunity = 1
		or DepEmp.AgreementType in (3,4) and Ser.IsInMushlam = 1
		or DepEmp.AgreementType in (5,6) and Ser.IsInHospitals = 1)
	AND (@RelevantForProfession = 1 OR Ser.IsProfession = 0)
----- "Professions-From" block end
) as temp     -- end union


ORDER BY CategoryDescrForSort, ServiceCategoryID, ServiceDescription
GO


GRANT EXEC ON rpc_getEmployeeServicesExtended TO PUBLIC

GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetOfficeService')
	BEGIN
		DROP  Procedure  rpc_GetOfficeService
		PRINT 'DROP  Procedure  rpc_GetOfficeService'
	END
GO

CREATE PROCEDURE [dbo].[rpc_GetOfficeService]

AS
	SELECT ServiceCode, ServiceDescription 
	FROM [Services]
	WHERE officeServices = 1
GO

GRANT EXEC ON rpc_GetOfficeService TO PUBLIC
GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetServiceCategoriesExtended')
    BEGIN
	    DROP  Procedure  rpc_GetServiceCategoriesExtended
		PRINT 'DROP  Procedure  rpc_GetServiceCategoriesExtended'
    END
GO

CREATE Procedure dbo.rpc_GetServiceCategoriesExtended
(
	@serviceCode INT,
	@selectedValues VARCHAR(50)
)

AS


IF @selectedValues = '' 
	SET @selectedValues = null


SELECT DISTINCT sc.*, '' as 'IsProfession', CASE WHEN @selectedValues IS NULL THEN (CASE xsc.ServiceCode WHEN @serviceCode THEN 1 ELSE 0 END)
						                                ELSE CASE ISNULL(sel.IntField,0) WHEN 0 THEN 0 ELSE 1 END END as selected
FROM ServiceCategories sc
LEFT JOIN x_ServiceCategories_Services xsc ON sc.ServiceCategoryID = xsc.ServiceCategoryID 
			AND (xsc.ServiceCode = @serviceCode OR @serviceCode IS NULL)
LEFT JOIN (SELECT IntField FROM dbo.SplitString(@selectedValues)) as sel 
	ON sc.ServiceCategoryID = sel.IntField
ORDER BY Selected DESC, sc.ServiceCategoryDescription
                
GO


GRANT EXEC ON rpc_GetServiceCategoriesExtended TO PUBLIC
GO            



------ new concept   Services = Services + Proffesions

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetServicesNewAndEventsBySector')
	BEGIN
		DROP  Procedure  rpc_GetServicesNewAndEventsBySector
		PRINT 'DROP  Procedure  rpc_GetServicesNewAndEventsBySector'
	END

GO

CREATE Procedure dbo.rpc_GetServicesNewAndEventsBySector
(
	@selectedServices VARCHAR(max),
	@sectorCode INT,
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
,IsProfession
from

-- ServiceCategory table
( -- begin union
SELECT 
ISNULL(SeCa_Se.ServiceCategoryID, -1) as ServiceCode   --'ServiceCategoryID'
,ISNULL(SeCa.ServiceCategoryDescription, 'שירותים שונים') as ServiceDescription ---'ServiceCategoryDescription'
,null as ServiceCategoryID
,0 as selected
,ISNULL(SeCa_Se.ServiceCategoryID, -1)as CategoryIDForSort
,ISNULL(SeCa.ServiceCategoryDescription, 'תתתא') AS CategoryDescrForSort
,null as 'AgreementType'
, 0 as IsProfession -- 0 as it not relevant for category

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
,ISNULL(SeCa.ServiceCategoryDescription, 'תתתא') AS 'CategoryDescrForSort'
,case when (s.IsInMushlam = 1
			and isnull(s.IsInCommunity, 0) = 0 
			and isnull(s.IsInHospitals, 0) = 0) 
	then 3 else null end as 'AgreementType'
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
		and(@IsInCommunity = 1 and s.IsInCommunity = 1
			or @IsInMushlam = 1 and  s.IsInMushlam = 1
			or @IsInHospitals = 1 and s.IsInHospitals = 1)

union
--------- Events ---------------------------------

SELECT
Eventcode as ServiceCode
,EventName as ServiceDescription
,-2 AS 'ServiceCategoryID'
, CASE IsNull(sel.IntField, 0) WHEN 0 THEN 0 ELSE 1 END as 'selected'
,-2 AS 'CategoryIDForSort'
,'תתתת' AS 'CategoryDescrForSort'
,null as 'AgreementType'
,'' as 'IsProfession'

FROM DIC_Events e
LEFT JOIN (SELECT IntField FROM dbo.SplitString(@selectedServices)) as sel ON e.EventCode = sel.IntField


union
--------- Events category  ---------------------------------

SELECT
-2 as ServiceCode
,'פעילות' as ServiceDescription
,null AS 'ServiceCategoryID'
,0 as 'selected'
,-2 AS 'CategoryIDForSort'
,'תתתת' AS 'CategoryDescrForSort'
,null as 'AgreementType'
,'' as 'IsProfession'

) as t     -- end union


ORDER BY CategoryDescrForSort, ServiceCategoryID, ServiceDescription


GO


GRANT EXEC ON rpc_GetServicesNewAndEventsBySector TO PUBLIC

GO



------ new concept   Services = Services + Proffesions

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetServicesNewBySector')
	BEGIN
		DROP  Procedure  rpc_GetServicesNewBySector
		PRINT 'DROP  Procedure  rpc_GetServicesNewBySector'
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
,s.IsProfession

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


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertEmployeeServicePhones')
	BEGIN
		DROP  Procedure  rpc_InsertEmployeeServicePhones
		PRINT 'DROP  Procedure  rpc_InsertEmployeeServicePhones'
	END
GO

CREATE PROCEDURE [dbo].[rpc_InsertEmployeeServicePhones]
	@x_Dept_Employee_ServiceID int, 
	@phoneType int,
	@phoneOrder int,
	@prePrefix tinyint,
	@prefix int,
	@phone int,
	@extension int,
	@updateUser varchar(50)
AS

	INSERT INTO EmployeeServicePhones
	(x_Dept_Employee_ServiceID, phoneType, phoneOrder, prePrefix, prefix, phone, extension, updateUser)
	VALUES
	(@x_Dept_Employee_ServiceID, @phoneType, @phoneOrder, @prePrefix, @prefix, @phone, @extension, @updateUser)
GO

GRANT EXEC ON dbo.rpc_InsertEmployeeServicePhones TO PUBLIC
GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertEmployeeServiceQueueOrderHours')
	BEGIN
		DROP  Procedure  rpc_InsertEmployeeServiceQueueOrderHours
		PRINT 'DROP  Procedure  rpc_InsertEmployeeServiceQueueOrderHours'
	END
GO

CREATE PROCEDURE [dbo].[rpc_InsertEmployeeServiceQueueOrderHours]
	(
		@EmployeeServiceQueueOrderMethodID int,
		@ReceptionDay int,
		@FromHour varchar(5),
		@ToHour varchar(5),
		@updateUser varchar(50),
		@ErrCode int = 0 OUTPUT
	)

AS



	INSERT INTO EmployeeServiceQueueOrderHours
	(EmployeeServiceQueueOrderMethodID, ReceptionDay, FromHour, ToHour, updateUser)
	VALUES
	(@EmployeeServiceQueueOrderMethodID, @ReceptionDay, @FromHour, @ToHour, @updateUser)

	SET @ErrCode = @@ERROR


GO


GRANT EXEC ON rpc_InsertEmployeeServiceQueueOrderHours TO PUBLIC
GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertEmployeeServiceQueueOrderMethod')
	BEGIN
		DROP  Procedure  rpc_InsertEmployeeServiceQueueOrderMethod
		PRINT 'DROP  Procedure  rpc_InsertEmployeeServiceQueueOrderMethod'
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
		(QueueOrderMethod, deptCode, serviceCode, employeeID, updateUser)
		SELECT
		@QueueOrderMethod, deptCode, serviceCode, employeeID, @updateUser
		FROM x_Dept_Employee_Service xDES
		WHERE xDES.x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID
				
		SET @ErrCode = @@ERROR
		SET @newID = @@IDENTITY
		
GO


GRANT EXEC ON rpc_InsertEmployeeServiceQueueOrderMethod TO PUBLIC
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertEmployeeServiceQueueOrderPhone')
	BEGIN
		DROP  Procedure  rpc_InsertEmployeeServiceQueueOrderPhone
		PRINT 'DROP  Procedure  rpc_InsertEmployeeServiceQueueOrderPhone'
	END
GO

CREATE PROCEDURE [dbo].[rpc_InsertEmployeeServiceQueueOrderPhone]
	(
		@EmployeeServiceQueueOrderMethodID int,
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
					WHERE EmployeeServiceQueueOrderMethodID = @EmployeeServiceQueueOrderMethodID)
SET @PhoneOrder = IsNull(@PhoneOrder, 1)

	INSERT INTO EmployeeServiceQueueOrderPhones
	(
		EmployeeServiceQueueOrderMethodID,
		phoneType,
		phoneOrder,
		prePrefix,
		prefix,
		phone,
		extension,
		updateUser	
	)
	VALUES
	(
		@EmployeeServiceQueueOrderMethodID,
		1,
		@PhoneOrder,
		@prePrefix,
		@prefix,
		@phone,
		@extension,
		@updateUser
	)
	
	SET @ErrCode = @@Error


GO


GRANT EXEC ON rpc_InsertEmployeeServiceQueueOrderPhone TO PUBLIC
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_Update_x_Dept_Employee_Service_CascadeUpdatePhones')
	BEGIN
		DROP  Procedure  rpc_Update_x_Dept_Employee_Service_CascadeUpdatePhones
		PRINT 'DROP  Procedure  rpc_Update_x_Dept_Employee_Service_CascadeUpdatePhones'
	END
GO

CREATE Procedure dbo.rpc_Update_x_Dept_Employee_Service_CascadeUpdatePhones
	(
		@x_Dept_Employee_ServiceID int,
		@CascadeUpdatePhones bit
	)

AS

	UPDATE x_Dept_Employee_Service
	SET CascadeUpdateEmployeeServicePhones = @CascadeUpdatePhones
	WHERE x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID


	
GO

GRANT EXEC ON rpc_Update_x_Dept_Employee_Service_CascadeUpdatePhones TO PUBLIC

GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateEmployeeInDeptStatusWhenNoProfessions')
	BEGIN
		DROP  Procedure  rpc_UpdateEmployeeInDeptStatusWhenNoProfessions
		PRINT 'DROP  Procedure  rpc_UpdateEmployeeInDeptStatusWhenNoProfessions'
	END

GO

CREATE Procedure [dbo].[rpc_UpdateEmployeeInDeptStatusWhenNoProfessions]
(		
	@employeeID BIGINT,
	@deptCode INT,
	@updateUser VARCHAR(50)
)

AS

IF (SELECT COUNT(*) FROM x_Dept_Employee_Service
		JOIN [Services] ON x_Dept_Employee_Service.serviceCode = [Services].serviceCode
		WHERE deptCode = @deptCode AND employeeID = @employeeID
		AND [Services].IsProfession = 1	) = 0
	AND 
	(SELECT COUNT(*) 
	FROM Employee 
	JOIN EmployeeSector ON Employee.EmployeeSectorCode = EmployeeSector.EmployeeSectorCode
	WHERE employeeID = @employeeID
	AND EmployeeSector.RelevantForProfession = 1
	AND Employee.IsMedicalTeam = 0
	) > 0

BEGIN
	DECLARE @CurrentDate datetime SET @CurrentDate = GETDATE()
	DECLARE @MaxNONfutureStatusID bigint
	
	SET @MaxNONfutureStatusID = (SELECT MAX(StatusID) 
								FROM EmployeeStatusInDept 
								WHERE DeptCode = @deptCode 
								AND EmployeeID = @employeeID
								AND FromDate <=  @CurrentDate)
		
	UPDATE EmployeeStatusInDept
	SET Status = 0
	WHERE DeptCode = @deptCode 
	AND EmployeeID = @employeeID
	AND (FromDate >= @CurrentDate
		OR
		(FromDate <= @CurrentDate AND StatusID = @MaxNONfutureStatusID)	)
			
	UPDATE x_Dept_Employee 
	SET Active = 0, updateDate = @CurrentDate,  UpdateUserName = @updateUser
	WHERE DeptCode = @deptCode 
	AND EmployeeID = @employeeID

	DELETE FROM deptEmployeeReception
	WHERE deptCode = @deptCode AND EmployeeID = @employeeID
	
	DELETE FROM x_Dept_Employee_Position
	WHERE EmployeeID  = @employeeID 
	AND deptCode = @deptCode

END
GO


GRANT EXEC ON rpc_UpdateEmployeeInDeptStatusWhenNoProfessions TO PUBLIC
GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateEmployeeServiceQueueOrder')
	BEGIN
		DROP  Procedure  rpc_UpdateEmployeeServiceQueueOrder
		PRINT 'DROP  Procedure  rpc_UpdateEmployeeServiceQueueOrder'
	END
GO

CREATE PROCEDURE [dbo].[rpc_UpdateEmployeeServiceQueueOrder]
	@x_Dept_Employee_ServiceID INT,
	@queueOrder INT
AS

UPDATE x_Dept_Employee_Service
SET QueueOrder = @queueOrder
WHERE x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID
GO


GRANT EXEC ON rpc_UpdateEmployeeServiceQueueOrder TO PUBLIC
GO




----------- 22/11/2011 julia -------------------------
IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rfn_TimeInterval')
	BEGIN
		DROP  function  dbo.rfn_TimeInterval
	END

GO

Create function [dbo].[rfn_TimeInterval](@openingHour_str varchar(5), @closingHour_str varchar(5))
  
RETURNS int
	
WITH EXECUTE AS CALLER
AS

BEGIN
	declare @interval_str as varchar(5)
	declare  @minutes as int
    declare  @interval as time(0)
    declare  @openingHour as time(0)
    declare  @closingHour as time(0)
    
	if ((@closingHour_str = '00:00' or @closingHour_str = '23:59' or @closingHour_str = '01:00' ) 
		and(@openingHour_str = '00:01' or @openingHour_str = '01:00' or @openingHour_str = '00:00'))
		begin
			set @minutes = 24*60 
		end
	else
		begin
			if(isdate(@openingHour_str) = 1)
				set @openingHour = cast(@openingHour_str as time(0))
			else
				set  @openingHour = cast('00:00' as time(0))
			
			if(isdate(@closingHour_str) = 1)
				set @closingHour = cast(@closingHour_str as time(0))
			else
				set  @closingHour = cast('00:00' as time(0))
			
			set @minutes =	DATEDIFF(minute, @openingHour, @closingHour) 
			
			if(@minutes < 0)
			begin
				set @minutes = @minutes + 24*60;
			end
			
		end
	return	(@minutes)	 
END
GO


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
	FROM x_Dept_Employee_Service
	WHERE EmployeeID = @employeeID 
	AND DeptCode = @deptCode
)
	SELECT 0
ELSE
	SELECT 1


GO

GRANT EXEC ON rpc_checkIfDeptEmployeeQueueOrderEnabled TO PUBLIC

GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteEmployeeProfession')
	BEGIN
		DROP  Procedure  rpc_deleteEmployeeProfession
	END

GO

CREATE Procedure dbo.rpc_deleteEmployeeProfession
	(
		@EmployeeID int,
		@ServiceCode int = null
	)

AS

DELETE FROM EmployeeServices
WHERE EmployeeID = @EmployeeID 
AND serviceCode = IsNull(@ServiceCode, serviceCode)
AND serviceCode IN (SELECT serviceCode FROM [Services] WHERE IsProfession = 1)

UPDATE Employee
SET updateDate = GETDATE()
WHERE employeeID = @EmployeeID
GO


GRANT EXEC ON rpc_deleteEmployeeProfession TO PUBLIC

GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeeProfessionsInDept')
	BEGIN
		DROP  Procedure  rpc_getEmployeeProfessionsInDept
	END
GO

CREATE Procedure dbo.rpc_getEmployeeProfessionsInDept
(
	@EmployeeID int,
	@DeptCode int
)

AS

SELECT 
x_D_E_Sr.deptCode,
x_D_E_Sr.employeeID, 
x_D_E_Sr.serviceCode as professionCode,
[Services].ServiceDescription as professionDescription,
mainProfession,
'expProfession' = CASE expProfession WHEN 1 THEN '(מומחה)' ELSE '' END
FROM x_Dept_Employee_Service as x_D_E_Sr
INNER JOIN EmployeeServices ON x_D_E_Sr.employeeID = EmployeeServices.employeeID
	AND x_D_E_Sr.serviceCode = EmployeeServices.serviceCode
INNER JOIN [Services] ON x_D_E_Sr.serviceCode = [Services].ServiceCode
WHERE x_D_E_Sr.deptCode = @DeptCode
AND x_D_E_Sr.employeeID = @EmployeeID
AND [Services].IsService = 0
ORDER BY professionDescription

SELECT [Services].ServiceCode as ProfessionCode, 
[Services].ServiceDescription as ProfessionDescription
FROM x_Dept_Employee_Service x_D_E_Sr
INNER JOIN EmployeeServices es ON x_D_E_Sr.EmployeeID = es.employeeID AND x_D_E_Sr.serviceCode = es.serviceCode 
INNER JOIN [Services] on es.serviceCode = [Services].ServiceCode
WHERE x_D_E_Sr.EmployeeID = @EmployeeID
AND x_D_E_Sr.DeptCode = @DeptCode
AND [Services].IsService = 0
AND es.ExpProfession = 1

GO


GRANT EXEC ON rpc_getEmployeeProfessionsInDept TO PUBLIC

GO




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
SELECT distinct de.EmployeeID, null receptionID, dept.deptCode, dept.deptName ,cities.cityCode ,cities.cityName , 
				null as receptionDay, null as openingHour, null as closingHour, null as validFrom, null as validTo,
				CASE s.IsProfession WHEN 0 THEN 'service' ELSE 'profession'  END as ItemType, 
				xd.serviceCode as ItemID, s.ServiceDescription as ItemDesc, null as RemarkID, null RemarkText, null as EnableOverMidnightHours
FROM x_Dept_Employee de 
INNER JOIN x_Dept_Employee_service xd ON de.Employeeid = xd.Employeeid AND de.deptCode = xd.deptCode
INNER JOIN [Services] s ON xd.serviceCode = s.ServiceCode
LEFT JOIN  dbo.Dept ON de.deptCode = dbo.Dept.deptCode 
INNER JOIN dbo.Cities ON dbo.Dept.cityCode = dbo.Cities.cityCode
WHERE de.Employeeid = @employeeID AND IsNULL(@deptCode,de.DeptCode) = de.DeptCode
							  
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

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertEmployeeProfession')
	BEGIN
		DROP  Procedure  rpc_insertEmployeeProfession
	END

GO

CREATE Procedure dbo.rpc_insertEmployeeProfession
	(
		@EmployeeID int,
		@ProfesionCodes varchar(max),
		@UpdateUser varchar(max)	
	)

AS

	DECLARE @count int, @currentCount int
	DECLARE @curProfCode int
	
	Declare @MinProfCode int
	SET @curProfCode = 0
	Set @MinProfCode = 0
	SET @count = (Select count(IntField) from  dbo.SplitString(@ProfesionCodes))

	IF( @count > 0)
		BEGIN 

			SET @currentCount = @count

			WHILE (@currentCount > 0)
				BEGIN
				
					SET @curProfCode = (select min(IntField) from dbo.SplitString(@ProfesionCodes)
											where IntField > @MinProfCode)
				
					SET @MinProfCode = @curProfCode
												   
					IF NOT EXISTS 
					(
						SELECT EmployeeID, serviceCode
						FROM EmployeeServices
						WHERE EmployeeID = @EmployeeID AND serviceCode = @curProfCode
					)
					INSERT INTO EmployeeServices 
					(EmployeeID, serviceCode, mainProfession, expProfession, updateUser)
					VALUES 
					(@EmployeeID, @curProfCode, 0, 0, @UpdateUser)
					
					SET @currentCount = @currentCount -1
				
				END

				UPDATE Employee
				SET updateDate = GETDATE()
				WHERE employeeID = @EmployeeID

		END 

GO

GRANT EXEC ON rpc_insertEmployeeProfession TO PUBLIC

GO




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

SET @enableOverlappingHours = 0


--EmployeeReception
INSERT INTO DeptEmployeeReception (deptCode, EmployeeID, ReceptionDay, OpeningHour, ClosingHour, 
													ValidFrom, ValidTo, UpdateDate, UpdateUser, disableBecauseOfOverlapping )
VALUES( @deptCode, @employeeID, @receptionDay, @openingHour, @closingHour, @validFrom, @validTo, GetDate(), @updateUser, 0)


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
			FROM x_Dept_Employee_Service xDES 
			WHERE xDES.employeeID = @EmployeeID 
			AND xDES.deptCode = @DeptCode
			) as T
		ORDER BY opder)
	IF (@order is null)
		SET @order = 4
	
	RETURN( @order )		
END

GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_CheckIfDoctorHasProfessionsOrReception')
	BEGIN
		DROP  Procedure  rpc_CheckIfDoctorHasProfessionsOrReception
	END
GO

CREATE Procedure dbo.rpc_CheckIfDoctorHasProfessionsOrReception
(
	@employeeID BIGINT,
	@retVal BIT OUTPUT
)

AS


IF EXISTS
(
	SELECT *
	FROM EmployeeServices
	JOIN [Services] S ON EmployeeServices.serviceCode = S.serviceCode
	WHERE EmployeeID = @employeeID
	AND S.IsProfession = 1
)
	SET @retVal = 1
ELSE
	IF EXISTS
	(
		SELECT * 
		FROM DeptEmployeeReception der
		INNER JOIN DeptEmployeeReceptionServices ders
			ON der.ReceptionID = ders.ReceptionID		
		INNER JOIN [Services] S ON ders.serviceCode = S.serviceCode
		WHERE der.EmployeeID = @employeeID
		AND S.IsProfession = 1
	)
		SET @retVal = 1
	ELSE
		SET @retVal = 0

GO


GRANT EXEC ON rpc_CheckIfDoctorHasProfessionsOrReception TO PUBLIC

GO

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

DELETE 
FROM x_Dept_Employee_Service
WHERE DeptCode = @deptCode 
AND EmployeeID = @employeeID
AND x_Dept_Employee_Service.serviceCode IN
	(SELECT serviceCode FROM [Services] WHERE IsProfession = 1)



GO


GRANT EXEC ON rpc_deleteEmployeeProfessionsInDept TO PUBLIC

GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteEmployeeService')
	BEGIN
		DROP  Procedure  rpc_deleteEmployeeService
	END

GO

CREATE Procedure dbo.rpc_deleteEmployeeService
	(
		@EmployeeID int,
		@ServiceCode int = NULL
	)

AS

DELETE FROM EmployeeServices
WHERE EmployeeID = @EmployeeID 
AND serviceCode = IsNull(@ServiceCode, serviceCode)
AND serviceCode IN (SELECT serviceCode FROM [Services] WHERE IsProfession = 0)

UPDATE Employee
SET updateDate = GETDATE()
WHERE employeeID = @EmployeeID
GO

GRANT EXEC ON rpc_deleteEmployeeService TO PUBLIC

GO




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
	WHERE employeeID = @employeeID
	AND x_Dept_Employee_Service.serviceCode IN
		(SELECT serviceCode FROM [Services] WHERE IsProfession = 1)

	DELETE FROM deptEmployeeReceptionServices 
	WHERE receptionID IN (SELECT receptionID FROM deptEmployeeReception WHERE EmployeeID = @employeeID)
	AND serviceCode IN (SELECT serviceCode FROM [Services] WHERE IsProfession = 1)

	DELETE FROM deptEmployeeReception 
	WHERE EmployeeID = @employeeID
	AND NOT EXISTS 
		(SELECT * FROM deptEmployeeReceptionServices 
		WHERE deptEmployeeReceptionServices.receptionID = deptEmployeeReception.receptionID 
		AND serviceCode IN (SELECT serviceCode FROM [Services] WHERE IsProfession = 1)
		)
	
	DELETE FROM EmployeeServices WHERE EmployeeID = @employeeID
END

GO

GRANT EXEC ON rpc_updateEmployee TO PUBLIC

GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeeProfessionForUpdate')
	BEGIN
		DROP  Procedure  rpc_getEmployeeProfessionForUpdate
	END

GO

CREATE Procedure rpc_getEmployeeProfessionForUpdate
	(
		@EmployeeID int,
		@ProfessionCode int
	)

AS

SELECT
EmployeeServices.EmployeeID,
EmployeeServices.serviceCode as professionCode,
[Services].ServiceDescription as professionDescription,
EmployeeServices.mainProfession,
'expProfession' = CAST( isNull(EmployeeServices.expProfession, 0) as bit) 

FROM EmployeeServices
INNER JOIN [Services] ON EmployeeServices.serviceCode = [Services].ServiceCode
WHERE EmployeeID = @EmployeeID
	AND EmployeeServices.serviceCode = @ProfessionCode

GO

GRANT EXEC ON rpc_getEmployeeProfessionForUpdate TO PUBLIC

GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetEmployeeSpecialityByName')
	BEGIN
		DROP  Procedure  rpc_GetEmployeeSpecialityByName
	END

GO

CREATE Procedure dbo.rpc_GetEmployeeSpecialityByName
(
	@prefixText VARCHAR(20),
	@employeeID BIGINT
)

AS


SELECT 
S.serviceCode as ProfessionCode, 
S.ServiceDescription as ProfessionDescription

FROM EmployeeServices
INNER JOIN [Services] S ON EmployeeServices.serviceCode = S.serviceCode

WHERE EmployeeID = @employeeID 
AND S.ServiceDescription LIKE '%' + @prefixText + '%'
ORDER BY S.ServiceDescription

GO


GRANT EXEC ON rpc_GetEmployeeSpecialityByName TO PUBLIC

GO


IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getProfessionsForEmployee')
	BEGIN
		DROP  Procedure  rpc_getProfessionsForEmployee
	END

GO

CREATE Procedure rpc_getProfessionsForEmployee
	(
		@EmployeeID int
	)

AS

SELECT
[Services].ServiceCode as professionCode,
[Services].ServiceDescription as professionDescription,
ExpProfession,
'parentCode' = IsNull(parentCode, 0),
'groupCode' = [Services].ServiceCode,
'groupName' = [Services].ServiceDescription,
'IsAlreadyIn' = CASE IsNull(EmployeeServices.ServiceCode, 0) WHEN 0 THEN 0 ELSE 1 END

FROM [Services]
LEFT JOIN serviceParentChild ON [Services].ServiceCode = serviceParentChild.childCode
LEFT JOIN EmployeeServices ON [Services].ServiceCode = EmployeeServices.ServiceCode
	AND EmployeeServices.EmployeeID = @EmployeeID
WHERE parentCode is null

UNION

SELECT
[Services].ServiceCode as professionCode,
[Services].ServiceDescription as professionDescription, ExpProfession, 
'parentCode' = IsNull(parentCode, 0),
'groupCode' = parentCode,
'groupName' = [Services].ServiceDescription,
'IsAlreadyIn' = CASE IsNull(EmployeeServices.ServiceCode, 0) WHEN 0 THEN 0 ELSE 1 END

FROM [Services]
LEFT JOIN serviceParentChild ON [Services].ServiceCode = serviceParentChild.childCode
INNER JOIN [Services] as S ON serviceParentChild.parentCode = S.ServiceCode
LEFT JOIN EmployeeServices ON [Services].ServiceCode = EmployeeServices.ServiceCode
	AND EmployeeServices.EmployeeID = @EmployeeID
WHERE parentCode is NOT null

ORDER BY groupName, parentCode

GO

GRANT EXEC ON rpc_getProfessionsForEmployee TO PUBLIC

GO

IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rpc_updateEmployeeExpertise')
	BEGIN
		DROP  Procedure  rpc_updateEmployeeExpertise
	END

GO

create Procedure [dbo].[rpc_updateEmployeeExpertise]
(
	@employeeID INT,
	@professionCodes VARCHAR(50),
	@updateUser VARCHAR(50)	
)

AS


	DECLARE @count int, @currentCount int
	DECLARE @curProfCode int
	
	Declare @MinProfCode int
	SET @curProfCode = 0
	Set @MinProfCode = 0
	SET @count = (Select count(IntField) from  dbo.SplitString(@professionCodes))

	-- RESET ALL THE EXPERTISES
	UPDATE EmployeeServices
	SET expProfession = 0 
	WHERE EmployeeID = @employeeID
	
	
	IF( @count > 0)
		BEGIN 

			SET @currentCount = @count

			WHILE (@currentCount > 0)
				BEGIN
				
					SET @curProfCode = (select min(IntField) from dbo.SplitString(@professionCodes)
											where IntField > @MinProfCode)
				
					SET @MinProfCode = @curProfCode
												   
					UPDATE EmployeeServices
					SET expProfession = 1,  updateUser = @UpdateUser
					WHERE EmployeeID = @employeeID AND serviceCode = @curProfCode
										
					SET @currentCount = @currentCount -1
				
				END

			UPDATE Employee
			SET updateDate = GETDATE()
			WHERE employeeID = @EmployeeID

		 end

GRANT EXEC ON rpc_updateEmployeeExpertise TO PUBLIC

GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateEmployeeProfession')
	BEGIN
		DROP  Procedure  rpc_updateEmployeeProfession
	END

GO

CREATE PROCEDURE dbo.rpc_updateEmployeeProfession
	(
		@EmployeeID int,
		@ProfessionCode int,
		@MainProfession int,
		@ExpProfession int,
		@UpdateUser varchar(50),
		@ErrCode int OUTPUT
	)

AS

	UPDATE EmployeeServices
	SET expProfession = @ExpProfession
	WHERE EmployeeID = @EmployeeID
		AND serviceCode = @ProfessionCode
	
	SET @ErrCode = @@Error

GO

GRANT EXEC ON rpc_updateEmployeeProfession TO PUBLIC

GO


-- DELETE OBSOLETE SPs & functions ********************************************************************
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_GetDeptProfessions')
	BEGIN
		DROP  function  fun_GetDeptProfessions
	END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptEmployeeProfessionsForReceptionToAdd')
	BEGIN
		DROP  Procedure  rpc_getDeptEmployeeProfessionsForReceptionToAdd
	END

GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptEmployeeReceptionProfessions_NotAttributed')
	BEGIN
		DROP  Procedure  rpc_getDeptEmployeeReceptionProfessions_NotAttributed
	END

GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDeptList_Printing')
	BEGIN
		DROP  Procedure  rpc_GetDeptList_Printing
	END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeeProfessionsForDept')
	BEGIN
		DROP  Procedure  rpc_getEmployeeProfessionsForDept
	END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getProfessionsForPopUp')
	BEGIN
		DROP  Procedure  rpc_getProfessionsForPopUp
	END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertDeptEmployeeProfession')
	BEGIN
		DROP  Procedure  rpc_insertDeptEmployeeProfession
	END
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateEmployeeProfessionsInDept')
	BEGIN
		DROP  Procedure  rpc_UpdateEmployeeProfessionsInDept
	END

GO

IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rfn_GetDeptEmployeeReception')
	BEGIN
		DROP  function  dbo.rfn_GetDeptEmployeeReception
	END

GO

IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'fun_GetProfessionsAndServicesForEmployeeReception')
	BEGIN
		DROP  function  dbo.fun_GetProfessionsAndServicesForEmployeeReception
	END

GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteMultipleEmployeeProfessions')
	BEGIN
		DROP  Procedure  rpc_DeleteMultipleEmployeeProfessions
	END

GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDoctorProfessions')
	BEGIN
		DROP  Procedure  rpc_getDoctorProfessions
	END
GO

--**** Yaniv - rpc_getDoctorList_PagedSorted ********************

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_getDoctorList_PagedSorted]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[rpc_getDoctorList_PagedSorted]
GO

CREATE Procedure [dbo].[rpc_getDoctorList_PagedSorted]

@FirstName varchar(max)=null,
@LastName varchar(max)=null,
@DistrictCodes varchar(max)=null,
@EmployeeID bigint=null,
@CityName varchar(max)=null,
--@ProfessionCode varchar(max)=null,
@serviceCode varchar(max)=null,
--@SubProfessionCode varchar(max)=null, 
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
dic.QueueOrderDescription,
'address' = dbo.GetAddress(x_Dept_Employee.deptCode),
'cityName' = IsNull(cityName, ''),
--'phone' = '08-1234567','HasReception' =1, 'expert' = 'expert', 'HasRemarks' = 1,

'phone' = IsNULL(	(SELECT dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) 
					FROM DeptEmployeePhones 
					WHERE deptCode = x_Dept_Employee.deptCode
					AND employeeID = x_Dept_Employee.employeeID
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
					WHERE deptCode = x_Dept_Employee.deptCode
					AND employeeID = x_Dept_Employee.employeeID
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
					FROM deptEmployeeReception
					WHERE deptCode = x_Dept_Employee.deptCode
					AND EmployeeID = x_Dept_Employee.employeeID
					AND (validFrom is null OR validFrom <= getdate())
					AND (validTo is null OR validTo >= getdate()) ), 0)
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
					AND (v_DE_ER.ValidFrom is null OR DATEDIFF(dd, v_DE_ER.ValidFrom ,getdate()) >= 0)
					AND (v_DE_ER.ValidTo is null OR DATEDIFF(dd, v_DE_ER.ValidTo ,getdate()) <= 0)
				)
				+
				(SELECT COUNT(DeptEmployeeServiceRemarkID)
				From DeptEmployeeServiceRemarks
					where DeptEmployeeServiceRemarks.EmployeeID = x_Dept_Employee.EmployeeID
					AND (validFrom is null OR DATEDIFF(dd, ValidFrom ,getdate()) >= 0) 
					AND (validTo is null OR DATEDIFF(dd, ValidTo ,getdate()) <= 0) 
				), 0)
				WHEN 0 THEN 0 ELSE 1 END,
				
'professions' = [dbo].[fun_GetEmployeeInDeptProfessions](x_Dept_Employee.employeeID, x_Dept_Employee.deptCode, 
						CASE @IsOrderDescending WHEN 1 THEN 0 ELSE 1 END),
'services' = [dbo].[fun_GetEmployeeInDeptServices] (x_Dept_Employee.employeeID, x_Dept_Employee.deptCode,
						CASE @IsOrderDescending WHEN 1 THEN 0 ELSE 1 END),
'positions'	= [dbo].[fun_GetEmployeeInDeptPositions](x_Dept_Employee.employeeID, x_Dept_Employee.deptCode, employee.sex),
'AgreementType' = IsNull(x_Dept_Employee.agreementType, 0),
'distance' = (xcoord - @CoordinateX)*(xcoord - @CoordinateX) + (ycoord - @CoordinateY)*(ycoord - @CoordinateY),

'hasMapCoordinates' = CASE IsNull((xcoord + ycoord),0) WHEN 0 THEN 0 ELSE 1 END,
'EmployeeStatus' = Employee.active,
'EmployeeStatusInDept' = IsNull(x_Dept_Employee.active, 0),
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
(@DistrictCodes is null or dept.districtCode IN (SELECT IntField FROM dbo.SplitString(@DistrictCodes)))
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
			Employee.employeeID IN  (
							SELECT DISTINCT EmployeeID
							FROM EmployeeServices 
							WHERE ExpProfession = 1 
							)
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
	x_Dept_Employee.employeeID IN (SELECT employeeID 
									FROM x_Dept_Employee_Service 
									WHERE deptCode = x_Dept_Employee.deptCode
									AND employeeID = x_Dept_Employee.employeeID
									AND serviceCode IN (SELECT IntField FROM dbo.SplitString(@serviceCode))
									AND (	@ExpProfession is null
											OR
											(
												employeeID IN  (
																SELECT DISTINCT EmployeeID
																FROM EmployeeServices 
																WHERE ExpProfession = 1 
																)
												AND @expProfession = 1
											)
											
											OR
											
											(
												employeeID NOT IN  (
																	SELECT DISTINCT EmployeeID
																	FROM EmployeeServices 
																	WHERE ExpProfession = 1 
																	)
												AND @expProfession = 0
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
		x_Dept_Employee.employeeID IN (SELECT EmployeeID 
										FROM EmployeeLanguages
										WHERE languageCode IN (SELECT IntField FROM dbo.SplitString(@LanguageCode))	
										)									
	)
AND (@deptHandicappedFacilities is null
	OR
	x_Dept_Employee.employeeID IN (SELECT employeeID FROM x_Dept_Employee as New
								WHERE (SELECT COUNT(deptCode) FROM DeptHandicappedFacilities as T
										WHERE FacilityCode IN (SELECT IntField FROM dbo.SplitString(@deptHandicappedFacilities))
										AND T.deptCode = New.deptCode) = @HandicappedFacilitiesCount )
	)
AND (@positionCode is null
	OR
	x_Dept_Employee.employeeID IN (SELECT employeeID FROM x_Dept_Employee_Position
									WHERE x_Dept_Employee_Position.deptCode = x_Dept_Employee.deptCode
									AND x_Dept_Employee_Position.employeeID = x_Dept_Employee.employeeID
									AND x_Dept_Employee_Position.positionCode = @positionCode)
	)
AND (@ReceptionDays is null
	OR
	(x_Dept_Employee.employeeID IN (SELECT employeeID 
								FROM deptEmployeeReception  as T
								INNER JOIN deptEmployeeReceptionServices ON T.receptionID = deptEmployeeReceptionServices.receptionID
								WHERE receptionDay IN (SELECT IntField FROM dbo.SplitString(@ReceptionDays))
								AND T.DeptCode =  Dept.DeptCode
								AND
									( @ServiceCode is null OR deptEmployeeReceptionServices.serviceCode IN (SELECT IntField FROM dbo.SplitString(@ServiceCode)) )
								)
		)
	)
AND	( (@OpenAtHour_Str is null AND @OpenFromHour_Str is null AND @OpenToHour_Str is null)
	OR x_Dept_Employee.employeeID IN 
								(SELECT employeeID FROM deptEmployeeReception as T
								INNER JOIN deptEmployeeReceptionServices ON T.receptionID = deptEmployeeReceptionServices.receptionID
								WHERE T.deptCode = x_Dept_Employee.deptCode
								AND T.EmployeeID = x_Dept_Employee.EmployeeID
								AND	( T.openingHour < @OpenToHour_var AND T.closingHour > @OpenFromHour_var )
								AND (@ReceptionDays is null
										OR
										T.receptionDay IN (SELECT IntField FROM dbo.SplitString(@ReceptionDays))
									)
								AND
									( @OpenAtHour_Str is null 
										OR 
										( T.openingHour < @OpenAtHour_var AND T.closingHour > @OpenAtHour_var )
									)
								AND
									( @ServiceCode is null OR deptEmployeeReceptionServices.serviceCode IN (SELECT IntField FROM dbo.SplitString(@ServiceCode)) )
								)
							) 
AND( @CoordinateX is null OR (xcoord is NOT null AND ycoord is NOT null))
AND( @licenseNumber is null OR Employee.licenseNumber = @licenseNumber)
AND(@userIsRegistered = 1 OR x_Dept_Employee.deptCode is NOT null)
AND((@userIsRegistered = 1 and x_Dept_Employee.deptCode is null) or dept.status = 1)
) as innerSelection
) as middleSelection


SELECT TOP (@PageSise) * INTO #tempTable FROM #tempTableAllRows
WHERE RowNumber > @StartingPosition
	AND RowNumber <= @StartingPosition + @PageSise
ORDER BY RowNumber


SELECT * FROM #tempTable


SELECT eqom.QueueOrderMethod, eqom.deptCode, eqom.employeeID , DIC_ReceptionDays.receptionDayName, eqoh.FromHour, eqoh.ToHour
FROM EmployeeQueueOrderMethod eqom
INNER JOIN #tempTable ON eqom.DeptCode = #tempTable.deptCode AND eqom.employeeID = #tempTable.employeeID
LEFT JOIN EmployeeQueueOrderHours eqoh ON eqom.QueueOrderMethodID = eqoh.QueueOrderMethodID
LEFT JOIN DIC_ReceptionDays ON eqoh.receptionDay = DIC_ReceptionDays.ReceptionDayCode


SELECT #tempTable.deptCode, #tempTable.employeeID,  
	dbo.fun_ParsePhoneNumberWithExtension(DeptPhones.prePrefix, DeptPhones.prefix, DeptPhones.phone, DeptPhones.extension) as Phone
FROM #tempTable  
INNER JOIN EmployeeQueueOrderMethod eqom ON eqom.DeptCode = #tempTable.deptCode AND eqom.employeeID = #tempTable.employeeID
INNER JOIN DIC_QueueOrderMethod ON eqom.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
INNER JOIN DeptPhones ON eqom.deptCode = DeptPhones.deptCode
WHERE phoneType = 1 AND phoneOrder = 1 AND SpecialPhoneNumberRequired = 0 AND ShowPhonePicture = 1


SELECT #tempTable.deptCode, #tempTable.employeeID, 
dbo.fun_ParsePhoneNumberWithExtension(eqop.prePrefix, eqop.prefix, eqop.phone, eqop.extension) as Phone
FROM #tempTable  
INNER JOIN EmployeeQueueOrderMethod eqom ON eqom.DeptCode = #tempTable.deptCode AND eqom.employeeID = #tempTable.employeeID
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
	  FROM [dbo].[vEmployeeReceptionHours] v
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
		where getdate() >= v_DE_ER.ValidFrom and (getdate() <= v_DE_ER.ValidTo
						or v_DE_ER.ValidTo is NULL)
	UNION

	SELECT
	desr.EmployeeID,
	desr.DeptCode,
	dbo.rfn_GetFotmatedRemark(desr.RemarkText),
	CONVERT(VARCHAR(2),DAY(desr.ValidTo)) + '/' + CONVERT(VARCHAR(2),MONTH(desr.ValidTo)) + '/' + CONVERT(VARCHAR(4),YEAR(desr.ValidTo))
	FROM DeptEmployeeServiceRemarks desr
	INNER JOIN [Services] ON desr.ServiceCode = [Services].ServiceCode
	INNER JOIN x_dept_employee_service xdes ON [Services].serviceCode = xdes.serviceCode AND xdes.Status = 1
	inner join #tempTableAllRows tbl on tbl.deptCode = xdes.deptCode
	and tbl.EmployeeID = xdes.EmployeeID
	where getdate() >= desr.ValidFrom and (getdate() <= desr.ValidTo
						or desr.ValidTo is NULL)
	DROP TABLE #tempTableAllRows
end
GO

GRANT EXEC ON rpc_getDoctorList_PagedSorted TO PUBLIC

GO


--**** End - rpc_getDoctorList_PagedSorted ********************

----------- 04/12/2011  ---  JULIA -----------------
---don't used now
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'rfn_GetDeptEmployeeExpertProfessionCodes')
	BEGIN
		DROP  FUNCTION  rfn_GetDeptEmployeeExpertProfessionCodes
	END

GO

IF EXISTS (SELECT * FROM sysobjects WHERE name = 'rfn_GetDeptEmployeeExpertProfessionDescriptions')
	BEGIN
		DROP  FUNCTION  rfn_GetDeptEmployeeExpertProfessionDescriptions
	END

GO

IF EXISTS (SELECT * FROM sysobjects WHERE name = 'rfn_GetEmployeeAllExpertProfessionsString')
	BEGIN
		DROP  FUNCTION  dbo.rfn_GetEmployeeAllExpertProfessionsString
	END

GO

IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rfn_GetDeptEmployeeReception')
	BEGIN
		DROP  function  dbo.rfn_GetDeptEmployeeReception
	END

GO

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

inner join [dbo].DeptEmployeeReception as Recep  on	x_dept_employee.deptCode = recep.deptCode
	and x_dept_employee.EmployeeID = recep.EmployeeID 
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

inner join [dbo].DeptEmployeeReception as Recep  on	x_dept_employee.deptCode = recep.deptCode 
	and x_dept_employee.EmployeeID = recep.EmployeeID 
inner join dbo.deptEmployeeReceptionServices as RecServ on Recep.receptionID = RecServ.receptionID  
inner join Services	ON RecServ.serviceCode = Services.serviceCode 
	and Services.IsService = 1 
inner join DIC_ReceptionDays on Recep.receptionDay = DIC_ReceptionDays.ReceptionDayCode
left join DeptEmployeeReceptionRemarks as RecRemarks on Recep.receptionID = RecRemarks.DeptEmployeeReceptionRemarkID

 )
AS subq

GO



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
						on xDEP.ServiceCode = Services.ServiceCode
						and xDEP.deptCode = x_Dept_Employee.deptCode
						and xDEP.employeeID = x_Dept_Employee.employeeID
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
						on xDEP.ServiceCode = Services.ServiceCode
						and xDEP.deptCode = x_Dept_Employee.deptCode
						and xDEP.employeeID = x_Dept_Employee.employeeID
						and Services.IsProfession = 1
					order by Services.ServiceDescription
					FOR XML PATH('') 
				)
				,1,2,'') as ProfessionCodes
	from x_Dept_Employee 
GO

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
	inner join Services on xDEP.ServiceCode = Services.ServiceCode
		and (@deptCode = -1 or xDEP.deptCode = @deptCode)
		and (@employeeID = -1 or xDEP.employeeID = @employeeID)
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
		FROM x_Dept_Employee_Service as xDEP 
		WHERE xDEP.deptCode = d.deptCode
		and xDEP.employeeID	= x_Dept_Employee.employeeID								
		AND ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ProfessionCodes + ''' ))) > 0
	)
	AND (''' + @ExpertProfessionCodes + ''' = ''-1'' or
	(	SELECT count(*) 
		FROM x_Dept_Employee_Service  as xDEP 
		left join EmployeeServices on xDEP.employeeID = EmployeeServices.employeeID 
					and xDEP.ServiceCode = EmployeeServices.ServiceCode
					and EmployeeServices.expProfession = 1
		WHERE deptCode = d.deptCode	
		and x_Dept_Employee.employeeID= xDEP.employeeID	
		and EmployeeServices.ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ExpertProfessionCodes + ''' ))) > 0
	)
	AND (''' + @ServiceCodes + ''' = ''-1'' or
	(	SELECT count(*) 
		FROM x_Dept_Employee_Service as xDS
		WHERE d.deptCode = xDS.deptCode
		and x_Dept_Employee.employeeID = xDS.employeeID									
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
left join DeptEmployeePhones as  emplPh1  on  d.deptCode = emplPh1.deptCode and x_Dept_Employee.employeeID = emplPh1.employeeID 
	and emplPh1.PhoneType = 1 and emplPh1.phoneOrder = 1  
left join DeptEmployeePhones as emplPh2  on  d.deptCode = emplPh2.deptCode and x_Dept_Employee.employeeID = emplPh2.employeeID 
	and emplPh2.PhoneType = 1 and emplPh2.phoneOrder = 2 
left join DeptEmployeePhones as emplPh3  on  d.deptCode = emplPh3.deptCode and x_Dept_Employee.employeeID = emplPh3.employeeID 
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
		WHERE d.deptCode = x_Dept_Employee_Service.deptCode
		and x_Dept_Employee.employeeID = x_Dept_Employee_Service.employeeID									
		AND ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ServiceCodes + ''' ))) > 0
	)	
	 and (''' + @ProfessionCodes + ''' = ''-1'' or
	(	
		SELECT count(*) 
		FROM x_Dept_Employee_Service 
		WHERE deptCode = d.deptCode	
		and x_Dept_Employee.employeeID= x_Dept_Employee_Service.employeeID								
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
		set @sql = @sql + 'dbo.rfn_FormatAddress(d.streetName, d.house, d.flat, d.floor, Cities.CityName ) as ClinicAddress '+ @NewLineChar;
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

set @sql = @sql + @sqlFrom + @sqlWhere + @sqlEnd

print '--------- sql query full ----------'
print '--===== @sql string length = ' + str(len(@sql))
print @sql 

EXECUTE sp_executesql @sql 
SET @ErrCode = @sql 
RETURN 

GO
GRANT EXEC ON [dbo].rprt_DeptEmployeeReceptions TO PUBLIC
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
	and d.IsCommunity = 1
	AND (''' + @AdminClinicCode + ''' = ''-1'' or d.administrationCode  in (SELECT IntField FROM dbo.SplitString( ''' + @AdminClinicCode + ''')))
	AND (''' + @UnitTypeCodes + ''' = ''-1'' or d.typeUnitCode  in (SELECT IntField FROM dbo.SplitString( ''' + @UnitTypeCodes + ''')) )
	AND (''' + @CitiesCodes + ''' = ''-1'' or d.CityCode IN (SELECT IntField FROM dbo.SplitString( ''' + @CitiesCodes + ''')) )
	AND (''' + @DistrictCodes + ''' = ''-1'' or d.districtCode IN (SELECT IntField FROM dbo.SplitString( ''' + @DistrictCodes + ''')) )
	AND (''' + @AgreementType_cond + ''' = ''-1'' or x_Dept_Employee.AgreementType IN (SELECT IntField FROM dbo.SplitString(''' + @AgreementType_cond + ''' ))) 
	and (''' + @ProfessionCodes + ''' = ''-1'' or
	(	SELECT count(*) 
		FROM x_Dept_Employee_Service as xDEP 
		WHERE xDEP.deptCode = d.deptCode
		and xDEP.employeeID	= x_Dept_Employee.employeeID								
		AND ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ProfessionCodes + ''' ))) > 0
	)
	AND (''' + @ExpertProfessionCodes + ''' = ''-1'' or
	(	SELECT count(*) 
		FROM x_Dept_Employee_Service  as xDEP 
		left join EmployeeServices on xDEP.employeeID = EmployeeServices.employeeID 
					and xDEP.ServiceCode = EmployeeServices.ServiceCode
					and EmployeeServices.expProfession = 1
		WHERE deptCode = d.deptCode	
		and x_Dept_Employee.employeeID= xDEP.employeeID	
		and EmployeeServices.ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ExpertProfessionCodes + ''' ))) > 0
	)
	AND (''' + @ServiceCodes + ''' = ''-1'' or
	(	SELECT count(*) 
		FROM x_Dept_Employee_Service as xDS
		WHERE d.deptCode = xDS.deptCode
		and x_Dept_Employee.employeeID = xDS.employeeID									
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
left join DeptEmployeePhones as  emplPh1  on  d.deptCode = emplPh1.deptCode and x_Dept_Employee.employeeID = emplPh1.employeeID 
	and emplPh1.PhoneType = 1 and emplPh1.phoneOrder = 1  
left join DeptEmployeePhones as emplPh2  on  d.deptCode = emplPh2.deptCode and x_Dept_Employee.employeeID = emplPh2.employeeID 
	and emplPh2.PhoneType = 1 and emplPh2.phoneOrder = 2 
left join DeptEmployeePhones as emplPh3  on  d.deptCode = emplPh3.deptCode and x_Dept_Employee.employeeID = emplPh3.employeeID 
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
		set @sql = @sql + 'dbo.rfn_FormatAddress(d.streetName, d.house, d.flat, d.floor, Cities.CityName ) as ClinicAddress '+ @NewLineChar;
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
--=================================================================
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

set @sql = @sql + @sqlFrom + @sqlWhere + @sqlEnd

print '--------- sql query full ----------'
print '--===== @sql string length = ' + str(len(@sql))
print @sql 

EXECUTE sp_executesql @sql 
SET @ErrCode = @sql 
RETURN 

GO
GRANT EXEC ON [dbo].rprt_DeptEmployees TO PUBLIC
GO
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
	AND (''' + @DistrictCodes + ''' = ''-1'' or  d.districtCode IN (SELECT IntField FROM dbo.SplitString( ''' + @DistrictCodes + ''')) )
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
			WHERE deptCode = d.deptCode									
			AND ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ProfessionCodes + ''' ))) > 0
		)
	AND (
	''' + @ServiceCodes + ''' = ''-1'' or
		(SELECT count(*) 
		FROM x_Dept_Employee_Service 
		WHERE d.deptCode = x_Dept_Employee_Service.deptCode									
		AND ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ServiceCodes + ''' ))) > 0
		or
		(SELECT count(*) 
		FROM x_Dept_Service 
		WHERE d.deptCode = x_Dept_Service.deptCode								
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
		set @sql = @sql + 'dbo.rfn_FormatAddress(d.streetName, d.house, d.flat, d.floor, Cities.CityName ) as ClinicAddress '+ @NewLineChar;
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

print '--===== @sql ========'
print '--===== @sql length====' + str(len(@sql))
print @sql


print '--===== @sqlFrom ========'
print '--===== @sqlFrom length====' + str(len(@sqlFrom))
print @sqlFrom 


 print '--===== @sqlEnd ========'
print '--===== @sqlEnd length====' + str(len(@sqlEnd))
print @sqlEnd


set @sql = @sql + @sqlFrom+ @sqlEnd

print '--------- sql query full ----------'
print '===== @sql string length = ' + str(len(@sql))
print @sql 


EXECUTE sp_executesql @sql 
SET @ErrCode = @sql 
RETURN 

GO
GRANT EXEC ON [dbo].rprt_DeptsByProfessionsTypes TO PUBLIC
GO
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
	AND (''' + @DistrictCodes + ''' = ''-1'' or  d.districtCode IN (SELECT IntField FROM dbo.SplitString( ''' + @DistrictCodes + ''')) )
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
			WHERE deptCode = d.deptCode									
			AND serviceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ProfessionCodes + ''' ))) > 0
		)
	AND (
	''' + @ServiceCodes + ''' = ''-1'' or
		(SELECT count(*) 
		FROM x_Dept_Employee_Service 
		WHERE d.deptCode = x_Dept_Employee_Service.deptCode									
		AND ServiceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ServiceCodes + ''' ))) > 0
		or
		(SELECT count(*) 
		FROM x_Dept_Service 
		WHERE d.deptCode = x_Dept_Service.deptCode								
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
		set @sql = @sql + 'dbo.rfn_FormatAddress(d.streetName, d.house, d.flat, d.floor, Cities.CityName ) as ClinicAddress '+ @NewLineChar;
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
print '--===== @sql ========'
print '--===== @sql length====' + str(len(@sql))
print @sql


print '--===== @sqlFrom ========'
print '--===== @sqlFrom length====' + str(len(@sqlFrom))
print @sqlFrom 


 print '--===== @sqlEnd ========'
print '--===== @sqlEnd length====' + str(len(@sqlEnd))
print @sqlEnd


set @sql = @sql + @sqlFrom+ @sqlEnd

print '--------- sql query full ----------'
print '===== @sql string length = ' + str(len(@sql))
print @sql 


EXECUTE sp_executesql @sql 
SET @ErrCode = @sql 
RETURN  
 
GO
GRANT EXEC ON [dbo].rprt_DeptsByServicesTypes TO PUBLIC
GO


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
		WHERE Employee.employeeID = x_Dept_Employee_Position.employeeID									
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
left join x_Dept_Employee_EmployeeRemarks on  d.deptCode = x_Dept_Employee_EmployeeRemarks.deptCode 
						and x_Dept_Employee.employeeID = x_Dept_Employee_EmployeeRemarks.employeeID	
left join EmployeeRemarks on x_Dept_Employee_EmployeeRemarks.EmployeeRemarkID = EmployeeRemarks.EmployeeRemarkID 
INNER JOIN View_EmployeeSector on Employee.EmployeeSectorCode = View_EmployeeSector.EmployeeSectorCode
--------------------
left join DeptEmployeePhones as  emplPh1  on  d.deptCode = emplPh1.deptCode and x_Dept_Employee.employeeID = emplPh1.employeeID 
	and emplPh1.PhoneType = 1 and emplPh1.phoneOrder = 1  
left join DeptEmployeePhones as emplPh2  on  d.deptCode = emplPh2.deptCode and x_Dept_Employee.employeeID = emplPh2.employeeID 
	and emplPh2.PhoneType = 1 and emplPh2.phoneOrder = 2 
left join DeptEmployeePhones as emplPh3  on  d.deptCode = emplPh3.deptCode and x_Dept_Employee.employeeID = emplPh3.employeeID 
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
print '--===== @sql ========'
print '--===== @sql length====' + str(len(@sql))
print @sql


print '--===== @sqlFrom ========'
print '--===== @sqlFrom length====' + str(len(@sqlFrom))
print @sqlFrom 


print '--===== @sqlEnd ========'
print '--===== @sqlEnd length====' + str(len(@sqlEnd))
print @sqlEnd

set @sql = @sql + @sqlFrom 
--+ @sqlWhere
 + @sqlEnd
 
set @sql = 'SET DATEFORMAT dmy ' + @NewLineChar + @sql +@NewLineChar+ 'SET DATEFORMAT mdy;'

print '--------- sql query full ----------'
print '--===== @sql string length = ' + str(len(@sql))
print @sql 

			 
			
SET DATEFORMAT dmy;
EXECUTE sp_executesql @sql 
SET DATEFORMAT mdy;

SET @ErrCode = @sql 
RETURN 

GO
GRANT EXEC ON [dbo].rprt_EmployeeReceptions TO PUBLIC
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_EmployeeRemarks')
	BEGIN
		DROP  Procedure  dbo.rprt_EmployeeRemarks
	END

GO

CREATE Procedure dbo.rprt_EmployeeRemarks
(
	@DistrictCodes varchar(max)=null,
	@EmployeeSector_cond varchar(max)=null,
	 
	@ProfessionCodes varchar(max)=null,
	@Remark_cond varchar(max)=null,
	@IsRemarkAttributedToAllClinics_cond varchar(max)=null,
	@ShowRemarkInInternet_cond varchar(max)=null,
	@IsFutureRemark_cond varchar(max)=null,
	@AgreementType_cond varchar(max)=null,

	@district varchar (2)= null,
	@adminClinic varchar (2) = null ,		
	@ClinicName varchar (2)=null,
	@ClinicCode varchar (2)=null,
	@simul varchar (2)=null,
	@city varchar (2)=null,
	@address varchar (2)=null,
	
	@EmployeeName varchar (2)=null,
	@EmployeeID varchar (2)=null,
	@EmployeeSector varchar (2)=null,
	@EmployeePosition varchar (2)=null,
	@EmployeeProfessions varchar (2)=null,
	--@DeptEmployeeIndependent varchar (2)=null,
	@AgreementType  varchar(2)= null,
	@Remark varchar (2)=null,
	@RemarkAttributedToAllClinics varchar (2)=null,
	@ShowRemarkInInternet varchar (2)=null,
	@RemarkValidFrom varchar (2)=null,
	@RemarkValidTo varchar (2)=null,
	
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
--declare  @sqlJoin varchar(max)
--declare  @sqlWhere varchar(max)

declare  @sqlPart nvarchar(max)-- nvarchar type supports hebrew lenguage
declare  @sqlFromPart varchar(max)
declare  @sqlJoinPart2 varchar(max)
declare  @sqlJoin_x_Dept_Employee varchar(max)
declare  @sqlWherePart varchar(max)
declare  @stringNotNeeded  nvarchar(max)
---------------------------

set @sql = 'SELECT distinct *  from
			(select ' + @NewLineChar;
set @sqlEnd = ') as resultTable '+ @NewLineChar;
				
--set @sqlJoin = ' ';
--set @sqlWhere = ' ';


set @sqlFrom = 'from Employee 
join Employee as Emp on Employee.employeeID = Emp.employeeID
AND  Employee.Active = 1
AND (''' + @DistrictCodes + ''' = ''-1'' or Employee.primaryDistrict IN (SELECT IntField FROM dbo.SplitString( ''' + @DistrictCodes + ''')) )
AND (''' + @EmployeeSector_cond + ''' = ''-1'' or Employee.EmployeeSectorCode IN (SELECT IntField FROM dbo.SplitString(''' + @EmployeeSector_cond + ''' )) )
AND (''' + @ProfessionCodes + ''' = ''-1'' or
	(	SELECT count(*) 
		FROM EmployeeServices 
		WHERE Employee.employeeID = EmployeeServices.employeeID								
		AND EmployeeServices.serviceCode IN (SELECT IntField FROM dbo.SplitString( ''' + @ProfessionCodes + ''' ))) > 0
	)
	
	
join x_Dept_Employee ON x_Dept_Employee.employeeID = Employee.employeeID 
left join dept  as d  on d.deptCode = x_Dept_Employee.deptCode

inner join View_DeptEmployeesCurrentStatus as v_DECStatus 
	on x_Dept_Employee.deptCode = v_DECStatus.deptCode
	and Employee.employeeID = v_DECStatus.employeeID
	and v_DECStatus.status = 1
	AND (''' + @AgreementType_cond + ''' = ''-1'' or x_Dept_Employee.AgreementType IN (SELECT IntField FROM dbo.SplitString(''' + @AgreementType_cond + ''' ))) 

join View_DeptEmployee_EmployeeRemarks as v_DepEm_EmRem on
	v_DepEm_EmRem.DeptCode = x_Dept_Employee.deptCode
	and v_DepEm_EmRem.EmployeeID = x_Dept_Employee.EmployeeID
	AND (''' + @ShowRemarkInInternet_cond + ''' = ''-1'' or v_DepEm_EmRem.displayInInternet IN (SELECT IntField FROM dbo.SplitString( ''' + @ShowRemarkInInternet_cond + ''')) )
	AND (''' + @Remark_cond + ''' = ''-1'' or v_DepEm_EmRem.DicRemarkID IN (SELECT IntField FROM dbo.SplitString( ''' + @Remark_cond + ''')) )
	AND (''' + @IsRemarkAttributedToAllClinics_cond + ''' = ''-1'' or v_DepEm_EmRem.AttributedToAllClinicsInCommunity IN (SELECT IntField FROM dbo.SplitString( ''' + @IsRemarkAttributedToAllClinics_cond + ''')) )
	AND (''' + @IsFutureRemark_cond + ''' = ''-1''  
	or ''' + @IsFutureRemark_cond + ''' = ''1'' and v_DepEm_EmRem.validFrom >= GETDATE()
	or ''' + @IsFutureRemark_cond + ''' = ''0'' and v_DepEm_EmRem.validFrom < GETDATE() )
	
left join [dbo].View_DeptEmployeeProfessions as DEProfessions 
	on x_Dept_Employee.deptCode = DEProfessions.deptCode
	and Employee.employeeID = DEProfessions.employeeID 

left join [dbo].View_DeptEmployeePositions as DEPositions 
	on x_Dept_Employee.deptCode = DEPositions.deptCode
	and Employee.employeeID = DEPositions.employeeID 
	
left join DIC_AgreementTypes on x_Dept_Employee.AgreementType = DIC_AgreementTypes.AgreementTypeID


left join dept as dAdmin on d.administrationCode = dAdmin.deptCode 

left join dept as dDistrict on d.districtCode = dDistrict.deptCode

left join deptSimul on d.DeptCode = deptSimul.DeptCode 
 
left join Cities on d.CityCode =  Cities.CityCode  
		
INNER JOIN View_EmployeeSector on Employee.EmployeeSectorCode = View_EmployeeSector.EmployeeSectorCode
		
'

--==========================================
if(@district = '1')
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);	
		set @sql = @sql + ' dDistrict.DeptName as DistrictName , isNull(dDistrict.deptCode , -1) as DeptCode '+ @NewLineChar;
	end
if(@adminClinic = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' dAdmin.DeptName as AdminClinicName , isNull(dAdmin.DeptCode , -1) as AdminClinicCode '+ @NewLineChar;
	end 
	
-------------- Clinic----------------------------
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
		set @sql = @sql + 'dbo.rfn_FormatAddress(d.streetName, d.house, d.flat, d.floor, Cities.CityName ) as ClinicAddress '+ @NewLineChar;
	end	
 

------------------------------- Employee --------------------------------------------
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

if(@AgreementType = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
		+ 'DIC_AgreementTypes.AgreementTypeID as AgreementTypeCode,
			DIC_AgreementTypes.AgreementTypeDescription as AgreementTypeDescription '
		+ @NewLineChar;
	end	



--------- Remarks ---------------------------
if(@Remark = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql +
		'v_DepEm_EmRem.RemarkTextFormated as RemarkText,
		v_DepEm_EmRem.DicRemarkID as RemarkID'
		--'replace(replace(EmployeeRemarks.RemarkText,''#'', ''''), ''&quot;'', char(34)) as RemarkText, 
		----replace( EmployeeRemarks.RemarkText,''#'', '''')  
		--EmployeeRemarks.DicRemarkID as RemarkID '
		+ @NewLineChar;
	end	
if(@ShowRemarkInInternet = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
		'case when v_DepEm_EmRem.displayInInternet = 1 then ''כן'' else ''לא'' end as ShowRemarkInInternet'
		+ @NewLineChar;
	end	
if(@RemarkAttributedToAllClinics = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + 
		'case when v_DepEm_EmRem.AttributedToAllClinicsInCommunity  = 1 then ''כן'' else ''לא'' end as RemarkAttributedToAllClinics '
		+ @NewLineChar;
	end	
	
if(@RemarkValidFrom = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' v_DepEm_EmRem.ValidFrom as RemarkValidFrom '+ @NewLineChar;
	end		
	
if(@RemarkValidTo = '1' )
	begin 
		set @sql= dbo.SqlDynamicColumnCommaSeparator(@sql);
		set @sql = @sql + ' v_DepEm_EmRem.ValidTo as RemarkValidTo '+ @NewLineChar;
	end		

set @sql = @sql + ',case when  v_DepEm_EmRem.validFrom >= GETDATE() then 1 else 0 end as IsFutureRemark' + @NewLineChar;

	
	
			
--=================================================================
print '--===== @sql ========'
print '--===== @sql length====' + str(len(@sql))
print @sql


print '--===== @sqlFrom ========'
print '--===== @sqlFrom length====' + str(len(@sqlFrom))
print @sqlFrom 


print '--===== @sqlEnd ========'
print '--===== @sqlEnd length====' + str(len(@sqlEnd))
print @sqlEnd

set @sql = @sql + @sqlFrom 
--+ @sqlWhere
 + @sqlEnd

print '--------- sql query full ----------'
print '--===== @sql string length = ' + str(len(@sql))
print @sql 


SET DATEFORMAT dmy;
EXECUTE sp_executesql @sql 
SET DATEFORMAT mdy;

SET @ErrCode = @sql 
RETURN 

GO
GRANT EXEC ON [dbo].rprt_EmployeeRemarks TO PUBLIC
GO

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
		WHERE Employee.employeeID = x_Dept_Employee_Position.employeeID									
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

left join DeptEmployeePhones as  emplPh1  
	on  d.deptCode = emplPh1.deptCode 
	and x_Dept_Employee.employeeID = emplPh1.employeeID 
	and x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic <> 1 
	and emplPh1.PhoneType = 1 and emplPh1.phoneOrder = 1  

left join DeptEmployeePhones as emplPh2  
	on  d.deptCode = emplPh2.deptCode 
	and x_Dept_Employee.employeeID = emplPh2.employeeID 
	and x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic <> 1 
	and emplPh2.PhoneType = 1 and emplPh2.phoneOrder = 2 

left join DeptEmployeePhones as emplPh3  
	on  d.deptCode = emplPh3.deptCode 
	and x_Dept_Employee.employeeID = emplPh3.employeeID 
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
		set @sql = @sql + 'dbo.rfn_FormatAddress(d.streetName, d.house, d.flat, d.floor, Cities.CityName ) as ClinicAddress '+ @NewLineChar;
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


EXECUTE sp_executesql @sql 
SET @ErrCode = @sql 
RETURN 

GO
GRANT EXEC ON [dbo].rprt_Employees TO PUBLIC
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetEmployeeClinicTeam')
	BEGIN
		DROP  Procedure  rpc_GetEmployeeClinicTeam
	END

GO

CREATE Procedure dbo.rpc_GetEmployeeClinicTeam
(
	@DeptCode int
)

AS

SELECT 
TOP 1 Employee.*
FROM Employee
LEFT JOIN x_Dept_Employee ON Employee.employeeID = x_Dept_Employee.employeeID
WHERE IsMedicalTeam = 1
AND (@DeptCode = 0 OR @DeptCode = x_Dept_Employee.deptCode)
GO

GRANT EXEC ON rpc_GetEmployeeClinicTeam TO PUBLIC

GO

--**** Yaniv - rpc_GetUnitTypes ************************* 

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetUnitTypes')
	BEGIN
		DROP  Procedure  rpc_GetUnitTypes
	END

GO

CREATE Procedure dbo.rpc_GetUnitTypes
	
AS


SELECT UnitTypeCode
      ,UnitTypeName
      ,ShowInInternet
      ,AllowQueueOrder
      ,IsActive
      ,SubUnitTypeName as DefaultSubUnit
      ,CategoryName,
      'Related' = dbo.fun_GetSubUnitsNames(UnitTypeCode)
	FROM UnitType,DIC_DeptCategory,DIC_SubUnitTypes
	 where UnitType.CategoryID=DIC_DeptCategory.CategoryID
	 AND UnitType.DefaultSubUnitTypeCode=DIC_SubUnitTypes.subUnitTypeCode
GO

GRANT EXEC ON rpc_GetUnitTypes TO PUBLIC

GO


--**** End - rpc_GetUnitTypes *************************

