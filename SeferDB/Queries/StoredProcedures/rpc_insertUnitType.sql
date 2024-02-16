IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_insertUnitType]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[rpc_insertUnitType]
GO

CREATE PROCEDURE [dbo].[rpc_insertUnitType]
(
	@UnitTypeCode int ,
	@UnitTypeName varchar(100), 
	@AllowQueueOrder bit,
	@ShowInInternet bit,			
	@defaultSubUnitTypeCode int,
	@UpdateUser varchar(50),
	@CategoryID tinyint,
	@ErrCode int OUTPUT	   
)


AS

INSERT INTO [dbo].[UnitType]
		   ([UnitTypeCode],
			[UnitTypeName],
			[ShowInInternet],
			[AllowQueueOrder],
			[defaultSubUnitTypeCode],
			[UpdateUser],
			[UpdateDate],
			[CategoryID])
	 VALUES
		   (@UnitTypeCode,
			@UnitTypeName ,                   
			@ShowInInternet,
			@AllowQueueOrder,  
			@defaultSubUnitTypeCode,
			@UpdateUser,
			getDate(),
			@CategoryID)

SET @ErrCode = @@Error

GO

GRANT EXEC ON rpc_insertUnitType TO PUBLIC
GO