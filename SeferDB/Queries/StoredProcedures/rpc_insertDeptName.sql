IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertDeptName')
	BEGIN
		DROP  Procedure  rpc_insertDeptName
	END

GO


CREATE Procedure dbo.rpc_insertDeptName
	(
		@DeptCode int,
		@DeptName varchar(100),
		@FromDate datetime,
		@ToDate datetime,
		@UpdateUser varchar(50)
	)

AS


	
INSERT INTO DeptNames
(deptCode, deptName, fromDate, ToDate, updateDate, updateUser)
VALUES
(@DeptCode, @DeptName, @FromDate, @ToDate, getdate(), @UpdateUser)

-- if it's from today, update dept name
IF DATEDIFF(dd, @FromDate, GETDATE()) = 0
	UPDATE DEPT
	SET DeptName = @DeptName
	WHERE DeptCode = @deptCode




GO

GRANT EXEC ON rpc_insertDeptName TO PUBLIC

GO
