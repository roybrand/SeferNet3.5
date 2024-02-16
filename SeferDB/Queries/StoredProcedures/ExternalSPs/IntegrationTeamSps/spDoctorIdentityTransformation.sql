alter  procedure spDoctorIdentityTransformation
	@doctorId bigint,
	@doctorLicenseNo int
AS          
BEGIN          
	/*Normalize input parameters*/        
	IF @doctorId IS NULL			SET @doctorId = 0
	IF @doctorLicenseNo IS NULL		SET @doctorLicenseNo = 0

	--Retrieve EmployeeID            
	DECLARE @doctorPhysicianID  bigint = 0           

	IF (@doctorId <> 0)  
		BEGIN
				SELECT /*TOP 1*/ @doctorPhysicianID = Employee.employeeID
				FROM dbo.vWS_Employee as Employee
					WHERE Employee.employeeID = @doctorId
					AND	Employee.IsVirtualDoctor = 0
					AND	Employee.IsMedicalTeam = 0

		END      
	ELSE IF (@doctorLicenseNo <> 0)          
		BEGIN        
		SELECT /*TOP 1*/ @doctorPhysicianID = Employee.employeeID            
			FROM   dbo.vWS_Employee as Employee        
				WHERE [licenseNumber] = @doctorLicenseNo
				AND Employee.IsVirtualDoctor = 0
				AND Employee.IsMedicalTeam = 0       
			       
		END
	
	select @doctorPhysicianID

END
go