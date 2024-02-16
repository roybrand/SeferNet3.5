IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vMushlamCervices]'))
DROP VIEW [dbo].[vMushlamCervices]
GO

CREATE VIEW [dbo].[vMushlamCervices]

AS

SELECT distinct ser.ServiceCode,
MushlamServiceName + ' - ' + mtt.Description as MushlamServiceName,
msi.PrivateRemark, msi.AgreementRemark,
mtt.Description as TreatmentDescription
,msi.GroupCode
,msi.SubGroupCode
,msi.ServiceCode as originalServiceCode
FROM [Services] ser 
INNER JOIN MushlamTreatmentTypesToSefer mtt ON ser.ServiceCode = mtt.SeferCode
INNER JOIN MushlamServicesInformation msi ON mtt.ParentServiceID = msi.ServiceCode
WHERE IsInMushlam = 1

UNION

SELECT distinct ser.ServiceCode,
case when MushlamServiceName = ser.ServiceDescription then MushlamServiceName
		else MushlamServiceName + ' - ' + ser.ServiceDescription end 
as MushlamServiceName, 
msi.PrivateRemark, msi.AgreementRemark,
'' as TreatmentDescription
,msi.GroupCode
,msi.SubGroupCode
,msi.ServiceCode as originalServiceCode
FROM [Services] ser 
INNER JOIN MushlamServicesToSefer mss on ser.ServiceCode = mss.SeferCode
INNER JOIN MushlamServicesInformation msi ON mss.GroupCode = msi.GroupCode and mss.SubGroupCode = msi.SubGroupCode
WHERE IsInMushlam = 1

GO
