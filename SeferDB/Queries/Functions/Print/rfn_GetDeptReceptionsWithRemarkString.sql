IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'rfn_GetDeptReceptionsWithRemarkString')
	BEGIN
		DROP  function  rfn_GetDeptReceptionsWithRemarkString
	END
GO

CREATE function [dbo].[rfn_GetDeptReceptionsWithRemarkString](@DeptCode int, @day int, @ReceptionHoursType int) 
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
	[dbo].[vDeptReceptionHours]
	WHERE DeptCode = @DeptCode
	AND receptionDay = @day
	AND ReceptionHoursTypeID = @ReceptionHoursType
	order by openingHour
	
	return (@IntervalsStr);
	
end 
GO

GRANT EXEC ON dbo.rfn_GetDeptReceptionsWithRemarkString TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rfn_GetDeptReceptionsWithRemarkString TO [clalit\IntranetDev]
GO 