﻿IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_HelperLongPrint]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].rpc_HelperLongPrint
GO

CREATE PROCEDURE dbo.rpc_HelperLongPrint( @string nvarchar(max) )
AS
SET NOCOUNT ON
	set @string = rtrim( @string )
	declare @cr char(1), @lf char(1)
	set @cr = char(13)
	set @lf = char(10)

	declare @len int, @cr_index int, @lf_index int, @crlf_index int, @has_cr_and_lf bit, @left nvarchar(4000), @reverse nvarchar(4000)

	set @len = 4000

	while ( len( @string ) > @len )
	begin

	set @left = left( @string, @len )
	set @reverse = reverse( @left )
	set @cr_index = @len - charindex( @cr, @reverse ) + 1
	set @lf_index = @len - charindex( @lf, @reverse ) + 1
	set @crlf_index = case when @cr_index < @lf_index then @cr_index else @lf_index end

	set @has_cr_and_lf = case when @cr_index < @len and @lf_index < @len then 1 else 0 end

	print left( @string, @crlf_index - 1 )

	set @string = right( @string, len( @string ) - @crlf_index - @has_cr_and_lf )

	end

	print @string
go

GRANT EXEC ON rpc_HelperLongPrint TO PUBLIC
go