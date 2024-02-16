IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateBrochure')
	BEGIN
		DROP  Procedure  rpc_UpdateBrochure
	END

GO

CREATE Procedure dbo.rpc_UpdateBrochure
(
	@BrochureID int,
	@DisplayName varchar(100),
	@FileName varchar(50),
	@LanguageCode int
	
)	
AS
	update Brochures 
	set DisplayName = @DisplayName,
	FileName = @FileName,
	LanguageCode = @LanguageCode
	where BrochureID = @BrochureID

GO

GRANT EXEC ON rpc_UpdateBrochure TO PUBLIC

GO