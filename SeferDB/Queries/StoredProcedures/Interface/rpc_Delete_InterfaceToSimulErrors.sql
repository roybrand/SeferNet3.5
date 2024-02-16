IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_Delete_InterfaceToSimulErrors')
	BEGIN
		DROP  Procedure  rpc_Delete_InterfaceToSimulErrors
	END

GO

CREATE Procedure dbo.rpc_Delete_InterfaceToSimulErrors

AS

DELETE FROM InterfaceToSimulErrors

GO


GRANT EXEC ON rpc_Delete_InterfaceToSimulErrors TO PUBLIC

GO

