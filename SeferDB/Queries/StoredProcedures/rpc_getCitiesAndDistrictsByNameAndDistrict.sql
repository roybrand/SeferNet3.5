IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getCitiesAndDistrictsByNameAndDistrict')
	BEGIN
		DROP  Procedure  rpc_getCitiesAndDistrictsByNameAndDistrict
	END

GO

CREATE Procedure dbo.rpc_getCitiesAndDistrictsByNameAndDistrict
(
	@SearchStr varchar(20),
	@DistrictCode int,
	@DeptCode int
)
 
AS
declare @tmpDistrictCode int
declare @tmpTypeUnitCode int

set @tmpDistrictCode = @DistrictCode

/* If the ditrict of the dept is hospital it will return the all cities */
if @DistrictCode <> -1
	begin
	set @tmpTypeUnitCode = (select typeUnitCode from Dept where deptCode = @DistrictCode)
	if(@tmpTypeUnitCode = 60)
		set @tmpDistrictCode = -1
	end


SELECT 
cityCode, 
'cityName' = cityName + ' - ' + districtName, 
Cities.districtCode
FROM Cities
INNER JOIN View_AllDistricts ON Cities.districtCode = View_AllDistricts.districtCode
WHERE ( @SearchStr is null or cityName like '%'+ @SearchStr+'%')
	AND ( @tmpDistrictCode = -1 or Cities.districtCode = @tmpDistrictCode)
ORDER BY cityName


GO

GRANT EXEC ON rpc_getCitiesAndDistrictsByNameAndDistrict TO PUBLIC

GO



