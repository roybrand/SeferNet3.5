IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_Insert_InterfaceToSimulErrors_from_InterfaceToSimulErrorsIntermediate')
	BEGIN
		DROP  Procedure  rpc_Insert_InterfaceToSimulErrors_from_InterfaceToSimulErrorsIntermediate
	END

GO

CREATE Procedure dbo.rpc_Insert_InterfaceToSimulErrors_from_InterfaceToSimulErrorsIntermediate

AS

INSERT INTO InterfaceToSimulErrors
(key_dept,
ErrorCode,
dept_name,
city,
street,
house,
entrance,
flat,
DoarNa,
Zip,
preprefix1,
prefix1,
nphone1,
preprefix2,
prefix2,
nphone2,
faxpreprefix,
faxprefix,
nfax,
ManagerName,
Email,
InterfaceDate)

SELECT 
deptCode,
ErrorCode,
deptName,
city,
street,
CASE WHEN ISNUMERIC(house) = 1 THEN house ELSE 0 END,
entrance,
flat,
DoarNa,
CASE WHEN ISNUMERIC(Zip) = 1 THEN Zip ELSE 0 END,
CASE WHEN ISNUMERIC(preprefix1) = 1 THEN preprefix1 ELSE 0 END,
CASE WHEN ISNUMERIC(prefix1) = 1 THEN prefix1 ELSE 0 END,
CASE WHEN ISNUMERIC(nphone1) = 1 THEN nphone1 ELSE 0 END,
CASE WHEN ISNUMERIC(preprefix2) = 1 THEN preprefix2 ELSE 0 END,
CASE WHEN ISNUMERIC(prefix2) = 1 THEN prefix2 ELSE 0 END,
CASE WHEN ISNUMERIC(nphone2) = 1 THEN nphone2 ELSE 0 END,
CASE WHEN ISNUMERIC(faxpreprefix) = 1 THEN faxpreprefix ELSE 0 END,
CASE WHEN ISNUMERIC(faxprefix) = 1 THEN faxprefix ELSE 0 END,
CASE WHEN ISNUMERIC(nfax) = 1 THEN nfax ELSE 0 END,
ManagerName,
Email,
GETDATE()

FROM InterfaceToSimulErrorsIntermediate

GO


GRANT EXEC ON rpc_Insert_InterfaceToSimulErrors_from_InterfaceToSimulErrorsIntermediate TO PUBLIC

GO


