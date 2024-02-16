
-- drop all constraints of linked tables

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_EmployeeStatusInDept_x_Dept_Employee]') AND parent_object_id = OBJECT_ID(N'[dbo].[EmployeeStatusInDept]'))
ALTER TABLE [dbo].[EmployeeStatusInDept] DROP CONSTRAINT [FK_EmployeeStatusInDept_x_Dept_Employee]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DeptEmployeePhones_x_Dept_Employee]') AND parent_object_id = OBJECT_ID(N'[dbo].[DeptEmployeePhones]'))
ALTER TABLE [dbo].[DeptEmployeePhones] DROP CONSTRAINT [FK_DeptEmployeePhones_x_Dept_Employee]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_x_Dept_Employee_Position_x_Dept_Employee]') AND parent_object_id = OBJECT_ID(N'[dbo].[x_Dept_Employee_Position]'))
ALTER TABLE [dbo].[x_Dept_Employee_Position] DROP CONSTRAINT [FK_x_Dept_Employee_Position_x_Dept_Employee]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_x_Dept_Employee_Profession_x_Dept_Employee]') AND parent_object_id = OBJECT_ID(N'[dbo].[x_Dept_Employee_Profession]'))
ALTER TABLE [dbo].[x_Dept_Employee_Profession] DROP CONSTRAINT [FK_x_Dept_Employee_Profession_x_Dept_Employee]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_deptEmployeeReception_x_Dept_Employee]') AND parent_object_id = OBJECT_ID(N'[dbo].[deptEmployeeReception]'))
ALTER TABLE [dbo].[deptEmployeeReception] DROP CONSTRAINT [FK_deptEmployeeReception_x_Dept_Employee]
GO


IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_x_Dept_Employee_Service_x_Dept_Employee]') AND parent_object_id = OBJECT_ID(N'[dbo].[x_Dept_Employee_Service]'))
ALTER TABLE [dbo].[x_Dept_Employee_Service] DROP CONSTRAINT [FK_x_Dept_Employee_Service_x_Dept_Employee]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_x_Dept_Employee_EmployeeRemarks_x_Dept_Employee]') AND parent_object_id = OBJECT_ID(N'[dbo].[x_Dept_Employee_EmployeeRemarks]'))
ALTER TABLE [dbo].[x_Dept_Employee_EmployeeRemarks] DROP CONSTRAINT [FK_x_Dept_Employee_EmployeeRemarks_x_Dept_Employee]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_EmployeeQueueOrderMethod_x_Dept_Employee]') AND parent_object_id = OBJECT_ID(N'[dbo].[EmployeeQueueOrderMethod]'))
ALTER TABLE [dbo].[EmployeeQueueOrderMethod] DROP CONSTRAINT [FK_EmployeeQueueOrderMethod_x_Dept_Employee]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_EmployeeStatusInDept_x_Dept_Employee]') AND parent_object_id = OBJECT_ID(N'[dbo].[EmployeeStatusInDept]'))
ALTER TABLE [dbo].[EmployeeStatusInDept] DROP CONSTRAINT [FK_EmployeeStatusInDept_x_Dept_Employee]
GO

-- Drop trigger that updates dept names in Dept table, we don't need that trigget because there is a job that updates that table
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[Update_Dept]'))
DROP TRIGGER [dbo].[Update_Dept]
GO



-- drop primary key and set a new one  *******************************
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[PK_x_Dept_Employee_1]') )
BEGIN
	ALTER TABLE [dbo].[x_Dept_Employee] DROP CONSTRAINT [PK_x_Dept_Employee_1]
END
go

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[PK_x_Dept_Employee]') )
BEGIN
	ALTER TABLE [dbo].[x_Dept_Employee] DROP CONSTRAINT [PK_x_Dept_Employee]
END
go

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'DeptEmployeeID' AND TABLE_NAME = 'x_dept_employee')
	ALTER TABLE x_dept_employee
	ADD DeptEmployeeID [bigint] IDENTITY(1,1) NOT NULL
go


IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[PK_x_Dept_Employee]') 
																			AND parent_obj = OBJECT_ID(N'[dbo].[x_Dept_Employee]'))
 ALTER TABLE [dbo].[x_Dept_Employee] ADD CONSTRAINT [PK_x_Dept_Employee] PRIMARY KEY CLUSTERED 
(
	[DeptEmployeeID] ASC
)WITH (PAD_INDEX  = OFF, 
STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, 
ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]


go
-- ******************************
-- Dept Employee Phones   CHECKED
-- ******************************

 

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'DeptEmployeeID' AND TABLE_NAME = 'DeptEmployeePhones')
BEGIN
	ALTER TABLE [DeptEmployeePhones]
	ADD DeptEmployeeID BIGINT NOT NULL DEFAULT 1
END
go

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'ID' AND TABLE_NAME = 'DeptEmployeePhones')
BEGIN
	ALTER TABLE [DeptEmployeePhones]
	ADD ID BIGINT IDENTITY (1,1) NOT NULL
END
go


IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DeptEmployeePhones_x_Dept_Employee]') 
																AND parent_object_id = OBJECT_ID(N'[dbo].[DeptEmployeePhones]'))
BEGIN
	ALTER TABLE [dbo].[DeptEmployeePhones]  DROP CONSTRAINT [FK_DeptEmployeePhones_x_Dept_Employee]
END
go

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DeptEmployeePhones_x_Dept_Employee]') 
																AND parent_object_id = OBJECT_ID(N'[dbo].[DeptEmployeePhones]'))
BEGIN
	ALTER TABLE [dbo].[DeptEmployeePhones]  WITH NOCHECK ADD  CONSTRAINT [FK_DeptEmployeePhones_x_Dept_Employee] FOREIGN KEY(DeptEmployeeID)
	REFERENCES [dbo].[x_Dept_Employee] (DeptEmployeeID)
	ON DELETE CASCADE
END
go


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'EmployeeID' AND TABLE_NAME = 'DeptEmployeePhones')
BEGIN
	DECLARE @str VARCHAR(5000)
	SET @str = 'UPDATE [DeptEmployeePhones]
				SET DeptEmployeeID = xd.DeptEmployeeID
				FROM x_dept_employee  xd
				INNER JOIN DeptEmployeePhones dep ON xd.DeptCode = dep.DeptCode  AND xd.EmployeeID = dep.EmployeeID'
	EXEC (@str)
END
go

IF EXISTS  (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[PK_DeptEmployeePhones]') 
																			AND parent_obj = OBJECT_ID(N'[dbo].[DeptEmployeePhones]'))
BEGIN
	ALTER TABLE [dbo].[DeptEmployeePhones] DROP CONSTRAINT [PK_DeptEmployeePhones]

	ALTER TABLE [dbo].[DeptEmployeePhones] WITH CHECK ADD CONSTRAINT [PK_DeptEmployeePhones]
	PRIMARY KEY CLUSTERED (ID ASC)
END
go

BEGIN TRY
DROP INDEX ix_employeeID ON deptEmployeePhones
END TRY
BEGIN CATCH END CATCH

go

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'EmployeeID' AND TABLE_NAME = 'DeptEmployeePhones')
	ALTER TABLE [DeptEmployeePhones]
	DROP COLUMN EmployeeID

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'DeptCode' AND TABLE_NAME = 'DeptEmployeePhones')
	ALTER TABLE [DeptEmployeePhones]
	DROP COLUMN DeptCode
																		   
																		   
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE name = 'ix_DeptEmployeePhones_employeeID')	 
	CREATE INDEX ix_DeptEmployeePhones_employeeID
	ON dbo.DeptEmployeePhones (DeptEmployeeID)


