IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertSubUnitTypeSubstituteName')
	BEGIN
		DROP  Procedure  rpc_InsertSubUnitTypeSubstituteName
	END
GO

CREATE PROCEDURE [dbo].[rpc_InsertSubUnitTypeSubstituteName]
(
	@UnitTypeCode int, 
	@SubUnitTypeCode int,
	@SubstituteName varchar(100),
	@UpdateUser varchar(50)
)

AS

INSERT INTO SubUnitTypeSubstituteName
(SubUnitTypeCode, UnitTypeCode, SubstituteName, UpdateUser)
VALUES
(@SubUnitTypeCode, @UnitTypeCode, @SubstituteName, @UpdateUser)


GRANT EXEC ON rpc_InsertSubUnitTypeSubstituteName TO PUBLIC
GO