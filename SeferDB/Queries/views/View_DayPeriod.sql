
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_DayPeriod')
	BEGIN
		DROP  View View_DayPeriod
	END
GO

create VIEW [dbo].[View_DayPeriod]
AS
SELECT     FromHour + ', ' + ToHour AS 'period', Description
FROM         dbo.DIC_DayPeriod

GO
 