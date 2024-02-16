-- =============================================
--	Owner : Internet Team
-- =============================================
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetSubUnitTypesForPharmacies')
	BEGIN
		DROP  Procedure  [rpc_GetSubUnitTypesForPharmacies]
	END

GO

CREATE Procedure [dbo].[rpc_GetSubUnitTypesForPharmacies]
(
	@SubUnitTypes varchar(max)
)
 
AS
	declare @Sql varchar(max)   

	select @Sql = 'SELECT SubUnitTypeCode, SubUnitTypeName FROM DIC_SubUnitTypes
					WHERE     SubUnitTypeCode In (' + @SubUnitTypes + ') ORDER BY SubUnitTypeCode'

	exec(@Sql) 

GO

GRANT EXEC ON [rpc_GetSubUnitTypesForPharmacies] TO PUBLIC

GO