GO

DELETE [DeptEmployeePhones]
WHERE DeptEmployeeID IS NULL

go

-- ******************************
-- x_Dept_Employee_Service  CHECKED
-- ******************************



IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_EmployeeServicePhones_x_Dept_Employee_Service]') AND parent_object_id = OBJECT_ID(N'[dbo].[DeptEmployeeServiceStatus]'))
	ALTER TABLE [dbo].[DeptEmployeeServiceStatus] DROP CONSTRAINT [FK_EmployeeServicePhones_x_Dept_Employee_Service]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_EmployeeServiceQueueOrderMethod_x_Dept_Employee_Service]') 
																	AND parent_object_id = OBJECT_ID(N'[dbo].[EmployeeServiceQueueOrderMethod]'))
	ALTER TABLE [dbo].[EmployeeServiceQueueOrderMethod] DROP CONSTRAINT [FK_EmployeeServiceQueueOrderMethod_x_Dept_Employee_Service]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_EmployeeServicePhones_x_Dept_Employee_Service]') AND parent_object_id = OBJECT_ID(N'[dbo].[DeptEmployeeServiceStatus]'))
	ALTER TABLE [dbo].[DeptEmployeeServiceStatus] DROP CONSTRAINT [FK_EmployeeServicePhones_x_Dept_Employee_Service]
GO


IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'DeptEmployeeID' AND TABLE_NAME = 'x_Dept_Employee_Service')
BEGIN
	ALTER TABLE [x_Dept_Employee_Service]
	ADD DeptEmployeeID BIGINT NOT NULL DEFAULT 1
END
go

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_x_Dept_Employee_Service_x_Dept_Employee]') 
																AND parent_object_id = OBJECT_ID(N'[dbo].[x_Dept_Employee_Service]'))
BEGIN
	ALTER TABLE [dbo].[x_Dept_Employee_Service]  WITH CHECK ADD  CONSTRAINT [FK_x_Dept_Employee_Service_x_Dept_Employee] FOREIGN KEY(DeptEmployeeID)
	REFERENCES [dbo].[x_Dept_Employee] (DeptEmployeeID)
	ON DELETE CASCADE
END

GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'EmployeeID' AND TABLE_NAME = 'x_Dept_Employee_Service')
BEGIN
	DECLARE @str VARCHAR(5000)
	
	SET @str = 'UPDATE [x_Dept_Employee_Service]
				SET DeptEmployeeID = xd.DeptEmployeeID
				FROM x_dept_employee  xd
				INNER JOIN x_Dept_Employee_Service der ON xd.DeptCode = der.DeptCode  AND xd.EmployeeID = der.EmployeeID'
	EXEC (@str)
END
go

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DeptEmployeeServiceStatus_x_Dept_Employee_Service]') 
										AND parent_object_id = OBJECT_ID(N'[dbo].[DeptEmployeeServiceStatus]'))
BEGIN
	ALTER TABLE dbo.DeptEmployeeServiceStatus
		DROP CONSTRAINT FK_DeptEmployeeServiceStatus_x_Dept_Employee_Service
	
	ALTER TABLE dbo.x_Dept_Employee_Service SET (LOCK_ESCALATION = TABLE)
END 
go

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[DF__DeptEmplo__x_dep__346CDFD1]') 
										AND parent_object_id = OBJECT_ID(N'[dbo].[DeptEmployeeServiceStatus]'))
BEGIN
	ALTER TABLE dbo.DeptEmployeeServiceStatus
		DROP CONSTRAINT DF__DeptEmplo__x_dep__346CDFD1
END
go

IF exists (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'x_dept_employee_serviceID' AND TABLE_NAME = 'DeptEmployeeServiceStatus')
begin
	ALTER TABLE dbo.DeptEmployeeServiceStatus
		DROP COLUMN x_dept_employee_serviceID

	ALTER TABLE dbo.DeptEmployeeServiceStatus SET (LOCK_ESCALATION = TABLE)
end 
go

-- DeptEmployeeServiceStatus
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'x_dept_employee_serviceID' AND TABLE_NAME = 'DeptEmployeeServiceStatus')
BEGIN 
	DECLARE @str VARCHAR(5000)
	
	ALTER TABLE DeptEmployeeServiceStatus
	ADD x_dept_employee_serviceID INT NOT NULL DEFAULT 1

																				   
	IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DeptEmployeeServiceStatus_x_Dept_Employee_Service]') 
																AND parent_object_id = OBJECT_ID(N'[dbo].[DeptEmployeeServiceStatus]'))
		ALTER TABLE [dbo].[DeptEmployeeServiceStatus] DROP CONSTRAINT FK_DeptEmployeeServiceStatus_x_Dept_Employee_Service


	
	SET @str = 'UPDATE [DeptEmployeeServiceStatus]
				SET x_dept_employee_serviceID = xdes.x_dept_employee_serviceID
				FROM x_dept_employee_service  xdes
				INNER JOIN DeptEmployeeServiceStatus dess ON xdes.DeptCode = dess.DeptCode  AND xdes.EmployeeID = dess.EmployeeID'
	EXEC (@str)


	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DeptEmployeeServiceStatus_x_Dept_Employee_Service]') 
															AND parent_object_id = OBJECT_ID(N'[dbo].[DeptEmployeeServiceStatus]'))
		ALTER TABLE [dbo].[DeptEmployeeServiceStatus]  WITH CHECK ADD  CONSTRAINT [FK_DeptEmployeeServiceStatus_x_Dept_Employee_Service] 
		FOREIGN KEY(x_dept_employee_serviceID) REFERENCES [dbo].[x_dept_employee_service] (x_dept_employee_serviceID)
		ON DELETE CASCADE
END
go

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DeptEmployeeServiceStatus_Employee]') 
															AND parent_object_id = OBJECT_ID(N'[dbo].[DeptEmployeeServiceStatus]'))																	
	ALTER TABLE dbo.DeptEmployeeServiceStatus DROP CONSTRAINT FK_DeptEmployeeServiceStatus_Employee
go

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'EmployeeID' AND TABLE_NAME = 'DeptEmployeeServiceStatus')
BEGIN
	ALTER TABLE DeptEmployeeServiceStatus
	DROP COLUMN EmployeeID
END
go

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DeptEmployeeServiceStatus_Dept]') 
															AND parent_object_id = OBJECT_ID(N'[dbo].[DeptEmployeeServiceStatus]'))																
	ALTER TABLE dbo.DeptEmployeeServiceStatus DROP CONSTRAINT FK_DeptEmployeeServiceStatus_Dept
go

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'DeptCode' AND TABLE_NAME = 'DeptEmployeeServiceStatus')
BEGIN
	ALTER TABLE DeptEmployeeServiceStatus
	DROP COLUMN DeptCode
END
go

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DeptEmployeeServiceStatus_service]') 
																AND parent_object_id = OBJECT_ID(N'[dbo].[DeptEmployeeServiceStatus]'))
	ALTER TABLE dbo.DeptEmployeeServiceStatus			
	DROP CONSTRAINT FK_DeptEmployeeServiceStatus_service
