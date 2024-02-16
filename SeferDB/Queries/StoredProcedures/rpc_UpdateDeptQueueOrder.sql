IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateDeptQueueOrder')
	BEGIN
		DROP  Procedure  rpc_UpdateDeptQueueOrder
	END

GO

CREATE Procedure rpc_UpdateDeptQueueOrder
(
	@deptCode INT,
	@queueOrder INT
)

AS

UPDATE Dept
SET QueueOrder = @queueOrder
WHERE DeptCode = @deptCode


GO


GRANT EXEC ON rpc_UpdateDeptQueueOrder TO PUBLIC

GO


