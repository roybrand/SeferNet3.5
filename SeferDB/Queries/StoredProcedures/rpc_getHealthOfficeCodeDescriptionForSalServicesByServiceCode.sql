IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getHealthOfficeCodeDescriptionForSalServicesByServiceCode')
	BEGIN
		DROP  Procedure  rpc_getHealthOfficeCodeDescriptionForSalServicesByServiceCode
	END
GO

Create Proc dbo.rpc_getHealthOfficeCodeDescriptionForSalServicesByServiceCode
@GoVCode VarChar(50)
As

Select GoVCode As Code , [Description]
From MF_HealthGov478
Where GoVCode = @GoVCode AND DELFL = 0

Go

GRANT EXEC ON rpc_getHealthOfficeCodeDescriptionForSalServicesByServiceCode TO PUBLIC
GO
