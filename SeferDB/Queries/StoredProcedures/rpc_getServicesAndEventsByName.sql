IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getServicesAndEventsByName')
	BEGIN
		DROP  Procedure  rpc_getServicesAndEventsByName
	END

GO
 
CREATE Procedure dbo.rpc_getServicesAndEventsByName
	(
	@SearchString varchar(50),
	@IsInCommunity bit,
	@IsInMushlam bit, 
	@IsInHospitals bit
	)

AS
select top 1000 * into #tmpTable from
(
SELECT code, description, showOrder FROM
(
	SELECT code, description, showOrder FROM
	(
		SELECT serviceCode as code, rtrim(ltrim(serviceDescription)) as description, showOrder = 0
		FROM [Services] as s
		WHERE 
			(@IsInCommunity = 1 and s.IsInCommunity = 1
				or @IsInMushlam = 1 and  s.IsInMushlam = 1
				or @IsInHospitals = 1 and s.IsInHospitals = 1)
			AND serviceDescription like @SearchString + '%'

		UNION

		SELECT EventCode as code, rtrim(ltrim(EventName)) as description, showOrder = 0
		FROM DIC_Events
		WHERE 
			IsActive = 1
			
			and EventName like @SearchString + '%'

		UNION 

		SELECT s.serviceCode as code, rtrim(ltrim(s.serviceDescription)) as description, showOrder = 0
		FROM ServiceSynonym as syn
		INNER JOIN [services] s ON syn.serviceCode = s.ServiceCode
		WHERE 
			(@IsInCommunity = 1 and s.IsInCommunity = 1
				or @IsInMushlam = 1 and  s.IsInMushlam = 1
				or @IsInHospitals = 1 and s.IsInHospitals = 1)
			AND ServiceSynonym like @SearchString + '%'
		
	) as T1
	
	UNION

	SELECT code, description, showOrder FROM
	(
		SELECT serviceCode as code, rtrim(ltrim(serviceDescription)) as description, showOrder = 1
		FROM [Services] as s
		WHERE 
			(@IsInCommunity = 1 and s.IsInCommunity = 1
				or @IsInMushlam = 1 and  s.IsInMushlam = 1
				or @IsInHospitals = 1 and s.IsInHospitals = 1)
			and (serviceDescription like '%' + @SearchString + '%' AND serviceDescription NOT like @SearchString + '%')

		UNION

		SELECT EventCode as code, rtrim(ltrim(EventName)) as description, showOrder = 1
		FROM DIC_Events
		WHERE 
			IsActive = 1
			AND(EventName like '%' + @SearchString + '%' AND EventName NOT like @SearchString + '%')

		UNION

		SELECT s.serviceCode as code, rtrim(ltrim(s.serviceDescription)) as description, showOrder = 0
		FROM ServiceSynonym as syn
		INNER JOIN [services] s ON syn.serviceCode = s.ServiceCode
		WHERE 
			(@IsInCommunity = 1 and s.IsInCommunity = 1
				or @IsInMushlam = 1 and  s.IsInMushlam = 1
				or @IsInHospitals = 1 and s.IsInHospitals = 1)
			AND ServiceSynonym like '%' + @SearchString + '%' 
			AND ServiceSynonym NOT like @SearchString + '%'
		 
	) as T2

) as T3

) as tmp



Select code, [description] 
from (
select code, [description], showorder , 
ROW_NUMBER() OVER (partition by code, [description] order by code, [description]) as r 
  from #tmpTable) as a 
  where a.r = 1 
  order by showorder, [description]

GO

GRANT EXEC ON rpc_getServicesAndEventsByName TO PUBLIC

GO

