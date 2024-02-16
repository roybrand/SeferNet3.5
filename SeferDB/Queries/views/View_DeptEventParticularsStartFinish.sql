IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_DeptEventParticularsStartFinish')
	BEGIN
		DROP  View View_DeptEventParticularsStartFinish
	END
GO

CREATE VIEW [dbo].View_DeptEventParticularsStartFinish
AS
SELECT 
DeptEventParticulars.Date,
DeptEventParticulars.Day,
DeptEventParticulars.OpeningHour,
DeptEventParticulars.ClosingHour,
--DeptEventParticulars.Duration,
totalHours = [dbo].rfn_TimeInterval_float(DeptEventParticulars.openingHour, DeptEventParticulars.closingHour),
DeptEventParticulars.DeptEventID,
StartDate = (select min(DEParticulars.Date) from DeptEventParticulars as DEParticulars 
								where DEParticulars.DeptEventID = DeptEventParticulars.DeptEventID),
								
FinishDate = (select max(DEParticulars.Date) from DeptEventParticulars as DEParticulars 
			where DEParticulars.DeptEventID = DeptEventParticulars.DeptEventID)								
								
FROM         
DeptEventParticulars
where DeptEventParticulars.Date  = (select min(DEParticulars.Date) from DeptEventParticulars as DEParticulars 
								where DEParticulars.DeptEventID = DeptEventParticulars.DeptEventID)

or DeptEventParticulars.Date  = (select max(DEParticulars.Date) from DeptEventParticulars as DEParticulars 
								where DEParticulars.DeptEventID = DeptEventParticulars.DeptEventID)
 

GO



