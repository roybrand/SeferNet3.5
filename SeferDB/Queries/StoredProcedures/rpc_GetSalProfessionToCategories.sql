IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetSalProfessionToCategories')
	BEGIN
		DROP  Procedure  rpc_GetSalProfessionToCategories
	END

GO

CREATE Procedure [dbo].[rpc_GetSalProfessionToCategories]
@SalCategoryID Int , @ProfessionCode Int
As

Select	SPC.SalProfessionToCategoryID , SPC.ProfessionCode , SPC.SalCategoryID , SPC.Add_Date , 
		SC.SalCategoryDescription , P.[Description] As ProfessionDescription
From [SalProfessionToCategory] SPC
Join [SalCategories] SC ON SC.SalCategoryID = SPC.SalCategoryID
Join [MF_Professions] P On P.Code = SPC.ProfessionCode And P.LogicalDelete = 0
Where	( @SalCategoryID Is Null Or SPC.SalCategoryID = @SalCategoryID ) And
		( @ProfessionCode Is Null Or SPC.ProfessionCode = @ProfessionCode )

Go

GRANT EXEC ON rpc_GetSalProfessionToCategories TO PUBLIC

GO