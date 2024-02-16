IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getCitiesByName')
	BEGIN
		DROP  Procedure  rpc_getCitiesByName
	END

GO

CREATE procedure [dbo].[rpc_getCitiesByName]

@SearchStr varchar(20)

as

SELECT [cityCode], [cityName], [districtCode] FROM [Cities]
where cityName like @SearchStr+'%' order by cityName

GO


GRANT EXEC ON rpc_getCitiesByName TO PUBLIC

GO


