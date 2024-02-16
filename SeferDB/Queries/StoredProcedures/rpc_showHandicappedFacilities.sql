IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_showHandicappedFacilities')
	BEGIN
		DROP  Procedure  rpc_showHandicappedFacilities
	END

GO

CREATE Procedure rpc_showHandicappedFacilities
AS

select FacilityCode as 'Code', 
FacilityDescription as 'Name',
'' as 'Sex',
'' as 'Gender'  ,
'' as  'ParentCode' ,
'' as  'ChildCode' , 
'' as 'GroupByParent',
'' as 'relevantSector',Active as 'ShowInInternet', 
'' as 'sectorDescription'

from dbo.DIC_HandicappedFacilities
order by FacilityDescription


GO


GRANT EXEC ON rpc_showHandicappedFacilities TO PUBLIC

GO


