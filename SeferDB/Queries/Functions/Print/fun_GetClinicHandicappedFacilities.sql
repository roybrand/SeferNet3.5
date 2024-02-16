IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_GetClinicHandicappedFacilities')
	BEGIN
		DROP  function  fun_GetClinicHandicappedFacilities
	END
GO 


CREATE FUNCTION [dbo].[fun_GetClinicHandicappedFacilities]
(
	@DeptCode int
)
RETURNS varchar(500)

AS
BEGIN
 
    DECLARE @p_str VARCHAR(500)
    SET @p_str = ''

	SELECT @p_str = @p_str + DIC_HandicappedFacilities.FacilityDescription + ', '
	FROM DIC_HandicappedFacilities
	INNER JOIN DeptHandicappedFacilities 
		ON DIC_HandicappedFacilities.FacilityCode = DeptHandicappedFacilities.FacilityCode
	WHERE DeptHandicappedFacilities.deptCode = @DeptCode

	IF len(@p_str) > 1
	-- remove last comma
	BEGIN
		SET @p_str = SUBSTRING(@p_str, 0, len(@p_str) - 1)
	END
	
    RETURN @p_str
END

GO

grant exec on fun_GetClinicHandicappedFacilities to public 
GO    