IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteDeptHandicappedFacilities')
	BEGIN
		DROP  Procedure  rpc_deleteDeptHandicappedFacilities
	END

GO

CREATE Procedure rpc_deleteDeptHandicappedFacilities
	(
		@DeptCode int,
		@FacilityCode int
	)

AS

DELETE FROM DeptHandicappedFacilities
WHERE DeptCode = @DeptCode
AND FacilityCode = @FacilityCode

GO

GRANT EXEC ON rpc_deleteDeptHandicappedFacilities TO PUBLIC

GO

