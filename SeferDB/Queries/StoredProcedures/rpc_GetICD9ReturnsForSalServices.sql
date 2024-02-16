IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetICD9ReturnsForSalService')
	BEGIN
		DROP  Procedure  rpc_GetICD9ReturnsForSalService
	END
GO

CREATE Proc [dbo].[rpc_GetICD9ReturnsForSalService]
@selectedICD9Codes VARCHAR(max)
As

SELECT Distinct DiagnosisID as ICD9ReturnCode, Name as ICD9ReturnDescription,
CASE IsNull(selectedICD9.ItemID, '0') WHEN '0' THEN 0 ELSE 1 END as 'selected'  
--,CASE WHEN SALS.ServiceCode is null THEN 0 ELSE 1 END as HasService
FROM (
	Select Distinct DiagnosisID , STUFF (
								(	SELECT ' ' + Name 
									FROM MF_ICDDiagnosis236 icdName
									Where icd1.DiagnosisID = icdName.DiagnosisID
									Order By icdName.LineNumber
									FOR XML Path('')), 1, 1, '' ) Name
	From MF_ICDDiagnosis236 ICD1

	Where ICD1.CancelVersionNumber = 0 
) T
 JOIN MF_XrefInsuranceICD435 ICD435 on T.DiagnosisID = ICD435.DiagnosisCode
 JOIN MF_SalServices386 SALS on ICD435.HospitalServiceCode = SALS.ServiceCode
	and SALS.IsCanceled = 0
 LEFT JOIN (	SELECT ItemID FROM dbo.rfn_SplitStringValuesToStr(@selectedICD9Codes)) As selectedICD9 
	ON T.DiagnosisID = selectedICD9.ItemID
WHERE SALS.ServiceCode is not null

SELECT popupType, popupTypeName, NameToShowInHebrew, SelectedElementsMaxNumber 
FROM SelectedElementsQuantityRestriction
WHERE popupType = 26

GO

GRANT EXEC ON dbo.rpc_GetICD9ReturnsForSalService TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_GetICD9ReturnsForSalService TO [clalit\IntranetDev]
GO
