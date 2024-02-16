IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_getDicQueueOrderMethods')
	BEGIN
		DROP  Procedure  rpc_getDicQueueOrderMethods
	END

GO

CREATE Procedure dbo.rpc_getDicQueueOrderMethods

AS

SELECT *
FROM DIC_QueueOrder
ORDER BY PermitOrderMethods


SELECT *
FROM DIC_QueueOrderMethod
ORDER BY SpecialPhoneNumberRequired, QueueOrderMethodDescription


GO


GRANT EXEC ON rpc_getDicQueueOrderMethods TO PUBLIC

GO


