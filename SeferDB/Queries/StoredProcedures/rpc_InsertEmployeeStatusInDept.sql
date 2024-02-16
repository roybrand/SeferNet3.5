IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertEmployeeStatusInDept')
	BEGIN
		DROP  Procedure  rpc_insertEmployeeStatusInDept
	END

GO

CREATE Procedure dbo.rpc_insertEmployeeStatusInDept
(
	@employeeID BIGINT,
	@deptCode	INT,
	@agreementType INT,
	@status		INT,
	@fromDate	DATETIME,
	@toDate		DATETIME,
	@updateUser	VARCHAR(50)
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

INSERT INTO EmployeeStatusInDept (Status, FromDate, ToDate, UpdateUser, UpdateDate, DeptEmployeeID)
VALUES ( @status, @fromDate, @toDate, @updateUser, GETDATE(), @deptEmployeeID )


GO


GRANT EXEC ON rpc_insertEmployeeStatusInDept TO PUBLIC

GO


