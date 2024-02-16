
/*-------------------------------------------------------------------------
Get all dept doctors data for integration team
-------------------------------------------------------------------------*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vIngr_ClinicDoctorsData]'))
	DROP VIEW [dbo].vIngr_ClinicDoctorsData
GO


CREATE VIEW [dbo].vIngr_ClinicDoctorsData
AS
select e.employeeID as DoctorID, e.licenseNumber as DoctorLicenceNo, 
		e.badgeID as EmployeeCode, e.firstName as DoctorFirstName, 
		e.lastName as DoctorLastName, e.sex as DoctorGenderCode, 
		e.degreeCode as DoctorTitleCode, ISNULL(e.email, '') as DoctorEmail, 
		e.showEmailInInternet as EmailIsUnlisted, e.IsMedicalTeam as IsDeptService, 
		xde.deptCode as ClinicCode, xde.AgreementType, 
		xdes.serviceCode, s.ServiceDescription, isnull(es.expProfession, 0) as IsExpert,
		s.IsProfession, s.IsService,
		case when ISNULL(ISNULL(esqm.queueOrderMethod, eqm.QueueOrderMethod), 0) = 1 then 1 else 0 end as OrderByClinicPhoneNumber,
		case when ISNULL(ISNULL(esqm.queueOrderMethod, eqm.QueueOrderMethod), 0) = 2 then 
			case when ISNULL(esqm.queueOrderMethod, 0) = 2 then 
     			(select dbo.fun_ParsePhoneNumberWithExtension(SPH.prePrefix, 
     								SPH.prefix, SPH.phone, SPH.extension)                 
				FROM EmployeeServiceQueueOrderPhones SPH 
				WHERE esqm.EmployeeServiceQueueOrderMethodID = SPH.EmployeeServiceQueueOrderMethodID
				AND SPH.phoneType = 1 and SPH.phoneOrder = 1
				) 
			else
     			(select top 1 dbo.fun_ParsePhoneNumberWithExtension(DEPH.prePrefix, 
     								DEPH.prefix, DEPH.phone, DEPH.extension)                 
				FROM DeptEmployeeQueueOrderPhones DEPH 
				WHERE eqm.QueueOrderMethodID = DEPH.QueueOrderMethodID
				AND DEPH.phoneType = 1 and DEPH.phoneOrder = 1
				) 
			end 
		else '' end	as OrderBySpecialPhoneNumber ,
		case when ISNULL(ISNULL(esqm.queueOrderMethod, eqm.QueueOrderMethod), 0) = 3 then '*2700' else '' end as OrderByTelemarketingCenter,
		case when ISNULL(ISNULL(esqm.queueOrderMethod, eqm.QueueOrderMethod), 0) = 4 then 1 else 0 end as OrderByInternet,
		case when ISNULL(ISNULL(xdes.QueueOrder, xde.QueueOrder), 0) = 4 then 1 else 0 end as OrderByClientClinic
		
from x_Dept_Employee xde
join Employee e
on xde.employeeID = e.employeeID
left join x_Dept_Employee_Service xdes
on xde.DeptEmployeeID = xdes.DeptEmployeeID
left join Services s
on xdes.serviceCode = s.ServiceCode
left join EmployeeServices es
on xdes.serviceCode = es.serviceCode
and xde.employeeID = es.EmployeeID
left join EmployeeQueueOrderMethod eqm
on xde.DeptEmployeeID = eqm.DeptEmployeeID
left join EmployeeServiceQueueOrderMethod esqm
on xdes.x_Dept_Employee_ServiceID = esqm.x_dept_employee_serviceID
join Dept d
on xde.deptCode = d.deptCode
where e.EmployeeSectorCode = 7
and e.active = 1
and xde.active = 1
and d.status = 1
--and xde.deptCode = 43300 
--and e.employeeID = 27062850 
--and e.employeeID = 1000000019

GO


GRANT SELECT ON [dbo].vIngr_ClinicDoctorsData TO [public] AS [dbo]
GO
