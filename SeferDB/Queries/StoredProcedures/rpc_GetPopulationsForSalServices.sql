IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetPopulationsForSalServices')
	BEGIN
		DROP  Procedure  rpc_GetPopulationsForSalServices
	END

GO

Create Proc [dbo].[rpc_GetPopulationsForSalServices]
@selectedPopulations VARCHAR(max)
As

Select	p.* , 
		CASE IsNull(selectedPopulations.IntField, 0) WHEN 0 THEN 0 ELSE 1 END as 'selected' , 
		3 as 'AgreementType'
From MF_Populations213 p
Left JOIN (	SELECT IntField 
			FROM dbo.SplitString(@selectedPopulations)) As selectedPopulations ON p.PopulationsCode = selectedPopulations.IntField
Where p.IsCanceled = 0 And p.SubPopulationsCode = 0

SELECT popupType, popupTypeName, NameToShowInHebrew, SelectedElementsMaxNumber 
FROM SelectedElementsQuantityRestriction
WHERE popupType = 22

Go


GRANT EXEC ON dbo.rpc_GetPopulationsForSalServices TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_GetPopulationsForSalServices TO [clalit\IntranetDev]
GO
