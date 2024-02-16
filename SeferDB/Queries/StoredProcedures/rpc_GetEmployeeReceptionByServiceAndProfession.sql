 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetEmployeeReceptionByServiceAndProfession')
	BEGIN
		DROP  Procedure  rpc_GetEmployeeReceptionByServiceAndProfession
	END
GO

CREATE  procedure [dbo].[rpc_GetEmployeeReceptionByServiceAndProfession]
(
	@employeeID  BIGINT,
	@deptCode INT = NULL
) 
as 

-- linked with receptions
SELECT EmployeeID , receptionID , deptCode, deptName ,cityCode ,cityName , 
  receptionDay, openingHour, closingHour, validFrom,validTo , ItemType, ItemID, ItemDesc, 
v.RemarkID, RemarkText, EnableOverMidnightHours, v.AgreementType, AT.AgreementTypeDescription
,v.ReceptionRoom
FROM v_EmployeeReceptionByServiceAndProfession v
LEFT JOIN DIC_GeneralRemarks rem ON v.RemarkID = rem.RemarkID
JOIN DIC_AgreementTypes AT ON v.AgreementType = AT.AgreementTypeID
WHERE EmployeeID =   @employeeID  AND IsNULL(@deptCode,DeptCode) = DeptCode
AND (DATEDIFF(dd,GETDATE(),validTo) >= 0 OR ValidTo IS NULL)

UNION 

--  linked service without reception
SELECT distinct xd.EmployeeID, null receptionID, dept.deptCode, dept.deptName, cities.cityCode, cities.cityName, 
				null as receptionDay, null as openingHour, null as closingHour, null as validFrom, null as validTo,
				CASE s.IsProfession WHEN 0 THEN 'service' ELSE 'profession'  END as ItemType, 
				xdes.serviceCode as ItemID, s.ServiceDescription as ItemDesc, null as RemarkID, null RemarkText, null as EnableOverMidnightHours,
				xd.AgreementType, AT.AgreementTypeDescription
				,null as ReceptionRoom
FROM x_Dept_Employee xd
INNER JOIN x_Dept_Employee_service xdes ON xd.DeptEmployeeID = xdes.DeptEmployeeID
INNER JOIN [Services] s ON xdes.serviceCode = s.ServiceCode
LEFT JOIN  dbo.Dept ON xd.deptCode = dbo.Dept.deptCode 
INNER JOIN dbo.Cities ON dbo.Dept.cityCode = dbo.Cities.cityCode
JOIN DIC_AgreementTypes AT ON xd.AgreementType = AT.AgreementTypeID
WHERE xd.Employeeid = @employeeID 
AND IsNULL(@deptCode, xd.DeptCode) = xd.DeptCode
							  
ORDER BY deptCode,ValidFrom


SELECT DeptCode, openinghour, ClosingHour ,  remarkText,  ValidFrom , ValidTo, ItemID, receptionDay,dense_rank() 
over (order by  DeptCode,openinghour, ClosingHour,  remarkText, ValidFrom , ValidTo, dayGroup) as RecRank 
FROM 
(
SELECT DeptCode, openinghour, ClosingHour , remarkText, ValidFrom ,ValidTo, ItemID, receptionDay,
sum(power(2,receptionDay-1)) over (partition by DeptCode, openinghour,  ClosingHour,  remarkText, ValidFrom , ValidTo, itemid) dayGroup,
   COUNT(*) as nrecs 
FROM v_EmployeeReceptionByServiceAndProfession v
WHERE employeeid =  @employeeID  AND IsNULL(@deptCode,DeptCode) = DeptCode     
GROUP BY  DeptCode, openinghour, ClosingHour, remarkText, ValidFrom, ValidTo, ItemID, receptionDay) as a 


GO


GRANT EXEC ON rpc_GetEmployeeReceptionByServiceAndProfession TO [clalit\webuser]
GO

GRANT EXEC ON rpc_GetEmployeeReceptionByServiceAndProfession TO [clalit\IntranetDev]
GO

