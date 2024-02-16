IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertAdminComment')
	BEGIN
		DROP  Procedure  rpc_InsertAdminComment
	END

GO

Create Procedure dbo.rpc_InsertAdminComment
(
		@Title varchar(200) ,
		@Comment varchar(2000) ,
		@StartDate DateTime ,
		@ExpiredDate DateTime ,
		@Active TinyInt ,
		@UpdateDate DateTime , 
		@UpdateUser VarChar(200)
)
As

Insert Into AdminComments ( Title , Comment , StartDate , ExpiredDate , Active , UpdateDate , UpdateUser )
Values ( @Title , @Comment , @StartDate , @ExpiredDate , @Active , @UpdateDate , @UpdateUser )

Select @@IDENTITY;

GO

GRANT EXEC ON rpc_InsertAdminComment TO PUBLIC

GO


