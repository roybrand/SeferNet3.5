IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_findDistrictsByName')
	BEGIN
		DROP  Procedure  dbo.rpc_findDistrictsByName
	END

GO

CREATE Procedure dbo.rpc_findDistrictsByName
	(
		@SearchString varchar(50),
		@unitCodes varchar(20)
	)

AS

SELECT deptCode as districtCode, DistrictName FROM
(	
Select deptCode, rtrim(ltrim(deptName)) as DistrictName, showOrder = 0,
'typeUnitCode' = case typeUnitCode 
	when 65 then 0
	when 60 then 1
	end

FROM dept
WHERE typeUnitCode in (SELECT IntField FROM dbo.SplitString(@unitCodes))
AND deptName like @SearchString + '%'
and status = 1

UNION

Select deptCode, rtrim(ltrim(deptName)) as DistrictName, showOrder = 1,
'typeUnitCode' = case typeUnitCode 
	when 65 then 0
	when 60 then 1
	end
FROM dept
WHERE typeUnitCode in (SELECT IntField FROM dbo.SplitString(@unitCodes))
AND(deptName like '%'+ @SearchString + '%' AND deptName NOT like @SearchString + '%')
and status = 1

) as T1
ORDER BY typeUnitCode,showOrder, DistrictName


GO

GRANT EXEC ON dbo.rpc_findDistrictsByName TO PUBLIC

GO

