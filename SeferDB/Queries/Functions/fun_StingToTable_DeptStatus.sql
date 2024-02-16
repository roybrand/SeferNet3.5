ALTER FUNCTION [dbo].[fun_StingToTable_DeptStatus]
(
	@InputStr varchar(1000),
	@DeptCode int,
	@UpdateUser varchar(50)
)
RETURNS 
/*@ResultTable has the structure of "DeptStatus" table
@InputStr has "records" separated with ';' and "field" separated with ','
the fields are: DeptCode, Status, FromDate, UpdateDate, UpdateUser
*/
@ResultTable table
(
	DeptCode int,
	Status smallint,
	FromDate smalldatetime,
	ToDate smalldatetime,
	UpdateDate smalldatetime,
	UpdateUser varchar(50)
)
AS

BEGIN

	DECLARE @Status smallint
	DECLARE @FromDate smalldatetime
	DECLARE @ToDate smalldatetime
	
	DECLARE @TableRow varchar(500)
	DECLARE @Index int
	DECLARE @RowSeparatorPosition int

	SET @InputStr = LTRIM(RTRIM(@InputStr)) + ';'
	SET @RowSeparatorPosition = CHARINDEX(';', @InputStr, 1)
	
	IF REPLACE(REPLACE(@InputStr, ',', ''), ';', '') <> ''-- to make sure @InputStr doesn't consist of separators only
	BEGIN
		WHILE @RowSeparatorPosition > 0
		BEGIN
			SET @TableRow = LTRIM(RTRIM(LEFT(@InputStr, @RowSeparatorPosition - 1)))
			IF REPLACE(@TableRow, ',', '') <> ''
			BEGIN
			
				SET @TableRow = LTRIM(RTRIM(@TableRow))+ ','
				SET @Index = CHARINDEX(',', @TableRow, 1)

				SET @Status = LTRIM(RTRIM(LEFT(@TableRow, @Index - 1)))
				SET @TableRow = RIGHT(@TableRow, LEN(@TableRow) - @Index)
				SET @Index = CHARINDEX(',', @TableRow, 1)

				SET @FromDate = CONVERT(smalldatetime,LEFT(@TableRow, @Index - 1), 103)
				SET @TableRow = RIGHT(@TableRow, LEN(@TableRow) - @Index)
				SET @Index = CHARINDEX(',', @TableRow, 1)
				
				SET @ToDate = CONVERT(smalldatetime,LEFT(@TableRow, @Index - 1), 103)
				IF @ToDate <= cast('1/1/1900 12:00:00 AM' as datetime)
					BEGIN
						SET @ToDate = null
					END	

				SET @TableRow = RIGHT(@TableRow, LEN(@TableRow) - @Index)
				--SET @Index = CHARINDEX(',', @TableRow, 1)
				
				IF @Status <> '' AND @FromDate <> ''
				BEGIN
					INSERT INTO @ResultTable (DeptCode, Status, FromDate, ToDate, UpdateDate, UpdateUser) 
					VALUES (@DeptCode, @Status, @FromDate, @ToDate, getdate(), @UpdateUser) 
				END

			END
			
			SET @InputStr = RIGHT(@InputStr, LEN(@InputStr) - @RowSeparatorPosition)
			SET @RowSeparatorPosition = CHARINDEX(';', @InputStr, 1)
			
		END
	END
	RETURN
END