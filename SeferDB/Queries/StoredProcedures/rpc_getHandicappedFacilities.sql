IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getHandicappedFacilities')
	BEGIN
		DROP  Procedure  rpc_getHandicappedFacilities
	END

GO

CREATE Procedure rpc_getHandicappedFacilities

	


AS

select 
FacilityCode, 
FacilityDescription 
from 
DIC_HandicappedFacilities


GRANT EXEC ON rpc_getHandicappedFacilities TO PUBLIC



