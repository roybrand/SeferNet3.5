IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'rfn_GetDeptHandicappedFacilities')
	BEGIN
		DROP  function  rfn_GetDeptHandicappedFacilities
	END

GO

CREATE  function [dbo].[rfn_GetDeptHandicappedFacilities](@DeptCode int) 
RETURNS varchar(100)
AS
BEGIN

	declare @HFacilities varchar(1000) 

	set @HFacilities = '' 
	if @DeptCode Is Not null and @DeptCode > 0 
	select @HFacilities = @HFacilities  + DIC_HF.FacilityDescription +  '; '
	from DeptHandicappedFacilities as DHF
	join DIC_HandicappedFacilities as DIC_HF 
	on DHF.FacilityCode = DIC_HF.FacilityCode
	and DeptCode = @DeptCode  

	return @HFacilities
	
end 
go 

grant exec on rfn_GetDeptHandicappedFacilities to public 
go 