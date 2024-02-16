IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getProfessionsWithDependency')
	BEGIN
		DROP  Procedure  rpc_getProfessionsWithDependency
	END

GO

CREATE Procedure rpc_getProfessionsWithDependency

AS
SELECT professionCode, professionDescription, 'parentCode' = IsNull(parentCode, 0),
'groupCode' = professionCode,
'groupName' = professionDescription
FROM professions
LEFT JOIN professionsParentChild ON professions.professionCode = professionsParentChild.childCode
WHERE parentCode is null

UNION

SELECT professions.professionCode, professions.professionDescription, 'parentCode' = IsNull(parentCode, 0),
'groupCode' = parentCode,
'groupName' = P.professionDescription
FROM professions
LEFT JOIN professionsParentChild ON professions.professionCode = professionsParentChild.childCode
INNER JOIN professions as P ON professionsParentChild.parentCode = P.professionCode
WHERE parentCode is NOT null

ORDER BY groupName, parentCode

GO

GRANT EXEC ON rpc_getProfessionsWithDependency TO PUBLIC

GO

