IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDeptsForEmployeeRemarkFromAllDepts')
	BEGIN
		DROP  Procedure  rpc_GetDeptsForEmployeeRemarkFromAllDepts
	END

GO

CREATE Procedure dbo.rpc_GetDeptsForEmployeeRemarkFromAllDepts
(
	@employeeRemarkID INT
)

AS


SELECT 
er.EmployeeRemarkId,
-1 as DeptCode , 
'כל היחידות בקהילה' as DeptName, 
'RemarkRelatedToDept' = er.AttributedToAllClinicsInCommunity
FROM EmployeeRemarks er 
WHERE er.EmployeeRemarkID = @employeeRemarkID


UNION

SELECT  er.EmployeeRemarkId, dept.deptCode, deptName, 
'RemarkRelatedToDept' = CASE er.AttributedToAllClinicsInCommunity 
							WHEN 0 THEN	CASE ISNULL(xder.DeptEmployeeID, 0) 
											WHEN 0 THEN 0 
											ELSE 1 
										END
							ELSE 1 
						END
																					
FROM x_dept_employee xd
INNER JOIN Dept on xd.deptCode = dept.deptCode
LEFT JOIN EmployeeRemarks er ON xd.EmployeeID = er.EmployeeID
LEFT JOIN x_Dept_Employee_EmployeeRemarks xder ON er.EmployeeRemarkID = xder.EmployeeRemarkID AND xd.DeptEmployeeID = xder.DeptEmployeeID
WHERE er.EmployeeRemarkID = @employeeRemarkID
--AND xd.Active = 1

GO


GRANT EXEC ON rpc_GetDeptsForEmployeeRemarkFromAllDepts TO PUBLIC

GO


