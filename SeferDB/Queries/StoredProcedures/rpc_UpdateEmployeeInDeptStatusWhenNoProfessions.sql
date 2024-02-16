IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateEmployeeInDeptStatusWhenNoProfessions')
	BEGIN
		DROP  Procedure  rpc_UpdateEmployeeInDeptStatusWhenNoProfessions
	END

GO

CREATE Procedure [dbo].[rpc_UpdateEmployeeInDeptStatusWhenNoProfessions]
(		
	@employeeID bigint,	
	@deptCode int,		
	@updateUser VARCHAR(50)
)

AS
BEGIN
SET XACT_ABORT on

DECLARE @DateNow date = GETDATE()

DECLARE @LocEmployeeID bigint
SET @LocEmployeeID = @EmployeeID
DECLARE @LocDeptCode int
SET @LocDeptCode = @DeptCode

DELETE FROM EmployeeInClinic_preselected
WHERE (@LocDeptCode is NULL OR EmployeeInClinic_preselected.deptCode = @LocDeptCode)
AND (@LocEmployeeID is NULL OR EmployeeInClinic_preselected.EmployeeID = @LocEmployeeID)

SELECT  
Employee.employeeID, 
Employee.EmployeeSectorCode,
CASE WHEN (Employee.EmployeeSectorCode = 7) THEN Employee.licenseNumber ELSE Employee.ProfessionalLicenseNumber END
	as licenseNumber,
Employee.sex,
Employee.lastName, 
Employee.firstName,
DegreeName, deptName, dept.deptCode, DeptEmployeeID, QueueOrderDescription, cityName, Cities.cityCode,
CascadeUpdateDeptEmployeePhonesFromClinic, IsVirtualDoctor, AgreementType, AgreementTypeDescription,
xcoord, ycoord, Employee.active, IsMedicalTeam, IsInCommunity, IsInHospitals, IsInMushlam, ReceiveGuests

INTO #tmp
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
--OPTION(RECOMPILE)



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
SELECT DISTINCT employeeID, EmployeeSectorCode, licenseNumber, sex, lastName, firstName,
'EmployeeName' = DegreeName + ' ' + z.lastName + ' ' + z.firstName,
'deptName' = IsNull(z.deptName, ''),
'deptCode' = IsNull(z.deptCode, ''),
ISNULL(z.DeptEmployeeID, 0) as DeptEmployeeID,
z.QueueOrderDescription,
'address' = dbo.GetAddress(z.deptCode),
'cityName' = IsNull(z.cityName, ''),
'cityCode' = IsNull(z.cityCode, 0),
'phone' = IsNULL(	(SELECT dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) 
					FROM DeptEmployeePhones 
					WHERE DeptEmployeeID = z.DeptEmployeeID					
					AND phoneType = 1
					AND phoneOrder = 1), 
			
					(SELECT dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension)
					FROM DeptPhones
					WHERE deptCode = z.deptCode
					AND phoneType = 1
					AND phoneOrder = 1
					AND z.CascadeUpdateDeptEmployeePhonesFromClinic = 1)
				),
'fax' = IsNULL(	(SELECT dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension) 
					FROM DeptEmployeePhones 
					WHERE deptEmployeeID = z.DeptEmployeeID 					
					AND phoneType = 2
					AND phoneOrder = 1), 
			
					(SELECT dbo.fun_ParsePhoneNumberWithExtension(prePrefix, prefix, phone, extension)
					FROM DeptPhones
					WHERE deptCode = z.deptCode
					AND phoneType = 2
					AND phoneOrder = 1
					AND z.CascadeUpdateDeptEmployeePhonesFromClinic = 1)
				),
'IsExpert' = CASE WHEN 
						exists  (
								SELECT EmployeeID
								FROM EmployeeServices 
								WHERE ExpProfession = 1 
								and EmployeeServices.EmployeeID = z.employeeID
								)
					THEN 1 ELSE 0 END,
'expert' = CASE(z.IsVirtualDoctor) WHEN 1 THEN '' ELSE dbo.fun_GetEmployeeExpert(z.employeeID) END,
'professions_ASC' =
	CASE WHEN EXISTS (	SELECT * FROM x_Dept_Employee_Service 
						WHERE x_Dept_Employee_Service.serviceCode = 180300
						AND x_Dept_Employee_Service.DeptEmployeeID = z.DeptEmployeeID	) 				  
		 THEN ' התייעצות עם רופא מומחה למתן חו"ד שנייה בנושא: ' + ',' ELSE '' END
		+ ISNULL( 
			stuff((
				SELECT ','+ [Services].serviceDescription 
				FROM [Services]
				inner join x_Dept_Employee_Service xdes
				ON xdes.serviceCode = [Services].serviceCode
				and xdes.DeptEmployeeID = z.DeptEmployeeID
				WHERE xdes.Status = 1
				AND [Services].IsService = 0
				ORDER BY [Services].serviceDescription 
				for xml path('')
			),1,1,''),
		''),
