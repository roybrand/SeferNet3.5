IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_DoctorOverView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[rpc_DoctorOverView]
GO

CREATE Procedure [dbo].[rpc_DoctorOverView]
(
	@employeeID int
)

AS

DECLARE @CurrentDate datetime = GETDATE()
DECLARE @ExpirationDate datetime = DATEADD(day, DATEDIFF(day, 0, @CurrentDate), 0) 
DECLARE @DateAfterExpiration datetime = DATEADD(day, 1, DATEADD(day, DATEDIFF(day, 0, @CurrentDate), 0))

DECLARE @ExcludedService int SET @ExcludedService = 180300

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
'ProfLicenseNumber' = CASE CAST(Employee.ProfessionalLicenseNumber as varchar(10)) WHEN '0' THEN '' ELSE CAST(Employee.ProfessionalLicenseNumber as varchar(10)) END,

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
PrivateHospitalPosition,
EmployeeSector.IsDoctor,
IsVirtualDoctor

FROM Employee
INNER JOIN DIC_EmployeeDegree ON Employee.degreeCode = DIC_EmployeeDegree.DegreeCode
INNER JOIN EmployeeSector ON Employee.EmployeeSectorCode = EmployeeSector.EmployeeSectorCode
LEFT JOIN View_AllDistricts ON Employee.primaryDistrict = View_AllDistricts.districtCode
LEFT JOIN DIC_Gender ON Employee.sex = DIC_Gender.sex
LEFT JOIN DIC_ActivityStatus ON Employee.active = DIC_ActivityStatus.status

WHERE employeeID = @employeeID

