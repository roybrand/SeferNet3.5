IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_updateEmployeeRemarks')
	BEGIN
		DROP  Procedure  rpc_updateEmployeeRemarks
	END

GO

CREATE Procedure [dbo].[rpc_updateEmployeeRemarks]
	(
		@EmployeeRemarkID int,
		@RemarkText varchar(500),
		@ValidFrom datetime,
		@ValidTo datetime,
		@displayInInternet int,
		@delimitedDeptsCodes VARCHAR(100),
		@attributedToAllClinics BIT,
		@updateUser varchar(50),  
		@ErrCode int OUTPUT
	)

AS

DECLARE @CurrDeptCode INT
DECLARE @OrderNumber INT
DECLARE @currentCount INT
DECLARE @employeeID BIGINT


IF @validTo <= cast('1/1/1900 12:00:00 AM' as datetime)
	BEGIN
		SET  @validTo=null
	END		


DELETE x_Dept_Employee_EmployeeRemarks
WHERE EmployeeRemarkID = @EmployeeRemarkID
	
	

IF (@delimitedDeptsCodes <> '' AND @attributedToAllClinics <> 1)
BEGIN

	SET @currentCount = (SELECT COUNT(IntField) FROM SplitString(@delimitedDeptsCodes))
	SET @OrderNumber = 1
	SELECT @employeeID = EmployeeID	
						 FROM EmployeeRemarks
						 WHERE EmployeeRemarkId = @EmployeeRemarkID

	WHILE(@currentCount > 0)
	BEGIN
		SET @CurrDeptCode = (SELECT IntField FROM SplitString(@delimitedDeptsCodes) WHERE OrderNumber = @OrderNumber)
	
		INSERT INTO x_Dept_Employee_EmployeeRemarks
		(employeeRemarkID, UpdateUser, UpdateDate, DeptEmployeeID)
		SELECT 
		@EmployeeRemarkID, @UpdateUser, GetDate(), DeptEmployeeID
		FROM x_Dept_Employee
		WHERE deptCode = @CurrDeptCode
		AND EmployeeID = @employeeID

		SET @OrderNumber = @OrderNumber + 1
		SET @currentCount = @currentCount - 1
	END	
END
	

UPDATE EmployeeRemarks
SET RemarkText = @remarkText,
validFrom = @validFrom,
validTo = @validTo,
displayInInternet = @displayInInternet,
ActiveFrom = DATEADD(dd, - (SELECT DIC_GeneralRemarks.ShowForPreviousDays FROM DIC_GeneralRemarks WHERE DIC_GeneralRemarks.remarkID = EmployeeRemarks.DicRemarkID), @validFrom),
updateUser = @updateUser,
updateDate = getdate()
FROM EmployeeRemarks
JOIN DIC_GeneralRemarks ON EmployeeRemarks.DicRemarkID = DIC_GeneralRemarks.remarkID
WHERE EmployeeRemarkID = @EmployeeRemarkID

GO

GRANT EXEC ON rpc_updateEmployeeRemarks TO PUBLIC

GO

