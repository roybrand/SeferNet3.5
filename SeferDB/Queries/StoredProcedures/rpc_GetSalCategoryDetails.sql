IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_GetSalCategoryDetails]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[rpc_GetSalCategoryDetails]
GO

CREATE Proc [dbo].[rpc_GetSalCategoryDetails]
@SalCategoryID Int
As
	Select * 
	From SalCategories 
	Where SalCategoryID = @SalCategoryID

GO

GRANT EXEC ON rpc_GetSalCategoryDetails TO PUBLIC
GO
