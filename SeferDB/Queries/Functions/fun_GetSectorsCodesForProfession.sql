  IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_GetSectorsCodesForProfession')
	BEGIN
		DROP  function  fun_GetSectorsCodesForProfession
	END
GO

CREATE FUNCTION [dbo].[fun_GetSectorsCodesForProfession]
(
	@professionCode INT
)
RETURNS varchar(500)
AS
BEGIN
 
    DECLARE @p_str VARCHAR(500)
    SET @p_str = ''
    
    SELECT @p_str = @p_str + CONVERT(VARCHAR,EmployeeSectorCode) + ','
    FROM X_Profession_SectorCode xps
    WHERE xps.ProfessionCode = @professionCode
        
	IF len(@p_str) > 1
	-- remove last comma
	BEGIN
		SET @p_str = SUBSTRING(@p_str, 0, len(@p_str))
	END
	
    RETURN @p_str

END
GO

  
GRANT EXEC ON fun_GetSectorsCodesForProfession to public 
GO 