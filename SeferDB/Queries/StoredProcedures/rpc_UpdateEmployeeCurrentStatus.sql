IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateEmployeeCurrentStatus')
	BEGIN
		DROP  Procedure  rpc_UpdateEmployeeCurrentStatus
	END

GO

CREATE Procedure rpc_UpdateEmployeeCurrentStatus
(
	@employeeID BIGINT,
	@status		TINYINT,
	@updateUser VARCHAR(30)
)

AS

UPDATE Employee 
SET Active = @status, updateDate = GETDATE(),  UpdateUser = @updateUser
WHERE EmployeeID = @employeeID


DELETE FROM x_dept_employee
WHERE EmployeeID  = @employeeID AND @status = 0

GO

GRANT EXEC ON rpc_UpdateEmployeeCurrentStatus TO PUBLIC

GO

