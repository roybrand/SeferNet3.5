IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateUnitTypeConvertSimul')
	BEGIN
		DROP  Procedure  rpc_UpdateUnitTypeConvertSimul
	END

GO

CREATE Procedure dbo.rpc_UpdateUnitTypeConvertSimul
(
	@ConvertId int,
	@Active int,
	@TypeUnit int,
	@PopSectorID int,
	@UserUpdate varchar(50)
)

AS

	IF @PopSectorID = -1 
		SET @PopSectorID = null
	
	UPDATE UnitTypeConvertSimul 
	SET userUpdate = @UserUpdate, 
	Active = @Active,
	key_TypUnit = @TypeUnit,
	PopSectorID = @PopSectorID
	WHERE ConvertId = @ConvertId 

GO

GRANT EXEC ON rpc_UpdateUnitTypeConvertSimul TO PUBLIC

GO

