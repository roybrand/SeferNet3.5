IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getClinicList_ForPrinting')
	BEGIN
		DROP  Procedure  rpc_getClinicList_ForPrinting
	END
GO

CREATE Procedure [dbo].[rpc_getClinicList_ForPrinting]
	(
	@ServiceCodes varchar(max) = null,
	@ReceptionDays varchar(max)=null,
	@OpenAtHour varchar(5)=null,
	@OpenFromHour varchar(5)=null,
	@OpenToHour varchar(5)=null,
	@OpenNow bit,
	@isCommunity bit,
	@isMushlam bit,
	@isHospital bit,
	@status int = null,
	@ReceiveGuests bit,
	@ServiceCodeForMuslam varchar(max) = null,
	@GroupCode int = null,
	@SubGroupCode int = null,
	@FoundDeptCodeList varchar(max)
	)
AS

DECLARE @CurrentDate datetime = getdate()
DECLARE @ExpirationDate datetime = DATEADD(day, DATEDIFF(day, 0, @CurrentDate), 0) 
DECLARE @DateAfterExpiration datetime = DATEADD(day, 1, DATEADD(day, DATEDIFF(day, 0, @CurrentDate), 0))

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
---
DECLARE 		
@DisplaySundayDoc varchar(20) =	  CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode in (SELECT IntField FROM dbo.SplitString(@FoundDeptCodeList)) AND v.receptionDay = 1) > 0 
 THEN '' ELSE 'display:none' END
,@DisplayMondayDoc varchar(20) =  CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode in (SELECT IntField FROM dbo.SplitString(@FoundDeptCodeList)) AND v.receptionDay = 2) > 0 
  THEN '' ELSE 'display:none' END	  
,@DisplayTuesdayDoc varchar(20) = CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode in (SELECT IntField FROM dbo.SplitString(@FoundDeptCodeList)) AND v.receptionDay = 3) > 0 
 THEN '' ELSE 'display:none' END	  
,@DisplayWednesdayDoc varchar(20) = CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode in (SELECT IntField FROM dbo.SplitString(@FoundDeptCodeList)) AND v.receptionDay = 4) > 0 
 THEN '' ELSE 'display:none' END	  
,@DisplayThursdayDoc varchar(20) = CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode in (SELECT IntField FROM dbo.SplitString(@FoundDeptCodeList)) AND v.receptionDay = 5) > 0 
THEN '' ELSE 'display:none' END	
,@DisplayFridayDoc varchar(20) = CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode in (SELECT IntField FROM dbo.SplitString(@FoundDeptCodeList)) AND v.receptionDay = 6) > 0 
THEN '' ELSE 'display:none' END	
,@DisplaySaturdayDoc varchar(20) = CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode in (SELECT IntField FROM dbo.SplitString(@FoundDeptCodeList)) AND v.receptionDay = 7) > 0 
THEN '' ELSE 'display:none' END	
,@DisplayHolHamoeedDoc varchar(20) = CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode in (SELECT IntField FROM dbo.SplitString(@FoundDeptCodeList)) AND v.receptionDay = 8) > 0 
THEN '' ELSE 'display:none' END
,@DisplayHolidayEveningDoc varchar(20) = CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode in (SELECT IntField FROM dbo.SplitString(@FoundDeptCodeList)) AND v.receptionDay = 9) > 0 
THEN '' ELSE 'display:none' END	
,@DisplayHolidayDoc varchar(20) = CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode in (SELECT IntField FROM dbo.SplitString(@FoundDeptCodeList)) AND v.receptionDay = 10) > 0 
THEN '' ELSE 'display:none' END	
,@DisplayRamadanDoc varchar(20) = CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode in (SELECT IntField FROM dbo.SplitString(@FoundDeptCodeList)) AND v.receptionDay = 11) > 0 
THEN '' ELSE 'display:none' END	
,@DisplayOptionalHolidayDoc varchar(20) = CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode in (SELECT IntField FROM dbo.SplitString(@FoundDeptCodeList)) AND v.receptionDay = 12) > 0 
THEN '' ELSE 'display:none' END	
,@DisplayStrikeDoc varchar(20) = CASE WHEN (Select COUNT(*) FROM vEmployeeReceptionHours v WHERE v.deptCode in (SELECT IntField FROM dbo.SplitString(@FoundDeptCodeList)) AND v.receptionDay = 13) > 0 
THEN '' ELSE 'display:none' END	
---


DECLARE @CellWidthForHours varchar(5) = CAST(100/(SELECT COUNT(*) FROM DIC_ReceptionDays WHERE Display = 1) as varchar(5))

DECLARE @CellWidthForDocHours varchar(5) = CAST(70/(SELECT COUNT(*) FROM DIC_ReceptionDays WHERE Display = 1) as varchar(5)) 
--print @CellWidthForDocHours

DECLARE @ServiceCodesList [tbl_UniqueIntArray]   
IF @ServiceCodes is NOT null
	INSERT INTO @ServiceCodesList SELECT DISTINCT * FROM dbo.SplitStringNoOrder(@ServiceCodes)
	
