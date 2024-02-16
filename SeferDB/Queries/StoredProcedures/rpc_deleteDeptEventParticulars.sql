IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteDeptEventParticulars')
	BEGIN
		DROP  Procedure  rpc_deleteDeptEventParticulars
	END

GO

CREATE Procedure rpc_deleteDeptEventParticulars
	(
		@DeptEventID int
	)

AS

	DELETE FROM DeptEventParticulars
	WHERE DeptEventID = @DeptEventID
GO

GRANT EXEC ON rpc_deleteDeptEventParticulars TO PUBLIC

GO

