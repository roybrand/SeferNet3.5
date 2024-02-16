
/*-------------------------------------------------------------------------
Get all dept facilities for integration team
-------------------------------------------------------------------------*/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vIngr_ClinicFacilities]'))
	DROP VIEW [dbo].vIngr_ClinicFacilities
GO


CREATE VIEW [dbo].vIngr_ClinicFacilities
AS
	select dhf.DeptCode as ClinicCode, dhf.FacilityCode, hf.FacilityDescription
	from DeptHandicappedFacilities dhf
	join DIC_HandicappedFacilities hf
	on dhf.FacilityCode = hf.FacilityCode
	where hf.Active = 1

GO


GRANT SELECT ON [dbo].vIngr_ClinicFacilities TO [public] AS [dbo]
GO
