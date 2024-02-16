IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'rfn_GetEmployeeReceptionsWithRemarkString')
	BEGIN
		DROP  function  rfn_GetEmployeeReceptionsWithRemarkString
	END
GO 


CREATE function [dbo].[rfn_GetEmployeeReceptionsWithRemarkString](@DeptCode int, @EmployeeID bigint, @day int) 
RETURNS varchar(200)
WITH EXECUTE AS CALLER

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
	order by openingHour
	
	return (@IntervalsStr);
	
end 
GO

GRANT EXEC ON dbo.rfn_GetEmployeeReceptionsWithRemarkString TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rfn_GetEmployeeReceptionsWithRemarkString TO [clalit\IntranetDev]
GO 