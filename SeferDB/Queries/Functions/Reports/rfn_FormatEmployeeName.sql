IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'rfn_FormatEmployeeName')
	BEGIN
		DROP  function  rfn_FormatEmployeeName
	END

GO

create function [dbo].[rfn_FormatEmployeeName](
	@FirstName varchar(50),
	@LastName varchar(50),
	@Degree int) 
RETURNS varchar(100)
AS
BEGIN

	declare @EmpName varchar(100) 

	set @EmpName = '' 
	if @LastName Is Not null set @EmpName = @LastName  +  ' '  
	if @FirstName Is Not null set @EmpName = @EmpName +  @FirstName +   ' '  
	if @Degree Is Not null and @Degree > 0 select @EmpName = @EmpName +  DegreeName from DIC_EmployeeDegree where DegreeCode = @Degree
	 


	return @EmpName
	
end 


go 

grant exec on rfn_FormatEmployeeName to public 
go   