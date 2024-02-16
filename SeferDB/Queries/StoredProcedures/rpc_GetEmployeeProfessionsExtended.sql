IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetEmployeeProfessionsExtended')
	DROP  Procedure  rpc_GetEmployeeProfessionsExtended
GO

CREATE Procedure [dbo].[rpc_GetEmployeeProfessionsExtended]
(
		@employeeID INT,
		@deptCode INT,					 -- in case @deptCode = null or @deptCode <= 0  -- all depts
		@IsLinkedToEmployeeOnly bit,	 -- case:0 returns whole profession list; case:1 returns only professions Linked To this Employee
		@EnableExpert bit
)

AS 

SELECT *
FROM 
( 

SELECT DISTINCT 
ISNULL(SerCatSer.ServiceCategoryID, -1) as 'ServiceCode' 
,ISNULL(SerCat.ServiceCategoryDescription, 'שירותים שונים') as 'ServiceDescription'
,null as 'ServiceCategoryID'
,0 as 'LinkedToEmployee'
,0 as 'ExpertProfession'
,ISNULL(SerCatSer.ServiceCategoryID, -1)as 'CategoryIDForSort'
,ISNULL(SerCat.ServiceCategoryDescription, 'תתתת') AS 'CategoryDescrForSort'
,null as 'AgreementType'
,Ser.IsProfession

--"ServiceCategory-From" - block begin ---"ServiceCategory-From" - block  equal to "Professions-From" block 
FROM [Services] as Ser
INNER JOIN x_Services_EmployeeSector xSerEmSec  ON Ser.ServiceCode = xSerEmSec.ServiceCode 
												AND Ser.IsProfession  = 1
INNER JOIN Employee ON xSerEmSec.EmployeeSectorCode = Employee.EmployeeSectorCode												
LEFT JOIN EmployeeServices es ON Ser.ServiceCode = es.ServiceCode AND Employee.employeeID = es.EmployeeID
LEFT JOIN  x_ServiceCategories_Services as SerCatSer ON Ser.ServiceCode	= SerCatSer.ServiceCode
LEFT JOIN ServiceCategories SerCat  ON  SerCat.ServiceCategoryID = SerCatSer.ServiceCategoryID
	
WHERE (@IsLinkedToEmployeeOnly = 0 OR es.ServiceCode IS NOT NULL)
AND Employee.employeeID = @employeeID
--AND 
--	(
--		( @deptCode <> -1
--			and
--			(DepEmp.AgreementType is null
--			or DepEmp.AgreementType in (1,2) and Ser.IsInCommunity = 1
--			or DepEmp.AgreementType in (3,4) and Ser.IsInMushlam = 1
--			or DepEmp.AgreementType in (5,6) and Ser.IsInHospitals = 1)	
--		)
		
--		OR
		
--		( @deptCode = -1
--			and 
--			((Employee.IsInCommunity = Ser.IsInCommunity )
--				or
--			 (Employee.IsInMushlam = Ser.IsInMushlam )
--				or
--			 (Employee.IsInHospitals = Ser.IsInHospitals)		
--			)
--		)
--	)
	--- end from block
/* The last condition is to hide Service Category when open PopUp for updating Employees' professions in clinic*/


UNION

------------- Professions table
SELECT 
Ser.ServiceCode
,Ser.ServiceDescription
,ISNULL(SerCatSer.ServiceCategoryID, -1) AS 'ServiceCategoryID'
,CASE IsNull(es.ServiceCode,0) WHEN 0 THEN 0 ELSE 1 END as 'LinkedToEmployee' 
,es.ExpProfession	as 'ExpertProfession'
,ISNULL(SerCatSer.ServiceCategoryID, -1) AS 'CategoryIDForSort'
,ISNULL(SerCat.ServiceCategoryDescription, 'תתתת') AS 'CategoryDescrForSort'
,case when (Ser.IsInMushlam = 1
			and isnull(Ser.IsInCommunity, 0) = 0 
			and isnull(Ser.IsInHospitals, 0) = 0) 
	then 3 else null end as 'AgreementType'
,Ser.IsProfession

------ "Professions-From" block 
FROM [Services] as Ser

INNER JOIN x_Services_EmployeeSector xSerEmSec 
	ON Ser.ServiceCode = xSerEmSec.ServiceCode
	and Ser.IsProfession  = 1

-- filter by Employee.EmployeeSectorCode of this Employee(@employeeID)
INNER JOIN Employee 
	ON xSerEmSec.EmployeeSectorCode = Employee.EmployeeSectorCode	 

LEFT JOIN EmployeeServices es
	ON Ser.ServiceCode = es.ServiceCode 
	AND es.EmployeeID = @employeeID

LEFT JOIN x_Dept_Employee xd 
	ON Employee.employeeID = xd.employeeID
	AND (@deptCode = -1 OR xd.deptCode = @deptCode)
	
LEFT JOIN X_Dept_Employee_Service xdes
	ON xd.DeptEmployeeID = xdes.DeptEmployeeID
	AND xdes.serviceCode = Ser.ServiceCode

LEFT JOIN  x_ServiceCategories_Services as SerCatSer
	ON 	SerCatSer.ServiceCode = Ser.ServiceCode
	
LEFT JOIN ServiceCategories SerCat 
	on  SerCat.ServiceCategoryID = SerCatSer.ServiceCategoryID


	
where (@IsLinkedToEmployeeOnly = 0 or es.ServiceCode is not null)
AND (xd.deptCode = @deptCode OR @deptCode IS NULL OR @deptCode <= 0 )
AND (Employee.employeeID = @employeeID)

AND (	
		( @deptCode <> -1
			and
			(xd.AgreementType is null
			or xd.AgreementType in (1,2) and Ser.IsInCommunity = 1
			or xd.AgreementType in (3,4) and Ser.IsInMushlam = 1
			or xd.AgreementType in (5,6) and Ser.IsInHospitals = 1)	
		)
		
		OR
		
		( @deptCode = -1
			and 
			((Employee.IsInCommunity = Ser.IsInCommunity )
				or
			 (Employee.IsInMushlam = Ser.IsInMushlam )
				or
			 (Employee.IsInHospitals = Ser.IsInHospitals)		
			)
		)
	)
AND (@EnableExpert = 0 OR Ser.EnableExpert = 1)	
----- "Professions-From" block end
) as temp     -- end union

ORDER BY CategoryDescrForSort, ServiceCategoryID, ServiceDescription

SELECT popupType, popupTypeName, NameToShowInHebrew, SelectedElementsMaxNumber 
FROM SelectedElementsQuantityRestriction
WHERE popupType = 2

GO


GRANT EXEC ON dbo.rpc_GetEmployeeProfessionsExtended TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_GetEmployeeProfessionsExtended TO [clalit\IntranetDev]
GO   