-- Clinics where the doctor works --------------------------------
SELECT	DISTINCT 
			xd.DeptEmployeeID, 
			xdes.ServiceCode,
			d.deptCode,
			d.deptName,
			Cities.cityName,
			'address' = dbo.GetAddress(d.deptCode),
			CASE WHEN e.IsMedicalTeam = 1 THEN xdes.ServiceCode ELSE 0 END as ServiceForGrouping,
			isnull(xdes.[Status], 1) as Status,
			IsMedicalTeam,
			IsVirtualDoctor,
			AgreementType,
			'expert' = dbo.fun_GetEmployeeExpert(xd.employeeID),
			'positions' = dbo.fun_GetEmployeeInDeptPositions(xd.employeeID, xd.deptCode, e.sex ),			
			'Phones' = dbo.fun_GetDeptEmployeeServicePhones(xd.DeptEmployeeID,xdes.serviceCode),
			'Faxes' = dbo.fun_GetDeptEmployeeServiceFaxes(xd.DeptEmployeeID,xdes.serviceCode),
			'active' = xd.active,
			'PermitOrderMethods' = IsNull(DIC_QueueOrder.PermitOrderMethods, 0),			
			'EmployeeSectorCode' = 
				CASE WHEN e.IsMedicalTeam = 1 
					 THEN ISNULL( (SELECT TOP 1 CASE WHEN [Services].SectorToShowWith IS NULL 
													 THEN e.EmployeeSectorCode 
													 ELSE [Services].SectorToShowWith END
									FROM [Services]
									WHERE [Services].ServiceCode = xdes.ServiceCode), e.EmployeeSectorCode)
					 ELSE e.EmployeeSectorCode
					 END,
			'QueueOrderDescription' = dbo.fun_GetDeptEmployeeServiceQueueOrderDescription(xdes.DeptEmployeeID, xdes.serviceCode),
			'HasRemarks' = 
			CASE WHEN EXISTS (
							SELECT *
							FROM View_DeptEmployee_EmployeeRemarks v
							WHERE (v.DeptCode = xd.DeptCode OR AttributedToAllClinicsInCommunity = 1)
							AND (v.EmployeeID = @EmployeeID)
							AND (v.ValidFrom is NULL OR v.ValidFrom < @DateAfterExpiration)
							AND (v.ValidTo is NULL OR v.ValidTo >= @ExpirationDate) 
							)							 
				THEN 1
				WHEN EXISTS (
							SELECT *
							FROM DeptEmployeeServiceRemarks desr
							INNER JOIN x_Dept_Employee_Service xdes1 on desr.x_dept_employee_serviceID = xdes1.x_Dept_Employee_ServiceID
							WHERE xdes1.DeptEmployeeID = xd.DeptEmployeeID
							AND (ValidFrom is NULL OR ValidFrom < @DateAfterExpiration)
							AND (ValidTo is NULL OR ValidTo >= @ExpirationDate)
							AND xdes1.serviceCode = xdes.serviceCode)							 
				THEN 1 
				WHEN EXISTS (
							SELECT * 
							from View_DeptRemarks
							JOIN DIC_GeneralRemarks GR ON View_DeptRemarks.DicRemarkID = GR.remarkID
							WHERE View_DeptRemarks.deptCode = xd.deptCode
							AND (ValidFrom is NULL OR ValidFrom < @DateAfterExpiration)
							AND (ValidTo is NULL OR ValidTo >= @ExpirationDate)
						) THEN 1	

				WHEN EXISTS ( -- This is NEW 16
							SELECT * 
							FROM deptEmployeeReception der
							JOIN deptEmployeeReceptionServices ders ON der.receptionID = ders.receptionID 
							JOIN DeptEmployeeReceptionRemarks derr ON derr.EmployeeReceptionID = der.receptionID
							WHERE der.DeptEmployeeID = xd.DeptEmployeeID  
							AND ders.serviceCode = xdes.serviceCode
							AND (@CurrentDate between ISNULL(der.ValidFrom,'1900-01-01') and ISNULL(der.ValidTo,'2079-01-01'))
						) THEN 1
				ELSE 0 END,							
			'ReceptionDaysCount' = (SELECT Count(*) 
									FROM 
									(	
										SELECT receptionDay
										FROM deptEmployeeReception der
										INNER JOIN DeptEmployeeReceptionServices ders ON der.receptionID = ders.receptionID
										INNER JOIN x_dept_employee_service xdes2 ON ders.serviceCode = xdes2.serviceCode 
													AND xdes2.DeptEmployeeID = xd.DeptEmployeeID 
													and ders.serviceCode = xdes.serviceCode
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
	INNER JOIN Dept d ON xd.deptCode = d.deptCode
	INNER JOIN Cities ON d.cityCode = Cities.cityCode
	INNER JOIN Employee e ON xd.employeeID = e.employeeID
	INNER JOIN DIC_EmployeeDegree ON e.degreeCode = DIC_EmployeeDegree.DegreeCode --??
	LEFT JOIN DIC_QueueOrder ON xd.QueueOrder = DIC_QueueOrder.QueueOrder
	LEFT JOIN x_Dept_Employee_Service xdes ON xd.DeptEmployeeID = xdes.DeptEmployeeID
					AND xdes.Status = 1
					AND xdes.ServiceCode <> @ExcludedService
	WHERE xd.employeeID = @EmployeeID

SELECT	DISTINCT xd.DeptEmployeeID, 
		xdes.ServiceCode,
		CASE WHEN e.IsMedicalTeam = 1 THEN xdes.ServiceCode ELSE 0 END as ServiceForGrouping,
		'Phones' = dbo.fun_GetDeptEmployeeServicePhones(xd.DeptEmployeeID,xdes.serviceCode),
		'QueueOrderDescription' = dbo.fun_GetDeptEmployeeServiceQueueOrderDescription(xdes.DeptEmployeeID, xdes.serviceCode),
		'QueueOrderMethod' = dbo.fun_GetEmployeeServiceQueueOrderMethod(xdes.DeptEmployeeID, xdes.serviceCode),
		'QueueOrderPhone' = dbo.fun_GetEmployeeServiceQueueOrderPhones(xdes.DeptEmployeeID , xdes.serviceCode),
		'EmployeeSectorCode' = 
			CASE WHEN e.IsMedicalTeam = 1 
				 THEN ISNULL( (SELECT TOP 1 CASE WHEN [Services].SectorToShowWith IS NULL 
												THEN e.EmployeeSectorCode 
												ELSE [Services].SectorToShowWith END
								FROM [Services]
								WHERE [Services].ServiceCode = xdes.ServiceCode), e.EmployeeSectorCode)
				 ELSE e.EmployeeSectorCode
			     END,
		 xd.AgreementType
INTO #tempGroup
FROM x_Dept_Employee xd
INNER JOIN Employee e on xd.employeeID = e.employeeID
INNER JOIN DIC_EmployeeDegree ON e.degreeCode = DIC_EmployeeDegree.DegreeCode
LEFT JOIN x_Dept_Employee_Service xdes on xd.DeptEmployeeID = xdes.DeptEmployeeID
		AND xdes.Status = 1
		AND xdes.ServiceCode <> @ExcludedService
WHERE xd.employeeID = @EmployeeID		

SELECT	DeptEmployeeID, 
		 stuff((SELECT ',' + CONVERT(VARCHAR,ServiceCode) 
		 FROM #tempGroup tgd2
		 WHERE tgd2.DeptEmployeeID = tgd.DeptEmployeeID
		 AND tgd2.Phones = tgd.Phones
		 AND tgd2.QueueOrderPhone = tgd.QueueOrderPhone
		 AND tgd2.EmployeeSectorCode = tgd.EmployeeSectorCode
		 AND tgd2.QueueOrderDescription = tgd.QueueOrderDescription
		 AND tgd2.QueueOrderMethod = tgd.QueueOrderMethod
		 AND tgd2.AgreementType = tgd.AgreementType
		 AND tgd2.ServiceForGrouping = tgd.ServiceForGrouping		 
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
		 AND tgd2.AgreementType = tgd.AgreementType
		 AND tgd2.ServiceForGrouping = tgd.ServiceForGrouping		 
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
		 AND tgd2.AgreementType = tgd.AgreementType
		 AND tgd2.ServiceForGrouping = tgd.ServiceForGrouping
		 AND ser.IsProfession = 1
		 order by serviceDescription
		 for xml path ('')
		 ), 1, 1, '') as 'Professions', 

		Phones, QueueOrderDescription, QueueOrderPhone, EmployeeSectorCode					
INTO #tempGroupingDoctors		
FROM #tempGroup tgd
GROUP BY DeptEmployeeID, Phones, QueueOrderDescription, QueueOrderPhone,
	 QueueOrderMethod, EmployeeSectorCode, AgreementType, ServiceForGrouping

	-- actual select
SELECT 	DeptEmployeeID, ToggleID,
		deptCode, deptName,	cityName, [address],
		expert, PhonesOnly, Fax,
		EmployeeSectorCode, [Status], IsMedicalTeam, IsVirtualDoctor, 
		[Services], ServiceDescription, Professions,
		QueueOrderDescription, QueueOrderPhone, AgreementType,
		positions, PermitOrderMethods,
		max(ReceptionDaysCount) as ReceptionDaysCount, max(HasRemarks) as RemarksCount
		, ReceiveGuests	
FROM (	
	SELECT td.DeptEmployeeID, 
			'ToggleID' = REPLACE(CONVERT(VARCHAR,td.DeptEmployeeID) + CONVERT(VARCHAR,tgd.[Services]), ',', '') + CAST(td.ServiceForGrouping as varchar(10)), 
			td.deptCode, td.deptName,	td.cityName, td.[address],
			td.expert, td.Phones as PhonesOnly, td.Faxes as Fax,
			td.EmployeeSectorCode, td.Active as [Status], td.IsMedicalTeam, td.IsVirtualDoctor, 
			tgd.[Services], tgd.ServiceDescription, tgd.Professions,
			td.QueueOrderDescription, QueueOrderPhone, td.AgreementType,
			td.positions, PermitOrderMethods,
			ReceptionDaysCount, td.HasRemarks
			, EmployeeInClinic_preselected.ReceiveGuests
	FROM #tempDoctors td
	INNER JOIN #tempGroupingDoctors tgd on td.DeptEmployeeID = tgd.DeptEmployeeID
	AND td.Phones = tgd.Phones
	AND td.EmployeeSectorCode = tgd.EmployeeSectorCode
	AND (td.ServiceCode in (SELECT IntField FROM dbo.SplitString(tgd.[Services])) OR td.ServiceCode IS NULL)
	and td.[Status] <> 0
	JOIN EmployeeInClinic_preselected ON td.DeptEmployeeID = EmployeeInClinic_preselected.DeptEmployeeID
	) as T
	
	group by DeptEmployeeID, ToggleID, 
			deptCode, deptName,	cityName, [address],
			expert, PhonesOnly, Fax,
			EmployeeSectorCode, [Status], IsMedicalTeam, IsVirtualDoctor, 
			[Services], ServiceDescription, Professions,
			QueueOrderDescription, QueueOrderPhone, AgreementType,
			positions, PermitOrderMethods, ReceiveGuests
	ORDER BY EmployeeSectorCode DESC
-- END of Clinics where the doctor works --------------------------------

-------- Doctor's Hours in Clinics (doctorReceptionHours) -------------------
SELECT DISTINCT
xd.deptCode,
Dept.deptName,
DER.receptionID,
xd.EmployeeID,
DER.receptionDay,
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
DER.closingHour,
'receptionRemarks' = IsNull(REPLACE(DERR.RemarkText, '#', ''), ''),
'professions&services' = [dbo].[fun_GetProfessionsAndServicesForEmployeeReception](DER.receptionID),
'willExpireIn' = DATEDIFF(day, @CurrentDate, IsNull(DER.validTo,'01/01/2050')),
'expirationDate' = DER.validTo

FROM deptEmployeeReception DER
INNER JOIN vReceptionDaysForDisplay ON DER.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode
INNER JOIN x_Dept_Employee xd ON DER.DeptEmployeeID = xd.DeptEmployeeID
INNER JOIN dept ON xd.deptCode = dept.deptCode
LEFT JOIN DeptEmployeeReceptionServices ders ON DER.ReceptionID = ders.ReceptionID
LEFT JOIN x_dept_employee_service xdes ON ders.ServiceCode = xdes.ServiceCode
	AND xd.DeptEmployeeID = xdes.DeptEmployeeID
LEFT JOIN DeptEmployeeReceptionRemarks DERR ON DER.receptionID = DERR.EmployeeReceptionID
WHERE xd.employeeID = @employeeID
AND (
		(   
			((DER.validFrom IS not NULL and DER.validTo IS NULL) and (@CurrentDate >= DER.validFrom ))			
			or ((DER.validFrom IS NULL and DER.validTo IS not NULL) and DER.validTo >= @CurrentDate)
			or ((DER.validFrom IS not NULL and DER.validTo IS not NULL) and (@CurrentDate >= DER.validFrom and DER.validTo >= @CurrentDate))
		)
		OR (DER.validFrom IS NULL AND DER.validTo IS NULL)
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
AND DATEDIFF(dd, ValidFrom, @CurrentDate) < 0
AND DATEDIFF(dd, ValidFrom, @CurrentDate) >= -14

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
			((validFrom IS not NULL and  validTo IS NULL) and (@CurrentDate >= validFrom ))			
			or ((validFrom IS NULL and validTo IS not NULL) and validTo >= @CurrentDate)
			or ((validFrom IS not NULL and  validTo IS not NULL) and (@CurrentDate >= validFrom and validTo >= @CurrentDate))
	
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
v_DE_ER.displayInInternet,
DIC_r.RemarkCategoryID

from View_DeptEmployee_EmployeeRemarks as v_DE_ER
JOIN DIC_GeneralRemarks DIC_r ON v_DE_ER.DicRemarkID = DIC_r.remarkID
		where v_DE_ER.EmployeeID = @EmployeeID
		AND (v_DE_ER.ValidFrom is null OR DATEDIFF(dd, v_DE_ER.ValidFrom ,@CurrentDate) >= 0)
		AND (v_DE_ER.ValidTo is null OR DATEDIFF(dd, v_DE_ER.ValidTo ,@CurrentDate) <= 0)
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
		AND (v_DE_ER.ValidFrom is null OR DATEDIFF(dd, v_DE_ER.ValidFrom ,@CurrentDate) >= 0)
		AND (v_DE_ER.ValidTo is null OR DATEDIFF(dd, v_DE_ER.ValidTo ,@CurrentDate) <= 0)
		and(v_DE_ER.EmpRemarkDeptCode > 0
		or v_DE_ER.AttributedToAllClinicsInCommunity = 1)
ORDER BY remarkIsGlobal DESC

------- EmployeeQueueOrderMethods (Employee Queue Order Methods) --------------
SELECT 
EQOM.QueueOrderMethod,
xd.deptCode,
xd.employeeID,
xd.DeptEmployeeID,
'serviceCode' = 0,
DIC_QueueOrderMethod.QueueOrderMethodDescription,
DIC_QueueOrderMethod.ShowPhonePicture,
DIC_QueueOrderMethod.SpecialPhoneNumberRequired

FROM EmployeeQueueOrderMethod EQOM
INNER JOIN DIC_QueueOrderMethod ON EQOM.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
INNER JOIN x_dept_employee xd ON EQOM.DeptEmployeeID = xd.DeptEmployeeID	
WHERE xd.employeeID = @EmployeeID

UNION

SELECT 
esqom.QueueOrderMethod,
xd.deptCode,
xd.employeeID,
xd.DeptEmployeeID,
xdes.serviceCode,
DIC_QueueOrderMethod.QueueOrderMethodDescription,
DIC_QueueOrderMethod.ShowPhonePicture,
DIC_QueueOrderMethod.SpecialPhoneNumberRequired

FROM EmployeeServiceQueueOrderMethod esqom
INNER JOIN x_Dept_Employee_Service xdes ON esqom.x_dept_employee_serviceID = xdes.x_dept_employee_serviceID
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
INNER JOIN DIC_QueueOrderMethod ON esqom.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
WHERE xd.employeeID = @EmployeeID
AND xdes.Status = 1
AND xdes.serviceCode <> @ExcludedService

UNION

-- get all cases where queue order is regular, but need to display with special icon
SELECT 
'5' as 'QueueOrderMethod',
xd.deptCode,
xd.employeeID,
xd.DeptEmployeeID,
xdes.serviceCode,

null,
null,
null

FROM x_Dept_Employee_Service xdes 
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
WHERE xd.employeeID = @EmployeeID
AND xd.QueueOrder = 4 
AND xdes.ServiceCode <> @ExcludedService
------- HoursForEmployeeQueueOrder (Hours for Employee Queue Order via Phone) --------------
SELECT
xd.deptCode,
xd.employeeID,
xd.DeptEmployeeID,
0 as serviceCode,
eqoh.receptionDay,
ReceptionDayName,
CASE WHEN FromHour = '00:00' AND ToHour = '00:00' THEN '24' ELSE FromHour END as FromHour,
CASE WHEN FromHour = '00:00' AND ToHour = '00:00' THEN 'שעות' ELSE ToHour END as ToHour,
vReceptionDaysForDisplay.ReceptionDayCode

FROM EmployeeQueueOrderHours eqoh
INNER JOIN vReceptionDaysForDisplay ON eqoh.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode
INNER JOIN EmployeeQueueOrderMethod eqom ON eqoh.QueueOrderMethodID = eqom.QueueOrderMethodID
INNER JOIN x_dept_employee xd ON eqom.DeptEmployeeID = xd.DeptEmployeeID
WHERE xd.employeeID = @EmployeeID

UNION

SELECT 
xd.deptCode,
xd.employeeID,
xd.DeptEmployeeID,
xdes.serviceCode,
esqoh.ReceptionDay,
ReceptionDayName,
CASE WHEN FromHour = '00:00' AND ToHour = '00:00' THEN '24' ELSE FromHour END as FromHour,
CASE WHEN FromHour = '00:00' AND ToHour = '00:00' THEN 'שעות' ELSE ToHour END as ToHour,
vReceptionDaysForDisplay.ReceptionDayCode

FROM EmployeeServiceQueueOrderHours esqoh
INNER JOIN vReceptionDaysForDisplay ON esqoh.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode
INNER JOIN EmployeeServiceQueueOrderMethod esqom ON esqoh.EmployeeServiceQueueOrderMethodID = esqom.EmployeeServiceQueueOrderMethodID
INNER JOIN x_Dept_Employee_Service xdes ON esqom.x_Dept_Employee_ServiceID = xdes.x_Dept_Employee_ServiceID
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
WHERE xd.employeeID = @EmployeeID
AND xdes.ServiceCode <> @ExcludedService
ORDER BY ReceptionDayCode, FromHour

-- DeptEmployeeServices (Employee's services) ***************************

SELECT 
DISTINCT [Services].serviceDescription, xdes.serviceCode
FROM x_Dept_Employee_Service as xdes
INNER JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
INNER JOIN [Services] ON xdes.serviceCode = [Services].serviceCode
WHERE xd.employeeID = @employeeID
AND Status = 1
AND [Services].ServiceCode <> @ExcludedService

GO

GRANT EXEC ON dbo.rpc_DoctorOverView TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_DoctorOverView TO [clalit\IntranetDev]
GO
