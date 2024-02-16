IF EXISTS (SELECT * FROM sysobjects WHERE  name = 'rfn_GetDeptAndServicesReception')
	BEGIN
		DROP  function  dbo.rfn_GetDeptAndServicesReception
	END

GO

CREATE function [dbo].[rfn_GetDeptAndServicesReception]
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


-- @ObjectType_cond ='-1' all 
if (@ObjectType_cond ='-1')
begin
	insert into @ResultTable 
	select * from
	dbo.rfn_GetDeptReception(@DeptCode, @ValidFrom_str, @ValidTo_str, '-1') 
	union 
	select * from
	dbo.rfn_GetDeptServicesReception(@DeptCode, @ValidFrom_str, @ValidTo_str, @ObjectType_cond, @ServiceGivenBy_cond)
end


-- ObjectType = 1 - clinic 	
else 
begin

	if ('1' IN (SELECT IntField FROM dbo.SplitString( @ObjectType_cond )) )
	begin
		insert into @ResultTable 
		select * from
		dbo.rfn_GetDeptReception(@DeptCode, @ValidFrom_str, @ValidTo_str, '1') 
	end


	-- ObjectType = 2 - regular service (is not office);
	if ('2' IN (SELECT IntField FROM dbo.SplitString( @ObjectType_cond )) or
		'3' IN (SELECT IntField FROM dbo.SplitString( @ObjectType_cond )))
	begin

		insert into @ResultTable 
		select * from @ResultTable
		union 
		select * from
		dbo.rfn_GetDeptServicesReception(@DeptCode, @ValidFrom_str, @ValidTo_str, @ObjectType_cond, @ServiceGivenBy_cond)

	end
end

return
end

GO

grant select on rfn_GetDeptAndServicesReception to public 
go  
