ALTER function [dbo].[rfn_IngBCCompareDatesToLog](@DateExpression1 datetime , @DateExpression2 datetime, @TableCode tinyint, @DistrictCode int)
returns tinyint 
as 
begin  
	Declare @DatesDiff tinyint 
	Declare @de1 datetime 
	Declare @de2 datetime 
	
	set @de1 = @DateExpression1
	set @de2 = @DateExpression2 

	
	set @DatesDiff =  0 
	Select  @DatesDiff = df from (
						Select top 1  case
							when bcl.LastConvertDate  is null and @de2 is not null and Datediff(ss, '2010/07/05 00:00:01.000', @de2) > 0 then 2 
							When Datediff(ss, bcl.LastConvertDate, @de2) < 0 then 1  
							When Datediff(ss, bcl.LastConvertDate, @de2) > 0 then 2
						end as df
						From ING_BCLog  bcl
						Where bcl.TableCode = @TableCode 
						and bcl.DistrictCode = @DistrictCode
						order by LastConvertDate desc) as tbldf 
	
	if @DatesDiff = 0 and Datediff(ss, '2010/07/05 00:00:01.000', @de2) > 0  set @DatesDiff = 2 
	
	return @DatesDiff
end
