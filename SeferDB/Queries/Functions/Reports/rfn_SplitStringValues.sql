 IF EXISTS (SELECT * FROM sysobjects WHERE name = 'rfn_SplitStringValues')
	BEGIN
		PRINT 'Dropping Procedure rfn_SplitStringValues'
		DROP  function rfn_SplitStringValues
	END

GO

PRINT 'Creating Procedure rfn_SplitStringValues'
GO

--The following is a general purpose UDF to split comma separated lists into individual items.
--Consider an additional input parameter for the delimiter, so that you can use any delimiter you like.
CREATE FUNCTION dbo.rfn_SplitStringValues
(
	@ItemList varchar(max)
)
RETURNS 
@ParsedList table
(
	ItemID int
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
			SET @ItemID = LTRIM(RTRIM(LEFT(@ItemList, @Pos - 1)))
			IF @ItemID <> ''
			BEGIN
				INSERT INTO @ParsedList (ItemID) 
				VALUES (CAST(@ItemID AS int)) --Use Appropriate conversion
			END
			SET @ItemList = RIGHT(@ItemList, LEN(@ItemList) - @Pos)
			SET @Pos = CHARINDEX(',', @ItemList, 1)

		END
	END	
	RETURN
END





GO

GRANT select ON rfn_SplitStringValues TO public

GO
