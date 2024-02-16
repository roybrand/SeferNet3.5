/*
	דוח רופאים עצמיים עבור מערת מרע (מערכת רופאים עצמיים), יש לשלוף
	רופאים עצמאיים, פעילים בכל המחוזות
*/

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vMaraIndependentDoctorsData]'))
	DROP VIEW [dbo].[vMaraIndependentDoctorsData]
GO

CREATE VIEW [dbo].[vMaraIndependentDoctorsData]
AS 
SELECT distinct * from (select 
	isNull(dDistrict.deptCode , -1) as DistrictCode 
	,dDistrict.DeptName as DistrictName
	,isNull(dAdmin.DeptCode , -1) as AdminClinicCode 
	,dAdmin.DeptName as AdminClinicName 
	,d.deptCode as ClinicCode 
	,deptSimul.Simul228 as Code228 
	,d.DeptName as ClinicName 
	,Cities.CityCode as CityCode
	,Cities.CityName as CityName
	,dbo.GetAddress(d.deptCode) as ClinicAddress 
	,Employee.EmployeeID as EmployeeID 
	,Employee.licenseNumber as EmployeeLicenseNumber 
	,Employee.firstName as EmployeeFirstName
	,Employee.lastName as EmployeeLastName
	,DEProfessions.ProfessionCodes as ProfessionCode 
	,DEProfessions.ProfessionDescriptions as ProfessionDescription
	,DEExpProfessions.ExpertProfessionCodes as ExpertProfessionCode
	,DEExpProfessions.ExpertProfessionDescriptions as ExpertProfessionDescription
FROM Dept as d    
	LEFT JOIN x_Dept_Employee ON d.deptCode = x_Dept_Employee.deptCode 
	JOIN Employee ON x_Dept_Employee.employeeID = Employee.employeeID 
	JOIN DIC_ActivityStatus as EmpStatus on EmpStatus.Status = Employee.active 
	JOIN DIC_ActivityStatus as DeptEmpStatus on DeptEmpStatus.Status = x_Dept_Employee.active 
	LEFT JOIN dept as dAdmin on d.administrationCode = dAdmin.deptCode 
	LEFT JOIN dept as dDistrict on d.districtCode = dDistrict.deptCode 
	LEFT JOIN Cities on d.CityCode = Cities.CityCode 
	LEFT JOIN deptSimul on d.DeptCode = deptSimul.DeptCode 
	LEFT JOIN [dbo].View_DeptEmployeeProfessions as DEProfessions    
				on x_Dept_Employee.deptCode = DEProfessions.deptCode
				and x_Dept_Employee.AgreementType = DEProfessions.AgreementType
				and Employee.employeeID = DEProfessions.employeeID 
	LEFT JOIN [dbo].View_DeptEmployeeExpertProfessions as DEExpProfessions 
				on x_Dept_Employee.deptCode = DEExpProfessions.deptCode
				and x_Dept_Employee.AgreementType = DEExpProfessions.AgreementType
				and Employee.employeeID = DEExpProfessions.employeeID 
WHERE x_Dept_Employee.AgreementType IN (2)  
	AND Employee.EmployeeSectorCode = 7  
	AND x_Dept_Employee.active = 1 
	and Employee.IsMedicalTeam <> 1
 )
  as resultTable


GO

GRANT SELECT ON [dbo].[vMaraIndependentDoctorsData] TO [public] AS [dbo]
GO
