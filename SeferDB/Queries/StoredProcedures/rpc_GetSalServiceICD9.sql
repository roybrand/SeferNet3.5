IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetSalServiceICD9')
	BEGIN
		DROP  Procedure  rpc_GetSalServiceICD9
	END

GO

CREATE PROCEDURE [dbo].[rpc_GetSalServiceICD9]
@ServiceCode Int
As

SELECT GroupCode, CASE WHEN LineNumber < 2 THEN ICDCode ELSE '--' END as ICDCode, ICDDesc, LineNumber,ICDCode as ICDCode_ToOrder FROM
(
SELECT TOP 100 PERCENT GroupCode, ICDCode, ICDDesc, LineNumber FROM
(
	Select Distinct XI.GroupCode, DiagnosisCode As ICDCode, ICD9Codes.Name As ICDDesc, 0 as LineNumber
	From MF_XrefInsuranceICD435 XI
	Join (	Select Distinct DiagnosisID , STUFF ((SELECT ' ' + Name 
								  FROM MF_ICDDiagnosis236 icdName
								  Where icd1.DiagnosisID = icdName.DiagnosisID 
									and  icdName.CancelVersionNumber = '00'
								  Order By icdName.LineNumber
								  FOR XML Path('')), 1, 1, '' ) As Name
			From MF_ICDDiagnosis236 icd1 
			Where icd1.CancelVersionNumber = '00'
			) ICD9Codes On ICD9Codes.DiagnosisID = XI.DiagnosisCode
	Where XI.HospitalServiceCode = @ServiceCode
	and XI.ModishRecord = 1
	and XI.Cancel = 0	
	and( XI.ToDate >= GetDate() OR XI.ToDate is null)	

	UNION

	SELECT Distinct t435.GroupCode, t436.DiagnosisCode As ICDCode, t236.Name as ICDDesc, t236.LineNumber
	FROM MF_XrefInsuranceICDGroup436 t436
	INNER JOIN MF_XrefInsuranceICD435 t435
		ON t436.GroupNumber = t435.GroupCode
	INNER JOIN MF_ICDDiagnosis236 t236
		ON t436.DiagnosisCode = t236.DiagnosisID
	WHERE t435.HospitalServiceCode = @ServiceCode
	and t436.fromDate <= GetDate() and (t435.todate >= getdate() or t435.todate is null) 
	and t435.type = 'ק' and t436.cancel = 0 and t435.cancel = 0 
	and t236.CancelVersionNumber = 0 
	) T
ORDER BY GroupCode, ICDCode, LineNumber
) TT
ORDER BY GroupCode, ICDCode_ToOrder, LineNumber

Go

GRANT EXEC ON rpc_GetSalServiceICD9 TO PUBLIC

GO