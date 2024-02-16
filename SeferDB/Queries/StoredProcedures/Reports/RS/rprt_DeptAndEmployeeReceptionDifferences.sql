IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_DeptAndEmployeeReceptionDifferences')
	BEGIN
		DROP  Procedure  dbo.rprt_DeptAndEmployeeReceptionDifferences
	END
GO


CREATE Procedure [dbo].[rprt_DeptAndEmployeeReceptionDifferences]
(
	@DistrictCodes varchar(max)=null,
	@AdminClinicCode varchar(max)=null,
	@ReceptionHoursSpan_cond varchar(max)=null,
	@EmployeeSector_cond varchar(max) = null,
	@AgreementType_cond varchar(max)=null,
	@IsExcelVersion varchar (2)=null,
	@ErrCode varchar(max) OUTPUT
)with recompile

AS

DECLARE @params nvarchar(max)
DECLARE @Declarations nvarchar(max)
DECLARE @Sql nvarchar(max)


SET @params = 
'	@xDistrictCodes varchar(max)= null,
	@xAdminClinicCode varchar(max)= null,
	@xReceptionHoursSpan_cond varchar(max) = null,
	@xEmployeeSector_cond varchar(max) = null,
	@xAgreementType_cond varchar(max) = null,
	@xIsExcelVersion varchar (2) = null '
	
SET @Declarations =
' DECLARE @xNewLineChar AS CHAR(2) 
  SET @xNewLineChar = CHAR(13) + CHAR(10)
  DECLARE @currentDate datetime SET @currentDate = GETDATE() 
  DECLARE @xReceptionHoursSpan int '
 
 IF (@ReceptionHoursSpan_cond is null OR @ReceptionHoursSpan_cond = '-1' OR ISDATE(@ReceptionHoursSpan_cond)= 0)
	SET @Declarations = @Declarations + ' SET @xReceptionHoursSpan = 24*60 '
 ELSE
	SET @Declarations = @Declarations + 
	' SET @xReceptionHoursSpan = datediff(minute,''00:00'', @xReceptionHoursSpan_cond) '
	
SET @Declarations = @Declarations + ' SET DATEFORMAT dmy '

