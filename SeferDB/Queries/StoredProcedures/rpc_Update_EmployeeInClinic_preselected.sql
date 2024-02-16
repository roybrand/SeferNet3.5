IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_Update_EmployeeInClinic_preselected')
	BEGIN
		DROP  Procedure  dbo.rpc_Update_EmployeeInClinic_preselected
	END
GO

CREATE Procedure [dbo].[rpc_Update_EmployeeInClinic_preselected]
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

GRANT EXEC ON dbo.rpc_Update_EmployeeInClinic_preselected TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_Update_EmployeeInClinic_preselected TO [clalit\IntranetDev]
GO 