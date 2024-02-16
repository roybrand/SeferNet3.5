IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rfn_TimeInterval_float')
	BEGIN
		DROP  function  dbo.rfn_TimeInterval_float
	END

GO

Create function dbo.rfn_TimeInterval_float(@openingHour_str varchar(5), @closingHour_str varchar(5))
RETURNS float
	
WITH EXECUTE AS CALLER
AS

BEGIN
	declare @interval float
	declare @minutes as int
			
	set @minutes = dbo.rfn_TimeInterval(@openingHour_str, @closingHour_str);
	set @interval = CONVERT(float, @minutes)/60;
		
	return	(@interval)	 
END




