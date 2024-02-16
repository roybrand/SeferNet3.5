 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_Events')
	BEGIN
		DROP  View View_Events
	END
GO

create VIEW [dbo].[View_Events]
AS
SELECT     TOP (100) PERCENT EventCode, EventName
FROM         dbo.DIC_Events
WHERE IsActive = 1
ORDER BY EventName

GO
 