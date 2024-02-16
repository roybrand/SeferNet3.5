IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_showProfessionsTree')
	BEGIN
		DROP  Procedure  rpc_showProfessionsTree
	END

GO


/****** Object:  StoredProcedure [dbo].[rpc_showProfessionsTree]    Script Date: 11/08/2009 13:54:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
create PROCEDURE [dbo].[rpc_showProfessionsTree]
AS


SELECT
professions.professionCode as 'Code',
professions.professionDescription as 'Name',
'GroupByParent' = professions.professionCode,
'ParentCode' = case
when (select count(childCode) from professionsParentChild where parentCode = professions.professionCode )=0 then null
when parentCode <> professions.professionCode  then  null else professions.professionCode
end ,

'ParentCodeName' = 
( select professions.professionDescription where professions.professionCode = professions.professionCode)
, 
'ChildCode' = case
when parentCode <> professions.professionCode then professions.professionCode else null
end ,
'SectorDescription' = dbo.fun_GetSectorsForProfession(professions.ProfessionCode),
professions.ShowExpert ,
'isSingle' = case
when (select count(childCode) from professionsParentChild where parentCode = professions.professionCode )=0 then '1'
when parentCode <> professions.professionCode  then  '1' else '0'
end
FROM dbo.professions
LEFT JOIN professionsParentChild ON  professions.professionCode = professionsParentChild.childCode
WHERE parentCode is null

UNION

SELECT
professions.professionCode as 'Code',
professions.professionDescription,
'GroupByParent' = parentCode,
'ParentCode' = case
when (select count(childCode) from professionsParentChild where parentCode = professions.professionCode )=0 then null
when parentCode <> professions.professionCode  then  null else professions.professionCode
end ,
'ParentCodeName' = 
(select professions.professionDescription from dbo.professions where professions.professionCode = parentCode)
,
'ChildCode' = case
when parentCode <> professions.professionCode then professions.professionCode else null
end,
'SectorDescription' = dbo.fun_GetSectorsForProfession(professions.ProfessionCode),
professions.ShowExpert ,
'0'  as 'isSingle'
FROM dbo.professions
LEFT JOIN professionsParentChild ON professions.professionCode = dbo.professionsParentChild.childCode
WHERE parentCode is not null

ORDER BY isSingle ,GroupByParent, ChildCode


Go
GRANT EXEC ON rpc_showProfessionsTree TO PUBLIC