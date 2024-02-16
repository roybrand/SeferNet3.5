/* rpc_DoctorOverView  
 new JOIN:
 . . .
 	JOIN EmployeeInClinic_preselected ON td.DeptEmployeeID = EmployeeInClinic_preselected.DeptEmployeeID
*/
ALTER Procedure [dbo].[rpc_DoctorOverView]
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

/* rpc_UpdateDeptStatus  
 CHANGE :
 ORDER BY fromDate desc, StatusID desc
	instead of
 ORDER BY fromDate desc
*/
ALTER Procedure [dbo].[rpc_UpdateDeptStatus]
(
	@DeptCode int = null,
	@UpdateUser varchar(50),
	@CurrentStatus int OUTPUT
)
AS

DECLARE @currentDate datetime SET @currentDate = GETDATE()
DECLARE @DeptStatus int SET @DeptStatus = null

SET @DeptStatus = IsNull((SELECT TOP 1 Status FROM DeptStatus
				  WHERE deptCode = @DeptCode
				  AND fromDate <= @currentDate
				  ORDER BY fromDate desc, StatusID desc), -1)

SET @CurrentStatus = @DeptStatus

UPDATE Dept
SET Dept.status = @DeptStatus,
Dept.updateUser = @UpdateUser
WHERE Dept.DeptCode = @DeptCode
AND @DeptStatus <> -1
AND Dept.status <> @DeptStatus

GO

/* rpc_getDic_GeneralRemarksByRemarkID  
 CHANGE :
New fields: OpenNow,ShowForPreviousDays
*/
ALTER Procedure [dbo].[rpc_getDic_GeneralRemarksByRemarkID]
(
	@remarkID int
)

AS
Select 
remarkID,
remark,
active,
RemarkCategoryID,
EnableOverlappingHours,
linkedToDept,
linkedToDoctor,
linkedToDoctorInClinic,
linkedToServiceInClinic,
linkedToReceptionHours,
Factor,
OpenNow,
ShowForPreviousDays
From 
DIC_GeneralRemarks
where
remarkID = @remarkID

GO

/* rpc_InsertDic_GeneralRemark  
 CHANGE :
New fields: OpenNow,ShowForPreviousDays
*/
ALTER Procedure [dbo].[rpc_InsertDic_GeneralRemark]
(
		@remark varchar(500),
		@remarkCategoryID int,
		@active bit,
		@linkedToDept bit = 0,
		@linkedToDoctor bit = 0,
		@linkedToDoctorInClinic bit = 0,
		@linkedToServiceInClinic bit = 0,
		@linkedToReceptionHours bit = 0,
		@EnableOverlappingHours bit = 0,
		@factor float = 1,
		@openNow bit,
		@showForPreviousDays int,
		@UserName varchar(50)
	)
AS
	insert into
	DIC_GeneralRemarks
	(remark,
	RemarkCategoryID,
	active,
	linkedToDept,
	linkedToDoctor,
	linkedToDoctorInClinic,
	linkedToServiceInClinic,
	linkedToReceptionHours,
	EnableOverlappingHours,
	factor,
	OpenNow,
	ShowForPreviousDays,
	UpdateUser,
	UpdateDate)
	VALUES
	(@remark,
	@remarkCategoryID,
	@active,
	@linkedToDept,
	@linkedToDoctor,
	@linkedToDoctorInClinic,
	@linkedToServiceInClinic,
	@linkedToReceptionHours,
	@EnableOverlappingHours,
	@factor,
	@openNow,
	@showForPreviousDays,
	@UserName,
	getdate())

	GO


/* rpc_insertDeptRemark  
 CHANGE :
New field to update: "ActiveFrom"
*/
ALTER Procedure [dbo].[rpc_insertDeptRemark]
(
	@remarkDicID INT,
	@remarkText VARCHAR(500),
	@deptCode INT,
	@validFrom DATETIME,
	@validTo DATETIME,
	@displayInInternet BIT,
	@updateUser VARCHAR(50)
)
 
AS

IF @validFrom <= cast('1/1/1900 12:00:00 AM' as datetime)
	BEGIN
		SET @validFrom = null
	END	

IF @validTo <= cast('1/1/1900 12:00:00 AM' as datetime)
	BEGIN
		SET @validTo = null
	END		

DECLARE @maxShowOrder INT
SELECT @maxShowOrder = MAX(ShowOrder) 
					FROM DeptRemarks
					WHERE DeptCode = @deptCode

IF @maxShowOrder IS NULL
	SET @maxShowOrder = 0

SET @maxShowOrder = @maxShowOrder + 1


INSERT INTO DeptRemarks
(DicRemarkID, RemarkText, DeptCode, ValidFrom, ValidTo,
				DisplayInInternet, ShowOrder, ActiveFrom, UpdateDate, UpdateUser)
VALUES
( @remarkDicID, @remarkText, @deptCode, @validFrom, @validTo, 
				@displayInInternet, @maxShowOrder,
				DATEADD(dd, - (SELECT DIC_GeneralRemarks.ShowForPreviousDays FROM DIC_GeneralRemarks WHERE DIC_GeneralRemarks.remarkID = @remarkDicID), @validFrom),
				GetDate(), @updateUser)

GO

/* rpc_UpdateDeptRemark  
 CHANGE :
New field to update: "ActiveFrom"
*/
ALTER PROCEDURE [dbo].[rpc_UpdateDeptRemark]
	(
		@remarkID int,
		@remarkText varchar(500),
		@validFrom datetime,
		@validTo datetime,
		@displayInInternet int,
		@showOrder INT,
		@updateUser varchar(50),
		@ErrCode int OUTPUT
	)


AS

	UPDATE DeptRemarks
	SET RemarkText = @remarkText,
	validFrom = @validFrom,
	validTo = @validTo,
	displayInInternet = @displayInInternet,
	showOrder = @showOrder,
	ActiveFrom = DATEADD(dd, - (SELECT DIC_GeneralRemarks.ShowForPreviousDays FROM DIC_GeneralRemarks WHERE DIC_GeneralRemarks.remarkID = DeptRemarks.DicRemarkID), @validFrom),
	updateUser = @updateUser,
	updateDate = getdate()
	FROM DeptRemarks
	JOIN DIC_GeneralRemarks ON DeptRemarks.DicRemarkID = DIC_GeneralRemarks.remarkID
	WHERE DeptRemarkID = @remarkID
	
	SET @ErrCode = @@Error

GO

/* View_Remarks  
 CHANGE :
New: "DeptRemarks.ActiveFrom as validFrom" instead of "DeptRemarks.validFrom"
*/
ALTER VIEW [dbo].[View_Remarks]
AS

select 
DeptRemarks.[DeptRemarkID]
,DeptRemarks.deptCode
,DeptRemarks.[DicRemarkID]
,DeptRemarks.[RemarkText]
,DeptRemarks.ActiveFrom as validFrom
,DeptRemarks.[validTo]
,DeptRemarks.[displayInInternet]
,DeptRemarks.[updateDate]
,DeptRemarks.[updateUser]
,isnull(SweepingDeptRemarks_District.[districtCode], -1) as districtCode
,isnull(SweepingDeptRemarks_Admin.[administrationCode], -1) as administrationCode
,isnull(SweepingDeptRemarks_UnitType.[UnitTypeCode], -1) as UnitTypeCode
,isnull(SweepingDeptRemarks_SubUnitType.[SubUnitTypeCode], -1) as SubUnitTypeCode
,isnull(SweepingDeptRemarks_PopulationSector.[PopulationSectorCode], -1) as PopulationSector
,isnull(SweepingDeptRemarks_City.cityCode, -1) as cityCode
,isnull(SweepingDeptRemarks_Service.serviceCode, -1) as serviceCode
,DeptRemarks.[ShowOrder]
from DeptRemarks
left join SweepingDeptRemarks_District on DeptRemarks.DeptRemarkID = SweepingDeptRemarks_District.DeptRemarkID
left join SweepingDeptRemarks_Admin	 on DeptRemarks.DeptRemarkID = SweepingDeptRemarks_Admin.DeptRemarkID
left join SweepingDeptRemarks_PopulationSector on DeptRemarks.DeptRemarkID = SweepingDeptRemarks_PopulationSector.DeptRemarkID
left join SweepingDeptRemarks_UnitType on DeptRemarks.DeptRemarkID = SweepingDeptRemarks_UnitType.DeptRemarkID
left join SweepingDeptRemarks_SubUnitType on DeptRemarks.DeptRemarkID = SweepingDeptRemarks_SubUnitType.DeptRemarkID

left join SweepingDeptRemarks_City on DeptRemarks.DeptRemarkID = SweepingDeptRemarks_City.DeptRemarkID
left join SweepingDeptRemarks_Service on DeptRemarks.DeptRemarkID = SweepingDeptRemarks_Service.DeptRemarkID

GO

/* rpc_insertEmployeeRemarks  
 CHANGE :
	New field to add - "ActiveFrom" */
ALTER Procedure [dbo].[rpc_insertEmployeeRemarks]
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

IF @validTo > cast('6/6/2079 12:00:00 AM' as datetime)
	BEGIN
		SET  @validTo = '2079-06-06'
	END	
	
	INSERT INTO EmployeeRemarks 
	(EmployeeID, RemarkText, DicRemarkID, displayInInternet, AttributedToAllClinicsInCommunity , ValidFrom, ValidTo, ActiveFrom, updateDate, updateUser)
	VALUES 
	(@EmployeeID, @RemarkText, @dicRemarkID, @displayInInternet, @attributedToAllClinics, @ValidFrom, @ValidTo, 
		DATEADD(dd, - (SELECT DIC_GeneralRemarks.ShowForPreviousDays FROM DIC_GeneralRemarks WHERE DIC_GeneralRemarks.remarkID = @dicRemarkID), @validFrom),
		getdate(), @updateUser)
	
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

/* rpc_updateEmployeeRemarks  
 CHANGE :
New field to update - "ActiveFrom" */
ALTER Procedure [dbo].[rpc_updateEmployeeRemarks]
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
SET RemarkText = @remarkText,
validFrom = @validFrom,
validTo = @validTo,
displayInInternet = @displayInInternet,
ActiveFrom = DATEADD(dd, - (SELECT DIC_GeneralRemarks.ShowForPreviousDays FROM DIC_GeneralRemarks WHERE DIC_GeneralRemarks.remarkID = EmployeeRemarks.DicRemarkID), @validFrom),
updateUser = @updateUser,
updateDate = getdate()
FROM EmployeeRemarks
JOIN DIC_GeneralRemarks ON EmployeeRemarks.DicRemarkID = DIC_GeneralRemarks.remarkID
WHERE EmployeeRemarkID = @EmployeeRemarkID

GO

/* View_DeptEmployee_EmployeeRemarks  

New: "EmployeeRemarks.ActiveFrom as validFrom" instead of "EmployeeRemarks.validFrom" */

ALTER VIEW [dbo].[View_DeptEmployee_EmployeeRemarks]
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
EmployeeRemarks.ActiveFrom as ValidFrom,
EmployeeRemarks.ValidTo,
EmployeeRemarks.updateDate,
xd.DeptEmployeeID


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
EmployeeRemarks.ActiveFrom as ValidFrom,
EmployeeRemarks.ValidTo,
EmployeeRemarks.updateDate,
x_D_E.DeptEmployeeID

FROM EmployeeRemarks 
join x_Dept_Employee as x_D_E on EmployeeRemarks.EmployeeID = x_D_E.employeeID
join Dept on Dept.deptCode = x_D_E.DeptCode
	and (
		(EmployeeRemarks.AttributedToAllClinicsInCommunity = 1 and Dept.IsCommunity = 1)  
	or (EmployeeRemarks.AttributedToAllClinicsInMushlam = 1 and Dept.IsMushlam = 1)
	or (EmployeeRemarks.AttributedToAllClinicsInHospitals = 1 and Dept.IsHospital = 1)
	)

GO

/* rpc_InsertDeptEmployeeServiceRemark  
New field to update - "ActiveFrom"*/
ALTER  Procedure [dbo].[rpc_InsertDeptEmployeeServiceRemark]
(
	@deptEmployeeID INT,  
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
								WHERE xd.deptEmployeeID = @deptEmployeeID
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
		ActiveFrom = DATEADD(dd, - (SELECT DIC_GeneralRemarks.ShowForPreviousDays FROM DIC_GeneralRemarks WHERE DIC_GeneralRemarks.remarkID = DeptEmployeeServiceRemarks.RemarkID), @dateFrom),
		UpdateDate = GETDATE(),
		UpdateUser = @userName
	WHERE x_dept_employee_serviceID = @deptEmployeeServiceID

ELSE
BEGIN

	INSERT INTO DeptEmployeeServiceRemarks
	([RemarkID], [RemarkText], [ValidFrom], [ValidTo], [DisplayInInternet], [UpdateDate], [UpdateUser], [x_dept_employee_serviceID], [ActiveFrom])
	VALUES (@remarkID, @remarkText, @dateFrom, @dateTo,  @displayOnInternet, GETDATE(), @userName, @deptEmployeeServiceID, 
		DATEADD(dd, - (SELECT DIC_GeneralRemarks.ShowForPreviousDays FROM DIC_GeneralRemarks WHERE DIC_GeneralRemarks.remarkID = @remarkID), @dateFrom))

	UPDATE x_dept_employee_service
	SET DeptEmployeeServiceRemarkID = @@IDENTITY
	WHERE x_Dept_Employee_ServiceID = @deptEmployeeServiceID

END

GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'view_DeptEmployeeServiceRemarks')
	BEGIN
		DROP  view  view_DeptEmployeeServiceRemarks
	END

GO

CREATE VIEW [dbo].[view_DeptEmployeeServiceRemarks]
AS
 
SELECT 
 DeptEmployeeServiceRemarkID
, RemarkID
, RemarkText
, ActiveFrom as ValidFrom
, ValidTo
, DisplayInInternet
, UpdateDate
, UpdateUser
, x_dept_employee_serviceID

FROM DeptEmployeeServiceRemarks as DESR


GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'view_DeptReceptionRemarks')
	BEGIN
		DROP  view  view_DeptReceptionRemarks
	END

GO

CREATE VIEW [dbo].[view_DeptReceptionRemarks]
AS
 
SELECT 
 DeptReceptionRemarkID
, ReceptionID
, RemarkText
, RemarkID
, ActiveFrom as ValidFrom
, ValidTo
, DisplayInInternet
, UpdateDate
, UpdateUser

FROM DeptReceptionRemarks as DESR

GO

/* rpc_DeptOverView  
NEW: view_DeptEmployeeServiceRemarks instead of DeptEmployeeServiceRemarks */

ALTER Procedure [dbo].[rpc_DeptOverView]
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
View_SubUnitTypes.DefaultReceptionHoursTypeID

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

/* rpc_GetDeptServices  
NEW: view_DeptEmployeeServiceRemarks instead of DeptEmployeeServiceRemarks */
ALTER Procedure [dbo].[rpc_GetDeptServices]
(
	@DeptCode int
)
as

DECLARE @CurrentDate datetime = getdate()
DECLARE @ExpirationDate datetime = DATEADD(day, DATEDIFF(day, 0, @CurrentDate), 0) 
DECLARE @DateAfterExpiration datetime = DATEADD(day, 1, DATEADD(day, DATEDIFF(day, 0, @CurrentDate), 0))
--print @CurrentDate print @ExpirationDate print @DateAfterExpiration 
DECLARE @ExcludedService int SET @ExcludedService = 180300
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
dbo.fun_GetEmployeeServiceSector(xd.employeeID, xdes.serviceCode) as Sector,
[Services].IsInMushlam, [Services].IsInCommunity, [Services].IsInHospitals

FROM x_Dept_Employee_Service as xdes
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
INNER JOIN Employee ON xd.EmployeeId = Employee.EmployeeID
INNER JOIN [Services] ON xdes.ServiceCode = [Services].ServiceCode
WHERE xd.deptCode = @DeptCode
AND [Services].IsProfession = 1
AND Status = 1
AND [Services].ServiceCode <> @ExcludedService

ORDER BY employeeID, ServiceDescription

