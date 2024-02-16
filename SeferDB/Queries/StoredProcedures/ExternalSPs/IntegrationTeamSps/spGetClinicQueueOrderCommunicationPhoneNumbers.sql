alter  procedure spGetClinicQueueOrderCommunicationPhoneNumbers
	@clinicCodes tbl_UniqueIntArray READONLY
AS
BEGIN
	-- Clinic Queue Order Communication          
	-- Clinic Phone Numbers          
	SELECT             
		DQOM.deptCode AS ClinicCode,          
		dbo.fun_ParsePhoneNumberWithExtension(DPH.prePrefix, DPH.prefix, DPH.phone, DPH.extension) AS ClinicPhoneNumber                            
	FROM vWS_DeptPhones DPH          
		INNER JOIN vWS_DeptQueueOrderMethod as DQOM ON   DQOM.deptCode = DPH.deptCode                     
	WHERE          
		DQOM.queueOrderMethod = 1           
		AND DPH.phoneType = 1 
		AND EXISTS( SELECT 1 FROM @clinicCodes as t where DPH.DeptCode = t.IntVal )                
                   
END
go