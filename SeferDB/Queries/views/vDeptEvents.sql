
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'vDeptEvents')
	BEGIN
		DROP  view  vDeptEvents
	END

GO



create VIEW [dbo].[vDeptEvents]
AS
SELECT     dbo.DeptEvent.DeptEventID, dbo.DIC_Events.EventCode, dbo.DIC_Events.EventName, dbo.DIC_RegistrationStatus.registrationStatusDescription, dbo.DeptEvent.MeetingsNumber,
                          fromDate,toDate,
                          (SELECT     TOP (1) Date
                            FROM          dbo.DeptEventParticulars
                            WHERE      (DeptEventID = dbo.DeptEvent.DeptEventID)
                            ORDER BY Date) AS FirstEventDate, dbo.DeptEvent.deptCode
FROM         dbo.DeptEvent INNER JOIN
                      dbo.DIC_Events ON dbo.DeptEvent.EventCode = dbo.DIC_Events.EventCode INNER JOIN
                      dbo.DIC_RegistrationStatus ON dbo.DeptEvent.RegistrationStatus = dbo.DIC_RegistrationStatus.registrationStatus
					  where (DATEDIFF(dd, FromDate, GetDate()) >= 0 AND DATEDIFF(dd, ToDate, GetDate()) <= 0 )
GO


grant select on vDeptEvents to public 

go

