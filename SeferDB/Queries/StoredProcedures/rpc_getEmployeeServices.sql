IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeeServices')
	BEGIN
		DROP  Procedure  rpc_getEmployeeServices
	END

GO

CREATE Procedure dbo.rpc_getEmployeeServices
	(
		@EmployeeID bigint
	)

AS

SELECT DISTINCT
--EmployeeServices.EmployeeID,
EmployeeServices.serviceCode,
[Services].ServiceDescription
--'parentCode' = 0,
--'groupCode' = ServiceCategories.ServiceCategoryID,
--'groupName' = ServiceCategories.ServiceCategoryDescription

FROM EmployeeServices
INNER JOIN [Services] ON EmployeeServices.serviceCode = [Services].ServiceCode
LEFT JOIN x_ServiceCategories_Services ON [Services].ServiceCode = x_ServiceCategories_Services.ServiceCode
LEFT JOIN ServiceCategories ON x_ServiceCategories_Services.ServiceCategoryID = ServiceCategories.ServiceCategoryID
WHERE EmployeeID = @EmployeeID
AND [Services].IsService = 1

GO

GRANT EXEC ON rpc_getEmployeeServices TO PUBLIC

GO

