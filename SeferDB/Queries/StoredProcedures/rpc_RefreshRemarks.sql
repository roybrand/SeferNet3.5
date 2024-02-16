IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_RefreshRemarks')
	BEGIN
		DROP  Procedure  rpc_RefreshRemarks
	END
GO

CREATE Procedure dbo.rpc_RefreshRemarks
(
	@DICremarkID int
)

AS

DECLARE @RemarkText varchar(1000)

SET @RemarkText = (SELECT remark FROM DIC_GeneralRemarks WHERE remarkID = @DICremarkID)
	
UPDATE DeptRemarks
SET DeptRemarks.RemarkText = @RemarkText
WHERE DeptRemarks.DicRemarkID = @DICremarkID
AND (DeptRemarks.validTo IS NULL OR DeptRemarks.validTo >= getdate())

UPDATE DeptReceptionRemarks
SET DeptReceptionRemarks.RemarkText = @RemarkText
WHERE DeptReceptionRemarks.RemarkID = @DICremarkID
AND (DeptReceptionRemarks.validTo IS NULL OR DeptReceptionRemarks.validTo >= getdate())


UPDATE DeptEmployeeReceptionRemarks
SET DeptEmployeeReceptionRemarks.RemarkText = @RemarkText
where DeptEmployeeReceptionRemarks.RemarkID = @DICremarkID
AND (DeptEmployeeReceptionRemarks.validTo IS NULL OR DeptEmployeeReceptionRemarks.validTo >= getdate())

UPDATE DeptEmployeeServiceRemarks
SET DeptEmployeeServiceRemarks.RemarkText = @RemarkText
where DeptEmployeeServiceRemarks.RemarkID = @DICremarkID
AND (DeptEmployeeServiceRemarks.validTo IS NULL OR DeptEmployeeServiceRemarks.validTo >= getdate())


UPDATE EmployeeRemarks
SET EmployeeRemarks.RemarkText = @RemarkText
where EmployeeRemarks.DicRemarkID = @DICremarkID
AND (EmployeeRemarks.validTo IS NULL OR EmployeeRemarks.validTo >= getdate())
		 

GO

GRANT EXEC ON dbo.rpc_RefreshRemarks TO [clalit\webuser]
GO

GRANT EXEC ON dbo.rpc_RefreshRemarks TO [clalit\IntranetDev]
GO
