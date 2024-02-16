IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptEventByID')
	BEGIN
		DROP  Procedure  rpc_getDeptEventByID
	END

GO

CREATE Procedure rpc_getDeptEventByID
	(
		@DeptEventID int
	)

AS

SELECT
DeptEventID, DeptCode, DeptEvent.EventCode, EventName, EventDescription, MeetingsNumber,
'RepeatingEvent' = CAST(RepeatingEvent as bit), FromDate, ToDate, 
RegistrationStatus, PayOrder, CommonPrice, MemberPrice, FullMemberPrice,
TargetPopulation, Remark, 
'displayInInternet' = CAST(displayInInternet as bit)

FROM DeptEvent
INNER JOIN DIC_Events ON DeptEvent.EventCode = DIC_Events.EventCode
WHERE DeptEventID = @DeptEventID
GO

GRANT EXEC ON rpc_getDeptEventByID TO PUBLIC

GO

