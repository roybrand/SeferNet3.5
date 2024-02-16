IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'rfn_GetServiceReceptionWithRemarks')
	BEGIN
		DROP  function  rfn_GetServiceReceptionWithRemarks
	END
GO 

CREATE function [dbo].[rfn_GetServiceReceptionWithRemarks](@DeptCode int, @serviceCode int, @day int) 
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
	[dbo].[vServicesReceptionWithRemarks]
	WHERE DeptCode = @DeptCode
	AND serviceCode = @serviceCode
	AND receptionDay = @day
	AND IsMedicalTeam = 1
	order by openingHour
	
	return (@IntervalsStr);
	
end
GO
GRANT EXEC ON dbo.rfn_GetServiceReceptionWithRemarks TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rfn_GetServiceReceptionWithRemarks TO [clalit\IntranetDev]
GO 