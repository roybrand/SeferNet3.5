IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'v_EmployeeReceptionByServiceAndProfession')
	BEGIN
		DROP  view  v_EmployeeReceptionByServiceAndProfession
	END
GO

CREATE VIEW [dbo].[v_EmployeeReceptionByServiceAndProfession]
AS 

SELECT DISTINCT 
        xd.EmployeeID, der.receptionID, xd.deptCode, Dept.deptName, Dept.cityCode, Cities.cityName, der.receptionDay, der.openingHour, 
        der.closingHour, der.validFrom, der.validTo, derr.RemarkID, derr.RemarkText, 
		CASE WHEN s.IsService = 1 THEN 'service' ELSE 'profession' END AS ItemType, 
 		s.ServiceDescription AS ItemDesc,	 
		s.servicecode AS ItemID,
		deptEmployeeReceptionServicesID AS ItemRecID,
		xd.AgreementType,
		der.ReceptionRoom,
		ISNULL(der.ReceiveGuests, 0) as ReceiveGuests
FROM    deptEmployeeReception AS der 
		LEFT JOIN DeptEmployeeReceptionRemarks AS derr ON der.receptionID = derr.EmployeeReceptionID 
		INNER JOIN x_dept_employee xd ON der.DeptEmployeeID = xd.DeptEmployeeID
		INNER JOIN Dept ON xd.deptCode = Dept.deptCode 
		INNER JOIN Cities ON Dept.cityCode = Cities.cityCode 
		LEFT JOIN deptEmployeeReceptionServices AS ders ON der.receptionID = ders.receptionID 
		LEFT JOIN x_Dept_Employee_Service AS xdes  ON (ders.serviceCode = xdes.serviceCode OR ders.serviceCode IS NULL) 
																					AND xd.DeptEmployeeID = xdes.DeptEmployeeID			
        INNER JOIN dbo.[Services] AS s ON ders.serviceCode = s.ServiceCode OR ders.serviceCode IS NULL 
WHERE     (ders.receptionID IS NOT NULL) AND (xdes.serviceCode IS NOT NULL) 

GO

GRANT select ON v_EmployeeReceptionByServiceAndProfession TO [clalit\webuser]
GO

GRANT select ON v_EmployeeReceptionByServiceAndProfession TO [clalit\IntranetDev]
GO