go

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'ServiceCode' AND TABLE_NAME = 'DeptEmployeeServiceStatus')
	ALTER TABLE DeptEmployeeServiceStatus
	DROP COLUMN ServiceCode
go

IF EXISTS  (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[PK_x_Dept_Employee_Service]') 
																			AND parent_obj = OBJECT_ID(N'[dbo].[x_Dept_Employee_Service]'))
BEGIN
	ALTER TABLE [dbo].[x_Dept_Employee_Service] DROP CONSTRAINT [PK_x_Dept_Employee_Service]

	ALTER TABLE [dbo].[x_Dept_Employee_Service]  WITH CHECK ADD CONSTRAINT [PK_x_Dept_Employee_Service]
	PRIMARY KEY CLUSTERED (x_Dept_Employee_ServiceID ASC)
END
go

-- EmployeeServiceQueueOrderMethod
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'x_dept_employee_serviceID' AND TABLE_NAME = 'EmployeeServiceQueueOrderMethod')
BEGIN
	DECLARE @str VARCHAR(5000)
	
	ALTER TABLE EmployeeServiceQueueOrderMethod
	ADD x_dept_employee_serviceID INT NOT NULL DEFAULT 1


	SET @str = 'UPDATE [EmployeeServiceQueueOrderMethod]
				SET x_dept_employee_serviceID = xdes.x_dept_employee_serviceID
				FROM x_dept_employee_service  xdes
				INNER JOIN EmployeeServiceQueueOrderMethod dess ON xdes.DeptCode = dess.DeptCode  AND xdes.EmployeeID = dess.EmployeeID'
	EXEC (@str)


	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_EmployeeServiceQueueOrderMethod_x_Dept_Employee_Service]') 
															AND parent_object_id = OBJECT_ID(N'[dbo].[EmployeeServiceQueueOrderMethod]'))
		ALTER TABLE [dbo].[EmployeeServiceQueueOrderMethod] WITH CHECK ADD  CONSTRAINT FK_EmployeeServiceQueueOrderMethod_x_Dept_Employee_Service
		FOREIGN KEY(x_dept_employee_serviceID) REFERENCES [dbo].[x_dept_employee_service] (x_dept_employee_serviceID)
		ON DELETE CASCADE
END	
go

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'EmployeeID' AND TABLE_NAME = 'EmployeeServiceQueueOrderMethod')
BEGIN
	ALTER TABLE EmployeeServiceQueueOrderMethod
	DROP COLUMN EmployeeID
END
go

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'DeptCode' AND TABLE_NAME = 'EmployeeServiceQueueOrderMethod')
BEGIN
	ALTER TABLE EmployeeServiceQueueOrderMethod
	DROP COLUMN DeptCode
END
go

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'ServiceCode' AND TABLE_NAME = 'EmployeeServiceQueueOrderMethod')
BEGIN
	ALTER TABLE EmployeeServiceQueueOrderMethod
	DROP COLUMN ServiceCode
END
go						  	


-- DeptEmployeeServiceRemarks
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'x_dept_employee_serviceID' AND TABLE_NAME = 'DeptEmployeeServiceRemarks')
BEGIN 
	DECLARE @str VARCHAR(5000)
	
	ALTER TABLE DeptEmployeeServiceRemarks
	ADD x_dept_employee_serviceID INT 

																				   
	IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DeptEmployeeServiceRemarks_x_Dept_Employee_Service]') 
																AND parent_object_id = OBJECT_ID(N'[dbo].[DeptEmployeeServiceRemarks]'))
		ALTER TABLE [dbo].[DeptEmployeeServiceRemarks] DROP CONSTRAINT FK_DeptEmployeeServiceRemarks_x_Dept_Employee_Service


	SET @str = 'UPDATE [DeptEmployeeServiceRemarks]
				SET x_dept_employee_serviceID = xdes.x_dept_employee_serviceID
				FROM x_dept_employee_service  xdes
				INNER JOIN DeptEmployeeServiceRemarks desr ON xdes.DeptCode = desr.DeptCode  AND xdes.EmployeeID = desr.EmployeeID
																							AND xdes.ServiceCode = desr.ServiceCode'
	EXEC (@str)


	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DeptEmployeeServiceRemarks_x_Dept_Employee_Service]') 
															AND parent_object_id = OBJECT_ID(N'[dbo].[DeptEmployeeServiceRemarks]'))
		ALTER TABLE [dbo].[DeptEmployeeServiceRemarks]  WITH CHECK ADD  CONSTRAINT [FK_DeptEmployeeServiceRemarks_x_Dept_Employee_Service] 
		FOREIGN KEY(x_dept_employee_serviceID) REFERENCES [dbo].[x_dept_employee_service] (x_dept_employee_serviceID)
		ON DELETE CASCADE
END
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'EmployeeID' AND TABLE_NAME = 'DeptEmployeeServiceRemarks')
BEGIN
	ALTER TABLE DeptEmployeeServiceRemarks
	DROP COLUMN EmployeeID
END
go

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'DeptCode' AND TABLE_NAME = 'DeptEmployeeServiceRemarks')
BEGIN
	ALTER TABLE DeptEmployeeServiceRemarks
	DROP COLUMN DeptCode
END
go

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'ServiceCode' AND TABLE_NAME = 'DeptEmployeeServiceRemarks')
	ALTER TABLE DeptEmployeeServiceRemarks
	DROP COLUMN ServiceCode
go

DELETE DeptEmployeeServiceRemarks
WHERE x_dept_employee_serviceID IS NULL

go

BEGIN TRY
	DROP INDEX ix_employeeID ON [x_Dept_Employee_Service]
END TRY
BEGIN CATCH
END CATCH
go

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'EmployeeID' AND TABLE_NAME = 'x_Dept_Employee_Service')
	ALTER TABLE [x_Dept_Employee_Service]
	DROP COLUMN EmployeeID
go

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'DeptCode' AND TABLE_NAME = 'x_Dept_Employee_Service')
	ALTER TABLE [x_Dept_Employee_Service]
	DROP COLUMN DeptCode				
go


DELETE [x_Dept_Employee_Service]
WHERE DeptEmployeeID IS NULL

go

-- ******************************
-- deptEmployeeReception  CHECKED
-- ******************************

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'DeptEmployeeID' AND TABLE_NAME = 'deptEmployeeReception')
BEGIN
	ALTER TABLE [deptEmployeeReception]
	ADD DeptEmployeeID BIGINT  NOT NULL DEFAULT 1
END
go

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_deptEmployeeReception_x_Dept_Employee]') 
																AND parent_object_id = OBJECT_ID(N'[dbo].[deptEmployeeReception]'))
BEGIN
	ALTER TABLE [dbo].[deptEmployeeReception]  WITH CHECK ADD  CONSTRAINT [FK_deptEmployeeReception_x_Dept_Employee] FOREIGN KEY(DeptEmployeeID)
	REFERENCES [dbo].[x_dept_employee] (DeptEmployeeID)
	ON DELETE CASCADE
END
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'EmployeeID' AND TABLE_NAME = 'deptEmployeeReception')
BEGIN
	DECLARE @str VARCHAR(5000) 
	SET @str = 'UPDATE deptEmployeeReception
				SET DeptEmployeeID = xd.DeptEmployeeID
				FROM x_dept_employee  xd
				INNER JOIN deptEmployeeReception der ON xd.DeptCode = der.DeptCode  AND xd.EmployeeID = der.EmployeeID'
	EXEC (@str)
