IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateDIC_PhonePrefix')
	BEGIN
		DROP  Procedure  rpc_updateDIC_PhonePrefix
	END

GO

CREATE Procedure dbo.rpc_updateDIC_PhonePrefix
(
	@PrefixCode int,
	@PrefixValue varchar(5),
	@PhoneType int,
	@ErrorCode int = 0 OUTPUT
)

AS


	UPDATE DIC_PhonePrefix
	SET prefixValue = @PrefixValue,
		phoneType = @PhoneType
	WHERE prefixCode = @PrefixCode
		
	SET @ErrorCode = @@Error

GO

GRANT EXEC ON rpc_updateDIC_PhonePrefix TO PUBLIC

GO

