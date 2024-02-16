IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteDeptEventPhones')
	BEGIN
		DROP  Procedure  rpc_deleteDeptEventPhones
	END

GO

CREATE Procedure rpc_deleteDeptEventPhones
	(
		@DeptEventID int
	)

AS

DELETE FROM DeptEventPhones
WHERE DeptEventID = @DeptEventID

GO

GRANT EXEC ON rpc_deleteDeptEventPhones TO PUBLIC

GO

