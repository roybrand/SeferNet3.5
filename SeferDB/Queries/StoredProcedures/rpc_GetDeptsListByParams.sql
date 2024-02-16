IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetDeptsListByParams')
	BEGIN
		DROP  Procedure  rpc_GetDeptsListByParams
	END

GO

CREATE Procedure dbo.rpc_GetDeptsListByParams
(
	@deptCode INT,
	@deptName VARCHAR(30),
	@cityCode INT,
	@districtCode INT,  
	@unitTypeCode INT
)

AS

SELECT d.DeptCode, DeptName, StreetName + ' ' + house as StreetName, CityName
FROM Dept d
LEFT JOIN DeptSimul on d.deptCode = deptSimul.deptCode
INNER JOIN Cities ON d.CityCode = Cities.CityCode
WHERE
	( d.DeptCode = @deptCode OR deptSimul.Simul228 = @DeptCode OR @deptCOde = -1)
AND
	( d.DeptName like '%' + @deptName + '%' OR @deptName = '')	
AND
	( d.CityCode = @cityCode OR @cityCode = -1)
AND
	( d.DistrictCode = @districtCode OR @districtCode = -1)		
AND
	( d.typeUnitCode = @unitTypeCode OR @unitTypeCode = -1)
AND d.status = 1
ORDER BY DeptName

GO

GRANT EXEC ON rpc_GetDeptsListByParams TO PUBLIC

GO


