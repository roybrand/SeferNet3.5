IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_GetDeptAttribution')
	BEGIN
		DROP  function  fun_GetDeptAttribution
	END
GO

CREATE FUNCTION [dbo].[fun_GetDeptAttribution]
(
	@IsCommunity bit,
	@IsMushlam bit,
	@IsHospital bit,
	@SubUnitTypeCode tinyint
)
RETURNS varchar(100)
AS
BEGIN
 
    DECLARE @p_str VARCHAR(100)
    SET @p_str = ''
    
    IF(@IsCommunity = 1 AND @IsMushlam = 1)
		SET @p_str = 'מושלם וקהילה'
    ELSE IF(@IsHospital = 1 AND @IsCommunity = 1)
		SET @p_str = 'בתי חולים וקהילה'	
    ELSE IF(@IsHospital = 1 AND @IsMushlam = 1)
		SET @p_str = 'בתי חולים ומושלם'			
	ELSE
		IF(	@IsHospital = 1 )
			SET @p_str = 'בתי חולים'
		ELSE IF(@SubUnitTypeCode = 0)
			SET @p_str = 'קהילה'			
		ELSE IF(@SubUnitTypeCode = 1 OR @SubUnitTypeCode = 2)
			SET @p_str = 'קהילה בהסכם'	
		ELSE IF(@SubUnitTypeCode = 4)
			SET @p_str = 'מושלם'
		ELSE IF(@SubUnitTypeCode = 5)
			SET @p_str = 'בתי חולים'
		ELSE 			
			SET @p_str = 'קהילה'								
	
    RETURN @p_str

END
GO
  
grant exec on fun_GetDeptAttribution to public 
GO 