-- DeptEmployeeServices (Employee's services) ***************************
SELECT 
employeeID, xdes.serviceCode, serviceDescription, xd.DeptEmployeeID,
dbo.fun_GetEmployeeServiceSector(xd.employeeID, xdes.serviceCode) as Sector,
IsInMushlam, IsInCommunity, IsInHospitals
FROM x_Dept_Employee_Service as xdes
INNER JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
INNER JOIN [Services] ON xdes.serviceCode = [Services].serviceCode
INNER JOIN DIC_AgreementTypes at ON xd.AgreementType = at.AgreementTypeID
	AND 
	(
		(at.OrganizationSectorID = 1 AND [Services].IsInCommunity = 1)
		OR
		(at.OrganizationSectorID = 2 AND [Services].IsInMushlam = 1)
		OR
		(at.OrganizationSectorID = 3 AND [Services].IsInHospitals = 1)					
	)
WHERE xd.deptCode = @DeptCode
AND Status = 1
AND [Services].IsService = 1
AND [Services].ServiceCode <> @ExcludedService

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
AND xdes.Status = 1
AND xdes.serviceCode <> @ExcludedService

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
AND xdes.QueueOrder is null
AND xdes.ServiceCode <> @ExcludedService


ORDER BY QueueOrderMethod

------- "HoursForEmployeeQueueOrder" (Hours for Employee Queue Order via Phone) ***************************
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
WHERE xd.deptCode = @DeptCode

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
WHERE xd.deptCode = @DeptCode
AND xdes.ServiceCode <> @ExcludedService
ORDER BY ReceptionDayCode, FromHour

-- "EmployeeOtherPlaces" (Employee's Other work places)  ************************************
SELECT
'ToggleID' = x_dept_employee.deptCode + x_dept_employee.employeeID,
x_dept_employee.deptCode,
x_dept_employee.DeptEmployeeID,
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
'HasRemarks' =  
CASE WHEN EXISTS (
				SELECT *
				FROM View_DeptEmployee_EmployeeRemarks v
				WHERE v.employeeID = x_dept_employee.EmployeeID
				AND (DeptCode = dept.deptCode OR AttributedToAllClinicsInCommunity = 1)
				AND (v.ValidFrom is NULL OR v.ValidFrom < @DateAfterExpiration)
				AND (v.ValidTo is NULL OR v.ValidTo >= @ExpirationDate)	
				)							 
	THEN 1
	WHEN EXISTS (
				SELECT *
				FROM view_DeptEmployeeServiceRemarks desr
				INNER JOIN x_Dept_Employee_Service xdes ON desr.x_dept_employee_serviceID = xdes.x_dept_employee_serviceID
				WHERE xdes.DeptEmployeeID = x_dept_employee.DeptEmployeeID
				AND (ValidFrom is NULL OR ValidFrom < @DateAfterExpiration)
				AND (ValidTo is NULL OR ValidTo >= @ExpirationDate)
				AND xdes.ServiceCode <> @ExcludedService)							 
	THEN 1 
	WHEN EXISTS (
				SELECT * 
				from View_DeptRemarks
				JOIN DIC_GeneralRemarks GR ON View_DeptRemarks.DicRemarkID = GR.remarkID
				WHERE View_DeptRemarks.deptCode = x_dept_employee.deptCode
				AND (ValidFrom is NULL OR ValidFrom < @DateAfterExpiration)
				AND (ValidTo is NULL OR ValidTo >= @ExpirationDate)
			) THEN 1	
	WHEN EXISTS (
				SELECT * 
				FROM deptEmployeeReception der
				JOIN deptEmployeeReceptionServices ders ON der.receptionID = ders.receptionID 
				JOIN DeptEmployeeReceptionRemarks derr ON derr.EmployeeReceptionID = der.receptionID
				WHERE der.DeptEmployeeID = x_dept_employee.DeptEmployeeID  
				AND (@CurrentDate between ISNULL(der.ValidFrom,'1900-01-01') and ISNULL(der.ValidTo,'2079-01-01'))
			) THEN 1
	
	ELSE 0 END				
				
FROM
x_dept_employee
INNER JOIN employee ON x_dept_employee.employeeID = employee.employeeID
INNER JOIN dept ON x_dept_employee.deptCode = dept.deptCode
INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode
LEFT JOIN DIC_QueueOrder ON x_dept_employee.QueueOrder = DIC_QueueOrder.QueueOrder

WHERE x_dept_employee.employeeID IN (SELECT employeeID FROM x_dept_employee WHERE deptCode = @DeptCode)
AND (employee.IsMedicalTeam = 0 OR employee.IsMedicalTeam IS NULL)
AND dept.status = 1
AND x_dept_employee.active = 1

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
AND [Services].ServiceCode <> @ExcludedService

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
AND [Services].ServiceCode <> @ExcludedService

------------- "deptDoctors" (Doctors in Clinic) ***************************
SELECT	DISTINCT e.employeeID,
			xd.DeptEmployeeID, 
			xdes.ServiceCode,
			CASE WHEN e.IsMedicalTeam = 1 THEN xdes.ServiceCode ELSE 0 END as ServiceForGrouping,
			isnull(xdes.[Status], 1) as Status,
			e.IsMedicalTeam,
			e.IsVirtualDoctor,
			xd.AgreementType,
			'DoctorName' = LTRIM(RTRIM(DegreeName + ' ' + e.lastName + ' ' + e.firstName)),
			'DoctorNameNoTitle' = LTRIM(RTRIM(e.lastName + ' ' + e.firstName)),
			'expert' = dbo.fun_GetEmployeeExpert(xd.employeeID),
			'Phones' = dbo.fun_GetDeptEmployeeServicePhones(xd.DeptEmployeeID,xdes.serviceCode),
			'Faxes' = dbo.fun_GetDeptEmployeeServiceFaxes(xd.DeptEmployeeID,xdes.serviceCode),
			'active' = xd.active,
			'ActiveForSort' = CASE WHEN xd.active = 0 THEN 10 ELSE xd.active END,
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
			'hasAnotherWorkPlace' = IsNull((SELECT COUNT(*) 
											FROM x_Dept_Employee as xd2 
											INNER JOIN dept ON xd2.deptCode = dept.deptCode 
											WHERE xd2.deptCode <> @DeptCode AND xd2.EmployeeID = xd.employeeID
											AND xd2.active = 1
											AND e.IsMedicalTeam = 0 AND dept.status <> 0), 0),
			'HasRemarks' = CASE WHEN EXISTS (
									SELECT * 
									FROM View_DeptEmployee_EmployeeRemarks v
									WHERE v.employeeID = xd.EmployeeID
									AND (v.DeptCode = @DeptCode OR AttributedToAllClinicsInCommunity = 1)
									AND (v.ValidFrom is NULL OR v.ValidFrom < @DateAfterExpiration)
									AND (v.ValidTo is NULL OR v.ValidTo >= @ExpirationDate)
								) THEN 1
								WHEN EXISTS (
									SELECT *
									FROM view_DeptEmployeeServiceRemarks desr
									INNER JOIN x_Dept_Employee_Service xdes1 on desr.x_dept_employee_serviceID = xdes1.x_Dept_Employee_ServiceID
									WHERE xdes1.DeptEmployeeID = xd.DeptEmployeeID
									AND (ValidFrom is NULL OR ValidFrom < @DateAfterExpiration)
									AND (ValidTo is NULL OR ValidTo >= @ExpirationDate)
									AND xdes1.serviceCode = xdes.serviceCode
								) THEN 1
								WHEN EXISTS (
									SELECT * 
									from View_DeptRemarks
									JOIN DIC_GeneralRemarks GR ON View_DeptRemarks.DicRemarkID = GR.remarkID
									WHERE View_DeptRemarks.deptCode = xd.deptCode
									--AND GR.RemarkCategoryID = 4
									AND (ValidFrom is NULL OR ValidFrom < @DateAfterExpiration)
									AND (ValidTo is NULL OR ValidTo >= @ExpirationDate)
								) THEN 1
								WHEN EXISTS (
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
									) as t),
		EmployeeInClinic_preselected.ReceiveGuests							 
	INTO #tempDoctors			
	FROM x_Dept_Employee xd
	INNER JOIN Employee e on xd.employeeID = e.employeeID
	INNER JOIN DIC_EmployeeDegree ON e.degreeCode = DIC_EmployeeDegree.DegreeCode
	INNER JOIN EmployeeInClinic_preselected ON xd.DeptEmployeeID = EmployeeInClinic_preselected.DeptEmployeeID
	LEFT JOIN x_Dept_Employee_Service xdes on xd.DeptEmployeeID = xdes.DeptEmployeeID
					AND xdes.Status = 1
					AND xdes.ServiceCode <> @ExcludedService
	WHERE xd.deptCode = @deptCode


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
SELECT 	employeeID, DeptEmployeeID,ToggleID,
		DoctorName, DoctorNameNoTitle, expert, Phones, Faxes,
		EmployeeSectorCode, Active, ActiveForSort, IsMedicalTeam, IsVirtualDoctor, 
		[Services], ServiceDescription, Professions,
		QueueOrderDescription, QueueOrderPhone, HasAnotherWorkPlace, AgreementType,
		max(ReceptionDaysCount) as ReceptionDaysCount, max(HasRemarks) as HasRemarks,
		ReceiveGuests,
		ROW_NUMBER() over (order by employeeID)	as rowID	
FROM (	
	SELECT td.employeeID, td.DeptEmployeeID, --td.ServiceCode,
			'ToggleID' = REPLACE(CONVERT(VARCHAR,td.DeptEmployeeID) + CONVERT(VARCHAR,tgd.[Services]), ',',  '') + CAST(td.ServiceForGrouping as varchar(10)), 
			td.DoctorName, td.DoctorNameNoTitle, td.expert, td.Phones, td.Faxes,
			td.EmployeeSectorCode, td.Active, td.ActiveForSort, td.IsMedicalTeam, td.IsVirtualDoctor, 
			tgd.[Services], tgd.ServiceDescription, tgd.Professions,
			td.QueueOrderDescription, QueueOrderPhone, HasAnotherWorkPlace, AgreementType,
			ReceptionDaysCount, HasRemarks, td.ReceiveGuests  
	FROM #tempDoctors td
	INNER JOIN #tempGroupingDoctors tgd on td.DeptEmployeeID = tgd.DeptEmployeeID
	AND td.Phones = tgd.Phones
	AND td.EmployeeSectorCode = tgd.EmployeeSectorCode
	AND (td.ServiceCode in (SELECT IntField FROM dbo.SplitString(tgd.[Services])) OR td.ServiceCode IS NULL)
	and td.[Status] <> 0

	) as T
	
	group by employeeID, DeptEmployeeID,ToggleID, 
			DoctorName, DoctorNameNoTitle, expert, Phones, Faxes,
			EmployeeSectorCode, Active, ActiveForSort, IsMedicalTeam, IsVirtualDoctor, 
			[Services], ServiceDescription, Professions,
			QueueOrderDescription, QueueOrderPhone, HasAnotherWorkPlace, AgreementType, ReceiveGuests
	ORDER BY EmployeeSectorCode DESC, IsMedicalTeam, DoctorNameNoTitle
	
------- deptEventPhones (Dept Event Phones) ***************************
SELECT
DeptEventID,
phoneOrder,
'phone' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension),
'shortPhoneTypeName' = CASE DeptEventPhones.phoneType WHEN 2 THEN 'פקס' ELSE 'טל`' END

FROM DeptEventPhones
WHERE DeptEventID IN 
	(SELECT DeptEventID FROM DeptEvent 
	WHERE deptCode = @deptCode	)
	
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

------ Employee remark -------------------------------------------------------------

--using  View_DeptEmployee_EmployeeRemarks includes EmployeeRemarks  per dept 
-- and EmployeeRemarks Attributed ToAll Clinics InCommunity, ..InMushlam, ..InHospitals 
-- according to Dept Membership Type

 SELECT distinct
	dbo.rfn_GetFotmatedRemark(v_DE_ER.RemarkTextFormated) as remark,
	v_DE_ER.displayInInternet,
	'' as ServiceName
	,RemarkCategoryID
	,v_DE_ER.DeptEmployeeID
from View_DeptEmployee_EmployeeRemarks as v_DE_ER
JOIN DIC_GeneralRemarks ON v_DE_ER.DicRemarkID = DIC_GeneralRemarks.remarkID
--JOIN DIC_RemarkCategory ON DIC_GeneralRemarks.RemarkCategoryID = DIC_RemarkCategory.
	where v_DE_ER.deptCode = @DeptCode
	AND (v_DE_ER.ValidFrom is null OR DATEDIFF(dd, v_DE_ER.ValidFrom ,@ExpirationDate) >= 0)
	AND (v_DE_ER.ValidTo is null OR DATEDIFF(dd, v_DE_ER.ValidTo ,@ExpirationDate) <= 0)

UNION

SELECT
dbo.rfn_GetFotmatedRemark(desr.RemarkText), displayInInternet, ServiceDescription as ServiceName
,RemarkCategoryID
,xd.DeptEmployeeID
FROM view_DeptEmployeeServiceRemarks desr
JOIN DIC_GeneralRemarks ON desr.RemarkID = DIC_GeneralRemarks.remarkID
INNER JOIN x_Dept_Employee_Service xdes ON desr.x_dept_employee_serviceID = xdes.x_dept_employee_serviceID
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
INNER JOIN [Services] ON xdes.ServiceCode = [Services].ServiceCode AND xdes.Status = 1
WHERE xd.deptCode = @DeptCode
--AND (@ServiceCode = '' OR xdes.ServiceCode IN (SELECT IntField FROM dbo.SplitString(@ServiceCode))) 
AND (ValidFrom is NULL OR DATEDIFF(dd, ValidFrom ,@ExpirationDate) >= 0 )
AND (ValidTo is NULL OR  DATEDIFF(dd, ValidTo ,@ExpirationDate) <= 0 ) 
 
GO

/* rpc_getDeptList_PagedSorted  
NEW: view_DeptEmployeeServiceRemarks instead of DeptEmployeeServiceRemarks */
ALTER Procedure [dbo].[rpc_getDeptList_PagedSorted]
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
	@OpenNow bit,
	@isCommunity bit,
	@isMushlam bit,
	@isHospital bit,
	@status int = null,
	@populationSectorCode int = null,
	@deptHandicappedFacilities varchar(max),
	@ReceiveGuests bit,

	@PageSise int,
	@StartingPage int,
	@SortedBy varchar(max),
	@IsOrderDescending int,
	
	@CoordinateX float=null,
	@CoordinateY float=null,
	@MaxNumberOfRecords int=null,

	@ClalitServiceCode varchar(max), 
	@ClalitServiceDescription varchar(max), 
	@MedicalAspectCode varchar(max), 
	@MedicalAspectDescription varchar(max),
	@ServiceCodeForMuslam varchar(max) = null,
	@GroupCode int = null,
	@SubGroupCode int = null
	)


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

if(@ServiceCodeForMuslam is not null)
	SET @ServiceCodes = @ServiceCodeForMuslam

DECLARE @AgreementTypeList [tbl_UniqueIntArray]   
INSERT INTO @AgreementTypeList
select AgreementTypeID from DIC_AgreementTypes
where OrganizationSectorID in (Select IntField from dbo.SplitString(@OrganizationSectorIDList))

-- @ClalitServiceCode actually bring us additional ServiceCode
DECLARE @AdditionalServiceCode int
	 
SELECT DISTINCT @AdditionalServiceCode = MedicalAspectsToSefer.SeferCode
FROM MF_MedicalAspects830
JOIN MedicalAspectsToSefer ON MF_MedicalAspects830.MedicalServiceCode = MedicalAspectsToSefer.MedicalAspectCode
WHERE MF_MedicalAspects830.ClalitServiceCode = @ClalitServiceCode	
		
IF @AdditionalServiceCode is NOT null
BEGIN
	IF @ServiceCodes is null
		SET @ServiceCodes = @AdditionalServiceCode
	ELSE
		BEGIN
			SET @ServiceCodes = @ServiceCodes + ',' + @AdditionalServiceCode
		END
END

DECLARE @ReceptionDayNow tinyint
DECLARE @OpenAtThisHour real

IF(@OpenNow = 1)
	BEGIN
		SET @ReceptionDayNow = DATEPART(WEEKDAY, GETDATE())
		IF(@ReceptionDays is NULL)
			SET @ReceptionDays = CAST(@ReceptionDayNow as varchar(1))
		ELSE
			IF(PATINDEX('%' + CAST(@ReceptionDayNow as varchar(1)) + '%', @ReceptionDays) = 0)
			SET @ReceptionDays = @ReceptionDays + ',' + CAST(@ReceptionDayNow as varchar(1))
	END

DECLARE @ServiceCodesList [tbl_UniqueIntArray]   
IF @ServiceCodes is NOT null
	INSERT INTO @ServiceCodesList SELECT DISTINCT * FROM dbo.SplitStringNoOrder(@ServiceCodes)

DECLARE @ReceptionDaysList [tbl_UniqueIntArray] 
IF @ReceptionDays is NOT null
	INSERT INTO @ReceptionDaysList SELECT DISTINCT * FROM dbo.SplitStringNoOrder(@ReceptionDays) 
	
IF (@CoordinateX is NOT null AND @CityCode is NOT null AND @DistrictCodes is null)
BEGIN
	SET @DistrictCodes = CAST((SELECT TOP 1 districtCode FROM Cities where cityCode = @CityCode) AS varchar(7))
END

DECLARE @ShowWithNoReceptionHours tinyint
	IF(@OpenAtHour is NOT null OR @OpenFromHour is NOT null OR @OpenToHour is NOT null OR @OpenNow = 1 OR @ReceptionDays is NOT NULL)
		SET @ShowWithNoReceptionHours = 1
	ELSE
		SET @ShowWithNoReceptionHours = 0

SET @Declarations =
'	
	DECLARE @DateNow date = GETDATE()
	
	SET @xStartingPage = @xStartingPage - 1

	DECLARE @xStartingPosition int
	SET @xStartingPosition = (@xStartingPage * @xPageSise)
	
	DECLARE @xHandicappedFacilitiesCount int
	SET @xHandicappedFacilitiesCount = IsNull((SELECT COUNT(IntField) FROM dbo.SplitString(@xDeptHandicappedFacilities)), 0)
	
	DECLARE @xOpenAtHour_time time
	DECLARE @xOpenFromHour_time time
	DECLARE @xOpenToHour_time time
	DECLARE @xOpenAtThisHour_time time
	
	IF @xOpenFromHour IS NOT NULL
		SET @xOpenFromHour_time = CAST(@xOpenFromHour as time) 
		
	IF @xOpenToHour IS NOT NULL
		SET @xOpenToHour_time = CAST(@xOpenToHour as time)
		
	IF @xOpenAtHour IS NOT NULL
		SET @xOpenAtHour_time = CAST(@xOpenAtHour as time) 
		
'
IF(@OpenNow = 1)
	SET @Declarations = @Declarations + 
	'SET @xOpenAtThisHour_time = CAST((CAST(DATEPART(HOUR, GETDATE()) as varchar(2)) + '':'' + CAST(DATEPART(MINUTE, GETDATE()) as varchar(2))) as time)
	'
SET @Declarations = @Declarations +
'		
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
	@xMaxNumberOfRecords int=null,

	@xClalitServiceCode varchar(max), 
	@xClalitServiceDescription varchar(max), 
	@xMedicalAspectCode varchar(max), 
	@xMedicalAspectDescription varchar(max),
	@xServiceCodeForMuslam varchar(max)=null,
	@xGroupCode int=null,
	@xSubGroupCode int=null
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
			'ELSE '  

