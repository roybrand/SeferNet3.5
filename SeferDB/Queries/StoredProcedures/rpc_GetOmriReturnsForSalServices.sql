IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetOmriReturnsForSalServices')
	BEGIN
		DROP  Procedure  rpc_GetOmriReturnsForSalServices
	END
GO

CREATE Proc [dbo].[rpc_GetOmriReturnsForSalServices]
@selectedOmriCodes VARCHAR(max)
As

SELECT ReturnCode
      ,ReturnDescription
      , -1 As ParentCategoryId 
	  , CASE IsNull(selectedProf.IntField, 0) WHEN 0 THEN 0 ELSE 1 END as 'selected' , 
	  3 as 'AgreementType'
FROM MF_OmriReturns536 p
Left JOIN (	SELECT IntField 
			FROM dbo.SplitString(@selectedOmriCodes)) As selectedProf ON p.ReturnCode = selectedProf.IntField
Where DelFlg = 0 And (AscriptionToCodeTariff > 0 And AscriptionToCodeTariff Is Not Null)

SELECT popupType, popupTypeName, NameToShowInHebrew, SelectedElementsMaxNumber 
FROM SelectedElementsQuantityRestriction
WHERE popupType = 23

GO

GRANT EXEC ON dbo.rpc_GetOmriReturnsForSalServices TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_GetOmriReturnsForSalServices TO [clalit\IntranetDev]
GO