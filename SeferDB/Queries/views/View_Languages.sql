IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_Languages')
	BEGIN
		DROP  view  View_Languages
	END

GO

create view [dbo].[View_Languages]
as
select languageCode,languageDescription from languages


GO




GO


