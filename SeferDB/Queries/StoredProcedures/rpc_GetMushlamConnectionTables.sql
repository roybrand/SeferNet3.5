IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetMushlamConnectionTables')
	BEGIN
		DROP  Procedure  rpc_GetMushlamConnectionTables
	END

GO



CREATE Procedure dbo.rpc_GetMushlamConnectionTables
(
	@tableCode INT,
	@seferServiceName VARCHAR(100),
	@mushlamServiceName VARCHAR(100)
)

AS


--MushlamSpecialities

select MushlamTableCode,
dTN.TableName,
MF51.Code as MushlamCode,
MF51.Description as MushlamDescription,
null as subCode,
null as ParentCode,
'' as ParentDescription,
MSTS.ID,
S.ServiceCode as SeferServiceCode,
S.ServiceDescription as SeferServiceDescription
from MushlamSpecialityToSefer MSTS join [Services] S
on MSTS.SeferServiceCode = S.ServiceCode
join MF_Specialities051 MF51 
on MSTS.MushlamServiceCode = MF51.Code
join Dic_tablesName dTN 
on MSTS.MushlamTableCode = dTN.tableCode
where (MSTS.MushlamTableCode = @tableCode or @tableCode is null)
and (S.ServiceDescription like '%' + @seferServiceName + '%'
	or @seferServiceName is null)
and (MF51.Description like '%' + @mushlamServiceName + '%'
	or @mushlamServiceName is null)

Union

--MushlamSubSpecialities
select MSSTS.MushlamTableCode,
dTM.TableName,
null as MushlamCode,
MSS.SubSpecialityName as MushlamDescription,
MSSTS.MushlamServiceCode as subCode,
MSSTS.ParentCode as ParentCode,
MF51.Description as ParentDescription,
MSSTS.ID,
S.ServiceCode as SeferServiceCode,
S.ServiceDescription as SeferServiceDescription
from MushlamSubSpecialityToSefer MSSTS
join Dic_tablesName dTM on MSSTS.MushlamTableCode = dTM.TableCode
join MushlamSubSpecialities MSS on MSSTS.MushlamServiceCode = MSS.SubSpecialityCode
and MSSTS.ParentCode = MSS.SpecialityCode
join [Services] S on MSSTS.SeferServiceCode = S.ServiceCode
join MF_Specialities051 MF51 on MSSTS.ParentCode = MF51.Code
where (MSSTS.MushlamTableCode = @tableCode or @tableCode is null)
and (S.ServiceDescription like '%' + @seferServiceName + '%'
	or @seferServiceName is null)
and (MSS.SubSpecialityName like '%' + @mushlamServiceName + '%'
	or @mushlamServiceName is null)

Union

--MushlamTreatmentTypesToSefer
select '15' as MushlamTableCode,
'סוגי טיפול' as TableName,
MTTTS.MushlamCode,
MTTTS.Description as MushlamDescription,
null as subCode,
MTTTS.ParentServiceID as ParentCode,
'ParentDescription' = 
(select ServiceDescription from Services
 where ServiceCode=MTTTS.ParentServiceID),
MTTTS.ID,
S.ServiceCode as SeferServiceCode,
S.ServiceDescription as SeferServiceDescription
from MushlamTreatmentTypesToSefer MTTTS
join [Services] S on MTTTS.SeferCode = S.ServiceCode
where (@tableCode = 15 or @tableCode is null)
and (S.ServiceDescription like '%' + @seferServiceName + '%'
	or @seferServiceName is null)
and (MTTTS.Description like '%' + @mushlamServiceName + '%'
	or @mushlamServiceName is null)

Union

--MushlamServicesToSefer
select
'18' as MushlamTableCode,
'שירותי מושלם' as TableName,
MSTS.GroupCode as MushlamCode,
MSI.MushlamServiceName as MushlamDescription,
MSTS.SubGroupCode as subCode,
null as ParentCode,
'' as ParentDescription,
MSTS.ID,
MSTS.SeferCode as SeferServiceCode,
S.ServiceDescription as SeferServiceDescription
from MushlamServicesToSefer MSTS
join MushlamServicesInformation MSI
on MSTS.GroupCode = MSI.GroupCode and MSTS.SubGroupCode = MSI.SubGroupCode
join Services S on MSTS.SeferCode = S.ServiceCode
where (@tableCode = 18 or @tableCode is null)
and (S.ServiceDescription like '%' + @seferServiceName + '%'
	or @seferServiceName is null)
and (MSI.MushlamServiceName like '%' + @mushlamServiceName + '%'
	or @mushlamServiceName is null)


GO


GRANT EXEC ON rpc_GetMushlamConnectionTables TO PUBLIC

GO



