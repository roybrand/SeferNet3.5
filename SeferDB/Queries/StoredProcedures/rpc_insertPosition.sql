IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertPosition')
	BEGIN
		DROP  Procedure  rpc_insertPosition
	END

GO

CREATE Procedure rpc_insertPosition

	(
		@positionCode int ,
		@gender int,
		@positionDescription  varchar(50),
		@UpdateUser varchar(50),
		@sector int
	)


AS
INSERT INTO [dbo].[position]
           ([positionCode]
           ,[gender]
           ,[positionDescription]
           ,[UpdateDate]
           ,[UpdateUser]
           ,[relevantSector]
           )
     VALUES
           (@positionCode 
           ,@gender
           ,@positionDescription
           ,getdate()
           ,@UpdateUser,
          @sector)

GO


GRANT EXEC ON rpc_insertPosition TO PUBLIC

GO


