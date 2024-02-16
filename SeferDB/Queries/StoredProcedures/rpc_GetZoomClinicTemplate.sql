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
DECLARE @CurrentDate date

SET @LastUpdateDateOfDept = (SELECT updateDate FROM dept WHERE deptCode = @DeptCode)
SET @LastUpdateDateOfRemarks = IsNull((SELECT MAX(updateDate) FROM View_Remarks WHERE deptCode = @deptCode), '01/01/1900')
SET @CurrentDate = GETDATE()


IF(@LastUpdateDateOfDept < @LastUpdateDateOfRemarks)
	BEGIN
		SET @LastUpdateDateOfDept = @LastUpdateDateOfRemarks --as 'LastUpdateDateOfDept'
	END

DECLARE 
@DisplaySunday varchar(20) = CASE (SELECT Display FROM DIC_ReceptionDays WHERE ReceptionDayCode = 1) 
		WHEN 1 THEN '' ELSE 'display:none' END 
,@DisplayMonday varchar(20) = CASE (SELECT Display FROM DIC_ReceptionDays WHERE ReceptionDayCode = 2) 
		WHEN 1 THEN '' ELSE 'display:none' END 
,@DisplayTuesday varchar(20) = CASE (SELECT Display FROM DIC_ReceptionDays WHERE ReceptionDayCode = 3) 
		WHEN 1 THEN '' ELSE 'display:none' END
,@DisplayWednesday varchar(20) = CASE (SELECT Display FROM DIC_ReceptionDays WHERE ReceptionDayCode = 4) 
		WHEN 1 THEN '' ELSE 'display:none' END		
,@DisplayThursday varchar(20) = CASE (SELECT Display FROM DIC_ReceptionDays WHERE ReceptionDayCode = 5) 
		WHEN 1 THEN '' ELSE 'display:none' END					
,@DisplayFriday varchar(20) = CASE (SELECT Display FROM DIC_ReceptionDays WHERE ReceptionDayCode = 6) 
		WHEN 1 THEN '' ELSE 'display:none' END	
,@DisplaySaturday varchar(20) = CASE (SELECT Display FROM DIC_ReceptionDays WHERE ReceptionDayCode = 7) 
		WHEN 1 THEN '' ELSE 'display:none' END	
,@DisplayHolHamoeed varchar(20) = CASE (SELECT Display FROM DIC_ReceptionDays WHERE ReceptionDayCode = 8) 
		WHEN 1 THEN '' ELSE 'display:none' END			
,@DisplayHolidayEvening varchar(20) = CASE (SELECT Display FROM DIC_ReceptionDays WHERE ReceptionDayCode = 9) 
		WHEN 1 THEN '' ELSE 'display:none' END	
,@DisplayHoliday varchar(20) = CASE (SELECT Display FROM DIC_ReceptionDays WHERE ReceptionDayCode = 10) 
		WHEN 1 THEN '' ELSE 'display:none' END	
,@DisplayRamadan varchar(20) = CASE (SELECT Display FROM DIC_ReceptionDays WHERE ReceptionDayCode = 11) 
		WHEN 1 THEN '' ELSE 'display:none' END			
,@DisplayOptionalHoliday varchar(20) = CASE (SELECT Display FROM DIC_ReceptionDays WHERE ReceptionDayCode = 12) 
		WHEN 1 THEN '' ELSE 'display:none' END			
,@DisplayStrike varchar(20) = CASE (SELECT Display FROM DIC_ReceptionDays WHERE ReceptionDayCode = 13) 
		WHEN 1 THEN '' ELSE 'display:none' END	
DECLARE 		
@DisplaySundayDoc varchar(20) =	  CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode = @DeptCode AND v.receptionDay = 1) > 0 
 THEN '' ELSE 'display:none' END
,@DisplayMondayDoc varchar(20) =  CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode = @DeptCode AND v.receptionDay = 2) > 0 
  THEN '' ELSE 'display:none' END	  
,@DisplayTuesdayDoc varchar(20) = CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode = @DeptCode AND v.receptionDay = 3) > 0 
 THEN '' ELSE 'display:none' END	  
,@DisplayWednesdayDoc varchar(20) = CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode = @DeptCode AND v.receptionDay = 4) > 0 
 THEN '' ELSE 'display:none' END	  
