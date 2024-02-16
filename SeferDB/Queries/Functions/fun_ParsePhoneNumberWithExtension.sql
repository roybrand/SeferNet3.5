IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_ParsePhoneNumberWithExtension')
	BEGIN
		DROP  function  fun_ParsePhoneNumberWithExtension
	END
GO

CREATE FUNCTION [dbo].[fun_ParsePhoneNumberWithExtension]
(
	@PrePrefix tinyint,
	@PrefixCode int,
	@Phone int,
	@Extension int
)
RETURNS varchar(100)

AS
BEGIN
	DECLARE @FullPhoneNumber varchar(100)
	DECLARE @PrefixValue varchar(5) 
	SELECT @PrefixValue = DIC_PhonePrefix.prefixValue FROM DIC_PhonePrefix WHERE DIC_PhonePrefix.prefixCode = @PrefixCode
	
	SET @FullPhoneNumber = 
		CAST(
		CASE ISNULL(LEN(@PrePrefix),'0') WHEN '0' THEN '' ELSE (CASE CAST(@PrePrefix as varchar(1)) WHEN '0' THEN '' WHEN '1' THEN '1-' WHEN '2' THEN '*' END) END
		as varchar(2))
		+ CAST((CASE ISNULL(LEN(@PrefixValue),'0') WHEN '0' THEN '' ELSE @PrefixValue + '-' END) as varchar(4))
		+ CAST(CASE ISNULL(LEN(@Phone),'0') WHEN '0' THEN '' ELSE CAST(@Phone as varchar(8)) END as varchar(7))
		+ CAST(CASE ISNULL(LEN(@Extension),'0') WHEN '0' THEN '' ELSE ' (' + CAST(@Extension as varchar(3)) + ')' END as varchar(8))
		
	IF ISNUMERIC(@FullPhoneNumber) = 1	/* here phone num. can't be just a number*/
		BEGIN
			SET @FullPhoneNumber = ''
		END
	RETURN (CASE CAST(ISNULL(@FullPhoneNumber,'0') as varchar(100)) WHEN '0' THEN '' ELSE @FullPhoneNumber END)
END
 
GO

grant exec on fun_ParsePhoneNumberWithExtension to public 
GO     