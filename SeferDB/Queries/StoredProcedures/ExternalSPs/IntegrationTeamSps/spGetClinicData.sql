ALTER procedure [dbo].[spGetClinicData]
	@clinicCodes tbl_UniqueIntArray READONLY
AS
BEGIN
	-- Clinic info
	SELECT
		Dept.deptCode AS ClinicCode,
		isnull(deptSimul.Simul228, 0) AS OldClinicCode,
		deptName AS ClinicName,
		Dept.districtCode AS District,
		Dept.administrationCode AS AdministrationCode,
		Dept.subAdministrationCode AS SubAdministrationCode,
		Cities.cityCode AS TownCode,
		Cities.cityName AS TownName,
		Dept.streetName AS Street,
		Dept.house AS HouseNo,
		Dept.addressComment AS AddressComment,
		isnull(Dept.subUnitTypeCode, 0)  AS IsIndependent,
		Dept.transportation AS Bus,
		Dept.email AS SiteEmail,
		Dept.adminManagerName AS AdminManagerName,
		Dept.TypeUnitCode AS TypeUnitCode,
		UnitType.UnitTypeName AS UnitTypeName
	FROM vWS_deptSimul as deptSimul
		INNER JOIN vWS_Dept as Dept  ON  deptSimul.deptCode = Dept.deptCode
		INNER JOIN vWS_UnitType as UnitType  ON UnitType.UnitTypeCode =  Dept.TypeUnitCode
		LEFT JOIN vWS_Cities as Cities ON Cities.cityCode = Dept.cityCode
		WHERE EXISTS ( SELECT 1 FROM @clinicCodes as t WHERE deptSimul.deptCode = t.IntVal)

END

GO