,@DisplayThursdayDoc varchar(20) = CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode = @DeptCode AND v.receptionDay = 5) > 0 
THEN '' ELSE 'display:none' END	
,@DisplayFridayDoc varchar(20) = CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode = @DeptCode AND v.receptionDay = 6) > 0 
THEN '' ELSE 'display:none' END	
,@DisplaySaturdayDoc varchar(20) = CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode = @DeptCode AND v.receptionDay = 7) > 0 
THEN '' ELSE 'display:none' END	
,@DisplayHolHamoeedDoc varchar(20) = CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode = @DeptCode AND v.receptionDay = 8) > 0 
THEN '' ELSE 'display:none' END
,@DisplayHolidayEveningDoc varchar(20) = CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode = @DeptCode AND v.receptionDay = 9) > 0 
THEN '' ELSE 'display:none' END	
,@DisplayHolidayDoc varchar(20) = CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode = @DeptCode AND v.receptionDay = 10) > 0 
THEN '' ELSE 'display:none' END	
,@DisplayRamadanDoc varchar(20) = CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode = @DeptCode AND v.receptionDay = 11) > 0 
THEN '' ELSE 'display:none' END	
,@DisplayOptionalHolidayDoc varchar(20) = CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode = @DeptCode AND v.receptionDay = 12) > 0 
THEN '' ELSE 'display:none' END	
,@DisplayStrikeDoc varchar(20) = CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode = @DeptCode AND v.receptionDay = 13) > 0 
THEN '' ELSE 'display:none' END			

DECLARE @DocColspan varchar(2) =
	CASE @DisplaySundayDoc WHEN '' THEN 1 ELSE 0 END +
	CASE @DisplayMondayDoc WHEN '' THEN 1 ELSE 0 END +	
	CASE @DisplayWednesdayDoc WHEN '' THEN 1 ELSE 0 END +
	CASE @DisplayTuesdayDoc WHEN '' THEN 1 ELSE 0 END +		
	CASE @DisplayThursdayDoc WHEN '' THEN 1 ELSE 0 END +	
	CASE @DisplayFridayDoc WHEN '' THEN 1 ELSE 0 END +		
	CASE @DisplaySaturdayDoc WHEN '' THEN 1 ELSE 0 END +		
	CASE @DisplayHolHamoeedDoc WHEN '' THEN 1 ELSE 0 END +		
	CASE @DisplayHolidayEveningDoc WHEN '' THEN 1 ELSE 0 END +	
	CASE @DisplayHolidayDoc WHEN '' THEN 1 ELSE 0 END +		
	CASE @DisplayRamadanDoc WHEN '' THEN 1 ELSE 0 END +		
	CASE @DisplayOptionalHolidayDoc WHEN '' THEN 1 ELSE 0 END +		
	CASE @DisplayStrikeDoc WHEN '' THEN 1 ELSE 0 END
	+ 3 --columns for ServiceDescriptions, EmployeeName, QueueOrderDescriptions	


DECLARE @CellWidthForHours varchar(5) = CAST(100/(SELECT COUNT(*) FROM DIC_ReceptionDays WHERE Display = 1) as varchar(5))

DECLARE @CellWidthForDocHours varchar(5) = CAST(70/(SELECT COUNT(*) FROM DIC_ReceptionDays WHERE Display = 1) as varchar(5)) 


--*****  deptDetails  *****
SELECT 
deptCode,
deptName,
UnitTypeName,
ISNULL(subUnitTypeName,'&nbsp;') as subUnitTypeName,
managerName + '&nbsp;' as managerName, 
administrativeManagerName + '&nbsp;' as administrativeManagerName,
geriatricsManagerName + '&nbsp;' as geriatricsManagerName,
pharmacologyManagerName + '&nbsp;' as pharmacologyManagerName,
districtName,
cityName,
addressComment + '&nbsp;' as addressComment,
CASE WHEN @IsInternal = 0 AND showEmailInInternet = 0 THEN '&nbsp;' ELSE email + '&nbsp;' END as email, 
'phones' = REPLACE(phones,',','<br />'),
'faxes' = '&nbsp;' + REPLACE(faxes,',','<br />'),
simpleAddress,
parking,
PopulationSectorDescription,
statusDescription,
transportation,
AdministrationName,
subAdministrationName,
deputyHeadOfDepartment,
secretaryName,
ISNULL(CAST(Simul228 as varchar(7)), '&nbsp;') as Simul228,
deptLevelDescription,
handicappedFacilities
,@LastUpdateDateOfDept as 'LastUpdateDate'
, deptCode as 'ID'
,0 as 'ParentCode'
,CASE @IsInternal WHEN 1 THEN 'display:none' ELSE '' END as ShowOuterHeader
,CASE @IsInternal WHEN 0 THEN 'display:none' ELSE '' END as ShowInnerHeader
,CASE IsHospital WHEN 1 THEN 'display:none' ELSE '' END as ShowWithNonHospital
,CASE IsHospital WHEN 0 THEN 'display:none' ELSE '' END as ShowWithHospital
 FROM vAllDeptDetails 
 WHERE DeptCode = @DeptCode
 
--******  deptRemarks  ********
SELECT remarkID,
RemarkText = dbo.rfn_GetFotmatedRemark(RemarkText),
CASE WHEN validTo is null OR  validTo > '9999-01-01' THEN '' ELSE 'תוקף ' + CONVERT(varchar(12),validTo,  103) END + '&nbsp;' as  validTo,
displayInInternet, 
RemarkDeptCode as deptCode,
ShowOrder
, remarkID as 'ID'
, RemarkDeptCode as 'ParentCode'
FROM View_DeptRemarks
WHERE deptCode = @deptCode
AND (@IsInternal = 1 OR displayInInternet = 1)
AND (validFrom is null OR validFrom <= @CurrentDate)
AND (validTo is null OR validTo >= @CurrentDate)
ORDER BY IsSharedRemark desc ,ShowOrder asc  
 
