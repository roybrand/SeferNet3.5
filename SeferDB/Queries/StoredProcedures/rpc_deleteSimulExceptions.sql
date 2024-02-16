IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteSimulExceptions')
	BEGIN
		DROP  Procedure  rpc_deleteSimulExceptions
	END

GO

CREATE Procedure rpc_deleteSimulExceptions

	(
		@simulExceptionID int 
	)


AS
DELETE FROM SimulExceptions where SimulId=@simulExceptionID

GO


GRANT EXEC ON rpc_deleteSimulExceptions TO PUBLIC

GO


