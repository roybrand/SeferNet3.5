ALTER function [dbo].[rfn_IngBCCompareDates3](@DateExpression1 datetime , @DateExpression2 datetime,  @DateExpression3 datetime)
returns tinyint 
as 
begin  
	Declare @DatesDiff tinyint 
	Declare @de1 datetime 
	Declare @de2 datetime 
	Declare @de3 datetime 
	
	set @de1 = @DateExpression1
	set @de2 = @DateExpression2 
	set @de3 = @DateExpression3 

	set @DatesDiff =  0 
	if @de1  is null and @de2 is null  
	begin 
		set @DatesDiff = 3 
	end 
	
	if @de1  is null and @de3 is null  
	begin 
		set @DatesDiff = 2  
	end 

	if @de2  is null and @de3 is null  
	begin 
		set @DatesDiff = 1  
	end 

	if Datediff(d, @de1, @de2) < 0 
	begin 
		set @DatesDiff = 1	
		if Datediff(d, @de3, @de1) < 0 
		begin 
			set @DatesDiff = 3
		end 
	end  
	else if Datediff(d, @de2, @de3) < 0  set @DatesDiff = 2	
	else set @DatesDiff = 3
		 
 	return @DatesDiff
end
