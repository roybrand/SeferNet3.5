IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteAttachedFileToEvent')
	BEGIN
		DROP  Procedure rpc_DeleteAttachedFileToEvent
	END

GO

CREATE Procedure dbo.rpc_DeleteAttachedFileToEvent
(
	@deptFileEventID INT
)

AS


DELETE DeptEventFiles
WHERE DeptEventFileID = @deptFileEventID 


GO


GRANT EXEC ON rpc_DeleteAttachedFileToEvent TO PUBLIC

GO
