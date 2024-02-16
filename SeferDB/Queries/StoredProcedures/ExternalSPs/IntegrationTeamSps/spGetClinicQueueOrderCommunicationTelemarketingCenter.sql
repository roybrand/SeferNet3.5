alter  procedure spGetClinicQueueOrderCommunicationTelemarketingCenter
	@clinicCodes tbl_UniqueIntArray READONLY
AS
BEGIN
	-- Clinic Queue Order Communication          
	-- Telemarketing Center
	SELECT
		DQOM.DeptCode AS ClinicCode,          
		QueueOrderMethodDescription AS TelemarketingCenter           
	FROM vWS_DIC_QueueOrderMethod as DIC_DQOM          
	INNER JOIN vWS_DeptQueueOrderMethod as DQOM ON DIC_DQOM.QueueOrderMethod = DQOM.QueueOrderMethod        
	WHERE           
		DQOM.QueueOrderMethod = 3       
		AND EXISTS( SELECT 1 FROM @clinicCodes t where DQOM.DeptCode = t.IntVal )  -- 980635    
                       
END
go