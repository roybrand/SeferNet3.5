IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptEvents')
	BEGIN
		DROP  Procedure  rpc_getDeptEvents
	END

GO

CREATE Procedure rpc_getDeptEvents
	(
		@deptCode int
	)

AS

SELECT 
DeptEventID,
DeptEvent.EventCode,
EventName,
EventDescription,
FromDate,
ToDate,
Remark,
'displayInInternet' = CAST(displayInInternet as bit),
RepeatingEvent

FROM DeptEvent
INNER JOIN DIC_Events ON DeptEvent.EventCode = DIC_Events.EventCode
WHERE deptCode = @deptCode
AND IsActive = 1

GO

GRANT EXEC ON rpc_getDeptEvents TO PUBLIC

GO

