IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getClinicByName_District_City_ClinicType_Status_Depended')
	BEGIN
		DROP  Procedure  rpc_getClinicByName_District_City_ClinicType_Status_Depended
	END

GO

CREATE Procedure dbo.rpc_getClinicByName_District_City_ClinicType_Status_Depended
	(
	@SearchString varchar(50),
	@DistrictCodes varchar(50),
	@status tinyint,
	@cityCode int, 
	@clinicType varchar(500),
	@isCommunity bit,
	@isMushlam bit,
	@isHospital bit
	)

AS
IF(@DistrictCodes = '')
	BEGIN SET @DistrictCodes = null END
	
SELECT deptCode, ClinicName FROM
(	
Select deptCode, rtrim(ltrim(deptName)) as ClinicName, showOrder = 0
FROM dept
WHERE deptName like @SearchString + '%'
AND (@DistrictCodes is null
	OR
	districtCode in (SELECT IntField FROM dbo.SplitString(@DistrictCodes)))
AND status >= @status
and(@isCommunity = 1 and dept.IsCommunity = 1
			or @isMushlam = 1 and  dept.isMushlam = 1
			or @isHospital = 1 and dept.isHospital = 1)
and (@cityCode = 0 OR dept.cityCode = @cityCode)
and (@clinicType = '' OR dept.typeUnitCode in (SELECT ItemID FROM [dbo].[rfn_SplitStringValues](@clinicType)))

UNION

Select deptCode, rtrim(ltrim(deptName)) as ClinicName, showOrder = 1
FROM dept
WHERE (deptName like '%'+ @SearchString + '%' AND deptName NOT like @SearchString + '%')
AND (@DistrictCodes is null
	OR
	districtCode in (SELECT IntField FROM dbo.SplitString(@DistrictCodes)))
AND status >= @status
and(@isCommunity = 1 and dept.IsCommunity = 1
			or @isMushlam = 1 and  dept.isMushlam = 1
			or @isHospital = 1 and dept.isHospital = 1)
and (@cityCode = 0 OR dept.cityCode = @cityCode)
and (@clinicType = '' OR dept.typeUnitCode in (SELECT ItemID FROM [dbo].[rfn_SplitStringValues](@clinicType)))
			
) as T1
ORDER BY showOrder, ClinicName

GO

GRANT EXEC ON rpc_getClinicByName_District_City_ClinicType_Status_Depended TO [clalit\webuser]
GO

GRANT EXEC ON rpc_getClinicByName_District_City_ClinicType_Status_Depended TO [clalit\IntranetDev]
GO
