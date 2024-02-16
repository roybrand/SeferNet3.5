   SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fun_GetReceptionIDs_ServiceHours]
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
	DECLARE @ReceptionIDs varchar(100)
	SET @ReceptionIDs = ''

	SELECT @ReceptionIDs = (CAST(receptionID as varchar(6))+',' + @ReceptionIDs) 
	FROM DeptServiceReception as DSR
	LEFT JOIN DeptServiceReceptionRemarks as DSRr ON DSR.receptionID = DSRr.ServiceReceptionID
	WHERE deptCode = @DeptCode
	AND serviceCode = @ServiceCode
	AND openingHour = @OpeningHour
	AND closingHour = @ClosingHour
	AND IsNull(DSR.validFrom, 0) = IsNull(@ValidFrom, 0)
	AND IsNull(DSR.validTo, 0) = IsNull(@ValidTo, 0)	
	AND IsNull(RemarkID, 0) = IsNull(@RemarkID, 0)
	
	IF len(@ReceptionIDs) > 1
	-- remove last comma
	BEGIN
		SET @ReceptionIDs = SUBSTRING(@ReceptionIDs, 0, len(@ReceptionIDs))
	END

	RETURN @ReceptionIDs
END