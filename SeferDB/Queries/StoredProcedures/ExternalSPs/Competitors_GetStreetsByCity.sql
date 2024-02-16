-- =============================================
-- Author:		Daniel	
-- Create date: 24.08.15
-- Description:	Get Streets By City
-- =============================================
CREATE PROCEDURE Competitors_GetStreetsByCity 
		@CityCode int = 0
AS
BEGIN

	SET NOCOUNT ON;

        SELECT [MapaStreetCode],[Name]
	FROM [dbo].[Streets] s
	where s.CityCode = @CityCode
	order by name asc

END
GO


GRANT EXEC ON Competitors_GetStreetsByCity TO [clalit\CatWebSqlDev]
GO

GRANT EXEC ON Competitors_GetStreetsByCity TO [clalit\drugsweb]
GO