END
go

IF EXISTS (SELECT * FROM dbo.sysindexes WHERE name = 'IX_deptEmployeeReception_receptionID')
	DROP INDEX IX_deptEmployeeReception_receptionID on deptemployeeReception
go


IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE name = 'IX_deptEmployeeReception_receptionDay')	 
	CREATE INDEX IX_deptEmployeeReception_receptionDay
	ON dbo.deptemployeeReception (receptionDay)
go

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[deptEmployeeReception]') AND name = N'ix_deptEmployeeReception__EmployeeID_validTo_validFrom_')
	DROP INDEX [ix_deptEmployeeReception__EmployeeID_validTo_validFrom_] ON [dbo].[deptEmployeeReception] WITH ( ONLINE = OFF )
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'EmployeeID' AND TABLE_NAME = 'deptEmployeeReception')
	ALTER TABLE deptEmployeeReception
	DROP COLUMN EmployeeID
go

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'DeptCode' AND TABLE_NAME = 'deptEmployeeReception')
	ALTER TABLE deptEmployeeReception
	DROP COLUMN DeptCode
go


-- ******************************
-- x_dept_Employee_position   CHECKED
-- ******************************



IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'DeptEmployeeID' AND TABLE_NAME = 'x_Dept_Employee_Position')
BEGIN
	ALTER TABLE [x_Dept_Employee_Position]
	ADD DeptEmployeeID BIGINT NOT NULL DEFAULT 1
END
go

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'ID' AND TABLE_NAME = 'x_Dept_Employee_Position')
BEGIN
	ALTER TABLE [x_Dept_Employee_Position]
	ADD ID BIGINT IDENTITY (1,1) NOT NULL
END
go

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_x_Dept_Employee_Position_x_Dept_Employee]') 
																AND parent_object_id = OBJECT_ID(N'[dbo].[x_Dept_Employee_Position]'))
BEGIN
	ALTER TABLE [dbo].[x_Dept_Employee_Position]  WITH CHECK ADD  CONSTRAINT [FK_x_Dept_Employee_Position_x_Dept_Employee] 
	FOREIGN KEY(DeptEmployeeID) REFERENCES [dbo].[x_Dept_Employee] (DeptEmployeeID)
	ON DELETE CASCADE
END
go

IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[PK_x_dept_Employee_position_1]') AND parent_obj = OBJECT_ID(N'[dbo].[x_dept_Employee_position]'))
	ALTER TABLE [dbo].[x_dept_Employee_position] DROP CONSTRAINT [PK_x_dept_Employee_position_1]
GO

IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[PK_x_dept_Employee_position]') AND parent_obj = OBJECT_ID(N'[dbo].[x_dept_Employee_position]'))
	ALTER TABLE [dbo].[x_dept_Employee_position] DROP CONSTRAINT [PK_x_dept_Employee_position]
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'EmployeeID' AND TABLE_NAME = 'x_dept_Employee_position')
BEGIN
	DECLARE @str VARCHAR(5000)
	SET @str = 'UPDATE [x_dept_Employee_position]
				SET DeptEmployeeID = xd.DeptEmployeeID
				FROM x_dept_employee  xd
				INNER JOIN x_dept_Employee_position dep ON xd.DeptCode = dep.DeptCode  AND xd.EmployeeID = dep.EmployeeID'
	EXEC (@str)
END
go

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'EmployeeID' AND TABLE_NAME = 'x_dept_Employee_position')
	ALTER TABLE [x_dept_Employee_position]
	DROP COLUMN EmployeeID
go

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'DeptCode' AND TABLE_NAME = 'x_dept_Employee_position')
	ALTER TABLE [x_dept_Employee_position]
	DROP COLUMN DeptCode
go
																	   
IF NOT EXISTS  (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[PK_x_dept_Employee_position]') 
																			AND parent_obj = OBJECT_ID(N'[dbo].[x_dept_Employee_position]'))
	ALTER TABLE [dbo].[x_dept_Employee_position]  WITH CHECK ADD CONSTRAINT [PK_x_dept_Employee_position]
	PRIMARY KEY CLUSTERED (ID ASC)

GO

IF NOT EXISTS  (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_x_Dept_Employee_Position_updateDate]') 
																			AND parent_obj = OBJECT_ID(N'[dbo].[x_dept_Employee_position]'))
ALTER TABLE [dbo].[x_dept_Employee_position] ADD  CONSTRAINT [DF_x_Dept_Employee_Position_updateDate]  
					DEFAULT (getdate()) FOR [updateDate]
GO

DELETE [x_dept_Employee_position]
WHERE DeptEmployeeID IS NULL



go



-- ******************************
-- x_dept_Employee_remarks  CHECKED
-- ******************************


IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'DeptEmployeeID' AND TABLE_NAME = 'x_Dept_Employee_EmployeeRemarks')
BEGIN
	ALTER TABLE [x_Dept_Employee_EmployeeRemarks]
	ADD DeptEmployeeID BIGINT NOT NULL DEFAULT 1
END
go

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'ID' AND TABLE_NAME = 'x_Dept_Employee_EmployeeRemarks')
BEGIN
	ALTER TABLE [x_Dept_Employee_EmployeeRemarks]
	ADD ID BIGINT IDENTITY (1,1) NOT NULL
END
go

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_x_Dept_Employee_EmployeeRemarks_x_Dept_Employee]') 
																AND parent_object_id = OBJECT_ID(N'[dbo].[x_Dept_Employee_EmployeeRemarks]'))
BEGIN
	ALTER TABLE [dbo].[x_Dept_Employee_EmployeeRemarks]  WITH CHECK ADD  CONSTRAINT [FK_x_Dept_Employee_EmployeeRemarks_x_Dept_Employee] FOREIGN KEY(DeptEmployeeID)
	REFERENCES [dbo].[x_Dept_Employee] (DeptEmployeeID)
	ON DELETE CASCADE
END
go

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_x_Dept_Employee_EmployeeRemarks_EmployeeRemarks]') 
																AND parent_object_id = OBJECT_ID(N'[dbo].[x_Dept_Employee_EmployeeRemarks]'))
BEGIN
	ALTER TABLE [dbo].[x_Dept_Employee_EmployeeRemarks]  WITH CHECK ADD  CONSTRAINT [FK_x_Dept_Employee_EmployeeRemarks_EmployeeRemarks] 
		FOREIGN KEY([EmployeeRemarkID]) REFERENCES [dbo].[EmployeeRemarks] ([EmployeeRemarkID])
	ON DELETE CASCADE
END

GO

IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[PK_x_Dept_Employee_EmployeeRemarks]') AND parent_obj = OBJECT_ID(N'[dbo].[x_Dept_Employee_EmployeeRemarks]'))
	ALTER TABLE [dbo].[x_Dept_Employee_EmployeeRemarks] DROP CONSTRAINT [PK_x_Dept_Employee_EmployeeRemarks]
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'EmployeeID' AND TABLE_NAME = 'x_Dept_Employee_EmployeeRemarks')
BEGIN
	DECLARE @str VARCHAR(5000)
	SET @str = 'UPDATE [x_Dept_Employee_EmployeeRemarks]
				SET DeptEmployeeID = xd.DeptEmployeeID
				FROM x_dept_employee  xd
				INNER JOIN x_Dept_Employee_EmployeeRemarks der ON xd.DeptCode = der.DeptCode  AND xd.EmployeeID = der.EmployeeID'
	EXEC (@str)
