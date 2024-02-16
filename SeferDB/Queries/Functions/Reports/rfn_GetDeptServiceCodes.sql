GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'rfn_GetDeptServiceCodes')
	BEGIN
		DROP  function  rfn_GetDeptServiceCodes
	END
GO

create FUNCTION [dbo].rfn_GetDeptServiceCodes (@DeptCode int)
RETURNS varchar(500)
WITH EXECUTE AS CALLER
AS
BEGIN

	RETURN( '' )
END;
go 

grant exec on dbo.rfn_GetDeptServiceCodes to public 
go  

