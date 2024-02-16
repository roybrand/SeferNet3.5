IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getEmployeeSectors')
	BEGIN
		DROP  Procedure  rpc_getEmployeeSectors
	END

GO

CREATE Procedure rpc_getEmployeeSectors
(
	@IsDoctor int
)

AS

IF(@IsDoctor = -1)
	BEGIN
		SET @IsDoctor = null
	END

SELECT
EmployeeSectorCode,
EmployeeSectorDescription,
RelevantForProfession,
IsDoctor

FROM EmployeeSector
WHERE ((@IsDoctor is null)
OR (@IsDoctor is not null AND @IsDoctor = IsDoctor))
AND EmployeeSectorCode <> 3 /* 'לא רופא' */
ORDER BY OrderToShow

GO

GRANT EXEC ON rpc_getEmployeeSectors TO PUBLIC

GO
 