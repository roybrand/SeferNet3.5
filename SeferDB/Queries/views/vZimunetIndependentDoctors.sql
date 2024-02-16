 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'vZimunetIndependentDoctors')
	BEGIN
		DROP  view  vZimunetIndependentDoctors
	END

GO
/*
View for zimunet - independent doctors data
1.      מספר רישיון רופא
2.      קוד מרפאה שבה הוא מקבל: גם ישן וגם חדש
3.      תואר (ד"ר / פרופ')
4.      שם פרטי
5.      שם משפחה
6.      התמחות
7.      כתובת המרפאה שבה הוא עובד
a.       עיר
b.      רחוב
c.       מספר בית
d.      טלפון 1
e.       טלפון 2
f.       הערה לכתובת

*/

CREATE view [dbo].[vZimunetIndependentDoctors]
as

       select e.licenseNumber as docId, d.deptCode as siteId,
                     cast(ed.DegreeName as nvarchar(50)) as title, 
                                   cast(e.firstName as nvarchar(50)) as firstName, 
                                   cast(e.lastName as nvarchar(50)) as lastName, 
                     case when xdes.serviceCode = 56 then 1059 else xdes.serviceCode end as roleId,
                                  cast(s.ServiceDescription as nvarchar(50)) as roleDescription,
                     cast(c.cityName as nvarchar(50)) as city, 
                                   cast(d.streetName as nvarchar(50)) as street, 
                                   cast(d.house as nvarchar(50)) as number, 
                                   cast(dbo.GetDeptPhoneNumber(d.deptCode, 1, 1) as nvarchar(50)) as phone1,
                     cast(dbo.GetDeptPhoneNumber(d.deptCode, 1, 2) as nvarchar(50)) as phone2
       from Employee e
       join x_Dept_Employee xde on e.employeeID = xde.employeeID
       join Dept d on xde.deptCode = d.deptCode
       join Cities c on d.cityCode = c.cityCode
       join DIC_EmployeeDegree ed on e.degreeCode = ed.DegreeCode
       join x_Dept_Employee_Service xdes on xde.DeptEmployeeID = xdes.DeptEmployeeID
       join Services s on xdes.serviceCode = s.ServiceCode
       where e.IsInCommunity = 1 and e.active = 1
              and xde.active = 1 and d.status = 1
                       and xde.AgreementType = 2 and d.subUnitTypeCode is not null and d.subAdministrationCode <> 0
              and e.EmployeeSectorCode = 7 and e.IsVirtualDoctor <> 1 and e.IsMedicalTeam <> 1
              and xdes.serviceCode in (12, 13, 21, 23, 31, 32, 52, 55, 58, 61, 62, 63, 65
                                                                     , 498, 501, 603, 1048, 1053, 1059, 1736)
                       and not exists (select 1
                                                from EmployeeQueueOrderMethod qe
                                                where qe.QueueOrderMethod = 3
                                                       and qe.DeptEmployeeID = xde.DeptEmployeeID)

GO


