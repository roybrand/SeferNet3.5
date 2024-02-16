IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetEmpRemarksForUpdate')
	BEGIN
		DROP  Procedure  rpc_GetEmpRemarksForUpdate
	END

GO

create Procedure [dbo].[rpc_GetEmpRemarksForUpdate](@EmployeeID int, @UserName varchar(20))
AS

declare @UserPermission int  
declare @UserPermissionType int  

Select @UserPermission = deptCode, 
	@UserPermissionType = PermissionType  
from  UserPermissions
where username = @UserName

--print '@UserPermission:'  + str(@UserPermission) 
--print '@UserPermissionType:'  + str(@UserPermissionType) 

-- Current Remarks 
Select RecordType , RemarkID, RemarkText, RemarkTemplate, ValidFrom, ValidTo, Internetdisplay, Deleted, 
UserEditPermission, nDepts,  AreasNames, DeptsCodes
from 
(
Select RecordType , RemarkID, RemarkText, RemarkTemplate, ValidFrom, ValidTo, Internetdisplay, Deleted, 
case 
	when  UserEditPermission = 1 and @UserPermissionType = 1  and nDepts > 1 then 0 
	else UserEditPermission
end  as UserEditPermission, nDepts, AreasNames, DeptsCodes
from(
Select  distinct 1 as RecordType, er.EmployeeRemarkID as RemarkID, RemarkText as RemarkText,  
case 
	when dgr.Remark  is not null then dgr.Remark  
	else '' 
end as RemarkTemplate , convert(varchar, ValidFrom, 103) as ValidFrom, convert(varchar, ValidTo , 103)  as ValidTo ,
displayInInternet as Internetdisplay, 0 as Deleted , 
case  
	when @UserPermissionType = 5 then 1 
	when xDept.DeptCode is not null and @UserPermissionType = 1 and @UserPermission = DeptCode then 1
	else 0 
end as UserEditPermission ,  
		(Select count(distinct xDept2.DeptCode) 
		from x_Dept_Employee_EmployeeRemarks as xDept2
		where xDept2.EmployeeRemarkID = er.EmployeeRemarkID 
		and xDept2.EmployeeID = er.EmployeeID ) as nDepts , 
		dbo.rfn_GetEmployeeRemarkDeptsNames(er.EmployeeRemarkID,@EmployeeID )  as  AreasNames, 
		dbo.rfn_GetEmployeeRemarkDeptsNames(er.EmployeeRemarkID,@EmployeeID )  as  DeptsCodes 
from EmployeeRemarks as er 
left join dbo.DIC_GeneralRemarks as dgr 
on er.DicRemarkID = dgr.RemarkID 
left join x_Dept_Employee_EmployeeRemarks as xDept 
on er.EmployeeRemarkID = xDept.EmployeeRemarkID 
and er.EmployeeID = xDept.EmployeeID 
Where dbo.rfn_IsDatesCurrent(validFrom, validTo, getdate()) = 1  
and er.EmployeeID = @EmployeeID
) as tblCurrent ) as tblFinalCurrent 
Order by UserEditPermission Desc 


