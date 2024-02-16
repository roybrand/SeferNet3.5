IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vDoctors]'))
DROP VIEW [dbo].[vDoctors]
GO

CREATE VIEW [dbo].[vDoctors]

AS

SELECT TOP 100 PERCENT
district, 
licenseNumber, 
employeeID, 
firstName, 
lastName, 
independent, 
sex, 
professionCode, 
professionDescription, 
expertProfessionCode, 
expertProfessionDescription

FROM
(
SELECT TOP 1
'קוד מחוז' as district, 
'מספר רישיון' as licenseNumber, 
'מספר רופא' as employeeID, 
'שם פרטי רופא' as firstName, 
'שם משפחה רופא' as lastName, 
'עצמאי' as independent, 
'מין רופא' as sex, 
'קוד מקצוע' as professionCode, 
'שם מקצוע' as professionDescription, 
'קוד התמחות' as expertProfessionCode, 
'שם התמחות' as expertProfessionDescription,
1 as orderNumber
FROM Employee

UNION

SELECT
CASE WHEN Employee.primaryDistrict is null THEN 'אין מחוז' ELSE CAST( Employee.primaryDistrict as varchar(7)) END as district, -- קוד מחוז
CAST(Employee.licenseNumber as varchar(6)) as licenseNumber, -- מספר רישיון
CAST(Employee.employeeID as varchar(10)) as employeeID, -- מספר רופא
Employee.firstName, -- שם פרטי רופא
Employee.lastName, -- שם משפחה רופא
dbo.fun_GetEmployeeIndependence(Employee.employeeID) as independent, -- '(עצמאי(כ/ל'
CASE WHEN DIC_Gender.sexDescription IS NULL THEN '' ELSE DIC_Gender.sexDescription END as sex, -- מין רופא
CAST(EmployeeServices.serviceCode as varchar(10)) as professionCode, -- קוד מקצוע
[Services].ServiceDescription as professionDescription, -- שם מקצוע
-- קוד התמחות, שם התמחות 
CASE CAST( EmployeeServices.expProfession as varchar(1)) WHEN '0' THEN '' ELSE CAST(EmployeeServices.serviceCode as varchar(10)) END as expertProfessionCode,
CASE CAST( EmployeeServices.expProfession as varchar(1)) WHEN '0' THEN '' ELSE [Services].ServiceDescription END as expertProfessionDescription,
2 as orderNumber

FROM Employee WITH(NOLOCK)
LEFT JOIN DIC_Gender ON Employee.sex = DIC_Gender.sex
LEFT JOIN EmployeeServices WITH(NOLOCK) ON Employee.employeeID = EmployeeServices.EmployeeID
LEFT JOIN [Services] ON EmployeeServices.serviceCode = [Services].ServiceCode
WHERE Employee.active <> 0
AND Employee.IsMedicalTeam = 0
AND Employee.IsVirtualDoctor = 0
AND EmployeeServices.serviceCode in (31,61,58,63,62) -- עור, עיניים, אורתופדיה, נשים, אף אוזן גרון
AND Employee.employeeID in (SELECT employeeID 
							FROM x_Dept_Employee 
							join x_Dept_Employee_Service xdes
							on x_Dept_Employee.DeptEmployeeID = xdes.DeptEmployeeID
							and xdes.serviceCode = EmployeeServices.serviceCode
							WHERE x_Dept_Employee.AgreementType in (1,2)
							and x_Dept_Employee.active = 1)

) T					
ORDER BY orderNumber

-- עור, עיניים, אורתופדיה, נשים, אף אוזן גרון

GO


grant select on [vDoctors] to public 
go


