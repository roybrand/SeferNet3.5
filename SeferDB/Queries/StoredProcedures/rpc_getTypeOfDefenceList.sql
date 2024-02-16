IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getTypeOfDefenceList')
	BEGIN
		DROP  Procedure  rpc_getTypeOfDefenceList
	END

GO

CREATE Procedure dbo.rpc_getTypeOfDefenceList

AS

SELECT 
TypeOfDefenceCode, TypeOfDefenceDefinition
FROM DIC_TypeOfDefence

ORDER BY TypeOfDefenceCode

GO

GRANT EXEC ON dbo.rpc_getTypeOfDefenceList TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_getTypeOfDefenceList TO [clalit\IntranetDev]
GO