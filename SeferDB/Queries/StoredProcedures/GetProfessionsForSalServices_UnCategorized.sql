IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'GetProfessionsForSalServices_UnCategorized')
	BEGIN
		DROP  Procedure  [dbo].GetProfessionsForSalServices_UnCategorized
	END

GO

CREATE Procedure [dbo].[GetProfessionsForSalServices_UnCategorized]
(
		@salCategoryId INT = null,
		@professionCode INT = null
)

AS

SELECT [ID]
      ,[Code]
      ,[Description]
      ,[DescriptionRev]
      ,[LogicalDelete]
      , -1 As ParentCategoryId 
	  , 3 as 'AgreementType'
FROM [MF_Professions] p
WHERE p.LogicalDelete = 0 And p.[Code] Not In 
	( Select ProfessionCode From SalProfessionToCategory 
	  WHERE @salCategoryId is null OR SalProfessionToCategory.SalCategoryID <> @salCategoryId )
OR (@professionCode is NOT null AND p.Code = @ProfessionCode)
Order By [Description]
	
GO


GRANT EXEC ON GetProfessionsForSalServices_UnCategorized TO PUBLIC
GO
