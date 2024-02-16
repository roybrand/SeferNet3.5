IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getServiceCategoriesByName')
    BEGIN
	    DROP  Procedure  rpc_getServiceCategoriesByName
    END

GO

CREATE Procedure dbo.rpc_getServiceCategoriesByName
(
	@prefixText VARCHAR(10)
)

AS


SELECT ServiceCategoryID, ServiceCategoryDescription, 1 as showOrder
FROM ServiceCategories
WHERE ServiceCategoryDescription like @prefixText + '%' 

UNION 

SELECT ServiceCategoryID, ServiceCategoryDescription, 2 as showOrder
FROM ServiceCategories
WHERE ServiceCategoryDescription like  '%' + @prefixText + '%' and ServiceCategoryDescription not like @prefixText + '%'

ORDER BY showOrder, ServiceCategoryDescription


                
GO


GRANT EXEC ON rpc_getServiceCategoriesByName TO PUBLIC

GO            
