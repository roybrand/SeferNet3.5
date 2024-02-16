IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateDeptLevelAndShowInInternet')
	BEGIN
		DROP  Procedure  rpc_UpdateDeptLevelAndShowInInternet
	END

GO

CREATE Procedure dbo.rpc_UpdateDeptLevelAndShowInInternet
(
	@DeptCode int,
	@DeptLevel int,
	@DisplayPriority int,	
	@UpdateUser varchar(50)
)

AS

BEGIN 

	UPDATE dept
	SET 
	deptLevel = @DeptLevel,
	DisplayPriority = @DisplayPriority,
	updateDate = getdate(),
	UpdateUser = @UpdateUser
	WHERE deptCode = @DeptCode
END 


GO

GRANT EXEC ON rpc_UpdateDeptLevelAndShowInInternet TO PUBLIC

GO