IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_OrganizationTree')
	BEGIN
		DROP  Procedure  rpc_OrganizationTree
	END

GO

create procedure [dbo].[rpc_OrganizationTree]
as
select 
d1.deptCode as distCode, 
d1.deptName as distName, 
d2.deptCode as adminCode, 
d2.deptName as admiName, 
d3.deptCode as clinicCode, 
d3.deptName as clinicName
from dept d1
join dept d2 on d1.deptCode = d2.districtCode
join dept d3 on d2.deptCode = d3.administrationCode

where d2.deptType = 2
and d1.deptType = 1
and d3.deptType = 3
ORDER BY distCode, adminCode, clinicCode

GO


GRANT EXEC ON rpc_OrganizationTree TO PUBLIC

GO


