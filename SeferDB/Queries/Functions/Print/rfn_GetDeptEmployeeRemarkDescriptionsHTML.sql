IF EXISTS (SELECT * FROM sysobjects WHERE name = 'rfn_GetDeptEmployeeRemarkDescriptionsHTML')
	BEGIN
		DROP  FUNCTION  rfn_GetDeptEmployeeRemarkDescriptionsHTML
	END

GO

CREATE function [dbo].[rfn_GetDeptEmployeeRemarkDescriptionsHTML](@DeptEmployeeID bigint) 
RETURNS varchar(500)
WITH EXECUTE AS CALLER

AS
BEGIN

	declare @RemarksStr varchar(500) 
	set @RemarksStr = ''
	
	SELECT @RemarksStr = @RemarksStr +  CASE @RemarksStr WHEN '' THEN '' ELSE '<br>' END + REPLACE(RemarkText, '#', '') 
	FROM
		(select distinct EmployeeRemarks.EmployeeRemarkID, EmployeeRemarks.RemarkText
		from x_Dept_Employee_EmployeeRemarks as xDER
		inner join EmployeeRemarks on xDER.EmployeeRemarkID = EmployeeRemarks.EmployeeRemarkID
			and xDER.DeptEmployeeID = @DeptEmployeeID 
			
		) as d 
	order by d.RemarkText
	
	return (@RemarksStr);
end 

go 
grant exec on rfn_GetDeptEmployeeRemarkDescriptionsHTML to public 
go
