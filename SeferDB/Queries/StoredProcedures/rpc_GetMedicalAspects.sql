IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetMedicalAspects')
	BEGIN
		DROP  Procedure  rpc_GetMedicalAspects
	END
GO

CREATE Procedure [dbo].[rpc_GetMedicalAspects]
(
	@deptCode INT,		-- in case @deptCode = null or @deptCode <= 0  -- all depts
	@IsLinkedToDept bit,  -- 0 - returns list with NOT linked to Dept; 1 - returns only services Linked to Dept; null - whole list
	@IsService bit
)

AS 

SELECT distinct
ServiceCode 
,ServiceDescription
,ServiceCategoryID 
,LinkedToEmployee
,LinkedToEmployeeInDept

,CategoryIDForSort
,CategoryDescrForSort

,IsProfession
FROM

-- ServiceCategory table
( -- begin union
SELECT  
ISNULL(SerCatSer.ServiceCategoryID, -1) as 'ServiceCode'   --'ServiceCategoryID'
,ISNULL(SerCat.ServiceCategoryDescription, 'שירותים שונים') as 'ServiceDescription' ---'ServiceCategoryDescription'
,null as 'ServiceCategoryID'
,0 as 'LinkedToEmployee'
,0 as 'LinkedToEmployeeInDept'
,ISNULL(SerCatSer.ServiceCategoryID, -1)as 'CategoryIDForSort'
,ISNULL(SerCat.ServiceCategoryDescription, 'תתתת') AS 'CategoryDescrForSort'
,0 as IsProfession

--"ServiceCategory-From" - block begin ---"ServiceCategory-From" - block  equal to "Professions-From" block 
FROM [Services] as Ser

LEFT JOIN  x_ServiceCategories_Services as SerCatSer ON SerCatSer.ServiceCode = Ser.ServiceCode
LEFT JOIN ServiceCategories SerCat on SerCat.ServiceCategoryID = SerCatSer.ServiceCategoryID
JOIN MedicalAspectsToSefer MAtoS ON Ser.ServiceCode = MAtoS.SeferCode
JOIN MF_MedicalAspects830 ON MAtoS.MedicalAspectCode = MF_MedicalAspects830.MedicalServiceCode 
LEFT JOIN x_dept_medicalAspect ON MAtoS.MedicalAspectCode = x_dept_medicalAspect.MedicalAspectCode
	AND (@deptCode is null 
		OR @deptCode <= 0
		OR x_dept_medicalAspect.NewDeptCode = @deptCode)

WHERE (@IsLinkedToDept is null
	OR (@IsLinkedToDept = 0 AND x_dept_medicalAspect.NewDeptCode is null)
	OR (@IsLinkedToDept = 1 AND x_dept_medicalAspect.NewDeptCode is NOT null)
)
AND (@IsService is null OR Ser.IsService = @IsService)

UNION

------------- Professions table
SELECT 
MF_MedicalAspects830.MedicalServiceCode as ServiceCode
,MF_MedicalAspects830.MedicalServiceDesc as ServiceDescription
,ISNULL(SerCatSer.ServiceCategoryID, -1) AS 'ServiceCategoryID'
,CASE IsNull(x_dept_medicalAspect.MedicalAspectCode, 0) WHEN 0 THEN 0 ELSE 1 END as 'LinkedToEmployee' 
,CASE IsNull(x_dept_medicalAspect.MedicalAspectCode, 0) WHEN 0 THEN 0 ELSE 1 END as 'LinkedToEmployeeInDept'

,ISNULL(SerCatSer.ServiceCategoryID, -1) AS 'CategoryIDForSort'
,ISNULL(SerCat.ServiceCategoryDescription, 'תתתת') AS 'CategoryDescrForSort'
,Ser.IsProfession
	
------ "Services-From" block 
FROM [Services] as Ser

LEFT JOIN x_ServiceCategories_Services as SerCatSer
	ON 	SerCatSer.ServiceCode = Ser.ServiceCode
LEFT JOIN ServiceCategories SerCat 
	on SerCat.ServiceCategoryID = SerCatSer.ServiceCategoryID
JOIN MedicalAspectsToSefer MAtoS ON Ser.ServiceCode = MAtoS.SeferCode

JOIN MF_MedicalAspects830 
	ON MAtoS.MedicalAspectCode = MF_MedicalAspects830.MedicalServiceCode 

LEFT JOIN x_dept_medicalAspect ON MAtoS.MedicalAspectCode = x_dept_medicalAspect.MedicalAspectCode
	AND (@deptCode is null 
		OR @deptCode <= 0
		OR x_dept_medicalAspect.NewDeptCode = @deptCode)

----------------------------------------------------------------------------------------------------
WHERE (@IsLinkedToDept is null
	OR (@IsLinkedToDept = 0 AND x_dept_medicalAspect.NewDeptCode is null)
	OR (@IsLinkedToDept = 1 AND x_dept_medicalAspect.NewDeptCode is NOT null)
)
AND (@IsService is null OR Ser.IsService = @IsService)
----- "Professions-From" block end
) as temp     -- end union

ORDER BY CategoryDescrForSort, ServiceCategoryID, ServiceDescription
GO

GRANT EXEC ON rpc_GetMedicalAspects TO PUBLIC
GO