SET @Sql = 
' SELECT distinct * FROM
 (SELECT 
 dDistrict.DeptName as DistrictName, dDistrict.deptCode as DeptCode,  
 dAdmin.DeptName as AdminClinicName, dAdmin.DeptCode as AdminClinicCode, 
 d.DeptName as ClinicName, 
 d.deptCode as ClinicCode, 
 deptSimul.Simul228 as Code228, 
 Employee.employeeID as employeeID, 
 Employee.firstName as EmployeeFirstName, 
 Employee.lastName as EmployeeLastName, 
 View_EmployeeSector.EmployeeSectorCode, -- for test
 View_EmployeeSector.EmployeeSectorDescription, -- for test
 DIC_ReceptionDays.ReceptionDayName as ReceptionDayName, 
 (SELECT stuff((	SELECT '' '' + cast(openingHour AS varchar(5)) + ''-'' + cast(closingHour AS varchar(5)) + ''; ''
					FROM DeptReception DR
					WHERE DR.deptCode = d.DeptCode
					AND DR.receptionDay = DeptReception.receptionDay
					AND DR.validFrom <= @currentDate
					AND (DR.validTo is null OR DR.validTo > @currentDate) 
					AND DR.ReceptionHoursTypeID = 1
					ORDER BY openingHour							
					for xml path('''')),1,1,''''
					)) AS deptReceptions,  
  (SELECT stuff((	SELECT '' '' + cast(openingHour AS varchar(5)) + ''-'' + cast(closingHour AS varchar(5)) + ''; ''
					FROM deptEmployeeReception DER
					WHERE DER.DeptEmployeeId = x_Dept_Employee.DeptEmployeeID
					AND DER.receptionDay = DeptReception.receptionDay
					AND DER.validFrom <= @currentDate 
					ORDER BY openingHour						
					for xml path('''')),1,1,''''
					)) AS DeptEmployeeReceptions, 
 Intervals.intervalsStr as nonIntersectedInterv, 
 Intervals.intervalsValues_str  as intervalsValues, 
 Intervals.intervalsSum_minu as intervalsSum

FROM dept  as d    
JOIN x_Dept_Employee on d.deptCode = x_Dept_Employee.deptCode 
	AND x_Dept_Employee.active = 1
	AND d.IsCommunity = 1 '
	
IF (@DistrictCodes <> '-1')
	SET @Sql = @Sql + 
	' AND (d.districtCode IN (SELECT IntField FROM dbo.SplitString(@xDistrictCodes))
							   or d.DeptCode IN (SELECT x_Dept_District.DeptCode FROM dbo.SplitString(@xDistrictCodes) as T
							   JOIN  x_Dept_District ON T.IntField = x_Dept_District.districtCode) ) '
IF (@AdminClinicCode <> '-1')
	SET @Sql = @Sql + 							   	
	' AND ( d.administrationCode IN (SELECT IntField FROM dbo.SplitString( @xAdminClinicCode)) ) '
IF (@AgreementType_cond <> '-1')
	SET @Sql = @Sql + 		
	' AND (x_Dept_Employee.AgreementType IN (SELECT IntField FROM dbo.SplitString( @xAgreementType_cond ))) '
	
SET @Sql = @Sql + 
' JOIN Employee on x_Dept_Employee.employeeID = Employee.employeeID
	AND Employee.active = 1 '
IF (@EmployeeSector_cond <> '-1')
	SET @Sql = @Sql + 		
	' AND (Employee.EmployeeSectorCode = @xEmployeeSector_cond) '
SET @Sql = @Sql + 	
'LEFT JOIN dept as dDistrict on d.districtCode = dDistrict.deptCode 
 LEFT JOIN dept as dAdmin on d.administrationCode = dAdmin.deptCode    
 LEFT JOIN deptSimul on d.DeptCode = deptSimul.DeptCode 
	
 JOIN View_EmployeeSector on Employee.EmployeeSectorCode = View_EmployeeSector.EmployeeSectorCode

 LEFT JOIN DeptReception on d.deptCode = DeptReception.deptCode
 JOIN DIC_ReceptionDays on DeptReception.receptionDay = DIC_ReceptionDays.ReceptionDayCode

 LEFT JOIN deptEmployeeReception  on x_Dept_Employee.DeptEmployeeID = deptEmployeeReception.DeptEmployeeID
	AND DeptReception.receptionDay = deptEmployeeReception.receptionDay

cross apply rfn_GetDeptAndEmployeeReceptionIntervalNonIntersection
		(d.deptCode, x_Dept_Employee.DeptEmployeeID, 
		 DeptReception.receptionDay, @xReceptionHoursSpan_cond, -1, @currentDate) as Intervals

) as resultTable
--WHERE DeptEmployeeReceptions is NOT null
order by DeptCode, ClinicCode, ReceptionDayName '

SET @Sql = @Sql + 'RETURN 
	SET DATEFORMAT mdy;'

SET @Sql = @Declarations + @Sql

--Exec rpc_HelperLongPrint @sql

exec sp_executesql @Sql, @params,

	@xDistrictCodes = @DistrictCodes,
	@xAdminClinicCode = @AdminClinicCode,
	@xReceptionHoursSpan_cond = @ReceptionHoursSpan_cond,
	@xEmployeeSector_cond = @EmployeeSector_cond,
	@xAgreementType_cond = @AgreementType_cond,
	@xIsExcelVersion = @IsExcelVersion

GO

GRANT EXEC ON [dbo].rprt_DeptAndEmployeeReceptionDifferences TO [clalit\webuser]
GO