END
go

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'EmployeeID' AND TABLE_NAME = 'x_Dept_Employee_EmployeeRemarks')
	ALTER TABLE [x_Dept_Employee_EmployeeRemarks]
	DROP COLUMN EmployeeID
go

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'DeptCode' AND TABLE_NAME = 'x_Dept_Employee_EmployeeRemarks')
	ALTER TABLE [x_Dept_Employee_EmployeeRemarks]
	DROP COLUMN DeptCode
go
																	   
IF NOT EXISTS  (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[PK_x_Dept_Employee_EmployeeRemarks]') 
																			AND parent_obj = OBJECT_ID(N'[dbo].[x_Dept_Employee_EmployeeRemarks]'))
	ALTER TABLE [dbo].[x_Dept_Employee_EmployeeRemarks]  WITH CHECK ADD CONSTRAINT [PK_x_Dept_Employee_EmployeeRemarks]
	PRIMARY KEY CLUSTERED (ID ASC)
GO

IF NOT EXISTS  (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_x_Dept_Employee_EmployeeRemarks_updateDate]') 
																			AND parent_obj = OBJECT_ID(N'[dbo].[x_Dept_Employee_EmployeeRemarks]'))
ALTER TABLE [dbo].[x_Dept_Employee_EmployeeRemarks] ADD  CONSTRAINT [DF_x_Dept_Employee_EmployeeRemarks_updateDate]  
					DEFAULT (getdate()) FOR [updateDate]
GO

DELETE [x_Dept_Employee_EmployeeRemarks]
WHERE DeptEmployeeID IS NULL
go



-- ******************************
-- Employee Queue Order Method    CHECKED 
-- ******************************


IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DeptEmployeeQueueOrderPhones_DIC_PhonePrefix]') AND parent_object_id = OBJECT_ID(N'[dbo].[DeptEmployeeQueueOrderPhones]'))
ALTER TABLE [dbo].[DeptEmployeeQueueOrderPhones] DROP CONSTRAINT [FK_DeptEmployeeQueueOrderPhones_DIC_PhonePrefix]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DeptEmployeeQueueOrderPhones_EmployeeQueueOrderMethod]') AND parent_object_id = OBJECT_ID(N'[dbo].[DeptEmployeeQueueOrderPhones]'))
ALTER TABLE [dbo].[DeptEmployeeQueueOrderPhones] DROP CONSTRAINT [FK_DeptEmployeeQueueOrderPhones_EmployeeQueueOrderMethod]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_DeptEmployeeQueueOrderPhones_updateDate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DeptEmployeeQueueOrderPhones] DROP CONSTRAINT [DF_DeptEmployeeQueueOrderPhones_updateDate]
END

GO


IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_EmployeeQueueOrderHours_DIC_ReceptionDays]') AND parent_object_id = OBJECT_ID(N'[dbo].[EmployeeQueueOrderHours]'))
ALTER TABLE [dbo].[EmployeeQueueOrderHours] DROP CONSTRAINT [FK_EmployeeQueueOrderHours_DIC_ReceptionDays]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_EmployeeQueueOrderHours_EmployeeQueueOrderMethod]') AND parent_object_id = OBJECT_ID(N'[dbo].[EmployeeQueueOrderHours]'))
ALTER TABLE [dbo].[EmployeeQueueOrderHours] DROP CONSTRAINT [FK_EmployeeQueueOrderHours_EmployeeQueueOrderMethod]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_EmployeeQueueOrderHours_updateDate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[EmployeeQueueOrderHours] DROP CONSTRAINT [DF_EmployeeQueueOrderHours_updateDate]
END

GO


IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_EmployeeQueueOrderMethod_DIC_QueueOrderMethod]') AND parent_object_id = OBJECT_ID(N'[dbo].[EmployeeQueueOrderMethod]'))
ALTER TABLE [dbo].[EmployeeQueueOrderMethod] DROP CONSTRAINT [FK_EmployeeQueueOrderMethod_DIC_QueueOrderMethod]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_EmployeeQueueOrderMethod_updateDate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[EmployeeQueueOrderMethod] DROP CONSTRAINT [DF_EmployeeQueueOrderMethod_updateDate]
END

GO



IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'DeptEmployeeID' AND TABLE_NAME = 'EmployeeQueueOrderMethod')
BEGIN
	ALTER TABLE [EmployeeQueueOrderMethod]
	ADD DeptEmployeeID BIGINT NOT NULL DEFAULT 1
END
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_EmployeeQueueOrderMethod_x_Dept_Employee]') 
																AND parent_object_id = OBJECT_ID(N'[dbo].[EmployeeQueueOrderMethod]'))
	ALTER TABLE [dbo].[EmployeeQueueOrderMethod]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeQueueOrderMethod_x_Dept_Employee] FOREIGN KEY(DeptEmployeeID)
	REFERENCES [dbo].[x_Dept_Employee] (DeptEmployeeID)
	ON DELETE CASCADE
GO


IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[PK_EmployeeQueueOrderMethod]') AND parent_obj = OBJECT_ID(N'[dbo].[EmployeeQueueOrderMethod]'))
ALTER TABLE [dbo].[EmployeeQueueOrderMethod] DROP CONSTRAINT [PK_EmployeeQueueOrderMethod]
GO


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'EmployeeID' AND TABLE_NAME = 'EmployeeQueueOrderMethod')
BEGIN
	DECLARE @str VARCHAR(5000)
	SET @str = 'UPDATE [EmployeeQueueOrderMethod]
				SET DeptEmployeeID = xd.DeptEmployeeID
				FROM x_dept_employee  xd
				INNER JOIN [EmployeeQueueOrderMethod] dep ON xd.DeptCode = dep.DeptCode  AND xd.EmployeeID = dep.EmployeeID'
	EXEC (@str)
END
go

BEGIN TRY
DROP INDEX ix_employeeID ON EmployeeQueueOrderMethod
END TRY
BEGIN CATCH END CATCH
go

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'EmployeeID' AND TABLE_NAME = 'EmployeeQueueOrderMethod')
BEGIN
	ALTER TABLE EmployeeQueueOrderMethod
	DROP COLUMN EmployeeID
END
go

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'DeptCode' AND TABLE_NAME = 'EmployeeQueueOrderMethod')
BEGIN
	ALTER TABLE EmployeeQueueOrderMethod
	DROP COLUMN DeptCode
END
go

IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[PK_EmployeeQueueOrderMethod]') 
																			AND parent_obj = OBJECT_ID(N'[dbo].[EmployeeQueueOrderMethod]'))
BEGIN
	ALTER TABLE [dbo].[EmployeeQueueOrderMethod]  WITH CHECK ADD CONSTRAINT [PK_EmployeeQueueOrderMethod] 
	PRIMARY KEY CLUSTERED (QueueOrderMethodID ASC)
END
go

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE name = 'ix_EmployeeQueueOrderMethod_DeptEmployeeID')	 
	CREATE INDEX ix_EmployeeQueueOrderMethod_DeptEmployeeID
	ON dbo.EmployeeQueueOrderMethod (DeptEmployeeID) 
go


IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_EmployeeQueueOrderMethod_DIC_QueueOrderMethod]') 
																AND parent_object_id = OBJECT_ID(N'[dbo].[EmployeeQueueOrderMethod]'))
