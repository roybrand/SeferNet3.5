create view dbo.vDoctorProfessionsForOmry
as

       select ds.Simul228 as OldSimulCode, e.licenseNumber as DoctorLicenseNumber
              , case when xdes.serviceCode = 2 then 2 else 1 end as DoctorProfession
       from Dept d
       join x_Dept_Employee xde on d.deptCode = xde.deptCode
       join Employee e on xde.employeeID = e.employeeID
       join deptSimul ds on d.deptCode = ds.deptCode
       join (select xdes.DeptEmployeeID, xdes.serviceCode from x_Dept_Employee_Service xdes
                           where xdes.Status = 1
                           --where xdes.DeptEmployeeID = xde.DeptEmployeeID
                           and xdes.serviceCode in (2, 40)) xdes on xdes.DeptEmployeeID = xde.DeptEmployeeID
       where d.IsCommunity = 1 and d.status = 1
       and e.active = 1 and e.IsMedicalTeam <> 1 and e.IsInCommunity = 1
       and xde.active = 1 and xde.AgreementType in (1, 2, 6)
       and e.licenseNumber is not null and e.licenseNumber <> 0
       and ds.Simul228 is not null

go
