IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_DeleteProfessionsParentChild')
	BEGIN
		DROP  Procedure  rpc_DeleteProfessionsParentChild
	END

GO

/****** Object:  StoredProcedure [dbo].[rpc_DeleteProfessionsParentChild]    Script Date: 11/08/2009 16:49:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[rpc_DeleteProfessionsParentChild]

	(
		@childCode int		
	)


AS

	delete professionsParentChild
	where childCode=@childCode


GO


GRANT EXEC ON rpc_DeleteProfessionsParentChild TO PUBLIC



