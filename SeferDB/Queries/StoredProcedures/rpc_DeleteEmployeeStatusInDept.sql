IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteEmployeeStatusInDept')
	BEGIN
		DROP  Procedure  rpc_DeleteEmployeeStatusInDept
	END

GO

CREATE Procedure dbo.rpc_DeleteEmployeeStatusInDept
(
	@employeeID BIGINT,
	@deptCode	INT,
	@agreementType INT
)

AS

declare @deptEmployeeID bigint
set @deptEmployeeID = 
(
	select DeptEmployeeID from x_Dept_Employee
	where deptCode = @deptCode 
	and employeeID = @employeeID
	and AgreementType = @agreementType
)

DELETE EmployeeStatusInDept
WHERE DeptEmployeeID = @deptEmployeeID


GO


GRANT EXEC ON rpc_DeleteEmployeeStatusInDept TO PUBLIC

GO


