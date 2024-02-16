
IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[dbo].[SplitStringToTable]') and xtype in (N'FN', N'IF', N'TF'))
	DROP FUNCTION [dbo].[SplitStringToTable]

GO

-- Used to handle the employee reception remarks

CREATE FUNCTION [dbo].[SplitStringToTable]
(
	@CommaDelStr varchar(max)
)
RETURNS 
@ParsedList table
(
	RemarkID INT,
	DeptCode	INT
)
AS
BEGIN
	DECLARE @remarkID varchar(10),  
			@Pos int, 
			@deptCode VARCHAR(10)
			
			
	SET @Pos = CHARINDEX(',', @CommaDelStr, 1)


	IF REPLACE(@CommaDelStr, ',', '') <> ''
	BEGIN
		WHILE @Pos > 0
		BEGIN
			SET @remarkID = LTRIM(RTRIM(LEFT(@CommaDelStr, @Pos - 1)))
			
			SET @CommaDelStr = RIGHT(@CommaDelStr, LEN(@CommaDelStr) - @Pos)
			SET @Pos = CHARINDEX(',', @CommaDelStr, 1)			
			
			IF (@pos = 0)
				SET @deptCode = LTRIM(RTRIM(@CommaDelStr))
			ELSE
				SET @deptCode = LTRIM(RTRIM(LEFT(@CommaDelStr, @Pos - 1)))
						
			IF @remarkID <> ''
			BEGIN
				
				INSERT INTO @ParsedList (RemarkID, DeptCode) 
				VALUES ( CAST(@remarkID AS int), CAST(@deptCode AS INT) ) --Use Appropriate conversion

			END
			
			SET @CommaDelStr = RIGHT(@CommaDelStr, LEN(@CommaDelStr) - @Pos)
			SET @Pos = CHARINDEX(',', @CommaDelStr, 1)		
				
			

		END
	END	
	RETURN
END

GO


