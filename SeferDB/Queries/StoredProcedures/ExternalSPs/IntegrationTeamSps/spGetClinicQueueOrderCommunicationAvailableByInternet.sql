alter  procedure spGetClinicQueueOrderCommunicationAvailableByInternet
	@clinicCodes tbl_UniqueIntArray READONLY
AS
BEGIN
	-- Clinic Queue Order Communication          
	-- Available By Internet
	SELECT
		DQOM.deptCode AS ClinicCode,          
		CASE DQOM.QueueOrderMethod          
			WHEN 4 THEN 1          
			ELSE 0          
		END AS AvailableByInternet          
	FROM vWS_DeptQueueOrderMethod DQOM          
	WHERE          
		DQOM.queueOrderMethod = 4 
		AND EXISTS( SELECT 1 FROM @clinicCodes t where DQOM.DeptCode = t.IntVal ) -- 152120
                
END
go