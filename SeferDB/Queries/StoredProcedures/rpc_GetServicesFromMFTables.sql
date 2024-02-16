IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetServicesFromMFTables')
    BEGIN
	    DROP  Procedure  rpc_GetServicesFromMFTables
    END

GO

CREATE Procedure [dbo].[rpc_GetServicesFromMFTables]
(
	@prefixText VARCHAR(30),
	@tableNums VARCHAR(50)
)

AS

SELECT ProfessionCode as serviceCode, ProfessionDesc as Description, 
	CASE IsNull(s.ServiceCode,-1) WHEN -1 THEN 0
										 ELSE 1 END AS Selected 
INTO #t601
FROM MF_zimun601 t601
LEFT JOIN [Services] s ON t601.ProfessionCode = s.serviceCode
WHERE (t601.ProfessionDesc like '%' + @prefixText + '%' OR @prefixText IS NULL)
AND Delfl = 0
ORDER BY Description


SELECT TatHitmahutCode as serviceCode, TatHitmahutDesc as Description, 
	CASE IsNull(s.ServiceCode,-1) WHEN -1 THEN 0
										 ELSE 1 END AS Selected 
INTO #t606
FROM MF_TatHitmahutZimun606 t606
LEFT JOIN [Services] s ON t606.TatHitmahutCode = s.serviceCode
WHERE (t606.TatHitmahutDesc like '%' + @prefixText + '%' OR @prefixText IS NULL)
AND Delfl = 0
ORDER BY Description


IF CHARINDEX('606',@tableNums, 1) = 0
	SELECT * FROM #t601
ELSE
	IF CHARINDEX('601',@tableNums, 1) = 0 
		SELECT * FROM #t606
	ELSE
		SELECT * 
		FROM #t601
		UNION
		SELECT * 
		FROM #t606
		ORDER BY Description
 GO 


GRANT EXEC ON rpc_GetServicesFromMFTables TO PUBLIC

GO            
