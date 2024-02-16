IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertDIC_PhonePrefix')
	BEGIN
		DROP  Procedure  rpc_insertDIC_PhonePrefix
	END

GO

CREATE Procedure dbo.rpc_insertDIC_PhonePrefix
(
	@PrefixValue varchar(5),
	@PhoneType int,
	@ErrorCode int = 0 OUTPUT,
	@PrefixCodeInserted int = 0 OUTPUT
)

AS

	INSERT INTO DIC_PhonePrefix
	( prefixValue, phoneType )
	VALUES
	( @PrefixValue, @PhoneType )
	
	SET @ErrorCode = @@Error
	SET @PrefixCodeInserted = @@IDENTITY 

GO

GRANT EXEC ON rpc_insertDIC_PhonePrefix TO PUBLIC

GO

