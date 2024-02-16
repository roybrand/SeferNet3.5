 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_GetServiceCategories')
	BEGIN
		DROP  function  fun_GetServiceCategories
	END
GO

CREATE FUNCTION [dbo].[fun_GetServiceCategories]
(
	@ServiceCode int
)
RETURNS varchar(500)
AS
BEGIN
 
    DECLARE @categories VARCHAR(500)
    SET @categories = ''
    

-- Categories *****
SELECT @categories = @categories + CONVERT(varchar,ServiceCategoryDescription) + ', '
FROM x_ServiceCategories_Services xsc
INNER JOIN ServiceCategories sc on xsc.ServiceCategoryID = sc.ServiceCategoryID
WHERE xsc.ServiceCode = @ServiceCode

IF LEN(@categories) > 0
	SET @categories = SUBSTRING(@categories, 1, LEN(@categories) - 1)
	
RETURN @categories

END

GO

GRANT EXEC ON fun_GetServiceCategories to public 
GO