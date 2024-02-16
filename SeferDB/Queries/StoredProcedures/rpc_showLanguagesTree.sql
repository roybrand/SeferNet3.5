IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_showLanguagesTree')
	BEGIN
		DROP  Procedure  rpc_showLanguagesTree
	END

GO

CREATE Procedure rpc_showLanguagesTree
AS

select languageCode  as 'Code', 
'' as 'Name' , 
languageDescription  as 'Gender', 
'1' as 'Sex',
'' as  'ParentCode' ,
'' as  'ChildCode' , 
'' as 'GroupByParent',
'' as 'relevantSector',
  isShow as 'ShowInInternet',
'' as 'sectorDescription'
from dbo.languages
where isShow=1 


union 

select languageCode  as 'Code', 
'' as 'Name' , 
languageDescription as 'Gender', 
'2' as 'Sex',
'' as  'ParentCode' ,
'' as  'ChildCode' , 
'' as 'GroupByParent',
'' as 'relevantSector',
  isShow as 'ShowInInternet',
'' as 'sectorDescription'
from dbo.languages
where isShow=0
order by Sex ,languageDescription asc

GO


GRANT EXEC ON rpc_showLanguagesTree TO PUBLIC

GO


