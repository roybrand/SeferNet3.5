IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateDeptHandicappedFacilities')
	BEGIN
		DROP  Procedure  rpc_updateDeptHandicappedFacilities
	END

GO

CREATE Procedure dbo.rpc_updateDeptHandicappedFacilities
	(
		@DeptCode int,
		@DeptHandicappedFacilities varchar(100),
		@ErrorStatus int output
	)

AS

DELETE FROM DeptHandicappedFacilities WHERE DeptCode = @DeptCode

INSERT INTO DeptHandicappedFacilities
(DeptCode, FacilityCode)
SELECT @DeptCode, IntField FROM dbo.SplitString(@DeptHandicappedFacilities)

SET @ErrorStatus = @@Error

GO

GRANT EXEC ON rpc_updateDeptHandicappedFacilities TO PUBLIC

GO

