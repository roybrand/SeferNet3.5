IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getCitiesAndDistrictsByNameAndDistricts')
	BEGIN
		DROP  Procedure  rpc_getCitiesAndDistrictsByNameAndDistricts
	END

GO

CREATE Procedure rpc_getCitiesAndDistrictsByNameAndDistricts
	(
	@SearchStr varchar(20),
	@DistrictCodes varchar(100)
	)

AS

SELECT * FROM
	(SELECT 
	cityCode, 
	'cityName' = cityName + ' - ' + districtName, 'cityNameOnly' = cityName, Cities.districtCode, showOrder = 0
	FROM Cities
	INNER JOIN View_AllDistricts ON Cities.districtCode = View_AllDistricts.districtCode
	WHERE ( @SearchStr is null or cityName like @SearchStr+'%')
		AND ( @DistrictCodes is null or Cities.districtCode IN (SELECT IntField FROM dbo.SplitString(@DistrictCodes)))

	UNION
	
	SELECT
	cityCode, 
	'cityName' = cityName + ' - ' + districtName, 'cityNameOnly' = cityName, Cities.districtCode, showOrder = 1
	FROM Cities
	INNER JOIN View_AllDistricts ON Cities.districtCode = View_AllDistricts.districtCode
	WHERE ( @SearchStr is null OR (cityName like '%' + @SearchStr + '%' AND cityName NOT like @SearchStr+'%'))
		AND ( @DistrictCodes is null or Cities.districtCode IN (SELECT IntField FROM dbo.SplitString(@DistrictCodes)))
	) as T1
	
ORDER BY showOrder, cityName

GO

GRANT EXEC ON rpc_getCitiesAndDistrictsByNameAndDistricts TO PUBLIC

GO

