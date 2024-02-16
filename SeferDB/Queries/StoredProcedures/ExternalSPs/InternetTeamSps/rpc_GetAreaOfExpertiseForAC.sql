-- =============================================
--	Owner : Internet Team
-- =============================================
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetAreaOfExpertiseForAC')
	BEGIN
		DROP  Procedure  [rpc_GetAreaOfExpertiseForAC]
	END

GO

CREATE Procedure [dbo].[rpc_GetAreaOfExpertiseForAC]
(
	@Prefix varchar(50)
)
 
AS

SELECT [ServiceCode]
      ,[ServiceDescription]
  FROM [dbo].[Services]
  where IsProfession=1
  and ServiceDescription like @Prefix + '%'

GO

GRANT EXEC ON [rpc_GetAreaOfExpertiseForAC] TO PUBLIC

GO

