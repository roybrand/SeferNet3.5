IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getServicesByName')
	BEGIN
		DROP  Procedure  rpc_getServicesByName
	END

GO

CREATE Procedure rpc_getServicesByName
	(
	@SearchString varchar(50)
	)

AS

	SELECT serviceCode, serviceDescription FROM
	(
		SELECT serviceCode, rtrim(ltrim(serviceDescription)) as serviceDescription, showOrder = 0
		FROM services
		WHERE serviceDescription like @SearchString + '%'

		UNION
		
		SELECT serviceCode, rtrim(ltrim(serviceDescription)) as serviceDescription, showOrder = 1
		FROM services
		WHERE (serviceDescription like '%' + @SearchString + '%' AND serviceDescription NOT like @SearchString + '%')

	) as T1
	ORDER BY showOrder
GO

GRANT EXEC ON rpc_getServicesByName TO PUBLIC

GO

