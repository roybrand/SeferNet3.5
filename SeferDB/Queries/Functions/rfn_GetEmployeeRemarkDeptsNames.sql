 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'TF' AND name = 'rfn_GetEmployeeRemarkDeptsNames')
	BEGIN
		PRINT 'Dropping function rfn_GetEmployeeRemarkDeptsNames'
		DROP  function rfn_GetEmployeeRemarkDeptsNames
	END

GO

PRINT 'Creating function rfn_GetEmployeeRemarkDeptsNames'
GO
create function dbo.rfn_GetEmployeeRemarkDeptsNames(@RemarkID int,@EmployeeID int) 
RETURNS varchar(2000)
AS
BEGIN
declare @DeptsNames varchar(2000) 
 
set @DeptsNames = '' 

select @DeptsNames = @DeptsNames + DeptName + ';'
from (
Select distinct deptName as DeptName 
from dbo.x_Dept_Employee_EmployeeRemarks as r 
inner join Dept as d
on r.DeptCode = d.DeptCode 
where r.EmployeeRemarkID = @RemarkID
r.EmployeeID = @EmployeeID) as tblDepts
where DeptName is not null 

 return @DeptsNames 
end 

GRANT exec ON rfn_GetEmployeeRemarkDeptsNames TO public

GO