DECLARE @OrganizationSectorIDList varchar(5) = ''
set @OrganizationSectorIDList = case when @isCommunity is null then '0' else '1' end
set @OrganizationSectorIDList = @OrganizationSectorIDList + ',' + case when @isMushlam is null then '0' else '2' end
set @OrganizationSectorIDList = @OrganizationSectorIDList + ',' + case when @isHospital is null then '0' else '3' end	

DECLARE @AgreementTypeList [tbl_UniqueIntArray]   
INSERT INTO @AgreementTypeList
select AgreementTypeID from DIC_AgreementTypes
where OrganizationSectorID in (Select IntField from dbo.SplitString(@OrganizationSectorIDList))

DECLARE @ReceptionDayNow tinyint
DECLARE @OpenAtThisHour real
DECLARE @OpenAtHour_real real
DECLARE @OpenFromHour_real real
DECLARE @OpenToHour_real real
	
IF @OpenFromHour IS NOT NULL
	SET @OpenFromHour_real = CAST (LEFT(@OpenFromHour,2) as real) + CAST (RIGHT(@OpenFromHour,2) as real)/60
	
IF @OpenToHour IS NOT NULL
	SET @OpenToHour_real = CAST (LEFT(@OpenToHour,2) as real) + CAST (RIGHT(@OpenToHour,2) as real)/60 

IF (@OpenAtHour is not null)
	SET @OpenAtHour_real = CAST (LEFT(@OpenAtHour,2) as real) + CAST (RIGHT(@OpenAtHour,2) as real)/60 

IF(@OpenNow = 1)
	BEGIN
		SET @ReceptionDayNow = DATEPART(WEEKDAY, GETDATE())
		IF(@ReceptionDays is NULL)
			SET @ReceptionDays = CAST(@ReceptionDayNow as varchar(1))
		ELSE
			IF(PATINDEX('%' + CAST(@ReceptionDayNow as varchar(1)) + '%', @ReceptionDays) = 0)
			SET @ReceptionDays = @ReceptionDays + ',' + CAST(@ReceptionDayNow as varchar(1))
	END
	
DECLARE @ReceptionDaysList [tbl_UniqueIntArray] 
IF @ReceptionDays is NOT null
	INSERT INTO @ReceptionDaysList SELECT DISTINCT * FROM dbo.SplitStringNoOrder(@ReceptionDays) 
	
SELECT deptCode, deptName, deptTypeDescription, SubstituteName, UnitTypeName, cityName, simpleAddress, phone, phoneRemark, phoneRemark, fax, ClinicRemarks,
Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, 
HolHamoeed, HolidayEvening, Holiday, Ramadan,OptionalHoliday, Strike,
 ID, ParentCode
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
,@CellWidthForDocHours as 'CellWidthDoc'

,@DisplaySundayDoc as 'DisplaySundayDoc'
,@DisplayMondayDoc as 'DisplayMondayDoc'
,@DisplayTuesdayDoc as 'DisplayTuesdayDoc'
,@DisplayWednesdayDoc as 'DisplayWednesdayDoc'
,@DisplayThursdayDoc as 'DisplayThursdayDoc'
,@DisplayFridayDoc as 'DisplayFridayDoc'
,@DisplaySaturdayDoc as 'DisplaySaturdayDoc'
,@DisplayHolHamoeedDoc as 'DisplayHolHamoeedDoc'
,@DisplayHolidayEveningDoc as 'DisplayHolidayEveningDoc'
,@DisplayHolidayDoc as 'DisplayHolidayDoc'
,@DisplayRamadanDoc as 'DisplayRamadanDoc'
,@DisplayOptionalHolidayDoc as 'DisplayOptionalHolidayDoc'
,@DisplayStrikeDoc as 'DisplayStrikeDoc'

