IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteServiceParentChild')
	BEGIN
		DROP  Procedure  rpc_DeleteServiceParentChild
	END

GO


/****** Object:  StoredProcedure [dbo].[rpc_DeleteServiceParentChild]    Script Date: 11/08/2009 16:50:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create Procedure [dbo].[rpc_DeleteServiceParentChild]

	(
		@childCode int		
	)


AS

	delete dbo.serviceParentChild
	where childCode=@childCode

GO


GRANT EXEC ON rpc_DeleteServiceParentChild TO PUBLIC

GO


