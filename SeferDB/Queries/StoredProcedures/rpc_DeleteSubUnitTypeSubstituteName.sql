IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteSubUnitTypeSubstituteName')
	BEGIN
		DROP  Procedure  rpc_DeleteSubUnitTypeSubstituteName
	END
GO

CREATE PROCEDURE [dbo].[rpc_DeleteSubUnitTypeSubstituteName]
(
	@UnitTypeCode int, 
	@SubUnitTypeCode int
)

AS

DELETE FROM SubUnitTypeSubstituteName
WHERE SubUnitTypeCode = @SubUnitTypeCode
AND UnitTypeCode = @UnitTypeCode

GRANT EXEC ON rpc_DeleteSubUnitTypeSubstituteName TO PUBLIC
GO