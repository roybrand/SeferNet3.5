IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDefencePolicyList')
	BEGIN
		DROP  Procedure  rpc_getDefencePolicyList
	END

GO

CREATE Procedure dbo.rpc_getDefencePolicyList

AS

SELECT 
DefencePolicyCode, DefencePolicyDefinition
FROM DIC_DefencePolicy

ORDER BY DefencePolicyCode

GO

GRANT EXEC ON dbo.rpc_getDefencePolicyList TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_getDefencePolicyList TO [clalit\IntranetDev]
GO