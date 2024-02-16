IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeptOverView')
	BEGIN
		DROP  Procedure  rpc_DeptOverView		
	END

GO

CREATE Procedure [dbo].[rpc_DeptOverView]
(
	@DeptCode int,
	@RemarkCategoriesForAbsence varchar(50),
	@RemarkCategoriesForClinicActivity varchar(50)
)

AS

DECLARE @p_str VARCHAR(500)
SET @p_str = ''

DECLARE @CurrentDate datetime = getdate()
DECLARE @ExpirationDate datetime = DATEADD(day, DATEDIFF(day, 0, @CurrentDate), 0) 
DECLARE @DateAfterExpiration datetime = DATEADD(day, 1, DATEADD(day, DATEDIFF(day, 0, @CurrentDate), 0))

SELECT ItemID as RemarkCategoryID 
INTO #RemarkCategoriesForAbsence
FROM [dbo].[rfn_SplitStringValues](@RemarkCategoriesForAbsence)

SELECT ItemID as RemarkCategoryID 
INTO #RemarkCategoriesForClinicActivity
FROM [dbo].[rfn_SplitStringValues](@RemarkCategoriesForClinicActivity)

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
'geriatricsManagerName' = dbo.fun_getGeriatricsManagerName(Dept.deptCode),
'pharmacologyManagerName' = dbo.fun_getPharmacologyManagerName(Dept.deptCode),
'deputyHeadOfDepartment' = dbo.fun_getDeputyHeadOfDepartment(Dept.deptCode),
'secretaryName' = dbo.fun_getSecretaryName(Dept.deptCode),
Dept.districtCode,
'additionaDistrictNames' = dbo.fun_GetAdditionalDistrictNames(@deptCode), 
View_AllDistricts_Extended.districtName,
Cities.cityName,
Dept.streetName as 'street',
Dept.house,
Dept.floor,
Dept.flat,
Dept.building,
Dept.addressComment,
Dept.email,
'showEmailInInternet' = isNull(Dept.showEmailInInternet, 0),
'address' = dbo.GetAddress(Dept.deptCode),
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
Dept.ParentClinic as parentClinicCode,
'parentClinicName' = (SELECT DeptName FROM Dept d WHERE deptCode = Dept.ParentClinic),
DeptSimul.Simul228, 
'phonesForQueueOrder' = dbo.fun_getDeptQueueOrderPhones_All(@DeptCode),
'QueueOrderDescription' = IsNull(DIC_QueueOrder.QueueOrderDescription, '&nbsp;'),					
'HasQueueOrder' = CASE IsNull(Dept.QueueOrder,0) WHEN 0 THEN 0 ELSE 1 END,
'HasMedicalAspects' = CASE IsNull((SELECT COUNT(*) FROM x_dept_medicalAspect WHERE NewDeptCode = @DeptCode), 0) WHEN 0 THEN 0 ELSE 1 END,
deptLevelDescription,
View_SubUnitTypes.DefaultReceptionHoursTypeID,
Dept.showUnitInInternet

FROM Dept 
INNER JOIN UnitType on Dept.typeUnitCode = UnitType.UnitTypeCode
INNER JOIN DIC_deptLevel on Dept.deptLevel = DIC_deptLevel.deptLevelCode
LEFT JOIN View_SubUnitTypes on Dept.subUnitTypeCode = View_SubUnitTypes.subUnitTypeCode
	AND Dept.typeUnitCode = View_SubUnitTypes.UnitTypeCode
LEFT JOIN View_AllDistricts_Extended on Dept.districtCode = View_AllDistricts_Extended.districtCode
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
SELECT View_DeptRemarks.RemarkID
, REPLACE(dbo.rfn_GetFotmatedRemark(RemarkText),'-', '&minus;') as RemarkText
, displayInInternet
, RemarkDeptCode as deptCode
, View_DeptRemarks.IsSharedRemark as 'sweeping' 
,GenRem.RemarkCategoryID
FROM View_DeptRemarks
JOIN DIC_GeneralRemarks GenRem ON View_DeptRemarks.DicRemarkID = GenRem.remarkID
LEFT JOIN Dept ON View_DeptRemarks.deptCode = Dept.deptCode
LEFT JOIN #RemarkCategoriesForClinicActivity CatAct ON GenRem.RemarkCategoryID = CatAct.RemarkCategoryID
WHERE View_DeptRemarks.deptCode = @deptCode
AND validFrom < @DateAfterExpiration AND ( validTo is null OR validTo >= @ExpirationDate )
AND (IsSharedRemark = 0 OR Dept.IsCommunity = 1) 
ORDER BY CatAct.RemarkCategoryID DESC, sweeping desc,
	View_DeptRemarks.validFrom, View_DeptRemarks.updateDate
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
,msi.GroupCode, msi.SubGroupCode
FROM x_dept_employee_service xdes
INNER JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID 
INNER JOIN Dept d ON xd.deptCode = d.deptCode
INNER JOIN MushlamServicesToSefer msts on xdes.ServiceCode = msts.SeferCode
INNER JOIN MushlamServicesInformation msi on msts.SeferCode = msi.ServiceCode
WHERE xd.DeptCode = @deptCode
AND xd.AgreementType IN (3,4)
AND ((d.typeUnitCode = 112 and xdes.serviceCode = 180300) 
	or (d.typeUnitCode <> 112 and xdes.serviceCode <> 180300))

UNION 

