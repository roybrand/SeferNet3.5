ALTER FUNCTION [dbo].[rfn_SplitStringValuesToStrLong]
(
	@ItemList varchar(4000)
)
RETURNS 
@ParsedList table
(
	ItemID varchar(500)
)
AS
BEGIN
	DECLARE @ItemID varchar(10), @Pos int

	SET @ItemList = LTRIM(RTRIM(@ItemList))+ ','
	SET @Pos = CHARINDEX(',', @ItemList, 1)

	IF REPLACE(@ItemList, ',', '') <> ''
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
			SET @Pos = CHARINDEX(',', @ItemList, 1)

		END
	END	
	RETURN
END








 