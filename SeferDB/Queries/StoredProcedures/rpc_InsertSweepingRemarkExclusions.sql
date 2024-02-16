IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertSweepingRemarkExclusions')
	BEGIN
		DROP  Procedure  rpc_InsertSweepingRemarkExclusions
	END

GO

CREATE Procedure dbo.rpc_InsertSweepingRemarkExclusions
	(
		@DeptRemarkID INT,
		@ExcludedDeptCode int,
		@updateUser varchar(500)
	)

AS
	update DeptRemarks 
	set DeptRemarks.UpdateDate = GetDate()
	 ,DeptRemarks.UpdateUser = @updateUser
	 WHERE DeptRemarkID = @DeptRemarkID
	

	insert into dbo.SweepingDeptRemarks_Exclusions (DeptRemarkID, ExcludedDeptCode)
	values(@DeptRemarkID, @ExcludedDeptCode)
GO

GRANT EXEC ON dbo.rpc_InsertSweepingRemarkExclusions TO PUBLIC

GO

