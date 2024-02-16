IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetSalBodyOrgans')
	BEGIN
		DROP  Procedure  rpc_GetSalBodyOrgans
	END

GO

CREATE Procedure [dbo].[rpc_GetSalBodyOrgans]
As

Select * 
From SalBodyOrgans
Order By OrganName

GO

GRANT EXEC ON rpc_GetSalBodyOrgans TO PUBLIC

GO