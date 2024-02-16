IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateUnitTypes')
	BEGIN
		DROP  Procedure  rpc_updateUnitTypes
	END

GO

CREATE PROCEDURE [dbo].[rpc_updateUnitTypes]
(	
	@code INT, 		
	@name VARCHAR(100),
	@userName VARCHAR(100),
	@showInInternet BIT,
	@allowQueueOrder BIT,
	@isActive BIT,
	@defaultSubUnitCode INT,
	@CategoryID tinyint
)
as  

UPDATE [UnitType]       
	  SET  [UnitTypeName] = @name ,
		   [ShowInInternet]= @showInInternet,
		   [AllowQueueOrder]=@allowQueueOrder,
		   [UpdateUser]=@userName,
			[UpdateDate] = getdate(),
			IsActive = @isActive,
			DefaultSubUnitTypeCode = @defaultSubUnitCode,
			CategoryID = @CategoryID
	   WHERE [UnitTypeCode] = @code  


GO

GRANT EXEC ON rpc_updateUnitTypes TO PUBLIC