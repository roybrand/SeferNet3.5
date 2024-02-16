IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetReportDetails')
	BEGIN
		DROP  Procedure  rpc_GetReportDetails
	END

GO

CREATE Procedure dbo.rpc_GetReportDetails
(
	@reportID int
)


AS
	Select ID, reportName, reportTitle
	from dbo.DIC_Reports 
	Where ID = @reportID


GO


GRANT EXEC ON rpc_GetReportDetails TO PUBLIC

GO


