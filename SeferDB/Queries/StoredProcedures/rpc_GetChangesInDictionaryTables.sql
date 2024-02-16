CREATE PROCEDURE dbo.rpc_GetChangesInDictionaryTables
AS
	DECLARE @TableList Table (TableName VARCHAR(100));
	DECLARE @Result Table (TableName VARCHAR(100), Timestamp BINARY(8));
	DECLARE @TableName VARCHAR(100);
	DECLARE @SQL NVARCHAR(300);
	DECLARE @Params NVARCHAR(MAX);

	INSERT INTO @TableList SELECT TableName FROM DIC_Translations GROUP BY TableName

	SET @Params = ' @xMaxTimeStamp BINARY(8) OUTPUT, 
					@xTableName VARCHAR(MAX) ';

	DECLARE @HistoryMaxTimeStamp BINARY(8);
	DECLARE @CurrentMaxTimeStamp BINARY(8);

	DECLARE IndexCursor CURSOR FOR SELECT TableName FROM @TableList

	OPEN IndexCursor
	FETCH next from IndexCursor into @TableName
	WHILE @@fetch_status=0
	BEGIN
		SET @Sql = 'SELECT TOP 1 @xMaxTimeStamp = MaxTimeStamp FROM TimeStampHistory WHERE TableName=''<TableName>'' ORDER BY ID DESC'
		SET @Sql = Replace(@Sql, '<TableName>', @TableName)

		EXEC sp_executesql @Sql, @Params,
						   @xTableName = @TableName,
						   @xMaxTimeStamp = @HistoryMaxTimeStamp OUTPUT

		SET @Sql = 'SELECT TOP 1 @xMaxTimeStamp = Max(TimeStamp) FROM <TableName>'
		SET @Sql = Replace(@Sql, '<TableName>', @TableName)
	
		EXEC sp_executesql @Sql, @Params,
						   @xTableName = @TableName,
						   @xMaxTimeStamp = @CurrentMaxTimeStamp OUTPUT

		IF(@CurrentMaxTimeStamp > @HistoryMaxTimeStamp)
		BEGIN
			INSERT INTO @Result VALUES (@TableName, @CurrentMaxTimeStamp)
		END

		FETCH NEXT FROM IndexCursor INTO @TableName
	END
	CLOSE IndexCursor
	DEALLOCATE IndexCursor

	SELECT TableName, Timestamp FROM @Result