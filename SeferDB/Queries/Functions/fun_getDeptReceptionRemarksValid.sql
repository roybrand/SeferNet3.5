set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fun_getDeptReceptionRemarksValid] (@DeptReceptionRemarkID int)
RETURNS varchar(1000)
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @strRemarks varchar(1000)
	SET @strRemarks = ''

	SELECT @strRemarks = @strRemarks + IsNull(REPLACE(RemarkText,'#',''), '') + '<br>'
		FROM DeptReceptionRemarks 
		WHERE ReceptionID = @DeptReceptionRemarkID
			AND (ValidFrom <= getdate() or ValidFrom is null)
			AND (ValidTo >= getdate() or ValidTo is null)
			
	RETURN( @strRemarks )
	
END;

 