IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetHandicappedFacilityByName')
	BEGIN
		DROP  Procedure  rpc_GetHandicappedFacilityByName
	END

GO

CREATE Procedure dbo.rpc_GetHandicappedFacilityByName
(
	@handicappedFacility VARCHAR(30),
	@searchExtended BIT
)

AS

SELECT *
FROM DIC_HandicappedFacilities
WHERE (FacilityDescription LIKE @handicappedFacility + '%' ) 
	  OR 
	  (FacilityDescription LIKE '%' + @handicappedFacility + '%' AND @searchExtended = 1)
ORDER BY FacilityDescription 


GO


GRANT EXEC ON rpc_GetHandicappedFacilityByName TO PUBLIC

GO


