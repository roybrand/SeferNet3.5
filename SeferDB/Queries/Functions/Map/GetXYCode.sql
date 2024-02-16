 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'GetXYCode')
BEGIN
	print 'drop function GetXYCode'
	DROP  FUNCTION  GetXYCode
END

GO

create FUNCTION [dbo].[GetXYCode](@x float,@y float)

RETURNS varchar(32)
AS
BEGIN
	if (@x is not null and @y is not null)
	begin
		return 
		(select	cast(cast(@x*[dbo].[GetXYMulitplier]() as bigint) as varchar(16) ) 
		+  cast(cast(@y*[dbo].[GetXYMulitplier]() as bigint)  as varchar(16)) )
	end
	
	
	return  null

END

 go 

grant exec on GetXYCode to public 
go