IF(@ServiceCodes is null)
	BEGIN
	IF(@ShowWithNoReceptionHours = 0)
		BEGIN
			SET @Sql1 = @Sql1 +
				' ROW_NUMBER() OVER(ORDER BY deptLevel, IsNull(DisplayPriority,99), OrderValue ) 
				'
		END
	ELSE
		BEGIN
			SET @Sql1 = @Sql1 +
				' ROW_NUMBER() OVER(ORDER BY deptLevel, IsNull(DisplayPriority,99), countReception DESC, OrderValue ) 
				'
		END
	END	
ELSE
	BEGIN
	IF(@ShowWithNoReceptionHours = 0)
		BEGIN
			SET @Sql1 = @Sql1 +
				' ROW_NUMBER() OVER(ORDER BY deptLevel, IsNull(DisplayPriority,99), OrderValue ) 
				'
		END
	ELSE
		BEGIN
			SET @Sql1 = @Sql1 +
				' ROW_NUMBER() OVER(ORDER BY deptLevel, IsNull(DisplayPriority,99), EmployeeHasReception DESC, OrderValue ) 
				'
		END
	END			
SET @Sql1 = @Sql1 +				
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
IsNull(dept.subUnitTypeCode, -1) as subUnitTypeCode,
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
--dbo.GetDeptPhoneNumber(dept.deptCode, 1, 1) as phone,
dbo.fun_ParsePhoneNumberWithExtension(DeptPhones.prePrefix, DeptPhones.prefix, DeptPhones.phone, DeptPhones.extension) as phone,
DeptPhones.remark,
	(SELECT COUNT(*) 
	from View_DeptRemarks
	WHERE deptCode = dept.deptCode
	AND (@DateNow between ISNULL(ValidFrom,''1900-01-01'') and ISNULL(ValidTo,''2079-01-01''))
	AND (IsSharedRemark = 0 OR dept.IsCommunity = 1) 
	)
		+
  CASE 
	(select COUNT(*) from View_DeptEmployee_EmployeeRemarks as v_DE_ER	
	WHERE v_DE_ER.deptCode = dept.deptCode
	AND (@DateNow between ISNULL(ValidFrom,''1900-01-01'') and ISNULL(ValidTo,''2079-01-01''))
	)WHEN 0 THEN 0 ELSE 1 END		
as countDeptRemarks,
CASE WHEN EXISTS
	(select * from DeptReception_Regular
	where deptCode = dept.deptCode
	AND (@DateNow between ISNULL(ValidFrom,''1900-01-01'') and ISNULL(ValidTo,''2079-01-01''))
	) THEN 1 ELSE 0 END
as 	countReception,
Simul228,
	(x_dept_XY.xcoord - @xCoordinateX)*(x_dept_XY.xcoord - @xCoordinateX) + (x_dept_XY.ycoord - @xCoordinateY)*(x_dept_XY.ycoord - @xCoordinateY)
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
0 as ReceiveGuests,
'''' as QueueOrderDescription,
0 as DeptEmployeeID,
0 as EmployeeHasReception,
'
	 
END
ELSE
BEGIN
	SET @Sql1 = @Sql1 + 
'CASE	WHEN @xIsHospital = 1 AND Employee.IsMedicalTeam = 1 AND xDE.AgreementType = 5 
		THEN dbo.fun_GetMedicalAspectsForService(T_services.ServiceCode, xDE.DeptEmployeeID)
		ELSE T_services.ServiceDescription  
		END as ServiceDescription,
T_services.ServiceCode as ServiceID, 
Employee.IsMedicalTeam as IsMedicalTeam, 
DegreeName + space(1) + Employee.lastName + space(1) + Employee.firstName as doctorName, 
Employee.employeeID as employeeID, 
  CASE WHEN isNull(T_services.ReceptionCount, 0) = 0 then 0 else 1 end
as ShowHoursPicture, 
CASE WHEN EXISTS -- This is NEW 12
		(SELECT View_DeptRemarks.deptCode
		from View_DeptRemarks
		JOIN DIC_GeneralRemarks GR ON View_DeptRemarks.DicRemarkID = GR.remarkID
		WHERE deptCode = xde.deptCode
		AND (@DateNow between ISNULL(ValidFrom,''1900-01-01'') and ISNULL(ValidTo,''2079-01-01''))
		) THEN 3 
			ELSE 
		  CASE WHEN EXISTS
			(select DESR.RemarkID from view_DeptEmployeeServiceRemarks DESR
				where T_services.x_dept_employee_serviceID = DESR.x_dept_employee_serviceID
				AND (@DateNow between ISNULL(ValidFrom,''1900-01-01'') and ISNULL(ValidTo,''2079-01-01''))
				)  THEN 1 
				ELSE 
					  CASE WHEN EXISTS
						(select v_DE_ER.DeptCode from View_DeptEmployee_EmployeeRemarks as v_DE_ER	
						WHERE v_DE_ER.DeptEmployeeID = xde.DeptEmployeeID
						AND (@DateNow between ISNULL(ValidFrom,''1900-01-01'') and ISNULL(ValidTo,''2079-01-01''))
						) THEN 2 
						
						ELSE 				
						  CASE WHEN EXISTS
							(SELECT der.receptionID 
							FROM deptEmployeeReception der
							JOIN deptEmployeeReceptionServices ders ON der.receptionID = ders.receptionID 
							JOIN DeptEmployeeReceptionRemarks derr ON derr.EmployeeReceptionID = der.receptionID
							WHERE der.DeptEmployeeID = xde.DeptEmployeeID  
							AND ders.serviceCode = T_services.serviceCode
							AND (@DateNow between ISNULL(der.ValidFrom,''1900-01-01'') and ISNULL(der.ValidTo,''2079-01-01''))
							) THEN 4 ELSE 0 END				
						END		
				END 
		END
as ShowRemarkPicture,
  stuff((SELECT ' + CHAR(39) + ',' + CHAR(39) + ' + convert(varchar(10), x.phone)
		FROM (select dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) as phone
			FROM x_Dept_Employee_Service join EmployeeServicePhones
			on EmployeeServicePhones.x_Dept_Employee_ServiceID = x_Dept_Employee_Service.x_Dept_Employee_ServiceID
			join x_Dept_Employee on x_Dept_Employee_Service.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
			where x_Dept_Employee_Service.serviceCode = T_services.serviceCode
			and x_Dept_Employee.DeptEmployeeID = xDE.DeptEmployeeID
			and x_Dept_Employee.AgreementType in (select * from @xAgreementTypeList)
		) x
		for xml path('+ CHAR(39) + CHAR(39) +')
	),1,1,'+ CHAR(39) + CHAR(39) +')
as ServicePhones,
T_services.status as serviceStatus,
xDE.active as employeeStatus,
xDE.agreementType,
CASE WHEN T_services.ServiceCode is null THEN 0 
	--WHEN (T_services.ServiceCode = 2 OR T_services.ServiceCode = 40) THEN ISNULL(xDE.ReceiveGuests, 1) 
	ELSE 
		emp_pr.ReceiveGuests
	END as ReceiveGuests,
CASE WHEN ServiceQueueOrderDescription is not null THEN ServiceQueueOrderDescription ELSE emp_pr.QueueOrderDescription END as QueueOrderDescription, 
xDE.DeptEmployeeID,
emp_pr.HasReception as EmployeeHasReception,
' 	
		 
END	

SET @Sql1 = @Sql1 + 
	' 1 as ServiceOrEvent /* 1 for service, 0 for event */
	'
IF(@SortedBy is null)
	SET @Sql1 = @Sql1 +	
	',RandomOrderSelect.OrderValue
	'
ELSE
	SET @Sql1 = @Sql1 +	
	',1 as OrderValue
	'	
	
SET @Sql1 = @Sql1 + 

'
FROM dept
INNER JOIN DIC_DeptTypes on Dept.deptType = DIC_DeptTypes.deptType
INNER JOIN UnitType on dept.typeUnitCode = UnitType.UnitTypeCode
INNER JOIN Cities on dept.cityCode = Cities.cityCode
LEFT JOIN DeptPhones ON dept.deptCode = DeptPhones.deptCode
	AND DeptPhones.phoneType = 1 AND phoneOrder = 1
LEFT JOIN DeptSimul on dept.deptCode = deptSimul.deptCode
LEFT JOIN x_dept_XY ON dept.deptCode = x_dept_XY.deptCode
LEFT JOIN SubUnitTypeSubstituteName ON dept.typeUnitCode = SubUnitTypeSubstituteName.UnitTypeCode
			AND (IsNull(dept.subUnitTypeCode, 0) + UnitType.DefaultSubUnitTypeCode) = SubUnitTypeSubstituteName.SubUnitTypeCode
'

IF(@ServiceCodes is NOT null OR @ServiceCodeForMuslam is NOT null)
BEGIN
	SET @Sql1 = @Sql1 +	
	'INNER JOIN x_dept_employee xDE on Dept.deptCode = xDE.deptCode '
--		
	SET @Sql1 = @Sql1 +		
	'INNER JOIN EmployeeInClinic_preselected emp_pr on xDE.deptCode = emp_pr.deptCode
	AND xDE.employeeID = emp_pr.employeeID AND xDE.AgreementType = emp_pr.AgreementType
	'
	
	IF(@ReceiveGuests = 1 AND (@OpenAtHour is null AND @OpenFromHour is null AND @OpenToHour is null AND @OpenNow <> 1)) 
		SET @Sql1 = @Sql1 +	
		' AND (emp_pr.ReceiveGuests = 1 OR emp_pr.ReceiveGuests = 2) '		
--
	SET @Sql1 = @Sql1 +	
	'INNER JOIN Employee on Employee.employeeID = xDE.employeeID
	LEFT JOIN DIC_EmployeeDegree on DIC_EmployeeDegree.DegreeCode = Employee.degreeCode 
 
	INNER JOIN  
	(		SELECT 
			xDE2.DeptEmployeeID,
			0 as x_dept_employee_serviceID,
			1 as status, 
			null as ServiceQueueOrderDescription,
			'
			IF(@ServiceCodeForMuslam is NOT null)
				SET @Sql1 = @Sql1 +	
				' @xServiceCodeForMuslam as ServiceCode, '
			ELSE
				SET @Sql1 = @Sql1 +	
				' (select TOP 1 IntVal from @xServiceCodesList) as ServiceCode, '
	SET @Sql1 = @Sql1 +					
			'
			'' התייעצות עם רופא מומחה למתן חו"ד שנייה בנושא: '' + [dbo].[fun_GetEmployeeMushlamInDeptServices](xDE2.EmployeeID,xDE2.deptCode,1) as ServiceDescription,
			(	SELECT COUNT(*) FROM x_Dept_Employee_Service
				JOIN deptEmployeeReception_Regular ON x_Dept_Employee_Service.DeptEmployeeID = deptEmployeeReception_Regular.DeptEmployeeID
						AND CAST(@DateNow as date) between ISNULL(validFrom,''1900-01-01'') and ISNULL(validTo,''2079-01-01'')
				WHERE x_Dept_Employee_Service.DeptEmployeeID = xDE2.DeptEmployeeID
				AND x_Dept_Employee_Service.serviceCode = 180300)	as ReceptionCount		

			FROM x_dept_employee xDE2

			WHERE EXISTS (	SELECT * FROM x_Dept_Employee_Service 
							WHERE x_Dept_Employee_Service.serviceCode = 180300
							AND x_Dept_Employee_Service.DeptEmployeeID = xDE2.DeptEmployeeID	) '
			IF(@ServiceCodeForMuslam is NOT null)
				SET @Sql1 = @Sql1 +	
				' AND  EXISTS (	SELECT * FROM x_Dept_Employee_Service
								WHERE x_Dept_Employee_Service.serviceCode = @xServiceCodeForMuslam
								AND x_Dept_Employee_Service.DeptEmployeeID = xDE2.DeptEmployeeID	) 
				'
			ELSE
				SET @Sql1 = @Sql1 +	
				' AND EXISTS (	SELECT * FROM x_Dept_Employee_Service 
								WHERE x_Dept_Employee_Service.serviceCode in (SELECT IntVal FROM @xServiceCodesList )
								AND x_Dept_Employee_Service.DeptEmployeeID = xDE2.DeptEmployeeID )
				'

	SET @Sql1 = @Sql1 +	
			'UNION

			SELECT 
			xDE2.DeptEmployeeID,
			xDES.x_dept_employee_serviceID,
			xDES.status,
			DIC_QueueOrder.QueueOrderDescription as ServiceQueueOrderDescription, 
			[Services].ServiceCode,
			[Services].ServiceDescription as ServiceDescription,
			[View_DeptEmployeeReceptionCount].ReceptionCount
			FROM x_dept_employee xDE2
			INNER JOIN x_Dept_Employee_Service xDES on xDE2.DeptEmployeeID = xDES.DeptEmployeeID
			LEFT JOIN DIC_QueueOrder on xDES.QueueOrder = DIC_QueueOrder.QueueOrder
			INNER JOIN [Services] on [Services].ServiceCode = xDES.serviceCode
			LEFT JOIN [View_DeptEmployeeReceptionCount] on [View_DeptEmployeeReceptionCount].DeptEmployeeID = xDE2.DeptEmployeeID
				and [View_DeptEmployeeReceptionCount].serviceCode = xDES.serviceCode
				and xDE2.AgreementType in (select * from @xAgreementTypeList)
			WHERE NOT EXISTS (	SELECT * FROM x_Dept_Employee_Service 
							WHERE x_Dept_Employee_Service.serviceCode = 180300
							AND x_Dept_Employee_Service.DeptEmployeeID = xDE2.DeptEmployeeID	)
	)	as T_services 
		ON 	T_services.DeptEmployeeID = xDE.DeptEmployeeID	
	'
END
IF(@MedicalAspectCode is NOT null)
	SET @Sql1 = @Sql1 +	
' LEFT JOIN x_dept_medicalAspect ON Dept.deptCode = x_dept_medicalAspect.NewDeptCode
'
IF(@ServiceCodeForMuslam is NOT null)
	SET @Sql1 = @Sql1 +	
' INNER JOIN vMushlamCervices ON T_services.ServiceCode = vMushlamCervices.ServiceCode
'
-- NEW
IF(@SortedBy is null AND @ServiceCodes is null)
	SET @Sql1 = @Sql1 +	
' LEFT JOIN	(Select CAST(deptCode as bigint) as KeyValue, ROW_NUMBER() over (ORDER BY newid()) as OrderValue
	from Dept) RandomOrderSelect ON dept.deptCode = RandomOrderSelect.KeyValue
'

IF(@SortedBy is null AND @ServiceCodes is NOT null)
	SET @Sql1 = @Sql1 +	
' LEFT JOIN	(Select CAST(DeptEmployeeID as bigint) as KeyValue, ROW_NUMBER() over (ORDER BY newid()) as OrderValue
	from x_Dept_Employee) RandomOrderSelect 
	ON T_services.DeptEmployeeID = RandomOrderSelect.KeyValue
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
				(dept.deptLevel = 1 
					OR (dept.deptLevel = 2 
						AND exists (SELECT districtCode FROM Cities WHERE cityCode = @xCityCode
									and (districtCode = dept.districtCode
											OR districtCode IN (SELECT districtCode FROM x_Dept_District WHERE x_Dept_District.deptCode = dept.deptCode)
										)
									)
						)
				)

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
IF(@MedicalAspectCode is NOT null)
	SET @SqlWhere1 = @SqlWhere1 +	
	' AND (x_dept_medicalAspect.MedicalAspectCode = @xMedicalAspectCode) 
	'	

--	Check the reception hours for Services

IF(@OpenAtHour is NOT null OR @OpenFromHour is NOT null OR @OpenToHour is NOT null OR @OpenNow = 1 OR @ReceptionDays IS NOT NULL )
BEGIN
	IF( @ServiceCodes is NOT null )
	BEGIN
		SET @SqlWhere1 = @SqlWhere1 + 	
		' AND (EXISTS (SELECT deptCode
					 FROM x_Dept_Employee xDE
					 JOIN deptEmployeeReception_Regular dER on xDE.DeptEmployeeID = dER.DeptEmployeeID
						AND CAST(@DateNow as date) between ISNULL(dER.validFrom,''1900-01-01'') and ISNULL(dER.validTo,''2079-01-01'')
					 JOIN deptEmployeeReceptionServices dERS on dER.DeptEmployeeReceptionID = dERS.receptionID 
					 LEFT JOIN DeptEmployeeReceptionRemarks DERR ON dER.DeptEmployeeReceptionID = DERR.EmployeeReceptionID 
					 WHERE xDE.AgreementType in (select * from @xAgreementTypeList)
					 '

				SET @SqlWhere1 = @SqlWhere1 + 						
					'AND exists (select * from @xServiceCodesList where IntVal = dERS.serviceCode)
					AND xDE.deptCode = Dept.deptCode
					AND xDE.employeeID = Employee.employeeID 
					'
				IF(	@OpenToHour IS NOT NULL OR @OpenFromHour IS NOT NULL )
				BEGIN
					SET @SqlWhere1 = @SqlWhere1 + 
					  ' AND (	
									Cast(openingHour as time) < @xOpenToHour_time 
										AND 
									Cast(closingHour as time) > @xOpenFromHour_time 
							)
					'						
				END

				IF(	@OpenAtHour IS NOT NULL )
				BEGIN
					SET @SqlWhere1 = @SqlWhere1 + 
					 ' AND (
									Cast(openingHour as time) <= @xOpenAtHour_time 
									AND
									Cast(closingHour as time) > @xOpenAtHour_time 
							)
					'
				END
			
				IF(	@OpenNow = 1 )
				BEGIN
					SET @SqlWhere1 = @SqlWhere1 + 
					 ' AND (
									Cast(openingHour as time) <= @xOpenAtThisHour_time 
									AND
									Cast(closingHour as time) > @xOpenAtThisHour_time 
							)
					'
				END

				IF( @ReceptionDays is NOT null )
				BEGIN
					SET @SqlWhere1 = @SqlWhere1 +
					' AND dER.receptionDay in (select IntVal from @xReceptionDaysList) 
					'					
				END
				
				IF(	@ReceiveGuests = 1)
				BEGIN
					SET @SqlWhere1 = @SqlWhere1 + 
					 ' AND (
									dER.ReceiveGuests = 1
							)
					'
				END	
				
		SET @SqlWhere1 = @SqlWhere1 + ') '									
		SET @SqlWhere1 = @SqlWhere1 +  
		' OR 
		(  emp_pr.HasReception = 0) 
		'	

	END
--	Check the reception hours for Dept	
	IF(@ServiceCodes is null)
	BEGIN
		SET @SqlWhere1 = @SqlWhere1 + 
		' AND  (EXISTS 
				(SELECT deptCode FROM DeptReception_Regular as T
				 WHERE T.deptCode = dept.deptCode
				AND CAST(@DateNow as date) between ISNULL(T.validFrom,''1900-01-01'') and ISNULL(T.validTo,''2079-01-01'')
		'
			IF(	@OpenToHour IS NOT NULL OR @OpenFromHour IS NOT NULL )
			BEGIN
				SET @SqlWhere1 = @SqlWhere1 +
					  ' AND (	
									Cast(openingHour as time) < @xOpenToHour_time 
										AND 
									Cast(closingHour as time) > @xOpenFromHour_time 
							)
					'		
			END	
			IF(	@OpenAtHour IS NOT NULL )
			BEGIN
				SET @SqlWhere1 = @SqlWhere1 +	
					 ' AND (
									Cast(openingHour as time) <= @xOpenAtHour_time 
									AND
									Cast(closingHour as time) > @xOpenAtHour_time 
							)
					'
			END	
			IF(	@OpenNow = 1 )
			BEGIN
				SET @SqlWhere1 = @SqlWhere1 +	
					 ' AND (
									Cast(openingHour as time) <= @xOpenAtThisHour_time 
									AND
									Cast(closingHour as time) > @xOpenAtThisHour_time 
							)
					'
			END					
			IF(	@ReceptionDays IS NOT NULL )
			BEGIN
				SET @SqlWhere1 = @SqlWhere1 +	
				' AND exists (select * from @xReceptionDaysList where IntVal = T.receptionDay)
				'
			END
		SET @SqlWhere1 = @SqlWhere1 + ') '	
		SET @SqlWhere1 = @SqlWhere1 + ' 
		OR 
		(  
			NOT EXISTS
			(select * from DeptReception_Regular
			where deptCode = dept.deptCode
			AND (@DateNow between ISNULL(ValidFrom,''1900-01-01'') and ISNULL(ValidTo,''2079-01-01''))
			)		
		
		) '		
		
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

		AND	((@xStatus = 0 AND T_services.status = 0)
				OR (@xStatus = 1 AND (T_services.status = 1 OR T_services.status = 2 ))
				OR (@xStatus = 2 AND (T_services.status = 1 ))
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
			AND exists (select * from @xServiceCodesList where IntVal = T_services.serviceCode)
			AND xDE.AgreementType in (select * from @xAgreementTypeList)
			)
		 > 0 ) 
	'	
END
	
IF(	@CoordinateX IS NOT NULL )
BEGIN
	SET @SqlWhere1 = @SqlWhere1 +	
	' AND x_dept_XY.xcoord is NOT null AND x_dept_XY.ycoord is NOT null 
	'
END	

IF(	@ServiceCodeForMuslam IS NOT NULL )
BEGIN
	SET @SqlWhere1 = @SqlWhere1 +	
	'
	AND vMushlamCervices.ServiceCode = @xServiceCodeForMuslam
	AND xDE.AgreementType IN (3,4)
	AND xDE.active = 1 and dept.status = 1 and T_services.Status = 1
	AND (	(vMushlamCervices.originalServiceCode = 180300 and dept.typeUnitCode = 112
			AND 
			exists (select * from x_dept_employee_service xdes2 
					where xdes2.DeptEmployeeID = xDE.DeptEmployeeID
					AND xdes2.serviceCode = vMushlamCervices.ServiceCode)
			AND 
			exists (select * from x_dept_employee_service xdes2 
					where xdes2.DeptEmployeeID = xDE.DeptEmployeeID
					AND xdes2.serviceCode = 180300)
			)
			OR 
			(vMushlamCervices.originalServiceCode <> 180300 and (dept.typeUnitCode <> 112 or xDE.employeeID = 1000000019))
		)

'
	END	

IF(	@GroupCode IS NOT NULL )
	SET @SqlWhere1 = @SqlWhere1 +	
	'
	AND vMushlamCervices.GroupCode = @xGroupCode	
	'
IF(	@SubGroupCode IS NOT NULL )
	SET @SqlWhere1 = @SqlWhere1 +	
	'
	AND vMushlamCervices.SubGroupCode = @xSubGroupCode	
	'
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
	dbo.fun_ParsePhoneNumberWithExtension(DeptPhones.prePrefix, DeptPhones.prefix, DeptPhones.phone, DeptPhones.extension) as phone,
	DeptPhones.remark,	
		(SELECT COUNT(*) 
		from View_DeptRemarks
		WHERE deptCode = dept.deptCode
		AND @DateNow between ISNULL(validFrom,'+CHAR(39)+'1900-01-01'+CHAR(39)+') and ISNULL(validTo,'+CHAR(39)+'2079-01-01'+CHAR(39)+')
		AND (IsSharedRemark = 0 OR dept.IsCommunity = 1) 
		)
	as countDeptRemarks,
		(select count(receptionID) 
		from DeptReception_Regular
		where deptCode = dept.deptCode
		AND (@DateNow between ISNULL(validFrom,''1900-01-01'') and ISNULL(validTo,''2079-01-01'')))
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
	0 as ReceiveGuests,
	'''' as QueueOrderDescription,
	0 as DeptEmployeeID,
	0 as EmployeeHasReception,

	0 as ServiceOrEvent -- 1 for service, 0 for event 
