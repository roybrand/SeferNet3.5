IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updatePosition')
	BEGIN
		DROP  Procedure  rpc_updatePosition
	END

GO

CREATE Procedure dbo.rpc_updatePosition
(
		@code int, 	
		@name varchar(100),
		@gender int, 
		@userName varchar (50),
		@sector int,
		@useInSearches tinyint,
		@active BIT
		
)
as
  

UPDATE [position]       
      SET  [positionDescription] = @name ,
			[updateDate] = getdate(),					
			[UpdateUser] = @userName,
			[relevantSector]=@sector,
			[useInSearches]= @useInSearches,
			IsActive = @active
       WHERE [positionCode] =@code  and [gender] = @gender
GO


GRANT EXEC ON rpc_updatePosition TO PUBLIC

GO


