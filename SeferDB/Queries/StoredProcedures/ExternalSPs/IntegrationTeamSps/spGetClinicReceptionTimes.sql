alter procedure spGetClinicReceptionTimes
	@clinicCodes tbl_UniqueIntArray READONLY
AS
BEGIN
	-- Clinic Reception Times
	SELECT
		deptCode,
		receptionDay,
		openingHour,
		closingHour,
		drr.RemarkText as Remark		-- NEW Field - For Rubik !
	FROM vWS_DeptReception as dr
	left join DeptReceptionRemarks as drr on dr.ReceptionID = drr.ReceptionID 
	WHERE EXISTS( SELECT 1 FROM  @clinicCodes as t where dr.DeptCode = t.IntVal )
	and  GETDATE() between ISNULL(drr.validFrom,'1900-01-01') and ISNULL(drr.validTo,'2079-01-01')
END
go