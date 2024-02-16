IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_DeptEmployeeAndPharmacyReceptionDifferences')
	BEGIN
		DROP  Procedure  dbo.rprt_DeptEmployeeAndPharmacyReceptionDifferences
	END
GO

CREATE Procedure [dbo].[rprt_DeptEmployeeAndPharmacyReceptionDifferences]
(
	@DistrictCodes varchar(max)=null,
	@AdminClinicCode varchar(max)=null,
	@ReceptionHoursSpan_cond varchar(max)=null,
	@EmployeeSector_cond varchar(max) = null,
	@IncludeSubClinicEmployees_cond varchar(2)=null,
	@AgreementType_cond varchar(max)=null,
	@IsExcelVersion varchar(2)=null,
	@ErrCode varchar(max) OUTPUT
--------------------------------------
)with recompile

AS
--------------------------------------
DECLARE @params nvarchar(max)
DECLARE @Declarations nvarchar(max)
DECLARE @Sql nvarchar(max)
DECLARE @NewLineChar AS CHAR(2) 
  SET @NewLineChar = CHAR(13) + CHAR(10)

SET @params = 
  ' @xDistrictCodes varchar(max)= null,
	@xAdminClinicCode varchar(max)= null,
	@xReceptionHoursSpan_cond varchar(max) = null,
	@xEmployeeSector_cond varchar(max) = null,
	@xAgreementType_cond varchar(max) = null,
	@xIsExcelVersion varchar(2) = null '

SET @Declarations =
'DECLARE @currentDate datetime SET @currentDate = GETDATE() 
 DECLARE @xReceptionHoursSpan int '
IF( @ReceptionHoursSpan_cond is null OR @ReceptionHoursSpan_cond = '-1' OR ISDATE(@ReceptionHoursSpan_cond)= 0) 
	SET @Declarations = @Declarations + ' SET @xReceptionHoursSpan = 24*60 '
ELSE
	SET @Declarations = @Declarations + ' SET @xReceptionHoursSpan = datediff(minute,''00:00'', @xReceptionHoursSpan_cond) '
	 
SET @Declarations = @Declarations + ' SET DATEFORMAT dmy '

