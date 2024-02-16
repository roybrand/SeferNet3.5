IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_Insert_LogInterface')
	BEGIN
		DROP  Procedure  rpc_Insert_LogInterface
	END

GO

CREATE Procedure dbo.rpc_Insert_LogInterface
(
	@Message varchar(100),
	@Comment varchar(200) = ''
)

AS

INSERT INTO LogInterface 
(LogDate, ErrNumber, KodSimul, TransName, ErrComment) 
 VALUES 
 (GETDATE(), 0 , 0, @Message, @Comment) 
 
GO


GRANT EXEC ON rpc_Insert_LogInterface TO PUBLIC

GO


