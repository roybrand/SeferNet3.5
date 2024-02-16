 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'GetXYMulitplier')
BEGIN
	print 'drop function GetXYMulitplier'
	DROP  FUNCTION  GetXYMulitplier
END

GO

create FUNCTION [dbo].[GetXYMulitplier]()

RETURNS bigint
AS
BEGIN
		return 1000000000000
END


 go 

grant exec on GetXYMulitplier to public 
go