'

	IF(@SortedBy is null)
		SET @Sql2 = @Sql2 +	
		',RandomOrderSelect.OrderValue
		'
	ELSE
		SET @Sql2 = @Sql2 +	
		',1 as OrderValue
		'	
	
SET @Sql2 = @Sql2 + 
'
	FROM DeptEvent
	INNER JOIN dept ON DeptEvent.deptCode = dept.deptCode
	INNER JOIN DIC_DeptTypes on Dept.deptType = DIC_DeptTypes.deptType
	INNER JOIN UnitType on dept.typeUnitCode = UnitType.UnitTypeCode
	INNER JOIN Cities on dept.cityCode = Cities.cityCode
	LEFT JOIN DeptPhones ON dept.deptCode = DeptPhones.deptCode
		AND DeptPhones.phoneType = 1 AND phoneOrder = 1	INNER JOIN DIC_Events ON DeptEvent.EventCode = DIC_Events.EventCode
	LEFT JOIN x_dept_XY ON dept.deptCode = x_dept_XY.deptCode 
	'

-- NEW

IF(@SortedBy is null AND @ServiceCodes is NOT null)
	SET @Sql2 = @Sql2 +	
' LEFT JOIN	(Select CAST(DeptEventID as bigint) as KeyValue, ROW_NUMBER() over (ORDER BY newid()) as OrderValue
	from DeptEvent as DeptEvent2) RandomOrderSelect 
	ON DeptEvent.DeptEventID = RandomOrderSelect.KeyValue
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
					(dept.deptLevel = 1 OR (dept.deptLevel = 2 AND exists (SELECT districtCode FROM Cities WHERE cityCode = @xCityCode 
																				and  (dept.districtCode = districtCode
																					OR districtCode IN (SELECT districtCode FROM x_Dept_District WHERE x_Dept_District.deptCode = dept.deptCode)
																				))
						))
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

	IF(	@OpenAtHour is NOT null OR @OpenFromHour is NOT null OR @OpenToHour is NOT null OR @OpenNow = 1)
	BEGIN
		SET @SqlWhere2 = @SqlWhere2 +	
		' AND exists
			(SELECT DeptEventID FROM DeptEventParticulars as T 
				WHERE 
					T.DeptEventID = DeptEvent.DeptEventID '
				
			IF(	@OpenToHour is NOT null OR @OpenFromHour is NOT null)
				SET @SqlWhere2 = @SqlWhere2 +					
				' AND (
						Cast(T.openingHour as time) < @xOpenToHour_time 
							AND
						Cast(T.closingHour as time) > @xOpenFromHour_time
					) '
				
			IF(	@OpenAtHour is NOT null )
			BEGIN
				SET @SqlWhere2 = @SqlWhere2 +					
				' AND
					( 
						Cast(T.openingHour as time) < @xOpenAtHour_time 
							AND
						Cast(T.closingHour as time) > @xOpenAtHour_time
					) 
				' 
			END	
			IF(	@OpenNow = 1 )
			BEGIN
				SET @SqlWhere2 = @SqlWhere2 +					
				' AND
					( 
						Cast(T.openingHour as time) < @xOpenAtThisHour_time 
							AND
						Cast(T.closingHour as time) > @xOpenAtThisHour_time
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
		' AND ( (@DateNow between ISNULL(DeptEvent.FromDate,'+CHAR(39)+'1900-01-01'+CHAR(39)+') and ISNULL(DeptEvent.ToDate,'+CHAR(39)+'2079-01-01'+CHAR(39)+') AND @xStatus = 1)
			  OR
			  (DeptEvent.FromDate > @DateNow OR DeptEvent.ToDate < @DateNow AND @xStatus = 0)
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
INTO #tempTableFinalSelect
FROM #tempTableAllRows
WHERE RowNumber > @xStartingPosition
	AND RowNumber <= @xStartingPosition + @xPageSise
ORDER BY RowNumber

SELECT * FROM #tempTableFinalSelect

-- select with same joins and conditions as above
-- just to get count of all the records in select

SET @xCount =	
		(SELECT COUNT(*)
		FROM #tempTableAllRows)

	

IF(@xMaxNumberOfRecords is NOT null)
BEGIN
	IF(@xCount > @xMaxNumberOfRecords)
	BEGIN
		SET @xCount = @xMaxNumberOfRecords
	END
END
	
SELECT @xCount

DECLARE @DeptCodeList varchar(max) = ''''
SELECT TOP (SELECT @xCount) @DeptCodeList = @DeptCodeList + CAST(deptCode as varchar(10)) + '','' 
FROM (SELECT DISTINCT deptCode FROM #tempTableFinalSelect) T
SELECT @DeptCodeList

-- QueueOrderMethods (via employees services)
SELECT esqom.QueueOrderMethod, #tempTableFinalSelect.deptCode, #tempTableFinalSelect.employeeID, 
	DIC_ReceptionDays.receptionDayName, esqoh.FromHour, esqoh.ToHour, xdes.serviceCode as ServiceID
FROM EmployeeServiceQueueOrderMethod esqom
INNER JOIN x_Dept_Employee_Service xdes ON esqom.x_dept_employee_serviceID = xdes.x_Dept_Employee_ServiceID
INNER JOIN #tempTableFinalSelect ON xdes.DeptEmployeeID = #tempTableFinalSelect.DeptEmployeeID
	AND xdes.serviceCode = #tempTableFinalSelect.ServiceID
LEFT JOIN EmployeeServiceQueueOrderHours esqoh ON esqom.EmployeeServiceQueueOrderMethodID = esqoh.EmployeeServiceQueueOrderMethodID
LEFT JOIN DIC_ReceptionDays ON esqoh.receptionDay = DIC_ReceptionDays.ReceptionDayCode

UNION

-- QueueOrderMethods (via Employee)
SELECT eqom.QueueOrderMethod, #tempTableFinalSelect.deptCode, #tempTableFinalSelect.employeeID, 
	DIC_ReceptionDays.receptionDayName, eqoh.FromHour, eqoh.ToHour
	,xdes.serviceCode as ServiceID
FROM EmployeeQueueOrderMethod eqom
INNER JOIN #tempTableFinalSelect ON eqom.DeptEmployeeID = #tempTableFinalSelect.DeptEmployeeID 
LEFT JOIN EmployeeQueueOrderHours eqoh ON eqom.QueueOrderMethodID = eqoh.QueueOrderMethodID
LEFT JOIN DIC_ReceptionDays ON eqoh.receptionDay = DIC_ReceptionDays.ReceptionDayCode
-- exclude when queue order for service exists
JOIN x_Dept_Employee_Service xdes 
	ON #tempTableFinalSelect.DeptEmployeeID = xdes.DeptEmployeeID
	AND xdes.serviceCode = #tempTableFinalSelect.ServiceID	
LEFT JOIN EmployeeServiceQueueOrderMethod esqom
	ON xdes.x_Dept_Employee_ServiceID = esqom.x_dept_employee_serviceID 
WHERE esqom.QueueOrderMethod is null
AND xdes.QueueOrder IS NULL

-- DeptPhones (new via employees services)
SELECT #tempTableFinalSelect.deptCode, #tempTableFinalSelect.employeeID, xdes.serviceCode as ServiceID
	,dbo.fun_ParsePhoneNumberWithExtension(DeptPhones.prePrefix, DeptPhones.prefix, DeptPhones.phone, DeptPhones.extension) as Phone
FROM EmployeeServiceQueueOrderMethod esqom
INNER JOIN x_Dept_Employee_Service xdes ON esqom.x_dept_employee_serviceID = xdes.x_Dept_Employee_ServiceID
INNER JOIN #tempTableFinalSelect ON xdes.DeptEmployeeID = #tempTableFinalSelect.DeptEmployeeID 
INNER JOIN DIC_QueueOrderMethod ON esqom.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
INNER JOIN DeptPhones ON #tempTableFinalSelect.deptCode = DeptPhones.deptCode
--WHERE phoneType = 1 AND phoneOrder = 1 AND SpecialPhoneNumberRequired = 0 AND ShowPhonePicture = 1 OPTION (FORCE order)
WHERE phoneType = 1 AND phoneOrder = 1 AND SpecialPhoneNumberRequired = 0 AND ShowPhonePicture = 1 --OPTION (FORCE order)

UNION

-- DeptPhones (old via Employee)
SELECT #tempTableFinalSelect.deptCode, #tempTableFinalSelect.employeeID, xdes.serviceCode as ServiceID,  
	dbo.fun_ParsePhoneNumberWithExtension(DeptPhones.prePrefix, DeptPhones.prefix, DeptPhones.phone, DeptPhones.extension) as Phone
FROM #tempTableFinalSelect  
INNER JOIN EmployeeQueueOrderMethod eqom ON #tempTableFinalSelect.DeptEmployeeID = eqom.DeptEmployeeID
INNER JOIN DIC_QueueOrderMethod ON eqom.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
INNER JOIN DeptPhones ON #tempTableFinalSelect.deptCode = DeptPhones.deptCode

LEFT JOIN x_Dept_Employee_Service xdes 
	ON #tempTableFinalSelect.DeptEmployeeID = xdes.DeptEmployeeID
LEFT JOIN EmployeeServiceQueueOrderMethod esqom
	ON xdes.x_Dept_Employee_ServiceID = esqom.x_dept_employee_serviceID
	AND  esqom.QueueOrderMethod = 1
WHERE phoneType = 1 AND SpecialPhoneNumberRequired = 0 
--WHERE phoneType = 1 AND phoneOrder = 1 AND SpecialPhoneNumberRequired = 0 
AND ShowPhonePicture = 1 AND esqom.x_dept_employee_serviceID is null
OPTION (FORCE order)


-- SpecialPhones (new via employees services)
SELECT xde.deptCode, xde.employeeID, xdes.serviceCode as ServiceID,
dbo.fun_ParsePhoneNumberWithExtension(esqop.prePrefix, esqop.prefix, esqop.phone, esqop.extension) as Phone
FROM #tempTableFinalSelect
JOIN x_Dept_Employee xde ON #tempTableFinalSelect.deptCode = xde.deptCode
	AND #tempTableFinalSelect.employeeID = xde.employeeID
JOIN x_Dept_Employee_Service xdes ON xde.DeptEmployeeID = xdes.DeptEmployeeID
	AND #tempTableFinalSelect.ServiceID = xdes.serviceCode
JOIN EmployeeServiceQueueOrderMethod esqom ON xdes.x_Dept_Employee_ServiceID = esqom.x_dept_employee_serviceID
JOIN EmployeeServiceQueueOrderPhones esqop ON esqom.EmployeeServiceQueueOrderMethodID = esqop.EmployeeServiceQueueOrderMethodID

UNION

-- SpecialPhones (old via Employee)
SELECT #tempTableFinalSelect.deptCode, #tempTableFinalSelect.employeeID, xdes.serviceCode as ServiceID,
dbo.fun_ParsePhoneNumberWithExtension(eqop.prePrefix, eqop.prefix, eqop.phone, eqop.extension) as Phone
FROM #tempTableFinalSelect  
INNER JOIN EmployeeQueueOrderMethod eqom ON #tempTableFinalSelect.DeptEmployeeID = eqom.DeptEmployeeID
INNER JOIN DeptEmployeeQueueOrderPhones eqop ON eqom.QueueOrderMethodID = eqop.QueueOrderMethodID

LEFT JOIN x_Dept_Employee_Service xdes 
	ON #tempTableFinalSelect.DeptEmployeeID = xdes.DeptEmployeeID
	AND #tempTableFinalSelect.ServiceID = xdes.serviceCode
LEFT JOIN EmployeeServiceQueueOrderMethod esqom
	ON xdes.x_Dept_Employee_ServiceID = esqom.x_dept_employee_serviceID
WHERE esqom.x_dept_employee_serviceID is null
--
'

-- For values to be passed as parameters for page by page searches
IF (@ServiceCodes is null)
	BEGIN
		SET @SqlEnd = @SqlEnd + ' SELECT deptCode FROM #tempTableAllRows ORDER BY RowNumber
		'
	END
ELSE
	BEGIN
		SET @SqlEnd = @SqlEnd + ' SELECT ServiceID, DeptEmployeeID, ServiceOrEvent FROM #tempTableAllRows ORDER BY RowNumber
		'
	END

SET @SqlEnd = @SqlEnd +
'		
DROP TABLE #tempTableAllRows
DROP TABLE #tempTableFinalSelect
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
	@xMaxNumberOfRecords = @MaxNumberOfRecords,
	
	@xClalitServiceCode = @ClalitServiceCode, 
	@xClalitServiceDescription = @ClalitServiceDescription, 
	@xMedicalAspectCode = @MedicalAspectCode, 
	@xMedicalAspectDescription = @MedicalAspectDescription,
	@xServiceCodeForMuslam = @ServiceCodeForMuslam,
	@xGroupCode = @GroupCode,
	@xSubGroupCode = @SubGroupCode	


GO

/* rpc_getDoctorList_PagedSorted  
NEW: view_DeptEmployeeServiceRemarks instead of DeptEmployeeServiceRemarks */
ALTER Procedure [dbo].[rpc_getDoctorList_PagedSorted]
(
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
@OpenNow bit,
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
@ReceiveGuests bit,


@PageSise int = null,
@StartingPage int = null,
@SortedBy varchar(max),
@IsOrderDescending int = null,


@NumberOfRecordsToShow int=null,
@CoordinateX float=null,
@CoordinateY float=null,

@userIsRegistered int=null,

@isGetEmployeesReceptionHours bit=null

)

AS

SET @StartingPage = @StartingPage - 1

DECLARE @StartingPosition int
SET @StartingPosition = (@StartingPage * @PageSise)

DECLARE @SortedByDefault varchar(max)
SET @SortedByDefault = 'lastname'

DECLARE @Count int

DECLARE @HandicappedFacilitiesCount int

IF(@deptHandicappedFacilities is NOT null)
	SET @HandicappedFacilitiesCount = IsNull((SELECT COUNT(IntField) FROM dbo.SplitString(@DeptHandicappedFacilities)), 0)

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
DECLARE @OpenAtThisHour_var varchar(5)

SET @OpenAtHour_var = IsNull(@OpenAtHour_Str,'00:00')
SET @OpenFromHour_var = IsNull(@OpenFromHour_Str,'00:00')
SET @OpenToHour_var = IsNull(@OpenToHour_Str,'24:00')
SET @OpenAtThisHour_var = '00:00'

DECLARE @DateNow datetime = GETDATE()

DECLARE @ReceptionDayNow tinyint

DECLARE @UseReceptionHours tinyint
	IF(@OpenAtHour_Str is null AND @OpenFromHour_Str is null AND @OpenToHour_Str is null AND @OpenNow <> 1)
		SET @UseReceptionHours = 0
	ELSE
		SET @UseReceptionHours = 1

DECLARE @ShowProvidersWithNoReceptionHours tinyint
	IF(@OpenAtHour_Str is NOT null OR @OpenFromHour_Str is NOT null OR @OpenToHour_Str is NOT null OR @OpenNow = 1 OR @ReceptionDays is NOT NULL)
		SET @ShowProvidersWithNoReceptionHours = 1
	ELSE
		SET @ShowProvidersWithNoReceptionHours = 0

--print '@UseReceptionHours = ' + CAST (@ShowProvidersWithNoReceptionHours as varchar(10))

IF (@OpenNow = 1)
BEGIN

	SET @ReceptionDayNow = DATEPART(WEEKDAY, GETDATE())
	IF(@ReceptionDays is NULL)
		SET @ReceptionDays = CAST(@ReceptionDayNow as varchar(1))
	ELSE
		IF(PATINDEX('%' + CAST(@ReceptionDayNow as varchar(1)) + '%', @ReceptionDays) = 0)
			SET @ReceptionDays = @ReceptionDays + ',' + CAST(@ReceptionDayNow as varchar(1))
		
	SET @OpenAtThisHour_var =	RIGHT('0' + CAST(DATEPART(HH, GETDATE()) as varchar(2)), 2) 
								+ ':' 
								+ RIGHT('0' + CAST(DATEPART(MINUTE, GETDATE()) as varchar(2)), 2)							 
END
CREATE TABLE #tempTableAllRows
(
	RowNumber int,
	ID bigint NOT NULL,
	employeeID bigint NOT NULL,
	EmployeeName varchar(100) NULL,	
	lastName varchar(50) NULL,
	firstName varchar(50) NULL,
	deptName varchar(100) NULL,
	deptCode int NULL,
	DeptEmployeeID bigint NULL,
	QueueOrderDescription varchar(50) NULL,
	[address] varchar(500) NULL,
	cityName varchar(50) NULL,
	phone varchar(50) NULL,
	fax varchar(50) NULL,
	HasReception bit NULL,
	HasRes varchar(50) NULL,
	expert varchar(500) NULL,		
	HasRemarks bit NULL,
	professions varchar(500) NULL,
	[services] varchar(500) NULL,
	positions varchar(500) NULL,
	AgreementType tinyint NULL,
	AgreementTypeDescription varchar(50) NULL,
	EmployeeLanguage varchar(100) NULL,
	EmployeeLanguageDescription varchar(500) NULL,
	distance float,
	hasMapCoordinates tinyint NULL,
	EmployeeStatus tinyint NULL,
	EmployeeStatusInDept tinyint NULL,
	orderLastNameLike tinyint,
	IsMedicalTeam bit NULL,
	IsVirtualDoctor bit NULL,
	ReceiveGuests int NULL,
	xcoord float NULL,
	ycoord float NULL,
)
-- *************************
SELECT IntField INTO #LanguageCodeTable FROM dbo.SplitString(@LanguageCode)
SELECT IntField INTO #deptHandicappedFacilitiesTable FROM dbo.SplitString(@deptHandicappedFacilities)
SELECT IntField INTO #districtCodesTable FROM dbo.SplitString(@DistrictCodes)
SELECT IntField INTO #serviceCodeTable FROM dbo.SplitString(@serviceCode)
SELECT IntField INTO #receptionDaysTable FROM dbo.SplitString(@ReceptionDays)

--**************************
IF(@NumberOfRecordsToShow <> -1)
-- search by distance **************************
	BEGIN
		SELECT * INTO #tempTableAllRowsDistance FROM
		( 
			SELECT *, 'RowNumber' = row_number() over (order by distance )	

		FROM

		-- inner selection - "employees themself"
		(

		SELECT DISTINCT 
		EmployeeInClinic_preselected.ID,
		EmployeeInClinic_preselected.employeeID,
		EmployeeInClinic_preselected.deptCode,
		EmployeeInClinic_preselected.DeptEmployeeID,
		'distance' = (EmployeeInClinic_preselected.xcoord - @CoordinateX)*(EmployeeInClinic_preselected.xcoord - @CoordinateX) + (EmployeeInClinic_preselected.ycoord - @CoordinateY)*(EmployeeInClinic_preselected.ycoord - @CoordinateY)

		FROM EmployeeInClinic_preselected

		LEFT JOIN x_Dept_Employee ON EmployeeInClinic_preselected.employeeID = x_Dept_Employee.employeeID
			AND EmployeeInClinic_preselected.deptCode = x_Dept_Employee.deptCode
			AND (@userIsRegistered = 1 OR x_Dept_Employee.employeeID is NOT NULL)
		LEFT JOIN dept ON EmployeeInClinic_preselected.deptCode = dept.deptCode
			AND (@userIsRegistered = 1 OR dept.status = 1)

		LEFT JOIN vEmplServReseption as vEmSerRecep	
			ON x_Dept_Employee.deptCode = vEmSerRecep.deptCode
			AND x_Dept_Employee.employeeID = vEmSerRecep.employeeID
			AND CAST(GETDATE() as date) between ISNULL(vEmSerRecep.validFrom,'1900-01-01') and ISNULL(vEmSerRecep.validTo,'2079-01-01')
			
		LEFT JOIN vEmplServAgreemExpert as vEmSerExp
			ON x_Dept_Employee.deptCode = vEmSerExp.deptCode
			AND x_Dept_Employee.employeeID = vEmSerExp.employeeID

		WHERE  (@DistrictCodes is NULL
			OR
				dept.districtCode IN (SELECT IntField FROM #districtCodesTable)
			OR
				dept.DeptCode IN (SELECT x_Dept_District.DeptCode FROM #districtCodesTable
									 JOIN  x_Dept_District ON #districtCodesTable.IntField = x_Dept_District.districtCode) 
			)
		AND (@FirstName is NULL OR EmployeeInClinic_preselected.FirstName like @FirstName +'%')
		AND (@LastName is NULL OR EmployeeInClinic_preselected.LastName like @LastName +'%')
		AND (@EmployeeID is NULL OR EmployeeInClinic_preselected.EmployeeID = @EmployeeID )
		AND (@CityName is NULL OR  EmployeeInClinic_preselected.CityName like @CityName +'%')
		AND (@CoordinateX is NOT NULL OR (@CityCode is NULL OR EmployeeInClinic_preselected.cityCode = @CityCode))
		AND (@Active is NULL
			OR
			(
				(@Active = 1 
					AND (EmployeeInClinic_preselected.EmployeeStatusInDept IN (1,2) 
						or 
						(EmployeeInClinic_preselected.EmployeeStatusInDept is null and EmployeeInClinic_preselected.EmployeeStatus IN (1,2))
						)
				)

				OR
				
				(@Active <> 1
				AND (EmployeeInClinic_preselected.EmployeeStatusInDept = @Active 
					or
					(EmployeeInClinic_preselected.EmployeeStatusInDept is null and EmployeeInClinic_preselected.EmployeeStatus = @Active))
			)
			)
			)
		AND (@EmployeeSectorCode is NULL OR EmployeeInClinic_preselected.EmployeeSectorCode = @EmployeeSectorCode)
		AND (@Sex is NULL OR EmployeeInClinic_preselected.sex = @Sex)
		AND (@ExpProfession is NULL OR @serviceCode is NOT NULL OR EmployeeInClinic_preselected.IsExpert = @ExpProfession ) 
		AND (@serviceCode is NULL 
				OR
				(vEmSerExp.serviceCode IN (SELECT IntField FROM #serviceCodeTable)
					AND	
					((@IsInCommunity = 1 AND (vEmSerExp.AgreementType in (1,2,6)))
						OR
					(@IsInMushlam = 1 AND (vEmSerExp.AgreementType in (3,4)))
						OR
					(@IsInHospitals = 1 AND vEmSerExp.AgreementType = 5)
					)
					AND
					(@ExpProfession is NULL OR vEmSerExp.ExpProfession = @ExpProfession)
				)
			)
		AND (@AgreementType is NULL OR EmployeeInClinic_preselected.AgreementType = @AgreementType)

		AND (
				(@isInCommunity is not NULL AND EmployeeInClinic_preselected.IsInCommunity = @IsInCommunity 
						AND (Dept.IsCommunity = @IsInCommunity OR Dept.IsCommunity IS NULL)
				)
			OR (@isInMushlam is not NULL AND EmployeeInClinic_preselected.IsInMushlam = @IsInMushlam 
						AND (Dept.IsMushlam = @IsInMushlam OR Dept.IsMushlam IS NULL)
				)
			OR (@isInHospitals is not NULL AND EmployeeInClinic_preselected.isInHospitals = @isInHospitals 
						AND (Dept.isHospital = @isInHospitals OR Dept.isHospital IS NULL)
				)
			)
			
		AND (@LanguageCode is NULL 
				OR 
				exists (
				SELECT * FROM dbo.SplitString(EmployeeInClinic_preselected.EmployeeLanguage) as T 
				JOIN #LanguageCodeTable ON #LanguageCodeTable.IntField = T.IntField)
			)

		AND (@deptHandicappedFacilities is NULL 
				OR 
				(SELECT COUNT(T.IntField) FROM dbo.SplitString(EmployeeInClinic_preselected.DeptHandicappedFacilities) as T 
				JOIN #deptHandicappedFacilitiesTable ON #deptHandicappedFacilitiesTable.IntField = T.IntField) = @HandicappedFacilitiesCount)	
			
		AND (@positionCode is NULL 
				OR 
				exists (SELECT xd.employeeID 
						FROM x_Dept_Employee_Position xdep
						INNER JOIN x_Dept_Employee xd ON xdep.DeptEmployeeID = xd.DeptEmployeeID
						WHERE x_Dept_Employee.employeeID = xd.employeeID
						AND xdep.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID									
						AND xdep.positionCode = @PositionCode)
			)
		AND	(
				(@ReceptionDays is NULL AND (@OpenNow is NULL OR @OpenNow = 0))
				OR
				(
					(
						vEmSerRecep.receptionDay IN (SELECT IntField FROM #receptionDaysTable)
						AND
						(@ServiceCode is NULL OR vEmSerRecep.serviceCode IN (SELECT IntField FROM #serviceCodeTable))		
					)	
				)
			)
		AND (
				(@OpenToHour_Str is NULL AND @OpenFromHour_Str is NULL)
				OR
				 ( vEmSerRecep.openingHour < @OpenToHour_var AND vEmSerRecep.closingHour > @OpenFromHour_var )
			)
		AND ( @OpenAtHour_Str is NULL 
				OR (vEmSerRecep.openingHour <= @OpenAtHour_var AND vEmSerRecep.closingHour >= @OpenAtHour_var )
			)
		AND ((@OpenNow is NULL OR @OpenNow = 0)
				OR  ( vEmSerRecep.openingHour <= @OpenAtThisHour_var AND vEmSerRecep.closingHour >= @OpenAtThisHour_var )
			)
		AND ((@ReceiveGuests is NULL OR @ReceiveGuests = 0 
				OR ((@UseReceptionHours = 0 AND @ReceptionDays is NULL) OR vEmSerRecep.ReceiveGuests = @ReceiveGuests) )
			)				
		AND (@CoordinateX is NULL OR ( xcoord <> 0 AND ycoord <> 0)) -- redundantly????

		AND (@licenseNumber is NULL OR EmployeeInClinic_preselected.licenseNumber = @LicenseNumber)

		AND (@ReceiveGuests is NULL OR @ReceiveGuests = 0 
				OR (@UseReceptionHours = 1 OR @ReceptionDays is NOT NULL OR EmployeeInClinic_preselected.ReceiveGuests = @ReceiveGuests))

		AND (@NumberOfRecordsToShow is NULL OR (EmployeeInClinic_preselected.xcoord <> 0 and EmployeeInClinic_preselected.ycoord <> 0))

		) as innerSelection
		) as middleSelection
		OPTION (RECOMPILE)
	
		INSERT INTO #tempTableAllRows 
		SELECT 
		#tempTableAllRowsDistance.RowNumber,
		EmployeeInClinic_preselected.ID,		 
		EmployeeInClinic_preselected.employeeID,
		EmployeeInClinic_preselected.EmployeeName,
		EmployeeInClinic_preselected.lastname,
		EmployeeInClinic_preselected.firstName,
		EmployeeInClinic_preselected.deptName,
		EmployeeInClinic_preselected.deptCode,
		EmployeeInClinic_preselected.DeptEmployeeID,
		EmployeeInClinic_preselected.QueueOrderDescription,
		EmployeeInClinic_preselected.address,
		EmployeeInClinic_preselected.cityName,
		EmployeeInClinic_preselected.phone,
		EmployeeInClinic_preselected.fax,
		EmployeeInClinic_preselected.HasReception,
		'expert' = EmployeeInClinic_preselected.ExpProfession,
		EmployeeInClinic_preselected.HasRemarks,
		EmployeeInClinic_preselected.professions_ASC as 'professions',
		EmployeeInClinic_preselected.[services],
		EmployeeInClinic_preselected.positions,	
		EmployeeInClinic_preselected.AgreementType,
		EmployeeInClinic_preselected.AgreementTypeDescription,
		EmployeeInClinic_preselected.EmployeeLanguage,
		EmployeeInClinic_preselected.EmployeeLanguageDescription,		
		#tempTableAllRowsDistance.distance,
		EmployeeInClinic_preselected.hasMapCoordinates,
		EmployeeInClinic_preselected.EmployeeStatus,
		EmployeeInClinic_preselected.EmployeeStatusInDept,
		'orderLastNameLike' = 1,
		EmployeeInClinic_preselected.IsMedicalTeam,
		EmployeeInClinic_preselected.IsVirtualDoctor,
		EmployeeInClinic_preselected.ReceiveGuests,
		EmployeeInClinic_preselected.xcoord,
		EmployeeInClinic_preselected.ycoord
		FROM EmployeeInClinic_preselected
		JOIN #tempTableAllRowsDistance 
			ON #tempTableAllRowsDistance.employeeID = EmployeeInClinic_preselected.employeeID
			AND #tempTableAllRowsDistance.deptCode = EmployeeInClinic_preselected.deptCode					
			AND #tempTableAllRowsDistance.DeptEmployeeID = EmployeeInClinic_preselected.DeptEmployeeID		
	END		
-- END search by distance **************************
ELSE
-- regular search **************************
	BEGIN
		INSERT INTO #tempTableAllRows SELECT * FROM
			( 
			SELECT 
		'RowNumber' = row_number() over (order by 
									(case	
											when @SortedBy='lastname' 
											then lastname
											when @SortedBy='deptName' 
											then deptName 
											when @SortedBy='professions' 
											then professions
											when @SortedBy='cityName' 
											then cityName									
											when @SortedBy='phone' 
											then phone	
											when @SortedBy='address' 
											then 'address'
											when @SortedBy='AgreementType' 
											then CAST(AgreementType	as varchar(50))
											else 
											CASE WHEN @ShowProvidersWithNoReceptionHours = 1 THEN
													HasRes + CAST(newid() as varchar(50)) --lastname 
												ELSE
													CAST(newid() as varchar(50))															
												END
											end )									
											+
									case	when @IsOrderDescending = 0 
											then '' else null end
									,case when @SortedBy='distance' then CAST(deptCode as varchar(50)) else null end									
									,(case	
											when @SortedBy='lastname' 
											then lastname
											when @SortedBy='deptName' 
											then deptName 
											when @SortedBy='professions' 
											then professions
											when @SortedBy='cityName' 
											then cityName									
											when @SortedBy='phone' 
											then phone	
											when @SortedBy='address' 
											then 'address'
											when @SortedBy='AgreementType' 
											then CAST(AgreementType	as varchar(50))	
											else CAST(newid() as varchar(50)) --lastname 																			
											end )
											+
									case	when @IsOrderDescending = 1 
											then '' else null end
											
											DESC
							)	
		,*
		FROM

		-- inner selection - "employees themself"
		(

		SELECT DISTINCT 
		EmployeeInClinic_preselected.ID,
		EmployeeInClinic_preselected.employeeID,
		EmployeeInClinic_preselected.EmployeeName,
		EmployeeInClinic_preselected.lastname,
		EmployeeInClinic_preselected.firstName,
		EmployeeInClinic_preselected.deptName,
		EmployeeInClinic_preselected.deptCode,
		EmployeeInClinic_preselected.DeptEmployeeID,
		EmployeeInClinic_preselected.QueueOrderDescription,
		EmployeeInClinic_preselected.address,
		EmployeeInClinic_preselected.cityName,
		EmployeeInClinic_preselected.phone,
		EmployeeInClinic_preselected.fax,
		EmployeeInClinic_preselected.HasReception,
		CASE WHEN EmployeeInClinic_preselected.HasReception = 1 THEN 'כן' else 'לא' end as  HasRes,
		'expert' = EmployeeInClinic_preselected.ExpProfession,
		EmployeeInClinic_preselected.HasRemarks,
		CASE WHEN @IsOrderDescending = 0 THEN EmployeeInClinic_preselected.professions_ASC
			ELSE EmployeeInClinic_preselected.professions_DESC END as 'professions',
		EmployeeInClinic_preselected.[services],
		EmployeeInClinic_preselected.positions,	
		EmployeeInClinic_preselected.AgreementType,
		EmployeeInClinic_preselected.AgreementTypeDescription,
		EmployeeInClinic_preselected.EmployeeLanguage,
		EmployeeInClinic_preselected.EmployeeLanguageDescription,		
		'distance' = (EmployeeInClinic_preselected.xcoord - @CoordinateX)*(EmployeeInClinic_preselected.xcoord - @CoordinateX) + (EmployeeInClinic_preselected.ycoord - @CoordinateY)*(EmployeeInClinic_preselected.ycoord - @CoordinateY),
		EmployeeInClinic_preselected.hasMapCoordinates,
		EmployeeInClinic_preselected.EmployeeStatus,
		EmployeeInClinic_preselected.EmployeeStatusInDept,
		'orderLastNameLike' =
			CASE WHEN @LastName is NOT null AND EmployeeInClinic_preselected.LastName like @LastName + '%' THEN 0
				 WHEN @LastName is NOT null AND EmployeeInClinic_preselected.LastName like '%' + @LastName + '%' THEN 1 
				 ELSE 0 END,
		EmployeeInClinic_preselected.IsMedicalTeam,
		EmployeeInClinic_preselected.IsVirtualDoctor,
		EmployeeInClinic_preselected.ReceiveGuests,
		EmployeeInClinic_preselected.xcoord,
		EmployeeInClinic_preselected.ycoord

		FROM EmployeeInClinic_preselected

		LEFT JOIN x_Dept_Employee ON EmployeeInClinic_preselected.employeeID = x_Dept_Employee.employeeID
			AND EmployeeInClinic_preselected.deptCode = x_Dept_Employee.deptCode
			AND (@userIsRegistered = 1 OR x_Dept_Employee.employeeID is NOT NULL)
		LEFT JOIN dept ON EmployeeInClinic_preselected.deptCode = dept.deptCode
			AND (@userIsRegistered = 1 OR dept.status = 1)

		LEFT JOIN vEmplServReseption as vEmSerRecep	
			ON x_Dept_Employee.deptCode = vEmSerRecep.deptCode
			AND x_Dept_Employee.employeeID = vEmSerRecep.employeeID
			AND CAST(GETDATE() as date) between ISNULL(vEmSerRecep.validFrom,'1900-01-01') and ISNULL(vEmSerRecep.validTo,'2079-01-01')
			
		LEFT JOIN vEmplServAgreemExpert as vEmSerExp
			ON x_Dept_Employee.deptCode = vEmSerExp.deptCode
			AND x_Dept_Employee.employeeID = vEmSerExp.employeeID

		WHERE 
			(@DistrictCodes is NULL
			OR
				dept.districtCode IN (SELECT IntField FROM #districtCodesTable)
			OR
				dept.DeptCode IN (SELECT x_Dept_District.DeptCode FROM #districtCodesTable
									 JOIN  x_Dept_District ON #districtCodesTable.IntField = x_Dept_District.districtCode) 
			)
		AND (@FirstName is NULL OR EmployeeInClinic_preselected.FirstName like @FirstName +'%')
		AND (@LastName is NULL OR EmployeeInClinic_preselected.LastName like @LastName +'%')
		AND (@EmployeeID is NULL OR EmployeeInClinic_preselected.EmployeeID = @EmployeeID )
		AND (@CityName is NULL OR  EmployeeInClinic_preselected.CityName like @CityName +'%')
		AND (@CoordinateX is NOT NULL OR (@CityCode is NULL OR EmployeeInClinic_preselected.cityCode = @CityCode))
		AND (@Active is NULL
			OR
			(
				(@Active = 1 
					AND (EmployeeInClinic_preselected.EmployeeStatusInDept IN (1,2) 
						or 
						(EmployeeInClinic_preselected.EmployeeStatusInDept is null and EmployeeInClinic_preselected.EmployeeStatus IN (1,2))
						)
				)

				OR
				
				(@Active <> 1
				AND (EmployeeInClinic_preselected.EmployeeStatusInDept = @Active 
					or
					(EmployeeInClinic_preselected.EmployeeStatusInDept is null and EmployeeInClinic_preselected.EmployeeStatus = @Active))
			)
			)
			)
		AND (@EmployeeSectorCode is NULL OR EmployeeInClinic_preselected.EmployeeSectorCode = @EmployeeSectorCode)
		AND (@Sex is NULL OR EmployeeInClinic_preselected.sex = @Sex)
		--AND (@ExpProfession is NULL OR EmployeeInClinic_preselected.IsExpert = @ExpProfession ) 
		AND (@ExpProfession is NULL OR @serviceCode is NOT NULL OR EmployeeInClinic_preselected.IsExpert = @ExpProfession ) 
		AND (@serviceCode is NULL 
				OR
				(vEmSerExp.serviceCode IN (SELECT IntField FROM #serviceCodeTable)
					AND	
					((@IsInCommunity = 1 AND (vEmSerExp.AgreementType in (1,2,6)))
						OR
					(@IsInMushlam = 1 AND (vEmSerExp.AgreementType in (3,4)))
						OR
					(@IsInHospitals = 1 AND vEmSerExp.AgreementType = 5)
					)
					AND
					(@ExpProfession is NULL OR vEmSerExp.ExpProfession = @ExpProfession)
				)
			)
		AND (@AgreementType is NULL OR EmployeeInClinic_preselected.AgreementType = @AgreementType)

		AND (
				(@isInCommunity is not NULL AND EmployeeInClinic_preselected.IsInCommunity = @IsInCommunity 
						AND (Dept.IsCommunity = @IsInCommunity OR Dept.IsCommunity IS NULL)
				)
			OR (@isInMushlam is not NULL AND EmployeeInClinic_preselected.IsInMushlam = @IsInMushlam 
						AND (Dept.IsMushlam = @IsInMushlam OR Dept.IsMushlam IS NULL)
				)
			OR (@isInHospitals is not NULL AND EmployeeInClinic_preselected.isInHospitals = @isInHospitals 
						AND (Dept.isHospital = @isInHospitals OR Dept.isHospital IS NULL)
				)
			)
		AND (@LanguageCode is NULL 
				OR 
				exists (
				SELECT * FROM dbo.SplitString(EmployeeInClinic_preselected.EmployeeLanguage) as T 
				JOIN #LanguageCodeTable ON #LanguageCodeTable.IntField = T.IntField)
			)

		AND (@deptHandicappedFacilities is NULL 
				OR 
				(SELECT COUNT(T.IntField) FROM dbo.SplitString(EmployeeInClinic_preselected.DeptHandicappedFacilities) as T 
				JOIN #deptHandicappedFacilitiesTable ON #deptHandicappedFacilitiesTable.IntField = T.IntField) = @HandicappedFacilitiesCount)	
			
		AND (@positionCode is NULL 
				OR 
				exists (SELECT xd.employeeID 
						FROM x_Dept_Employee_Position xdep
						INNER JOIN x_Dept_Employee xd ON xdep.DeptEmployeeID = xd.DeptEmployeeID
						WHERE x_Dept_Employee.employeeID = xd.employeeID
						AND xdep.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID									
						AND xdep.positionCode = @PositionCode)
			)
		AND ( (@ShowProvidersWithNoReceptionHours = 1 AND (HasReception = 0 OR NOT exists(SELECT * FROM vEmplServReseption vESR WHERE vESR.employeeID = vEmSerRecep.employeeID AND vESR.deptCode = vEmSerRecep.deptCode AND vESR.serviceCode IN (SELECT IntField FROM #serviceCodeTable) ) ))
				OR 
				( (
						(@ReceptionDays is NULL AND (@OpenNow is NULL OR @OpenNow = 0))
						OR
						(
							(
								vEmSerRecep.receptionDay IN (SELECT IntField FROM #receptionDaysTable)
								AND
								(@ServiceCode is NULL OR vEmSerRecep.serviceCode IN (SELECT IntField FROM #serviceCodeTable))		
							)	
						)
					)
				AND (
						(@OpenToHour_Str is NULL AND @OpenFromHour_Str is NULL)
						OR
						 ( vEmSerRecep.openingHour < @OpenToHour_var AND vEmSerRecep.closingHour > @OpenFromHour_var )
					)
				AND ( @OpenAtHour_Str is NULL 
						OR (vEmSerRecep.openingHour <= @OpenAtHour_var AND vEmSerRecep.closingHour >= @OpenAtHour_var )
					)
				AND ((@OpenNow is NULL OR @OpenNow = 0)
						OR  ( vEmSerRecep.openingHour <= @OpenAtThisHour_var AND vEmSerRecep.closingHour >= @OpenAtThisHour_var )
					)
				AND ((@ReceiveGuests is NULL OR @ReceiveGuests = 0 
						OR ((@UseReceptionHours = 0 AND @ReceptionDays is NULL) OR vEmSerRecep.ReceiveGuests = @ReceiveGuests) )
					)
				)
			)				
		AND (@CoordinateX is NULL OR ( xcoord <> 0 AND ycoord <> 0)) -- redundant????

		AND (@licenseNumber is NULL OR EmployeeInClinic_preselected.licenseNumber = @LicenseNumber)

		AND (@ReceiveGuests is NULL OR @ReceiveGuests = 0 
				OR (@UseReceptionHours = 1 OR @ReceptionDays is NOT NULL OR EmployeeInClinic_preselected.ReceiveGuests = @ReceiveGuests))

		AND (@NumberOfRecordsToShow is NULL OR (EmployeeInClinic_preselected.xcoord <> 0 and EmployeeInClinic_preselected.ycoord <> 0))

		) as innerSelection
		) as middleSelection
	END	
-- END regular search **************************


SELECT TOP (@PageSise) * INTO #tempTable FROM #tempTableAllRows
WHERE RowNumber > @StartingPosition AND RowNumber <= @StartingPosition + @PageSise
ORDER BY RowNumber

SELECT * FROM #tempTable

/***** DeptPhones ************************/
SELECT *
INTO #tempTableDeptPhones
FROM(
-- DeptPhones (new via employees services)
SELECT #tempTable.deptCode, #tempTable.employeeID, xdes.serviceCode as ServiceID
	,dbo.fun_ParsePhoneNumberWithExtension(DeptPhones.prePrefix, DeptPhones.prefix, DeptPhones.phone, DeptPhones.extension) as Phone
FROM EmployeeServiceQueueOrderMethod esqom
INNER JOIN x_Dept_Employee_Service xdes ON esqom.x_dept_employee_serviceID = xdes.x_Dept_Employee_ServiceID
INNER JOIN #tempTable ON xdes.DeptEmployeeID = #tempTable.DeptEmployeeID 
INNER JOIN DIC_QueueOrderMethod ON esqom.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
INNER JOIN DeptPhones ON #tempTable.deptCode = DeptPhones.deptCode
--WHERE phoneType = 1 AND phoneOrder = 1 AND SpecialPhoneNumberRequired = 0 AND ShowPhonePicture = 1 
WHERE phoneType = 1 AND SpecialPhoneNumberRequired = 0 AND ShowPhonePicture = 1 

UNION

-- DeptPhones (old via Employee)
SELECT #tempTable.deptCode, #tempTable.employeeID, xdes.serviceCode as ServiceID,  
	dbo.fun_ParsePhoneNumberWithExtension(DeptPhones.prePrefix, DeptPhones.prefix, DeptPhones.phone, DeptPhones.extension) as Phone
FROM #tempTable  
INNER JOIN EmployeeQueueOrderMethod eqom ON #tempTable.DeptEmployeeID = eqom.DeptEmployeeID
INNER JOIN DIC_QueueOrderMethod ON eqom.QueueOrderMethod = DIC_QueueOrderMethod.QueueOrderMethod
INNER JOIN DeptPhones ON #tempTable.deptCode = DeptPhones.deptCode

LEFT JOIN x_Dept_Employee_Service xdes 
	ON #tempTable.DeptEmployeeID = xdes.DeptEmployeeID
LEFT JOIN EmployeeServiceQueueOrderMethod esqom
	ON xdes.x_Dept_Employee_ServiceID = esqom.x_dept_employee_serviceID
	AND  esqom.QueueOrderMethod = 1
--WHERE phoneType = 1 AND phoneOrder = 1 AND SpecialPhoneNumberRequired = 0 
WHERE phoneType = 1 AND SpecialPhoneNumberRequired = 0 
AND ShowPhonePicture = 1 AND esqom.x_dept_employee_serviceID is null
--OPTION (FORCE order)
) T

/*****  END DeptPhones ************************/

/*****  QueueOrderPhones ************************/
SELECT *
INTO #tempQueueOrderPhones
FROM(
-- SpecialPhones (new via employees services)
SELECT xde.deptCode, xde.employeeID, xdes.serviceCode as ServiceID,
dbo.fun_ParsePhoneNumberWithExtension(esqop.prePrefix, esqop.prefix, esqop.phone, esqop.extension) as Phone
FROM #tempTable
JOIN x_Dept_Employee xde ON #tempTable.deptCode = xde.deptCode
	AND #tempTable.employeeID = xde.employeeID
JOIN x_Dept_Employee_Service xdes ON xde.DeptEmployeeID = xdes.DeptEmployeeID
	--AND #tempTableFinalSelect.ServiceID = xdes.serviceCode
JOIN EmployeeServiceQueueOrderMethod esqom ON xdes.x_Dept_Employee_ServiceID = esqom.x_dept_employee_serviceID
JOIN EmployeeServiceQueueOrderPhones esqop ON esqom.EmployeeServiceQueueOrderMethodID = esqop.EmployeeServiceQueueOrderMethodID

UNION

-- SpecialPhones (old via Employee)
SELECT #tempTable.deptCode, #tempTable.employeeID, xdes.serviceCode as ServiceID,
dbo.fun_ParsePhoneNumberWithExtension(eqop.prePrefix, eqop.prefix, eqop.phone, eqop.extension) as Phone
FROM #tempTable  
INNER JOIN EmployeeQueueOrderMethod eqom ON #tempTable.DeptEmployeeID = eqom.DeptEmployeeID
INNER JOIN DeptEmployeeQueueOrderPhones eqop ON eqom.QueueOrderMethodID = eqop.QueueOrderMethodID

LEFT JOIN x_Dept_Employee_Service xdes 
	ON #tempTable.DeptEmployeeID = xdes.DeptEmployeeID
LEFT JOIN EmployeeServiceQueueOrderMethod esqom
	ON xdes.x_Dept_Employee_ServiceID = esqom.x_dept_employee_serviceID
WHERE esqom.x_dept_employee_serviceID is null
) T
/*****  END QueueOrderPhones ************************/

/********************  QueueOrderMethods *************************/
SELECT QO.*, Ph.Phone
INTO #tempTableQueueOrder
FROM(
	-- QueueOrderMethods (via employees services)
	SELECT ISNULL(esqom.QueueOrderMethod, 0) as QueueOrderMethod, #tempTable.deptCode, #tempTable.employeeID, 
		DIC_ReceptionDays.receptionDayName, esqoh.FromHour, esqoh.ToHour, xdes.serviceCode as ServiceID,
		s.ServiceDescription,
		DIC_QueueOrder.QueueOrderDescription, DIC_QueueOrder.QueueOrder,
		#tempTable.RowNumber
	FROM x_Dept_Employee_Service xdes 
	INNER JOIN x_Dept_Employee xde ON xde.DeptEmployeeID = xdes.DeptEmployeeID
	INNER JOIN #tempTable ON xdes.DeptEmployeeID = #tempTable.DeptEmployeeID
	INNER JOIN [Services] s ON xdes.serviceCode = s.ServiceCode	
	LEFT JOIN EmployeeServiceQueueOrderMethod esqom ON esqom.x_dept_employee_serviceID = xdes.x_Dept_Employee_ServiceID
	LEFT JOIN dbo.DIC_QueueOrder ON xdes.QueueOrder = DIC_QueueOrder.QueueOrder

	LEFT JOIN EmployeeServiceQueueOrderHours esqoh ON esqom.EmployeeServiceQueueOrderMethodID = esqoh.EmployeeServiceQueueOrderMethodID
	LEFT JOIN DIC_ReceptionDays ON esqoh.receptionDay = DIC_ReceptionDays.ReceptionDayCode
	WHERE xdes.QueueOrder is not null
	
	UNION

	-- QueueOrderMethods (via Employee)
	SELECT ISNULL(eqom.QueueOrderMethod, 0) as QueueOrderMethod, #tempTable.deptCode, #tempTable.employeeID, 
		DIC_ReceptionDays.receptionDayName, eqoh.FromHour, eqoh.ToHour
		,xdes.serviceCode as ServiceID, s.ServiceDescription,
		ISNULL(DIC_QueueOrder.QueueOrderDescription, '') as QueueOrderDescription, ISNULL(DIC_QueueOrder.QueueOrder, 2) as QueueOrder,
		#tempTable.RowNumber		
	FROM #tempTable
	LEFT JOIN EmployeeQueueOrderMethod eqom ON eqom.DeptEmployeeID = #tempTable.DeptEmployeeID 
	LEFT JOIN EmployeeQueueOrderHours eqoh ON eqom.QueueOrderMethodID = eqoh.QueueOrderMethodID
	LEFT JOIN DIC_ReceptionDays ON eqoh.receptionDay = DIC_ReceptionDays.ReceptionDayCode
	JOIN x_Dept_Employee xde ON #tempTable.DeptEmployeeID = xde.DeptEmployeeID
	LEFT JOIN dbo.DIC_QueueOrder ON xde.QueueOrder = DIC_QueueOrder.QueueOrder
	-- exclude when queue order for service exists
	JOIN x_Dept_Employee_Service xdes 
		ON #tempTable.DeptEmployeeID = xdes.DeptEmployeeID
	LEFT JOIN EmployeeServiceQueueOrderMethod esqom
		ON xdes.x_Dept_Employee_ServiceID = esqom.x_dept_employee_serviceID 
	LEFT JOIN [Services] s ON xdes.serviceCode = s.ServiceCode
	WHERE esqom.QueueOrderMethod is null
	--AND xdes.QueueOrder is null
	
	) QO
LEFT JOIN
(	
	-- SpecialPhones (new via employees services)
	SELECT xde.deptCode, xde.employeeID, xdes.serviceCode as ServiceID,
	dbo.fun_ParsePhoneNumberWithExtension(esqop.prePrefix, esqop.prefix, esqop.phone, esqop.extension) as Phone
	FROM #tempTable
	JOIN x_Dept_Employee xde ON #tempTable.deptCode = xde.deptCode
		AND #tempTable.employeeID = xde.employeeID
	JOIN x_Dept_Employee_Service xdes ON xde.DeptEmployeeID = xdes.DeptEmployeeID
	JOIN EmployeeServiceQueueOrderMethod esqom ON xdes.x_Dept_Employee_ServiceID = esqom.x_dept_employee_serviceID
	JOIN EmployeeServiceQueueOrderPhones esqop ON esqom.EmployeeServiceQueueOrderMethodID = esqop.EmployeeServiceQueueOrderMethodID

	UNION

	-- SpecialPhones (old via Employee)
	SELECT #tempTable.deptCode, #tempTable.employeeID, xdes.serviceCode as ServiceID,
	dbo.fun_ParsePhoneNumberWithExtension(eqop.prePrefix, eqop.prefix, eqop.phone, eqop.extension) as Phone
	FROM #tempTable  
	INNER JOIN EmployeeQueueOrderMethod eqom ON #tempTable.DeptEmployeeID = eqom.DeptEmployeeID
	INNER JOIN DeptEmployeeQueueOrderPhones eqop ON eqom.QueueOrderMethodID = eqop.QueueOrderMethodID

	LEFT JOIN x_Dept_Employee_Service xdes 
		ON #tempTable.DeptEmployeeID = xdes.DeptEmployeeID
	LEFT JOIN EmployeeServiceQueueOrderMethod esqom
		ON xdes.x_Dept_Employee_ServiceID = esqom.x_dept_employee_serviceID
	WHERE esqom.x_dept_employee_serviceID is null
) Ph 
	ON QO.deptCode = Ph.deptCode 
	AND QO.employeeID = Ph.employeeID
	AND QO.ServiceID = Ph.ServiceID	

----------------------------------------
SELECT DISTINCT QueueOrderMethod, ISNULL(QueueOrder, 2) as QueueOrder, deptCode, employeeID, ServiceID
INTO #tempTableMarker
FROM #tempTableQueueOrder

SELECT QueueOrderMethod, QueueOrder, deptCode, employeeID, ServiceID,
LEFT(CAST(QueueOrder as varchar(1))
		+ REPLACE(
			 stuff((SELECT ',' + CONVERT(VARCHAR,QueueOrderMethod) 
			 FROM #tempTableMarker ttM2
			 WHERE ttM2.employeeID = ttM.employeeID
			 AND  ttM2.deptCode = ttM.deptCode
			 AND  ttM2.ServiceID = ttM.ServiceID
			 order by ttM2.QueueOrderMethod
			 for xml path ('')
			 ), 1, 1, ''), ',','')
		+ '0000', 5)
		 as 'Marker'
INTO #tempTableMarkerStuff
FROM #tempTableMarker ttM

----------------------------------------
SELECT ttQO.QueueOrderMethod, ttQO.QueueOrderDescription, ttQO.QueueOrder, ttQO.deptCode, ttQO.employeeID, ttQO.receptionDayName, ttQO.FromHour, ttQO.ToHour, ttQO.ServiceID, ttQO.ServiceDescription
,ttM.Marker + LEFT( REPLACE( REPLACE(ISNULL(ttQO.Phone, '000000000'), '-', ''),'*', '')  , 9) as 'Marker'
,ttQO.RowNumber
,ttDP.Phone as DeptPhone, ttQOP.Phone as QueueOrderPhone
FROM #tempTableQueueOrder ttQO
JOIN #tempTableMarkerStuff ttM 
	ON ttQO.deptCode = ttM.deptCode AND ttQO.employeeID = ttM.employeeID
	AND ttQO.ServiceID = ttM.ServiceID AND ttQO.QueueOrderMethod = ttM.QueueOrderMethod
	AND ttQO.QueueOrder = ttM.QueueOrder

LEFT JOIN #tempTableDeptPhones ttDP
	ON ttQO.deptCode = ttDP.deptCode
	AND ttQO.employeeID = ttDP.employeeID
	AND ttQO.ServiceID = ttDP.ServiceID
	
LEFT JOIN #tempQueueOrderPhones ttQOP
	ON ttQO.deptCode = ttQOP.deptCode
	AND ttQO.employeeID = ttQOP.employeeID
	AND ttQO.ServiceID = ttQOP.ServiceID	
/******************** END  QueueOrderMethods *************************/

DROP TABLE #tempTable
DROP TABLE #tempTableQueueOrder
DROP TABLE #tempTableMarkerStuff
DROP TABLE #tempTableMarker
DROP TABLE #tempTableDeptPhones
DROP TABLE #tempQueueOrderPhones

-- select with same joins and conditions as above
-- just to get count of all the records in select

SET @Count = (SELECT COUNT(*) FROM #tempTableAllRows)

IF(@NumberOfRecordsToShow is NOT null)
BEGIN
	IF(@Count > @NumberOfRecordsToShow)
	BEGIN
		SET @Count = @NumberOfRecordsToShow
	END
END
	
SELECT @Count

-- For values to be passed as parameters for page by page search
 SELECT ID FROM #tempTableAllRows ORDER BY RowNumber
--SELECT @Count -- temp

IF(@isGetEmployeesReceptionHours = 1)
BEGIN
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
		  ,v.[ServiceCode]
		  ,v.[AgreementType]
	  FROM [dbo].[vEmployeeReceptionHours_Having180300service] v
	  left join deptEmployeeReception dER on v.receptionID = dER.receptionID
	  left join DeptEmployeeReceptionRemarks DERR on dER.receptionID = DERR.EmployeeReceptionID
	  inner join #tempTableAllRows tbl
	  on tbl.deptCode = v.deptCode
	  and tbl.EmployeeID = v.EmployeeID
	  and tbl.AgreementType = v.AgreementType
	  order by v.[EmployeeID],v.[deptCode],v.[ServiceDescription]


	--Remarks
	SELECT distinct
		v_DE_ER.EmployeeID,
		v_DE_ER.DeptCode,
		dbo.rfn_GetFotmatedRemark(v_DE_ER.RemarkTextFormated) as RemarkText,
		CONVERT(VARCHAR(2),DAY(v_DE_ER.ValidTo)) + '/' + CONVERT(VARCHAR(2),MONTH(v_DE_ER.ValidTo)) + '/' + CONVERT(VARCHAR(4),YEAR(v_DE_ER.ValidTo)) as ValidTo
	FROM View_DeptEmployee_EmployeeRemarks v_DE_ER
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
	FROM view_DeptEmployeeServiceRemarks desr
	INNER JOIN x_dept_employee_service xdes ON desr.x_dept_employee_serviceID = xdes.x_Dept_Employee_ServiceID AND xdes.Status = 1
	inner join x_dept_employee xde on xdes.DeptEmployeeID = xde.DeptEmployeeID
	inner join #tempTableAllRows tbl on tbl.deptCode = xde.deptCode
	and tbl.EmployeeID = xde.EmployeeID
	where GETDATE() between ISNULL(desr.validFrom,'1900-01-01') 
						and ISNULL(desr.validTo,'2079-01-01')

END

DROP TABLE #tempTableAllRows


GO

/* rpc_Update_EmployeeInClinic_preselected  
NEW: view_DeptEmployeeServiceRemarks instead of DeptEmployeeServiceRemarks */
ALTER Procedure [dbo].[rpc_Update_EmployeeInClinic_preselected]
(@EmployeeID bigint, @DeptCode int, @DeptEmployeeID int)

AS
BEGIN

DECLARE @DateNow date = GETDATE()

DECLARE @LocEmployeeID bigint
SET @LocEmployeeID = @EmployeeID
DECLARE @LocDeptCode int
SET @LocDeptCode = @DeptCode
DECLARE @LocDeptEmployeeID int
SET @LocDeptEmployeeID = @DeptEmployeeID

SET XACT_ABORT on

	--PRINT (CONVERT( VARCHAR(24), GETDATE(), 121))
	
SELECT DISTINCT 
Employee.employeeID, 
Employee.EmployeeSectorCode,
CASE WHEN (Employee.EmployeeSectorCode = 7) THEN Employee.licenseNumber ELSE Employee.ProfessionalLicenseNumber END
	as licenseNumber,
Employee.sex,
Employee.lastName, 
Employee.firstName,
'EmployeeName' = DegreeName + ' ' + Employee.lastName + ' ' + Employee.firstName,
'deptName' = IsNull(dept.deptName, ''),
'deptCode' = IsNull(dept.deptCode, ''),
ISNULL(x_dept_employee.DeptEmployeeID, 0) as DeptEmployeeID,
dic.QueueOrderDescription,
'address' = dbo.GetAddress(x_Dept_Employee.deptCode),
'cityName' = IsNull(Cities.cityName, ''),
'cityCode' = IsNull(Cities.cityCode, 0),
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
'IsExpert' = CASE WHEN 
						exists  (
								SELECT EmployeeID
								FROM EmployeeServices 
								WHERE ExpProfession = 1 
								and EmployeeServices.EmployeeID = Employee.employeeID
								)
					THEN 1 ELSE 0 END,
'expert' = CASE(Employee.IsVirtualDoctor) WHEN 1 THEN '' ELSE dbo.fun_GetEmployeeExpert(Employee.employeeID) END,
'professions_ASC' =
	CASE WHEN EXISTS (	SELECT * FROM x_Dept_Employee_Service 
						WHERE x_Dept_Employee_Service.serviceCode = 180300
						AND x_Dept_Employee_Service.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID	) 				  
		 THEN ' התייעצות עם רופא מומחה למתן חו"ד שנייה בנושא: ' + ',' ELSE '' END
		+ ISNULL( 
			stuff((
				SELECT ','+ [Services].serviceDescription 
				FROM [Services]
				inner join x_Dept_Employee_Service xdes
				ON xdes.serviceCode = [Services].serviceCode
				and xdes.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
				WHERE xdes.Status = 1
				AND [Services].IsService = 0
				ORDER BY [Services].serviceDescription 
				for xml path('')
			),1,1,''),
		''),
'professions_DESC' =
	CASE WHEN EXISTS (	SELECT * FROM x_Dept_Employee_Service 
						WHERE x_Dept_Employee_Service.serviceCode = 180300
						AND x_Dept_Employee_Service.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID	) 				  
		 THEN ' התייעצות עם רופא מומחה למתן חו"ד שנייה בנושא: ' + ',' ELSE '' END
		+ ISNULL( 
			stuff((
				SELECT ','+ [Services].serviceDescription 
				FROM [Services]
				inner join x_Dept_Employee_Service xdes
				ON xdes.serviceCode = [Services].serviceCode
				and xdes.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
				WHERE xdes.Status = 1
				AND [Services].IsService = 0
				ORDER BY [Services].serviceDescription DESC  
				for xml path('')
			),1,1,''),
		''),		
						
'services' =
			stuff((
					SELECT ','+ [Services].serviceDescription 
					FROM [Services]
					inner join x_Dept_Employee_Service xdes
					ON xdes.serviceCode = [Services].serviceCode
					and xdes.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
					WHERE xdes.Status = 1
					AND [Services].IsService = 1
					AND [Services].ServiceCode <> 180300
					ORDER BY [Services].serviceDescription 
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
IsNull(DIC_AgreementTypes.AgreementTypeDescription, '') as AgreementTypeDescription,
'EmployeeLanguage'	= stuff((SELECT ',' + CAST(languages.languageCode as varchar(4))
		FROM EmployeeLanguages
		JOIN languages ON EmployeeLanguages.languageCode = languages.languageCode
		WHERE EmployeeLanguages.EmployeeID = Employee.employeeID
		for xml path('')
	),1,1,''),
'EmployeeLanguageDescription'	= stuff((SELECT ',' + CAST(languages.languageDescription as varchar(50))
		FROM EmployeeLanguages
		JOIN languages ON EmployeeLanguages.languageCode = languages.languageCode
		WHERE EmployeeLanguages.EmployeeID = Employee.employeeID
		for xml path('')
	),1,1,''),		
'hasMapCoordinates' = CASE IsNull((x_dept_XY.xcoord + x_dept_XY.ycoord),0) WHEN 0 THEN 0 ELSE 1 END,
'EmployeeStatus' = Employee.active,
'EmployeeStatusInDept' = IsNull(dbo.fun_GetDeptEmployeeCurrentStatus(x_dept_Employee.deptCode, x_dept_Employee.employeeID,x_dept_Employee.AgreementType), 0),
Employee.IsMedicalTeam,
Employee.IsVirtualDoctor,
	
CASE WHEN x_Dept_Employee.AgreementType is null THEN Employee.IsInCommunity
	ELSE CASE WHEN x_Dept_Employee.AgreementType in (1,2,6) THEN 1 ELSE 0 END 
	END as IsInCommunity,
CASE WHEN x_Dept_Employee.AgreementType is null THEN Employee.IsInHospitals
	ELSE CASE WHEN x_Dept_Employee.AgreementType in (5) THEN 1 ELSE 0 END 
	END as IsInHospitals,
CASE WHEN x_Dept_Employee.AgreementType is null THEN Employee.IsInMushlam
	ELSE CASE WHEN x_Dept_Employee.AgreementType in (3,4) THEN 1 ELSE 0 END 
	END as IsInMushlam,		

CASE WHEN EXISTS (SELECT * 
			FROM x_Dept_Employee_Service 
			WHERE x_Dept_Employee_Service.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
			AND x_Dept_Employee_Service.serviceCode in (2,40)) 
	 THEN 
		CASE WHEN EXISTS
				(SELECT * 
				FROM vEmplServReseption as vEmSerRecep 
				WHERE vEmSerRecep.deptCode = x_Dept_Employee.deptCode
				AND vEmSerRecep.employeeID = x_Dept_Employee.employeeID
				AND vEmSerRecep.serviceCode in (2,40))  
					
			 THEN 
				CASE
					WHEN
						(SELECT COUNT(*)
						FROM vEmplServReseption as vEmSerRecep	
						WHERE x_Dept_Employee.deptCode = vEmSerRecep.deptCode
						AND x_Dept_Employee.employeeID = vEmSerRecep.employeeID
						AND x_Dept_Employee.ReceiveGuests = vEmSerRecep.ReceiveGuests) = 0
					THEN
						CASE WHEN ISNULL(x_Dept_Employee.ReceiveGuests, 0) = 0 THEN 1 ELSE 0 END
					ELSE
						CASE 
							WHEN 
								(SELECT COUNT(*)
								FROM vEmplServReseption as vEmSerRecep	
								WHERE x_Dept_Employee.deptCode = vEmSerRecep.deptCode
								AND x_Dept_Employee.employeeID = vEmSerRecep.employeeID
								AND x_Dept_Employee.ReceiveGuests <> vEmSerRecep.ReceiveGuests) = 0				
							THEN
								CASE WHEN ISNULL(x_Dept_Employee.ReceiveGuests, 0) = 0 THEN 0 ELSE 1 END						
								ELSE 2
								END
					END 				
			 ELSE ISNULL(x_Dept_Employee.ReceiveGuests, 0) END 
					
	 ELSE -1 END as ReceiveGuests,
'HasReception' = CASE IsNull((SELECT count(receptionID)
					FROM deptEmployeeReception der
					WHERE der.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID					
					AND @DateNow between ISNULL(validFrom,'1900-01-01') 
						and ISNULL(validTo,'2079-01-01'))
					, 0)
				WHEN 0 THEN 0 ELSE 1 END,
			
'HasRemarks' = CASE WHEN EXISTS (
						SELECT * 
						FROM View_DeptEmployee_EmployeeRemarks as v_DE_ER
						where v_DE_ER.EmployeeID =  x_Dept_Employee.EmployeeID
						and v_DE_ER.DeptCode = x_Dept_Employee.deptCode
						AND (@DateNow between ISNULL(v_DE_ER.validFrom,'1900-01-01') AND ISNULL(v_DE_ER.validTo,'2079-01-01'))
					) THEN 1
                    WHEN EXISTS (
						SELECT *
						FROM view_DeptEmployeeServiceRemarks desr
						INNER JOIN x_Dept_Employee_Service xdes ON desr.x_dept_employee_serviceID = xdes.x_Dept_Employee_ServiceID
						WHERE xdes.DeptEmployeeID = x_Dept_Employee.DeptEmployeeID
						AND (@DateNow between ISNULL(validFrom,'1900-01-01') AND ISNULL(validTo,'2079-01-01'))
                    ) THEN 1
                    WHEN EXISTS (
						SELECT * 
						from View_DeptRemarks
						JOIN DIC_GeneralRemarks GR ON View_DeptRemarks.DicRemarkID = GR.remarkID
						WHERE View_DeptRemarks.deptCode = x_Dept_Employee.deptCode
						--AND GR.RemarkCategoryID = 4
						AND (@DateNow between ISNULL(ValidFrom,'1900-01-01') and ISNULL(ValidTo,'2079-01-01'))
                    ) THEN 1
					WHEN EXISTS ( -- This is NEW 17
						SELECT * 
						FROM deptEmployeeReception der
						JOIN deptEmployeeReceptionServices ders ON der.receptionID = ders.receptionID 
						JOIN DeptEmployeeReceptionRemarks derr ON derr.EmployeeReceptionID = der.receptionID
						WHERE der.DeptEmployeeID = x_dept_employee.DeptEmployeeID  
						AND (@DateNow between ISNULL(der.ValidFrom,'1900-01-01') and ISNULL(der.ValidTo,'2079-01-01'))
					) THEN 1

                ELSE 0 END,
				
x_dept_XY.xcoord,
x_dept_XY.ycoord,
'DeptHandicappedFacilities' = 
	 stuff((SELECT ',' + CAST(DeptHandicappedFacilities.FacilityCode as varchar(2))
		FROM DeptHandicappedFacilities 
		WHERE DeptHandicappedFacilities.DeptCode = dept.deptCode
		for xml path('')
	),1,1,'')
INTO #EmployeeInClinic_preselected
FROM Employee
INNER JOIN DIC_EmployeeDegree ON Employee.degreeCode = DIC_EmployeeDegree.DegreeCode
LEFT JOIN x_Dept_Employee ON Employee.employeeID = x_Dept_Employee.employeeID
LEFT JOIN DIC_AgreementTypes ON x_Dept_Employee.AgreementType = DIC_AgreementTypes.AgreementTypeID
LEFT JOIN DIC_QueueOrder dic ON x_dept_employee.QueueOrder = dic.QueueOrder AND PermitOrderMethods = 0
LEFT JOIN dept ON x_Dept_Employee.deptCode = dept.deptCode
LEFT JOIN x_dept_XY ON dept.deptCode = x_dept_XY.deptCode
LEFT JOIN Cities ON dept.cityCode = Cities.cityCode
WHERE (@LocDeptCode is NULL OR x_Dept_Employee.deptCode = @LocDeptCode)
AND (@LocEmployeeID is NULL OR Employee.EmployeeID = @LocEmployeeID)
AND (@LocDeptEmployeeID is NULL OR x_Dept_Employee.DeptEmployeeID = @LocDeptEmployeeID)

	--PRINT (CONVERT( VARCHAR(24), GETDATE(), 121))

BEGIN TRY
	BEGIN TRANSACTION
	
	IF (@EmployeeID is null)
	BEGIN
		UPDATE Employee
		SET IsInMushlam = 1, IsInHospitals = 1
		WHERE Employee.IsMedicalTeam = 1 	
	END
	
	DELETE FROM EmployeeInClinic_preselected
	WHERE (@LocDeptCode is NULL OR EmployeeInClinic_preselected.deptCode = @LocDeptCode)
	AND (@LocEmployeeID is NULL OR EmployeeInClinic_preselected.EmployeeID = @LocEmployeeID)
	AND (@LocDeptEmployeeID is NULL OR EmployeeInClinic_preselected.DeptEmployeeID = @LocDeptEmployeeID)	

	INSERT INTO dbo.EmployeeInClinic_preselected
	(
		employeeID ,
		EmployeeSectorCode,
		licenseNumber,
		sex,
		lastName , 
		firstName ,
		EmployeeName ,
		deptName ,
		deptCode ,
		DeptEmployeeID ,
		QueueOrderDescription ,
		[address] ,
		cityName ,
		cityCode ,
		phone ,
		fax ,
		IsExpert ,
		ExpProfession ,
		professions_ASC ,
		professions_DESC ,
		[services] ,
		positions ,
		AgreementType ,
		AgreementTypeDescription ,
		EmployeeLanguage ,
		EmployeeLanguageDescription,
		hasMapCoordinates ,
		EmployeeStatus ,
		EmployeeStatusInDept ,
		IsMedicalTeam ,
		IsVirtualDoctor ,
		IsInCommunity ,
		IsInHospitals ,
		IsInMushlam ,
		ReceiveGuests ,
		HasReception ,
		HasRemarks ,	
		xcoord ,
		ycoord,
		DeptHandicappedFacilities 
	)	
	SELECT * 
	FROM #EmployeeInClinic_preselected
	
	COMMIT TRANSACTION 

END TRY

BEGIN CATCH
 IF @@TRANCOUNT > 0
  BEGIN
    ROLLBACK TRANSACTION
  END
END CATCH
	--PRINT (CONVERT( VARCHAR(24), GETDATE(), 121))
END

GO

/* rpc_getEmployeeReceptionAndRemarks  
NEW: view_DeptEmployeeServiceRemarks instead of DeptEmployeeServiceRemarks */
ALTER Procedure [dbo].[rpc_getEmployeeReceptionAndRemarks]
(
	@DeptEmployeeID int,
	@ServiceCode varchar(100),
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
	,GenRem.RemarkCategoryID
from View_DeptEmployee_EmployeeRemarks as v_DE_ER
	JOIN DIC_GeneralRemarks GenRem ON v_DE_ER.DicRemarkID = GenRem.remarkID
	where v_DE_ER.DeptEmployeeID = @DeptEmployeeID
	AND (v_DE_ER.ValidFrom is null OR DATEDIFF(dd, v_DE_ER.ValidFrom ,@ExpirationDate) >= 0)
	AND (v_DE_ER.ValidTo is null OR DATEDIFF(dd, v_DE_ER.ValidTo ,@ExpirationDate) <= 0)

UNION

SELECT
dbo.rfn_GetFotmatedRemark(desr.RemarkText), displayInInternet
,ServiceDescription + ': &nbsp;' as ServiceName 
,GenRem.RemarkCategoryID
FROM view_DeptEmployeeServiceRemarks desr
JOIN DIC_GeneralRemarks GenRem ON desr.RemarkID = GenRem.remarkID
INNER JOIN x_Dept_Employee_Service xdes ON desr.x_dept_employee_serviceID = xdes.x_dept_employee_serviceID
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
INNER JOIN [Services] ON xdes.ServiceCode = [Services].ServiceCode AND xdes.Status = 1
WHERE xd.DeptEmployeeID = @DeptEmployeeID
AND (@ServiceCode = '' OR xdes.ServiceCode IN (SELECT IntField FROM dbo.SplitString(@ServiceCode))) 
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

WHERE x_Dept_Employee.DeptEmployeeID = @DeptEmployeeID


-- get the closest new reception within 14 days for each profession or service
SELECT MIN(ValidFrom) as ChangeDate , s.serviceCode AS ServiceOrProfessionCode, s.ServiceDescription as professionOrServiceDescription
FROM deptEmployeeReception der
INNER JOIN deptEmployeeReceptionServices  ders on der.receptionID = ders.receptionID
INNER JOIN x_Dept_Employee xd ON der.DeptEmployeeID = xd.DeptEmployeeID
INNER JOIN [Services] s ON dERS.serviceCode = s.serviceCode
WHERE xd.DeptEmployeeID = @DeptEmployeeID
AND DATEDIFF(dd, ValidFrom, @ExpirationDate) < 0 
AND DATEDIFF(dd, ValidFrom, @ExpirationDate) >= -14
AND (@ServiceCode = '' OR ders.ServiceCode IN (SELECT IntField FROM dbo.SplitString(@ServiceCode))) 
GROUP BY s.serviceCode, s.serviceDescription



--------  "doctorReception" (Doctor's Hours in Clinic) -------------------

SELECT
dER.receptionID,
xd.EmployeeID,
xd.deptCode,
xd.DeptEmployeeID,
IsNull(dERS.serviceCode, 0) as professionOrServiceCode,
IsNull(serviceDescription, 'NoData') as professionOrServiceDescription,
DER.validFrom,
DER.validTo,
'expirationDate' = DER.validTo,
'willExpireIn' = DATEDIFF(day, @ExpirationDate, IsNull(validTo,'01/01/2050')),
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
						 WHERE xd.DeptEmployeeID = @DeptEmployeeID 
						 AND ders2.serviceCode = ders.serviceCode
						),
CASE WHEN (dERS.serviceCode = 2 OR dERS.serviceCode = 40) 
	 THEN der.ReceiveGuests
	 ELSE 0
	 END AS ReceiveGuests
FROM deptEmployeeReception as der
INNER JOIN deptEmployeeReceptionServices as dERS ON der.receptionID = dERS.receptionID
INNER JOIN [Services] ON dERS.serviceCode = [Services].serviceCode
INNER JOIN x_dept_employee_service xdes ON der.DeptEmployeeID = xdes.DeptEmployeeID AND [Services].serviceCode = xdes.serviceCode AND xdes.Status = 1
INNER JOIN x_dept_employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID
INNER JOIN vReceptionDaysForDisplay on dER.receptionDay = vReceptionDaysForDisplay.ReceptionDayCode
WHERE xd.DeptEmployeeID = @DeptEmployeeID
AND (@ServiceCode = '' OR xdes.ServiceCode IN (SELECT IntField FROM dbo.SplitString(@ServiceCode))) 
AND (
	(validFrom is null OR DATEDIFF(dd, ValidFrom, @ExpirationDate) >= 0 )
	and 
	(validTo is null OR DATEDIFF(dd, ValidTo, @ExpirationDate) <= 0 ) 
	)

ORDER BY EmployeeID, receptionDay, openingHour

------ DeptEmployeePhones
SELECT
employeeID,
phoneOrder,
xd.DeptEmployeeID,
'phone' = dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension),
phoneType,
phoneTypeName,
'shortPhoneTypeName' = CASE phoneType WHEN 2 THEN 'פקס' ELSE 'טל`' END

FROM DeptEmployeePhones dep
INNER JOIN x_Dept_Employee xd ON dep.DeptEmployeeID = xd.DeptEmployeeID
INNER JOIN DIC_PhoneTypes ON dep.phoneType = DIC_PhoneTypes.phoneTypeCode
WHERE xd.DeptEmployeeID = @DeptEmployeeID

--------- Remarks for Changes in clinic activity-------------------------
SELECT 
View_DeptRemarks.remarkID
, dbo.rfn_GetFotmatedRemark(RemarkText) as RemarkText
, validFrom
, validTo
, displayInInternet
, RemarkDeptCode as deptCode
, View_DeptRemarks.IsSharedRemark -- as 'sweeping' 
, ShowOrder
, RemarkCategoryID

FROM View_DeptRemarks
JOIN DIC_GeneralRemarks ON View_DeptRemarks.DicRemarkID = DIC_GeneralRemarks.remarkID
JOIN x_Dept_Employee xde ON View_DeptRemarks.deptCode = xde.deptCode
WHERE DIC_GeneralRemarks.linkedToReceptionHours = 0
--AND DIC_GeneralRemarks.RemarkCategoryID = 4
--and DIC_GeneralRemarks.linkedToServiceInClinic = 0
and xde.DeptEmployeeID = @DeptEmployeeID
AND DATEDIFF(dd, validFrom , @ExpirationDate) >= 0
AND ( validTo is null OR DATEDIFF(dd, validTo , @ExpirationDate) <= 0 ) 
ORDER BY IsSharedRemark desc ,ShowOrder asc 


GO
/* rpc_GetDeptReceptionAndRemarks  
NEW: view_DeptEmployeeServiceRemarks instead of DeptEmployeeServiceRemarks */
ALTER Procedure [dbo].[rpc_GetDeptReceptionAndRemarks]
(
	@DeptCode int,
	@ExpirationDate datetime,
	@ServiceCodes varchar(100),
	@RemarkCategoriesForAbsence varchar(50),
	@RemarkCategoriesForClinicActivity varchar(50)
)
as

SELECT ItemID as RemarkCategoryID 
INTO #RemarkCategoriesForAbsence
FROM [dbo].[rfn_SplitStringValues](@RemarkCategoriesForAbsence)

SELECT ItemID as RemarkCategoryID 
INTO #RemarkCategoriesForClinicActivity
FROM [dbo].[rfn_SplitStringValues](@RemarkCategoriesForClinicActivity)

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
SELECT View_DeptRemarks.remarkID
, dbo.rfn_GetFotmatedRemark(RemarkText) as RemarkText
, validFrom
, validTo
, displayInInternet
, RemarkDeptCode as deptCode
, View_DeptRemarks.IsSharedRemark -- as 'sweeping' 
,GenRem.RemarkCategoryID
FROM View_DeptRemarks
JOIN DIC_GeneralRemarks GenRem ON View_DeptRemarks.DicRemarkID = GenRem.remarkID
LEFT JOIN #RemarkCategoriesForClinicActivity REMACT ON GenRem.RemarkCategoryID = REMACT.RemarkCategoryID
WHERE deptCode = @deptCode
--AND validFrom < @DateAfterExpiration AND ( validTo is null OR validTo >= @ExpirationDate )
AND DATEDIFF(dd, validFrom , @ExpirationDate) >= 0
AND ( validTo is null OR DATEDIFF(dd, validTo , @ExpirationDate) <= 0 ) 
ORDER BY REMACT.RemarkCategoryID DESC, IsSharedRemark DESC, validFrom, View_DeptRemarks.updateDate

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

------ Employee remarks -------------------------------------------------------------

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
LEFT JOIN #RemarkCategoriesForAbsence CATABS ON GenRem.RemarkCategoryID = CATABS.RemarkCategoryID
WHERE v_DE_ER.DeptCode = @DeptCode

AND Employee.EmployeeSectorCode = 7
AND (v_DE_ER.ValidFrom is null OR DATEDIFF(dd, v_DE_ER.ValidFrom ,@ExpirationDate) >= 0)
AND (v_DE_ER.ValidTo is null OR DATEDIFF(dd, v_DE_ER.ValidTo ,@ExpirationDate) <= 0)	

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
INNER JOIN x_Dept_Employee xd ON xdes.DeptEmployeeID = xd.DeptEmployeeID AND xd.active = 1
INNER JOIN [Services] ON xdes.ServiceCode = [Services].ServiceCode AND xdes.Status = 1
JOIN Employee ON xd.EmployeeID = Employee.employeeID
JOIN DIC_EmployeeDegree ON Employee.degreeCode = DIC_EmployeeDegree.DegreeCode
LEFT JOIN #RemarkCategoriesForAbsence CATABS ON GenRem.RemarkCategoryID = CATABS.RemarkCategoryID
WHERE xd.DeptCode = @DeptCode

AND (@ServiceCodes is null OR xdes.ServiceCode IN (SELECT IntField FROM dbo.SplitString(@ServiceCodes))) 
AND (ValidFrom is NULL OR DATEDIFF(dd, ValidFrom ,@ExpirationDate) >= 0 )
AND (ValidTo is NULL OR  DATEDIFF(dd, ValidTo ,@ExpirationDate) <= 0 )


SELECT DISTINCT employeeID, AbsenceRemark as HasAbsenceRemark
INTO #Absence
FROM #Remarks
WHERE AbsenceRemark = 1

SELECT *
FROM #Remarks
LEFT JOIN #Absence ON #Remarks.employeeID = #Absence.employeeID
ORDER BY #Absence.HasAbsenceRemark DESC,#Remarks.IsMedicalTeam, #Remarks.lastName, #Remarks.AbsenceRemark DESC
	,#Remarks.ValidFrom, #Remarks.updateDate

GO

/* rpc_getDIC_GeneralRemarks  
NEW: add fields Factor , OpenNow , ShowForPreviousDays */
ALTER Procedure [dbo].[rpc_getDIC_GeneralRemarks]
	
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
	,Factor
	,OpenNow
	,ShowForPreviousDays

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
