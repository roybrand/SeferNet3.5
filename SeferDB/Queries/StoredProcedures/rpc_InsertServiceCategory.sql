IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertServiceCategory')
	BEGIN
		DROP  Procedure  rpc_InsertServiceCategory
	END
GO

CREATE PROCEDURE [dbo].[rpc_InsertServiceCategory]

	@ServiceCategoryDescription varchar(500),
	@SubCategoryFromTableMF51 int,
	@AttributedServices varchar(500),
	@ServiceCategoryID int OUT
AS
	INSERT INTO ServiceCategories
	(ServiceCategoryDescription, SubCategoryFromTableMF51)
	VALUES
	(@ServiceCategoryDescription, @SubCategoryFromTableMF51)
	
	SET @ServiceCategoryID = @@IDENTITY

	INSERT INTO x_ServiceCategories_Services
	(ServiceCategoryID, ServiceCode)
	SELECT @ServiceCategoryID, vals.IntField
	FROM dbo.SplitString(@AttributedServices) AS vals

GO

GRANT EXEC ON rpc_InsertServiceCategory TO PUBLIC
GO