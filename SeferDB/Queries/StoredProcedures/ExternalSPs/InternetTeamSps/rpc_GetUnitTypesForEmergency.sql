-- =============================================
--	Owner : Internet Team
-- =============================================
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetUnitTypesForEmergency')
	BEGIN
		DROP  Procedure  [rpc_GetUnitTypesForEmergency]
	END

GO

CREATE Procedure [dbo].[rpc_GetUnitTypesForEmergency]
(
	@UnitTypes varchar(max)
)
 
AS
	declare @Sql varchar(max)   
	
	select @Sql = 'SELECT UnitTypeCode, UnitTypeName FROM UnitType
					WHERE     UnitTypeCode In (' + @UnitTypes + ') ORDER BY UnitTypeCode'
	
	exec(@Sql) 

GO

GRANT EXEC ON [rpc_GetUnitTypesForEmergency] TO PUBLIC

GO