FROM 
(
SELECT distinct
dept.deptCode,
dept.deptName,
DIC_DeptTypes.deptTypeDescription,
SubUnitTypeSubstituteName.SubstituteName,
UnitType.UnitTypeName,
Cities.cityName,
dbo.GetAddress(dept.deptCode) as simpleAddress,
--dbo.GetDeptPhoneNumber(dept.deptCode, 1, 1) as phone,
dbo.fun_ParsePhoneNumberWithExtension(DeptPhones.prePrefix, DeptPhones.prefix, DeptPhones.phone, DeptPhones.extension) as phone,
'</br>' + DeptPhones.remark as phoneRemark,

dbo.GetDeptPhoneNumber(dept.deptCode, 2, 1) as fax
,STUFF( (SELECT STUFF((SELECT '<br>' + REPLACE(dbo.rfn_GetFotmatedRemark(RemarkText),'-', '&minus;') 
				FROM View_DeptRemarks 
				WHERE View_DeptRemarks.deptCode = Dept.deptCode
				AND (IsSharedRemark = 0 OR Dept.IsCommunity = 1)
				AND validFrom < @DateAfterExpiration AND ( validTo is null OR validTo >= @ExpirationDate )
				for xml path('')),1,1,''
				)) ,1,9,'')  AS ClinicRemarks 
,STUFF((SELECT STUFF ((SELECT '<br>' + v_DeptReception.openingHour + '-' + v_DeptReception.closingHour 
				FROM v_DeptReception 
				WHERE v_DeptReception.deptCode = Dept.deptCode
				AND v_DeptReception.receptionDay = 1
				AND v_DeptReception.ReceptionHoursTypeID = 1 
				AND validFrom < @DateAfterExpiration AND ( validTo is null OR validTo >= @ExpirationDate )
				ORDER BY openingHour
				for xml path('')),1,1,'')) ,1,9,'')  AS Sunday 
,STUFF((SELECT STUFF ((SELECT '<br>' + v_DeptReception.openingHour + '-' + v_DeptReception.closingHour 
				FROM v_DeptReception 
				WHERE v_DeptReception.deptCode = Dept.deptCode
				AND v_DeptReception.receptionDay = 2
				AND v_DeptReception.ReceptionHoursTypeID = 1 
				AND validFrom < @DateAfterExpiration AND ( validTo is null OR validTo >= @ExpirationDate )
				ORDER BY openingHour
				for xml path('')),1,1,'')) ,1,9,'')  AS Monday
,STUFF((SELECT STUFF ((SELECT '<br>' + v_DeptReception.openingHour + '-' + v_DeptReception.closingHour 
				FROM v_DeptReception 
				WHERE v_DeptReception.deptCode = Dept.deptCode
				AND v_DeptReception.receptionDay = 3
				AND v_DeptReception.ReceptionHoursTypeID = 1 
				AND validFrom < @DateAfterExpiration AND ( validTo is null OR validTo >= @ExpirationDate )
				ORDER BY openingHour
				for xml path('')),1,1,'')) ,1,9,'')  AS Tuesday
,STUFF((SELECT STUFF ((SELECT '<br>' + v_DeptReception.openingHour + '-' + v_DeptReception.closingHour 
				FROM v_DeptReception 
				WHERE v_DeptReception.deptCode = Dept.deptCode
				AND v_DeptReception.receptionDay = 4
				AND v_DeptReception.ReceptionHoursTypeID = 1 
				AND validFrom < @DateAfterExpiration AND ( validTo is null OR validTo >= @ExpirationDate )
				ORDER BY openingHour
				for xml path('')),1,1,'')) ,1,9,'')  AS Wednesday
,STUFF((SELECT STUFF ((SELECT '<br>' + v_DeptReception.openingHour + '-' + v_DeptReception.closingHour 
				FROM v_DeptReception 
				WHERE v_DeptReception.deptCode = Dept.deptCode
				AND v_DeptReception.receptionDay = 5
				AND v_DeptReception.ReceptionHoursTypeID = 1 
				AND validFrom < @DateAfterExpiration AND ( validTo is null OR validTo >= @ExpirationDate )
				ORDER BY openingHour
				for xml path('')),1,1,'')) ,1,9,'')  AS Thursday
,STUFF((SELECT STUFF ((SELECT '<br>' + v_DeptReception.openingHour + '-' + v_DeptReception.closingHour 
				FROM v_DeptReception 
				WHERE v_DeptReception.deptCode = Dept.deptCode
				AND v_DeptReception.receptionDay = 6
				AND v_DeptReception.ReceptionHoursTypeID = 1 
				AND validFrom < @DateAfterExpiration AND ( validTo is null OR validTo >= @ExpirationDate )
				ORDER BY openingHour
				for xml path('')),1,1,'')) ,1,9,'')  AS Friday
,STUFF((SELECT STUFF ((SELECT '<br>' + v_DeptReception.openingHour + '-' + v_DeptReception.closingHour 
				FROM v_DeptReception 
				WHERE v_DeptReception.deptCode = Dept.deptCode
				AND v_DeptReception.receptionDay = 7
				AND v_DeptReception.ReceptionHoursTypeID = 1 
				AND validFrom < @DateAfterExpiration AND ( validTo is null OR validTo >= @ExpirationDate )
				for xml path('')),1,1,'')) ,1,9,'')  AS Saturday
,STUFF((SELECT STUFF ((SELECT '<br>' + v_DeptReception.openingHour + '-' + v_DeptReception.closingHour 
				FROM v_DeptReception 
				WHERE v_DeptReception.deptCode = Dept.deptCode
				AND v_DeptReception.receptionDay = 8
				AND v_DeptReception.ReceptionHoursTypeID = 1 
				AND validFrom < @DateAfterExpiration AND ( validTo is null OR validTo >= @ExpirationDate )
				ORDER BY openingHour
				for xml path('')),1,1,'')) ,1,9,'')  AS HolHamoeed				
,STUFF((SELECT STUFF ((SELECT '<br>' + v_DeptReception.openingHour + '-' + v_DeptReception.closingHour 
				FROM v_DeptReception 
				WHERE v_DeptReception.deptCode = Dept.deptCode
				AND v_DeptReception.receptionDay = 9
				AND v_DeptReception.ReceptionHoursTypeID = 1 
				AND validFrom < @DateAfterExpiration AND ( validTo is null OR validTo >= @ExpirationDate )
				ORDER BY openingHour
				for xml path('')),1,1,'')) ,1,9,'')  AS HolidayEvening
,STUFF((SELECT STUFF ((SELECT '<br>' + v_DeptReception.openingHour + '-' + v_DeptReception.closingHour 
				FROM v_DeptReception 
				WHERE v_DeptReception.deptCode = Dept.deptCode
				AND v_DeptReception.receptionDay = 10
				AND v_DeptReception.ReceptionHoursTypeID = 1 
				AND validFrom < @DateAfterExpiration AND ( validTo is null OR validTo >= @ExpirationDate )
				ORDER BY openingHour
				for xml path('')),1,1,'')) ,1,9,'')  AS Holiday	
,STUFF((SELECT STUFF ((SELECT '<br>' + v_DeptReception.openingHour + '-' + v_DeptReception.closingHour 
				FROM v_DeptReception 
				WHERE v_DeptReception.deptCode = Dept.deptCode
				AND v_DeptReception.receptionDay = 11
				AND v_DeptReception.ReceptionHoursTypeID = 1 
				AND validFrom < @DateAfterExpiration AND ( validTo is null OR validTo >= @ExpirationDate )
				ORDER BY openingHour
				for xml path('')),1,1,'')) ,1,9,'')  AS Ramadan
,STUFF((SELECT STUFF ((SELECT '<br>' + v_DeptReception.openingHour + '-' + v_DeptReception.closingHour 
				FROM v_DeptReception 
				WHERE v_DeptReception.deptCode = Dept.deptCode
				AND v_DeptReception.receptionDay = 12
				AND v_DeptReception.ReceptionHoursTypeID = 1 
				AND validFrom < @DateAfterExpiration AND ( validTo is null OR validTo >= @ExpirationDate )
				ORDER BY openingHour
				for xml path('')),1,1,'')) ,1,9,'')  AS OptionalHoliday
,STUFF((SELECT STUFF ((SELECT '<br>' + v_DeptReception.openingHour + '-' + v_DeptReception.closingHour 
				FROM v_DeptReception 
				WHERE v_DeptReception.deptCode = Dept.deptCode
				AND v_DeptReception.receptionDay = 13
				AND v_DeptReception.ReceptionHoursTypeID = 1 
				AND validFrom < @DateAfterExpiration AND ( validTo is null OR validTo >= @ExpirationDate )
				ORDER BY openingHour
				for xml path('')),1,1,'')) ,1,9,'')  AS Strike																	
, Dept.deptCode as 'ID'
,0 as 'ParentCode'																									
FROM Dept
INNER JOIN DIC_DeptTypes on Dept.deptType = DIC_DeptTypes.deptType
INNER JOIN UnitType on dept.typeUnitCode = UnitType.UnitTypeCode
INNER JOIN Cities on dept.cityCode = Cities.cityCode
LEFT JOIN SubUnitTypeSubstituteName ON dept.typeUnitCode = SubUnitTypeSubstituteName.UnitTypeCode
			AND (IsNull(dept.subUnitTypeCode, 0) + UnitType.DefaultSubUnitTypeCode) = SubUnitTypeSubstituteName.SubUnitTypeCode
LEFT JOIN DeptPhones ON dept.deptCode = DeptPhones.deptCode
	AND DeptPhones.phoneType = 1 AND phoneOrder = 1
			
WHERE Dept.deptCode in (SELECT IntField FROM dbo.SplitString(@FoundDeptCodeList))
) T

