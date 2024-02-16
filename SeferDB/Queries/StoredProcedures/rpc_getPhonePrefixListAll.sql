IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getPhonePrefixListAll')
	BEGIN
		DROP  Procedure  rpc_getPhonePrefixListAll
	END

GO

CREATE Procedure dbo.rpc_getPhonePrefixListAll


AS

SELECT prefixCode, prefixValue, phoneType, DIC_PhoneTypes.phoneTypeName
FROM DIC_PhonePrefix
INNER JOIN DIC_PhoneTypes ON DIC_PhonePrefix.phoneType = DIC_PhoneTypes.phoneTypeCode
ORDER BY prefixValue, phoneType

GO

GRANT EXEC ON rpc_getPhonePrefixListAll TO PUBLIC

GO

