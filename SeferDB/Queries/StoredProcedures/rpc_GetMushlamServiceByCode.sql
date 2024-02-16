/****** Object:  StoredProcedure [dbo].[rpc_GetMushlamServiceByCode]    Script Date: 05/15/2012 17:12:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpc_GetMushlamServiceByCode]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[rpc_GetMushlamServiceByCode]
GO

CREATE Procedure [dbo].[rpc_GetMushlamServiceByCode]
(
	@serviceCode INT
)

AS


SELECT ser.ServiceCode, msi.MushlamServiceName, GeneralRemark, AgreementRemark, PrivateRemark, EligibilityRemark,
'LinkedSalServices' = (	SELECT ';' + CONVERT(VARCHAR,ServiceCode) + '#' + ServiceName
						FROM MushlamServicesToSal msts						
						INNER JOIN MF_SalServices386 ON msts.SalServiceCode = MF_SalServices386.serviceCode
						WHERE msts.MushlamGroupCode = msi.GroupCode AND msts.MushlamSubGroupCode = msi.SubGroupCode
						FOR XML PATH('')
					   ),
RepRemark,
msi.GroupCode,
msi.SubGroupCode,
msi.ClalitRefund,
msi.SelfParticipation,
msi.RequiredDocuments
FROM [Services] ser
INNER JOIN MushlamTreatmentTypesToSefer mtt ON ser.ServiceCode = mtt.SeferCode
INNER JOIN MushlamServicesInformation msi ON mtt.ParentServiceID = msi.ServiceCode
WHERE ser.ServiceCode = @serviceCode
AND ser.IsInMushlam = 1

UNION

SELECT ser.ServiceCode, msi.MushlamServiceName, GeneralRemark, AgreementRemark, PrivateRemark, EligibilityRemark,
'LinkedSalServices' = (	SELECT ';' + CONVERT(VARCHAR,ServiceCode) + '#' + ServiceName
						FROM MushlamServicesToSal msts						
						INNER JOIN MF_SalServices386 ON msts.SalServiceCode = MF_SalServices386.serviceCode
						WHERE msts.MushlamGroupCode = msi.GroupCode 
						AND msts.MushlamSubGroupCode = msi.SubGroupCode
						AND msi.ServiceCode <> 180300
						FOR XML PATH('')
					   ),
RepRemark,
msi.GroupCode,
msi.SubGroupCode,
msi.ClalitRefund,
msi.SelfParticipation,
msi.RequiredDocuments
FROM [Services] ser 
INNER JOIN MushlamServicesToSefer mss on ser.ServiceCode = mss.SeferCode
INNER JOIN MushlamServicesInformation msi ON mss.GroupCode = msi.GroupCode and mss.SubGroupCode = msi.SubGroupCode
WHERE IsInMushlam = 1
AND ser.ServiceCode = @serviceCode


GO

GRANT EXEC ON rpc_GetMushlamServiceByCode TO PUBLIC

GO


