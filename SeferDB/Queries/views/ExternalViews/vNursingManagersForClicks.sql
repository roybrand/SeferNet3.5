create view vNursingManagersForClicks
as

	select d.deptCode as NewSimul, ds.Simul228 as OldSimul, d.deptName
	 , dp.employeeID, e.ProfessionalLicenseNumber as LicenseNumber, e.firstName, e.lastName
	 , ut.UnitTypeName
	from Dept d
	join (select xde.deptCode, xde.employeeID 
	   from x_Dept_Employee xde
	   join x_Dept_Employee_Position xdep on xde.DeptEmployeeID = xdep.DeptEmployeeID
	   where xde.active = 1 and xdep.positionCode = 17
	  ) dp on d.deptCode = dp.deptCode
	join Employee e on dp.employeeID = e.employeeID
	join deptSimul ds on d.deptCode = ds.deptCode
	join UnitType ut on d.typeUnitCode = ut.UnitTypeCode
	join MainFrame.dbo.dmg_mirpaot m on m.kod_mirpaa = ds.Simul228
	where d.status = 1
	and d.IsCommunity = 1
	and e.active = 1
	and d.typeUnitCode in (101, 102, 103, 112, 501)
	and m.mirpaat_mevutahim = 'כ'

go