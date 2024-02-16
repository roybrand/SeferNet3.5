IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteDeptRemark')
	BEGIN
		DROP  Procedure  rpc_DeleteDeptRemark
	END

GO

CREATE Procedure dbo.rpc_DeleteDeptRemark
	(
	@DeptRemarkId INT
	)

AS

delete from DeptRemarks where DeptRemarks.DeptRemarkID = @DeptRemarkId


GO

GRANT EXEC ON dbo.rpc_DeleteDeptRemark TO PUBLIC

GO

