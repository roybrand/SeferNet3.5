ALTER TABLE x_dept_employee
ADD ApptUrl varchar(300)
GO
-- New part 16/10/2019

ALTER TABLE EmployeeInClinic_preselected
ADD	[ID] [int] IDENTITY(1,1) NOT NULL
GO

CREATE INDEX index_ID
ON EmployeeInClinic_preselected (ID)
GO
