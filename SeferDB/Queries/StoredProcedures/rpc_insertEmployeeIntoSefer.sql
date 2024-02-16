IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertEmployeeIntoSefer')
	BEGIN
		DROP  Procedure  rpc_insertEmployeeIntoSefer
	END

GO

CREATE Procedure [dbo].[rpc_insertEmployeeIntoSefer]
	(
		@employeeID bigint,
		
		@lastName varchar(50),
		@firstName varchar(50),
		@EmployeeSectorCode int,
		@primaryDistrict int,
		@IsVirtualDoctor bit,
		
		@updateUser varchar(50),
		@Gender tinyint,
		@profLicence int,
		@IsDental bit,
		@NewEmployeeID bigint=0 OUTPUT,
		@ErrCode int OUTPUT
		
	)

AS

DECLARE @active int
DECLARE @PersonID_TR226 int 
DECLARE @IDControlDigit_TR226 int
DECLARE @degreeCode int
DECLARE @isDoctor int
DECLARE @VirtualEmployeeIDFroInsert bigint

SET XACT_ABORT on

BEGIN TRY
	Begin tran
	
	SET @ErrCode = 0
	SET @isDoctor = (SELECT TOP 1 IsDoctor FROM EmployeeSector WHERE EmployeeSectorCode = @EmployeeSectorCode)

	SET @degreeCode = 0

	SET @active = 1


	IF(@isDoctor = 1 AND @IsVirtualDoctor <> 1 AND @IsDental <> 1)
	BEGIN

		IF EXISTS 
			(SELECT * FROM Employee 
			WHERE employeeID = @employeeID
			AND IsInCommunity = 0)
		BEGIN
			UPDATE Employee
			SET IsInCommunity = 1
			WHERE employeeID = @employeeID

			SET @NewEmployeeID = 0
		END

		ELSE
		
		BEGIN

			SET @PersonID_TR226 = LEFT(@employeeID, LEN(@employeeID) - 1)

			print @PersonID_TR226

			INSERT INTO Employee
			(employeeID, licenseNumber, IsDental, lastName, firstName, lastName_MF, firstName_MF, primaryDistrict, degreeCode, EmployeeSectorCode, active, IsVirtualDoctor, updateUser,
			IsInCommunity, IsInHospitals, IsInMushlam, sex, ProfessionalLicenseNumber)
			SELECT
			@employeeID, 
			CASE WHEN DocLicenseNumber <> 0 THEN DocLicenseNumber
			WHEN DocLicenseNumber = 0 AND DentalLicenseNumber <> 0 THEN DentalLicenseNumber
			ELSE 0 END as licenseNumber,
			CASE WHEN DocLicenseNumber <> 0 THEN 0
			WHEN DocLicenseNumber = 0 AND DentalLicenseNumber <> 0 THEN 1
			ELSE 0 END as IsDental,
			FamilyName,FirstName,FamilyName,FirstName,@primaryDistrict,@degreeCode,@EmployeeSectorCode,@active,@IsVirtualDoctor,@updateUser,
			1 as IsInCommunity, 0 as IsInHospitals, 0 as IsInMushlam, Gender, 0
			FROM TR_DoctorsInfo226
			WHERE PersonID = @PersonID_TR226
		
			SET @NewEmployeeID = 0
		
			INSERT INTO EmployeeStatus 
			(EmployeeID, Status, UpdateUser, FromDate)
			SELECT
			@employeeID, @active, @updateUser, getdate()
			FROM TR_DoctorsInfo226
			WHERE PersonID = @PersonID_TR226

		END
		
	END	

	IF(@isDoctor = 1 AND @IsVirtualDoctor = 1)
	BEGIN

		SET @VirtualEmployeeIDFroInsert = (SELECT MAX(employeeID) FROM employee) + 1
		IF (@VirtualEmployeeIDFroInsert < 1000000000)
		BEGIN
			SET @VirtualEmployeeIDFroInsert = 1000000000
			print @VirtualEmployeeIDFroInsert
		END
		
		INSERT INTO Employee
		(employeeID, firstName, lastName, EmployeeSectorCode, primaryDistrict, degreeCode, active, IsVirtualDoctor, updateUser, sex)
		VALUES
		(@VirtualEmployeeIDFroInsert,@firstName,@lastName,@EmployeeSectorCode,@primaryDistrict,@degreeCode,@active,@IsVirtualDoctor,@updateUser,@Gender)
		
		SET @NewEmployeeID = @VirtualEmployeeIDFroInsert
		
		INSERT INTO EmployeeStatus 
		(EmployeeID, Status, UpdateUser, FromDate)
		VALUES
		(@VirtualEmployeeIDFroInsert, @active, @updateUser, getdate())
		
	END
		
	IF(@isDoctor = 0 AND @IsDental = 0)
	BEGIN 

		INSERT INTO Employee
		(employeeID, lastName, firstName, lastName_MF, firstName_MF, EmployeeSectorCode, primaryDistrict, degreeCode, active, IsVirtualDoctor, updateUser, sex, ProfessionalLicenseNumber, IsDental)
		VALUES
		(@employeeID, @lastName, @firstName, @lastName, @firstName, @EmployeeSectorCode, @primaryDistrict, @degreeCode, @active, @IsVirtualDoctor, @updateUser, @Gender, @profLicence, @IsDental)
		
		SET @ErrCode = @@ERROR
		SET @NewEmployeeID = 0

		INSERT INTO EmployeeStatus 
		(EmployeeID, Status, UpdateUser, FromDate)
		VALUES
		(@employeeID, @active, @updateUser, getdate())
		
		SET @ErrCode = @@ERROR

	END

	IF(@IsDental = 1)
	BEGIN 

		INSERT INTO Employee
		(employeeID, licenseNumber, lastName, firstName, lastName_MF, firstName_MF, EmployeeSectorCode, primaryDistrict, degreeCode, active, IsVirtualDoctor, updateUser, sex,  IsDental)
		VALUES
		(@employeeID, @profLicence, @lastName, @firstName, @lastName, @firstName, @EmployeeSectorCode, @primaryDistrict, @degreeCode, @active, @IsVirtualDoctor, @updateUser, @Gender, @IsDental)
		
		SET @ErrCode = @@ERROR
		SET @NewEmployeeID = 0

		INSERT INTO EmployeeStatus 
		(EmployeeID, Status, UpdateUser, FromDate)
		VALUES
		(@employeeID, @active, @updateUser, getdate())
		
		SET @ErrCode = @@ERROR

	END	
	 
	commit
END TRY 
BEGIN CATCH
	rollback
	Exec master.dbo.sp_RethrowError
END CATCH

GO


GRANT EXEC ON dbo.rpc_insertEmployeeIntoSefer TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_insertEmployeeIntoSefer TO [clalit\IntranetDev]
GO

