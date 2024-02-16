-- =============================================
-- Author:		Daniel	
-- Create date: 24.08.15
-- Description:	Get All Cities
-- =============================================
CREATE PROCEDURE Competitors_GetCities 
		
AS
BEGIN

	SET NOCOUNT ON;

    SELECT [cityCode],[cityName]
    FROM [dbo].[Cities]
    ORDER BY cityName ASC

END
GO


GRANT EXEC ON Competitors_GetCities TO [clalit\CatWebSqlDev]
GO

GRANT EXEC ON Competitors_GetCities TO [clalit\drugsweb]
GO
