IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetProfessionsForSalServices')
	BEGIN
		DROP  Procedure  rpc_GetProfessionsForSalServices
	END

GO

CREATE Procedure  [dbo].[rpc_GetProfessionsForSalServices] 
@selectedProfessions VARCHAR(max)
As

SELECT [ID]
      ,[Code]
      ,[Description]
      ,[DescriptionRev]
      ,[LogicalDelete]
      , -1 As ParentCategoryId 
	  , CASE IsNull(selectedProf.IntField, 0) WHEN 0 THEN 0 ELSE 1 END as 'selected' , 
	  3 as 'AgreementType'
FROM [dbo].[MF_Professions] p
Left JOIN (	SELECT IntField 
			FROM dbo.SplitString(@selectedProfessions)) As selectedProf ON p.Code = selectedProf.IntField
Where LogicalDelete = 0
Order By [Description]

SELECT popupType, popupTypeName, NameToShowInHebrew, SelectedElementsMaxNumber 
FROM SelectedElementsQuantityRestriction
WHERE popupType = 20

GO

GRANT EXEC ON dbo.rpc_GetProfessionsForSalServices TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_GetProfessionsForSalServices TO [clalit\IntranetDev]
GO


