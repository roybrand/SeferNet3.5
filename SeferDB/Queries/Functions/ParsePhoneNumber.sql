set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[ParsePhoneNumber]
(
	@Preprefix tinyint,
	@Prefix smallint,
	@Phone int
)
RETURNS varchar(100)

AS
BEGIN
	DECLARE @FullPhoneNumber varchar(100)
	SET @FullPhoneNumber = 
		CASE ISNULL(LEN(@Preprefix),'0') WHEN '0' THEN '' ELSE (CASE CAST(@Preprefix as varchar(1)) WHEN '1' THEN '1-' WHEN '2' THEN '*' END) END
		+ CASE ISNULL(LEN(@Prefix),'0') WHEN '0' THEN '' WHEN '3' THEN CAST(@Prefix as varchar(3)) + '-' 
			ELSE (CASE @Prefix WHEN '0' THEN '' ELSE '0' + CAST(@Prefix as varchar(3)) + '-' END) END 
		+ CASE ISNULL(LEN(@Phone),'0') WHEN '0' THEN '' ELSE CAST(@Phone as varchar(8)) END
		
	IF ISNUMERIC(@FullPhoneNumber) = 1	/* here phone num. can't be just a number*/
		BEGIN
			SET @FullPhoneNumber = ''
		END
	RETURN (CASE CAST(ISNULL(@FullPhoneNumber,'0') as varchar(100)) WHEN '0' THEN '' ELSE @FullPhoneNumber END)
END
 