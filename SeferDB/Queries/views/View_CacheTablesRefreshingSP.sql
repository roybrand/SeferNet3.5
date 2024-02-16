IF EXISTS (SELECT * FROM sysobjects WHERE type = 'V' AND name = 'View_CacheTablesRefreshingSP')
	BEGIN
		DROP  view  View_CacheTablesRefreshingSP
	END

GO

CREATE VIEW [dbo].[View_CacheTablesRefreshingSP]
AS
SELECT    ctr.CacheTablesRefreshingSPCode, c.TableCode, c.TableName, ctr.SPName
FROM        dbo.CacheTablesRefreshingSP  AS ctr  inner  JOIN
                    dbo.CachedTables   AS c ON c.TableCode = ctr.TableCode
GO

grant select on View_CacheTablesRefreshingSP to public 

go
  