IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertNewBrochure')
	BEGIN
		DROP  Procedure  rpc_InsertNewBrochure
	END

GO

CREATE Procedure dbo.rpc_InsertNewBrochure
(
	@DisplayName varchar(80),
	@FileName varchar(50),
	@languageCode int,
	@IsCommunity bit,
	@IsMushlam bit
)	
AS
	insert into Brochures 
	([DisplayName], [FileName], [languageCode], [IsCommunity], [IsMushlam]) 
	values(@DisplayName,@FileName,@languageCode,@IsCommunity,@IsMushlam)

GO

GRANT EXEC ON rpc_InsertNewBrochure TO PUBLIC

GO