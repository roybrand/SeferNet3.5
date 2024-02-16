IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_showTreeViewUnitTypes')
	BEGIN
		DROP  Procedure  rpc_showTreeViewUnitTypes
	END

GO

CREATE Procedure dbo.rpc_showTreeViewUnitTypes
AS

SELECT
subUnitType. subUnitTypeCode as 'Code',
dic2.subUnitTypeName as 'Name',
'0' as 'Sex',
'' as 'Gender',
'GroupByParent' = subUnitType.UnitTypeCode ,
'ParentCode' = 
	case
	when (select count(subUnitTypeCode) from dbo.subUnitType where subUnitType.UnitTypeCode = UnitType.UnitTypeCode) > 0 then null
	else -1
	end
,
'ParentCodeName' =  
(select UnitType.UnitTypeName from UnitType where UnitType.UnitTypeCode=subUnitType.UnitTypeCode ),
subUnitType. subUnitTypeCode as 'ChildCode' ,ShowInInternet , AllowQueueOrder,
'' as 'relevantSector',
'' as 'sectorDescription',
'0' as 'isSingle',
null as DefaultSubUnitTypeCode,
null as DefaultSubUnitType,
IsActive
FROM dbo.UnitType
INNER JOIN DIC_SubUnitTypes dic1 on UnitType.defaultSubUnitTypeCode = dic1.subUnitTypeCode
LEFT JOIN subUnitType ON  UnitType.UnitTypeCode = subUnitType.UnitTypeCode
INNER JOIN DIC_SubUnitTypes dic2 on subUnitType.subUnitTypeCode = dic2.subUnitTypeCode
WHERE subUnitType.UnitTypeCode is not null

union 

select distinct  UnitType.UnitTypeCode as 'Code',
UnitType.UnitTypeName as 'Name',
'0' as 'Sex',
'' as 'Gender',
UnitType.UnitTypeCode as 'GroupByParent',
UnitType.UnitTypeCode as 'ParentCode' ,
UnitType.UnitTypeName as 'ParentCodeName',
 'ChildCode'
= case
when (select count(subUnitTypeCode) from dbo.subUnitType where subUnitType.UnitTypeCode = UnitType.UnitTypeCode) > 0 then null
else -1
end,ShowInInternet , AllowQueueOrder,
'' as 'relevantSector',
'' as 'sectorDescription',
'0' as 'isSingle',
dic.SubUnitTypeCode as DefaultSubUnitTypeCode,
dic.SubUnitTypeName as DefaultSubUnitType,
IsActive

FROM dbo.UnitType
INNER JOIN subUnitType ON UnitType.UnitTypeCode = subUnitType.UnitTypeCode
INNER JOIN DIC_SubUnitTypes dic on UnitType.defaultSubUnitTypeCode = dic.subUnitTypeCode
WHERE subUnitType.UnitTypeCode is not  null


union 

select UnitType.UnitTypeCode as 'Code',
UnitType.UnitTypeName as 'Name',
'1' as 'Sex',
'' as 'Gender',
UnitType.UnitTypeCode as 'GroupByParent',
'ParentCode' = case
when (select count(subUnitTypeCode) from dbo.subUnitType where subUnitType.UnitTypeCode = UnitType.UnitTypeCode) > 0 then '*'
else null
end,
UnitType.UnitTypeName 'ParentCodeName',
'ChildCode' 
= case
when (select count(subUnitTypeCode) from dbo.subUnitType where subUnitType.UnitTypeCode = UnitType.UnitTypeCode) > 0 then '*'
else null
end,ShowInInternet , AllowQueueOrder,
'' as 'relevantSector',
'' as 'sectorDescription',
'1' as 'isSingle',
dic.SubUnitTypeCode as DefaultSubUnitTypeCode,
dic.SubUnitTypeName as DefaultSubUnitType,
IsActive
FROM dbo.UnitType
INNER JOIN DIC_SubUnitTypes dic on UnitType.defaultSubUnitTypeCode = dic.subUnitTypeCode
LEFT JOIN subUnitType ON UnitType.UnitTypeCode= subUnitType.UnitTypeCode
WHERE subUnitType.UnitTypeCode is  null
ORDER BY 
isSingle ,
GroupByParent, 
ChildCode






GO


GRANT EXEC ON dbo.rpc_showTreeViewUnitTypes TO PUBLIC

GO


