IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rfn_AddInputTypeToRemark]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rfn_AddInputTypeToRemark]
GO


CREATE function [dbo].[rfn_AddInputTypeToRemark]
(
	@ItemList varchar(max)

)
returns varchar(max) 

AS
BEGIN
	
	declare @res varchar(max)
	declare @length int
	declare @lastChar varchar(1)
	
	
	set @res = replace(@ItemList,'# ','~10# ')
	
	
	set @length = len(@res)
	set @lastChar = substring(@res,@length,1)
	if @lastChar = '#'
	begin
		set @res = substring(@res,0,@length ) + '~10#'
	end
	
	
	RETURN @res
END

GO

GRANT EXEC ON rfn_AddInputTypeToRemark TO PUBLIC
GO