 USE [SeferNet]
GO
/****** Object:  UserDefinedFunction [dbo].[rfn_IsDatesCurrent]    Script Date: 01/31/2010 11:48:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[rfn_IsDatesCurrent](@StartDate datetime, @EndDate datetime, @CurrentDate datetime)  
RETURNS tinyint AS  
BEGIN  
	declare @IsCurrent tinyint 
	
	set @IsCurrent = 0 
	
	if ((DateDiff(day, @StartDate, @CurrentDate) >=0) or (@StartDate is null))
		and ((DateDiff(day, @CurrentDate, @EndDate) >=0) or (@EndDate is null)) 
	begin 
		set @IsCurrent = 1
	end 
	
	return @IsCurrent
END
