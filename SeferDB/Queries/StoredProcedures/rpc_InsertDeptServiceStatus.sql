

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertDeptServiceStatus')
	BEGIN
		DROP  Procedure  rpc_InsertDeptServiceStatus
	END

GO

CREATE Procedure dbo.rpc_InsertDeptServiceStatus
(	
	@deptCode INT,
	@serviceCode INT,
	@employeeID bigint,
	@status SMALLINT,
	@fromDate DATETIME,
	@toDate DATETIME,
	@userName VARCHAR(30)
)

AS

declare @xDeptEmployeeServiceID int

set @xDeptEmployeeServiceID = (select x_dept_employee_serviceID
	from x_Dept_Employee_Service xDES join x_Dept_Employee xDE
	on xDES.DeptEmployeeID = xDE.DeptEmployeeID
	where xDES.serviceCode = @serviceCode 
	and xDE.deptCode = @deptCode and xDE.employeeID = @employeeID)

INSERT INTO DeptEmployeeServiceStatus(Status, FromDate, ToDate, UpdateUser,
	UpdateDate, x_dept_employee_serviceID)
	values(@status, @fromDate, @toDate, @userName, GETDATE(), @xDeptEmployeeServiceID)


GO


GRANT EXEC ON rpc_InsertDeptServiceStatus TO PUBLIC

GO