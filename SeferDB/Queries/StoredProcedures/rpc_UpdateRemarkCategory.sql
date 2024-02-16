IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateRemarkCategory')
	BEGIN
		DROP  Procedure  rpc_UpdateRemarkCategory
	END
GO

Create Procedure [dbo].[rpc_UpdateRemarkCategory]
(
	@RemarkCategoryID int,
	@RemarkCategoryName varchar(50)
)
AS
	update
	DIC_RemarkCategory
	set 
	RemarkCategoryName = @RemarkCategoryName
	where RemarkCategoryID = @RemarkCategoryID
	
GO

GRANT EXEC ON rpc_UpdateRemarkCategory TO PUBLIC

GO


