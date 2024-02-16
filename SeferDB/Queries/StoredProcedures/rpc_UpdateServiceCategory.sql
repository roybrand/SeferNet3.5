IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateServiceCategory')
	BEGIN
		DROP  Procedure  rpc_UpdateServiceCategory
	END
GO

CREATE PROCEDURE [dbo].[rpc_UpdateServiceCategory]
	@ServiceCategoryID int,
	@ServiceCategoryDescription varchar(500),
	@AttributedServices varchar(500),
	@SubCategoryFromTableMF51 int

AS
	UPDATE ServiceCategories
	SET ServiceCategoryDescription = @ServiceCategoryDescription,
	SubCategoryFromTableMF51 = @SubCategoryFromTableMF51
	WHERE ServiceCategoryID = @ServiceCategoryID

	DELETE FROM x_ServiceCategories_Services
	WHERE ServiceCategoryID = @ServiceCategoryID

	INSERT INTO x_ServiceCategories_Services
	(ServiceCategoryID, ServiceCode)
	SELECT @ServiceCategoryID, vals.IntField
	FROM dbo.SplitString(@AttributedServices) AS vals

GO

GRANT EXEC ON rpc_UpdateServiceCategory TO PUBLIC
GO