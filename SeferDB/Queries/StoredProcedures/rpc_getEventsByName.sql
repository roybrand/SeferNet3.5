IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEventsByName')
	BEGIN
		DROP  Procedure  rpc_getEventsByName
	END

GO

CREATE Procedure rpc_getEventsByName
	(
	@SearchString varchar(50)
	)

AS
SELECT code, description FROM
(
	SELECT code, description, showOrder FROM
	(
		SELECT EventCode as code, rtrim(ltrim(EventName)) as description, showOrder = 0
		FROM DIC_Events
		WHERE EventName like @SearchString + '%'
		AND IsActive = 1
	) as T1
	
	UNION

	SELECT code, description, showOrder FROM
	(
		SELECT EventCode as code, rtrim(ltrim(EventName)) as description, showOrder = 1
		FROM DIC_Events
		WHERE (EventName like '%' + @SearchString + '%' AND EventName NOT like @SearchString + '%')
		AND IsActive = 1
	) as T2
) as T3
ORDER BY showOrder, description

GO

GRANT EXEC ON rpc_getEventsByName TO PUBLIC

GO

