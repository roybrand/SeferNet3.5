IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteSubUnitType')
	BEGIN
		DROP  Procedure  rpc_deleteSubUnitType
	END

GO

CREATE Procedure rpc_deleteSubUnitType
(
	@parentCode int,
	@code int
)

AS

DELETE FROM subUnitType
      WHERE UnitTypeCode = @parentCode and subUnitTypeCode = @code

GO


GRANT EXEC ON rpc_deleteSubUnitType TO PUBLIC

GO


