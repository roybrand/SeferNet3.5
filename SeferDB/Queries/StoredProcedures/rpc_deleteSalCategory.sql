  
IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rpc_deleteSalCategory')
	BEGIN
		DROP  Procedure  rpc_deleteSalCategory
	END

GO


CREATE Procedure [dbo].rpc_deleteSalCategory
@SalCategoryId Int
As

Delete From SalCategories Where SalCategoryId = @SalCategoryId


GO

GRANT EXEC ON rpc_deleteSalCategory TO PUBLIC
GO
   