IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteRemarkInfo')
	BEGIN
		DROP  Procedure  rpc_deleteRemarkInfo
	END

GO

CREATE Procedure rpc_deleteRemarkInfo
	(
		@RemarkInfoID int
	)

AS

DELETE FROM RemarkInfo WHERE RemarkInfoID = @RemarkInfoID

GO

GRANT EXEC ON rpc_deleteRemarkInfo TO PUBLIC

GO

