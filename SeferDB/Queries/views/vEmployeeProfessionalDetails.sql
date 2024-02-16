
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'vEmployeeProfessionalDetails')
	BEGIN
		DROP  view  vEmployeeProfessionalDetails
	END

GO

CREATE VIEW [dbo].[vEmployeeProfessionalDetails]
AS
SELECT  	dbo.x_Dept_Employee.deptCode, dbo.rfn_GetDeptEmployeeRemarkDescriptionsHTML(x_Dept_Employee.deptEmployeeID) 
					  AS EmployeeRemark, dbo.Employee.employeeID, 
					  dbo.DIC_EmployeeDegree.DegreeName + ' ' + dbo.Employee.lastName + ' ' + dbo.Employee.firstName AS EmployeeName, 
					  dbo.fun_GetEmployeeExpert(dbo.Employee.employeeID) AS Experties, 
					  dbo.rfn_GetDeptEmployeeProfessionDescriptions(dbo.x_Dept_Employee.deptCode, dbo.x_Dept_Employee.employeeID) AS ProfessionDescriptions, 
					  dbo.rfn_GetDeptEmployeesServiceDescriptions(dbo.x_Dept_Employee.deptCode, dbo.x_Dept_Employee.employeeID) AS ServiceDescriptions, 
					  dbo.rfn_GetDeptEmployeeQueueOrderDescriptionsHTML(dbo.x_Dept_Employee.deptCode, dbo.x_Dept_Employee.employeeID) 
					  AS QueueOrderDescriptions, dbo.rfn_GetDeptEmployeeRemarkDescriptionsHTML(x_Dept_Employee.deptEmployeeID) AS HTMLRemarks, dbo.Employee.EmployeeSectorCode,
					  orderNumber = dbo.fun_getEmployeeOrderByProfessionInDept(dbo.x_Dept_Employee.deptCode ,dbo.x_Dept_Employee.employeeID),
					  CASE CascadeUpdateDeptEmployeePhonesFromClinic 
						WHEN 0 THEN [dbo].[fun_GetDeptEmployeePhonesOnly](x_Dept_Employee.employeeID,x_Dept_Employee.deptCode) ELSE '' END as Phones,
					  Employee.IsMedicalTeam,
					Employee.IsVirtualDoctor
FROM         dbo.x_Dept_Employee 
INNER JOIN dbo.Employee ON dbo.x_Dept_Employee.employeeID = dbo.Employee.employeeID 
INNER JOIN dbo.DIC_EmployeeDegree ON dbo.Employee.degreeCode = dbo.DIC_EmployeeDegree.DegreeCode 
LEFT OUTER JOIN dbo.DIC_QueueOrder ON dbo.x_Dept_Employee.QueueOrder = dbo.DIC_QueueOrder.QueueOrder
WHERE x_Dept_Employee.active <> 0

GO
  
grant select on vEmployeeProfessionalDetails to public 

go