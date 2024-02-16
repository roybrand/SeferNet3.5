IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_Update_x_Dept_Employee_PhonesInClinic')
	BEGIN
		DROP  Procedure  rpc_Update_x_Dept_Employee_PhonesInClinic
	END

GO

CREATE Procedure dbo.rpc_Update_x_Dept_Employee_PhonesInClinic
	(
		@DeptCode int,
		@ErrorCode int OUTPUT
	)

AS

	UPDATE x_Dept_Employee
	SET CascadeUpdateDeptEmployeePhonesFromClinic = 1
	WHERE deptCode = @DeptCode

	SET @ErrorCode = @@Error
	
GO

GRANT EXEC ON rpc_Update_x_Dept_Employee_PhonesInClinic TO PUBLIC

GO

