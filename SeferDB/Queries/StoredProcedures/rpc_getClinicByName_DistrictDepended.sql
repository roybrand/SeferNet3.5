IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getClinicByName_DistrictDepended')
	BEGIN
		DROP  Procedure  rpc_getClinicByName_DistrictDepended
	END

GO

CREATE Procedure dbo.rpc_getClinicByName_DistrictDepended
	(
	@SearchString varchar(50),
	@DistrictCodes varchar(50),
	@status tinyint,
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
) as T1
ORDER BY showOrder, ClinicName

GO

GRANT EXEC ON dbo.rpc_getClinicByName_DistrictDepended TO PUBLIC

GO
