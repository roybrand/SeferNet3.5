IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getProfessionsByName')
	BEGIN
		DROP  Procedure  rpc_getProfessionsByName
	END

GO

CREATE Procedure dbo.rpc_getProfessionsByName
	(
		@SearchString varchar(50), 
		@sectorCode INT = -1
	)

AS

SELECT professionCode, professionDescription FROM
(
	SELECT
	p.professionCode,
	p.professionDescription,
	showOrder = 0
	FROM professions p
	INNER JOIN X_Profession_SectorCode xps ON p.ProfessionCode = xps.ProfessionCode
	WHERE professionDescription like @SearchString + '%'
	AND (xps.EmployeeSectorCode = @sectorCode OR @sectorCode = -1)
	
	UNION
	
	SELECT
	p.professionCode,
	p.professionDescription,
	showOrder = 1
	FROM professions p
	INNER JOIN X_Profession_SectorCode xps ON p.ProfessionCode = xps.ProfessionCode
	WHERE professionDescription like '%' + @SearchString + '%'
	AND professionDescription NOT like @SearchString + '%'
	AND (xps.EmployeeSectorCode = @sectorCode OR @sectorCode = -1)
	
) as T1

ORDER BY showOrder, professionDescription

GO


GRANT EXEC ON rpc_getProfessionsByName TO PUBLIC

GO


