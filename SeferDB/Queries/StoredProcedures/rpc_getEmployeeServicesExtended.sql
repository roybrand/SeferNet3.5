IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeeServicesExtended')
	BEGIN
		DROP  Procedure  rpc_getEmployeeServicesExtended
	END

GO

CREATE Procedure [dbo].[rpc_getEmployeeServicesExtended]
(
	@employeeID INT,
	@deptCode INT,					 -- in case @deptCode = null or @deptCode <= 0  -- all depts
	@DeptEmployeeID INT,
	@IsLinkedToEmployeeOnly bit,		-- in case = 0 returns with whole service list;
									-- = 1 returns only services Linked To this Employee
	@IsService bit
)

AS 

DECLARE @RelevantForProfession int

SELECT @RelevantForProfession = RelevantForProfession
FROM EmployeeSector
INNER JOIN Employee ON EmployeeSector.EmployeeSectorCode = Employee.EmployeeSectorCode
WHERE Employee.EmployeeID = @employeeID

select distinct
ServiceCode 
,REPLACE(ServiceDescription, CHAR(39), '`') as ServiceDescription 
,ServiceCategoryID
,LinkedToEmployee  
,LinkedToEmployeeInDept  
,HasReceptionInDept
,CategoryIDForSort
,CategoryDescrForSort
,AgreementType
,IsProfession
from

