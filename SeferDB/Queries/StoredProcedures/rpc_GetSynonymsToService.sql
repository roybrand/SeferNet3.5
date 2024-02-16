
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetSynonymsToService')
    BEGIN
	    DROP  Procedure  rpc_GetSynonymsToService
    END

GO

CREATE Procedure dbo.rpc_GetSynonymsToService
(
	@serviceCode INT,
	@serviceName VARCHAR(50),
	@Synonym VARCHAR(50),
	@Categorie int
)

AS

SELECT syn.SynonymID, ser.ServiceCode, rtrim(ltrim(ser.ServiceDescription)) as ServiceDescription,
rtrim(ltrim(syn.ServiceSynonym)) as ServiceSynonym, rtrim(ltrim(sc.ServiceCategoryDescription)) as ServiceCategoryDescription
FROM ServiceSynonym syn
INNER JOIN [Services] ser ON syn.ServiceCode = ser.ServiceCode
join x_ServiceCategories_Services xSS on ser.ServiceCode = xSS.ServiceCode
join ServiceCategories sc on xSS.ServiceCategoryID = sc.ServiceCategoryID
WHERE (ser.ServiceCode = @serviceCode OR @serviceCode IS NULL)
AND (ser.ServiceDescription like '%' + @serviceName + '%' OR @serviceName IS NULL)
AND(syn.ServiceSynonym like '%' + @Synonym + '%' OR @Synonym IS NULL)
and (xSS.ServiceCategoryID = @Categorie OR @Categorie is null)
ORDER BY ser.ServiceCode

                
GO


GRANT EXEC ON rpc_GetSynonymsToService TO PUBLIC

GO            
