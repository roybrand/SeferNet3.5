CREATE VIEW dbo.vInternetEmployeeDegreeDesc
as
       select e.licenseNumber as LicenseNumber 
        , ed.DegreeName
       from Employee e
       join DIC_EmployeeDegree ed on e.degreeCode = ed.DegreeCode
       where e.active = 1 and e.IsInCommunity = 1
       and e.EmployeeSectorCode = 7
       and exists (select 1 from x_dept_employee xde
          where xde.employeeID = e.employeeID and xde.active = 1)
       and e.IsVirtualDoctor = 0 and e.IsMedicalTeam = 0
       and isnull(e.licenseNumber, 0) <> 0 

go
