IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'fun_StingToTable_DeptNames')
	BEGIN
		DROP  FUNCTION  fun_StingToTable_DeptNames
	END

GO

CREATE FUNCTION [dbo].[fun_StingToTable_DeptNames]
(
	@InputStr varchar(1000),
	@DeptCode int,
	@UpdateUser varchar(50)
)
RETURNS 
/*@ResultTable has the structure of "DeptNames" table
@InputStr has "records" separated with ';' and "field" separated with ','
the fields are: deptName, fromDate
*/
@ResultTable table
(
	deptCode int,
	deptName varchar(100),
	fromDate smalldatetime,
	updateDate smalldatetime,
	updateUser varchar(50)
)
AS

BEGIN

	DECLARE @DeptName varchar(100)
	DECLARE @FromDate varchar(30)
	DECLARE @TableRow varchar(500)
	DECLARE @Index int
	DECLARE @RowSeparatorPosition int

	
	SET @InputStr = LTRIM(RTRIM(@InputStr)) + ';'
	SET @RowSeparatorPosition = CHARINDEX(';', @InputStr, 1)
	
	IF REPLACE(REPLACE(@InputStr, ',', ''), ';', '') <> ''
	BEGIN
		WHILE @RowSeparatorPosition > 0
		BEGIN
			SET @TableRow = LTRIM(RTRIM(LEFT(@InputStr, @RowSeparatorPosition - 1)))
			IF REPLACE(@TableRow, ',', '') <> ''
			BEGIN
				SET @TableRow = LTRIM(RTRIM(@TableRow))+ ','
				SET @Index = CHARINDEX(',', @TableRow, 1)
				
				SET @DeptName = LTRIM(RTRIM(LEFT(@TableRow, @Index - 1)))
				SET @TableRow = RIGHT(@TableRow, LEN(@TableRow) - @Index)
				SET @Index = CHARINDEX(',', @TableRow, 1)

				SET @FromDate = LTRIM(RTRIM(LEFT(@TableRow, @Index - 1)))
				SET @TableRow = RIGHT(@TableRow, LEN(@TableRow) - @Index)
				--SET @Index = CHARINDEX(',', @TableRow, 1)
				
				IF @DeptName <> '' AND @FromDate <> ''
				BEGIN
					INSERT INTO @ResultTable (deptCode, deptName, fromDate, updateDate, updateUser) 
					VALUES (@DeptCode, @DeptName, CONVERT(smalldatetime, @FromDate, 103), getdate(), @UpdateUser) 
				END
			END
			
			SET @InputStr = RIGHT(@InputStr, LEN(@InputStr) - @RowSeparatorPosition)
			SET @RowSeparatorPosition = CHARINDEX(';', @InputStr, 1)
			
		END
	END
	RETURN
END
GO

GRANT select ON fun_StingToTable_DeptNames TO PUBLIC
GO