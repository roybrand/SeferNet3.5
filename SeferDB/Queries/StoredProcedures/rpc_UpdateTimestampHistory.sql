CREATE PROCEDURE dbo.rpc_UpdateTimestampHistory
AS
	DECLARE @MaxTimeStamp BINARY(8);
	DECLARE @TableList Table (TableName VARCHAR(100));
	DECLARE @TableName VARCHAR(100);
	DECLARE @SQL NVARCHAR(300);
	DECLARE @Params NVARCHAR(MAX);

	INSERT INTO @TableList SELECT TableName FROM DIC_Translations GROUP BY TableName

	SET @Params = ' @xMaxTimeStamp BINARY(8) OUTPUT, 
					@xTableName VARCHAR(MAX) ';

	DECLARE IndexCursor CURSOR FOR SELECT TableName FROM @TableList

	OPEN IndexCursor
	FETCH NEXT FROM IndexCursor INTO @TableName
	WHILE @@fetch_status=0
	BEGIN
		SET @SQL = 'SELECT @xTableName, MAX(TimeStamp), GETDATE() FROM <TableName> '
		SET @Sql = Replace(@Sql, '<TableName>', @TableName)

		INSERT INTO TimeStampHistory
		EXEC sp_executesql @Sql, @Params,
						   @xTableName = @TableName,
						   @xMaxTimeStamp = @MaxTimeStamp OUTPUT

		FETCH NEXT FROM IndexCursor INTO @TableName
	END
	CLOSE IndexCursor
	DEALLOCATE IndexCursor