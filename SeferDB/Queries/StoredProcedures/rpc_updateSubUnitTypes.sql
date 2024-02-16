IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateSubUnitTypes')
	BEGIN
		DROP  Procedure  rpc_updateSubUnitTypes
	END

GO

CREATE Procedure rpc_updateSubUnitTypes
(  
	@code int, 	
	@parentCode int, 	
	@name varchar(100),
	@userName varchar(100)		
)
as  

UPDATE [subUnitType]       
      SET  [subUnitTypeName] = @name ,
		   [UpdateUser]=@userName,
      		[UpdateDate] = getdate()	
       WHERE [subUnitTypeCode] =@code  and [UnitTypeCode]=@parentCode

GO


GRANT EXEC ON rpc_updateSubUnitTypes TO PUBLIC

GO

