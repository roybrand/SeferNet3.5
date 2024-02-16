IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rprt_DeptOfficeAndDeptEmployeeReceptionDifferences')
	BEGIN
		DROP  Procedure  dbo.rprt_DeptOfficeAndDeptEmployeeReceptionDifferences
	END
GO

CREATE Procedure dbo.rprt_DeptOfficeAndDeptEmployeeReceptionDifferences
(
	@DistrictCodes varchar(max) = null,
	@AdminClinicCode varchar(max) = null,
	@ReceptionHoursSpan_cond varchar(max) = null,
	@EmployeeSector_cond varchar(max) = null,
	@IncludeSubClinicEmployees_cond varchar(2) = null,
	@IsExcelVersion varchar(2) = null,
	@ErrCode varchar(max) OUTPUT
-----------------------------------------
)with recompile

AS
--------------------------------------
DECLARE @params nvarchar(max)
DECLARE @Declarations nvarchar(max)
DECLARE @Sql nvarchar(max)
DECLARE @Where nvarchar(max)
DECLARE @SqlEnd nvarchar(max)

SET @params = 
'	@xDistrictCodes varchar(max)= null,
	@xAdminClinicCode varchar(max)= null,
	@xReceptionHoursSpan_cond varchar(max) = null,
	@xEmployeeSector_cond varchar(max) = null,
	@xIncludeSubClinicEmployees_cond varchar(2)=null,
	@xIsExcelVersion varchar (2) = null '
SET @Declarations =
  ' DECLARE @currentDate datetime SET @currentDate = GETDATE() 
	DECLARE @xReceptionHoursSpan int 
	DECLARE @ServiceDescription varchar(100)
	DECLARE @ServiceCode int  
	SET @ServiceDescription = (select ReceptionTypeDescription from DIC_ReceptionHoursTypes where ReceptionHoursTypeID = 2)
	SET @ServiceCode = (select ReceptionHoursTypeID from DIC_ReceptionHoursTypes where ReceptionHoursTypeID = 2)
	'
	
DECLARE @NewLineChar AS CHAR(2) 
SET @NewLineChar = CHAR(13) + CHAR(10)

IF (@ReceptionHoursSpan_cond is null OR @ReceptionHoursSpan_cond = '-1' OR ISDATE(@ReceptionHoursSpan_cond)= 0)
	SET @Declarations = @Declarations + ' SET @xReceptionHoursSpan = 24*60 '
ELSE
	SET @Declarations = @Declarations + 
	' SET @xReceptionHoursSpan = datediff(minute,''00:00'', @xReceptionHoursSpan_cond) '
		
SET @Declarations = @Declarations + @NewLineChar + ' SET DATEFORMAT dmy ' 

