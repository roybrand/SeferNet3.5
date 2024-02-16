IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteEventFile')
	BEGIN
		DROP  Procedure  rpc_DeleteEventFile
	END

GO

PRINT 'Creating rpc_DeleteEventFile'
GO 

CREATE Procedure dbo.rpc_DeleteEventFile
(
	@eventFileID INT,
	@FileName VARCHAR(100) OUTPUT
)

AS

SELECT @fileName = FileName
				FROM EventFiles
				WHERE EventFileID = @eventFileID


DELETE EventFiles
WHERE EventFileID = @eventFileID



GO


GRANT EXEC ON rpc_DeleteEventFile TO PUBLIC

GO


