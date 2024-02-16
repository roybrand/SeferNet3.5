IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertMushlamToSeferServiceMapping')
    BEGIN
	    DROP  Procedure  rpc_insertMushlamToSeferServiceMapping
    END

GO

CREATE Procedure dbo.rpc_insertMushlamToSeferServiceMapping
(
	@tableCode INT, 
	@mushlamServiceCode INT, 
	@parentCode INT, 
	@seferServiceCode INT,
	@updateUser VARCHAR(50)
)

AS

IF @parentCode IS NULL
	INSERT INTO MushlamSpecialityToSefer
	(MushlamTableCode, MushlamServiceCode, SeferServiceCode, UpdateUser, UpdateDate)
	VALUES (@tableCode, @mushlamServiceCode, @seferServiceCode, @updateUser, GETDATE())
ELSE
	INSERT INTO MushlamSubSpecialityToSefer
	(MushlamTableCode, MushlamServiceCode, ParentCode, SeferServiceCode, UpdateUser, UpdateDate)
	VALUES (@tableCode, @mushlamServiceCode, @parentCode, @seferServiceCode, @updateUser, GETDATE())


                
GO


GRANT EXEC ON rpc_insertMushlamToSeferServiceMapping TO PUBLIC

GO            


