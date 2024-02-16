IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getProfessionsNotInDept')
	BEGIN
		DROP  Procedure  rpc_getProfessionsNotInDept
	END

GO

CREATE Procedure rpc_getProfessionsNotInDept

	(
		@DeptCode int
		
	)


AS
	Select 
		ProfessionCode,
		ProfessionDescription
	From
		Professions
	where
		professionCode not in (select professionCode from x_dept_Professions where deptCode=@deptCode)			
		order by professionDescription 
		

GO


GRANT EXEC ON rpc_getProfessionsNotInDept TO PUBLIC

GO

