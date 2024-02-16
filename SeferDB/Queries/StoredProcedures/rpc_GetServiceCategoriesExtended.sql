IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetServiceCategoriesExtended')
    BEGIN
	    DROP  Procedure  rpc_GetServiceCategoriesExtended
    END
GO

CREATE Procedure [dbo].[rpc_GetServiceCategoriesExtended]
(
	@serviceCode INT,
	@selectedValues VARCHAR(50)
)

AS


IF @selectedValues = '' 
	SET @selectedValues = null


SELECT DISTINCT sc.*, '' as 'IsProfession', CASE WHEN @selectedValues IS NULL THEN (CASE xsc.ServiceCode WHEN @serviceCode THEN 1 ELSE 0 END)
						                                ELSE CASE ISNULL(sel.IntField,0) WHEN 0 THEN 0 ELSE 1 END END as selected
FROM ServiceCategories sc
LEFT JOIN x_ServiceCategories_Services xsc ON sc.ServiceCategoryID = xsc.ServiceCategoryID 
			AND (xsc.ServiceCode = @serviceCode OR @serviceCode IS NULL)
LEFT JOIN (SELECT IntField FROM dbo.SplitString(@selectedValues)) as sel 
	ON sc.ServiceCategoryID = sel.IntField
ORDER BY Selected DESC, sc.ServiceCategoryDescription

SELECT popupType, popupTypeName, NameToShowInHebrew, SelectedElementsMaxNumber 
FROM SelectedElementsQuantityRestriction
WHERE popupType = 17
                
GO

GRANT EXEC ON dbo.rpc_GetServiceCategoriesExtended TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_GetServiceCategoriesExtended TO [clalit\IntranetDev]
GO           
