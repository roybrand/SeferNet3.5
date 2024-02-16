  
IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rpc_InsertSalCategory')
	BEGIN
		DROP  Procedure  rpc_InsertSalCategory
	END

GO


CREATE Procedure [dbo].rpc_InsertSalCategory
@SalCategoryDescription varchar(100) , @Add_Date DateTime
As
 
DECLARE @SalCategoryId as int

Insert Into SalCategories ( SalCategoryDescription , Add_Date )
Values ( @SalCategoryDescription , @Add_Date )

SET @SalCategoryId = @@IDENTITY

--EXEC [HealthServices].[dbo].[rpc_UpdateArea] @SalCategoryId, @SalCategoryDescription

Select @SalCategoryId;
GO

GRANT EXEC ON rpc_InsertSalCategory TO PUBLIC
GO
   