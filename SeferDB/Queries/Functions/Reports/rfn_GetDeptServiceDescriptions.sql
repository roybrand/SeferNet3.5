GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'rfn_GetDeptServiceDescriptions')
	BEGIN
		DROP  function  rfn_GetDeptServiceDescriptions
	END
GO

create FUNCTION [dbo].rfn_GetDeptServiceDescriptions (@DeptCode int)
RETURNS varchar(500)
WITH EXECUTE AS CALLER
AS
BEGIN
	RETURN( '' )
END;
go 

grant exec on dbo.rfn_GetDeptServiceDescriptions to public 
go  