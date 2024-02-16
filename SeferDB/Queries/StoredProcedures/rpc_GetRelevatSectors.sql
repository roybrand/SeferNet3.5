IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetRelevatSectors')
	BEGIN
		DROP  Procedure  rpc_GetRelevatSectors
	END

GO


CREATE PROCEDURE dbo.rpc_GetRelevatSectors
AS

SELECT EmployeeSectorCode , EmployeeSectorDescription  
FROM dbo.EmployeeSector
WHERE RelevantForProfession = 1
ORDER BY EmployeeSectorDescription


GO


GRANT EXEC ON rpc_GetRelevatSectors TO PUBLIC

GO




 