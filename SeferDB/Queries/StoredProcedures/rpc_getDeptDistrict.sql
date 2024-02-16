IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptDistrict')
	BEGIN
		DROP  Procedure  rpc_getDeptDistrict
	END

GO

CREATE Procedure rpc_getDeptDistrict
	(
		@DeptCode int
	)

AS

SELECT districtCode 
FROM dept
WHERE DeptCode = @DeptCode
AND districtCode IS NOT null
AND districtCode > 0

UNION

SELECT deptCode
FROM dept
WHERE DeptCode = @DeptCode
AND (districtCode IS null OR districtCode < 0)

GO

GRANT EXEC ON rpc_getDeptDistrict TO PUBLIC

GO

