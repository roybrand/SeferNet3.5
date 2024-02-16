IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertSubUnitTypeCodeToUnitTypeCode')
	BEGIN
		DROP  Procedure  rpc_insertSubUnitTypeCodeToUnitTypeCode
	END

GO

CREATE Procedure dbo.rpc_insertSubUnitTypeCodeToUnitTypeCode

	(
		@subUnitTypeCode int ,
		@unitTypeCode int ,
		@updateUser varchar(50)		
	)


AS


IF NOT EXISTS 
(
	SELECT *
	FROM subUnitType
	WHERE  subUnitTypeCode = @subUnitTypeCode
	AND UnitTypeCode = @unitTypeCode
)

INSERT INTO [subUnitType]
           ([subUnitTypeCode]
           ,[UnitTypeCode]
         
           ,[UpdateDate]
           ,[UpdateUser])
     VALUES
           (
			@subUnitTypeCode
           ,@unitTypeCode           
           ,getDate()
           ,@updateUser)

GO


GRANT EXEC ON rpc_insertSubUnitTypeCodeToUnitTypeCode TO PUBLIC

GO