--****** deptReceptionHours  ********

SELECT Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, HolHamoeed, HolidayEvening, Holiday, Ramadan, OptionalHoliday, Strike,
 ReceptionHoursTypeID, ReceptionTypeDescription,
 DisplaySunday, DisplayMonday, DisplayTuesday, DisplayWednesday, DisplayThursday, DisplayFriday, DisplaySaturday
 ,CASE WHEN (HolHamoeed = '&nbsp;' OR @DisplayHolHamoeed <> '') THEN 'display:none' ELSE '' END as 'DisplayHolHamoeed'  
 ,CASE WHEN (HolidayEvening = '&nbsp;' OR @DisplayHolidayEvening <> '') THEN 'display:none' ELSE '' END as 'DisplayHolidayEvening'
 ,CASE WHEN (Holiday = '&nbsp;' OR @DisplayHoliday <> '') THEN 'display:none' ELSE '' END as 'DisplayHoliday' 
 ,CASE WHEN (Ramadan = '&nbsp;' OR @DisplayRamadan <> '') THEN 'display:none' ELSE '' END as 'DisplayRamadan'  
 ,CASE WHEN (OptionalHoliday = '&nbsp;' OR @DisplayOptionalHoliday <> '') THEN 'display:none' ELSE '' END as 'DisplayOptionalHoliday'
 ,CASE WHEN (Strike = '&nbsp;' OR @DisplayStrike <> '') THEN 'display:none' ELSE '' END as 'DisplayStrike'
 ,CellWidth, ID, ParentCode   
 
FROM
(
SELECT 
 dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 1, ReceptionHoursTypeID ) + '&nbsp;' as Sunday
,dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 2, ReceptionHoursTypeID ) + '&nbsp;' as Monday
,dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 3, ReceptionHoursTypeID ) + '&nbsp;' as Tuesday
,dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 4, ReceptionHoursTypeID ) + '&nbsp;' as Wednesday
,dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 5, ReceptionHoursTypeID ) + '&nbsp;' as Thursday
,dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 6, ReceptionHoursTypeID ) + '&nbsp;' as Friday
,dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 7, ReceptionHoursTypeID ) + '&nbsp;' as Saturday
,dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 8, ReceptionHoursTypeID ) + '&nbsp;' as HolHamoeed
,dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 9, ReceptionHoursTypeID ) + '&nbsp;' as HolidayEvening
,dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 10, ReceptionHoursTypeID ) + '&nbsp;' as Holiday
,dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 11, ReceptionHoursTypeID ) + '&nbsp;' as Ramadan
,dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 12, ReceptionHoursTypeID ) + '&nbsp;' as OptionalHoliday
,dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 13, ReceptionHoursTypeID ) + '&nbsp;' as Strike
,ReceptionHoursTypeID, ReceptionTypeDescription
,@DisplaySunday as 'DisplaySunday'
,@DisplayMonday as 'DisplayMonday'
,@DisplayTuesday as 'DisplayTuesday'
,@DisplayWednesday as 'DisplayWednesday'
,@DisplayThursday as 'DisplayThursday'
,@DisplayFriday as 'DisplayFriday'
,@DisplaySaturday as 'DisplaySaturday'
,@DisplayHolHamoeed as 'DisplayHolHamoeed'
,@DisplayHolidayEvening as 'DisplayHolidayEvening'
,@DisplayHoliday as 'DisplayHoliday'
,@DisplayRamadan as 'DisplayRamadan'
,@DisplayOptionalHoliday as 'DisplayOptionalHoliday'
,@DisplayStrike as 'DisplayStrike'
,@CellWidthForHours as 'CellWidth'
 , 0 as ID, DeptCode as ParentCode
 
FROM
(SELECT DISTINCT TOP 100 percent DeptCode, ReceptionHoursTypeID, ReceptionTypeDescription
  FROM [dbo].[vDeptReceptionHours]
  WHERE DeptCode = @DeptCode
  order by  DeptCode, ReceptionHoursTypeID  
  ) T   ) TT

--****** employeeSectors  ********
SELECT DISTINCT es.EmployeeSectorCode, EmployeeSectorDescriptionForCaption as EmployeeSectorDescription
,es.EmployeeSectorCode as 'ID', @DeptCode as ParentCode, es.OrderToShow
FROM EmployeeSector es
JOIN Employee e on es.EmployeeSectorCode = e.EmployeeSectorCode
JOIN x_Dept_Employee xde on e.employeeID = xde.employeeID
JOIN x_Dept_Employee_Service xdes on xde.DeptEmployeeID = xdes.DeptEmployeeID
WHERE e.IsMedicalTeam = 0
AND xde.deptCode = @DeptCode
AND xde.active = 1
ORDER BY OrderToShow

