IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getHandicappedFacilitiesForDept')
	BEGIN
		DROP  Procedure  rpc_getHandicappedFacilitiesForDept
	END

GO

CREATE Procedure rpc_getHandicappedFacilitiesForDept
	(
		@DeptCode int
	)

AS

SELECT
DIC_HandicappedFacilities.FacilityCode,
DIC_HandicappedFacilities.FacilityDescription

FROM DIC_HandicappedFacilities
WHERE DIC_HandicappedFacilities.FacilityCode NOT IN
	(SELECT FacilityCode 
	FROM DeptHandicappedFacilities 
	WHERE DeptHandicappedFacilities.deptCode = @DeptCode)


GO

GRANT EXEC ON rpc_getHandicappedFacilitiesForDept TO PUBLIC

GO

