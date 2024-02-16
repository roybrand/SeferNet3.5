IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetCurrentStatusForEmployeeInDept')
	BEGIN
		DROP  Procedure  rpc_GetCurrentStatusForEmployeeInDept
	END

GO

CREATE Procedure dbo.rpc_GetCurrentStatusForEmployeeInDept
(
	@deptEmployeeID INT
)

AS

SELECT xd.active, StatusDescription
FROM x_dept_employee xd
INNER JOIN DIC_ActivityStatus dic ON xd.active = dic.status
WHERE xd.DeptEmployeeID = @deptEmployeeID 



GO


GRANT EXEC ON rpc_GetCurrentStatusForEmployeeInDept TO PUBLIC

GO


