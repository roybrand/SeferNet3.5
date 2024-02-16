IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteDeptEvent')
	BEGIN
		DROP  Procedure  rpc_deleteDeptEvent
	END

GO

CREATE Procedure rpc_deleteDeptEvent
	(
		@DeptEventID int 
	)

AS

DELETE FROM DeptEvent
WHERE DeptEventID = @DeptEventID


GO

GRANT EXEC ON rpc_deleteDeptEvent TO PUBLIC

GO

