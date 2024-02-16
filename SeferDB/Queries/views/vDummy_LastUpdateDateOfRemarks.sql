
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'vDummy_LastUpdateDateOfRemarks')
	BEGIN
		DROP  view  vDummy_LastUpdateDateOfRemarks
	END

GO


create VIEW [dbo].[vDummy_LastUpdateDateOfRemarks]
AS
SELECT     GETDATE() AS smalldatetime

GO


  
grant select on vDummy_LastUpdateDateOfRemarks to public 

go