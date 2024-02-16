IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetMushlamServicesForSalService')
	BEGIN
		DROP  Procedure  rpc_GetMushlamServicesForSalService		
	END

GO

CREATE Procedure [dbo].[rpc_GetMushlamServicesForSalService]
(
	@SalServiceCode int
)

AS

SELECT msi.ServiceCode, msi.MushlamServiceName as ServiceName
,msi.GroupCode, msi.SubGroupCode
FROM MF_SalServices386 ss
join dbo.MushlamServicesToSal ms on ss.ServiceCode = ms.SalServiceCode
INNER JOIN MushlamServicesInformation msi on ms.MushlamGroupCode = msi.GroupCode
		and ms.MushlamSubGroupCode = msi.SubGroupCode
where ss.ServiceCode = @SalServiceCode

UNION 

SELECT msi.ServiceCode,
msi.MushlamServiceName + ' - ' + mtts.Description as ServiceName
,msi.GroupCode, msi.SubGroupCode
FROM MF_SalServices386 ss
join dbo.MushlamServicesToSal ms on ss.ServiceCode = ms.SalServiceCode
INNER JOIN MushlamServicesInformation msi on ms.MushlamGroupCode = msi.GroupCode
		and ms.MushlamSubGroupCode = msi.SubGroupCode
inner join MushlamTreatmentTypesToSefer mtts ON msi.ServiceCode = mtts.SeferCode
where ss.ServiceCode = @SalServiceCode
ORDER BY msi.MushlamServiceName

GO


GRANT EXEC ON rpc_GetMushlamServicesForSalService TO PUBLIC
GO