SET @Sql = 
'SELECT distinct * FROM
(SELECT 
 dDistrict.DeptName AS DistrictName , isNull(dDistrict.deptCode , -1) AS DeptCode 
,dAdmin.DeptName AS AdminClinicName , isNull(dAdmin.DeptCode , -1) AS AdminClinicCode
				 
,d.DeptName AS ClinicName 
,d.deptCode AS ClinicCode 
,deptSimul.Simul228 AS Code228 
,d.typeUnitCode AS ClinicUnitTypeCode
,d.subAdministrationCode AS ClinicSubAdminCode

,SubClinics.DeptName AS SubClinicName 
,SubClinics.deptCode AS SubClinicCode 
,SubClinicDeptSimul.Simul228 AS SubClinicCode228 
,SubClinicUnitType.UnitTypeCode AS SubClinicUnitTypeCode -- for tes
,SubClinicUnitType.UnitTypeName AS SubClinicUnitTypeName -- for tes
,SubClinics.subAdministrationCode AS SubClinicSubAdminCode 

,Employee.employeeID AS employeeID
,Employee.firstName AS EmployeeFirstName 
,Employee.lastName AS EmployeeLastName
,View_EmployeeSector.EmployeeSectorCode -- for test
,View_EmployeeSector.EmployeeSectorDescription -- for test

,DIC_ReceptionDays.ReceptionDayName AS ReceptionDayName

,(SELECT stuff((	SELECT cast(openingHour AS varchar(5)) + ''-'' + cast(closingHour AS varchar(5)) + ''; ''
					FROM DeptReception DR
					WHERE DR.deptCode = SubClinics.DeptCode
					AND DR.receptionDay = SubClinicDeptReception.receptionDay
					AND DR.validFrom <= @currentDate 
					AND DR.ReceptionHoursTypeID = 1
					ORDER BY openingHour							
					for xml path('''')),1,0,''''
					)) AS subDeptReceptions
,(SELECT stuff((	SELECT cast(openingHour AS varchar(5)) + ''-'' + cast(closingHour AS varchar(5)) + ''; ''
					FROM deptEmployeeReception DER
					WHERE DER.DeptEmployeeId = x_Dept_Employee.DeptEmployeeID
					AND DER.receptionDay = SubClinicDeptReception.receptionDay
					AND DER.validFrom <= @currentDate 
					ORDER BY openingHour						
					for xml path('''')),1,0,''''
					)) AS DeptEmployeeReceptions 
,Intervals.intervalsStr AS nonIntersectedInterv	
,Intervals.intervalsValues_str AS intervalsValues
,Intervals.intervalsSum_minu AS intervalsSum

FROM x_Dept_Employee 
JOIN dept  AS d  ON x_Dept_Employee.deptCode = d.deptCode 
	AND x_Dept_Employee.active = 1
	AND d.status = 1 '
IF(	@DistrictCodes <> '-1')
	SET @Sql = @Sql + 
	' AND (d.districtCode IN (SELECT IntField FROM dbo.SplitString(@xDistrictCodes))
							   OR d.DeptCode IN (SELECT x_Dept_District.DeptCode FROM dbo.SplitString(@xDistrictCodes) AS T
							   JOIN x_Dept_District ON T.IntField = x_Dept_District.districtCode) ) '
IF(	@AdminClinicCode <> '-1')
	SET @Sql = @Sql + 							   
	' AND (d.administrationCode IN (SELECT IntField FROM dbo.SplitString( @xAdminClinicCode )) ) '
IF(	@AgreementType_cond <> '-1')
	SET @Sql = @Sql + 		
	' AND (x_Dept_Employee.AgreementType IN (SELECT IntField FROM dbo.SplitString( @xAgreementType_cond ))) '
SET @Sql = @Sql + 
'JOIN dept AS SubClinics ON 
	SubClinics.typeUnitCode  = 401 /* pharmacy */
	AND SubClinics.status = 1 '
IF(	@IncludeSubClinicEmployees_cond = '1')
	SET @Sql = @Sql + 		
	' AND (d.deptCode = SubClinics.subAdministrationCode /* dept is parent of pharmacy */
		OR d.subAdministrationCode = SubClinics.subAdministrationCode) /* dept is brother of pharmacy */ ' + @NewLineChar
ELSE
	SET @Sql = @Sql + 	
	' AND d.deptCode = SubClinics.subAdministrationCode /* dept is parent of pharmacy */ ' 
 
SET @Sql = @Sql + @NewLineChar + 			
' JOIN Employee ON x_Dept_Employee.employeeID = Employee.employeeID
	AND Employee.active = 1 '
IF(	@EmployeeSector_cond <> '-1')
	SET @Sql = @Sql + @NewLineChar +
	' AND Employee.EmployeeSectorCode = @xEmployeeSector_cond '
SET @Sql = @Sql + @NewLineChar +	
' JOIN deptEmployeeReception ON x_Dept_Employee.DeptEmployeeID = deptEmployeeReception.DeptEmployeeID
LEFT JOIN DeptReception AS SubClinicDeptReception ON SubClinics.deptCode = SubClinicDeptReception.deptCode
JOIN DIC_ReceptionDays ON SubClinicDeptReception.receptionDay = DIC_ReceptionDays.ReceptionDayCode
	AND SubClinicDeptReception.receptionDay = deptEmployeeReception.receptionDay
	
INNER JOIN View_EmployeeSector ON Employee.EmployeeSectorCode = View_EmployeeSector.EmployeeSectorCode
		
LEFT JOIN dept AS dDistrict ON d.districtCode = dDistrict.deptCode 
LEFT JOIN dept AS dAdmin ON d.administrationCode = dAdmin.deptCode    
LEFT JOIN deptSimul ON d.DeptCode = deptSimul.DeptCode 	

LEFT JOIN View_UnitType AS SubClinicUnitType ON SubClinics.typeUnitCode = SubClinicUnitType.UnitTypeCode  
LEFT JOIN deptSimul AS SubClinicDeptSimul ON SubClinics.DeptCode = SubClinicDeptSimul.DeptCode 

cross apply rfn_GetDeptAndEmployeeReceptionIntervalNonIntersection
		(SubClinics.deptCode, x_Dept_Employee.DeptEmployeeID, 
		 SubClinicDeptReception.receptionDay, @xReceptionHoursSpan_cond, -1, @currentDate) AS Intervals

) AS resultTable
order by DeptCode, SubClinicCode, ClinicCode, employeeID, ReceptionDayName '

SET @Sql = @Sql + ' RETURN 
	SET DATEFORMAT mdy; '

SET @Sql = @Declarations + @Sql

-- Exec rpc_HelperLongPrint @sql

exec sp_executesql @Sql, @params,

	@xDistrictCodes = @DistrictCodes,
	@xAdminClinicCode = @AdminClinicCode,
	@xReceptionHoursSpan_cond = @ReceptionHoursSpan_cond,
	@xEmployeeSector_cond = @EmployeeSector_cond,
	@xAgreementType_cond = @AgreementType_cond,
	@xIsExcelVersion = @IsExcelVersion

GO

GRANT EXEC ON [dbo].rprt_DeptEmployeeAndPharmacyReceptionDifferences TO PUBLIC
GO
