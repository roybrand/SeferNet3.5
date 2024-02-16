IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDIC_RemarkCategory')
	BEGIN
		DROP  Procedure  rpc_GetDIC_RemarkCategory
	END

GO

Create Procedure [dbo].[rpc_GetDIC_RemarkCategory]
AS

select 
	cat.RemarkCategoryID,
	cat.RemarkCategoryName
from DIC_RemarkCategory as cat

GO

GRANT EXEC ON rpc_GetDIC_RemarkCategory TO PUBLIC

GO


