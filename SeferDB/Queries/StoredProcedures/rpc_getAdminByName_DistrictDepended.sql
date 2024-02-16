IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getAdminByName_DistrictDepended')
	BEGIN
		DROP  Procedure  rpc_getAdminByName_DistrictDepended
	END

GO

CREATE Procedure rpc_getAdminByName_DistrictDepended
(
	@SearchString varchar(50),
	@DistrictCodes varchar(50)
)

AS

IF(@DistrictCodes = '')
	BEGIN SET @DistrictCodes = null END

SELECT deptCode, deptName FROM
(	
	SELECT 
	dept.deptCode, rtrim(ltrim(deptName)) as deptName, showOrder = 0 
	FROM dept 
	WHERE deptType = 2
	AND (@DistrictCodes is null
		OR
		districtCode in (SELECT IntField FROM dbo.SplitString(@DistrictCodes)))
	AND deptName like @SearchString + '%'
	AND status = 1

	UNION

	SELECT 
	dept.deptCode, rtrim(ltrim(deptName)) as deptName, showOrder = 1 
	FROM dept 
	WHERE deptType = 2
	AND (@DistrictCodes is null
		OR
		districtCode in (SELECT IntField FROM dbo.SplitString(@DistrictCodes)))
	AND (deptName like '%' + @SearchString + '%' and deptName NOT like @SearchString + '%')
	AND status = 1
) as T
ORDER BY showOrder, deptName


GO

GRANT EXEC ON rpc_getAdminByName_DistrictDepended TO PUBLIC

GO

