IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rfn_GetDeptServicesReception')
	BEGIN
		DROP  function  dbo.rfn_GetDeptServicesReception
	END

GO

ALTER function [dbo].[rfn_GetDeptServicesReception]
 (
	@DeptCode int,
	@ValidFrom_str varchar(15),
	@ValidTo_str varchar(15),
	@ObjectType_cond varchar(10),
	@ServiceGivenBy_cond varchar(10)
 ) 
RETURNS 
@ResultTable table
(
--  ObjectType = 3 - service is clinic office; ObjectType = 2 - regular service (is not office); ObjectType = 1 - clinic 
	ObjectType varchar(10), 
	deptCode int,
	serviceCode int,
	serviceDescription varchar(100),
	serviceGivenByPersonCode int,
	serviceGivenByPerson varchar(50),
	receptionID int,
	receptionDay int,
	ReceptionDayName varchar(50),
	openingHour varchar(5),
	closingHour	varchar(5),
	totalHours	float,
	ReceptionRoom varchar(10),
	validFrom smalldateTime,
	validTo smalldateTime,
	remarkText varchar(500),
	viaPerson int
)
as

begin

----------parameters casting------------------------
declare @ValidFrom smallDateTime
declare @ValidTo smallDateTime

if (isdate(@ValidTo_str)= 0 )
	set @ValidTo = null
else
	set @ValidTo = convert(smallDateTime, @ValidTo_str, 103 )

if (isdate(@ValidFrom_str) = 0)
	set @ValidFrom = convert(smallDateTime, '1900-01-01', 103 )
else
	set @ValidFrom = convert(smallDateTime, @ValidFrom_str, 103 )



-------------Services of Doctors in Clinic --------------------------------------
--if (@ServiceGivenBy_cond ='-1' or 
--	'1' IN (SELECT IntField FROM dbo.SplitString( @ServiceGivenBy_cond )))
begin

insert into @ResultTable
SELECT

--  ObjectType = 3 - service is clinic office; ObjectType = 2 - regular service (is not office); ObjectType = 1 - clinic 
ObjectType = 2, 
x_dept_employee.deptCode,
RecServ.serviceCode,
Services.serviceDescription,
'serviceGivenByPersonCode' = x_dept_employee.employeeID,
'serviceGivenByPerson' = DegreeName + ' ' + lastName + ' ' + firstName,
recep.receptionID,
recep.receptionDay,
DIC_ReceptionDays.ReceptionDayName,
recep.openingHour,
recep.closingHour,
'totalHours' =  [dbo].rfn_TimeInterval_float(recep.openingHour, recep.closingHour),
Recep.ReceptionRoom,
recep.validFrom,
recep.validTo,
RecRemarks.remarkText,
CASE Employee.IsMedicalTeam WHEN 0 THEN 1 ELSE 0 END  as viaPerson

FROM x_dept_employee

inner join [dbo].DeptEmployeeReception as Recep  
	on x_dept_employee.deptCode = @DeptCode
	and	x_dept_employee.DeptEmployeeID = recep.DeptEmployeeID 

inner join dbo.deptEmployeeReceptionServices as RecServ on recep.receptionID = RecServ.receptionID  

INNER JOIN Services	ON RecServ.serviceCode = Services.serviceCode and 
	(@ObjectType_cond = '-1' or
	2 IN (SELECT IntField FROM dbo.SplitString( @ObjectType_cond )))-- @ObjectType_cond
	
INNER JOIN Employee ON x_dept_employee.employeeID = Employee.employeeID
INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode

left JOIN DIC_ReceptionDays on recep.receptionDay = DIC_ReceptionDays.ReceptionDayCode
left join DeptEmployeeReceptionRemarks as RecRemarks on Recep.receptionID = RecRemarks.DeptEmployeeReceptionRemarkID

WHERE 	[x_dept_employee].deptCode = @DeptCode
and(@ValidTo is null and recep.validTo is null
		
	or	@ValidTo is not null and recep.validTo is not null
		and @ValidFrom <= recep.validTo and	 recep.validFrom <=  @ValidTo 
		
	or  @ValidTo is not null and recep.validTo is null
		and  recep.validFrom <=  @ValidTo
		
	or	@ValidTo is null and recep.validTo is not null
		and @ValidFrom <= recep.validTo
)
--AND (@ServiceGivenBy_cond ='-1' OR Employee.IsMedicalTeam <> CAST(@ServiceGivenBy_cond as int))
	
end

return
end

GO

grant select on rfn_GetDeptServicesReception to public 
go
