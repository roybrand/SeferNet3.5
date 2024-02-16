 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_GetSectorsForProfession')
	BEGIN
		DROP  function  fun_GetSectorsForProfession
	END
GO

CREATE FUNCTION [dbo].[fun_GetSectorsForProfession]
(
	@professionCode INT
)
RETURNS varchar(500)
AS
BEGIN
 
    DECLARE @p_str VARCHAR(500)
    SET @p_str = ''
    
    SELECT @p_str = @p_str + EmployeeSectorDescription + ','
    FROM X_Profession_SectorCode xps
    INNER JOIN EmployeeSector ON xps.EmployeeSectorCode = EmployeeSector.EmployeeSectorCode
    WHERE xps.ProfessionCode = @professionCode
        
	IF len(@p_str) > 1
	-- remove last comma
	BEGIN
		SET @p_str = SUBSTRING(@p_str, 0, len(@p_str))
	END
	
    RETURN @p_str

END
GO

  
GRANT EXEC ON fun_GetSectorsForProfession to public 
GO 