--******  employeeServices  ********
SELECT [deptCode]
      ,[EmployeeRemark]
      , CAST(CAST(EmployeeID as varchar(10)) + CAST(ServiceCode as varchar(7)) as bigint) as 'employeeID'
      ,[EmployeeName]
      ,[Experties] = '<br/>' + CASE [Experties] WHEN '' THEN '' ELSE CASE WHEN IsVirtualDoctor = 1 THEN 'מומחה' ELSE [Experties] END END
      ,[ProfessionDescriptions]
	  ,ServiceDescriptions = 
			REPLACE( [ProfessionDescriptions] + CASE WHEN LEN([ProfessionDescriptions]) > 0 AND LEN([ServiceDescriptions]) > 0 THEN ', ' ELSE '' END + [ServiceDescriptions], ';', ',')
      ,[QueueOrderDescriptions]
      ,[HTMLRemarks]
      ,[EmployeeSectorCode]
	  ,Phones
	  ,[dbo].[rfn_GetEmployeeServiceReceptionsWithRemarkString](DeptCode, EmployeeID, 1, ServiceCode) + '&nbsp;' as Sunday
	  ,[dbo].[rfn_GetEmployeeServiceReceptionsWithRemarkString](DeptCode, EmployeeID, 2, ServiceCode) + '&nbsp;' as Monday	  
	  ,[dbo].[rfn_GetEmployeeServiceReceptionsWithRemarkString](DeptCode, EmployeeID, 3, ServiceCode) + '&nbsp;' as Tuesday	  
	  ,[dbo].[rfn_GetEmployeeServiceReceptionsWithRemarkString](DeptCode, EmployeeID, 4, ServiceCode) + '&nbsp;' as Wednesday	  
	  ,[dbo].[rfn_GetEmployeeServiceReceptionsWithRemarkString](DeptCode, EmployeeID, 5, ServiceCode) + '&nbsp;' as Thursday	  
	  ,[dbo].[rfn_GetEmployeeServiceReceptionsWithRemarkString](DeptCode, EmployeeID, 6, ServiceCode) + '&nbsp;' as Friday	  
	  ,[dbo].[rfn_GetEmployeeServiceReceptionsWithRemarkString](DeptCode, EmployeeID, 7, ServiceCode) + '&nbsp;' as Saturday	  
	  ,[dbo].[rfn_GetEmployeeServiceReceptionsWithRemarkString](DeptCode, EmployeeID, 8, ServiceCode) + '&nbsp;' as HolHamoeed
	  ,[dbo].[rfn_GetEmployeeServiceReceptionsWithRemarkString](DeptCode, EmployeeID, 9, ServiceCode) + '&nbsp;' as HolidayEvening	  
	  ,[dbo].[rfn_GetEmployeeServiceReceptionsWithRemarkString](DeptCode, EmployeeID, 10, ServiceCode) + '&nbsp;' as Holiday	  
	  ,[dbo].[rfn_GetEmployeeServiceReceptionsWithRemarkString](DeptCode, EmployeeID, 11, ServiceCode) + '&nbsp;' as Ramadan	 
	  ,[dbo].[rfn_GetEmployeeServiceReceptionsWithRemarkString](DeptCode, EmployeeID, 12, ServiceCode) + '&nbsp;' as OptionalHoliday	 
	  ,[dbo].[rfn_GetEmployeeServiceReceptionsWithRemarkString](DeptCode, EmployeeID, 13, ServiceCode) + '&nbsp;' as Strike
	  ,CASE Phones WHEN	'' THEN 'display:none' ELSE '' END as DisplayPhones
  
	  ,CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours WHERE deptCode = @DeptCode AND receptionDay = 1 AND IsMedicalTeam = 0) > 0 
	  THEN '' ELSE 'display:none' END as DisplaySunday
	  ,CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode = @DeptCode AND v.receptionDay = 2 AND IsMedicalTeam = 0) > 0 
	  THEN '' ELSE 'display:none' END as DisplayMonday	  
	  ,CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode = @DeptCode AND v.receptionDay = 3 AND IsMedicalTeam = 0) > 0 
	  THEN '' ELSE 'display:none' END as DisplayTuesday	  
	  ,CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode = @DeptCode AND v.receptionDay = 4 AND IsMedicalTeam = 0) > 0 
	  THEN '' ELSE 'display:none' END as DisplayWednesday	  
	  ,CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode = @DeptCode AND v.receptionDay = 5 AND IsMedicalTeam = 0) > 0 
	  THEN '' ELSE 'display:none' END as DisplayThursday	
	  ,CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode = @DeptCode AND v.receptionDay = 6 AND IsMedicalTeam = 0) > 0 
	  THEN '' ELSE 'display:none' END as DisplayFriday	
	  ,CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode = @DeptCode AND v.receptionDay = 7 AND IsMedicalTeam = 0) > 0 
	  THEN '' ELSE 'display:none' END as DisplaySaturday	
	  ,CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode = @DeptCode AND v.receptionDay = 8 AND IsMedicalTeam = 0) > 0 
	  THEN '' ELSE 'display:none' END as DisplayHolHamoeed
	  ,CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode = @DeptCode AND v.receptionDay = 9 AND IsMedicalTeam = 0) > 0 
	  THEN '' ELSE 'display:none' END as DisplayHolidayEvening	
	  ,CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode = @DeptCode AND v.receptionDay = 10 AND IsMedicalTeam = 0) > 0 
	  THEN '' ELSE 'display:none' END as DisplayHoliday	
	  ,CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode = @DeptCode AND v.receptionDay = 11 AND IsMedicalTeam = 0) > 0 
	  THEN '' ELSE 'display:none' END as DisplayRamadan	
	  ,CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode = @DeptCode AND v.receptionDay = 12 AND IsMedicalTeam = 0) > 0 
	  THEN '' ELSE 'display:none' END as DisplayOptionalHoliday	
	  ,CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode = @DeptCode AND v.receptionDay = 13 AND IsMedicalTeam = 0) > 0 
	  THEN '' ELSE 'display:none' END as DisplayStrike		  
	  ,@DocColspan as DocColspan
      , CAST(CAST(EmployeeID as varchar(10)) + CAST(ServiceCode as varchar(7)) as bigint) as 'ID'
	  ,EmployeeSectorCode as 'ParentCode'
	  
  FROM [dbo].[vEmployeeProfessionalDetails_perService]
  WHERE DeptCode = @DeptCode
  and IsMedicalTeam = 0 
  ORDER BY orderNumber, ProfessionDescriptions	

