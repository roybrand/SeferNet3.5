
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_GetProfessionsForInternet]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[rpc_GetProfessionsForInternet]
GO

CREATE Proc [dbo].[rpc_GetProfessionsForInternet] 
@ProfessionCode Int , @ProfessionDescription NVarChar(255)
As

SELECT	PDFI.[ProfessionCode] ,
		PDFI.[ProfessionDescriptionForInternet] ,
		P.[Description] As [ProfessionDescription] , 
		PDFI.ShowProfessionInInternet,
		PDFI.ProfessionExtraData
FROM ProfessionDetailsForInternet PDFI
Join [dbo].[MF_Professions] P On P.Code = PDFI.ProfessionCode 
Where	LogicalDelete = 0 And 
	  (	@ProfessionCode Is Null Or @ProfessionCode = 0 Or P.Code = @ProfessionCode ) And
	  (	@ProfessionDescription Is Null Or Len(@ProfessionDescription) = 0 Or 
		P.[Description] Like '%'+@ProfessionDescription+'%' Or PDFI.[ProfessionDescriptionForInternet] Like '%'+@ProfessionDescription+'%' )
Order By [Description]

GO

GRANT EXEC ON dbo.rpc_GetProfessionsForInternet TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_GetProfessionsForInternet TO [clalit\IntranetDev]
GO  
