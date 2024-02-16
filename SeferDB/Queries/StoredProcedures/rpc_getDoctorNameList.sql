IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDoctorNameList')
	BEGIN
		DROP  Procedure  rpc_getDoctorNameList

	END

GO

create procedure rpc_getDoctorNameList

(
	@searchStrFirstName varchar(50) = null,
	@searchStrLastName varchar(50) = null
)
as

select employeeID,lastName + ' '+firstName as DoctorName, firstName, lastName
from employee 
where (@searchStrLastName is null OR lastName like @searchStrLastName+'%')
AND (@searchStrFirstName is null OR firstName like @searchStrFirstName+'%')

GO


GRANT EXEC ON rpc_getDoctorNameList
 TO PUBLIC

GO


