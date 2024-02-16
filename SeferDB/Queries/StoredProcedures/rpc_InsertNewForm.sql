IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertNewForm')
	BEGIN
		DROP  Procedure  rpc_InsertNewForm
	END

GO

CREATE Procedure dbo.rpc_InsertNewForm
(
	@FileName varchar(50),
	@FormDisplayName varchar(100),
	@IsCommunity bit,
	@IsMushlam bit
)	
AS
	insert into Forms values(@FileName, @FormDisplayName, @IsCommunity, @IsMushlam)

GO

GRANT EXEC ON rpc_InsertNewForm TO PUBLIC

GO