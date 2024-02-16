IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'rpc_GetSalServiceHistoryDetails')
	BEGIN
		DROP  Procedure  rpc_GetSalServiceHistoryDetails
	END
GO

CREATE PROCEDURE [dbo].[rpc_GetSalServiceHistoryDetails] 
@ServiceCode Int , @UpdateDate DateTime
As

-- Table 0: History details of the service.
Select      HS.ServiceCode , HC.ServiceDescription As ServiceName , HC.ServiceDescriptionEnglish As EngName , 
            HS.BasketApproveDate , HS.IsCanceled , HS.CanceledDate , HS.UpdateDate , 
            HC.IncludeInBasket , HC.GuidancesType , HC.Limiter , HC.Common , HC.InsideService , 
            HC.FormCode , HC.LimitationComment , HC.GovernmentServiceCodeType , HC.GovernmentServiceCode  , 
            HC.InternalGovernmentServiceCode , OFT.ObligationFormDesc As FormType
            ,HC.UpdateDate
From MF_HistoryServices148 HS
left Join MF_HistoryConditions148 HC On HS.ServiceCode = HC.ServiceCode 
									And HS.BasketApproveDate = HC.UpdateDate
left Join MF_ObligationFormType312 OFT On HC.FormCode = OFT.ObligationFormCode
Where HS.ServiceCode = @ServiceCode And HS.BasketApproveDate = @UpdateDate
and HS.GuidancesType = 9
order by hs.BasketApproveDate desc


-- Table 1: Guidances Management Instructions
Select * 
From MF_HistoryGuidances148
Where ServiceCode = @ServiceCode And UpdateDate = @UpdateDate
order by Entrance, LineNum, TableBreak

-- Table 2: Select service's "Medical Instructions"
Select [Description]
From MF_HistoryFinance148
Where GuidancesType = 2 And ServiceCode = @ServiceCode And UpdateDate = @UpdateDate

-- Table 3: Select service's "General Management Instructions"
Select [Description]
From MF_HistoryFinance148
Where GuidancesType = 1 And ServiceCode = @ServiceCode And UpdateDate = @UpdateDate

Go

GRANT EXEC ON rpc_GetSalServiceHistoryDetails TO PUBLIC

GO