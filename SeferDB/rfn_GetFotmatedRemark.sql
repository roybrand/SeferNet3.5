IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rfn_GetFotmatedRemark]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rfn_GetFotmatedRemark]
GO



CREATE function [dbo].[rfn_GetFotmatedRemark](@s varchar(max))
returns varchar(max)
AS
BEGIN

declare @d varchar(max)
set @d = '' 

	Select 
	@d = @d + ' ' + c.t
	from 
	(
	select CHARINDEX('~', b.itemid, 1) as pod , LEN(b.itemid) as l, 
	case 
				when CHARINDEX('~', b.itemid, 1) > 0  then Substring(b.itemid, 1, CHARINDEX('~', b.itemid, 1)-1)
				else b.itemid
		  end  as t 
	from(
	SELECT   a.*
	FROM dbo.rfn_SplitStringByDelimiterValuesToStr(@s, '#') as a
	)  as b 
	) as c  
	
	return @d 
end 


GO


GRANT EXEC ON rfn_GetFotmatedRemark TO PUBLIC
GO