IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_insertEmployeeRemarks')
	BEGIN
		DROP  Procedure  rpc_insertEmployeeRemarks
	END
GO

CREATE Procedure [dbo].[rpc_insertEmployeeRemarks]
	(
		@EmployeeID int,
		@RemarkText varchar(500),
		@dicRemarkID INT,
		@attributedToAllClinics BIT,
		@delimitedDepts VARCHAR(500),
		@displayInInternet int,
		@ValidFrom datetime,
		@ValidTo datetime,
		@updateUser varchar(50),
		@ErrCode int OUTPUT
	)

AS

DECLARE @newID INT
DECLARE @count INT
DECLARE @currentCount INT
DECLARE @OrderNumber INT
DECLARE @CurrDeptCode INT
DECLARE @deptEmployeeID INT


IF @ValidFrom <= cast('1/1/1900 12:00:00 AM' as datetime)
	BEGIN
		SET  @ValidFrom = null
	END		

IF @validTo <= cast('1/1/1900 12:00:00 AM' as datetime)
	BEGIN
		SET  @validTo = null
	END		

IF @validTo > cast('6/6/2079 12:00:00 AM' as datetime)
	BEGIN
		SET  @validTo = '2079-06-06'
	END	
	
	INSERT INTO EmployeeRemarks 
	(EmployeeID, RemarkText, DicRemarkID, displayInInternet, AttributedToAllClinicsInCommunity , ValidFrom, ValidTo, ActiveFrom, updateDate, updateUser)
	VALUES 
	(@EmployeeID, @RemarkText, @dicRemarkID, @displayInInternet, @attributedToAllClinics, @ValidFrom, @ValidTo, 
		DATEADD(dd, - (SELECT DIC_GeneralRemarks.ShowForPreviousDays FROM DIC_GeneralRemarks WHERE DIC_GeneralRemarks.remarkID = @dicRemarkID), @validFrom),
		getdate(), @updateUser)
	
	SET @newID =  @@IDENTITY	

	IF (@attributedToAllClinics <> 1 AND @delimitedDepts <> '')
	BEGIN
	
		SET @count = (SELECT COUNT(IntField) FROM SplitString(@delimitedDepts))
		SET @currentCount = @count
		SET @OrderNumber = 1
	
		WHILE(@currentCount > 0)
		BEGIN
			SET @CurrDeptCode = (SELECT IntField FROM SplitString(@delimitedDepts) WHERE OrderNumber = @OrderNumber)
			
			SET @deptEmployeeID =  (SELECT DeptEmployeeID 
									FROM x_Dept_Employee
									WHERE deptCode = @CurrDeptCode
									AND employeeID = @EmployeeID)
									
		
			INSERT INTO x_Dept_Employee_EmployeeRemarks
			(employeeRemarkID, UpdateUser, UpdateDate, DeptEmployeeID)
			VALUES
			(@newID, @UpdateUser, GetDate(), @deptEmployeeID)

			SET @OrderNumber = @OrderNumber + 1
			SET @currentCount = @currentCount - 1
		END	
	END

 
	SET @ErrCode = @@Error

GO

GRANT EXEC ON dbo.rpc_insertEmployeeRemarks TO PUBLIC

GO

