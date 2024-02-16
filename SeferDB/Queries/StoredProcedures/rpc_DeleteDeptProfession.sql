IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteDeptProfession')
	BEGIN
		DROP  Procedure  rpc_DeleteDeptProfession
	END

GO

CREATE Procedure rpc_DeleteDeptProfession

	(
		@deptCode int,
		@professionCode int
	
	)
	
	AS
	
	delete x_dept_Professions
	where deptCode=@deptCode
	and professionCode=@professionCode


GO


GRANT EXEC ON rpc_DeleteDeptProfession TO PUBLIC

GO


