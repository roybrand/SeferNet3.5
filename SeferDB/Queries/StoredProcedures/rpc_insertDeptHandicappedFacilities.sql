IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertDeptHandicappedFacilities')
	BEGIN
		DROP  Procedure  rpc_insertDeptHandicappedFacilities
	END

GO

CREATE Procedure dbo.rpc_insertDeptHandicappedFacilities
	(
		@DeptCode int,
		@HandicappedFacilities varchar(50),
		@ErrorCode int=0 OUTPUT
	)

AS


	INSERT INTO DeptHandicappedFacilities
	(DeptCode, FacilityCode)
	
	SELECT @DeptCode, IntField
	FROM dbo.SplitString(@HandicappedFacilities)
	
	SET @ErrorCode = @@Error


GO

GRANT EXEC ON rpc_insertDeptHandicappedFacilities TO PUBLIC

GO

