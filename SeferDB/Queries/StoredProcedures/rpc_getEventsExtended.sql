IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEventsExtended')
	BEGIN
		DROP  Procedure  dbo.rpc_getEventsExtended
	END

GO

CREATE Procedure [dbo].[rpc_getEventsExtended]
	(
		@SelectedCodes varchar(100)
	)

AS

SELECT
EventCode,
EventName,
'selected' = CASE IsNull(sel.IntField, 0) WHEN 0 THEN 0 ELSE 1 END
FROM
DIC_Events
LEFT JOIN (SELECT IntField FROM dbo.SplitString(@SelectedCodes)) as sel ON DIC_Events.EventCode = sel.IntField
ORDER BY EventCode

SELECT popupType, popupTypeName, NameToShowInHebrew, SelectedElementsMaxNumber 
FROM SelectedElementsQuantityRestriction
WHERE popupType = 14

GO


GRANT EXEC ON dbo.rpc_getEventsExtended TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_getEventsExtended TO [clalit\IntranetDev]
GO

