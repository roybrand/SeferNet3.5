IF EXISTS (SELECT * FROM sysobjects WHERE name = 'fun_GetServicesForEmployeeReception')
	BEGIN
		DROP  FUNCTION  fun_GetServicesForEmployeeReception
	END
GO

CREATE FUNCTION [dbo].[fun_GetServicesForEmployeeReception]
(
	@ReceptionID int
)
RETURNS varchar(500)
AS
BEGIN
 
    DECLARE @p_str VARCHAR(500)
    SET @p_str = ''

	SELECT @p_str = @p_str + ServiceDescription + ','
	FROM deptEmployeeReceptionServices
	INNER JOIN [Services] ON deptEmployeeReceptionServices.serviceCode = [Services].serviceCode
	WHERE receptionID = @ReceptionID
	AND [Services].IsProfession = 0

	IF len(@p_str) > 1
	-- remove last comma
	BEGIN
		SET @p_str = SUBSTRING(@p_str, 0, len(@p_str))
	END
	
    RETURN @p_str

END
GO

grant exec on fun_GetServicesForEmployeeReception to public 
go 
