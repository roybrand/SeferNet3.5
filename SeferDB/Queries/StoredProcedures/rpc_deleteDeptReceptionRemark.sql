IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_deleteDeptReceptionRemark')
	BEGIN
		DROP  Procedure  rpc_deleteDeptReceptionRemark
	END

GO

CREATE Procedure rpc_deleteDeptReceptionRemark
	(
		@DeptReceptionRemarkID int
	)

AS

DELETE FROM DeptReceptionRemarks
WHERE DeptReceptionRemarkID = @DeptReceptionRemarkID

GO

GRANT EXEC ON rpc_deleteDeptReceptionRemark TO PUBLIC

GO

