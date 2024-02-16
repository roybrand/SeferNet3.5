
IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[dbo].[SplitStringNoOrder]') and xtype in (N'FN', N'IF', N'TF'))
	DROP FUNCTION [dbo].[SplitStringNoOrder]

GO


PRINT 'Creating Procedure SplitStringNoOrder'
GO

--The following is a general purpose UDF to split comma separated lists into individual items with no order.
CREATE FUNCTION dbo.SplitStringNoOrder
(
	@ItemList varchar(500)
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

GRANT select ON SplitStringNoOrder TO [clalit\webuser]

GO