--******  employeeRemarks  ********
SELECT [EmployeeRemarkID]
      ,[DicRemarkID]
      ,[RemarkText] = dbo.rfn_GetFotmatedRemark([vEmployeeDeptRemarks].RemarkText)
      ,[displayInInternet]
      ,[AttributedToAllClinics]
      ,[ValidFrom]
      ,CASE WHEN (ValidTo is null OR ValidTo > '2050-01-01') THEN '&nbsp;'
       ELSE 'תוקף ' + CONVERT(varchar(12),ValidTo,  103) END + '&nbsp;' as ValidTo
      ,[vEmployeeDeptRemarks].[DeptCode]
      ,[vEmployeeDeptRemarks].EmployeeSectorCode
      ,CAST(CAST(vEmployeeDeptRemarks.EmployeeID as varchar(10)) + CAST(xDES.ServiceCode as varchar(7)) as bigint) as 'ParentCode' 
      ,0 as 'ID'
  FROM [dbo].[vEmployeeDeptRemarks]
  JOIN x_Dept_Employee xDE ON [vEmployeeDeptRemarks].deptCode = xDE.deptCode
	AND [vEmployeeDeptRemarks].EmployeeID = xDE.employeeID
  JOIN x_Dept_Employee_Service xDES ON xDE.DeptEmployeeID = xDES.DeptEmployeeID
  JOIN Employee e ON xDE.employeeID = e.employeeID
	AND e.IsMedicalTeam = 0
  WHERE [vEmployeeDeptRemarks].DeptCode = @DeptCode
	AND (@IsInternal = 1 OR displayInInternet = 1)

