IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getProfessionsForEmployee')
	BEGIN
		DROP  Procedure  rpc_getProfessionsForEmployee
	END

GO

CREATE Procedure rpc_getProfessionsForEmployee
	(
		@EmployeeID int
	)

AS

SELECT
[Services].ServiceCode as professionCode,
[Services].ServiceDescription as professionDescription,
ExpProfession,
'parentCode' = IsNull(parentCode, 0),
'groupCode' = [Services].ServiceCode,
'groupName' = [Services].ServiceDescription,
'IsAlreadyIn' = CASE IsNull(EmployeeServices.ServiceCode, 0) WHEN 0 THEN 0 ELSE 1 END

FROM [Services]
LEFT JOIN serviceParentChild ON [Services].ServiceCode = serviceParentChild.childCode
LEFT JOIN EmployeeServices ON [Services].ServiceCode = EmployeeServices.ServiceCode
	AND EmployeeServices.EmployeeID = @EmployeeID
WHERE parentCode is null

UNION

SELECT
[Services].ServiceCode as professionCode,
[Services].ServiceDescription as professionDescription, ExpProfession, 
'parentCode' = IsNull(parentCode, 0),
'groupCode' = parentCode,
'groupName' = [Services].ServiceDescription,
'IsAlreadyIn' = CASE IsNull(EmployeeServices.ServiceCode, 0) WHEN 0 THEN 0 ELSE 1 END

FROM [Services]
LEFT JOIN serviceParentChild ON [Services].ServiceCode = serviceParentChild.childCode
INNER JOIN [Services] as S ON serviceParentChild.parentCode = S.ServiceCode
LEFT JOIN EmployeeServices ON [Services].ServiceCode = EmployeeServices.ServiceCode
	AND EmployeeServices.EmployeeID = @EmployeeID
WHERE parentCode is NOT null

ORDER BY groupName, parentCode

GO

GRANT EXEC ON rpc_getProfessionsForEmployee TO PUBLIC

GO

