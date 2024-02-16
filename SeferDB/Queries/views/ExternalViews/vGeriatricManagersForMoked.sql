create view dbo.vGeriatricManagersForMoked
as

       select ds.Simul228 as OldSeferSimul, d.deptCode, d.deptName, e.firstName + ' ' + e.lastName as SeferSiudName
          from Employee e
          join x_Dept_Employee xde on e.employeeID = xde.employeeID
          join Dept d on xde.deptCode = d.deptCode
          join x_Dept_Employee_Position xdep on xde.DeptEmployeeID =xdep.DeptEmployeeID
          left join deptSimul ds on d.deptCode = ds.deptCode
          join mainframe.dbo.dmg_mirpaot m on d.deptCode = m.SimulNew
          where d.status = 1 and xde.active = 1 and e.active = 1
          and xdep.positionCode = 17
          and ds.Simul228 is not null
          and (mirpaat_mevutahim = 'כ')

       --  order by ds.Simul228

go


GRANT SELECT ON dbo.vGeriatricManagersForMoked TO [clalit\MokedAdmin]
go
