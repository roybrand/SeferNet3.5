IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_getUnitTypesByName]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[rpc_getUnitTypesByName]
GO



/* The procedure check if the unit type has subUnitTypes, if yes it returns 
   the unit types according to the subUnitType aggrement types(isCommunity,isMushlam,isHospital).
   If the unit type has no subUnitTypes, it returns the unit types according to
   the DefaultSubUnitTypeCode aggrement types.
 */
CREATE Procedure [dbo].[rpc_getUnitTypesByName]
	(
		@SearchString varchar(50),
		@isCommunity bit,
		@isMushlam bit,
		@isHospital bit
	)

AS

SELECT UnitTypeCode, UnitTypeName FROM
(
	SELECT
	UnitTypeCode, UnitTypeName, showOrder = 0
	FROM UnitType
	WHERE UnitTypeName like @SearchString + '%'
	AND IsActive = 1
	and
	(
		UnitTypeCode in
		(
			select UT.UnitTypeCode from UnitType UT
			join subUnitType SUT on UT.UnitTypeCode = SUT.UnitTypeCode
			join DIC_SubUnitTypes dSUT on SUT.subUnitTypeCode = dSUT.subUnitTypeCode
			where UT.UnitTypeName like @SearchString + '%'
			and(@isCommunity = 1 and dSUT.IsCommunity = 1
				or @isMushlam = 1 and  dSUT.isMushlam = 1
				or @isHospital = 1 and dSUT.IsHospitals = 1)
			
		)
		or
		(	-- Looking for the DefaultSubUnitTypeCode
			UnitTypeCode in
			(
				select UT.UnitTypeCode from UnitType UT
				join DIC_SubUnitTypes dSUT on UT.DefaultSubUnitTypeCode = dSUT.subUnitTypeCode
				where UT.UnitTypeName like @SearchString + '%'
				and(@isCommunity = 1 and dSUT.IsCommunity = 1
					or @isMushlam = 1 and  dSUT.isMushlam = 1
					or @isHospital = 1 and dSUT.IsHospitals = 1)
			)
		)
	)
				
	UNION
	
	SELECT
	UnitTypeCode, UnitTypeName, showOrder = 1
	FROM UnitType
	WHERE (UnitTypeName like '%' + @SearchString + '%' AND UnitTypeName NOT like @SearchString + '%')
	AND IsActive = 1
	and
	(
		UnitTypeCode in
		(
			select UT.UnitTypeCode from UnitType UT
			join subUnitType SUT on UT.UnitTypeCode = SUT.UnitTypeCode
			join DIC_SubUnitTypes dSUT on SUT.subUnitTypeCode = dSUT.subUnitTypeCode
			where UT.UnitTypeName like '%' + @SearchString + '%'
			and(@isCommunity = 1 and dSUT.IsCommunity = 1
				or @isMushlam = 1 and  dSUT.isMushlam = 1
				or @isHospital = 1 and dSUT.IsHospitals = 1)
		)
		or
		(
			UnitTypeCode in
			(
				select UT.UnitTypeCode from UnitType UT
				join DIC_SubUnitTypes dSUT on UT.DefaultSubUnitTypeCode = dSUT.subUnitTypeCode
				where UT.UnitTypeName like '%' + @SearchString + '%'
				and(@isCommunity = 1 and dSUT.IsCommunity = 1
					or @isMushlam = 1 and  dSUT.isMushlam = 1
					or @isHospital = 1 and dSUT.IsHospitals = 1)
			)
		)
	)
	
) as T1

ORDER BY showOrder, UnitTypeName
go

GRANT EXEC ON rpc_getUnitTypesByName TO PUBLIC
GRANT EXEC ON rpc_getUnitTypesByName TO [clalit\webuser]

GO


