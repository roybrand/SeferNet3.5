-- =============================================
--	Owner : Internet Team
-- =============================================
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetClinicsForAC')
	BEGIN
		DROP  Procedure  [rpc_GetClinicsForAC]
	END

GO

CREATE Procedure [dbo].[rpc_GetClinicsForAC]
(
	@Prefix varchar(50)
)
 
AS
	select	deptname,deptcode 
	from	dept,UnitType
	where	dept.typeUnitCode=UnitType.UnitTypeCode
			and UnitType.ShowInInternet =1 and UnitType.IsActive =1
			and dept.showUnitInInternet=1
			and dept.typeUnitCode not in(401,303,304)
			and dept.IsCommunity=1
			and dept.deptName like @Prefix + '%'


GO

GRANT EXEC ON [rpc_GetClinicsForAC] TO PUBLIC

GO

