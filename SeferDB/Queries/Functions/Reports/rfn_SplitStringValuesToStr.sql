if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rfn_SplitStringValuesToStr]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rfn_SplitStringValuesToStr]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


--The following is a general purpose UDF to split comma separated lists into individual items.
--Consider an additional input parameter for the delimiter, so that you can use any delimiter you like.
CREATE FUNCTION [dbo].[rfn_SplitStringValuesToStr]
(
	@ItemList varchar(max)
)
RETURNS 
@ParsedList table
(
	ItemID varchar(50)
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







GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



GRANT select ON rfn_SplitStringValuesToStr TO [clalit\webuser]

GO
 

  