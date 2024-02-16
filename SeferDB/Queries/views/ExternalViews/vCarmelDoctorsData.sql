/*

מבית חולים כרמל מבקשים view עבור רופאים עצמאיים בקהילה:

ספר השירות – מידע עדכני על משרות רופאים

מטרה:
מערכות המחלקה לרפואת הקהילה נמצאות בקשר קבוע עם רופאים רבים בקהילה. הקשר עם הרופאים הינו באמצעות דיוור, טלפונים והפצת תוצאות אלקטרונית. אחד ממקורות המידע על פרטי הרופאים הינו ספר השירות

תדירות גישה:
הגישה אל מקור הנתונים תעשה אחת ליממה בשעות הלילה.

אפיון מקור המידע:
המידע אשר נדרש מספר השירות מוגדר עפ"י מנגנון הפקת דוח "נותני שירות ביחידות", בכל המחוזות, מסקטור רפואה, בסוג הסכם "עצמאי בקהילה".
שדות מידע נדרשים: כל השדות המוגדרים ע"י הדוח הנ"ל.
טיובים לא נדרשים במקור המידע, יבוצעו במנגנון הקליטה.

הרשאות גישה:
יש לאפשר הרשאות ביצוע לקבוצת Carmel\cmdAdmins ולמשתמש Carmel\sqlDev.


*/
alter VIEW [dbo].[vCarmelDoctorsData]
AS

SELECT 
dDistrict.deptCode as 'קוד מחוז', 
dDistrict.DeptName as 'מחוז',
ISNULL(CAST(dAdmin.deptCode as varchar(10)), '') as 'קוד מנהלת',
ISNULL(dAdmin.DeptName, '') as 'מינהלת',
ISNULL(UnitType.UnitTypeCode, '') as 'קוד סוג יחידה',
ISNULL(UnitType.UnitTypeName, '') as 'סוג יחידה',
ISNULL(CAST(subUnitType.subUnitTypeCode as varchar(1)), '') as 'קוד שיוך',
ISNULL(subUnitType.subUnitTypeName, '') as 'שיוך',
d.DeptName as 'שם יחידה',
d.deptCode as 'קוד סימול',
ISNULL(CAST(deptSimul.Simul228 as varchar(6)), '') as 'קוד סימול ישן',
ISNULL(CAST(dSubAdmin.deptCode as varchar(10)), '') as 'קוד כפיפות ניהולית',
ISNULL(dSubAdmin.DeptName, '') as 'כפיפות ניהולית',
Cities.CityCode as 'קוד ישוב', Cities.CityName as 'ישוב',
dbo.GetAddress(d.deptCode) as 'כתובת',
dbo.fun_ParsePhoneNumberWithExtension(dp1.prePrefix, dp1.Prefix,dp1.Phone, dp1.extension ) as 'טלפון 1',
dbo.fun_ParsePhoneNumberWithExtension(dp2.prePrefix, dp2.Prefix, dp2.Phone, dp2.extension) as 'טלפון 2',
dbo.fun_ParsePhoneNumberWithExtension(dp3.prePrefix, dp3.Prefix, dp3.Phone, dp3.extension) as 'פקס',
ISNULL(d.Email, '') as 'מייל',
ps.PopulationSectorID as 'קוד מגזר',
ps.PopulationSectorDescription as 'מגדר',
CASE WHEN deptWithManager is null THEN d.managerName ELSE dbo.fun_getManagerName(d.deptCode) END as 'שם מנהל',
CASE WHEN deptWithAdminManager is null THEN d.administrativeManagerName ELSE dbo.fun_getAdminManagerName(d.deptCode) END as 'שם מנהל אדמיניסטרטיבי',
Employee.firstName as 'שם פרטי נותן שירות', Employee.lastName as 'שם משפחה נותן שירות',
Employee.EmployeeID as 'ת.ז. נותן שירות',
View_EmployeeSector.EmployeeSectorCode as 'קוד סקטור נותן שירות',
View_EmployeeSector.EmployeeSectorDescription as 'סקטור נותן שירות',
ISNULL(CAST(DEPositions.PositionCodes as varchar(3)), '') as 'קוד תפקיד נותן שירות',
ISNULL(DEPositions.PositionDescriptions, '') as 'תפקיד נותן שירות',
ISNULL(Employee.licenseNumber, '') as 'מס` רשיון נותן שירות',
ISNULL(CAST(DEProfessions.ProfessionCodes as varchar(7)), '') as 'קוד מקצוע נותן שירות',
ISNULL(DEProfessions.ProfessionDescriptions, '') as 'מקצוע נותן שירות',
ISNULL(CAST(DEExpProfessions.ExpertProfessionCodes as varchar(7)), '') as 'קוד מקצוע מומחיות נותן שירות',
ISNULL(DEExpProfessions.ExpertProfessionDescriptions, '') as 'מקצוע מומחיות נותן שירות',
ISNULL(CAST(DEServices.ServiceCodes as varchar(7)), '') as 'קוד שירותים נותן שירות',
ISNULL(DEServices.ServiceDescriptions, '') as 'שירותים נותן שירות',
ISNULL(DERemarks.RemarkDescriptions, '') as 'הערות נותן שירות',
DIC_AgreementTypes.AgreementTypeID as 'קוד סוג הסכם נותן שירות',
DIC_AgreementTypes.AgreementTypeDescription as 'סוג הסכם נותן שירות',
EmpStatus.status as 'קוד סטטוס נותן שירות',
EmpStatus.StatusDescription as 'סטטוס נותן שירות',
DeptEmpStatus.status as 'קוד סטטוס נותן שירות ביחידה',
DeptEmpStatus.StatusDescription as 'סטטוס נותן שירות ביחידה',
case when Employee.Sex = 1 then 'זכר' when Employee.Sex = 2 then 'נקבה' else 'לא מוגדר' end as 'מגדר נותן שירות',
DIC_EmployeeDegree.DegreeCode as 'קוד תואר נותר שירות',
DIC_EmployeeDegree.degreeName as 'תואר נותן שירות',
case when x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1
	then dbo.fun_ParsePhoneNumberWithExtension(dp1.prePrefix, dp1.Prefix, dp1.Phone, dp1.Extension )
	else dbo.fun_ParsePhoneNumberWithExtension(emplPh1.prePrefix, emplPh1.Prefix, emplPh1.Phone, emplPh1.Extension )end as 'טלפון נותן שירות',
