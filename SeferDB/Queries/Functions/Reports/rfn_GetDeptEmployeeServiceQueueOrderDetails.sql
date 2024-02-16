IF EXISTS (SELECT * FROM sysobjects WHERE type = 'TF' AND name = 'rfn_GetDeptEmployeeServiceQueueOrderDetails')
	BEGIN
		DROP  FUNCTION  dbo.rfn_GetDeptEmployeeServiceQueueOrderDetails
	END

GO

create function dbo.rfn_GetDeptEmployeeServiceQueueOrderDetails
 (
	@deptCode INT,
	@employeeCode INT,
	@serviceCode INT
 ) 

RETURNS @ResultTable table
(
QueueOrderDescription		varchar(100),
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
	then dbo.rfn_GetDeptEmployeeServiceQueueOrderSpecialPhones(OrderMethod2.EmployeeServiceQueueOrderMethodID)
	else '' end as QueueOrderSpecialTelephone,

case when xDES.QueueOrder <> 3 then ''
	 when xDES.QueueOrder = 3 and OrderMethod3.QueueOrderMethod is not null then 'כן' 
	 when xDES.QueueOrder = 3 and OrderMethod3.QueueOrderMethod is null then 'לא'
	end as QueueOrderTelephone2700, 
case when xDES.QueueOrder <> 3 then ''
	 when xDES.QueueOrder = 3 and OrderMethod4.QueueOrderMethod is not null then 'כן' 
	 when xDES.QueueOrder = 3 and OrderMethod4.QueueOrderMethod is null then 'לא'
	 end as QueueOrderInternet 

FROM x_Dept_Employee
join x_Dept_Employee_Service xDES on x_Dept_Employee.DeptEmployeeID = xDES.DeptEmployeeID 
	and x_Dept_Employee.deptCode = @deptCode
	and x_Dept_Employee.employeeID = @employeeCode
	and xDES.serviceCode = @serviceCode
	
left JOIN DIC_QueueOrder as dic ON xDES.QueueOrder = dic.QueueOrder

left join EmployeeServiceQueueOrderMethod as OrderMethod1 on xDES.x_Dept_Employee_ServiceID = OrderMethod1.x_dept_employee_serviceID	
	and OrderMethod1.QueueOrderMethod = 1 
left join EmployeeServiceQueueOrderMethod as OrderMethod2 on xDES.x_Dept_Employee_ServiceID = OrderMethod2.x_dept_employee_serviceID	
	and OrderMethod2.QueueOrderMethod = 2

left join EmployeeServiceQueueOrderMethod as OrderMethod3 on xDES.x_Dept_Employee_ServiceID = OrderMethod3.x_dept_employee_serviceID
	and OrderMethod3.QueueOrderMethod = 3 
left join EmployeeServiceQueueOrderMethod as OrderMethod4 on xDES.x_Dept_Employee_ServiceID = OrderMethod4.x_dept_employee_serviceID
	and OrderMethod4.QueueOrderMethod = 4 
--------------------------------------------------

return
end
GO
