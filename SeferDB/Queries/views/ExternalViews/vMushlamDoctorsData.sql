/*

שליפה עבור המושלם שתכלול את השדות הבאים
•	ת.ז.
•	ספרת ביקורת
•	שם פרטי
•	שם משפחה
•	רישיון רופא
• קוד מקצוע מומחה (מטבלה 51)
•	תיאור מקצוע מומחה
                                                                                
עבור כל הרופאים בספר השירות בקהילה ובבתי החולים
במידה וקיים רופא עם יותר ממקצוע התמחות אחד, יהיו לו כמה שורות
אם בעייתי להפריד ספרת ביקורת מת.ז. – אפשר בשדה אחד כולל ספרת ביקורת

*/

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vMushlamDoctorsData]'))
	DROP VIEW [dbo].vMushlamDoctorsData
GO


CREATE VIEW [dbo].vMushlamDoctorsData  
AS  

select distinct e.employeeID as EmployeeID, e.firstName as FirstName, e.lastName as LastName,
  e.licenseNumber as DoctorLicense, ed.DegreeName, sc.ServiceCategoryID as ExpertiseID, 
  sc.ServiceCategoryDescription as ExpertiseDescreption
from Employee e
join EmployeeServices es on e.employeeID = es.EmployeeID
join x_ServiceCategories_Services xsc on xsc.ServiceCode = es.serviceCode
join ServiceCategories sc on xsc.ServiceCategoryID = sc.ServiceCategoryID
join Services s on es.serviceCode = s.ServiceCode
left join DIC_EmployeeDegree ed on e.degreeCode = ed.DegreeCode
where (e.IsInCommunity = 1 or e.IsInHospitals = 1)
and e.active = 1 and e.EmployeeSectorCode = 7
and e.IsMedicalTeam = 0 and e.IsVirtualDoctor = 0
and s.IsProfession = 1
union
select distinct e.employeeID as EmployeeID, e.firstName as FirstName, e.lastName as LastName,
  e.licenseNumber as DoctorLicense, ed.DegreeName, sc.ServiceCategoryID as ExpertiseID, 
  sc.ServiceCategoryDescription as ExpertiseDescreption
from Employee e
join x_Dept_Employee de on e.employeeID = de.employeeID
join x_Dept_Employee_Service es on de.DeptEmployeeID = es.DeptEmployeeID
left join x_ServiceCategories_Services xsc on xsc.ServiceCode = es.serviceCode
left join ServiceCategories sc on xsc.ServiceCategoryID = sc.ServiceCategoryID
join Services s on es.serviceCode = s.ServiceCode
left join DIC_EmployeeDegree ed on e.degreeCode = ed.DegreeCode
where (e.IsInCommunity = 1 or e.IsInHospitals = 1)
and e.active = 1 and e.EmployeeSectorCode = 7
and e.IsMedicalTeam = 0 and e.IsVirtualDoctor = 0
and s.IsProfession = 1
and not exists (select * from EmployeeServices es1 where es1.EmployeeID = e.employeeID
				and es1.serviceCode = es.serviceCode)

GO

GRANT SELECT ON [dbo].vMushlamDoctorsData TO [public] AS [dbo]
GO
