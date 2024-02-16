IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertRemarkCategory')
	BEGIN
		DROP  Procedure  rpc_InsertRemarkCategory
	END

GO

Create Procedure [dbo].[rpc_InsertRemarkCategory]
(
		@remarkCategoryName varchar(50)
	)
AS
	insert into
	DIC_RemarkCategory
	(RemarkCategoryName)
	values
	(@remarkCategoryName)
GO


GRANT EXEC ON rpc_InsertRemarkCategory TO PUBLIC

GO


