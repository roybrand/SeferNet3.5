IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteAllDeptEmployeePhones')
	BEGIN
		DROP  Procedure  rpc_DeleteAllDeptEmployeePhones
	END

GO

CREATE Procedure dbo.rpc_DeleteAllDeptEmployeePhones
(
	@deptEmployeeID INT	
)

AS

DELETE DeptEmployeePhones
WHERE DeptEmployeeID = @deptEmployeeID

GO


GRANT EXEC ON rpc_DeleteAllDeptEmployeePhones TO PUBLIC

GO


