IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertDeptStatusWithoutDependency')
	BEGIN
		DROP  Procedure  rpc_insertDeptStatusWithoutDependency
	END

GO

CREATE Procedure dbo.rpc_insertDeptStatusWithoutDependency
	(
		@DeptCode int,
		@Status int,
		@FromDate datetime = null,
		@ToDate datetime = null,
		@UpdateUser varchar(50),
		
		@ErrorCode int = 0 OUTPUT
	)

AS



	INSERT INTO DeptStatus
	(DeptCode, Status, FromDate, ToDate, UpdateUser, UpdateDate)
	VALUES
	(@DeptCode, @Status, @FromDate, @ToDate, @UpdateUser, getdate())

	SET @ErrorCode = @@Error

GO

GRANT EXEC ON rpc_insertDeptStatusWithoutDependency TO PUBLIC

GO