-- ServiceCategory table
( -- begin union
SELECT  
ISNULL(SerCatSer.ServiceCategoryID, -1) as 'ServiceCode'   --'ServiceCategoryID'
,ISNULL(SerCat.ServiceCategoryDescription, 'שירותים שונים') as 'ServiceDescription' ---'ServiceCategoryDescription'
,null as 'ServiceCategoryID'
,0 as 'LinkedToEmployee'
,0 as 'LinkedToEmployeeInDept'
,0 as 'HasReceptionInDept'
,ISNULL(SerCatSer.ServiceCategoryID, -1)as 'CategoryIDForSort'
,ISNULL(SerCat.ServiceCategoryDescription, 'תתתת') AS 'CategoryDescrForSort'
,null as 'AgreementType'
,0 as IsProfession

--"ServiceCategory-From" - block begin ---"ServiceCategory-From" - block  equal to "Professions-From" block 
FROM [Services] as Ser
left JOIN x_Services_EmployeeSector xSerEmSec 
	ON Ser.ServiceCode = xSerEmSec.ServiceCode

-- filter by Employee.EmployeeSectorCode of this Employee(@employeeID)
inner JOIN Employee 
	ON (xSerEmSec.EmployeeSectorCode is null or Employee.IsMedicalTeam = 1
		or xSerEmSec.EmployeeSectorCode = Employee.EmployeeSectorCode)
	 AND Employee.EmployeeID = @employeeID
	 AND (@IsService is null OR Ser.IsService = @IsService)


LEFT JOIN EmployeeServices EmpSer
	ON Ser.ServiceCode = EmpSer.serviceCode 
	AND EmpSer.EmployeeID = @employeeID
	
LEFT JOIN x_Dept_Employee as xd 
	ON ((@DeptEmployeeID = -1 AND xd.EmployeeID = @employeeID AND xd.deptCode = @deptCode)
		OR
		(@DeptEmployeeID <> -1 AND xd.DeptEmployeeID = @DeptEmployeeID)
	   )

left JOIN  x_ServiceCategories_Services as SerCatSer
	ON 	SerCatSer.ServiceCode = Ser.ServiceCode
	
left join ServiceCategories SerCat 
	on  SerCat.ServiceCategoryID = SerCatSer.ServiceCategoryID

	
where (@IsLinkedToEmployeeOnly = 0 or EmpSer.serviceCode is not null)
	and(xd.AgreementType is null
		or xd.AgreementType in (1,2,6) and Ser.IsInCommunity = 1
		or xd.AgreementType in (3,4) and Ser.IsInMushlam = 1
		or xd.AgreementType in (5) and Ser.IsInHospitals = 1)
	AND (@RelevantForProfession = 1 OR Ser.IsProfession = 0)
--- end from block

union

------------- Professions table
SELECT 
Ser.ServiceCode
,Ser.ServiceDescription
,ISNULL(SerCatSer.ServiceCategoryID, -1) AS 'ServiceCategoryID'
,CASE IsNull(EmpSer.serviceCode,0) WHEN 0 THEN 0 ELSE 1 END as 'LinkedToEmployee' 
,CASE WHEN EXISTS (SELECT * 
					FROM X_Dept_Employee_Service xdes 
					JOIN x_Dept_Employee xDE ON xdes.DeptEmployeeID = xDE.DeptEmployeeID 
					WHERE xdes.serviceCode = Ser.ServiceCode AND xDE.DeptEmployeeID = @DeptEmployeeID) THEN 1
	ELSE 0 END as LinkedToEmployeeInDept
,'HasReceptionInDept' = 
(case
(
select COUNT(*) 
from deptEmployeeReception der 
INNER JOIN deptEmployeeReceptionServices ders 
	ON der.ReceptionID = ders.ReceptionID 
	AND ders.serviceCode = Ser.ServiceCode
	and (der.ValidTo IS NULL 
		OR DATEDIFF(dd, der.ValidTo, GETDATE()) <= 0)
)
when 0 then 0
else 1 end
)
,ISNULL(SerCatSer.ServiceCategoryID, -1) AS 'CategoryIDForSort'
,ISNULL(SerCat.ServiceCategoryDescription, 'תתתת') AS 'CategoryDescrForSort'
,case when (Ser.IsInMushlam = 1
			and isnull(Ser.IsInCommunity, 0) = 0 
			and isnull(Ser.IsInHospitals, 0) = 0) 
	then 3 else null end as 'AgreementType'
,Ser.IsProfession
	
	
------ "Services-From" block 
FROM [Services] as Ser
left JOIN x_Services_EmployeeSector xSerEmSec 
	ON Ser.ServiceCode = xSerEmSec.ServiceCode

-- filter by Employee.EmployeeSectorCode of this Employee(@employeeID)
INNER JOIN Employee 
	ON (xSerEmSec.EmployeeSectorCode is null or Employee.IsMedicalTeam = 1
		or xSerEmSec.EmployeeSectorCode = Employee.EmployeeSectorCode)
	 AND Employee.EmployeeID = @employeeID
	 AND (@IsService is null OR Ser.IsService = @IsService)
	 
LEFT JOIN x_Dept_Employee xd 
	ON Employee.employeeID = xd.employeeID 
	AND ( (@DeptEmployeeID <> -1 AND xd.DeptEmployeeID = @DeptEmployeeID)
			OR 
		  (@DeptEmployeeID = -1 AND (xd.deptCode = @deptCode OR @deptCode is null OR @deptCode <= 0))
		 )

LEFT JOIN EmployeeServices EmpSer
	ON Ser.ServiceCode = EmpSer.serviceCode 
	AND EmpSer.EmployeeID = @employeeID

left JOIN  x_ServiceCategories_Services as SerCatSer
	ON 	SerCatSer.ServiceCode = Ser.ServiceCode
	
left join ServiceCategories SerCat 
	on  SerCat.ServiceCategoryID = SerCatSer.ServiceCategoryID


where (@IsLinkedToEmployeeOnly = 0 or EmpSer.serviceCode is not null)
	and(xd.AgreementType is null
		or xd.AgreementType in (1,2,6) and Ser.IsInCommunity = 1
		or xd.AgreementType in (3,4) and Ser.IsInMushlam = 1
		or xd.AgreementType in (5) and Ser.IsInHospitals = 1)
	AND (@RelevantForProfession = 1 OR Ser.IsProfession = 0)
----- "Professions-From" block end
) as temp     -- end union


ORDER BY CategoryDescrForSort, ServiceCategoryID, ServiceDescription

SELECT popupType, popupTypeName, NameToShowInHebrew, SelectedElementsMaxNumber 
FROM SelectedElementsQuantityRestriction
WHERE popupType = 3

GO

GRANT EXEC ON dbo.rpc_getEmployeeServicesExtended TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_getEmployeeServicesExtended TO [clalit\IntranetDev]
GO
