IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteSalProfessionToCategory')
	BEGIN
		DROP  Procedure  rpc_DeleteSalProfessionToCategory
	END

GO

CREATE Procedure [dbo].[rpc_DeleteSalProfessionToCategory]
@SalProfessionToCategoryID Int
As

--DECLARE @ProfessionCode int 
--DECLARE @SalCategoryID int

--SELECT	@ProfessionCode = ProfessionCode, 
--		@SalCategoryID = SalCategoryID
--FROM SalProfessionToCategory
--WHERE SalProfessionToCategoryID = @SalProfessionToCategoryID

Delete From SalProfessionToCategory 
WHERE SalProfessionToCategoryID = @SalProfessionToCategoryID

--EXEC [Healthservices].[dbo].[rpc_DeleteProfessionToCategory] @ProfessionCode, @SalCategoryID
GO

GRANT EXEC ON rpc_DeleteSalProfessionToCategory TO PUBLIC

GO