ALTER TABLE [dbo].[EmployeeQueueOrderMethod]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeQueueOrderMethod_DIC_QueueOrderMethod] FOREIGN KEY([QueueOrderMethod])
REFERENCES [dbo].[DIC_QueueOrderMethod] ([QueueOrderMethod])
ON DELETE CASCADE
GO


ALTER TABLE [dbo].[EmployeeQueueOrderMethod] ADD  CONSTRAINT [DF_EmployeeQueueOrderMethod_updateDate]  DEFAULT (getdate()) FOR [updateDate]
GO


IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[PK_EmployeeQueueOrderHours]') AND parent_obj = OBJECT_ID(N'[dbo].[EmployeeQueueOrderHours]'))
BEGIN
	ALTER TABLE [dbo].[EmployeeQueueOrderHours] DROP CONSTRAINT [PK_EmployeeQueueOrderHours] 
	
	ALTER TABLE [dbo].[EmployeeQueueOrderHours]  WITH CHECK ADD CONSTRAINT [PK_EmployeeQueueOrderHours] 
	PRIMARY KEY CLUSTERED (EmployeeQueueOrderHoursID ASC)
END

GO



ALTER TABLE [dbo].[EmployeeQueueOrderHours]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeQueueOrderHours_DIC_ReceptionDays] FOREIGN KEY([receptionDay])
REFERENCES [dbo].[DIC_ReceptionDays] ([ReceptionDayCode])
ON DELETE CASCADE
GO


ALTER TABLE [dbo].[EmployeeQueueOrderHours]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeQueueOrderHours_EmployeeQueueOrderMethod] FOREIGN KEY([QueueOrderMethodID])
REFERENCES [dbo].[EmployeeQueueOrderMethod] ([QueueOrderMethodID])
ON DELETE CASCADE
GO


ALTER TABLE [dbo].[EmployeeQueueOrderHours] ADD  CONSTRAINT [DF_EmployeeQueueOrderHours_updateDate]  DEFAULT (getdate()) FOR [updateDate]
GO


IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[PK_DeptEmployeeQueueOrderPhones]') AND parent_obj = OBJECT_ID(N'[dbo].[DeptEmployeeQueueOrderPhones]'))
BEGIN
	ALTER TABLE [dbo].[DeptEmployeeQueueOrderPhones]  DROP CONSTRAINT [PK_DeptEmployeeQueueOrderPhones] 

	ALTER TABLE [dbo].[DeptEmployeeQueueOrderPhones]  WITH CHECK ADD CONSTRAINT [PK_DeptEmployeeQueueOrderPhones] 
	PRIMARY KEY CLUSTERED (QueueOrderPhoneID ASC)
END

GO


ALTER TABLE [dbo].[DeptEmployeeQueueOrderPhones]  WITH CHECK ADD  CONSTRAINT [FK_DeptEmployeeQueueOrderPhones_DIC_PhonePrefix] FOREIGN KEY([prefix])
REFERENCES [dbo].[DIC_PhonePrefix] ([prefixCode])
GO

ALTER TABLE [dbo].[DeptEmployeeQueueOrderPhones] CHECK CONSTRAINT [FK_DeptEmployeeQueueOrderPhones_DIC_PhonePrefix]
GO

ALTER TABLE [dbo].[DeptEmployeeQueueOrderPhones]  WITH CHECK ADD  CONSTRAINT [FK_DeptEmployeeQueueOrderPhones_EmployeeQueueOrderMethod] FOREIGN KEY([QueueOrderMethodID])
REFERENCES [dbo].[EmployeeQueueOrderMethod] ([QueueOrderMethodID])
ON DELETE CASCADE
GO


ALTER TABLE [dbo].[DeptEmployeeQueueOrderPhones] ADD  CONSTRAINT [DF_DeptEmployeeQueueOrderPhones_updateDate]  DEFAULT (getdate()) FOR [updateDate]
GO


DELETE EmployeeQueueOrderMethod
WHERE DeptEmployeeID IS NULL
go

-- ******************************
-- EmployeeStatusInDept   CHECKED
-- ******************************


IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'DeptEmployeeID' AND TABLE_NAME = 'EmployeeStatusInDept')
BEGIN
	ALTER TABLE [EmployeeStatusInDept]
	ADD DeptEmployeeID BIGINT NOT NULL DEFAULT 1
END

GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_EmployeeStatusInDept_x_Dept_Employee]') 
																AND parent_object_id = OBJECT_ID(N'[dbo].[EmployeeStatusInDept]'))
	ALTER TABLE [dbo].[EmployeeStatusInDept]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeStatusInDept_x_Dept_Employee] FOREIGN KEY(DeptEmployeeID)
	REFERENCES [dbo].[x_Dept_Employee] (DeptEmployeeID)
	ON DELETE CASCADE
go

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'EmployeeID' AND TABLE_NAME = 'EmployeeStatusInDept')
BEGIN
	DECLARE @str VARCHAR(5000)
	SET @str = 'UPDATE [EmployeeStatusInDept]
				SET DeptEmployeeID = xd.DeptEmployeeID
				FROM x_dept_employee  xd
				INNER JOIN EmployeeStatusInDept dep ON xd.DeptCode = dep.DeptCode  AND xd.EmployeeID = dep.EmployeeID'
	
	EXEC (@str)
END
go

IF EXISTS  (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[PK_EmployeeStatusInDept]') AND parent_obj = OBJECT_ID(N'[dbo].[EmployeeStatusInDept]'))
BEGIN
	ALTER TABLE [dbo].[EmployeeStatusInDept] DROP CONSTRAINT [PK_EmployeeStatusInDept]

	ALTER TABLE [dbo].[EmployeeStatusInDept] ADD CONSTRAINT [PK_EmployeeStatusInDept] PRIMARY KEY CLUSTERED 
	(
		[StatusID] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
END
go	

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'EmployeeID' AND TABLE_NAME = 'EmployeeStatusInDept')
	ALTER TABLE EmployeeStatusInDept
	DROP COLUMN EmployeeID

go

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'DeptCode' AND TABLE_NAME = 'EmployeeStatusInDept')
	ALTER TABLE EmployeeStatusInDept
	DROP COLUMN DeptCode


go

/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.DeptReception
	DROP CONSTRAINT FK_DeptReception_DIC_ReceptionDays
GO
ALTER TABLE dbo.DIC_ReceptionDays SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.DeptReception ADD CONSTRAINT
	FK_DeptReception_DIC_ReceptionDays FOREIGN KEY
	(
	receptionDay
	) REFERENCES dbo.DIC_ReceptionDays
	(
	ReceptionDayCode
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.DeptReception SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
go
/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.deptEmployeeReception
	DROP CONSTRAINT FK_deptEmployeeReception_ReceptionDay
GO
ALTER TABLE dbo.DIC_ReceptionDays SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.deptEmployeeReception ADD CONSTRAINT
	FK_deptEmployeeReception_ReceptionDay FOREIGN KEY
	(
	receptionDay
	) REFERENCES dbo.DIC_ReceptionDays
	(
	ReceptionDayCode
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.deptEmployeeReception SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
go

IF not EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'NeighbourhoodOrInstituteCode' AND TABLE_NAME = 'Dept')
BEGIN
	ALTER TABLE Dept ADD NeighbourhoodOrInstituteCode varchar(50) NULL
END
GO

IF not EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'IsSite' AND TABLE_NAME = 'Dept')
BEGIN
	ALTER TABLE Dept ADD IsSite tinyint NULL
