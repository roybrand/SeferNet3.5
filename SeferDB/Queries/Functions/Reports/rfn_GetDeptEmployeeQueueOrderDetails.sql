IF EXISTS (SELECT * FROM sysobjects WHERE type = 'TF' AND name = 'rfn_GetDeptEmployeeQueueOrderDetails')
	BEGIN
		DROP  FUNCTION  dbo.rfn_GetDeptEmployeeQueueOrderDetails
	END

GO

create function dbo.rfn_GetDeptEmployeeQueueOrderDetails
 (
	@deptCode INT,
	@employeeCode INT
 ) 

RETURNS @ResultTable table
(
QueueOrderDescription		varchar(50),
QueueOrderClinicTelephone	varchar(100),
QueueOrderSpecialTelephone	varchar(100),
QueueOrderTelephone2700		varchar(5),
QueueOrderInternet			varchar(5)
)
as

begin

declare @specPhones varchar(200)
set @specPhones = ''


insert into @ResultTable
----------------------------------------------------------

----------------------------------------------------------
SELECT 
CASE WHEN dic.PermitOrderMethods = 1 THEN '' ELSE dic.QueueOrderDescription END as EmpQueueOrderDescription,
case when OrderMethod1.QueueOrderMethod is not null  
	then(	SELECT TOP 1 dbo.fun_ParsePhoneNumberWithExtension(DeptPhones.preprefix,DeptPhones.prefix,DeptPhones.phone,DeptPhones.extension) 
			FROM DeptPhones 
			WHERE DeptCode = @deptCode 
			AND DeptPhones.PhoneType = 1 
			ORDER BY PhoneOrder)
	else '' END AS QueueOrderClinicTelephone,

case when OrderMethod2.QueueOrderMethod is not null 
	then dbo.rfn_GetDeptEmployeeQueueOrderSpecialPhones(OrderMethod2.QueueOrderMethodID)
	else '' end as QueueOrderSpecialTelephone,

case when de.QueueOrder <> 3 then ''
	 when de.QueueOrder = 3 and OrderMethod3.QueueOrderMethod is not null then 'כן' 
	 when de.QueueOrder = 3 and OrderMethod3.QueueOrderMethod is null then 'לא'
	end as QueueOrderTelephone2700, 
case when de.QueueOrder <> 3 then ''
	 when de.QueueOrder = 3 and OrderMethod4.QueueOrderMethod is not null then 'כן' 
	 when de.QueueOrder = 3 and OrderMethod4.QueueOrderMethod is null then 'לא'
	 end as QueueOrderInternet 

FROM x_Dept_Employee as de  
join x_Dept_Employee on  x_Dept_Employee.DeptEmployeeID = de.DeptEmployeeID 
	and de.deptCode = @deptCode
	and de.employeeID = @employeeCode
left JOIN DIC_QueueOrder as dic ON de.QueueOrder = dic.QueueOrder

left join EmployeeQueueOrderMethod as OrderMethod1 on de.DeptEmployeeID = OrderMethod1.DeptEmployeeID	
	and OrderMethod1.QueueOrderMethod = 1 
left join EmployeeQueueOrderMethod as OrderMethod2 on de.DeptEmployeeID = OrderMethod2.DeptEmployeeID	
	and OrderMethod2.QueueOrderMethod = 2

left join EmployeeQueueOrderMethod as OrderMethod3 on de.DeptEmployeeID = OrderMethod3.DeptEmployeeID
	and OrderMethod3.QueueOrderMethod = 3 
left join EmployeeQueueOrderMethod as OrderMethod4 on de.DeptEmployeeID = OrderMethod4.DeptEmployeeID
	and OrderMethod4.QueueOrderMethod = 4 
--------------------------------------------------

return
end
GO