IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getHandicappedFacilitiesInDept')
	BEGIN
		DROP  Procedure  rpc_getHandicappedFacilitiesInDept
	END

GO

CREATE Procedure rpc_getHandicappedFacilitiesInDept
	(
		@DeptCode int
	)

AS

SELECT
DeptHandicappedFacilities.deptCode,
DeptHandicappedFacilities.FacilityCode,
DIC_HandicappedFacilities.FacilityDescription

FROM DIC_HandicappedFacilities
INNER JOIN DeptHandicappedFacilities 
	ON DIC_HandicappedFacilities.FacilityCode = DeptHandicappedFacilities.FacilityCode
WHERE DeptHandicappedFacilities.deptCode = @DeptCode

GO

GRANT EXEC ON rpc_getHandicappedFacilitiesInDept TO PUBLIC

GO

