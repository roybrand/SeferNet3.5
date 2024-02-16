IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeeRemarksAttributedToDepts')
	BEGIN
		DROP  Procedure  rpc_getEmployeeRemarksAttributedToDepts
	END

GO

CREATE Procedure dbo.rpc_getEmployeeRemarksAttributedToDepts
	(
		@EmployeeRemarkID int
	)

AS

SELECT 
xd.deptCode,
xd.employeeID,
dept.deptName,
'attributed' = 
	CAST(
		CASE
			isNull((SELECT EmployeeRemarkID 
					FROM x_Dept_Employee_EmployeeRemarks
					WHERE xd.DeptEmployeeID = x_Dept_Employee_EmployeeRemarks.DeptEmployeeID					
					AND x_Dept_Employee_EmployeeRemarks.EmployeeRemarkID = @EmployeeRemarkID), 0)
		WHEN 0 THEN 0 ELSE 1 END
	AS bit)
	
FROM x_Dept_Employee xd
INNER JOIN dept ON dept.deptCode = xd.deptCode
INNER JOIN Employee ON xd.EmployeeID = Employee.EmployeeID
INNER JOIN EmployeeRemarks ON Employee.EmployeeID = EmployeeRemarks.EmployeeID
LEFT JOIN x_Dept_Employee_EmployeeRemarks ON xd.DeptEmployeeID = x_Dept_Employee_EmployeeRemarks.DeptEmployeeID	
	AND x_Dept_Employee_EmployeeRemarks.EmployeeRemarkID = @EmployeeRemarkID
	 

WHERE EmployeeRemarks.EmployeeRemarkID = @EmployeeRemarkID

GO

GRANT EXEC ON rpc_getEmployeeRemarksAttributedToDepts TO PUBLIC

GO
 