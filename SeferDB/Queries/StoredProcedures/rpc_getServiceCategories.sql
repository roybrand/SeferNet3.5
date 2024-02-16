IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getServiceCategories')
	BEGIN
		DROP  Procedure  rpc_getServiceCategories
	END

GO


CREATE PROCEDURE [dbo].[rpc_getServiceCategories]
	@ServiceCategoryID int, 
	@ServiceCategoryDescription varchar(500),
	@SubCategoryFromTableMF51 int
AS
	SELECT DISTINCT
	ServiceCategories.ServiceCategoryID,
	ServiceCategoryDescription,
	SubCategoryFromTableMF51 as 'MF_Specialities051Code',
	MF_Specialities051.Description as 'SubCategoryFromTableMF51',
	MF_Specialities051.Code as 'SubCategoryCodeFromTableMF51',
	CASE  WHEN xSCS.ServiceCode is null THEN 0 ELSE 1 END as 'HasAttributedServices'
	FROM ServiceCategories
	LEFT JOIN x_ServiceCategories_Services xSCS ON ServiceCategories.ServiceCategoryID = xSCS.ServiceCategoryID
	LEFT JOIN MF_Specialities051 ON ServiceCategories.SubCategoryFromTableMF51 = MF_Specialities051.Code
	WHERE (@ServiceCategoryID is null OR ServiceCategories.ServiceCategoryID = @ServiceCategoryID)
	AND (@ServiceCategoryDescription is null OR ServiceCategoryDescription LIKE '%'+ @ServiceCategoryDescription +'%')
	AND (@SubCategoryFromTableMF51 is null OR SubCategoryFromTableMF51 = @SubCategoryFromTableMF51)

GO


GRANT EXEC ON rpc_getServiceCategories TO PUBLIC
GO