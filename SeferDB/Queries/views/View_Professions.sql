IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_Professions')
	BEGIN
		DROP  view  View_Professions
	END

GO

create view [dbo].[View_Professions]
as
select ServiceCode as professionCode, ServiceDescription as professionDescription 
from dbo.[Services]
WHERE [Services].IsProfession = 1


GO



