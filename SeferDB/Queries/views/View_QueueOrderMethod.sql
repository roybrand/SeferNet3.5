IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_QueueOrderMethod')
	BEGIN
		DROP  view  View_QueueOrderMethod
	END
GO 
 
create VIEW [dbo].[View_QueueOrderMethod]
AS
SELECT     QueueOrderMethod, QueueOrderMethodDescription
FROM         dbo.DIC_QueueOrderMethod

GO