-- Future Remarks 
Select RecordType , RemarkID, RemarkText, RemarkTemplate, ValidFrom, ValidTo, Internetdisplay, Deleted, 
UserEditPermission, nDepts,  AreasNames , DeptsCodes
from 
(
Select RecordType , RemarkID, RemarkText, RemarkTemplate, ValidFrom, ValidTo, Internetdisplay, Deleted, 
case 
	when  UserEditPermission = 1 and @UserPermissionType = 1  and nDepts > 1 then 0 
	else UserEditPermission
end  as UserEditPermission, nDepts, AreasNames, DeptsCodes
from(
Select  distinct 1 as RecordType, er.EmployeeRemarkID as RemarkID, RemarkText as RemarkText,  
case 
	when dgr.Remark  is not null then dgr.Remark  
	else '' 
end as RemarkTemplate , convert(varchar, ValidFrom, 103) as ValidFrom, convert(varchar, ValidTo , 103)  as ValidTo ,
displayInInternet as Internetdisplay, 0 as Deleted , 
case  
	when @UserPermissionType = 5 then 1 
	when xDept.DeptCode is not null and @UserPermissionType = 1 and @UserPermission = DeptCode then 1
	else 0 
end as UserEditPermission ,  
		(Select count(distinct xDept2.DeptCode) 
		from x_Dept_Employee_EmployeeRemarks as xDept2
		where xDept2.EmployeeRemarkID = er.EmployeeRemarkID 
		and xDept2.EmployeeID = er.EmployeeID ) as nDepts , 
		dbo.rfn_GetEmployeeRemarkDeptsNames(er.EmployeeRemarkID,@EmployeeID )  as  AreasNames, 
		dbo.rfn_GetEmployeeRemarkDeptsNames(er.EmployeeRemarkID,@EmployeeID )  as  DeptsCodes 
from EmployeeRemarks as er 
left join dbo.DIC_GeneralRemarks as dgr 
on er.DicRemarkID = dgr.RemarkID 
left join x_Dept_Employee_EmployeeRemarks as xDept 
on er.EmployeeRemarkID = xDept.EmployeeRemarkID 
and er.EmployeeID = xDept.EmployeeID 
Where ValidFrom > getdate() 
and er.EmployeeID = @EmployeeID
) as tblCurrent ) as tblFinalCurrent 
Order by UserEditPermission Desc 




-- Historic Remarks 
Select RecordType , RemarkID, RemarkText, RemarkTemplate, ValidFrom, ValidTo, Internetdisplay, Deleted, 
UserEditPermission, nDepts,  AreasNames , DeptsCodes
from 
(
Select RecordType , RemarkID, RemarkText, RemarkTemplate, ValidFrom, ValidTo, Internetdisplay, Deleted, 
case 
	when  UserEditPermission = 1 and @UserPermissionType = 1  and nDepts > 1 then 0 
	else UserEditPermission
end  as UserEditPermission, nDepts, AreasNames, DeptsCodes
from(
Select  distinct 1 as RecordType, er.EmployeeRemarkID as RemarkID, RemarkText as RemarkText,  
case 
	when dgr.Remark  is not null then dgr.Remark  
	else '' 
end as RemarkTemplate , convert(varchar, ValidFrom, 103) as ValidFrom, convert(varchar, ValidTo , 103)  as ValidTo ,
displayInInternet as Internetdisplay, 0 as Deleted , 
case  
	when @UserPermissionType = 5 then 1 
	when xDept.DeptCode is not null and @UserPermissionType = 1 and @UserPermission = DeptCode then 1
	else 0 
end as UserEditPermission ,  
		(Select count(distinct xDept2.DeptCode) 
		from x_Dept_Employee_EmployeeRemarks as xDept2
		where xDept2.EmployeeRemarkID = er.EmployeeRemarkID 
		and xDept2.EmployeeID = er.EmployeeID ) as nDepts , 
		dbo.rfn_GetEmployeeRemarkDeptsNames(er.EmployeeRemarkID,@EmployeeID )  as  AreasNames, 
		dbo.rfn_GetEmployeeRemarkDeptsNames(er.EmployeeRemarkID,@EmployeeID )  as  DeptsCodes 
from EmployeeRemarks as er 
left join dbo.DIC_GeneralRemarks as dgr 
on er.DicRemarkID = dgr.RemarkID 
left join x_Dept_Employee_EmployeeRemarks as xDept 
on er.EmployeeRemarkID = xDept.EmployeeRemarkID 
and er.EmployeeID = xDept.EmployeeID 
Where DateDiff(day, ValidTo, getdate()) >= 1
and er.EmployeeID = @EmployeeID
) as tblCurrent ) as tblFinalCurrent 
Order by UserEditPermission Desc 

GO


GRANT EXEC ON rpc_GetEmpRemarksForUpdate TO PUBLIC

GO


