set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fun_getDeptReceptionRemarks] (@receptionID INT, @displayOnInternet BIT)
RETURNS varchar(500)
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @count int, @curentCount int, @strRemarks varchar(500)
	DECLARE @curRemark int
	SET @curRemark = 0
	SET @strRemarks = ''

	SET @count = (SELECT COUNT(*) FROM  DeptReceptionRemarks 
				  WHERE ReceptionID = @receptionID 
				  AND (DATEDIFF(dd,ValidFrom, GETDATE()) >= 0 OR ValidFrom IS NULL)   
				  AND (DATEDIFF(dd, ValidTo, GETDATE()) <= 0 OR ValidTo IS NULL)
				  AND (DisplayInInternet = 1 OR @displayOnInternet = 0)
				  )

	IF( @count > 0)
		BEGIN
			SET @curentCount = @count

			WHILE (@curentCount > 0)
				BEGIN

					SET @curRemark = 
						(	SELECT MIN(DeptReceptionRemarkID) 
							FROM DeptReceptionRemarks 
							WHERE ReceptionID = @receptionID 
							AND (DATEDIFF(dd,ValidFrom, GETDATE()) >= 0 OR ValidFrom IS NULL)   
							AND (DATEDIFF(dd, ValidTo, GETDATE()) <= 0 OR ValidTo IS NULL)
							AND (DisplayInInternet = 1 OR @displayOnInternet = 0)							
							AND DeptReceptionRemarkID > @curRemark
						)

					SET @strRemarks = @strRemarks + ', ' +
						(	SELECT TOP 1 RemarkText 
							FROM DeptReceptionRemarks dr
							WHERE DeptReceptionRemarkID = @curRemark)	

					SET @curentCount = @curentCount - 1
					
				END
			SET @strRemarks = RIGHT( @strRemarks, LEN(@strRemarks) -1 )

		END

	RETURN( @strRemarks )
	
END;
 

