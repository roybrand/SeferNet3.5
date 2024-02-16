IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vEmployeeProfessionalDetails_perService]'))
DROP VIEW [dbo].[vEmployeeProfessionalDetails_perService]
GO

CREATE VIEW [dbo].[vEmployeeProfessionalDetails_perService]
AS
SELECT 
	dbo.x_Dept_Employee.deptCode, dbo.rfn_GetDeptEmployeeRemarkDescriptionsHTML(x_Dept_Employee.deptEmployeeID) 
	AS EmployeeRemark, dbo.Employee.employeeID, 
	dbo.DIC_EmployeeDegree.DegreeName + ' ' + dbo.Employee.lastName + ' ' + dbo.Employee.firstName AS EmployeeName, 
	dbo.fun_GetEmployeeExpert(dbo.Employee.employeeID) AS Experties, 
	CASE WHEN [Services].IsService  = 1 THEN '' ELSE [Services].ServiceDescription END AS ProfessionDescriptions, 
	CASE WHEN [Services].IsService  = 0 THEN '' ELSE [Services].ServiceDescription END AS ServiceDescriptions, 
	dbo.rfn_GetDeptEmployeeServiceQueueOrderDescriptionsHTML(x_Dept_Employee.deptCode, x_Dept_Employee.employeeID, x_Dept_Employee_Service.x_Dept_Employee_ServiceID)
	AS QueueOrderDescriptions, 
	dbo.rfn_GetDeptEmployeeRemarkDescriptionsHTML(x_Dept_Employee.deptEmployeeID) AS HTMLRemarks, dbo.Employee.EmployeeSectorCode,
	orderNumber = dbo.fun_getEmployeeOrderByProfessionInDept(dbo.x_Dept_Employee.deptCode ,dbo.x_Dept_Employee.employeeID),
	CASE CascadeUpdateDeptEmployeePhonesFromClinic 
	WHEN 0 THEN [dbo].[fun_GetDeptEmployeePhonesOnly](x_Dept_Employee.employeeID,x_Dept_Employee.deptCode) ELSE '' END as Phones,
	Employee.IsMedicalTeam,
	Employee.IsVirtualDoctor,
	[Services].ServiceCode
FROM dbo.x_Dept_Employee 
INNER JOIN dbo.Employee ON dbo.x_Dept_Employee.employeeID = dbo.Employee.employeeID 
INNER JOIN dbo.DIC_EmployeeDegree ON dbo.Employee.degreeCode = dbo.DIC_EmployeeDegree.DegreeCode
INNER JOIN x_Dept_Employee_Service ON x_Dept_Employee.DeptEmployeeID = x_Dept_Employee_Service.DeptEmployeeID
INNER JOIN [Services] ON x_Dept_Employee_Service.serviceCode = [Services].ServiceCode
LEFT OUTER JOIN dbo.DIC_QueueOrder ON dbo.x_Dept_Employee.QueueOrder = dbo.DIC_QueueOrder.QueueOrder
WHERE x_Dept_Employee.active = 1
AND IsMedicalTeam = 0

GO
