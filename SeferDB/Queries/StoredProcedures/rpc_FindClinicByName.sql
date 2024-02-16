if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rpc_FindClinicByName]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[rpc_FindClinicByName]
GO

CREATE procedure [dbo].[rpc_FindClinicByName]
@ClinicName varchar(50)
as

Select dept.deptCode, CAST(dept.deptCode as varchar(10)) + ' ' + rtrim(ltrim(dept.deptName))  as ClinicName
FROM dept
WHERE status=1
AND (deptName like '%'+ @ClinicName+'%' OR CAST(dept.deptCode as varchar(10)) like '%'+ @ClinicName+'%')
ORDER BY dept.deptName

GO

GRANT EXEC ON dbo.rpc_FindClinicByName TO PUBLIC
GO

