IF EXISTS (SELECT * FROM sysobjects WHERE name = 'fun_GetProfessionsForEmployeeReception')
	BEGIN
		DROP  FUNCTION  fun_GetProfessionsForEmployeeReception
	END
GO

CREATE FUNCTION [dbo].[fun_GetProfessionsForEmployeeReception]
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
	INNER JOIN [Services] ON deptEmployeeReceptionServices.ServiceCode = [Services].ServiceCode
	WHERE receptionID = @ReceptionID
	AND [Services].IsProfession = 1

	IF len(@p_str) > 1
	-- remove last comma
	BEGIN
		SET @p_str = SUBSTRING(@p_str, 0, len(@p_str))
	END
	
    RETURN @p_str

END
GO
 
grant exec on fun_GetProfessionsForEmployeeReception to public 
go 
