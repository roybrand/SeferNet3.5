set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fun_GetDeptHandicappedFacilities] (@DeptCode int)
RETURNS varchar(500)
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @strFacilities varchar(500)
	SET @strFacilities = ''

	SELECT @strFacilities = @strFacilities + CASE CHARINDEX(ParkingInClinicDescription,@strFacilities) WHEN 0 THEN ', ' + ParkingInClinicDescription
																									 ELSE '' END
		FROM Dept 
		INNER JOIN DeptHandicappedFacilities deptFac ON Dept.DeptCode = deptFac.DeptCode
		INNER JOIN DIC_ParkingInClinic dicPark ON deptFac.FacilityCode = dicPark.ParkingInClinicCode
		WHERE dept.deptCode = @DeptCode

						
	IF(LEN(@strFacilities)) > 0 -- to remove last ','
		BEGIN
			SET @strFacilities = RIGHT( @strFacilities, LEN(@strFacilities) -1 )
		END
	
	RETURN( @strFacilities )
	
END;
  