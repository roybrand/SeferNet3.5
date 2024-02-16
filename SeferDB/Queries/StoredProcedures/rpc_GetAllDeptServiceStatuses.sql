IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetAllDeptServiceStatuses')
	BEGIN
		DROP  Procedure  rpc_GetAllDeptServiceStatuses
	END

GO

CREATE Procedure dbo.rpc_GetAllDeptServiceStatuses
(	
	@deptCode INT,
	@serviceCode INT,
	@employeeID bigint
)

AS

select DESS.Status, StatusDescription, FromDate, ToDate
from DeptEmployeeServiceStatus DESS
JOIN DIC_ActivityStatus dic ON DESS.Status = dic.Status
join x_Dept_Employee_Service xDES on DESS.x_dept_employee_serviceID = xDES.x_Dept_Employee_ServiceID
join x_Dept_Employee xDE on xDES.DeptEmployeeID = xDE.DeptEmployeeID
where xDE.deptCode = @deptCode
	and xDE.employeeID = @employeeID
	and xDES.serviceCode = @serviceCode
ORDER BY FromDate ASC


GO


GRANT EXEC ON rpc_GetAllDeptServiceStatuses TO PUBLIC

GO


