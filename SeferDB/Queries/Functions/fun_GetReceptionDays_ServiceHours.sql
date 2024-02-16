SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fun_GetReceptionDays_ServiceHours]
(
	@DeptCode int,
	@ServiceCode int,
	@OpeningHour varchar(5),
	@ClosingHour varchar(5),
	@ValidFrom smalldatetime,
	@ValidTo smalldatetime,
	@RemarkID int
)
RETURNS varchar(100)
AS
BEGIN
	DECLARE @ReceptionDays varchar(100)
	SET @ReceptionDays = ''

	SELECT @ReceptionDays = (CAST(receptionDay as varchar(6))+',' + @ReceptionDays) 
	FROM DeptServiceReception as DSR
	LEFT JOIN DeptServiceReceptionRemarks as DSRr ON DSR.receptionID = DSRr.ServiceReceptionID
	WHERE deptCode = @DeptCode
	AND serviceCode = @ServiceCode
	AND openingHour = @OpeningHour
	AND closingHour = @ClosingHour
	AND IsNull(DSR.validFrom, 0) = IsNull(@ValidFrom, 0)
	AND IsNull(DSR.validTo, 0) = IsNull(@ValidTo, 0)	
	AND IsNull(RemarkID, 0) = IsNull(@RemarkID, 0)
	
	IF len(@ReceptionDays) > 1
	-- remove last comma
	BEGIN
		SET @ReceptionDays = SUBSTRING(@ReceptionDays, 0, len(@ReceptionDays))
	END

	RETURN @ReceptionDays
END 