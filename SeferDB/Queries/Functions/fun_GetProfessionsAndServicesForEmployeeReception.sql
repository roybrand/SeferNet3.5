IF EXISTS (SELECT * FROM sysobjects WHERE name = 'fun_GetProfessionsAndServicesForEmployeeReception')
	BEGIN
		DROP  FUNCTION  fun_GetProfessionsAndServicesForEmployeeReception
	END
GO

CREATE FUNCTION [dbo].[fun_GetProfessionsAndServicesForEmployeeReception]
(
	@ReceptionID int
)
RETURNS varchar(500)
AS
BEGIN
 
    DECLARE @prof_str VARCHAR(500)    SET @prof_str = ''
    DECLARE @serv_str VARCHAR(500)    SET @serv_str = ''
    DECLARE @retValue VARCHAR(500)    SET @retValue = ''
    
	SELECT  @prof_str = @prof_str + CASE WHEN IsProfession = 1 THEN ServiceDescription + ',' ELSE '' END,
			@serv_str = @serv_str + CASE WHEN IsProfession = 0 THEN ServiceDescription + ',' ELSE '' END
	FROM deptEmployeeReceptionServices
	INNER JOIN [Services] ON deptEmployeeReceptionServices.ServiceCode = [Services].ServiceCode
	WHERE receptionID = @ReceptionID

	IF len(@prof_str) > 1
	-- remove last comma
		SET @prof_str = SUBSTRING(@prof_str, 0, len(@prof_str))

	IF len(@serv_str) > 1
	-- remove last comma
		SET @serv_str = SUBSTRING(@serv_str, 0, len(@serv_str))

	SET @retValue = @prof_str + CASE @serv_str WHEN '' THEN '#' ELSE '#' + @serv_str END
	
    RETURN @retValue

END
GO