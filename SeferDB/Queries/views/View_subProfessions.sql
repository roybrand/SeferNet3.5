IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_subProfessions')
	BEGIN
		DROP  view  View_subProfessions
	END
GO 

CREATE VIEW [dbo].[View_subProfessions]
AS
SELECT     TOP (100) PERCENT dbo.[Services].ServiceCode AS subProfessionCode, ServiceCategories.ServiceCategoryID AS professionCode, 
                      dbo.[Services].ServiceDescription AS subProfessionDescription, ServiceCategories.ServiceCategoryDescription AS groupName
FROM        dbo.[Services] 
INNER JOIN x_ServiceCategories_Services ON [Services].ServiceCode = x_ServiceCategories_Services.ServiceCode
INNER JOIN ServiceCategories ON x_ServiceCategories_Services.ServiceCategoryID = ServiceCategories.ServiceCategoryID
					
WHERE [Services].IsProfession = 1 
ORDER BY 'groupName', professionCode

GO