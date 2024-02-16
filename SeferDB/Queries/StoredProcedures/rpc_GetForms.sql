IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetForms')
	BEGIN
		DROP  Procedure  rpc_GetForms
	END
GO
CREATE PROCEDURE [dbo].[rpc_GetForms]
(
	@IsCommunity bit,
	@IsMushlam bit
)
AS
	select * from Forms
	where Forms.IsCommunity = @IsCommunity 
		and Forms.IsMushlam = @IsMushlam
GO

GRANT EXEC ON rpc_GetForms TO PUBLIC
GO
