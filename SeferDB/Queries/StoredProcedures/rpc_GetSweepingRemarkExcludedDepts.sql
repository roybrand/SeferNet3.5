IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetSweepingRemarkExcludedDepts')
	BEGIN
		DROP  Procedure  rpc_GetSweepingRemarkExcludedDepts
	END

GO

CREATE Procedure dbo.rpc_GetSweepingRemarkExcludedDepts
	(
		@DeptRemarkID INT
	)

AS
	SELECT DISTINCT 
	r.ExcludedDeptCode as 'ExcludedDeptCode'
	, Dept.deptName as 'ExcludedDeptName'
	FROM dbo.SweepingDeptRemarks_Exclusions as r
	INNER JOIN Dept ON r.ExcludedDeptCode = Dept.DeptCode
	WHERE r.DeptRemarkID = @DeptRemarkID


	select REPLACE(DeptRemarks.RemarkText,'#','') as RemarkText
	from DeptRemarks
	where DeptRemarks.DeptRemarkID = @DeptRemarkID
GO

GRANT EXEC ON dbo.rpc_GetSweepingRemarkExcludedDepts TO PUBLIC

GO

