IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getServiceDescriptionForSalServicesByServiceCode')
	BEGIN
		DROP  Procedure  rpc_getServiceDescriptionForSalServicesByServiceCode
	END
GO

Create Proc dbo.rpc_getServiceDescriptionForSalServicesByServiceCode 
@ServiceCode Int
As

Select * 
From MF_SalServices386
Where ServiceCode = @ServiceCode

Go

GRANT EXEC ON rpc_getServiceDescriptionForSalServicesByServiceCode TO PUBLIC
GO