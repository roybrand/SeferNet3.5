IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_showPositionsTree')
	BEGIN
		DROP  Procedure  rpc_showPositionsTree
	END

GO

CREATE Procedure dbo.rpc_showPositionsTree
AS

select positionCode as 'Code' , 
positionDescription as 'Name', 
gender as 'Sex', 
'Gender' = case 
when position.gender = 1 then 'זכר' else  'נקבה'
end ,
'' as  'ParentCode' ,
'' as  'ChildCode' , 
'' as 'GroupByParent' , 
relevantSector ,
useInSearches as 'isShow', 
IsActive,
EmployeeSector.EmployeeSectorDescription as 'sectorDescription'

from dbo.position
 
INNER JOIN  EmployeeSector ON position.relevantSector = EmployeeSector.EmployeeSectorCode
order by IsActive DESC, positionDescription

GO
GRANT EXEC ON dbo.rpc_showPositionsTree TO PUBLIC

GO
