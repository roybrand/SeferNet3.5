IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteDIC_PhonePrefix')
	BEGIN
		DROP  Procedure  rpc_deleteDIC_PhonePrefix
	END

GO

CREATE Procedure dbo.rpc_deleteDIC_PhonePrefix
(
	@PrefixCode int,
	@ErrorCode int = 0 OUTPUT
) 

AS

	DELETE DIC_PhonePrefix 
	WHERE prefixCode = @PrefixCode
	
	SET @ErrorCode = @@ERROR



GO

GRANT EXEC ON rpc_deleteDIC_PhonePrefix TO PUBLIC

GO

