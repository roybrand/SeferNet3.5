IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateLanguages')
	BEGIN
		DROP  Procedure  rpc_updateLanguages
	END

GO

CREATE Procedure rpc_updateLanguages
(	
	@code int, 			
	@show tinyint,
	@userName varchar(100)
)
as  

UPDATE [dbo].[languages]
   SET       
      [updateDate] = getDate()
      ,[updateUsername] = @userName
      ,[isShow] = @show
 WHERE [languageCode] = @code

GO


GRANT EXEC ON rpc_updateLanguages TO PUBLIC

GO


