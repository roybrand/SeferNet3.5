IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDoctorInClinicDetails')
	BEGIN
		DROP  Procedure  rpc_getDoctorInClinicDetails
	END

GO

CREATE Procedure rpc_getDoctorInClinicDetails
-- @CodesArray it's 4 codes - deptCode,employeeID,positionCode,professionCode 
-- delimited with ','
-- the reason to use "combined" parameter instead of 4 separated: it's selected value of GridView,
-- which can't be more then 1 parameter
	(
		@deptCode int,
		@employeeID int
		--@professionCode int
	)

AS


declare @indValue bit

SELECT
x_Dept_Employee.employeeID, 
x_Dept_Employee.deptCode, 
'independent'= Cast(ISNULL(x_Dept_Employee.independent,0) as bit),
'active'= Cast(ISNULL(x_Dept_Employee.active, 0) as bit),
'DoctorsName' = DIC_EmployeeDegree.DegreeName + ' ' + Employee.FirstName + ' ' + Employee.LastName,
Employee.FirstName, Employee.LastName,
EmployeeSectorDescription,
dept.deptName,
dept.deptCode,
x_Dept_Employee.email,
'showEmailInInternet' = Cast(ISNULL(x_Dept_Employee.showEmailInInternet, 0) as bit)

FROM x_Dept_Employee
INNER JOIN Employee ON x_Dept_Employee.employeeID = Employee.employeeID
INNER JOIN DIC_EmployeeDegree ON Employee.degreeCode = DIC_EmployeeDegree.DegreeCode
INNER JOIN EmployeeSector ON Employee.EmployeeSectorCode = EmployeeSector.EmployeeSectorCode
INNER JOIN dept ON x_Dept_Employee.deptCode = dept.deptCode


WHERE x_Dept_Employee.deptCode = @deptCode
AND x_Dept_Employee.employeeID = @employeeID

GO

GRANT EXEC ON rpc_getDoctorInClinicDetails TO PUBLIC

GO


