IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetAdminComments')
	BEGIN
		DROP  Procedure  rpc_GetAdminComments
	END

GO

CREATE Procedure dbo.rpc_GetAdminComments
@Title VarChar(200) , @Comment VarChar(200) , @StartDate DateTime , @ExpiredDate DateTime , @Active TinyInt
AS

Select * 
From AdminComments
Where	( @Title is null Or LEN(@Title)<=0 Or Title Like '%'+@Title+'%' ) And
		( @Comment is null Or LEN(@Comment)<=0 Or Comment Like '%'+@Comment+'%' ) And
		( @StartDate is null Or StartDate >= @StartDate ) And
		( @ExpiredDate is null Or ExpiredDate >= @ExpiredDate Or ExpiredDate Is Null ) And
		( @Active is null Or Active = @Active )

GO


GRANT EXEC ON rpc_GetAdminComments TO PUBLIC

GO


