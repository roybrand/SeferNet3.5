IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateDoctorsInClinic')
	BEGIN
		DROP  Procedure  rpc_updateDoctorsInClinic
	END

GO

CREATE Procedure dbo.rpc_updateDoctorsInClinic
	(
		@deptCode int,
		@employeeID int,
		@agreementTypeOld int,
		@agreementTypeNew int,
		@receiveGuests bit,
		@updateUserName varchar(50),
		@showPhonesFromDept bit,
		@ErrorStatus int output
	)

AS
DECLARE @Err int, @Count int
SET @Err = 0
SET @Count = 0
SET @ErrorStatus = 0

		UPDATE x_Dept_Employee
		SET 
		updateUserName = @updateUserName,
		CascadeUpdateDeptEmployeePhonesFromClinic = @showPhonesFromDept,
		AgreementType = @agreementTypeNew,
		ReceiveGuests = @receiveGuests,
		updateDate = getdate()
		WHERE deptCode = @deptCode
		AND employeeID = @employeeID
		AND AgreementType = @agreementTypeOld

		
	IF @showPhonesFromDept = 1 
	BEGIN
		DELETE FROM DeptEmployeePhones 
		FROM DeptEmployeePhones dep
		INNER JOIN x_Dept_Employee xd ON dep.DeptEmployeeID = xd.DeptEmployeeID		
		WHERE deptCode = @DeptCode 
		AND employeeID = @employeeID
	END
				
		SET @ErrorStatus = @@Error

GO


GRANT EXEC ON dbo.rpc_updateDoctorsInClinic TO PUBLIC

GO


