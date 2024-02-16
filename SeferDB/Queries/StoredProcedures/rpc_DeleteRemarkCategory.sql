IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteRemarkCategory')
	BEGIN
		DROP  Procedure  rpc_DeleteRemarkCategory
	END

GO

Create Procedure [dbo].[rpc_DeleteRemarkCategory]
	(
		@RemarkCategoryID int
	)

AS
delete DIC_RemarkCategory
where RemarkCategoryID = @RemarkCategoryID

GO

GRANT EXEC ON rpc_DeleteRemarkCategory TO PUBLIC

GO


