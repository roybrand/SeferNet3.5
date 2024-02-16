IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getClinicByNameWithDeptCode_DistrictDepended')
	BEGIN
		DROP  Procedure  rpc_getClinicByNameWithDeptCode_DistrictDepended
	END

GO

CREATE Procedure dbo.rpc_getClinicByNameWithDeptCode_DistrictDepended
(
	@SearchString varchar(50),
	@DistrictCodes varchar(50)
)

AS

IF(@DistrictCodes = '')
	BEGIN SET @DistrictCodes = null END
	
SELECT deptCode, CAST(deptCode AS VARCHAR) + ' - ' + ClinicName  AS ClinicName
FROM
(	
Select deptCode, rtrim(ltrim(deptName)) as ClinicName, showOrder = 0
FROM dept
WHERE deptName like @SearchString + '%'
AND (@DistrictCodes is null
	OR
	districtCode in (SELECT IntField FROM dbo.SplitString(@DistrictCodes)))
AND status = 1

UNION

Select deptCode, DeptName AS ClinicName, showOrder = 1
FROM dept
WHERE (deptName like '%'+ @SearchString + '%' AND deptName NOT like @SearchString + '%')
AND (@DistrictCodes is null
	OR
	districtCode in (SELECT IntField FROM dbo.SplitString(@DistrictCodes)))
AND status = 1
) as T1
ORDER BY showOrder, ClinicName




GO


GRANT EXEC ON rpc_getClinicByNameWithDeptCode_DistrictDepended TO PUBLIC

GO


