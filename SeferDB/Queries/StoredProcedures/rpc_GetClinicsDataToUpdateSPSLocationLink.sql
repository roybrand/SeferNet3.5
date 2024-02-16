IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetClinicsDataToUpdateSPSLocationLink')
	BEGIN
		drop procedure rpc_GetClinicsDataToUpdateSPSLocationLink
	END

GO

CREATE Procedure [dbo].[rpc_GetClinicsDataToUpdateSPSLocationLink]
(
	@HasLocationLink int,
	@DeptStatus int 
)
as

SELECT  D.deptCode,
		D.deptName,
		Cities.cityName + 
		CASE WHEN (streetName is not NULL AND streetName <> '')
			THEN ', ' + D.streetName 
			ELSE ''
			END +
		CASE WHEN (D.house is not NULL AND D.house <> '')
			THEN ' ' + D.house
			ELSE ''
			END +
		CASE WHEN (D.NeighbourhoodOrInstituteCode is NOT NULL AND D.NeighbourhoodOrInstituteCode <> '')
			THEN
				CASE WHEN D.IsSite = 1 
					THEN Atarim.InstituteName 
					ELSE Neighbourhoods.NybName 
					END 
			ELSE ''
			END	+		
		CASE WHEN (D.addressComment is NOT NULL AND D.addressComment <> '')
			THEN
				' ' + D.addressComment
			ELSE ''
			END
        AS  ClinicAddress,
			dbo.fun_ParsePhoneNumberWithExtension(dp.prePrefix, dp.prefix, dp.phone, dp.extension) 
        as deptPhone,
        x_dept_XY.XLongitude as Longitude,
        x_dept_XY.YLatitude as Latitude,
		x_dept_XY.xcoord,
        x_dept_XY.ycoord,    
        LocationLink

FROM Dept D
JOIN Cities ON D.cityCode = Cities.cityCode
JOIN x_dept_XY ON D.deptCode = x_dept_XY.deptCode
LEFT JOIN Atarim ON D.NeighbourhoodOrInstituteCode = Atarim.InstituteCode
LEFT JOIN Neighbourhoods ON D.NeighbourhoodOrInstituteCode = Neighbourhoods.NeighbourhoodCode
LEFT JOIN DeptPhones dp ON D.deptCode = dp.deptCode
	AND dp.phoneType = 1 AND dp.phoneOrder = 1
WHERE 
	(@HasLocationLink = -1 
		OR (@HasLocationLink = 1 AND LocationLink is NOT NULL)
		OR (@HasLocationLink = 0 AND LocationLink is NULL)
	)
AND (@DeptStatus = -1
	OR (@DeptStatus = 1 AND D.status = 1)
	OR (@DeptStatus = 0 AND D.status = 0)
)
GO

GRANT EXECUTE
    ON OBJECT::[dbo].[rpc_GetClinicsDataToUpdateSPSLocationLink] TO [clalit\webuser]
    AS [dbo];
GO

GRANT EXECUTE
    ON OBJECT::[dbo].[rpc_GetClinicsDataToUpdateSPSLocationLink] TO [clalit\IntranetDev]
    AS [dbo];
GO