IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getSubUnitTypes')
	BEGIN
		DROP  Procedure  rpc_getSubUnitTypes
	END

GO

CREATE Procedure rpc_getSubUnitTypes
(
	@UnitTypeCode int
)

AS
  
SELECT distinct d.subUnitTypeCode, 
d.subUnitTypeName ,
'selected' = CASE when 
(select count (subUnitTypeCode) 
from dbo.subUnitType 
where UnitTypeCode = @UnitTypeCode and subUnitTypeCode=d.subUnitTypeCode) > 0
 THEN 0 ELSE 1 
 END
FROM [DIC_SubUnitTypes] as d
left JOIN subUnitType ON d.subUnitTypeCode = subUnitType.subUnitTypeCode  
ORDER BY [subUnitTypeCode]


GO


GRANT EXEC ON rpc_getSubUnitTypes TO PUBLIC

GO


