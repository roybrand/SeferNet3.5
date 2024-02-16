IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptStatus')
	BEGIN
		DROP  Procedure  rpc_getDeptStatus
	END

GO

CREATE Procedure dbo.rpc_getDeptStatus
	(
		@deptCode int
	)

AS

SELECT
DS.Status,
statusDescription,
FromDate,
ToDate

FROM DeptStatus as DS
INNER JOIN DIC_ActivityStatus ON DS.Status = DIC_ActivityStatus.status
WHERE deptCode = @deptCode
ORDER BY StatusID

GO

GRANT EXEC ON rpc_getDeptStatus TO PUBLIC

GO

