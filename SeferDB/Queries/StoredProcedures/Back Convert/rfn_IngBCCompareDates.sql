ALTER function [dbo].[rfn_IngBCCompareDates](@DateExpression1 datetime , @DateExpression2 datetime)
returns tinyint 
as 
begin  
	Declare @DatesDiff tinyint 
	Declare @de1 datetime 
	Declare @de2 datetime 
	
	set @de1 = @DateExpression1
	set @de2 = @DateExpression2 

	set @DatesDiff =  0 
	if @de1  is null or (@de1 is not null and @de2 is null and Datediff(ss, '2010/07/05 08:00:01.000', getdate()) > 0 )
	begin 
		set @DatesDiff = 2 
	end 

	if Datediff(d, @de1, @de2) < 0 
	begin 
		set @DatesDiff = 1	
	end 
	else if Datediff(d, @de1, @de2) > 0 and  Datediff(ss, '2010/07/05 00:00:01.000', @de2) > 0  
	begin 
		set @DatesDiff = 2	
	end 
	return @DatesDiff
end
