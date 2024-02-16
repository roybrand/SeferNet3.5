 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_RemarkTypeDeptAndServices')
	BEGIN
		DROP  view  View_RemarkTypeDeptAndServices
	END

GO

create view [dbo].View_RemarkTypeDeptAndServices
as
 
 select *
from RemarksTypes
where RemarksTypes.ID = 1 or RemarksTypes.ID  = 4

Go