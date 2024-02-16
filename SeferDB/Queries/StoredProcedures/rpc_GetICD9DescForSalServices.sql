IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetICD9DescForSalServices')
	BEGIN
		DROP  Procedure  rpc_GetICD9DescForSalServices
	END
GO

Create Proc [dbo].[rpc_GetICD9DescForSalServices]
(
	@SearchString varchar(50)
)

AS

Select Distinct DiagnosisID , STUFF ((SELECT ' ' + Name 
                              FROM MF_ICDDiagnosis236 icdName
                              Where icd1.DiagnosisID = icdName.DiagnosisID
                              Order By icdName.LineNumber
                              FOR XML Path('')), 1, 1, '' ) Name
From MF_ICDDiagnosis236 icd1
Where CancelVersionNumber = 0 and Name like '%'+ @SearchString +'%'

GO

GRANT EXEC ON rpc_GetICD9DescForSalServices TO PUBLIC
GO
