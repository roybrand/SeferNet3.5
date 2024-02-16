IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDeptNamesForUpdate')
	BEGIN
		DROP  Procedure  rpc_getDeptNamesForUpdate
	END

GO

CREATE Procedure dbo.rpc_getDeptNamesForUpdate
	(
		@deptCode int
	)
AS

--- DeptDetails --------------------------------------------------------
SELECT
D.deptName,
D.deptNameFreePart,
D.deptType, -- 1, 2, 3
DIC_DeptTypes.deptTypeDescription, -- מחוז, מנהלת, מרפאה
D.typeUnitCode, -- סוג יחידה
'subUnitTypeCode' = IsNull(D.subUnitTypeCode, -1), -- שיוך
D.deptLevel,
D.DisplayPriority,
'showUnitInInternet' = IsNull(D.showUnitInInternet, 1)

FROM dept as D
INNER JOIN DIC_DeptTypes ON D.deptType = DIC_DeptTypes.deptType	-- ??
WHERE D.deptCode = @deptCode

-- DeptNames
SELECT
deptCode, deptName, fromDate, toDate
FROM DeptNames
WHERE deptCode = @deptCode
ORDER BY fromDate


GO

GRANT EXEC ON rpc_getDeptNamesForUpdate TO PUBLIC

GO