SET @Sql =
'SELECT distinct * from
(select 
 dDistrict.DeptName as DistrictName 
, dDistrict.deptCode as DeptCode 
, dAdmin.DeptName as AdminClinicName 
, dAdmin.DeptCode as AdminClinicCode
				 
,d.DeptCode as ServiceDeptCode 
,x_Dept_Employee.DeptCode as EmployeeDeptCode 

,@ServiceDescription as ServiceDescription 
,@ServiceCode as ServiceCode 

,Employee.employeeID as employeeID
,Employee.firstName as EmployeeFirstName 
,Employee.lastName as EmployeeLastName 
,View_EmployeeSector.EmployeeSectorCode -- for test
,View_EmployeeSector.EmployeeSectorDescription -- for test

,DIC_ReceptionDays.ReceptionDayName as ReceptionDayName

,(SELECT stuff((	SELECT  cast(openingHour AS varchar(5)) + ''-'' + cast(closingHour AS varchar(5)) + ''; ''
					FROM DeptReception DR
					WHERE DR.deptCode = d.DeptCode
					AND DR.receptionDay = DIC_ReceptionDays.ReceptionDayCode
					AND DR.validFrom <= @currentDate 
					AND DR.ReceptionHoursTypeID = 2
					ORDER BY openingHour							
					for xml path('''')),1,1,''''
					)) AS DeptServiceReceptions 	 
	 
,(SELECT stuff((	SELECT cast(openingHour AS varchar(5)) + ''-'' + cast(closingHour AS varchar(5)) + ''; ''
					FROM deptEmployeeReception DER
					WHERE DER.DeptEmployeeId = x_Dept_Employee.DeptEmployeeID
					AND DER.receptionDay = deptEmployeeReception.receptionDay
					AND DER.validFrom <= @currentDate 
					ORDER BY openingHour						
					for xml path('''')),1,1,''''
					)) AS DeptEmployeeReceptions 

,Intervals.intervalsStr as nonIntersectedInterv	
,Intervals.intervalsValues_str  as intervalsValues
,Intervals.intervalsSum_minu as intervalsSum

---------------------------------
from dept  as d
left join dept as chieldDept on d.deptCode = chieldDept.subAdministrationCode   
join dept as d1 on d.deptCode = d1.deptCode
	and d.IsCommunity = 1 
	and d.status = 1 '
IF(	@DistrictCodes <> '-1' )
SET @Sql = @Sql + @NewLineChar +
	'AND (d.districtCode IN (SELECT IntField FROM dbo.SplitString(@xDistrictCodes))
			or d.DeptCode IN (SELECT x_Dept_District.DeptCode FROM dbo.SplitString(@xDistrictCodes) as T
							   JOIN x_Dept_District ON T.IntField = x_Dept_District.districtCode) ) '
IF(	@AdminClinicCode <> '-1' )
SET @Sql = @Sql + @NewLineChar +							   
	'AND (d.administrationCode IN (SELECT IntField FROM dbo.SplitString( @xAdminClinicCode)) ) '
SET @Sql = @Sql + @NewLineChar +	
	
'join x_Dept_Employee on '
IF(@IncludeSubClinicEmployees_cond = '1')
	SET @Sql = @Sql + @NewLineChar +
	' x_Dept_Employee.deptCode = d.deptCode
		or x_Dept_Employee.deptCode = chieldDept.deptCode '
ELSE
	SET @Sql = @Sql + @NewLineChar + 
	' x_Dept_Employee.deptCode = d.deptCode '

SET @Sql = @Sql + @NewLineChar +
' and x_Dept_Employee.active = 1

join Employee on x_Dept_Employee.employeeID = Employee.employeeID
	and Employee.active = 1 '
IF(@EmployeeSector_cond <> '-1')
	SET @Sql = @Sql + @NewLineChar +	
	' and Employee.EmployeeSectorCode = @xEmployeeSector_cond '
	
SET @Sql = @Sql + @NewLineChar +
' JOIN View_EmployeeSector on Employee.EmployeeSectorCode = View_EmployeeSector.EmployeeSectorCode
------------------
left join dept as dDistrict on d.districtCode = dDistrict.deptCode 
left join dept as dAdmin on d.administrationCode = dAdmin.deptCode    
left join deptSimul on d.DeptCode = deptSimul.DeptCode 	

join deptEmployeeReception on x_Dept_Employee.DeptEmployeeID = deptEmployeeReception.DeptEmployeeID

JOIN DIC_ReceptionDays on deptEmployeeReception.receptionDay = DIC_ReceptionDays.ReceptionDayCode

cross apply rfn_GetDepServicetAndDeptEmployeeReceptionIntervalNonIntersection
	(d.deptCode, x_Dept_Employee.DeptEmployeeID, 
	deptEmployeeReception.receptionDay, @xReceptionHoursSpan_cond) as Intervals

) as resultTable
order by DeptCode, ServiceDeptCode, EmployeeDeptCode,  ReceptionDayName 

SET DATEFORMAT mdy; 

RETURN '

SET @Sql = @Declarations + @Sql --+ @Where + @SqlEnd

--Exec rpc_HelperLongPrint @sql

exec sp_executesql @Sql, @params,
	@xDistrictCodes = @DistrictCodes,
	@xAdminClinicCode = @AdminClinicCode,
	@xReceptionHoursSpan_cond = @ReceptionHoursSpan_cond,
	@xEmployeeSector_cond = @EmployeeSector_cond,
	@xIncludeSubClinicEmployees_cond = @IncludeSubClinicEmployees_cond,
	@xIsExcelVersion = @IsExcelVersion

GO

GRANT EXEC ON [dbo].rprt_DeptOfficeAndDeptEmployeeReceptionDifferences TO PUBLIC
GO
