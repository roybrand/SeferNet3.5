IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteEmployeeServicePhones')
	BEGIN
		DROP  Procedure  rpc_DeleteEmployeeServicePhones
	END
GO

CREATE PROCEDURE [dbo].[rpc_DeleteEmployeeServicePhones]
	@x_Dept_Employee_ServiceID int, 
	@phoneType int

AS
	DELETE FROM EmployeeServicePhones
	WHERE (@x_Dept_Employee_ServiceID is null OR x_Dept_Employee_ServiceID = @x_Dept_Employee_ServiceID)
	AND (@phoneType is null OR phoneType = @phoneType)
GO

GRANT EXEC ON dbo.rpc_DeleteEmployeeServicePhones TO PUBLIC
GO