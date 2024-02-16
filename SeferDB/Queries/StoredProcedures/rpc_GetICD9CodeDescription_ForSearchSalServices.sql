IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetICD9CodeDescription_ForSearchSalServices')
	BEGIN
		DROP  Procedure  rpc_GetICD9CodeDescription_ForSearchSalServices
	END
GO

Create Proc [dbo].[rpc_GetICD9CodeDescription_ForSearchSalServices]
@ICD9Code VarChar(50)
As

Select Distinct DiagnosisID , STUFF (
							(	SELECT ' ' + Name 
								FROM MF_ICDDiagnosis236 icdName
								Where icd1.DiagnosisID = icdName.DiagnosisID
								Order By icdName.LineNumber
								FOR XML Path('')), 1, 1, '' ) Name
From MF_ICDDiagnosis236 icd1
Where CancelVersionNumber = 0 and icd1.DiagnosisID = @ICD9Code

Go

GRANT EXEC ON rpc_GetICD9CodeDescription_ForSearchSalServices TO PUBLIC
GO
