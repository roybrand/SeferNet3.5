IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getObjectTypesExtended')
	BEGIN
		DROP  Procedure  dbo.rpc_getObjectTypesExtended
	END

GO

CREATE Procedure [dbo].[rpc_getObjectTypesExtended]
	(
		@SelectedCodes varchar(100)
	)

AS

SELECT
ReceptionHoursTypeID as ID,
ReceptionTypeDescription as Description,
'selected' = CASE IsNull(sel.IntField, 0) WHEN 0 THEN 0 ELSE 1 END
FROM
DIC_ReceptionHoursTypes
LEFT JOIN (SELECT IntField FROM dbo.SplitString(@SelectedCodes)) as sel ON DIC_ReceptionHoursTypes.ReceptionHoursTypeID = sel.IntField
ORDER BY OrderNumber

SELECT popupType, popupTypeName, NameToShowInHebrew, SelectedElementsMaxNumber 
FROM SelectedElementsQuantityRestriction
WHERE popupType = 11

GO

GO

GRANT EXEC ON dbo.rpc_getObjectTypesExtended TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_getObjectTypesExtended TO [clalit\IntranetDev]
GO



