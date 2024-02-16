IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetUnitTypes')
	BEGIN
		DROP  Procedure  rpc_GetUnitTypes
	END

GO

CREATE Procedure dbo.rpc_GetUnitTypes
	
AS


SELECT UnitTypeCode
      ,UnitTypeName
      ,ShowInInternet
      ,AllowQueueOrder
      ,IsActive
      ,SubUnitTypeName as DefaultSubUnit
      ,CategoryName,
      'Related' = dbo.fun_GetSubUnitsNames(UnitTypeCode)
	FROM UnitType,DIC_DeptCategory,DIC_SubUnitTypes
	 where UnitType.CategoryID=DIC_DeptCategory.CategoryID
	 AND UnitType.DefaultSubUnitTypeCode=DIC_SubUnitTypes.subUnitTypeCode
GO

GRANT EXEC ON rpc_GetUnitTypes TO PUBLIC

GO