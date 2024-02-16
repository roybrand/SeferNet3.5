IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetChangeTypes')
	BEGIN
		DROP  Procedure  rpc_GetChangeTypes
	END
GO

CREATE Proc [dbo].[rpc_GetChangeTypes]
@selectedChangeTypes VARCHAR(max)
As

SELECT ChangeTypeID as ChangeTypeCode, ChangeTypeDescription,
	CASE IsNull(selectedTypes.ItemID, '0') WHEN '0' THEN 0 ELSE 1 END as 'selected'  
FROM DIC_LogChangeType
LEFT JOIN (	SELECT ItemID FROM dbo.rfn_SplitStringValuesToStr(@selectedChangeTypes)) As selectedTypes 
	ON DIC_LogChangeType.ChangeTypeID = selectedTypes.ItemID

GO

GRANT EXEC ON dbo.rpc_GetChangeTypes TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_GetChangeTypes TO [clalit\IntranetDev]
GO