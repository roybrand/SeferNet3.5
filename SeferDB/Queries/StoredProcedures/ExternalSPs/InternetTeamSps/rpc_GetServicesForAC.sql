-- =============================================
--	Owner : Internet Team
-- =============================================
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_GetServicesForAC]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[rpc_GetServicesForAC]
GO

create Procedure [dbo].[rpc_GetServicesForAC]
(
	@Prefix varchar(50),
	@IsService bit,
	@SectorCode int
)
 
AS
IF @IsService = 0 -- IF Is Employee
begin

      SELECT      distinct s.serviceCode, s.ServiceDescription
      FROM  dbo.Services s
      JOIN  x_Dept_Employee_Service xdes 
                        on xdes.serviceCode = s.ServiceCode 
                        and xdes.Status = 1
      join  x_Dept_Employee xde
                        on xdes.DeptEmployeeID = xde.DeptEmployeeID
                        and xde.active = 1
                        and xde.AgreementType <> 4
      join  Employee e
                        on xde.employeeID = e.employeeID
                        and e.active = 1
                        and e.EmployeeSectorCode in (2, 7)
                        and IsVirtualDoctor <> 1
      join  Dept d
                        on xde.deptCode = d.deptCode
                        and d.status = 1
                         and d.showUnitInInternet = 1
                         and (d.IsCommunity = 1 or d.IsMushlam = 1)
      join UnitType ut
                        on d.typeUnitCode = ut.UnitTypeCode
                        and ut.ShowInInternet = 1 and ut.IsActive = 1

      WHERE (e.EmployeeSectorCode = @SectorCode)
                    AND  (s.ServiceDescription LIKE @Prefix + '%')
      order by s.ServiceCode
end
ELSE -- IF Is Service (Dept)
begin
      SELECT      distinct s.serviceCode, s.ServiceDescription, IsMedicalTeam^1 AS IsProffesion
      FROM dbo.Services s
      JOIN x_Dept_Employee_Service xdes  
                  on xdes.serviceCode = s.ServiceCode 
                  and xdes.Status = 1
      join x_Dept_Employee xde
                  on xdes.DeptEmployeeID = xde.DeptEmployeeID
                  and xde.active = 1
                  and xde.AgreementType <> 4
      join Employee e
                  on xde.employeeID = e.employeeID
                  and e.active = 1
                  and e.EmployeeSectorCode in (2, 7)
                  and IsVirtualDoctor <> 1
      join Dept d
                  on xde.deptCode = d.deptCode
                  and d.status = 1
                  and d.showUnitInInternet = 1
                  and (d.IsCommunity = 1 or d.IsMushlam = 1)
      join UnitType ut
                  on d.typeUnitCode = ut.UnitTypeCode
                  and ut.ShowInInternet = 1 and ut.IsActive = 1

      WHERE (s.ServiceDescription LIKE @Prefix + '%')
                  and d.typeUnitCode not in (401, 303, 304)

      order by s.ServiceDescription

end
	


--(
--	@Prefix varchar(50),
--	@IsService bit
--)
 
--AS
--IF @IsService = 0 -- IF Is Employee
--begin

--      SELECT      distinct s.serviceCode, s.ServiceDescription
--      FROM  dbo.Services s
--      JOIN  x_Dept_Employee_Service xdes 
--                        on xdes.serviceCode = s.ServiceCode 
--                        and xdes.Status = 1
--      join  x_Dept_Employee xde
--                        on xdes.DeptEmployeeID = xde.DeptEmployeeID
--                        and xde.active = 1
--                        and xde.AgreementType <> 4
--      join  Employee e
--                        on xde.employeeID = e.employeeID
--                        and e.active = 1
--                        and e.EmployeeSectorCode in (2, 7)
--                        and IsVirtualDoctor <> 1
--      join  Dept d
--                        on xde.deptCode = d.deptCode
--                        and d.status = 1
--                         and d.showUnitInInternet = 1
--                         and (d.IsCommunity = 1 or d.IsMushlam = 1)
--      join UnitType ut
--                        on d.typeUnitCode = ut.UnitTypeCode
--                        and ut.ShowInInternet = 1 and ut.IsActive = 1

--      WHERE (e.EmployeeSectorCode = @SectorCode)
--                    AND  (s.ServiceDescription LIKE @Prefix + '%')
--      order by s.ServiceCode
--end
--ELSE -- IF Is Service (Dept)
--begin
--      SELECT      distinct s.serviceCode, s.ServiceDescription, IsMedicalTeam^1 AS IsProffesion
--      FROM dbo.Services s
--      JOIN x_Dept_Employee_Service xdes  
--                  on xdes.serviceCode = s.ServiceCode 
--                  and xdes.Status = 1
--      join x_Dept_Employee xde
--                  on xdes.DeptEmployeeID = xde.DeptEmployeeID
--                  and xde.active = 1
--                  and xde.AgreementType <> 4
--      join Employee e
--                  on xde.employeeID = e.employeeID
--                  and e.active = 1
--                  and e.EmployeeSectorCode in (2, 7)
--                  and IsVirtualDoctor <> 1
--      join Dept d
--                  on xde.deptCode = d.deptCode
--                  and d.status = 1
--                  and d.showUnitInInternet = 1
--                  and (d.IsCommunity = 1 or d.IsMushlam = 1)
--      join UnitType ut
--                  on d.typeUnitCode = ut.UnitTypeCode
--                  and ut.ShowInInternet = 1 and ut.IsActive = 1

--      WHERE (e.EmployeeSectorCode = @SectorCode)
--                  and (s.ServiceDescription LIKE @Prefix + '%')
--                  and d.typeUnitCode not in (401, 303, 304)

--      order by s.ServiceDescription

--end

go


GRANT EXEC ON rpc_GetServicesForAC TO PUBLIC

GO

