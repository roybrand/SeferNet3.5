IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateSalProfessionToCategory')
	BEGIN
		DROP  Procedure  rpc_UpdateSalProfessionToCategory
	END

GO

CREATE Procedure [dbo].[rpc_UpdateSalProfessionToCategory]
@SalProfessionToCategoryID Int , @SalCategoryID Int , @ProfessionCode Int , @UpdateUser varchar(50)
As

--DECLARE @OldSalCategoryID int
--DECLARE @OldProfessionCode int

--SELECT @OldProfessionCode = ProfessionCode, @OldSalCategoryID = SalCategoryID
--FROM SalProfessionToCategory
--WHERE SalProfessionToCategoryID = @SalProfessionToCategoryID

UPDATE SalProfessionToCategory 
SET SalCategoryID = @SalCategoryID , ProfessionCode = @ProfessionCode , 
	@UpdateUser = UpdateUser
WHERE SalProfessionToCategoryID = @SalProfessionToCategoryID

--IF EXISTS (	SELECT * FROM [Healthservices].[dbo].[ProfessionToCategory] 
--			WHERE ProfessionCode = @OldProfessionCode AND CategoryID = @OldSalCategoryID)
--	Update [Healthservices].[dbo].[ProfessionToCategory]
--	SET ProfessionCode = @ProfessionCode
--	WHERE CategoryID = @OldSalCategoryID
--	AND ProfessionCode = @OldProfessionCode

--IF NOT EXISTS (	SELECT * FROM [Healthservices].[dbo].[ProfessionToCategory] 
--			WHERE ProfessionCode = @ProfessionCode AND CategoryID = @SalProfessionToCategoryID)
--	EXEC [Healthservices].[dbo].[rpc_AddProfessionToCategory] @ProfessionCode, 	@SalProfessionToCategoryID

GO

GRANT EXEC ON rpc_UpdateSalProfessionToCategory TO PUBLIC
GO
