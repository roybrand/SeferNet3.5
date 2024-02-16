IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertDeptProfessions')
	BEGIN
		DROP  Procedure  rpc_insertDeptProfessions
	END

GO

CREATE Procedure rpc_insertDeptProfessions
	(
		@DeptCode int,
		@ProfessionCodes varchar(50)=null,
		@updateUserName varchar(50)
	)
AS


	DECLARE @count int, @currentCount int, @strProfessions varchar(100)
	DECLARE @curProfessionCode int
	
	Declare @MinProfessionCode int
	SET @curProfessionCode = 0
	Set @MinProfessionCode = 0
	
	SET @count = (Select count(IntField) from  dbo.SplitString(@ProfessionCodes))

	IF( @count > 0)
		BEGIN
			SET @currentCount = @count

			WHILE (@currentCount > 0)
				BEGIN
					set @curProfessionCode = (select min(IntField) from dbo.SplitString(@ProfessionCodes)
											where IntField >@MinProfessionCode)
												
					set @MinProfessionCode = @curProfessionCode							   
					Insert  into x_dept_professions 
					(DeptCode,professionCode,updateUserName)
					values (@DeptCode,@curProfessionCode,@updateUserName)
					set @currentCount = @currentCount -1
				END
		END

GO


GRANT EXEC ON rpc_insertDeptProfessions TO PUBLIC

GO

