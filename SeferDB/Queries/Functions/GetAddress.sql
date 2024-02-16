IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'GetAddress')
	BEGIN
		PRINT 'Dropping Function GetAddress'
		DROP  Function  GetAddress
	END
GO

PRINT 'Creating Function GetAddress'
GO     
CREATE FUNCTION [dbo].[GetAddress]
(
	@DeptCode int
)
RETURNS varchar(600)

AS
BEGIN
	DECLARE @Address varchar(600)
	DECLARE @Index int
    DECLARE @apostraphe varchar(10)
    --set @apostraphe = escape "\"
	SET @Address = (
		--SELECT CASE ISNULL(LEN(dept.StreetCode),'0') WHEN '0' THEN '' ELSE /*'רח' + '''' + ' '+*/ RTRIM(LTRIM(streetName)) END
		SELECT CASE ISNULL(LEN(dept.streetName),'0') WHEN '0' THEN '' ELSE  RTRIM(LTRIM(streetName)) END
			+ CASE ISNULL(LEN(house),'0') WHEN '0' THEN '' ELSE ' ' + house END 
			+ CASE ISNULL(LEN(floor),'0') WHEN '0' THEN '' ELSE ', קומה ' + floor END
			+ CASE ISNULL(LEN(flat),'0') WHEN '0' THEN '' ELSE ', חדר ' + flat END
			+ ISNULL(CASE WHEN dept.IsSite = 1 THEN Atarim.InstituteName ELSE Neighbourhoods.NybName END, '')
			+ CASE ISNULL(LEN(addressComment),'0') WHEN '0' THEN '' ELSE ', ' + addressComment END
		FROM dept
		LEFT JOIN Atarim ON dept.NeighbourhoodOrInstituteCode = Atarim.InstituteCode
		LEFT JOIN Neighbourhoods ON dept.NeighbourhoodOrInstituteCode = Neighbourhoods.NeighbourhoodCode
		WHERE deptCode = @DeptCode
		)

	IF CHARINDEX(',', @Address, 1) = 1	/* clear ',' at first position */
		BEGIN
			SET @Address = SUBSTRING( @Address, 2, LEN(@Address) - 1 )
		END
	IF ISNUMERIC(@Address) = 1	/* reasonable address can't be just a number*/
		BEGIN
			SET @Address = ''
		END
	RETURN (CASE CAST(ISNULL(@Address,0) as varchar(600)) WHEN '0' THEN '' ELSE @Address END)
END

GO


GRANT EXEC ON GetAddress TO PUBLIC
GO
            