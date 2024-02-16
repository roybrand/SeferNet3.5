IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rfn_SplitStringByDelimiterValuesToInt]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rfn_SplitStringByDelimiterValuesToInt]
GO

CREATE FUNCTION [dbo].[rfn_SplitStringByDelimiterValuesToInt]
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
	DECLARE @ItemID int, @Pos int

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

grant select on rfn_SplitStringByDelimiterValuesToInt to public 
GO