IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetServiceByCode')
    BEGIN
	    DROP  Procedure  rpc_GetServiceByCode
    END

GO

CREATE Procedure [dbo].[rpc_GetServiceByCode]
(
	@serviceCode INT
)

AS


DECLARE @sectors VARCHAR(30)
DECLARE @categories VARCHAR(200)
DECLARE @categoriesCodes VARCHAR(200)


SET @sectors = ''
SET @categories = ''
SET @categoriesCodes = ''

-- Sectors *****
SELECT @sectors = @sectors + CONVERT(varchar,EmployeeSectorCode) + ','
FROM x_Services_EmployeeSector
WHERE ServiceCode = @serviceCode	
	

-- Categories *****
SELECT @categories = @categories + CONVERT(varchar,ServiceCategoryDescription) + ','
FROM x_ServiceCategories_Services xsc
INNER JOIN ServiceCategories sc on xsc.ServiceCategoryID = sc.ServiceCategoryID
WHERE ServiceCode = @serviceCode

IF LEN(@categories) > 0
	SET @categories = SUBSTRING(@categories,1 , LEN(@categories) - 1)

SELECT @categoriesCodes = @categoriesCodes + CONVERT(varchar,xsc.ServiceCategoryID) + ','
FROM x_ServiceCategories_Services xsc
INNER JOIN ServiceCategories sc on xsc.ServiceCategoryID = sc.ServiceCategoryID
WHERE ServiceCode = @serviceCode

IF LEN(@categoriesCodes) > 0
	SET @categoriesCodes = SUBSTRING(@categoriesCodes,1 , LEN(@categoriesCodes) - 1)


		
-- main select *****
SELECT ServiceCode, ServiceDescription, IsService, IsProfession, ISNULL(IsInMushlam,0) as IsInMushlam,
				ISNULL(IsInCommunity,0) as IsInCommunity, EnableExpert, 
				ISNULL(IsInHospitals,0) as IsInHospitals,  ShowExpert, @sectors  as Sectors, 
				@categories as Categories, @categoriesCodes as CategoriesCodes, SectorToShowWith
				,displayServiceInInternet as displayInInternet, RequiresQueueOrder
FROM [Services] s
WHERE ServiceCode = @serviceCode

GO               



GRANT EXEC ON rpc_GetServiceByCode TO PUBLIC

GO            