'professions_DESC' =
	CASE WHEN EXISTS (	SELECT * FROM x_Dept_Employee_Service 
						WHERE x_Dept_Employee_Service.serviceCode = 180300
						AND x_Dept_Employee_Service.DeptEmployeeID = z.DeptEmployeeID	) 				  
		 THEN ' התייעצות עם רופא מומחה למתן חו"ד שנייה בנושא: ' + ',' ELSE '' END
		+ ISNULL( 
			stuff((
				SELECT ','+ [Services].serviceDescription 
				FROM [Services]
				inner join x_Dept_Employee_Service xdes
				ON xdes.serviceCode = [Services].serviceCode
				and xdes.DeptEmployeeID = z.DeptEmployeeID
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
					and xdes.DeptEmployeeID = z.DeptEmployeeID
					WHERE xdes.Status = 1
					AND [Services].IsService = 1
					AND [Services].ServiceCode <> 180300
					ORDER BY [Services].serviceDescription 
					for xml path('')
				),1,1,''),
'positions'	= stuff((SELECT ',' + position.positionDescription
		FROM position 
		INNER JOIN x_Dept_Employee_Position ON x_Dept_Employee_Position.positionCode = position.positionCode
		WHERE x_Dept_Employee_Position.DeptEmployeeID = z.DeptEmployeeID
		AND position.gender = z.sex
		for xml path('')
	),1,1,''),
'AgreementType' = IsNull(z.agreementType, 0),
IsNull(z.AgreementTypeDescription, '') as AgreementTypeDescription,
'EmployeeLanguage'	= stuff((SELECT ',' + CAST(languages.languageCode as varchar(4))
		FROM EmployeeLanguages
		JOIN languages ON EmployeeLanguages.languageCode = languages.languageCode
		WHERE EmployeeLanguages.EmployeeID = z.employeeID
		for xml path('')
	),1,1,''),
'EmployeeLanguageDescription'	= stuff((SELECT ',' + CAST(languages.languageDescription as varchar(50))
		FROM EmployeeLanguages
		JOIN languages ON EmployeeLanguages.languageCode = languages.languageCode
		WHERE EmployeeLanguages.EmployeeID = z.employeeID
		for xml path('')
	),1,1,''),		
'hasMapCoordinates' = CASE IsNull((z.xcoord + z.ycoord),0) WHEN 0 THEN 0 ELSE 1 END,
'EmployeeStatus' = z.active,
'EmployeeStatusInDept' = IsNull(dbo.fun_GetDeptEmployeeCurrentStatus(z.deptCode, z.employeeID,z.AgreementType), 0),
z.IsMedicalTeam,
z.IsVirtualDoctor,
	
CASE WHEN z.AgreementType is null THEN z.IsInCommunity
	ELSE CASE WHEN z.AgreementType in (1,2,6) THEN 1 ELSE 0 END 
	END as IsInCommunity,
CASE WHEN z.AgreementType is null THEN z.IsInHospitals
	ELSE CASE WHEN z.AgreementType in (5) THEN 1 ELSE 0 END 
	END as IsInHospitals,
CASE WHEN z.AgreementType is null THEN z.IsInMushlam
	ELSE CASE WHEN z.AgreementType in (3,4) THEN 1 ELSE 0 END 
	END as IsInMushlam,		

CASE WHEN (SELECT COUNT(*) 
			FROM x_Dept_Employee_Service 
			WHERE x_Dept_Employee_Service.DeptEmployeeID = z.DeptEmployeeID
			AND x_Dept_Employee_Service.serviceCode in (2,40)) > 0 
	 THEN ISNULL(z.ReceiveGuests, 1) 
	 ELSE 1 END as ReceiveGuests,
'HasReception' = CASE IsNull((SELECT count(receptionID)
					FROM deptEmployeeReception der
					WHERE der.DeptEmployeeID = z.DeptEmployeeID					
					AND @DateNow between ISNULL(validFrom,'1900-01-01') 
						and ISNULL(validTo,'2079-01-01'))
					, 0)
				WHEN 0 THEN 0 ELSE 1 END,
'HasRemarks' = CASE IsNull(
				(SELECT COUNT(DeptCode) 
				from View_DeptEmployee_EmployeeRemarks as v_DE_ER
					where v_DE_ER.EmployeeID =  z.EmployeeID
					and v_DE_ER.DeptCode = z.deptCode
					AND @DateNow between ISNULL(v_DE_ER.validFrom,'1900-01-01') 
						and ISNULL(v_DE_ER.validTo,'2079-01-01')
				)
				+
				(SELECT COUNT(desr.DeptEmployeeServiceRemarkID)
				 FROM DeptEmployeeServiceRemarks desr
				 INNER JOIN x_Dept_Employee_Service xdes ON desr.x_dept_employee_serviceID = xdes.x_Dept_Employee_ServiceID
				 WHERE xdes.DeptEmployeeID = z.DeptEmployeeID
					AND @DateNow between ISNULL(validFrom,'1900-01-01') 
						and ISNULL(validTo,'2079-01-01')
				), 0)
				
				WHEN 0 THEN 0 ELSE 1 END,
z.xcoord,
z.ycoord,
'DeptHandicappedFacilities' = 
	 stuff((SELECT ',' + CAST(DeptHandicappedFacilities.FacilityCode as varchar(2))
		FROM DeptHandicappedFacilities 
		WHERE DeptHandicappedFacilities.DeptCode = z.deptCode
		for xml path('')
	),1,1,'')


 
FROM #tmp z

END

GO

GRANT EXEC ON rpc_UpdateEmployeeInDeptStatusWhenNoProfessions TO [clalit\webuser]
GO

GRANT EXEC ON rpc_UpdateEmployeeInDeptStatusWhenNoProfessions TO [clalit\IntranetDev]
GO

