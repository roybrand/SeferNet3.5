IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteEmployeeReceptionInDept')
	BEGIN
		DROP  Procedure  rpc_DeleteEmployeeReceptionInDept
	END

GO

CREATE Procedure dbo.rpc_DeleteEmployeeReceptionInDept
(
	@employeeID BIGINT,
	@deptCode INT,
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

DELETE DeptEmployeeReception
WHERE DeptEmployeeID = @deptEmployeeID

GO


GRANT EXEC ON rpc_DeleteEmployeeReceptionInDept TO PUBLIC

GO


