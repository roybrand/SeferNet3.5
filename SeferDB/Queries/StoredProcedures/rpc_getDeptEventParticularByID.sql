IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptEventParticularByID')
	BEGIN
		DROP  Procedure  rpc_getDeptEventParticularByID
	END

GO

CREATE Procedure rpc_getDeptEventParticularByID
	(
		@DeptEventParticularsID int
	)

AS

SELECT DeptEventParticularsID, DeptEventID, OrderNumber, ReceptionDayName as 'Day', Date, OpeningHour, Duration
FROM DeptEventParticulars
LEFT JOIN DIC_ReceptionDays ON DeptEventParticulars.Day = DIC_ReceptionDays.ReceptionDayCode
WHERE DeptEventParticularsID = @DeptEventParticularsID
GO

GRANT EXEC ON rpc_getDeptEventParticularByID TO PUBLIC

GO

