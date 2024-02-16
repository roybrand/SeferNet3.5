IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_InsertIncorrectDataReport')
	BEGIN
		DROP  Procedure  rpc_InsertIncorrectDataReport
	END

GO

CREATE Procedure dbo.rpc_InsertIncorrectDataReport
(
	@deptCode INT, 
	@employeeID BIGINT,
	@errorDesc VARCHAR(1000),
	@pageUrl VARCHAR(200),
	@mailToList VARCHAR(1000),
	@reportDate DATETIME,
	@ReportedBy VARCHAR(100)
)

AS

INSERT INTO ReportedIncorrectData
VALUES (@deptCode , @employeeID , @errorDesc , @pageUrl , @mailToList , @reportDate, @ReportedBy )

GO


GRANT EXEC ON rpc_InsertIncorrectDataReport TO PUBLIC

GO
