IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_AttachFileToEvent')
	BEGIN
		DROP  Procedure  rpc_AttachFileToEvent
	END

GO

PRINT 'Creating rpc_AttachFileToEvent '
GO 

CREATE Procedure dbo.rpc_AttachFileToEvent
(
	@eventCode INT,
	@fileName VARCHAR(150),
	@fileDescription VARCHAR(100)
	
)

AS


INSERT INTO EventFiles (eventCode, FileName, FileDescription)
VALUES (@eventCode, @fileName, @fileDescription)



GO

GRANT EXEC ON rpc_AttachFileToEvent TO PUBLIC

GO

