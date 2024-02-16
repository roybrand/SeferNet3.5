IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_Delete_InterfaceToSimulErrorsIntermediate')
	BEGIN
		DROP  Procedure  rpc_Delete_InterfaceToSimulErrorsIntermediate
	END

GO

CREATE Procedure dbo.rpc_Delete_InterfaceToSimulErrorsIntermediate

AS

delete from InterfaceToSimulErrorsIntermediate


GO


GRANT EXEC ON rpc_Delete_InterfaceToSimulErrorsIntermediate TO PUBLIC

GO


