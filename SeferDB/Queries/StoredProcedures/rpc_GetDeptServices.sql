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

GRANT EXEC ON rpc_GetDeptServices TO [clalit\webuser]
GO

GRANT EXEC ON rpc_GetDeptServices TO [clalit\IntranetDev]
GO
