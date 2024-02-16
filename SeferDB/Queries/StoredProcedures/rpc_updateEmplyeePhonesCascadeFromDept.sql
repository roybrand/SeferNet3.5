IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateEmplyeePhonesCascadeFromDept')
	BEGIN
		DROP  Procedure  rpc_updateEmplyeePhonesCascadeFromDept
	END

GO

CREATE PROCEDURE dbo.rpc_updateEmplyeePhonesCascadeFromDept
	(
		@DeptCode int,
		@EmployeeID int,
		@CascadeUpdateDeptEmployeePhonesFromClinic int,
		@UpdateUser varchar(50),
		@ErrorCode int OUTPUT
	)

AS

SET @ErrorCode = 0
DECLARE @deptEmployeeID INT


	IF @CascadeUpdateDeptEmployeePhonesFromClinic = 0 -- DO NOT update
		BEGIN
			UPDATE x_dept_employee
			SET CascadeUpdateDeptEmployeePhonesFromClinic = @CascadeUpdateDeptEmployeePhonesFromClinic
			WHERE deptCode = @DeptCode
			AND employeeID = @EmployeeID
		END

	IF @CascadeUpdateDeptEmployeePhonesFromClinic = 1 -- Update
		BEGIN
			UPDATE x_dept_employee
			SET CascadeUpdateDeptEmployeePhonesFromClinic = @CascadeUpdateDeptEmployeePhonesFromClinic
			WHERE deptCode = @DeptCode
			AND employeeID = @EmployeeID
			
			SET @deptEmployeeID =  (SELECT DeptEmployeeID
									FROM x_Dept_Employee
									WHERE deptCode = @DeptCode
									AND employeeID = @EmployeeID)
			
			DELETE FROM DeptEmployeePhones
			WHERE DeptEmployeeID = @deptEmployeeID			

			INSERT INTO DeptEmployeePhones
				(phoneType, phoneOrder, prePrefix, prefix, phone, updateUser, updateDate, DeptEmployeeID)
				
			SELECT phoneType, phoneOrder, prePrefix, prefix, phone, @UpdateUser, getdate(), @deptEmployeeID
			FROM DeptPhones
			WHERE DeptPhones.deptCode = @deptCode
			
		END
		
	SET @ErrorCode = @@Error

GO

GRANT EXEC ON rpc_updateEmplyeePhonesCascadeFromDept TO PUBLIC

GO

