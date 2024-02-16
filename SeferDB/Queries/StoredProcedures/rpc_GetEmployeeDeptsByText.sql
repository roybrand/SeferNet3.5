IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetEmployeeDeptsByText')
	BEGIN
		DROP  Procedure  rpc_GetEmployeeDeptsByText
	END

GO

CREATE Procedure dbo.rpc_GetEmployeeDeptsByText
(
	@prefixText VARCHAR(20),
	@employeeID BIGINT
)

AS

SELECT *
FROM x_dept_employee xd
INNER JOIN Dept ON xd.DeptCode = Dept.DeptCode
WHERE xd.EmployeeID = @employeeID
AND Dept.DeptName LIKE '%' + @prefixText + '%'
AND xd.Active = 1




GO


GRANT EXEC ON rpc_GetEmployeeDeptsByText TO PUBLIC

GO


