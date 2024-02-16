IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'fun_GetAdditionalDistrictCodes')
	BEGIN
		DROP  FUNCTION  fun_GetAdditionalDistrictCodes
	END
GO

CREATE FUNCTION [dbo].[fun_GetAdditionalDistrictCodes] 
(
	@deptCode int
)
RETURNS varchar(500)

AS
	
BEGIN
	DECLARE  @AdditionalDistrictsCodes varchar(500)
	
	SET @AdditionalDistrictsCodes = ''
	SELECT @AdditionalDistrictsCodes = @AdditionalDistrictsCodes + CAST(districtCode as varchar(10)) + ','  
	FROM x_Dept_District
	WHERE deptCode = @deptCode

	IF(LEN(@AdditionalDistrictsCodes) > 0) 
		SET @AdditionalDistrictsCodes = LEFT(@AdditionalDistrictsCodes, LEN(@AdditionalDistrictsCodes) - 1)
						
	RETURN( @AdditionalDistrictsCodes )		
END

GO
 
 