case when x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1
		then dbo.fun_ParsePhoneNumberWithExtension(dp2.prePrefix, dp2.Prefix, dp2.Phone, dp2.Extension )
		else dbo.fun_ParsePhoneNumberWithExtension(emplPh2.prePrefix, emplPh2.Prefix, emplPh2.Phone, emplPh2.Extension )end as 'טלפון 2 נותן שירות',	
case when x_Dept_Employee.CascadeUpdateDeptEmployeePhonesFromClinic = 1
		then dbo.fun_ParsePhoneNumberWithExtension(dp3.prePrefix, dp3.Prefix, dp3.Phone, dp3.Extension ) 
		else dbo.fun_ParsePhoneNumberWithExtension(emplPh3.prePrefix, emplPh3.Prefix, emplPh3.Phone, emplPh3.Extension )end as 'פקס נותן שירות',
Employee.email as 'מייל נותן שירות',
ISNULL(QueueOrderDetails.QueueOrderDescription, '') as ':זימון התור',
ISNULL(QueueOrderDetails.QueueOrderClinicTelephone, '') as 'טלפון יחידה לזימון התור',
ISNULL(QueueOrderDetails.QueueOrderSpecialTelephone, '') as 'טלפון מיוחד זימון התור',
ISNULL(QueueOrderDetails.QueueOrderTelephone2700, '') as 'טלפון 2700* זימון התור',
ISNULL(QueueOrderDetails.QueueOrderInternet, '') as 'זימון התור באינטרנט'
		
FROM Dept as d    
LEFT JOIN x_Dept_Employee ON d.deptCode = x_Dept_Employee.deptCode 
JOIN Employee ON x_Dept_Employee.employeeID = Employee.employeeID 
JOIN DIC_ActivityStatus as EmpStatus on EmpStatus.Status = Employee.active 
JOIN DIC_ActivityStatus as DeptEmpStatus on DeptEmpStatus.Status = x_Dept_Employee.active 
JOIN DIC_AgreementTypes on x_Dept_Employee.AgreementType = DIC_AgreementTypes.AgreementTypeID 

LEFT JOIN View_EmployeeSector on Employee.EmployeeSectorCode = View_EmployeeSector.EmployeeSectorCode 
LEFT JOIN dept as dAdmin on d.administrationCode = dAdmin.deptCode 

LEFT JOIN dept as dDistrict on d.districtCode = dDistrict.deptCode 
LEFT JOIN View_UnitType as UnitType on d.typeUnitCode = UnitType.UnitTypeCode 
 
LEFT JOIN View_SubUnitTypes as SubUnitType on d.subUnitTypeCode = SubUnitType.subUnitTypeCode
		and  d.typeUnitCode = SubUnitType.UnitTypeCode 

LEFT JOIN Cities on d.CityCode = Cities.CityCode 

LEFT JOIN deptSimul on d.DeptCode = deptSimul.DeptCode 

