 SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fun_GetServiceInDeptQueueOrders]
(
	@ServiceCode int,
	@DeptCode int
)
RETURNS varchar(500)
AS
BEGIN


 
    DECLARE @p_str VARCHAR(500)
    SET @p_str = ''

	SELECT @p_str = @p_str + CASE sqom.QueueOrderMethod WHEN 1 THEN dbo.ParsePhoneNumber(deptPhones.prePrefix,deptPhones.prefix,deptPhones.phone) 
				WHEN 2 THEN '#' + dbo.ParsePhoneNumber(queuePhones.prePrefix , queuePhones.prefix, queuePhones.phone) + '#' 
				WHEN 3 THEN '*2700'
				WHEN 4 THEN '1' END + ','
	FROM x_dept_service ds
	LEFT JOIN ServiceQueueOrderMethod sqom ON ds.ServiceCode = sqom.ServiceCode AND ds.DeptCode = sqom.DeptCode
	LEFT JOIN DeptPhones ON sqom.deptCode = deptPhones.DeptCode AND PhoneType = 1 AND PhoneOrder = 1 AND QueueOrderMethod = 1
	LEFT JOIN DeptServiceQueueOrderPhones queuePhones ON sqom.QueueOrderMethodID = queuePhones.QueueOrderMethodID
	LEFT JOIN DIC_QueueOrderMethod dic ON sqom.QueueOrderMethod = dic.QueueOrderMethod
	WHERE ds.deptCode = @DeptCode
	AND ds.ServiceCode = @ServiceCode
	
	IF len(@p_str) > 1
	-- remove last comma
	BEGIN
		SET @p_str = SUBSTRING(@p_str, 0, len(@p_str))
	END

    RETURN @p_str

END
GO

  