SELECT msi.ServiceCode,
msi.MushlamServiceName + ' - ' + mtts.Description as ServiceName
,msi.GroupCode, msi.SubGroupCode
FROM x_dept_employee_service xdes
INNER JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID 
INNER JOIN Dept d ON xd.deptCode = d.deptCode
INNER JOIN MushlamTreatmentTypesToSefer mtts ON xdes.serviceCode = mtts.SeferCode
INNER JOIN MushlamServicesInformation msi on mtts.ParentServiceID = msi.ServiceCode
WHERE xd.DeptCode = @deptCode
AND xd.AgreementType IN (3,4)
AND ((d.typeUnitCode = 112 and xdes.serviceCode = 180300) 
	or (d.typeUnitCode <> 112 and xdes.serviceCode <> 180300))
ORDER BY msi.MushlamServiceName


-- DeptPhones   ***************************
SELECT
deptCode, DeptPhones.phoneType, phoneOrder, remark, 
'phone' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension),
'ShortPhoneTypeName' = CASE DeptPhones.phoneType WHEN 2 THEN 'פקס' ELSE 'טל`' END
FROM DeptPhones
WHERE deptCode = @DeptCode
ORDER BY DeptPhones.phoneType, phoneOrder

------ Employee remarks -------------------------------------------------------------

--using  View_DeptEmployee_EmployeeRemarks includes EmployeeRemarks  per dept 
-- and EmployeeRemarks Attributed ToAll Clinics InCommunity, ..InMushlam, ..InHospitals 
-- according to Dept Membership Type
	
SELECT distinct
dbo.rfn_GetFotmatedRemark(v_DE_ER.RemarkTextFormated) as remark
,v_DE_ER.displayInInternet, '' as ServiceName, 0 as ServiceCode
,v_DE_ER.EmployeeID
,Employee.lastName
,Employee.IsMedicalTeam
,DIC_EmployeeDegree.DegreeName + ' ' + Employee.lastName + ' ' +  Employee.firstName as EmployeeName
,GenRem.RemarkCategoryID
,CASE WHEN CATABS.RemarkCategoryID IS null THEN 0 ELSE 1 END as AbsenceRemark
,v_DE_ER.ValidFrom
,v_DE_ER.updateDate

INTO #Remarks

from View_DeptEmployee_EmployeeRemarks as v_DE_ER
JOIN Employee ON v_DE_ER.EmployeeID = Employee.employeeID
JOIN DIC_EmployeeDegree ON Employee.degreeCode = DIC_EmployeeDegree.DegreeCode
JOIN DIC_GeneralRemarks GenRem ON v_DE_ER.DicRemarkID = GenRem.remarkID
JOIN DIC_RemarkCategory RemCat ON GenRem.RemarkCategoryID = RemCat.RemarkCategoryID
JOIN x_Dept_Employee xde ON v_DE_ER.DeptEmployeeID = xde.DeptEmployeeID
LEFT JOIN #RemarkCategoriesForAbsence CATABS ON GenRem.RemarkCategoryID = CATABS.RemarkCategoryID
WHERE v_DE_ER.DeptCode = @DeptCode
AND Employee.EmployeeSectorCode = 7
AND (v_DE_ER.ValidFrom is null OR DATEDIFF(dd, v_DE_ER.ValidFrom ,@ExpirationDate) >= 0)
AND (v_DE_ER.ValidTo is null OR DATEDIFF(dd, v_DE_ER.ValidTo ,@ExpirationDate) <= 0)	
AND Employee.active = 1
AND xde.active = 1

------ Service remarks -------------------------------------------------------------
UNION

SELECT
dbo.rfn_GetFotmatedRemark(desr.RemarkText) as remark
,displayInInternet, ServiceDescription + ': &nbsp;' as ServiceName, xdes.ServiceCode 
,xd.employeeID
,Employee.lastName
,Employee.IsMedicalTeam
,DIC_EmployeeDegree.DegreeName + ' ' + Employee.lastName + ' ' +  Employee.firstName as EmployeeName
,GenRem.RemarkCategoryID
,CASE WHEN CATABS.RemarkCategoryID IS null THEN 0 ELSE 1 END as AbsenceRemark
,desr.ValidFrom
,desr.updateDate 

FROM view_DeptEmployeeServiceRemarks desr
JOIN DIC_GeneralRemarks GenRem ON desr.RemarkID = GenRem.remarkID
INNER JOIN x_Dept_Employee_Service xdes ON desr.x_dept_employee_serviceID = xdes.x_dept_employee_serviceID
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
INNER JOIN [Services] ON xdes.ServiceCode = [Services].ServiceCode AND xdes.Status = 1
JOIN Employee ON xd.EmployeeID = Employee.employeeID
JOIN DIC_EmployeeDegree ON Employee.degreeCode = DIC_EmployeeDegree.DegreeCode
LEFT JOIN #RemarkCategoriesForAbsence CATABS ON GenRem.RemarkCategoryID = CATABS.RemarkCategoryID

WHERE xd.DeptCode = @DeptCode

AND (ValidFrom is NULL OR DATEDIFF(dd, ValidFrom ,@ExpirationDate) >= 0 )
AND (ValidTo is NULL OR  DATEDIFF(dd, ValidTo ,@ExpirationDate) <= 0 )
AND xd.active = 1

SELECT DISTINCT employeeID, AbsenceRemark as HasAbsenceRemark
INTO #Absence
FROM #Remarks
WHERE AbsenceRemark = 1

SELECT *
FROM #Remarks
LEFT JOIN #Absence ON #Remarks.employeeID = #Absence.employeeID
ORDER BY #Absence.HasAbsenceRemark DESC,#Remarks.IsMedicalTeam,  #Remarks.lastName, #Remarks.AbsenceRemark DESC
	, #Remarks.ValidFrom, #Remarks.updateDate


GO

GRANT EXEC ON rpc_DeptOverView TO PUBLIC
GO


