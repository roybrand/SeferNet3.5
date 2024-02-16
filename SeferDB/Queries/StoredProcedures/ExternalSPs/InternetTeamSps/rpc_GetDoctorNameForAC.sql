-- =============================================
--	Owner : Internet Team
-- =============================================
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDoctorNameForAC')
	BEGIN
		DROP  Procedure  [rpc_GetDoctorNameForAC]
	END

GO

CREATE Procedure [dbo].[rpc_GetDoctorNameForAC]
(
	@SectorCode int,
	@Prefix varchar(50)
)
 
AS

SELECT DIC_EmployeeDegree.DegreeName
	  ,[lastName]	
      ,[firstName]
  FROM [dbo].[Employee],DIC_EmployeeDegree
  where active=1
  and (EmployeeSectorCode=@SectorCode)
  and DIC_EmployeeDegree.DegreeCode=Employee.degreeCode
and lastname like @Prefix + '%'


--(
--	@SectorCode int,
--	@Prefix varchar(50)
--)
 
--AS

--select ed.DegreeName , e.firstName, e.lastName
--from Employee e
--join DIC_EmployeeDegree ed
--on e.degreeCode = ed.DegreeCode
--WHERE e.EmployeeSectorCode = @SectorCode
--		and e.lastName like @Prefix + '%'
--		and e.EmployeeSectorCode IN (2, 7)  
--		and e.active = 1
--		and e.IsVirtualDoctor <> 1 and e.IsMedicalTeam <> 1
--		and exists (select * from x_Dept_Employee xde
--					join Dept d
--						on xde.deptCode = d.deptCode
--						and d.status = 1 and d.showUnitInInternet = 1
--						and (d.IsCommunity = 1 or d.IsMushlam = 1)
--					join UnitType ut
--						on d.typeUnitCode = ut.UnitTypeCode
--						and ut.ShowInInternet = 1 and ut.IsActive = 1
--					where xde.active = 1 and xde.AgreementType <> 4
--						and xde.employeeID = e.employeeID
--					)

GO

GRANT EXEC ON [rpc_GetDoctorNameForAC] TO PUBLIC

GO

