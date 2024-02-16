IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getHandicappedFacilitiesByName')
	BEGIN
		DROP  Procedure  rpc_getHandicappedFacilitiesByName
	END

GO

CREATE Procedure rpc_getHandicappedFacilitiesByName
(
	@SearchString varchar(50)
)

AS

SELECT 
FacilityCode, 
FacilityDescription 
FROM DIC_HandicappedFacilities
WHERE FacilityDescription like '%' + @SearchString + '%' and Active=1

GO

GRANT EXEC ON rpc_getHandicappedFacilitiesByName TO PUBLIC

GO