LEFT JOIN dept as dSubAdmin on d.subAdministrationCode = dSubAdmin.deptCode 

	cross apply rfn_GetDeptEmployeeQueueOrderDetails(d.deptCode, x_Dept_Employee.employeeID) as QueueOrderDetails 

LEFT JOIN DeptEmployeePhones as emplPh1 on x_Dept_Employee.DeptEmployeeID = emplPh1.DeptEmployeeID 
		and emplPh1.PhoneType = 1 and emplPh1.phoneOrder = 1 
	 LEFT JOIN DeptEmployeePhones as emplPh2 on x_Dept_Employee.DeptEmployeeID = emplPh2.DeptEmployeeID 
		and emplPh2.PhoneType = 1 and emplPh2.phoneOrder = 2 

LEFT JOIN DeptEmployeePhones as emplPh3 on x_Dept_Employee.DeptEmployeeID = emplPh3.DeptEmployeeID  
		and emplPh3.PhoneType = 2 and emplPh3.phoneOrder = 1 
		
LEFT JOIN DeptPhones dp1 on d.DeptCode = dp1.DeptCode and dp1.PhoneType = 1 and dp1.phoneOrder = 1 
		
LEFT JOIN DeptPhones dp2 on d.DeptCode = dp2.DeptCode and dp2.PhoneType = 1 and dp2.phoneOrder = 2 
	
LEFT JOIN DeptPhones dp3 on d.DeptCode = dp3.DeptCode and dp3.PhoneType = 2 and dp3.phoneOrder = 1 

LEFT JOIN PopulationSectors as ps on d.populationSectorCode = ps.PopulationSectorID 

LEFT JOIN [dbo].View_DeptEmployeeProfessions as DEProfessions	 
		on x_Dept_Employee.deptCode = DEProfessions.deptCode
		and x_Dept_Employee.AgreementType = DEProfessions.AgreementType
		and Employee.employeeID = DEProfessions.employeeID 

LEFT JOIN [dbo].View_DeptEmployeeExpertProfessions as DEExpProfessions 
		on x_Dept_Employee.deptCode = DEExpProfessions.deptCode
		and x_Dept_Employee.AgreementType = DEExpProfessions.AgreementType
		and Employee.employeeID = DEExpProfessions.employeeID 
 
LEFT JOIN [dbo].View_DeptEmployeePositions as DEPositions 
		on x_Dept_Employee.deptCode = DEPositions.deptCode
		and x_Dept_Employee.AgreementType = DEPositions.AgreementType
		and Employee.employeeID = DEPositions.employeeID 

LEFT JOIN [dbo].View_DeptEmployeeServices as DEServices 
		on x_Dept_Employee.deptCode = DEServices.deptCode 
		and x_Dept_Employee.AgreementType = DEServices.AgreementType
		and Employee.employeeID = DEServices.employeeID 

LEFT JOIN [dbo].View_DeptEmployeeRemarks as DERemarks
		on x_Dept_Employee.deptCode = DERemarks.deptCode
		and x_Dept_Employee.AgreementType = DERemarks.AgreementType
		and Employee.employeeID = DERemarks.employeeID 
	
LEFT JOIN DIC_EmployeeDegree on Employee.DegreeCode = DIC_EmployeeDegree.DegreeCode 

LEFT JOIN 
	(SELECT DISTINCT x_dept_employee.deptCode as deptWithManager
	FROM employee
	INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode
	INNER JOIN x_dept_employee ON employee.employeeID = x_dept_employee.employeeID
	INNER JOIN x_Dept_Employee_Position ON x_dept_employee.DeptEmployeeID = x_Dept_Employee_Position.DeptEmployeeID 								
	INNER JOIN mappingPositions ON x_Dept_Employee_Position.positionCode = mappingPositions.positionCode
	WHERE mappingPositions.mappedToManager = 1
	) T on d.deptCode = T.deptWithManager
LEFT JOIN 
(	SELECT DISTINCT	xd.deptCode as deptWithAdminManager
	FROM employee
	INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode
	INNER JOIN x_dept_employee xd ON employee.employeeID = xd.employeeID 
	INNER JOIN x_Dept_Employee_Position ON xd.DeptEmployeeID = x_Dept_Employee_Position.DeptEmployeeID							
	INNER JOIN mappingPositions ON x_Dept_Employee_Position.positionCode = mappingPositions.positionCode
				AND  mappingPositions.mappedToAdministrativeManager = 1	
	) T2 on d.deptCode = T2.deptWithAdminManager

WHERE 1=1
AND x_Dept_Employee.AgreementType = 2
AND Employee.EmployeeSectorCode = 7
AND x_Dept_Employee.active = 1

GO
