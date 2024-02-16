 
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'TF' AND name = 'rfn_GetDeptQueueOrderDetails')
	BEGIN
		DROP  FUNCTION  dbo.rfn_GetDeptQueueOrderDetails
	END

GO

create function dbo.rfn_GetDeptQueueOrderDetails
 (
	@deptCode INT
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

--set @deptCode = 43300
--set @employeeCode = 14407514
declare @specPhones varchar(200)
set @specPhones = ''


insert into @ResultTable
----------------------------------------------------------
SELECT dic.QueueOrderDescription as QueueOrderDescription,
case when OrderMethod1.QueueOrderMethod is not null  
	then(	SELECT TOP 1 dbo.fun_ParsePhoneNumberWithExtension(DeptPhones.preprefix,DeptPhones.prefix,DeptPhones.phone,DeptPhones.extension) 
			FROM DeptPhones 
			WHERE DeptCode = @deptCode 
			AND DeptPhones.PhoneType = 1 
			ORDER BY PhoneOrder)
	else '' END AS QueueOrderClinicTelephone,

case when OrderMethod2.QueueOrderMethod is not null 
	then dbo.rfn_GetDeptQueueOrderSpecialPhones(OrderMethod2.QueueOrderMethodID)
	else '' end as QueueOrderSpecialTelephone,

case when OrderMethod3.QueueOrderMethod is not null then 'כן' else 'לא' end as QueueOrderTelephone2700, 
case when OrderMethod4.QueueOrderMethod is not null then 'כן' else 'לא' end as QueueOrderInternet 

FROM Dept as de  
join dept on dept.deptCode = de.deptCode and  de.deptCode = @deptCode
left JOIN DIC_QueueOrder as dic ON de.QueueOrder = dic.QueueOrder

left join DeptQueueOrderMethod as OrderMethod1 on de.DeptCode = OrderMethod1.DeptCode
	and OrderMethod1.QueueOrderMethod = 1 

left join DeptQueueOrderMethod as OrderMethod2 on de.DeptCode = OrderMethod2.DeptCode
	and OrderMethod2.QueueOrderMethod = 2

left join DeptQueueOrderMethod as OrderMethod3 on de.DeptCode = OrderMethod3.DeptCode
	and OrderMethod3.QueueOrderMethod = 3 

left join DeptQueueOrderMethod as OrderMethod4 on de.DeptCode = OrderMethod4.DeptCode
	and OrderMethod4.QueueOrderMethod = 4 
--LEFT JOIN DeptEmployeeQueueOrderPhones phones ON phones.QueueOrderMethodID = OrderMethod2.QueueOrderMethodID

--WHERE 
--de.deptCode = @deptCode
--and 
--de.QueueOrder is not null
--order by EmpQueueOrderDescription
--------------------------------------------------

return
end

