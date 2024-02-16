IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_showServicesTree')
	BEGIN
		DROP  Procedure  rpc_showServicesTree
	END

GO
create PROCEDURE [dbo].[rpc_showServicesTree]
AS

SELECT
service.serviceCode as 'Code',
service.serviceDescription as 'Name',
'GroupByParent' = service.serviceCode,
'ParentCode' = case
when (select count(childCode) from serviceParentChild where parentCode =serviceCode )=0 then null
when parentCode <> serviceCode  then  null else service.serviceCode
end ,

'ParentCodeName' = service.serviceDescription, 
'ChildCode' = case
when parentCode <> serviceCode then service.serviceCode else null
end ,
'' as 'SectorDescription' ,
'' as 'ShowExpert' ,
'' as 'relevantSector',
'' as 'sectorDescription',
'isSingle' = case
when (select count(childCode) from serviceParentChild where parentCode =serviceCode )=0 then '1'
when parentCode <> serviceCode  then  '1' else '0'
end
FROM service
LEFT JOIN serviceParentChild ON  service.serviceCode = serviceParentChild.childCode
WHERE parentCode is null

UNION

SELECT
service.serviceCode as 'Code',
service.serviceDescription,
'GroupByParent' = parentCode,
'ParentCode' = case
when (select count(childCode) from serviceParentChild where parentCode =serviceCode )=0 then null
when parentCode <> serviceCode  then  null else service.serviceCode
end ,
'ParentCodeName' =  
(select service.serviceDescription from service where serviceCode= parentCode)
,
'ChildCode' = case
when parentCode <> serviceCode then service.serviceCode else null
end,
'' as 'SectorDescription' ,
'' as 'ShowExpert' ,
'' as 'relevantSector',
'' as 'sectorDescription',
'0'  as 'isSingle'
FROM service
LEFT JOIN serviceParentChild ON service.serviceCode = dbo.serviceParentChild.childCode
WHERE parentCode is not null
ORDER BY isSingle ,GroupByParent, ChildCode 


Go
GRANT EXEC ON rpc_showServicesTree TO PUBLIC
go 