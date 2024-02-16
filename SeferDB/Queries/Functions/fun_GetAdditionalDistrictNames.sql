IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'fun_GetAdditionalDistrictNames')
	BEGIN
		DROP  FUNCTION  fun_GetAdditionalDistrictNames
	END
GO

CREATE FUNCTION [dbo].[fun_GetAdditionalDistrictNames] 
(
	@deptCode int
)
RETURNS varchar(500)

AS
	
BEGIN
	DECLARE  @AdditionalDistrictsNames varchar(500)
	
	SET @AdditionalDistrictsNames = ''
	SELECT @AdditionalDistrictsNames = @AdditionalDistrictsNames + CAST(districtName as varchar(100)) + ', '  
	FROM x_Dept_District
	JOIN View_AllDistricts ON x_Dept_District.districtCode = View_AllDistricts.districtCode
	WHERE deptCode = @deptCode

	IF(LEN(@AdditionalDistrictsNames) > 0) 
		SET @AdditionalDistrictsNames = LEFT(@AdditionalDistrictsNames, LEN(@AdditionalDistrictsNames) - 1)
						
	RETURN( @AdditionalDistrictsNames )		
END

GO
 
 