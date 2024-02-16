alter procedure spGetClinicHandicappedFacilities
	@clinicCodes tbl_UniqueIntArray READONLY
AS
BEGIN
	-- Clinic Handicapped Facilities           
	SELECT DHF.DeptCode,          
		FacilityDescription AS HandicappedFacility           
	FROM vWS_DeptHandicappedFacilities DHF          
		--INNER JOIN @clinicCodes as t ON DHF.DeptCode = t.IntVal          
		INNER JOIN vWS_DIC_HandicappedFacilities as DIC_HF ON DHF.FacilityCode = DIC_HF.FacilityCode          
	WHERE EXISTS( SELECT 1 FROM  @clinicCodes as t where DHF.DeptCode = t.IntVal )

END
go