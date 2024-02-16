IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rfn_SplitStringByDelimiterValuesToStr]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rfn_SplitStringByDelimiterValuesToStr]
GO


--The following is a general purpose UDF to split comma separated lists into individual items.
--Consider an additional input parameter for the delimiter, so that you can use any delimiter you like.
CREATE FUNCTION [dbo].[rfn_SplitStringByDelimiterValuesToStr]
(
	@ItemList varchar(max), 
	@Delimiter varchar(10)
)
RETURNS 
@ParsedList table
(
	ItemID varchar(4000)
)
AS
BEGIN
	DECLARE @ItemID varchar(4000), @Pos int

	SET @ItemList = LTRIM(RTRIM(@ItemList))+ @Delimiter
	SET @Pos = CHARINDEX(@Delimiter, @ItemList, 1)

	IF REPLACE(@ItemList, @Delimiter, '') <> ''
	BEGIN
		WHILE @Pos > 0
		BEGIN
			SET @ItemID = LTRIM(RTRIM(LEFT(@ItemList, @Pos-1)))
			IF @ItemID <> ''
			BEGIN
				INSERT INTO @ParsedList (ItemID) 
				VALUES (@ItemID ) --Use Appropriate conversion
			END
			SET @ItemList = RIGHT(@ItemList, LEN(@ItemList) - @Pos)
			SET @Pos = CHARINDEX(@Delimiter, @ItemList, 1)

		END
	END	
	RETURN
END


GO

grant select on rfn_SplitStringByDelimiterValuesToStr to public 
go