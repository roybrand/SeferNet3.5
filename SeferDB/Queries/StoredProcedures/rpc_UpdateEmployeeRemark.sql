IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_UpdateEmployeeRemark')
	BEGIN
		DROP  Procedure  rpc_UpdateEmployeeRemark
	END

GO

CREATE procedure [dbo].[rpc_UpdateEmployeeRemark](@RemarkID int, 
										  @RemarkText varchar(max), 
										  @ValidFrom varchar(10),
										  @ValidTo varchar(10),
										  @InternetDisplay tinyint, 
										  @UpdateUser varchar(50)) 
as 

declare @From  smalldatetime 
declare @To smalldatetime 


set @From = dbo.rfn_ConvertDate(@ValidFrom)  

if len(@ValidTo) > 0 
begin 
	set @To  = dbo.rfn_ConvertDate(@ValidTo)
end 
else 
begin 
	set @To  = null 
end 
 


Update EmployeeRemarks  
set RemarkText = @RemarkText, 
ValidFrom = @From, 
ValidTo = @To, 
displayInInternet = @InternetDisplay, 
updateDate = getdate() , 
updateUser = @UpdateUser
where EmployeeRemarkID = @RemarkID  


GO


GRANT EXEC ON rpc_UpdateEmployeeRemark TO PUBLIC

GO


