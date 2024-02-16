IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getAdministrationList')
	BEGIN
		DROP  Procedure  rpc_getAdministrationList
	END

GO

CREATE Procedure rpc_getAdministrationList

	(
		@DistrictCode int
	)


AS

SELECT dept.deptCode, dept.deptname
FROM dept

WHERE districtCode = @DistrictCode
AND deptType = 2
ORDER BY deptName

GO


GRANT EXEC ON rpc_getAdministrationList TO PUBLIC

GO


