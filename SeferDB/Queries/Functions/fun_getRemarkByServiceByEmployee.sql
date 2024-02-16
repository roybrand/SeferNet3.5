IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_getRemarkByServiceByEmployee')
	BEGIN
		DROP  FUNCTION  fun_getRemarkByServiceByEmployee
	END

GO

ALTER  function [dbo].[fun_getRemarkByServiceByEmployee]
 (
	@DeptCode int , 
	@EmployeeID	int,
	@serviceCode int
 ) 
RETURNS varchar(500)
WITH EXECUTE AS CALLER

AS
BEGIN

declare @RemarkStr varchar(5000) 
	set @RemarkStr = ''
--=======
-- doctors services details 
--=======
SELECT @RemarkStr = @RemarkStr + RemarkText + ' ; ' FROM
(
	SELECT  
		[dbo].[rfn_GetFotmatedRemark](desr.RemarkText) as RemarkText 		

		FROM x_Dept_Employee_Service as xdes
		INNER JOIN x_dept_employee xde
			ON xdes.DeptEmployeeID = xde.DeptEmployeeID
		INNER JOIN EmployeeServices ON xde.employeeID = EmployeeServices.employeeID
										AND xdes.serviceCode = EmployeeServices.serviceCode	
		INNER JOIN Services ON xdes.serviceCode = Services.serviceCode
		LEFT JOIN serviceParentChild ON Services.serviceCode = serviceParentChild.childCode
		LEFT JOIN DeptEmployeeServiceRemarks desr ON xdes.DeptEmployeeServiceRemarkID = desr.DeptEmployeeServiceRemarkID

	WHERE xde.deptCode = @DeptCode and 
			xde.employeeID = @EmployeeID and 
			xdes.serviceCode = @serviceCode

	UNION

	SELECT 
	[dbo].[rfn_GetFotmatedRemark](desr.RemarkText) as RemarkText 	

	FROM x_Dept_Employee_Service as xdes
	INNER JOIN x_dept_employee xde
				ON xdes.DeptEmployeeID = xde.DeptEmployeeID
	INNER JOIN EmployeeServices ON xde.employeeID = EmployeeServices.employeeID
									AND xdes.serviceCode = EmployeeServices.serviceCode	
	INNER JOIN Services ON xdes.serviceCode = Services.serviceCode
	LEFT JOIN serviceParentChild ON Services.serviceCode = serviceParentChild.childCode
	INNER JOIN Services as S ON serviceParentChild.parentCode = s.serviceCode
	LEFT JOIN DeptEmployeeServiceRemarks desr ON xdes.DeptEmployeeServiceRemarkID = desr.DeptEmployeeServiceRemarkID

	WHERE xde.deptCode =  @DeptCode and 
			xde.employeeID = @EmployeeID and 
			xdes.serviceCode = @serviceCode

) as d 

SET @RemarkStr = SUBSTRING(@RemarkStr,0, LEN(@RemarkStr));

return (@RemarkStr);
	
end 

GO

