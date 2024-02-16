alter procedure spGetClinicCommunications
	@clinicCodes tbl_UniqueIntArray READONLY
AS
BEGIN
	-- Clinic Communications   
	SELECT       
		DPH.DeptCode AS ClinicCode,          
		dbo.fun_ParsePhoneNumberWithExtension(DPH.prePrefix, DPH.prefix, DPH.phone, DPH.extension) AS CommunicationData,          
		DPH.phoneType AS CommunicationTypeCode,          
		DPT.phoneTypeName          
	FROM vWS_DeptPhones as DPH          
	INNER JOIN vWS_DIC_PhoneTypes as DPT ON   DPH.phoneType = DPT.phoneTypeCode                
	WHERE EXISTS( SELECT 1 FROM  @clinicCodes as t where DPH.DeptCode = t.IntVal )       
	ORDER BY  DPH.DeptCode  
END
go