IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_InsertSalProfessionToCategory]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[rpc_InsertSalProfessionToCategory]
GO

CREATE Procedure [dbo].[rpc_InsertSalProfessionToCategory]
@ProfessionCode Int , @SalCategoryID Int , @Add_Date DateTime , @UpdateUser varchar(50)
As 

Insert Into SalProfessionToCategory ( ProfessionCode , SalCategoryID , Add_Date , UpdateUser )
Values ( @ProfessionCode , @SalCategoryID , @Add_Date , @UpdateUser )

Select @@IDENTITY;

--EXEC [Healthservices].[dbo].[rpc_AddProfessionToCategory] @ProfessionCode, @SalCategoryID


GO

GRANT EXEC ON rpc_InsertSalProfessionToCategory TO PUBLIC

GO