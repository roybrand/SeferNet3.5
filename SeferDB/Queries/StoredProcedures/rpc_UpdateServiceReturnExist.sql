IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateServiceReturnExist')
	BEGIN
		DROP  Procedure  dbo.rpc_UpdateServiceReturnExist
	END

GO

CREATE Procedure [dbo].[rpc_UpdateServiceReturnExist]
(
	@serviceCode INT,
	@ServiceReturnExist smallint
)

AS

update MF_SalServices386
set ServiceReturnExist = @ServiceReturnExist
where ServiceCode = @serviceCode
GO

GRANT EXEC ON dbo.rpc_UpdateServiceReturnExist TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_UpdateServiceReturnExist TO [clalit\IntranetDev]
GO 