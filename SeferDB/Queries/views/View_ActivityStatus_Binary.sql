IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_ActivityStatus_Binary')
	BEGIN
		DROP  View View_ActivityStatus_Binary
	END
GO

CREATE  VIEW dbo.View_ActivityStatus_Binary
AS

SELECT status
      ,statusDescription
  FROM DIC_ActivityStatus
  where status < 2

GO


grant select on View_ActivityStatus_Binary to public 

go