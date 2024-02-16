IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateAdminComment')
	BEGIN
		DROP  Procedure  rpc_UpdateAdminComment
	END

GO

Create Procedure dbo.rpc_UpdateAdminComment
(
		@ID int ,
		@Title varchar(200) ,
		@Comment varchar(2000) ,
		@StartDate DateTime ,
		@ExpiredDate DateTime ,
		@Active TinyInt ,
		@UpdateDate DateTime , 
		@UpdateUser VarChar(200)
	)
As

Update	AdminComments
SET		Title = @Title , Comment = @Comment , 
		StartDate = @StartDate , ExpiredDate = @ExpiredDate , 
		Active = @Active , UpdateDate = @UpdateDate , UpdateUser = @UpdateUser
WHERE	ID = @ID

GO

GRANT EXEC ON rpc_UpdateAdminComment TO PUBLIC

GO


