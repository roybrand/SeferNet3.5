IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[dbo].[fun_getPharmacologyManagerName]') and xtype in (N'FN', N'IF', N'TF'))
	DROP FUNCTION [dbo].[fun_getPharmacologyManagerName]
GO

CREATE FUNCTION [dbo].[fun_getPharmacologyManagerName]
(
	@DeptCode int
)

RETURNS varchar(100)

AS
BEGIN
	DECLARE  @strPharmacologyManagerName varchar(100)
	SET @strPharmacologyManagerName = ''
	
	
--------- Clinic itself (if it is of 401 type) ----------------------------
	 set @strPharmacologyManagerName = 
							(SELECT  TOP 1 DegreeName + ' ' + lastName + ' ' + firstName
							FROM employee
							INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode
							INNER JOIN x_dept_employee ON employee.employeeID = x_dept_employee.employeeID
							INNER JOIN x_Dept_Employee_Position ON x_dept_employee.DeptEmployeeID = x_Dept_Employee_Position.DeptEmployeeID 								
							INNER JOIN mappingPositions ON x_Dept_Employee_Position.positionCode = mappingPositions.positionCode
							INNER JOIN Dept ON x_dept_employee.deptCode = Dept.deptCode
							WHERE mappingPositions.mappedToManager = 1
							AND Dept.typeUnitCode = 401 -- בית מרקחת
							AND Dept.deptCode = @deptCode)
							
	if(@strPharmacologyManagerName = '' or @strPharmacologyManagerName is null )						
	begin
		 select @strPharmacologyManagerName = Dept.managerName 
		 from Dept 
		 where Dept.deptCode = @deptCode
		 AND Dept.typeUnitCode = 401			
	end
	
	--------- Clinic itself (if it is of 65 or 801 type) ----------------------------
	if(@strPharmacologyManagerName = '' or @strPharmacologyManagerName is null )
	begin	
		set @strPharmacologyManagerName = 
							(SELECT  TOP 1 DegreeName + ' ' + lastName + ' ' + firstName
							FROM employee
							INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode
							INNER JOIN x_dept_employee ON employee.employeeID = x_dept_employee.employeeID
							INNER JOIN x_Dept_Employee_Position ON x_dept_employee.DeptEmployeeID = x_Dept_Employee_Position.DeptEmployeeID 								
								AND x_Dept_Employee_Position.positionCode = 59
							INNER JOIN Dept ON x_dept_employee.deptCode = Dept.deptCode
							WHERE Dept.deptCode = @deptCode)
	end
------- If it has Subordinate clinic of 401 type --------------------------------		
	if(@strPharmacologyManagerName = '' or @strPharmacologyManagerName is null )						
	begin	
		set @strPharmacologyManagerName = 
				(SELECT  TOP 1 DegreeName + ' ' + lastName + ' ' + firstName
				FROM employee
				INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode
				INNER JOIN x_dept_employee ON employee.employeeID = x_dept_employee.employeeID
				INNER JOIN x_Dept_Employee_Position ON x_dept_employee.DeptEmployeeID = x_Dept_Employee_Position.DeptEmployeeID 								
				INNER JOIN mappingPositions ON x_Dept_Employee_Position.positionCode = mappingPositions.positionCode
				INNER JOIN Dept ON x_dept_employee.deptCode = Dept.deptCode
				JOIN Dept SA ON Dept.subAdministrationCode = SA.deptCode
				 
				WHERE mappingPositions.mappedToManager = 1
				AND Dept.typeUnitCode = 401 -- בית מרקחת
				AND SA.deptCode = @deptCode
				AND SA.typeUnitCode NOT in (65, 801) -- מנהלת, מחוז	
				)	
	end	

	if(@strPharmacologyManagerName = '' or @strPharmacologyManagerName is null )						
	begin
		 SELECT @strPharmacologyManagerName = Dept.managerName 
		 FROM Dept
		 JOIN Dept SA ON Dept.subAdministrationCode = SA.deptCode
		 WHERE SA.deptCode = @deptCode
		 AND SA.typeUnitCode NOT in (65, 801)
		 AND Dept.typeUnitCode = 401
		 AND Dept.status <> 0			 			
	end

------- If subAdministration for this clinic has another Subordinate clinic of 401 type --------------------------------

	if(@strPharmacologyManagerName = '' or @strPharmacologyManagerName is null )						
	begin
		set @strPharmacologyManagerName = 
							(SELECT  TOP 1 DegreeName + ' ' + lastName + ' ' + firstName
							FROM employee
							INNER JOIN DIC_EmployeeDegree ON employee.degreeCode = DIC_EmployeeDegree.DegreeCode
							INNER JOIN x_dept_employee ON employee.employeeID = x_dept_employee.employeeID
							INNER JOIN x_Dept_Employee_Position ON x_dept_employee.DeptEmployeeID = x_Dept_Employee_Position.DeptEmployeeID 								
							INNER JOIN mappingPositions ON x_Dept_Employee_Position.positionCode = mappingPositions.positionCode
							INNER JOIN Dept ON x_dept_employee.deptCode = Dept.deptCode
							INNER JOIN Dept SubAdmin ON Dept.subAdministrationCode = SubAdmin.deptCode
							INNER JOIN Dept SubordinateDept ON SubAdmin.deptCode = SubordinateDept.subAdministrationCode
							
							WHERE mappingPositions.mappedToManager = 1
							AND SubordinateDept.typeUnitCode = 401 -- בית מרקחת
							AND Dept.typeUnitCode = 301 -- יחידה במרפאה
							AND Dept.deptCode = @deptCode)		
	end
	
	if(@strPharmacologyManagerName = '' or @strPharmacologyManagerName is null )						
	begin
		 select @strPharmacologyManagerName = SubordinateDept.managerName 
		 from Dept 
		INNER JOIN Dept SubAdmin ON Dept.subAdministrationCode = SubAdmin.deptCode
		INNER JOIN Dept SubordinateDept ON SubAdmin.deptCode = SubordinateDept.subAdministrationCode
		 
		 where Dept.deptCode = @deptCode
		 AND SubordinateDept.typeUnitCode = 401
		 AND Dept.typeUnitCode = 301
		AND SubordinateDept.status <> 0			
	end	

---------------------------------------	
	
	IF(@strPharmacologyManagerName is null )	
		SET @strPharmacologyManagerName = ''					
	
	RETURN( @strPharmacologyManagerName )		
END

GO


GRANT EXEC ON dbo.fun_getPharmacologyManagerName TO [clalit\webuser]
GO

GRANT EXEC ON dbo.fun_getPharmacologyManagerName TO [clalit\IntranetDev]
GO
