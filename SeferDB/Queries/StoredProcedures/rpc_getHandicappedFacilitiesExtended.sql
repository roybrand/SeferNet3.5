IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getHandicappedFacilitiesExtended')
	BEGIN
		DROP  Procedure  rpc_getHandicappedFacilitiesExtended
	END

GO

CREATE Procedure rpc_getHandicappedFacilitiesExtended
	(
		@SelectedFacilities varchar(100)
	)

AS

SELECT 
FacilityCode, 
FacilityDescription,
'selected' = CASE IsNull(sel.IntField, 0) WHEN 0 THEN 0 ELSE 1 END

FROM 
DIC_HandicappedFacilities
LEFT JOIN (SELECT IntField FROM dbo.SplitString(@SelectedFacilities)) as sel 
ON DIC_HandicappedFacilities.FacilityCode = sel.IntField
where DIC_HandicappedFacilities.Active = 1



GO

GRANT EXEC ON rpc_getHandicappedFacilitiesExtended TO PUBLIC

GO

