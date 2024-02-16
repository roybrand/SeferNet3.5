IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[View_DeptEmployeeReceptionCount]'))
DROP VIEW [dbo].[View_DeptEmployeeReceptionCount]
GO

create VIEW [dbo].[View_DeptEmployeeReceptionCount]
AS
select COUNT(*) as ReceptionCount, deptEmployeeReception.DeptEmployeeID, deptEmployeeReceptionServices.serviceCode
		FROM deptEmployeeReception
		INNER JOIN deptEmployeeReceptionServices 
			ON deptEmployeeReception.receptionID = deptEmployeeReceptionServices.receptionID
		where disableBecauseOfOverlapping <> 1
		and (GETDATE() between ISNULL(validFrom,'1900-01-01') and ISNULL(validTo,'2079-01-01'))
group by deptEmployeeReception.DeptEmployeeID, deptEmployeeReceptionServices.serviceCode

go


GRANT SELECT ON [dbo].[View_DeptEmployeeReceptionCount] TO [public] AS [dbo]
GO
