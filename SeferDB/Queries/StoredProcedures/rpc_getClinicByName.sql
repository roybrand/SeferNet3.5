IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getClinicByName')
	BEGIN
		DROP  Procedure  rpc_getClinicByName
	END

GO

CREATE Procedure dbo.rpc_getClinicByName
(
	@SearchString varchar(50)
)

AS

SELECT deptCode, ClinicName FROM
(	
Select deptCode, rtrim(ltrim(deptName)) as ClinicName, showOrder = 0
FROM dept
WHERE deptName like @SearchString + '%'
AND status = 1

UNION

Select deptCode, rtrim(ltrim(deptName)) as ClinicName, showOrder = 1
FROM dept
WHERE (deptName like '%'+ @SearchString + '%' AND deptName NOT like @SearchString + '%')
AND status = 1
) as T1

ORDER BY showOrder, ClinicName

GO

GRANT EXEC ON rpc_getClinicByName TO PUBLIC

GO


