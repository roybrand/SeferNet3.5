IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_Parent_Professions')
	BEGIN
		DROP  View View_Parent_Professions
	END
GO

CREATE VIEW [dbo].[View_Parent_Professions]
AS
SELECT  DISTINCT   ServiceCategories.ServiceCategoryID as professionCode, ServiceCategories.ServiceCategoryDescription as professionDescription
FROM       ServiceCategories 
INNER JOIN x_ServiceCategories_Services ON ServiceCategories.ServiceCategoryID = x_ServiceCategories_Services.ServiceCategoryID
INNER JOIN [Services] ON x_ServiceCategories_Services.ServiceCode = [Services].ServiceCode
WHERE   
[Services].IsProfession = 1
GO 