-- ************** Service suppliers	

SELECT EmployeeID, deptCode, IsMedicalTeam, Name, Experties, QueueOrderDescriptions, ServiceDescription,
Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, 
HolHamoeed, HolidayEvening, Holiday, Ramadan, OptionalHoliday,
Strike,
Remarks, ID, ParentCode
,CASE WHEN Remarks IS NULL  THEN 'display:none' ELSE '' END as 'ShowRemarks'
,@DisplaySundayDoc as 'DisplaySunday'
,@DisplayMondayDoc as 'DisplayMonday'
,@DisplayTuesdayDoc as 'DisplayTuesday'
,@DisplayWednesdayDoc as 'DisplayWednesday'
,@DisplayThursdayDoc as 'DisplayThursday'
,@DisplayFridayDoc as 'DisplayFriday'
,@DisplaySaturdayDoc as 'DisplaySaturday'
,@DisplayHolHamoeedDoc as 'DisplayHolHamoeed'
,@DisplayHolidayEveningDoc as 'DisplayHolidayEvening'
,@DisplayHolidayDoc as 'DisplayHoliday'
,@DisplayRamadanDoc as 'DisplayRamadan'
,@DisplayOptionalHolidayDoc as 'DisplayOptionalHoliday'
,@DisplayStrikeDoc as 'DisplayStrike'

