ALTER function [dbo].[rfn_IngBCComapareDistricts](@DistrictParam int, @RecDistrict int)  
returns tinyint 
as  
begin 
declare @RetVal tinyint 
set @RetVal = 0 
if @DistrictParam  = @RecDistrict set @RetVal = 1 
return @RetVal
end
