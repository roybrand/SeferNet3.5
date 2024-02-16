IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteX_dept_XY')
	BEGIN
		DROP  Procedure  rpc_DeleteX_dept_XY
	END

GO

CREATE Procedure dbo.rpc_DeleteX_dept_XY
	(
		@DeptCode int,
		@ErrorCode int = 0 OUTPUT
	)

AS

	DELETE FROM x_dept_XY WHERE deptCode = @DeptCode
	
	SET @ErrorCode = @@Error

GO

GRANT EXEC ON rpc_DeleteX_dept_XY TO PUBLIC

GO

