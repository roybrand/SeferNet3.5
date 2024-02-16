IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'rfn_GetEmployeeReceptionsWithRemarkStringNoBR')
	BEGIN
		DROP  function  rfn_GetEmployeeReceptionsWithRemarkStringNoBR
	END
GO

CREATE function [dbo].[rfn_GetEmployeeReceptionsWithRemarkStringNoBR](@DeptCode int, @EmployeeID bigint, @ServiceCode int, @day int) 
RETURNS varchar(200)
WITH EXECUTE AS CALLER

AS
BEGIN

	declare @IntervalsStr varchar(200) 
	set @IntervalsStr = ''
	
	SELECT 
	@intervalsStr = @intervalsStr + ' ' + replace(openingHourText, '<br>', ' ')
		
	FROM 
 
	[dbo].[vEmployeeReceptionHours]
	WHERE DeptCode = @DeptCode
	AND EmployeeID = @EmployeeID
	AND ServiceCode = @ServiceCode
	AND receptionDay = @day
	order by openingHour
	
	return (@IntervalsStr);
	
END 
GO

GRANT EXEC ON dbo.rfn_GetEmployeeReceptionsWithRemarkStringNoBR TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rfn_GetEmployeeReceptionsWithRemarkStringNoBR TO [clalit\IntranetDev]
GO 
