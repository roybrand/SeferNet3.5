
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[View_SubUnitTypes]'))
DROP VIEW [dbo].[View_SubUnitTypes]
GO


CREATE VIEW [dbo].[View_SubUnitTypes]
AS
SELECT  TOP (100) PERCENT subUnitType.subUnitTypeCode, subUnitType.UnitTypeCode, DIC_SubUnitTypes.subUnitTypeName,
			DIC_SubUnitTypes.IsCommunity, DIC_SubUnitTypes.IsMushlam, DIC_SubUnitTypes.IsHospitals,
			subUnitType.DefaultReceptionHoursTypeID
FROM subUnitType 
INNER JOIN DIC_SubUnitTypes ON subUnitType.subUnitTypeCode = DIC_SubUnitTypes.subUnitTypeCode
ORDER BY subUnitType.UnitTypeCode, DIC_SubUnitTypes.subUnitTypeName

GO

grant select on View_SubUnitTypes to public 

go