END
GO



-- ******************************
-- DeptServiceStatus
-- ******************************


IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DeptServiceStatus_Dept]') 
																					AND parent_object_id = OBJECT_ID(N'[dbo].[DeptServiceStatus]'))
	ALTER TABLE [dbo].[DeptServiceStatus] DROP CONSTRAINT [FK_DeptServiceStatus_Dept]
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DeptServiceStatus_Dept]') 
																AND parent_object_id = OBJECT_ID(N'[dbo].[DeptServiceStatus]'))
BEGIN
	ALTER TABLE [dbo].[DeptServiceStatus]  WITH NOCHECK ADD  CONSTRAINT [FK_DeptServiceStatus_Dept] FOREIGN KEY(DeptCode)
	REFERENCES [dbo].[Dept] (DeptCode)
	ON DELETE CASCADE
END

GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DeptServiceStatus_service]')  
																					AND parent_object_id = OBJECT_ID(N'[dbo].[DeptServiceStatus]'))
	ALTER TABLE [dbo].[DeptServiceStatus] DROP CONSTRAINT [FK_DeptServiceStatus_service]

GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DeptServiceStatus_service]') 
																AND parent_object_id = OBJECT_ID(N'[dbo].[DeptServiceStatus]'))
BEGIN
	ALTER TABLE [dbo].[DeptServiceStatus] WITH NOCHECK ADD  CONSTRAINT [FK_DeptServiceStatus_service] FOREIGN KEY(ServiceCode)
	REFERENCES [dbo].[Services] (ServiceCode)
	ON DELETE CASCADE
END
go

-- **************************************************************************************************************************

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SalServices]') AND type in (N'U'))
BEGIN

	CREATE TABLE [dbo].[SalServices](
		[ServiceCode] [int] NOT NULL,
		[ServiceName] [varchar](300) NULL,
		[EngName] [varchar](300) NULL,
		[IsCanceled] [bit] NULL,
	 CONSTRAINT [PK_SalServices] PRIMARY KEY CLUSTERED 
	(
		[ServiceCode] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	) ON [PRIMARY]

END

GO

SET ANSI_PADDING OFF
GO

-- **************************************************************************************************************************

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MushlamServicesToSal]') AND type in (N'U'))
BEGIN

	CREATE TABLE [dbo].[MushlamServicesToSal](
		[ID] [bigint] IDENTITY(1,1) NOT NULL,
		[MushlamGroupCode] [int] NULL,
		[MushlamSubGroupCode] [int] NULL,
		[SalServiceCode] [int] NULL,
	 CONSTRAINT [PK_MushlamServicesToSal] PRIMARY KEY CLUSTERED 
	(
		[ID] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	) ON [PRIMARY]

END

GO

-- **************************************************************************************************************************



--**** Yaniv - Start deleting ReceptionType ********************
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReceptionType]') AND type in (N'U'))
	DROP table ReceptionType
GO
--**** Yaniv - End deleting ReceptionType ********************

--**** Yaniv - Start DIC_ReceptionHoursTypes **********************

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DIC_ReceptionHoursTypes]') AND type in (N'U'))
	DROP TABLE [dbo].[DIC_ReceptionHoursTypes]
GO

CREATE TABLE [dbo].[DIC_ReceptionHoursTypes](
	[ReceptionHoursTypeID] [tinyint] IDENTITY(1,1) NOT NULL,
	[ReceptionTypeDescription] [varchar](50) NULL,
	[EnumName] [varchar](50) NULL,
 CONSTRAINT [PK_DIC_ReceptionHoursTypes] PRIMARY KEY CLUSTERED 
(
	[ReceptionHoursTypeID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


--**** Yaniv - End DIC_ReceptionHoursTypes **********************

--**** Yaniv - Start adding new column to DeptReception ----------------
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS
   WHERE COLUMN_NAME = 'ReceptionHoursTypeID' AND TABLE_NAME = 'DeptReception')
	ALTER TABLE DeptReception
	ADD ReceptionHoursTypeID tinyint null;
go
--**** Yaniv - End adding new column to DeptReception ----------------

--**** Yaniv - Start adding new column to subUnitType --------------------

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS
   WHERE COLUMN_NAME = 'DefaultReceptionHoursTypeID' AND TABLE_NAME = 'subUnitType')
	alter table subUnitType
	add DefaultReceptionHoursTypeID tinyint null DEFAULT 1
go
--**** Yaniv - End adding new column to subUnitType --------------------

if not exists (SELECT * FROM sysindexes WHERE name = 'uc_deptCode_employeeID_AgreementType')
BEGIN
	ALTER TABLE x_Dept_Employee
	ADD CONSTRAINT UC_deptCode_employeeID_AgreementType UNIQUE (deptCode,employeeID,AgreementType)
END
go

-- *********************************************************************************************************

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'ToDate' AND TABLE_NAME = 'DeptNames')
BEGIN 
	ALTER TABLE DeptNames
	ADD ToDate DATETIME NULL 
END
go
-- ********************************************************************************************************* 

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MushlamServiceSynonyms]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[MushlamServiceSynonyms](
		[GroupCode] [smallint] NULL,
		[SubGroupCode] [smallint] NULL,
		[ServiceSynonym] [varchar](100) NULL
	) ON [PRIMARY]

END
go
-- ********************************************************************************************************* 

/****** Object:  UserDefinedTableType [dbo].[tbl_UniqueIntArray]    Script Date: 02/05/2012 15:10:16 ******/
IF  EXISTS (SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'tbl_UniqueIntArray' AND ss.name = N'dbo')
DROP TYPE [dbo].[tbl_UniqueIntArray]
GO

CREATE TYPE [dbo].[tbl_UniqueIntArray] AS TABLE(
	[IntVal] [int] NOT NULL,
	PRIMARY KEY CLUSTERED 
(
	[IntVal] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO

-- ********************************************************************************************************* 
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'UnitType' AND COLUMN_NAME = 'IsCommunity')
	BEGIN
		ALTER table UnitType
		ADD IsCommunity bit
	END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'UnitType' AND COLUMN_NAME = 'IsMushlam')
	BEGIN
		ALTER table UnitType
		ADD IsMushlam bit
	END
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'UnitType' AND COLUMN_NAME = 'IsHospital')
	BEGIN
		ALTER table UnitType
		ADD IsHospital bit
	END
GO
-- ********************************************************************************************************* 

ALTER table Dept
ALTER column DeptName varchar(100)
go

ALTER table DeptNames
ALTER column DeptName varchar(100)
go

ALTER TABLE Dept
ALTER COLUMN addressComment varchar(500)
go
-- ********************************************************************************************************* 

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MushlamModels]') AND type in (N'U'))
BEGIN

	CREATE TABLE [dbo].[MushlamModels](
		[ID] [bigint] IDENTITY(1,1) NOT NULL,
		[GroupCode] [int] NOT NULL,
		[SubGroupCode] [int] NOT NULL,
		[ModelCode] [int] NOT NULL,
		[ModelDescription] [varchar](200) NOT NULL,
		[Remark] [varchar](200) NULL,
		[ParticipationAmount] [int] NULL,
		[WaitingPeriod] [smallint] NULL,
	 CONSTRAINT [PK_MushlamModels] PRIMARY KEY CLUSTERED 
	(
		[ID] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	) ON [PRIMARY]
END

GO

-- ********************************************************************************************************* 

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'MushlamServicesInformation' AND COLUMN_NAME = 'RepRemark')
	BEGIN
		ALTER TABLE MushlamServicesInformation
		ADD RepRemark VARCHAR(1200)
	END
