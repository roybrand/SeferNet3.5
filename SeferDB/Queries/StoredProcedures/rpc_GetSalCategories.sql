  
IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rpc_GetSalCategories')
	BEGIN
		DROP  Procedure  rpc_GetSalCategories
	END

GO

CREATE Proc [dbo].[rpc_GetSalCategories]
@SalCategoryId Int , @SalCategoryDescription NVarChar(100)
As

Select * 
From SalCategories 
Where	( @SalCategoryId Is Null Or @SalCategoryId = 0 Or SalCategoryId = @SalCategoryId ) And
		( @SalCategoryDescription Is Null Or @SalCategoryDescription = 0 Or SalCategoryDescription Like '%' + @SalCategoryDescription + '%' ) And
		SalCategoryId >= 0
GO

GRANT EXEC ON rpc_GetSalCategories TO PUBLIC
GO
