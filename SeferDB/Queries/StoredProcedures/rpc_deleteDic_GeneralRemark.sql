IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteDic_GeneralRemark')
	BEGIN
		DROP  Procedure  rpc_deleteDic_GeneralRemark
	END

GO

Create Procedure [dbo].[rpc_deleteDic_GeneralRemark]
	(
		@remarkID int
	)

AS
delete DIC_GeneralRemarks
where remarkID = @remarkID



GO


GRANT EXEC ON rpc_deleteDic_GeneralRemark TO PUBLIC

GO


