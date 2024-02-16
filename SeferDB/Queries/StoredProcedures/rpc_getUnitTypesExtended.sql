IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getUnitTypesExtended')
	BEGIN
		DROP  Procedure  rpc_getUnitTypesExtended
	END

GO

/* The procedure check if the unit type has subUnitTypes, if yes it returns 
   the unit types according to the subUnitType aggrement types(isCommunity,isMushlam,isHospital).
   If the unit type has no subUnitTypes, it returns the unit types according to
   the DefaultSubUnitTypeCode aggrement types.
 */

ALTER Procedure [dbo].[rpc_getUnitTypesExtended]
	(
		@SelectedUnitTypeCodes varchar(100),
		@isCommunity bit,
		@isMushlam bit,
		@isHospital bit
	)

AS

SELECT
UnitTypeCode,
UnitTypeName,
'selected' = CASE IsNull(sel.IntField, 0) WHEN 0 THEN 0 ELSE 1 END
FROM UnitType
LEFT JOIN (SELECT IntField FROM dbo.SplitString(@SelectedUnitTypeCodes)) as sel ON UnitType.UnitTypeCode = sel.IntField
WHERE IsActive = 1
and
	(
		UnitTypeCode in
		(
			select UT.UnitTypeCode from UnitType UT
			join subUnitType SUT on UT.UnitTypeCode = SUT.UnitTypeCode
			join DIC_SubUnitTypes dSUT on SUT.subUnitTypeCode = dSUT.subUnitTypeCode
			where
			(@isCommunity = 1 and dSUT.IsCommunity = 1
				or @isMushlam = 1 and  dSUT.isMushlam = 1
				or @isHospital = 1 and dSUT.IsHospitals = 1)
			
		)
		or
		(	-- Looking for the DefaultSubUnitTypeCode
			UnitTypeCode in
			(
				select UT.UnitTypeCode from UnitType UT
				join DIC_SubUnitTypes dSUT on UT.DefaultSubUnitTypeCode = dSUT.subUnitTypeCode
				where
				(@isCommunity = 1 and dSUT.IsCommunity = 1
					or @isMushlam = 1 and  dSUT.isMushlam = 1
					or @isHospital = 1 and dSUT.IsHospitals = 1)
			)
		)
	)
ORDER BY UnitTypeName

SELECT popupType, popupTypeName, NameToShowInHebrew, SelectedElementsMaxNumber 
FROM SelectedElementsQuantityRestriction
WHERE popupType = 6

GO

GRANT EXEC ON rpc_getUnitTypesExtended TO PUBLIC

GO

