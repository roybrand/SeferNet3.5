IF EXISTS (SELECT * FROM sysobjects WHERE name = 'rfn_GetEmployeeAllServicesString')
	BEGIN
		DROP  FUNCTION  rfn_GetEmployeeAllServicesString
	END

GO

create  function [dbo].[rfn_GetEmployeeAllServicesString](@employeeID bigint) 
RETURNS varchar(500)

WITH EXECUTE AS CALLER

AS
BEGIN

	declare @ServicesStr varchar(500) 
	set @ServicesStr = ''
	
	SELECT @ServicesStr = @ServicesStr + ServiceDescription + ' ; ' 
	FROM
	(select distinct ServiceDescription
	from EmployeeServices
	inner join Service on EmployeeServices.ServiceCode = Service.ServiceCode
			and EmployeeServices.employeeID = @employeeID
	) as d 

	return (@ServicesStr);
	
end 

go 
grant exec on rfn_GetEmployeeAllServicesString to public 
go