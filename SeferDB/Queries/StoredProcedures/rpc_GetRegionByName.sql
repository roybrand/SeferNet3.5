IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetRegionByName')
	BEGIN
		DROP  Procedure  rpc_GetRegionByName
	END

GO

CREATE Procedure dbo.rpc_GetRegionByName
(
	@regionName VARCHAR(50),
	@searchExtended BIT
)

AS

SELECT ProfessionCode as RegionCode, ProfessionDescription as RegionName
FROM Professions
WHERE (ProfessionDescription LIKE @regionName + '%') OR (ProfessionDescription LIKE '%' + @regionName + '%' AND @searchExtended = 1)

UNION

SELECT ServiceCode as RegionCode, ServiceDescription as RegionName
FROM Service
WHERE (ServiceDescription LIKE @regionName + '%') OR (ServiceDescription LIKE '%' + @regionName + '%' AND @searchExtended = 1)

ORDER BY RegionName


GO


GRANT EXEC ON rpc_GetRegionByName TO PUBLIC

GO


