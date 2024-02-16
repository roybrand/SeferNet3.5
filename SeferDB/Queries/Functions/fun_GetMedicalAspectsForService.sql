IF EXISTS (SELECT * FROM sysobjects WHERE type = 'FN' AND name = 'fun_GetMedicalAspectsForService')
	BEGIN
		DROP  function  fun_GetMedicalAspectsForService
	END
GO

CREATE FUNCTION [dbo].[fun_GetMedicalAspectsForService]
(
	@ServiceCode int,
	@DeptEmployeeID int
)
RETURNS VARCHAR(1000)
AS
BEGIN
    DECLARE @p_str VARCHAR(1000)
    SET @p_str = ''
    
	SELECT @p_str = @p_str + MedicalServiceDesc + '<br>'
	FROM
		(SELECT DISTINCT MA830.MedicalServiceDesc
		FROM MedicalAspectsToSefer MAS
		JOIN x_Dept_Employee_Service xDES ON MAS.SeferCode = xDES.serviceCode
		JOIN x_Dept_Employee xDE ON xDES.DeptEmployeeID = xDE.DeptEmployeeID
		JOIN MF_MedicalAspects830 MA830 ON MAS.MedicalAspectCode = MA830.MedicalServiceCode
		JOIN x_dept_medicalAspect xDMA ON xDE.deptCode = xDMA.NewDeptCode
										AND xDMA.MedicalAspectCode = MAS.MedicalAspectCode
		WHERE MAS.SeferCode = @ServiceCode
		AND xDE.DeptEmployeeID = @DeptEmployeeID ) T   

	IF len(@p_str) > 1
	-- remove last <br>
	BEGIN
		SET @p_str = SUBSTRING(@p_str, 0, len(@p_str) - len('<br>') + 1)
	END
	
    RETURN @p_str

END

GO

grant exec on fun_GetMedicalAspectsForService to public 
GO    
