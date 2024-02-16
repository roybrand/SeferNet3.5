 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getServicesByNameAndSector')
	BEGIN
		DROP  Procedure  rpc_getServicesByNameAndSector
	END

GO

CREATE Procedure dbo.rpc_getServicesByNameAndSector
	(
		@SearchString varchar(50)
		,@sectorCode INT
		,@IsInCommunity bit
		,@IsInMushlam bit
		,@IsInHospitals bit
	)

AS

	SELECT top 1000 serviceCode, serviceDescription 
	into #tmpTable FROM
	(
		SELECT s.serviceCode, rtrim(ltrim(s.serviceDescription)) as serviceDescription, showOrder = 0
		FROM [Services] as s
		left join x_Services_EmployeeSector as Se_EmSec
			on s.ServiceCode = Se_EmSec.ServiceCode
		WHERE 
			(	@sectorCode = -1
			or (Se_EmSec.EmployeeSectorCode is null 
				or Se_EmSec.EmployeeSectorCode = @sectorCode)
			)
			and(@IsInCommunity = 1 and s.IsInCommunity = 1
				or @IsInMushlam = 1 and  s.IsInMushlam = 1
				or @IsInHospitals = 1 and s.IsInHospitals = 1)
			
			and s.serviceDescription like @SearchString + '%'

		UNION

		SELECT s.serviceCode, rtrim(ltrim(s.serviceDescription)) as serviceDescription, showOrder = 0
		FROM ServiceSynonym syn 
		INNER JOIN [Services] as s ON syn.serviceCode = s.ServiceCode
		LEFT JOIN x_Services_EmployeeSector as Se_EmSec ON s.ServiceCode = Se_EmSec.ServiceCode
		WHERE 
			(	@sectorCode = -1
			or (Se_EmSec.EmployeeSectorCode is null 
				or Se_EmSec.EmployeeSectorCode = @sectorCode)
			)
			and(@IsInCommunity = 1 and s.IsInCommunity = 1
				or @IsInMushlam = 1 and  s.IsInMushlam = 1
				or @IsInHospitals = 1 and s.IsInHospitals = 1)
			
			and syn.ServiceSynonym like @SearchString + '%'

		UNION
		
		SELECT s.serviceCode, rtrim(ltrim(s.serviceDescription)) as serviceDescription, showOrder = 1
		FROM [Services] as s
		left join x_Services_EmployeeSector as Se_EmSec
			on s.ServiceCode = Se_EmSec.ServiceCode
		WHERE
			 (	@sectorCode = -1
			or (Se_EmSec.EmployeeSectorCode is null 
				or Se_EmSec.EmployeeSectorCode = @sectorCode)
			)
			and(@IsInCommunity = 1 and s.IsInCommunity = 1
				or @IsInMushlam = 1 and  s.IsInMushlam = 1
				or @IsInHospitals = 1 and s.IsInHospitals = 1)
			
			AND (s.serviceDescription like '%' + @SearchString + '%' 
			AND serviceDescription NOT like @SearchString + '%')

		UNION

		SELECT s.serviceCode, rtrim(ltrim(s.serviceDescription)) as serviceDescription, showOrder = 1
		FROM ServiceSynonym syn 
		INNER JOIN [Services] as s ON syn.serviceCode = s.ServiceCode
		LEFT JOIN x_Services_EmployeeSector as Se_EmSec ON s.ServiceCode = Se_EmSec.ServiceCode
		WHERE 
			(	@sectorCode = -1
			or (Se_EmSec.EmployeeSectorCode is null 
				or Se_EmSec.EmployeeSectorCode = @sectorCode)
			)
			and(@IsInCommunity = 1 and s.IsInCommunity = 1
				or @IsInMushlam = 1 and  s.IsInMushlam = 1
				or @IsInHospitals = 1 and s.IsInHospitals = 1)
			
			AND syn.ServiceSynonym like '%' + @SearchString + '%'
			AND syn.ServiceSynonym NOT like @SearchString + '%'

	) as T1
	ORDER BY showOrder, ServiceDescription

select distinct serviceCode, serviceDescription from #tmpTable
ORDER BY ServiceDescription

GO

GRANT EXEC ON rpc_getServicesByNameAndSector TO PUBLIC

GO