--****** deptServices ********
SELECT deptCode
  ,serviceCode
  ,ServiceDescription
  ,QueueOrder
  ,dbo.rfn_GetServiceReceptionWithRemarks(DeptCode, serviceCode, 1) + '&nbsp;' as Sunday
  ,dbo.rfn_GetServiceReceptionWithRemarks(DeptCode, serviceCode, 2) + '&nbsp;' as Monday	  
  ,dbo.rfn_GetServiceReceptionWithRemarks(DeptCode, serviceCode, 3) + '&nbsp;' as Tuesday	  
  ,dbo.rfn_GetServiceReceptionWithRemarks(DeptCode, serviceCode, 4) + '&nbsp;' as Wednesday	  
  ,dbo.rfn_GetServiceReceptionWithRemarks(DeptCode, serviceCode, 5) + '&nbsp;' as Thursday	  
  ,dbo.rfn_GetServiceReceptionWithRemarks(DeptCode, serviceCode, 6) + '&nbsp;' as Friday	  
  ,dbo.rfn_GetServiceReceptionWithRemarks(DeptCode, serviceCode, 7) + '&nbsp;' as Saturday	  
  ,dbo.rfn_GetServiceReceptionWithRemarks(DeptCode, serviceCode, 8) + '&nbsp;' as HolHamoeed
  ,dbo.rfn_GetServiceReceptionWithRemarks(DeptCode, serviceCode, 9) + '&nbsp;' as HolidayEvening	  
  ,dbo.rfn_GetServiceReceptionWithRemarks(DeptCode, serviceCode, 10) + '&nbsp;' as Holiday	  
  ,dbo.rfn_GetServiceReceptionWithRemarks(DeptCode, serviceCode, 11) + '&nbsp;' as Ramadan	 
  ,dbo.rfn_GetServiceReceptionWithRemarks(DeptCode, serviceCode, 12) + '&nbsp;' as OptionalHoliday	 
  ,dbo.rfn_GetServiceReceptionWithRemarks(DeptCode, serviceCode, 13) + '&nbsp;' as Strike
  
  ,CASE WHEN (Select COUNT(*) FROM vServicesReceptionWithRemarks v WHERE v.deptCode = @DeptCode AND v.receptionDay = 1) > 0 
  THEN '' ELSE 'display:none' END as DisplaySunday
  ,CASE WHEN (Select COUNT(*) FROM vServicesReceptionWithRemarks v WHERE v.deptCode = @DeptCode AND v.receptionDay = 2) > 0 
  THEN '' ELSE 'display:none' END as DisplayMonday	  
  ,CASE WHEN (Select COUNT(*) FROM vServicesReceptionWithRemarks v WHERE v.deptCode = @DeptCode AND v.receptionDay = 3) > 0 
  THEN '' ELSE 'display:none' END as DisplayTuesday	  
  ,CASE WHEN (Select COUNT(*) FROM vServicesReceptionWithRemarks v WHERE v.deptCode = @DeptCode AND v.receptionDay = 4) > 0 
  THEN '' ELSE 'display:none' END as DisplayWednesday	  
  ,CASE WHEN (Select COUNT(*) FROM vServicesReceptionWithRemarks v WHERE v.deptCode = @DeptCode AND v.receptionDay = 5) > 0 
  THEN '' ELSE 'display:none' END as DisplayThursday	
  ,CASE WHEN (Select COUNT(*) FROM vServicesReceptionWithRemarks v WHERE v.deptCode = @DeptCode AND v.receptionDay = 6) > 0 
  THEN '' ELSE 'display:none' END as DisplayFriday	
  ,CASE WHEN (Select COUNT(*) FROM vServicesReceptionWithRemarks v WHERE v.deptCode = @DeptCode AND v.receptionDay = 7) > 0 
  THEN '' ELSE 'display:none' END as DisplaySaturday	
  ,CASE WHEN (Select COUNT(*) FROM vServicesReceptionWithRemarks v WHERE v.deptCode = @DeptCode AND v.receptionDay = 8) > 0 
  THEN '' ELSE 'display:none' END as DisplayHolHamoeed
  ,CASE WHEN (Select COUNT(*) FROM vServicesReceptionWithRemarks v WHERE v.deptCode = @DeptCode AND v.receptionDay = 9) > 0 
  THEN '' ELSE 'display:none' END as DisplayHolidayEvening	
  ,CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode = @DeptCode AND v.receptionDay = 10) > 0 
  THEN '' ELSE 'display:none' END as DisplayHoliday	
  ,CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode = @DeptCode AND v.receptionDay = 11) > 0 
  THEN '' ELSE 'display:none' END as DisplayRamadan	
  ,CASE WHEN (Select COUNT(*) FROM vServicesReceptionWithRemarks v WHERE v.deptCode = @DeptCode AND v.receptionDay = 12) > 0 
  THEN '' ELSE 'display:none' END as DisplayOptionalHoliday	
  ,CASE WHEN (Select COUNT(*) FROM vServicesReceptionWithRemarks v WHERE v.deptCode = @DeptCode AND v.receptionDay = 13) > 0 
  THEN '' ELSE 'display:none' END as DisplayStrike
  ,deptCode as ParentCode
  ,serviceCode as 'ID'
FROM [dbo].[vServicesAndQueueOrderForReport]
WHERE DeptCode = @DeptCode
and IsMedicalTeam = 1
  
--****** deptServiceRemarks ********
 SELECT DeptCode,
	 ServiceCode as ParentCode,
	 RemarkID,
	 RemarkText = dbo.rfn_GetFotmatedRemark(RemarkText),
	 displayInInternet,
	 ValidFrom,
	 CASE WHEN validTo is null OR  validTo > '9999-01-01' THEN '' ELSE 'עד ' + CONVERT(varchar(12),validTo,  103) END + '&nbsp;' as validTo,
	 0 as 'ID'
 FROM vDeptServicesRemarks 
 WHERE DeptCode = @DeptCode
	AND (@IsInternal = 1 OR displayInInternet = 1)
	and IsMedicalTeam = 1

--****** deptEvents ********
SELECT V.EventCode
      ,V.EventName
      ,V.registrationStatusDescription
      ,V.MeetingsNumber
      ,CONVERT(varchar(12),V.FirstEventDate,  103) as FirstEventDate
      ,V.deptCode as ParentCode
	  ,0 as 'ID'      
  FROM [dbo].[vDeptEvents] V
  JOIN DeptEvent DE ON V.DeptEventID = DE.DeptEventID
  WHERE V.DeptCode = @DeptCode
  AND (DE.FromDate <= GETDATE() AND DE.ToDate >= GETDATE())

