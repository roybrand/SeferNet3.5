IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetGroupsForSalServices')
	BEGIN
		DROP  Procedure  rpc_GetGroupsForSalServices
	END
GO

CREATE Proc [dbo].[rpc_GetGroupsForSalServices]
@selectedGroups VARCHAR(max)
As

Select	tg.* , 
		CASE IsNull(selectedGroups.IntField, 0) WHEN 0 THEN 0 ELSE 1 END as 'selected' , 
		3 as 'AgreementType'
From MF_TariffGroups212 tg
Left JOIN (	SELECT IntField 
			FROM dbo.SplitString(@selectedGroups)) As selectedGroups ON tg.GroupCode = selectedGroups.IntField
Where tg.IsCanceled = 0 And tg.GroupSubCode = 0
Order By GroupDesc 

SELECT popupType, popupTypeName, NameToShowInHebrew, SelectedElementsMaxNumber 
FROM SelectedElementsQuantityRestriction
WHERE popupType = 21

GO

GRANT EXEC ON dbo.rpc_GetGroupsForSalServices TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_GetGroupsForSalServices TO [clalit\IntranetDev]
GO
