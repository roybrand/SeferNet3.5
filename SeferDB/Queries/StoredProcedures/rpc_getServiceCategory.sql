IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getServiceCategory')
	BEGIN
		DROP  Procedure  rpc_getServiceCategory
	END
GO

CREATE PROCEDURE [dbo].[rpc_getServiceCategory]
	@ServiceCategoryID int

AS
	SELECT ServiceCategoryID,
	ServiceCategoryDescription,
	SubCategoryFromTableMF51 as 'MF_Specialities051Code',
	MF_Specialities051.Description as 'MF_Specialities051Description'
	FROM ServiceCategories
	LEFT JOIN MF_Specialities051 ON ServiceCategories.SubCategoryFromTableMF51 = MF_Specialities051.Code
	WHERE ServiceCategoryID = @ServiceCategoryID

	SELECT SC.ServiceCategoryID,
	[Services].ServiceCode,
	[Services].ServiceDescription
	FROM ServiceCategories SC
	INNER JOIN x_ServiceCategories_Services xSCS ON SC.ServiceCategoryID = xSCS.ServiceCategoryID
	INNER JOIN [Services] ON xSCS.ServiceCode = [Services].ServiceCode
	WHERE SC.ServiceCategoryID = @ServiceCategoryID
GO


GRANT EXEC ON rpc_getServiceCategory TO PUBLIC
GO