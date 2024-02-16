IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeeProfessions')
	BEGIN
		DROP  Procedure  rpc_getEmployeeProfessions
	END

GO

CREATE Procedure dbo.rpc_getEmployeeProfessions
( 
	@EmployeeID bigint
)

AS

SELECT
EmployeeServices.EmployeeID,
EmployeeServices.ServiceCode as 'professionCode',
[Services].ServiceDescription as professionDescription,
EmployeeServices.mainProfession,
'expProfession' = CASE IsNull(EmployeeServices.expProfession, 0) WHEN 0 THEN NULL ELSE 1 END,
'parentCode' = 0,
'groupCode' = ServiceCategories.ServiceCategoryID,
'groupName' = ServiceCategories.ServiceCategoryDescription

FROM EmployeeServices
INNER JOIN [Services] ON EmployeeServices.ServiceCode = [Services].ServiceCode
INNER JOIN x_ServiceCategories_Services ON [Services].ServiceCode = x_ServiceCategories_Services.ServiceCode
INNER JOIN ServiceCategories ON x_ServiceCategories_Services.ServiceCategoryID = ServiceCategories.ServiceCategoryID
WHERE EmployeeID = @EmployeeID
AND [Services].IsProfession = 1

ORDER BY groupName, parentCode

GO

GRANT EXEC ON rpc_getEmployeeProfessions TO PUBLIC
GO