FROM
(
	SELECT 
	xDE.EmployeeID,
	xDE.deptCode,	
	emp_pr.IsMedicalTeam as IsMedicalTeam, 
	emp_pr.EmployeeName as Name,
	CASE WHEN emp_pr.ExpProfession = '' THEN ''
		ELSE '<br>' + emp_pr.ExpProfession END 
	as Experties,
	dbo.rfn_GetDeptEmployeeServiceQueueOrderDescriptionsHTML(xDE.deptCode, xDE.employeeID, T_services.ServiceCode)
	AS QueueOrderDescriptions, 
	CASE WHEN @IsHospital = 1 AND emp_pr.IsMedicalTeam = 1 AND xDE.AgreementType = 5 
		THEN dbo.fun_GetMedicalAspectsForService(T_services.ServiceCode, xDE.DeptEmployeeID)
		ELSE T_services.ServiceDescription  
		END 
	as ServiceDescription 
	------------------------------------------------------------
,STUFF((SELECT STUFF ((SELECT '<br>' + der2.openingHour + '-' + der2.closingHour 
				FROM deptEmployeeReception as der2
				INNER JOIN deptEmployeeReceptionServices as ders2 ON dER2.receptionID = ders2.receptionID
				WHERE der2.DeptEmployeeID = xDE.DeptEmployeeID
				AND ders2.serviceCode = T_services.ServiceCode
				AND der2.receptionDay = 1
				AND der2.validFrom < @DateAfterExpiration AND ( der2.validTo is null OR der2.validTo >= @ExpirationDate )
				ORDER BY openingHour
				for xml path('')),1,1,'')) ,1,9,'') 
	AS Sunday
,STUFF((SELECT STUFF ((SELECT '<br>' + der2.openingHour + '-' + der2.closingHour 
				FROM deptEmployeeReception as der2
				INNER JOIN deptEmployeeReceptionServices as ders2 ON dER2.receptionID = ders2.receptionID
				WHERE der2.DeptEmployeeID = xDE.DeptEmployeeID
				AND ders2.serviceCode = T_services.ServiceCode
				AND der2.receptionDay = 2
				AND der2.validFrom < @DateAfterExpiration AND ( der2.validTo is null OR der2.validTo >= @ExpirationDate )
				ORDER BY openingHour
				for xml path('')),1,1,'')) ,1,9,'') AS Monday
,STUFF((SELECT STUFF ((SELECT '<br>' + der2.openingHour + '-' + der2.closingHour 
				FROM deptEmployeeReception as der2
				INNER JOIN deptEmployeeReceptionServices as ders2 ON dER2.receptionID = ders2.receptionID
				WHERE der2.DeptEmployeeID = xDE.DeptEmployeeID
				AND ders2.serviceCode = T_services.ServiceCode
				AND der2.receptionDay = 3
				AND der2.validFrom < @DateAfterExpiration AND ( der2.validTo is null OR der2.validTo >= @ExpirationDate )
				ORDER BY openingHour
				for xml path('')),1,1,'')) ,1,9,'') 
	AS Tuesday
,STUFF((SELECT STUFF ((SELECT '<br>' + der2.openingHour + '-' + der2.closingHour 
				FROM deptEmployeeReception as der2
				INNER JOIN deptEmployeeReceptionServices as ders2 ON dER2.receptionID = ders2.receptionID
				WHERE der2.DeptEmployeeID = xDE.DeptEmployeeID
				AND ders2.serviceCode = T_services.ServiceCode
				AND der2.receptionDay = 4
				AND der2.validFrom < @DateAfterExpiration AND ( der2.validTo is null OR der2.validTo >= @ExpirationDate )
				ORDER BY openingHour
				for xml path('')),1,1,'')) ,1,9,'') 
	AS Wednesday
,STUFF((SELECT STUFF ((SELECT '<br>' + der2.openingHour + '-' + der2.closingHour 
				FROM deptEmployeeReception as der2
				INNER JOIN deptEmployeeReceptionServices as ders2 ON dER2.receptionID = ders2.receptionID
				WHERE der2.DeptEmployeeID = xDE.DeptEmployeeID
				AND ders2.serviceCode = T_services.ServiceCode
				AND der2.receptionDay = 5
				AND der2.validFrom < @DateAfterExpiration AND ( der2.validTo is null OR der2.validTo >= @ExpirationDate )
				ORDER BY openingHour
				for xml path('')),1,1,'')) ,1,9,'') 
	AS Thursday
,STUFF((SELECT STUFF ((SELECT '<br>' + der2.openingHour + '-' + der2.closingHour 
				FROM deptEmployeeReception as der2
				INNER JOIN deptEmployeeReceptionServices as ders2 ON dER2.receptionID = ders2.receptionID
				WHERE der2.DeptEmployeeID = xDE.DeptEmployeeID
				AND ders2.serviceCode = T_services.ServiceCode
				AND der2.receptionDay = 6
				AND der2.validFrom < @DateAfterExpiration AND ( der2.validTo is null OR der2.validTo >= @ExpirationDate )
				ORDER BY openingHour
				for xml path('')),1,1,'')) ,1,9,'') 
	AS Friday
,STUFF((SELECT STUFF ((SELECT '<br>' + der2.openingHour + '-' + der2.closingHour 
				FROM deptEmployeeReception as der2
				INNER JOIN deptEmployeeReceptionServices as ders2 ON dER2.receptionID = ders2.receptionID
				WHERE der2.DeptEmployeeID = xDE.DeptEmployeeID
				AND ders2.serviceCode = T_services.ServiceCode
				AND der2.receptionDay = 7
				AND der2.validFrom < @DateAfterExpiration AND ( der2.validTo is null OR der2.validTo >= @ExpirationDate )
				ORDER BY openingHour
				for xml path('')),1,1,'')) ,1,9,'') 
	AS Saturday
,STUFF((SELECT STUFF ((SELECT '<br>' + der2.openingHour + '-' + der2.closingHour 
				FROM deptEmployeeReception as der2
				INNER JOIN deptEmployeeReceptionServices as ders2 ON dER2.receptionID = ders2.receptionID
				WHERE der2.DeptEmployeeID = xDE.DeptEmployeeID
				AND ders2.serviceCode = T_services.ServiceCode
				AND der2.receptionDay = 8
				AND der2.validFrom < @DateAfterExpiration AND ( der2.validTo is null OR der2.validTo >= @ExpirationDate )
				ORDER BY openingHour
				for xml path('')),1,1,'')) ,1,9,'') 
	AS HolHamoeed
,STUFF((SELECT STUFF ((SELECT '<br>' + der2.openingHour + '-' + der2.closingHour 
				FROM deptEmployeeReception as der2
				INNER JOIN deptEmployeeReceptionServices as ders2 ON dER2.receptionID = ders2.receptionID
				WHERE der2.DeptEmployeeID = xDE.DeptEmployeeID
				AND ders2.serviceCode = T_services.ServiceCode
				AND der2.receptionDay = 9
				AND der2.validFrom < @DateAfterExpiration AND ( der2.validTo is null OR der2.validTo >= @ExpirationDate )
				ORDER BY openingHour
				for xml path('')),1,1,'')) ,1,9,'') 
	AS HolidayEvening		
,STUFF((SELECT STUFF ((SELECT '<br>' + der2.openingHour + '-' + der2.closingHour 
				FROM deptEmployeeReception as der2
				INNER JOIN deptEmployeeReceptionServices as ders2 ON dER2.receptionID = ders2.receptionID
				WHERE der2.DeptEmployeeID = xDE.DeptEmployeeID
				AND ders2.serviceCode = T_services.ServiceCode
				AND der2.receptionDay = 10
				AND der2.validFrom < @DateAfterExpiration AND ( der2.validTo is null OR der2.validTo >= @ExpirationDate )
				ORDER BY openingHour
				for xml path('')),1,1,'')) ,1,9,'') 
	AS Holiday
,STUFF((SELECT STUFF ((SELECT '<br>' + der2.openingHour + '-' + der2.closingHour 
				FROM deptEmployeeReception as der2
				INNER JOIN deptEmployeeReceptionServices as ders2 ON dER2.receptionID = ders2.receptionID
				WHERE der2.DeptEmployeeID = xDE.DeptEmployeeID
				AND ders2.serviceCode = T_services.ServiceCode
				AND der2.receptionDay = 11
				AND der2.validFrom < @DateAfterExpiration AND ( der2.validTo is null OR der2.validTo >= @ExpirationDate )
				ORDER BY openingHour
				for xml path('')),1,1,'')) ,1,9,'') 
	AS Ramadan	
,STUFF((SELECT STUFF ((SELECT '<br>' + der2.openingHour + '-' + der2.closingHour 
				FROM deptEmployeeReception as der2
				INNER JOIN deptEmployeeReceptionServices as ders2 ON dER2.receptionID = ders2.receptionID
				WHERE der2.DeptEmployeeID = xDE.DeptEmployeeID
				AND ders2.serviceCode = T_services.ServiceCode
				AND der2.receptionDay = 12
				AND der2.validFrom < @DateAfterExpiration AND ( der2.validTo is null OR der2.validTo >= @ExpirationDate )
				ORDER BY openingHour
				for xml path('')),1,1,'')) ,1,9,'') 
	AS OptionalHoliday
,STUFF((SELECT STUFF ((SELECT '<br>' + der2.openingHour + '-' + der2.closingHour 
				FROM deptEmployeeReception as der2
				INNER JOIN deptEmployeeReceptionServices as ders2 ON dER2.receptionID = ders2.receptionID
				WHERE der2.DeptEmployeeID = xDE.DeptEmployeeID
				AND ders2.serviceCode = T_services.ServiceCode
				AND der2.receptionDay = 13
				AND der2.validFrom < @DateAfterExpiration AND ( der2.validTo is null OR der2.validTo >= @ExpirationDate )
				ORDER BY openingHour
				for xml path('')),1,1,'')) ,1,9,'') 
	AS Strike	
				
,STUFF((SELECT STUFF ((
	SELECT '<br>' + '&nbsp;&nbsp;' + RemarkText
	FROM (
		SELECT 
		dbo.rfn_GetFotmatedRemark(v_DE_ER.RemarkTextFormated) as RemarkText
		from View_DeptEmployee_EmployeeRemarks as v_DE_ER
		where v_DE_ER.DeptEmployeeID = xDE.DeptEmployeeID
		AND (v_DE_ER.ValidFrom is null OR DATEDIFF(dd, v_DE_ER.ValidFrom ,@ExpirationDate) >= 0)
		AND (v_DE_ER.ValidTo is null OR DATEDIFF(dd, v_DE_ER.ValidTo ,@ExpirationDate) <= 0)
		AND v_DE_ER.displayInInternet = 1

		UNION

		SELECT dbo.rfn_GetFotmatedRemark(desr.RemarkText) as RemarkText
		FROM DeptEmployeeServiceRemarks desr
		INNER JOIN x_Dept_Employee_Service xdes ON desr.x_dept_employee_serviceID = xdes.x_dept_employee_serviceID
		INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
		INNER JOIN [Services] ON xdes.ServiceCode = [Services].ServiceCode AND xdes.Status = 1
		WHERE xd.DeptEmployeeID = xDE.DeptEmployeeID
		--AND (@ServiceCode = '' OR xdes.ServiceCode IN (SELECT IntField FROM dbo.SplitString(@ServiceCode))) 
		AND (xdes.ServiceCode = T_services.ServiceCode ) 
		AND (ValidFrom is NULL OR DATEDIFF(dd, ValidFrom ,@ExpirationDate) >= 0 )
		AND (ValidTo is NULL OR  DATEDIFF(dd, ValidTo ,@ExpirationDate) <= 0 ) 
		AND desr.DisplayInInternet = 1
		) as T
	for xml path('')),1,1,'')) ,1,9,'') 
	AS Remarks 
,xDE.EmployeeID as 'ID'
,xDE.deptCode as 'ParentCode'				

------------------------------------------------------------	 
	FROM x_dept_employee xDE
	INNER JOIN EmployeeInClinic_preselected emp_pr on xDE.DeptEmployeeID = emp_pr.DeptEmployeeID
		AND ((@ReceiveGuests is null OR @ReceiveGuests = 0) OR emp_pr.ReceiveGuests = CAST(@ReceiveGuests as int))
	INNER JOIN  
	(		SELECT 
			xDE2.DeptEmployeeID,
			0 as x_dept_employee_serviceID,
			1 as status, 
			CASE ISNULL(@ServiceCodeForMuslam, '')
				WHEN '' THEN (select TOP 1 IntVal from @ServiceCodesList)
				ELSE @ServiceCodeForMuslam 
				END 
			as ServiceCode,
				' התייעצות עם רופא מומחה למתן חו"ד שנייה בנושא: ' + [dbo].[fun_GetEmployeeMushlamInDeptServices](xDE2.EmployeeID,xDE2.deptCode,1) as ServiceDescription,
				(	SELECT COUNT(*) FROM x_Dept_Employee_Service
					JOIN deptEmployeeReception ON x_Dept_Employee_Service.DeptEmployeeID = deptEmployeeReception.DeptEmployeeID
							AND CAST(GETDATE() as date) between ISNULL(validFrom,'1900-01-01') and ISNULL(validTo,'2079-01-01')
					WHERE x_Dept_Employee_Service.DeptEmployeeID = xDE2.DeptEmployeeID
					AND x_Dept_Employee_Service.serviceCode = 180300)
			as ReceptionCount		

			FROM x_dept_employee xDE2
			WHERE xDE2.deptCode in (SELECT IntField FROM dbo.SplitString(@FoundDeptCodeList))
			--AND xDE2.active = 1
			AND EXISTS (	SELECT * FROM x_Dept_Employee_Service 
							WHERE x_Dept_Employee_Service.serviceCode = 180300
							AND x_Dept_Employee_Service.DeptEmployeeID = xDE2.DeptEmployeeID	) 
			AND	(
					(@ServiceCodeForMuslam is NOT null
					AND  EXISTS (	SELECT * FROM x_Dept_Employee_Service
									WHERE x_Dept_Employee_Service.serviceCode = @ServiceCodeForMuslam
									AND x_Dept_Employee_Service.DeptEmployeeID = xDE2.DeptEmployeeID	)
					)
					OR
					(@ServiceCodeForMuslam is null
					AND EXISTS (SELECT * FROM x_Dept_Employee_Service 
								WHERE x_Dept_Employee_Service.serviceCode in (SELECT IntVal FROM @ServiceCodesList )
								AND x_Dept_Employee_Service.DeptEmployeeID = xDE2.DeptEmployeeID )
					)
				)

		UNION
		
			SELECT 
			xDE2.DeptEmployeeID,
			xDES.x_dept_employee_serviceID,
			xDES.status,
			[Services].ServiceCode,
			[Services].ServiceDescription as ServiceDescription,
			[View_DeptEmployeeReceptionCount].ReceptionCount
			FROM x_dept_employee xDE2
			INNER JOIN x_Dept_Employee_Service xDES on xDE2.DeptEmployeeID = xDES.DeptEmployeeID
			INNER JOIN [Services] on [Services].ServiceCode = xDES.serviceCode
			LEFT JOIN [View_DeptEmployeeReceptionCount] on [View_DeptEmployeeReceptionCount].DeptEmployeeID = xDE2.DeptEmployeeID
				and [View_DeptEmployeeReceptionCount].serviceCode = xDES.serviceCode
				and xDE2.AgreementType in (select * from @AgreementTypeList)
			WHERE NOT EXISTS (	SELECT * FROM x_Dept_Employee_Service 
							WHERE x_Dept_Employee_Service.serviceCode = 180300
							AND x_Dept_Employee_Service.DeptEmployeeID = xDE2.DeptEmployeeID	)
			AND xDE2.deptCode in (SELECT IntField FROM dbo.SplitString(@FoundDeptCodeList))
			--AND xDE2.active = 1		
	)	as T_services 
		ON 	T_services.DeptEmployeeID = xDE.DeptEmployeeID
		LEFT JOIN vMushlamCervices ON T_services.ServiceCode = vMushlamCervices.ServiceCode --!!!!!!!!!!!!!!	

WHERE 	(T_services.ServiceCode in (select IntVal from @ServiceCodesList))
		AND xDE.AgreementType in (select * from @AgreementTypeList)
--------------------------------------------------------------------
		AND	((@Status = 0 AND xDE.active = 0)
				OR (@Status = 1 AND (xDE.active = 1 OR xDE.active = 2 ))
				OR (@Status = 2 AND (xDE.active = 1 ))
				)

		AND	((@Status = 0 AND T_services.status = 0)
				OR (@Status = 1 AND (T_services.status = 1 OR T_services.status = 2 ))
				OR (@Status = 2 AND (T_services.status = 1 ))
				) 
--------------------------------------------------------------------		
		AND (
				(@OpenAtHour is null AND @OpenFromHour is null AND @OpenToHour is null AND @OpenNow = 0 AND @ReceptionDays is null )
				OR
				EXISTS
				(SELECT deptCode
				 FROM x_Dept_Employee xDE3
				 JOIN deptEmployeeReception dER on xDE.DeptEmployeeID = dER.DeptEmployeeID
					AND CAST(GETDATE() as date) between ISNULL(dER.validFrom,'1900-01-01') and ISNULL(dER.validTo,'2079-01-01')
				 JOIN deptEmployeeReceptionServices dERS on dER.receptionID = dERS.receptionID
				 LEFT JOIN DeptEmployeeReceptionRemarks DERR ON dER.receptionID = DERR.EmployeeReceptionID
				 LEFT JOIN DIC_GeneralRemarks D_GR ON DERR.RemarkID = D_GR.remarkID
				 WHERE xDE3.DeptEmployeeID = T_services.DeptEmployeeID
				 AND dERS.serviceCode = T_services.ServiceCode
				 AND xDE3.AgreementType in (select * from @AgreementTypeList)
				 AND (@ReceptionDays is null 
					OR dER.receptionDay in (select IntVal from @ReceptionDaysList))
--------------------------					
				AND ((@OpenToHour IS NULL AND @OpenFromHour IS NULL )
						OR
						(	
							(Cast(Left(dER.openingHour,2) as real) + Cast(Right(dER.openingHour,2) as real)/60) < @OpenToHour_real 
								AND 
							((Cast(Left(dER.closingHour,2) as real) + Cast(Right(dER.closingHour,2) as real)/60) > @OpenFromHour_real 
								OR D_GR.EnableOverMidnightHours = 1))

							   OR (openingHour = '00:00' AND closingHour = '00:00')
					)
--------------------------
				AND ((@OpenAtHour IS NULL)
						OR
						(
							(
								(Cast(Left(openingHour,2) as real) + Cast(Right(openingHour,2) as real)/60) <= @OpenAtHour_real 
								AND
								((Cast(Left(closingHour,2) as real) + Cast(Right(closingHour,2) as real)/60) > @OpenAtHour_real 
										OR D_GR.EnableOverMidnightHours = 1)
							)	
						  OR -- close at midnight or after midnight
							(
								(Cast(Left(openingHour,2) as real) + Cast(Right(openingHour,2) as real)/60) <= @OpenAtHour_real 
								AND
								closingHour <= '04:00')						  	
						  OR -- 24 hours
							(
								openingHour = '00:00'
								 AND
								closingHour = '00:00')
						  OR -- starts before midnight and close after midnight
							(
							   (Cast(Left(closingHour,2) as real) + Cast(Right(closingHour,2) as real)/60) > @OpenAtHour_real 
								AND
							   (Cast(Left(closingHour,2) as real) + Cast(Right(closingHour,2) as real)/60) < 
																		(Cast(Left(openingHour,2) as real) + Cast(Right(openingHour,2) as real)/60) 
							) 		  
						)
					)
--------------------------				
				AND((@OpenNow = 0 )
						OR
						(
							(
								(Cast(Left(openingHour,2) as real) + Cast(Right(openingHour,2) as real)/60) <= @OpenAtThisHour 
								AND
								(Cast(Left(closingHour,2) as real) + Cast(Right(closingHour,2) as real)/60) > @OpenAtThisHour 
							)	
						  OR -- close at midnight or after midnight
							(
								(Cast(Left(openingHour,2) as real) + Cast(Right(openingHour,2) as real)/60) <= @OpenAtThisHour 
								AND
								closingHour <= '04:00')						  	
						  OR -- 24 hours
						   (
								openingHour = '00:00' AND
								closingHour = '00:00')
						  OR -- starts before midnight and close after midnight
						   (
							   (Cast(Left(closingHour,2) as real) + Cast(Right(closingHour,2) as real)/60) > @OpenAtThisHour 
								AND
							   (Cast(Left(closingHour,2) as real) + Cast(Right(closingHour,2) as real)/60) < 
																		(Cast(Left(openingHour,2) as real) + Cast(Right(openingHour,2) as real)/60) 
						   ) 		  
						)
					)
--------------------------	
				AND(@GroupCode IS NULL OR vMushlamCervices.GroupCode = @GroupCode)
				AND(@SubGroupCode IS NULL OR vMushlamCervices.SubGroupCode = @SubGroupCode	)
--------------------------					
				)					

			)
		) T

GO

GRANT EXEC ON dbo.rpc_getClinicList_ForPrinting TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_getClinicList_ForPrinting TO [clalit\IntranetDev]
GO 