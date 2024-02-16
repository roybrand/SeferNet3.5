
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteDeptNames')
	BEGIN
		DROP  Procedure  rpc_deleteDeptNames
	END

GO

CREATE Procedure dbo.rpc_deleteDeptNames
	(
		@DeptCode int
	)
AS

BEGIN 

	DELETE FROM DeptNames where deptCode = @DeptCode
END 

GO

GRANT EXEC ON rpc_deleteDeptNames TO PUBLIC

GO