-- =============================================
--	Owner : Internet Team
-- =============================================
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetCitiesByAdministration')
	BEGIN
		DROP  Procedure  [rpc_GetCitiesByAdministration]
	END

GO

CREATE Procedure [dbo].[rpc_GetCitiesByAdministration]
(
	@Prefix varchar(50) = null,
	@AdministrationCodes varchar(max)
)
 
AS

	declare @Sql varchar(max)   
	declare @WhereSql varchar(4000)

	IF @AdministrationCodes = 'ALL'
	BEGIN
		select @Sql = 'SELECT DISTINCT Cities.cityName, Dept.cityCode FROM Dept
						INNER JOIN Cities ON Cities.cityCode = Dept.cityCode 
						WHERE    Cities.cityName LIKE ''' + @Prefix + '%'' ORDER BY Cities.cityName'
	END
	ELSE IF @AdministrationCodes <> '0'
	BEGIN
		select @Sql = 'SELECT DISTINCT Cities.cityName, Dept.cityCode FROM Dept
						INNER JOIN Cities ON Cities.cityCode = Dept.cityCode
						WHERE     administrationCode In (' + @AdministrationCodes + ') AND Cities.cityName LIKE ''' + @Prefix + '%'' ORDER BY Cities.cityName'
	END

	exec(@Sql) 


GO

GRANT EXEC ON [rpc_GetCitiesByAdministration] TO PUBLIC

GO

