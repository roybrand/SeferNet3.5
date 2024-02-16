IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertSimulExceptions')
	BEGIN
		DROP  Procedure  rpc_insertSimulExceptions
	END

GO

CREATE Procedure dbo.rpc_insertSimulExceptions
	(
		@CodeSimul int,
		@SeferSherut int,
		@userUpdate varchar(50),
		@ErrorCode int = 0 OUTPUT
	)

AS

	
	DELETE FROM SimulExceptions
	WHERE SimulId = @CodeSimul
	
	
	INSERT INTO SimulExceptions
	(SimulId, SeferSherut, userUpdate)
	VALUES
	(@CodeSimul, @SeferSherut, @userUpdate)
	
GO

GRANT EXEC ON rpc_insertSimulExceptions TO PUBLIC

GO

