IF EXISTS (SELECT * FROM sysobjects WHERE type = 'TF' AND name = 'SplitString')

      BEGIN
            DROP  FUNCTION  SplitString
      END

GO

CREATE FUNCTION dbo.SplitString
(
	@CommaDelStr varchar(max)
)
RETURNS 
@ParsedList table
(
	IntField int,
	OrderNumber int
)
AS
BEGIN
	DECLARE @IntValue varchar(10), @OrderNumber int, @Pos int
	SET @OrderNumber = 0
	
	SET @CommaDelStr = LTRIM(RTRIM(@CommaDelStr))+ ','
	SET @Pos = CHARINDEX(',', @CommaDelStr, 1)

	IF REPLACE(@CommaDelStr, ',', '') <> ''
	BEGIN
		WHILE @Pos > 0
		BEGIN
			SET @IntValue = LTRIM(RTRIM(LEFT(@CommaDelStr, @Pos - 1)))
			IF @IntValue <> ''
			BEGIN
				SET @OrderNumber = @OrderNumber + 1
				INSERT INTO @ParsedList (IntField, OrderNumber) 
				VALUES (CAST(@IntValue AS int), @OrderNumber) --Use Appropriate conversion
			END
			SET @CommaDelStr = RIGHT(@CommaDelStr, LEN(@CommaDelStr) - @Pos)
			SET @Pos = CHARINDEX(',', @CommaDelStr, 1)

		END
	END	
	RETURN
END
 