GO

-- ********************************************************************************************************* 
	
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[PK_speciality]') )
BEGIN
	ALTER TABLE [dbo].[MushlamSpecialityToSefer] DROP CONSTRAINT [PK_speciality]
END
go

/****** Object:  Table [dbo].[MushlamSpecialityToSefer]    Script Date: 05/03/2012 09:52:58 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MushlamSpecialityToSefer]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[MushlamSpecialityToSefer](
	[MushlamTableCode] [int] NULL,
	[MushlamServiceCode] [int] NULL,
	[SeferServiceCode] [int] NULL,
	[UpdateUser] [varchar](30) NULL,
	[UpdateDate] [datetime] NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_speciality] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
ELSE
BEGIN
	ALTER TABLE MushlamSpecialityToSefer 
	DROP COLUMN id

	ALTER TABLE MushlamSpecialityToSefer 
	ADD ID INT IDENTITY(1,1)

	ALTER TABLE MushlamSpecialityToSefer 
	ADD CONSTRAINT PK_speciality PRIMARY KEY (ID)
END
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[PK_SubSpeciality]') )
BEGIN
	ALTER TABLE [dbo].[MushlamSubSpecialityToSefer] DROP CONSTRAINT [PK_SubSpeciality]
END
go

ALTER TABLE MushlamSubSpecialityToSefer 
DROP COLUMN id
go

ALTER TABLE MushlamSubSpecialityToSefer 
ADD ID INT IDENTITY(1,1)
go

ALTER TABLE MushlamSubSpecialityToSefer 
ADD CONSTRAINT PK_SubSpeciality PRIMARY KEY (ID)
go

-- ********************************************************************************************************* 

--**** Yaniv - Start adding displayDescription to table languages *********
if not exists(SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'languages' AND COLUMN_NAME = 'displayDescription')
begin
	alter table languages
	add displayDescription nvarchar(50) NULL
end
--**** Yaniv - End adding displayDescription to table languages *********
go

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MushlamBrochures]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[MushlamBrochures](
		[BrochureID] [int] NOT NULL,
		[DisplayName] [varchar](80) NULL,
		[FileName] [varchar](30) NULL,
		[languageCode] [int] NOT NULL
	) ON [PRIMARY]
end
GO

--**** Yaniv - Start adding languageCode to MushlamBrochures ***********
IF NOt EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MushlamBrochures]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[MushlamBrochures](
		[BrochureID] [int] NOT NULL,
		[DisplayName] [varchar](80) NULL,
		[FileName] [varchar](30) NULL,
		[languageCode] [int] NOT NULL
	) ON [PRIMARY]
END
GO


ALTER TABLE [dbo].[MushlamBrochures] ADD  DEFAULT ((18)) FOR [languageCode]
GO

--**** Yaniv - End adding languageCode to MushlamBrochures ***********


--**** Yaniv - Start droping column officeService *****************************
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'officeServices' AND TABLE_NAME = 'Services')
	ALTER TABLE [Services]
	DROP COLUMN officeServices
go
--**** Yaniv - End droping column officeService *****************************

--------------------------------------------------------------------------------
-- *** Fix schema - by Maria


IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_EmployeeServiceQueueOrderMethod_x_Dept_Employee_Service]') AND parent_object_id = OBJECT_ID(N'[dbo].[EmployeeServiceQueueOrderMethod]'))
ALTER TABLE [dbo].[EmployeeServiceQueueOrderMethod] DROP CONSTRAINT [FK_EmployeeServiceQueueOrderMethod_x_Dept_Employee_Service]
GO

ALTER TABLE [dbo].[EmployeeServiceQueueOrderMethod]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeServiceQueueOrderMethod_x_Dept_Employee_Service] FOREIGN KEY([x_dept_employee_serviceID])
REFERENCES [dbo].[x_Dept_Employee_Service] ([x_Dept_Employee_ServiceID])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[EmployeeServiceQueueOrderMethod] CHECK CONSTRAINT [FK_EmployeeServiceQueueOrderMethod_x_Dept_Employee_Service]
GO





--------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_x_Dept_District_Dept]') AND parent_object_id = OBJECT_ID(N'[dbo].[x_Dept_District]'))
ALTER TABLE [dbo].[x_Dept_District] DROP CONSTRAINT [FK_x_Dept_District_Dept]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_x_Dept_District_Dept1]') AND parent_object_id = OBJECT_ID(N'[dbo].[x_Dept_District]'))
ALTER TABLE [dbo].[x_Dept_District] DROP CONSTRAINT [FK_x_Dept_District_Dept1]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_x_Dept_District_mainDistrict]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[x_Dept_District] DROP CONSTRAINT [DF_x_Dept_District_mainDistrict]
END

GO

/****** Object:  Table [dbo].[x_Dept_District]    Script Date: 03/28/2012 18:13:58 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[x_Dept_District]') AND type in (N'U'))
DROP TABLE [dbo].[x_Dept_District]
GO

CREATE TABLE [dbo].[x_Dept_District](
	[x_Dept_DistrictID] [int] IDENTITY(1,1) NOT NULL,
	[deptCode] [int] NOT NULL,
	[districtCode] [int] NOT NULL,
	[mainDistrict] [bit] NOT NULL
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[x_Dept_District]  WITH CHECK ADD  CONSTRAINT [FK_x_Dept_District_Dept] FOREIGN KEY([deptCode])
REFERENCES [dbo].[Dept] ([deptCode])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[x_Dept_District] CHECK CONSTRAINT [FK_x_Dept_District_Dept]
GO

ALTER TABLE [dbo].[x_Dept_District]  WITH CHECK ADD  CONSTRAINT [FK_x_Dept_District_Dept1] FOREIGN KEY([districtCode])
REFERENCES [dbo].[Dept] ([deptCode])
GO

ALTER TABLE [dbo].[x_Dept_District] CHECK CONSTRAINT [FK_x_Dept_District_Dept1]
GO

ALTER TABLE [dbo].[x_Dept_District] ADD  CONSTRAINT [DF_x_Dept_District_mainDistrict]  DEFAULT ((0)) FOR [mainDistrict]
GO

ALTER TABLE x_Dept_Employee_Service
ADD CONSTRAINT UQ_DeptEmployeeID_Service UNIQUE (DeptEmployeeID,serviceCode)
GO

--*****************************************************************************************************************************
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'IsCommunity' AND TABLE_NAME = 'DIC_ReceptionHoursTypes')
	ALTER TABLE DIC_ReceptionHoursTypes
	ADD IsCommunity [bit]
go

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'IsMushlam' AND TABLE_NAME = 'DIC_ReceptionHoursTypes')
	ALTER TABLE DIC_ReceptionHoursTypes
	ADD IsMushlam [bit]
go
	
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'IsHospital' AND TABLE_NAME = 'DIC_ReceptionHoursTypes')
	ALTER TABLE DIC_ReceptionHoursTypes
	ADD IsHospital [bit]
go
-------------------------------------------------------

BEGIN TRANSACTION
GO
ALTER TABLE dbo.TR_DoctorsInfo226 ADD
	Degree varchar(10) NULL
GO
ALTER TABLE dbo.TR_DoctorsInfo226 SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
