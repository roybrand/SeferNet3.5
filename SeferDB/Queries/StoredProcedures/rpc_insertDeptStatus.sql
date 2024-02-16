IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertDeptStatus')
	BEGIN
		DROP  Procedure  rpc_insertDeptStatus
	END

GO

CREATE PROCEDURE dbo.rpc_insertDeptStatus
	(
		@DeptCode int,
		@Status int,
		@FromDate datetime,
		@ToDate datetime,
		@UpdateUser varchar(50),
		
		@ErrorCode int = 0 OUTPUT,
		@Message varchar(500) = '' OUTPUT
	)

AS

IF @FromDate <= cast('1/1/1900 12:00:00 AM' as datetime)
	BEGIN
		SET @FromDate = null
	END	

IF @ToDate <= cast('1/1/1900 12:00:00 AM' as datetime)
	BEGIN
		SET @ToDate = null
	END	
		

		UPDATE DeptStatus
		SET ToDate = DATEADD(d, -1, @FromDate)
		WHERE StatusID = (SELECT MAX(StatusID) FROM DeptStatus WHERE DeptCode = @DeptCode)

		INSERT INTO DeptStatus
		(DeptCode, Status, FromDate, ToDate, UpdateUser, UpdateDate)
		VALUES
		(@DeptCode, @Status, @FromDate, @ToDate, @UpdateUser, getdate())

	
	SET @ErrorCode = @@Error

GO

GRANT EXEC ON rpc_insertDeptStatus TO PUBLIC

GO

