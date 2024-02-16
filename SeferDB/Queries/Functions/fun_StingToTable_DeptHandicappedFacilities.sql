ALTER FUNCTION [dbo].[fun_StingToTable_DeptHandicappedFacilities]
(
	@InputStr varchar(500),
	@DeptCode int
)
RETURNS 
--@ResultTable has the structure of "DeptHandicappedFacilities" table
@ResultTable table
(
	DeptCode int,
	FacilityCode int
)

AS

BEGIN
	DECLARE @FacilityCode varchar(10)
	DECLARE @Index int
	--SET @OrderNumber = 0
	
	SET @InputStr = LTRIM(RTRIM(@InputStr))+ ','
	SET @Index = CHARINDEX(',', @InputStr, 1)

	IF REPLACE(@InputStr, ',', '') <> ''
	BEGIN
		WHILE @Index > 0
		BEGIN
			SET @FacilityCode = LTRIM(RTRIM(LEFT(@InputStr, @Index - 1)))
			IF @FacilityCode <> ''
			BEGIN
				--SET @OrderNumber = @OrderNumber + 1
				INSERT INTO @ResultTable (DeptCode, FacilityCode) 
				VALUES (@DeptCode, CAST(@FacilityCode AS int)) --Use appropriate conversion
			END
			SET @InputStr = RIGHT(@InputStr, LEN(@InputStr) - @Index)
			SET @Index = CHARINDEX(',', @InputStr, 1)

		END
	END	
	RETURN
END
 