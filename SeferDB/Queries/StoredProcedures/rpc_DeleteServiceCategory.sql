IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteServiceCategory')
	BEGIN
		DROP  Procedure  rpc_DeleteServiceCategory
	END
GO

CREATE PROCEDURE [dbo].[rpc_DeleteServiceCategory]
	@ServiceCategoryID int

AS
	DELETE FROM ServiceCategories
	WHERE ServiceCategoryID = @ServiceCategoryID
GO

GRANT EXEC ON rpc_DeleteServiceCategory TO PUBLIC
GO
