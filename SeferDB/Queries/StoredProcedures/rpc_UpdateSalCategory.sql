  
IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rpc_UpdateSalCategory')
	BEGIN
		DROP  Procedure  rpc_UpdateSalCategory
	END
GO

CREATE Procedure [dbo].rpc_UpdateSalCategory
@SalCategoryId Int , @SalCategoryDescription varchar(100)
As

Update SalCategories Set SalCategoryDescription = @SalCategoryDescription 
Where SalCategoryID = @SalCategoryID

--EXEC [HealthServices].[dbo].[rpc_UpdateArea] @SalCategoryId, @SalCategoryDescription
GO

GRANT EXEC ON rpc_UpdateSalCategory TO PUBLIC
GO
   