--****** subClinics ********
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
CASE WHEN @IsInternal = 0 AND V.showEmailInInternet = 0 THEN '' ELSE V.email END as email, 
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
, V.deptCode as 'ID'
,@DeptCode as 'ParentCode'
FROM vAllDeptDetails V 
 JOIN Dept D ON V.deptCode = D.deptCode
 WHERE V.DeptCode in ( SELECT [deptCode]      
  FROM [dbo].[Dept]
where subAdministrationCode = @DeptCode) 
AND D.status = 1

--****** subClinicsRemarks ********
SELECT V.remarkID,
RemarkText = dbo.rfn_GetFotmatedRemark(V.RemarkText),
'מ ' + CONVERT(varchar(12),V.validFrom,  103) as  validFrom,
CASE WHEN V.validTo is null OR  V.validTo > '9999-01-01' THEN '' ELSE 'עד ' + CONVERT(varchar(12),V.validTo,  103) END + '&nbsp;' as validTo,
V.displayInInternet, 
V.RemarkDeptCode as deptCode,
V.ShowOrder
, V.remarkID as 'ID'
, V.RemarkDeptCode as 'ParentCode'
FROM View_DeptRemarks V
JOIN Dept D ON V.deptCode = D.deptCode
where V.deptCode in
( SELECT [deptCode]      
  FROM [dbo].[Dept]
where subAdministrationCode = @DeptCode)
AND (V.validFrom is null OR V.validFrom <= @CurrentDate)
AND (V.validTo is null OR V.validTo >= @CurrentDate)
AND (@IsInternal = 1 OR V.displayInInternet = 1)
AND D.status = 1
ORDER BY IsSharedRemark desc, ShowOrder asc  

--****** subClinicsReceptionHours ********
SELECT Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, HolHamoeed, HolidayEvening, Holiday, Ramadan, OptionalHoliday, Strike,
 ReceptionHoursTypeID, ReceptionTypeDescription,
 DisplaySunday, DisplayMonday, DisplayTuesday, DisplayWednesday, DisplayThursday, DisplayFriday, DisplaySaturday
 ,CASE WHEN (HolHamoeed = '&nbsp;' OR @DisplayHolHamoeed <> '') THEN 'display:none' ELSE '' END as 'DisplayHolHamoeed'  
 ,CASE WHEN (HolidayEvening = '&nbsp;' OR @DisplayHolidayEvening <> '') THEN 'display:none' ELSE '' END as 'DisplayHolidayEvening'
 ,CASE WHEN (Holiday = '&nbsp;' OR @DisplayHoliday <> '') THEN 'display:none' ELSE '' END as 'DisplayHoliday' 
 ,CASE WHEN (Ramadan = '&nbsp;' OR @DisplayRamadan <> '') THEN 'display:none' ELSE '' END as 'DisplayRamadan'  
 ,CASE WHEN (OptionalHoliday = '&nbsp;' OR @DisplayOptionalHoliday <> '') THEN 'display:none' ELSE '' END as 'DisplayOptionalHoliday'
 ,CASE WHEN (Strike = '&nbsp;' OR @DisplayStrike <> '') THEN 'display:none' ELSE '' END as 'DisplayStrike'
 ,CellWidth, ID, ParentCode   
 
FROM
(

SELECT 
 dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 1, ReceptionHoursTypeID ) + '&nbsp;' as Sunday
,dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 2, ReceptionHoursTypeID ) + '&nbsp;' as Monday
,dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 3, ReceptionHoursTypeID ) + '&nbsp;' as Tuesday
,dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 4, ReceptionHoursTypeID ) + '&nbsp;' as Wednesday
,dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 5, ReceptionHoursTypeID ) + '&nbsp;' as Thursday
,dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 6, ReceptionHoursTypeID ) + '&nbsp;' as Friday
,dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 7, ReceptionHoursTypeID ) + '&nbsp;' as Saturday
,dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 8, ReceptionHoursTypeID ) + '&nbsp;' as HolHamoeed
,dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 9, ReceptionHoursTypeID ) + '&nbsp;' as HolidayEvening
,dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 10, ReceptionHoursTypeID ) + '&nbsp;' as Holiday
,dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 11, ReceptionHoursTypeID ) + '&nbsp;' as Ramadan
,dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 12, ReceptionHoursTypeID ) + '&nbsp;' as OptionalHoliday
,dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 13, ReceptionHoursTypeID ) + '&nbsp;' as Strike
,ReceptionHoursTypeID, ReceptionTypeDescription
,@DisplaySunday as 'DisplaySunday'
,@DisplayMonday as 'DisplayMonday'
,@DisplayTuesday as 'DisplayTuesday'
,@DisplayWednesday as 'DisplayWednesday'
,@DisplayThursday as 'DisplayThursday'
,@DisplayFriday as 'DisplayFriday'
,@DisplaySaturday as 'DisplaySaturday'
,@DisplayHolHamoeed as 'DisplayHolHamoeed'
,@DisplayHolidayEvening as 'DisplayHolidayEvening'
,@DisplayHoliday as 'DisplayHoliday'
,@DisplayRamadan as 'DisplayRamadan'
,@DisplayOptionalHoliday as 'DisplayOptionalHoliday'
,@DisplayStrike as 'DisplayStrike'
,@CellWidthForHours as 'CellWidth'
,0 as ID, DeptCode as ParentCode
 
