IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeeInClinicDetails')
	BEGIN
		DROP  Procedure  rpc_getEmployeeInClinicDetails
	END

GO

CREATE Procedure [dbo].[rpc_getEmployeeInClinicDetails]
	(
		@deptEmployeeID int		
	)

AS


declare @indValue bit

SELECT
x_Dept_Employee.employeeID, 
x_Dept_Employee.deptCode, 
AgreementType,
'active'= Cast(ISNULL(x_Dept_Employee.active, 0) as bit),
'DoctorsName' = DIC_EmployeeDegree.DegreeName + ' ' + Employee.LastName + ' ' + Employee.FirstName,
Employee.FirstName, Employee.LastName,
EmployeeSector.EmployeeSectorCode,
EmployeeSector.IsDoctor,
EmployeeSectorDescription, 
dept.deptName,
dept.deptCode,
'phonesOnly' = dbo.fun_GetDeptEmployeePhonesOnly(x_Dept_Employee.employeeID, x_Dept_Employee.deptCode),	
'fax' = dbo.fun_GetDeptEmployeeFax(x_Dept_Employee.employeeID, x_Dept_Employee.deptCode),	
'expert' = dbo.fun_GetEmployeeExpert(x_Dept_Employee.employeeID),
Employee.IsMedicalTeam,
ISNULL(x_Dept_Employee.ReceiveGuests, 0) as ReceiveGuests

FROM x_Dept_Employee
INNER JOIN Employee ON x_Dept_Employee.employeeID = Employee.employeeID
INNER JOIN DIC_EmployeeDegree ON Employee.degreeCode = DIC_EmployeeDegree.DegreeCode
INNER JOIN EmployeeSector ON Employee.EmployeeSectorCode = EmployeeSector.EmployeeSectorCode
INNER JOIN dept ON x_Dept_Employee.deptCode = dept.deptCode

WHERE x_Dept_Employee.deptEmployeeID = @deptEmployeeID

GO

GRANT EXEC ON rpc_getEmployeeInClinicDetails TO PUBLIC

GO


