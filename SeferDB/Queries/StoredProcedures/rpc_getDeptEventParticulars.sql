IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptEventParticulars')
	BEGIN
		DROP  Procedure  rpc_getDeptEventParticulars
	END

GO

CREATE Procedure rpc_getDeptEventParticulars
	(
		@DeptEventID int
	)

AS

SELECT DeptEventParticularsID, OrderNumber, ReceptionDayName as 'Day', Date, OpeningHour, Duration
FROM DeptEventParticulars
LEFT JOIN DIC_ReceptionDays ON DeptEventParticulars.Day = DIC_ReceptionDays.ReceptionDayCode
WHERE DeptEventID = @DeptEventID
GO

GRANT EXEC ON rpc_getDeptEventParticulars TO PUBLIC

GO