FROM
(SELECT DISTINCT TOP 100 percent V.DeptCode, V.ReceptionHoursTypeID, V.ReceptionTypeDescription
  FROM [dbo].[vDeptReceptionHours] V
  JOIN Dept D ON V.deptCode = D.deptCode  
  WHERE V.DeptCode in 
	( SELECT [deptCode]      
	FROM [dbo].[Dept]
	where subAdministrationCode = @DeptCode)
  AND D.status = 1
  order by  DeptCode, ReceptionHoursTypeID  
  ) T ) TT 


--****** nearbyDepts ******

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
CASE WHEN @IsInternal = 0 AND showEmailInInternet = 0 THEN '' ELSE email END as email,
'phones' = REPLACE(phones,',','<br />') + '&nbsp;',
'faxes' = '&nbsp;' + REPLACE(faxes,',','<br />'),
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
,deptCode as 'ID'
,@DeptCode as 'ParentCode'
FROM vAllDeptDetails
JOIN (SELECT ItemID FROM dbo.rfn_SplitStringByDelimiterValuesToInt( @DeptCodesInArea, ',')) T ON vAllDeptDetails.deptCode = T.ItemID

--******  nearbyDeptsRemarks  ********
SELECT remarkID,
RemarkText = dbo.rfn_GetFotmatedRemark(RemarkText),
CASE WHEN validTo is null OR  validTo > '9999-01-01' THEN '' ELSE 'תוקף ' + CONVERT(varchar(12),validTo,  103) END + '&nbsp;' as validTo,
displayInInternet, 
RemarkDeptCode as deptCode,
ShowOrder
, remarkID as 'ID'
, RemarkDeptCode as 'ParentCode'
FROM View_DeptRemarks
WHERE deptCode in (select ItemID from dbo.rfn_SplitStringValues(@DeptCodesInArea))
AND (@IsInternal = 1 OR displayInInternet = 1)
AND (validFrom is null OR validFrom <= @CurrentDate)
AND (validTo is null OR validTo >= @CurrentDate)
ORDER BY IsSharedRemark desc ,ShowOrder asc

--****** nearbyDeptsReceptionHours  ********
SELECT 
 dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 1, ReceptionHoursTypeID ) + '&nbsp;' as Sunday
,dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 2, ReceptionHoursTypeID ) + '&nbsp;' as Monday
,dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 3, ReceptionHoursTypeID ) + '&nbsp;' as Tuesday
,dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 4, ReceptionHoursTypeID ) + '&nbsp;' as Wednesday
,dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 5, ReceptionHoursTypeID ) + '&nbsp;' as Thursday
,dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 6, ReceptionHoursTypeID ) + '&nbsp;' as Friday
,dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 7, ReceptionHoursTypeID ) + '&nbsp;' as Saturday
,dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 8, ReceptionHoursTypeID ) + '&nbsp;' as HolHamoeed
,dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 9, ReceptionHoursTypeID ) + '&nbsp;' as HolidayEvening
,dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 10, ReceptionHoursTypeID ) + '&nbsp;' as Holiday
,dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 11, ReceptionHoursTypeID ) + '&nbsp;' as Ramadan
,dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 12, ReceptionHoursTypeID ) + '&nbsp;' as OptionalHoliday
,dbo.rfn_GetDeptReceptionsWithRemarkString(DeptCode, 13, ReceptionHoursTypeID ) + '&nbsp;' as Strike
,ReceptionHoursTypeID, ReceptionTypeDescription
,@DisplaySunday as 'DisplaySunday'
,@DisplayMonday as 'DisplayMonday'
,@DisplayTuesday as 'DisplayTuesday'
,@DisplayWednesday as 'DisplayWednesday'
,@DisplayThursday as 'DisplayThursday'
,@DisplayFriday as 'DisplayFriday'
,@DisplaySaturday as 'DisplaySaturday'
,@DisplayHolHamoeed as 'DisplayHolHamoeed'
,@DisplayHolidayEvening as 'DisplayHolidayEvening'
,@DisplayHoliday as 'DisplayHoliday'
,@DisplayRamadan as 'DisplayRamadan'
,@DisplayOptionalHoliday as 'DisplayOptionalHoliday'
,@DisplayStrike as 'DisplayStrike'
,@CellWidthForHours as 'CellWidth'
 , 0 as ID, DeptCode as ParentCode
 
FROM
(SELECT DISTINCT TOP 100 percent DeptCode, ReceptionHoursTypeID, ReceptionTypeDescription
  FROM [dbo].[vDeptReceptionHours]
  WHERE DeptCode in (select ItemID from dbo.rfn_SplitStringValues(@DeptCodesInArea))
  order by  DeptCode, ReceptionHoursTypeID  
  ) T  

GO

GRANT EXEC ON dbo.rpc_GetZoomClinicTemplate TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_GetZoomClinicTemplate TO [clalit\IntranetDev]
GO 


