IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'MakePhoneNumber')
	BEGIN
		DROP  function  MakePhoneNumber
	END
GO

CREATE FUNCTION [dbo].[MakePhoneNumber]
(
	@PrePrefix int,
	@Prefix varchar(3),
	@Phone int
)
RETURNS varchar(100)

AS
BEGIN
	DECLARE @FullPhoneNumber varchar(100)
	
	SET @FullPhoneNumber = 
		  CASE ISNULL(LEN(@PrePrefix),'0') WHEN '0' THEN '' ELSE (CASE CAST(@PrePrefix as varchar(1)) WHEN '1' THEN '1-' WHEN '2' THEN '*' END) END
		+ CASE ISNULL(@Prefix,'0') WHEN '0' THEN '' ELSE @Prefix + '-' END
		+ CASE ISNULL(LEN(@Phone),'0') WHEN '0' THEN '' ELSE CAST(@Phone as varchar(8)) END
		
	IF ISNUMERIC(@FullPhoneNumber) = 1	/* phone num. can't be just a number*/
		BEGIN
			SET @FullPhoneNumber = ''
		END
	RETURN (CASE CAST(ISNULL(@FullPhoneNumber,'0') as varchar(100)) WHEN '0' THEN '' ELSE @FullPhoneNumber END)
END  
GO

grant exec on MakePhoneNumber to public 
GO     