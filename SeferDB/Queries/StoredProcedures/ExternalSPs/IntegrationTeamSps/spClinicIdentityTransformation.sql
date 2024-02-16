alter  procedure spClinicIdentityTransformation
	@clinicCode int,
	@oldClinicCode int,
	@clinicName varchar(50),
	@doctorId bigint = 0,
	@doctorLicenseNo int = 0
AS
BEGIN
	/*Normalize input parameters*/
	IF @clinicCode IS NULL		SET @clinicCode = 0
	IF @oldClinicCode IS NULL	SET @oldClinicCode = 0
	IF @clinicName IS NULL		SET @clinicName = ''
	IF @doctorId IS NULL		SET @doctorId = 0
	IF @doctorLicenseNo IS NULL	SET @doctorLicenseNo = 0

	--Retrieve ClinicCodes
	CREATE TABLE #tblClinicCodes  (ClinicCode int)


	IF (@clinicCode <> 0)
	BEGIN
		IF  EXISTS(   SELECT 1  FROM vWS_Dept as Dept
							WHERE Dept.deptCode = @clinicCode)
		BEGIN
			INSERT INTO #tblClinicCodes(ClinicCode)
			SELECT @clinicCode
		END
	END
	ELSE IF (@oldClinicCode <> 0)
	BEGIN
		IF (@clinicName <> '')
		BEGIN
			INSERT INTO #tblClinicCodes(ClinicCode)
			SELECT distinct deptSimul.deptCode
			FROM dbo.vWS_deptSimul as deptSimul
			WHERE (deptSimul.Simul228 = @oldClinicCode)
				AND EXISTS
				(SELECT * FROM  dbo.vWS_Dept Dept
					WHERE deptSimul.deptCode = Dept.deptCode
     				and  Dept.deptName LIKE '%' + @clinicName + '%'
				)
		END
		ELSE
		BEGIN
			INSERT INTO #tblClinicCodes(ClinicCode)
			SELECT distinct deptSimul.deptCode
			FROM dbo.vWS_deptSimul as deptSimul
  			WHERE (deptSimul.Simul228 = @oldClinicCode)
				AND EXISTS
				(SELECT * FROM  dbo.vWS_Dept Dept
					WHERE deptSimul.deptCode = Dept.deptCode
				)
		END
	END
	ELSE IF (@clinicName <> '')
	BEGIN
		INSERT INTO #tblClinicCodes(ClinicCode)
		SELECT distinct deptCode FROM dbo.vWS_Dept Dept
		WHERE  (Dept.deptName LIKE '%' + @clinicName + '%')		            
	END       
	

	-- Get doctor data
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

	IF @doctorPhysicianID <> 0 
		begin
			select c.* 
			from #tblClinicCodes c
			join x_Dept_Employee xde on c.ClinicCode = xde.deptCode and xde.employeeID = @doctorPhysicianID
			where xde.active = 1
		end
	ELSE
		begin
			select * from #tblClinicCodes -- convert to tbl_UniqueIntArray
		end

	drop table #tblClinicCodes
--	select 43300 as ClinicCode
END
go
