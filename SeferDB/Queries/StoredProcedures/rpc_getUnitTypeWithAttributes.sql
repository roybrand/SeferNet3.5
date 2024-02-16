IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getUnitTypeWithAttributes')
	BEGIN
		DROP  Procedure  rpc_getUnitTypeWithAttributes
	END

GO

CREATE Procedure dbo.rpc_getUnitTypeWithAttributes
	(
		@UnitTypeCode int
	)

AS

SELECT
UnitTypeCode,
UnitTypeName,
'ShowInInternet' = IsNull(ShowInInternet, 1),
'AllowQueueOrder' = IsNull(AllowQueueOrder, 0)

FROM UnitType
WHERE UnitTypeCode = @UnitTypeCode

GO

GRANT EXEC ON dbo.rpc_getUnitTypeWithAttributes TO PUBLIC

GO

