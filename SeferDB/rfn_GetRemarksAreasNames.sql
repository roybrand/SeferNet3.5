 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'TF' AND name = 'rfn_GetRemarksAreasNames')
	BEGIN
		PRINT 'Dropping function rfn_GetRemarksAreasNames'
		DROP  function rfn_GetRemarksAreasNames
	END

GO

PRINT 'Creating function rfn_GetRemarksAreasNames'
GO

CREATE function [dbo].[rfn_GetRemarksAreasNames](@RelatedRemarkID int) 
RETURNS varchar(2000)
AS
BEGIN
declare @AreasNames varchar(2000) 
 
set @AreasNames = '' 
select @AreasNames = @AreasNames + AreaName + ';'
from (
Select distinct 
case 
	-- District + Admin + Sector + Type 
	when vd.DistrictCode is not null and vAdmins.AdministrationCode is not null 
	and ps.PopulationSectorID is not null and us.UnitTypeCode is not null 
	then 'ב' + vd.districtName + ' ב' + vAdmins.AdministrationName + ' במגזר '  
	+  ps.PopulationSectorDescription + ' סוג יחידה '  + us.UnitTypeName
	-- District + Admin + Sector 
	when vd.DistrictCode is not null and vAdmins.AdministrationCode is not null 
	and ps.PopulationSectorID is not null and us.UnitTypeCode is null 
	then 'ב' + vd.districtName + ' ב' + vAdmins.AdministrationName + ' במגזר ' 
	+  ps.PopulationSectorDescription 
	-- District + Admin  
	when vd.DistrictCode is not null and vAdmins.AdministrationCode is not null 
	and ps.PopulationSectorID is null and us.UnitTypeCode is not null 
	then 'ב' + vd.districtName + ' ב' + vAdmins.AdministrationName 
	-- District 
	when vd.DistrictCode is not null and vAdmins.AdministrationCode is null 
	and ps.PopulationSectorID is null and us.UnitTypeCode is null 
	then 'ב' + vd.districtName 
	-- District + Admin +  Type 
	when vd.DistrictCode is not null and vAdmins.AdministrationCode is not null 
	and ps.PopulationSectorID is null and us.UnitTypeCode is not null 
	then 'ב' + vd.districtName + ' ב' + vAdmins.AdministrationName 
	+ ' סוג יחידה '  + us.UnitTypeName
	-- District + Sector + Type 
	when vd.DistrictCode is not null and vAdmins.AdministrationCode is null 
	and ps.PopulationSectorID is not null and us.UnitTypeCode is not null 
	then 'ב' + vd.districtName + ' במגזר ' 	+  ps.PopulationSectorDescription + ' סוג יחידה '  + us.UnitTypeName
	-- District + Type 
	when vd.DistrictCode is not null and vAdmins.AdministrationCode is null 
	and ps.PopulationSectorID is null and us.UnitTypeCode is not null 
	then 'ב' + vd.districtName + ' סוג יחידה '  + us.UnitTypeName
	-- District + Sector 
	when vd.DistrictCode is not null and vAdmins.AdministrationCode is null 
	and ps.PopulationSectorID is not null and us.UnitTypeCode is null 
	then 'ב' + vd.districtName + ' במגזר ' 	+  ps.PopulationSectorDescription 
end as AreaName 
from Remarks as r
left join dbo.View_AllDistricts as vd
on r.districtCode = vd.DistrictCode  
left join dbo.View_AllAdministrations as vAdmins 
on r.administrationCode = vAdmins.AdministrationCode 
left join dbo.PopulationSectors as ps 
on r.populationSector = ps.PopulationSectorID
left join  dbo.View_UnitType as us 
on r.UnitTypeCode = us.UnitTypeCode
where r.RelatedRemarkID = @RelatedRemarkID
and @RelatedRemarkID <> 0) as tblAreas 
where AreaName is not null 
 return @AreasNames 
end 

GO

GRANT exec ON rfn_GetRemarksAreasNames TO public

GO
