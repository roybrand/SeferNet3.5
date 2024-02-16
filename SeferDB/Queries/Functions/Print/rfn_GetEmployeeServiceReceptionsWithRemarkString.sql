IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'rfn_GetEmployeeServiceReceptionsWithRemarkString')
	BEGIN
		DROP  function  rfn_GetEmployeeServiceReceptionsWithRemarkString
	END
GO

CREATE function [dbo].[rfn_GetEmployeeServiceReceptionsWithRemarkString](@DeptCode int, @EmployeeID bigint, @day int, @ServiceCode int) 
RETURNS varchar(200)

AS
BEGIN

	declare @IntervalsStr varchar(200) 
	set @IntervalsStr = ''
	
	SELECT 
	@intervalsStr = @intervalsStr + CASE WHEN @intervalsStr = '' THEN '' ELSE '<br>' END
		+ openingHourText
		
	FROM 
 
	[dbo].[vEmployeeReceptionHours]
	WHERE DeptCode = @DeptCode
	AND EmployeeID = @EmployeeID
	AND receptionDay = @day
	AND ServiceCode = @ServiceCode
	order by openingHour
	
	return (@IntervalsStr);
	
end

GO


GRANT EXEC ON dbo.rfn_GetEmployeeServiceReceptionsWithRemarkString TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rfn_GetEmployeeServiceReceptionsWithRemarkString TO [clalit\IntranetDev]
GO 