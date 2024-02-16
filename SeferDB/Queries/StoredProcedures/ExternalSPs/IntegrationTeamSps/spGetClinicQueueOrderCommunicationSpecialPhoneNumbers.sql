alter  procedure spGetClinicQueueOrderCommunicationSpecialPhoneNumbers
	@clinicCodes tbl_UniqueIntArray READONLY
AS
BEGIN
	-- Clinic Queue Order Communication          
    -- Special Phone Numbers
	SELECT
		DQOM.DeptCode AS ClinicCode,
		dbo.fun_ParsePhoneNumberWithExtension(DQOPH.prePrefix, DQOPH.prefix, DQOPH.phone, DQOPH.extension) AS SpecialPhoneNumber
	FROM vWS_DeptQueueOrderPhones as DQOPH
	INNER JOIN vWS_DeptQueueOrderMethod as DQOM ON DQOM.queueOrderMethodID = DQOPH.queueOrderMethodID
	WHERE
		DQOM.queueOrderMethod  = 2
		AND DQOPH.phoneType = 1
		AND EXISTS ( SELECT 1 FROM @clinicCodes as t  where DQOM.DeptCode = t.IntVal )

END
go
