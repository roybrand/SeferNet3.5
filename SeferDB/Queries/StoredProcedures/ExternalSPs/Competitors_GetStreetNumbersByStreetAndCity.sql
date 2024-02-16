-- =============================================
-- Author:		Daniel	
-- Create date: 24.08.15
-- Description:	Get Street Numbers By Street Code And City Code
-- =============================================
ALTER PROCEDURE Competitors_GetStreetNumbersByStreetAndCity
		@StreetName nvarchar(255) = '',
		@CityCode int = 0
AS
BEGIN

	SET NOCOUNT ON;

    SELECT s.HouseNumber
	FROM [dbo].[Addresses_All] s
	where s.CityCode = @CityCode and s.Street = @StreetName
	and HouseNumber > 0
	order by HouseNumber asc

END
GO

GRANT EXEC ON Competitors_GetStreetNumbersByStreetAndCity TO [clalit\CatWebSqlDev]
GO

GRANT EXEC ON Competitors_GetStreetNumbersByStreetAndCity TO [clalit\drugsweb]
GO

