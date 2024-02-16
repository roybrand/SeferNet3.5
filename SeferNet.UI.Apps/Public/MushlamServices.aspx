<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="Public_MushlamServices" Codebehind="MushlamServices.aspx.cs" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link rel="STYLESHEET" href="../CSS/General/general.css" type="text/css" />
</head>
<body>
    <script type="text/javascript" src="../Scripts/srcScripts/jquery.js"></script>
    <script language="javascript" type="text/javascript">

        function DisplaySelectedTab(tabSelected, tabNotSelected, panel) {

            $('#tabsContainer').find("[id$='NotSelected']").css('display', 'inline');
            $('#tabsContainer').find("[id$='IsSelected']").hide();

            $('#tabsContainer').find("[id$='" + tabSelected + "']").css('display', 'inline');
            $('#tabsContainer').find("[id$='" + tabNotSelected + "']").hide();

            $('#tabsContainer').find("[id^='pnl']").hide();
            $('#tabsContainer').find("[id$='" + panel + "']").show();


        }
    </script>

    <form id="form1" runat="server">
    <div style="direction: rtl; width: 990px; height: 400px;background-color:#F8F8F8">
        <div class="BackColorBlue" style="height: 29px;">
            <div style="float: right; margin-top: 5px; margin-right: 3px;">
                <asp:Image ID="imgAttribution" runat="server" ToolTip="שירותי בריאות כללית" />
            </div>
            <div style="float: right; margin-right: 10px; margin-top: 3px;">
                <asp:Label ID="lblDeptName" EnableTheming="false" CssClass="LabelBoldWhite_18" runat="server"
                    Text=""></asp:Label>
            </div>
            <div style="float: right; margin-right: 10px; margin-top: 3px;">
                <asp:Label ID="lblServiceName" EnableTheming="false" CssClass="LabelBoldWhite_18" runat="server"
                    Text=""></asp:Label>
            </div>
        </div>
        <table cellpadding="0" cellspacing="0">
            <tr>
                <td style="padding-bottom: 0px; padding-left: 0px; width: 980px; padding-right: 0px;
                    padding-top: 0px">
                    <table id="tblNoRrecordsFound" runat="server" style="display:none" cellspacing="0" cellpadding="0" border="0">
                        <tr>
                            <td style="padding-right: 30px; height: 50px" valign="middle" align="right">
                                <asp:Label runat="server" ID="lblICD9Title" CssClass="LabelCaptionBlue_14" Style="font-size: 16px;">לא נמצאו שירות מושלם מקושרים</asp:Label>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
        <table id="tblResult" runat="server" width="100%" cellpadding="0" cellspacing="0" style="margin-top:10px">
            <tr>
                <td colspan="2" align="right" class="ColumnHeader" style="padding-right: 15px">
                    <asp:Label ID="Label5" runat="server" EnableTheming="false">שם שירות</asp:Label>
                </td>
            </tr>
            <tr>
                <td valign="top" style="width: 260px;">
                    <asp:TextBox ID="txtScrollTop" runat="server" CssClass="DisplayNone" EnableTheming="false"></asp:TextBox>
                    <div id="divMushlamServices" style="width: 245px; height: 322px; direction: ltr;
                        overflow-y: auto;">
                        <div style="direction: rtl; height: 100%; vertical-align: top">
                            <asp:Repeater ID="rptSearchResults" runat="server">
                                <ItemTemplate>
                                    <div id="divServiceRow" runat="server" class="mushlamServiceResultsRow">
                                        <asp:LinkButton ID="btnServiceName" runat="server" CssClass="LinkButtonBoldForPaging"
                                            OnClick="lnkMushlamService_clicked" Text='<%# Eval("ServiceName") %>' CommandArgument='<%# Eval("ServiceCode") + "_" + Eval("GroupCode") + "_" + Eval("SubGroupCode") %>'
                                            Width="180px" />
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </div>
                </td>
                <td valign="top" style="padding-top: 1px;">
                    <div id="tabsContainer" style="width: 100%; background-color: #E7F0F7; height: 340px;
                        text-align: right;">
                        <div style="height: 20px; margin-bottom: 8px; padding-bottom: 1px; width: 690px;
                            margin-right: 18px; margin-top: 5px" dir="rtl">
                            <div id="tabInnerServicesIsSelected" runat="server" style="float: right; width: 45px;">
                                <div class="divRightTabSelected height22">
                                </div>
                                <div class="divCenterTabSelected height22">
                                    <asp:Label ID="Label6" runat="server" EnableTheming="false" Text="כללי" CssClass="LabelBoldBlack_14"></asp:Label>
                                </div>
                                <div class="divLeftTabSelected height22">
                                </div>
                            </div>
                            <div id="tabInnerServicesNotSelected" runat="server" class="tabNotSelected" style="width: 50px;
                                float: right; display: none">
                                <div class="divRightTabNotSelected">
                                </div>
                                <div class="divCenterTabNotSelected">
                                    <asp:Button ID="Button1" Width="30px" runat="server" Text="כללי" CssClass="TabButton_13" OnClientClick="DisplaySelectedTab('tabInnerServicesIsSelected', 'tabInnerServicesNotSelected', 'pnlMushlamServiceDescription');return false;" />
                                </div>
                                <div class="divLeftTabNotSelected">
                                </div>
                            </div>
                            <div id="tabInnerAgreementMethodIsSelected" runat="server" style="float: right; width: 89px;
                                display: none">
                                <div class="divRightTabSelected height22">
                                </div>
                                <div class="divCenterTabSelected height22">
                                    <asp:Label ID="Label2" runat="server" EnableTheming="false" Text="מסלול הסדר" CssClass="LabelBoldBlack_14"></asp:Label>
                                </div>
                                <div class="divLeftTabSelected height22">
                                </div>
                            </div>
                            <div id="tabInnerAgreementMethodNotSelected" runat="server" class="tabNotSelected"
                                style="width: 109px; float: right">
                                <div class="divRightTabNotSelected">
                                </div>
                                <div class="divCenterTabNotSelected">
                                    <asp:Button ID="Button2" runat="server" Text="מסלול הסדר" CssClass="TabButton_13"
                                        OnClientClick="DisplaySelectedTab('tabInnerAgreementMethodIsSelected', 'tabInnerAgreementMethodNotSelected', 'pnlMushlamAgreement');return false;" />
                                </div>
                                <div class="divLeftTabNotSelected">
                                </div>
                            </div>
                            <div id="tabInnerRefundMethodIsSelected" runat="server" style="float: right; width: 87px;
                                display: none">
                                <div class="divRightTabSelected height22">
                                </div>
                                <div class="divCenterTabSelected height22">
                                    <asp:Label ID="Label8" runat="server" EnableTheming="false" Text="מסלול החזר" CssClass="LabelBoldBlack_14"></asp:Label>
                                </div>
                                <div class="divLeftTabSelected height22">
                                </div>
                            </div>
                            <div id="tabInnerRefundMethodNotSelected" runat="server" class="tabNotSelected" style="width: 107px;
                                float: right">
                                <div class="divRightTabNotSelected">
                                </div>
                                <div class="divCenterTabNotSelected">
                                    <asp:Button ID="Button3" runat="server" Text="מסלול החזר" CssClass="TabButton_13"
                                        OnClientClick="DisplaySelectedTab('tabInnerRefundMethodIsSelected', 'tabInnerRefundMethodNotSelected', 'pnlMushlamRefund');return false;" />
                                </div>
                                <div class="divLeftTabNotSelected">
                                </div>
                            </div>
                            <div id="tabInnerSalServicesIsSelected" runat="server" style="float: right; width: 120px;
                                display: none">
                                <div class="divRightTabSelected height22">
                                </div>
                                <div class="divCenterTabSelected height22">
                                    <asp:Label ID="Label9" runat="server" EnableTheming="false" Text="שירותי סל קשורים"
                                        CssClass="LabelBoldBlack_14"></asp:Label>
                                </div>
                                <div class="divLeftTabSelected height22">
                                </div>
                            </div>
                            <!-- tabInnerSalServicesNotSelected renamed to tabInnerSalServicesNeverSelected not to be shown 29.04.2015 VG-->
                            <div id="tabInnerSalServicesNeverSelected" runat="server" class="tabNotSelected" style="width: 157px;
                                float: right; display: none">
                                <div class="divRightTabNotSelected">
                                </div>
                                <div class="divCenterTabNotSelected">
                                    <asp:Button ID="Button4" runat="server" Text="שירותי סל קשורים" CssClass="TabButton_13"
                                        OnClientClick="DisplaySelectedTab('tabInnerSalServicesIsSelected', 'tabInnerSalServicesNotSelected', 'pnlMushlamSalServices');return false;" />
                                </div>
                                <div class="divLeftTabNotSelected">
                                </div>
                            </div>
                            <div id="tabInnerServiceModelsIsSelected" runat="server" style="display: none">
                                <div class="divRightTabSelected height22">
                                </div>
                                <div class="divCenterTabSelected height22">
                                    <asp:Label ID="Label3" runat="server" EnableTheming="false" Text="רשימת דגמים לשירות"
                                        CssClass="LabelBoldBlack_14"></asp:Label>
                                </div>
                                <div class="divLeftTabSelected height22">
                                </div>
                            </div>
                            <div id="tabInnerServiceModelsNotSelected" runat="server" class="tabNotSelected"
                                style="float: right; width: 190px">
                                <div class="divRightTabNotSelected">
                                </div>
                                <div class="divCenterTabNotSelected">
                                    <asp:Button ID="btnShowModelsForService" runat="server" Text="רשימת דגמים לשירות"
                                        CssClass="TabButton_13" OnClientClick="DisplaySelectedTab('tabInnerServiceModelsIsSelected', 'tabInnerServiceModelsNotSelected', 'pnlMushlamServiceModels');return false;" />
                                </div>
                                <div class="divLeftTabNotSelected">
                                </div>
                            </div>
                            <div style="background-color: #BDD7F1; margin-top: 0px; width: 100%; height: 1px">
                            </div>
                        </div>
                        <div id="pnlMushlamServiceDescription">
                            <table cellpadding="0" cellspacing="0">
                                <tr>
                                    <td valign="top">
                                        <div class="divMushlamContainer" style="padding-top: 8px;">
                                            <div class="divMushlamTopRightCornerWithoutColor">
                                            </div>
                                            <div class="divMushlamTopCenterWithoutColor">
                                            </div>
                                            <div class="divMushlamTopLeftCornerWithoutColor">
                                            </div>
                                            <div class="divMushlamInnerContainerExtended">
                                                <div class="divMushlamMiddleRight">
                                                </div>
                                                <div class="divMushlamMiddleContent">
                                                    <div style="direction: rtl">
                                                        <asp:Label ID="lblGeneralRemark" EnableTheming="false" CssClass="LabelBlack_14" runat="server"></asp:Label>
                                                    </div>
                                                </div>
                                                <div class="divMushlamMiddleLeft">
                                                </div>
                                            </div>
                                            <div class="divMushlamBottomRight">
                                            </div>
                                            <div class="divMushlamBottomCenter">
                                            </div>
                                            <div class="divMushlamBottomLeft">
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td valign="top" style="display:none">
                                        <div class="divMushlamContainer">
                                            <div class="divMushlamTopRightCorner">
                                            </div>
                                            <div class="divMushlamTopCenter LabelBoldBlack_13" style="line-height: 23px">
                                                הערות לנציג</div>
                                            <div class="divMushlamTopLeftCorner">
                                            </div>
                                            <div style="clear:both"></div>
                                            <div class="divMushlamInnerContainer">
                                                <div class="divMushlamMiddleRight">
                                                </div>
                                                <div class="divMushlamMiddleContent">
                                                    <div style="direction: rtl; padding-right: 2px;">
                                                        <asp:Label ID="lblRepRemark" runat="server" EnableTheming="false" CssClass="LabelBlack_14"></asp:Label>
                                                    </div>
                                                </div>
                                                <div class="divMushlamMiddleLeft">
                                                </div>
                                            </div>
                                            <div class="divMushlamBottomRight">
                                            </div>
                                            <div class="divMushlamBottomCenter">
                                            </div>
                                            <div class="divMushlamBottomLeft">
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </div>
                        <div id="pnlMushlamAgreement" style="display: none; padding: 10px; padding-right: 15px;">
                            
                            <div style="direction: ltr; overflow-y: auto; width: 675px;">
                                <div class="divMushlamTopRightCornerWithoutColor">
                                </div>
                                <div class="divMushlamTopCenterWithoutColor">
                                </div>
                                <div class="divMushlamTopLeftCornerWithoutColor">
                                </div>
                                <div class="divMushlamInnerContainerExtended">
                                    <div class="divMushlamMiddleRight">
                                    </div>
                                    <div class="divMushlamMiddleContentExtended">
                                        <div style="direction: rtl;">
                                            <asp:Label ID="lblAgreementDetails" runat="server" EnableTheming="false" CssClass="LabelBlack_14"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="divMushlamMiddleLeft">
                                    </div>
                                </div>
                                <div class="divMushlamBottomRight">
                                </div>
                                <div class="divMushlamBottomCenter">
                                </div>
                                <div class="divMushlamBottomLeft">
                                </div>
                            </div>                            
                        </div>
                        <div id="pnlMushlamRefund" style="display: none; padding: 10px; padding-right: 15px">
                            <div style="direction: ltr; overflow-y: auto; width: 675px;">
                                <div class="divMushlamTopRightCornerWithoutColor">
                                </div>
                                <div class="divMushlamTopCenterWithoutColor">
                                </div>
                                <div class="divMushlamTopLeftCornerWithoutColor">
                                </div>
                                <div class="divMushlamInnerContainerExtended">
                                    <div class="divMushlamMiddleRight">
                                    </div>
                                    <div class="divMushlamMiddleContentExtended">
                                        <asp:Label ID="lblRefund" runat="server" EnableTheming="false" CssClass="LabelBlack_14"></asp:Label>
                                    </div>
                                    <div class="divMushlamMiddleLeft">
                                    </div>
                                </div>
                                <div class="divMushlamBottomRight">
                                </div>
                                <div class="divMushlamBottomCenter">
                                </div>
                                <div class="divMushlamBottomLeft">
                                </div>
                            </div>
                        </div>
                        <div id="pnlMushlamSalServices" style="display: none; padding-right: 5px; padding-top: 10px">
                            <div class="divMushlamContainer" style="direction: ltr; overflow-y: auto; height: 290px;
                                margin-right: 10px; width: 675px;">
                                <asp:Repeater ID="rptLinkedServices" runat="server">
                                    <HeaderTemplate>
                                        <div style="display: inline">
                                            <div class="divMushlamTopRightCorner">
                                            </div>
                                            <div class="divMushlamTopCenter LabelBoldBlack_13" style="width: 645px; float: right;
                                                padding-right: 10px;">
                                                <span class="marginTop3" style="width: 155px; float: right;">קוד שירות</span>
                                                <div style="background-color: #DBDBDA; width: 2px; float: right">
                                                    &nbsp;&nbsp;</div>
                                                <span class="marginTop3" style="margin-right: 15px; width: 150px; float: right">שם שירות</span>
                                            </div>
                                            <div class="divMushlamTopLeftCorner">
                                            </div>
                                        </div>
                                        <div class="divMushlamInnerContainer" style="height: 220px">
                                            <div class="divMushlamMiddleRight">
                                            </div>
                                            <div class="divMushlamMiddleContent" style="height: 220px; width: 659px">
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <div style="height: 25px; border-bottom: 1px solid #E8F0F5; vertical-align: middle;
                                            display: block">
                                            <div style="float: right; width: 152px">
                                                <asp:Label ID="Label4" runat="server" Width="152px" EnableTheming="false" CssClass="linkedServicesDesc SimpleText"><%# Eval("ServiceCode") %></asp:Label>
                                            </div>
                                            <div style="border-right: 1px solid #E8F0F5; padding-right: 15px; line-height: 24px;
                                                vertical-align: middle; right: 180px; width: 380px">
                                                <a target="_blank" href="http://mkweb104.clalit.org.il/intranet/newlook/ServicesBasket/ConfirmLogin.asp?eligable=true&zakaut=true&KodService= <%# Eval("ServiceCode") %>"
                                                    class="mushlamServicesText">
                                                    <%# Eval("ServiceName") %></a>
                                            </div>
                                        </div>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        </div>
                                        <div class="divMushlamMiddleLeft">
                                        </div>
                                        </div>
                                        <div class="divMushlamBottomRight">
                                        </div>
                                        <div class="divMushlamBottomCenter" style="width: 655px">
                                        </div>
                                        <div class="divMushlamBottomLeft">
                                        </div>
                                    </FooterTemplate>
                                </asp:Repeater>
                            </div>
                        </div>
                        <div id="pnlMushlamServiceModels" style="display: none; margin-right: 10px; padding-top: 10px;">
                            <div class="divMushlamContainer" style="direction: ltr; overflow-y: auto; height: 300px;
                                margin-right: 5px; width: 675px">
                                <asp:Repeater ID="rptModels" runat="server">
                                    <HeaderTemplate>
                                        <div class="divMushlamTopRightCorner">
                                        </div>
                                        <div class="divMushlamTopCenter LabelBoldBlack_13" style="float: right; direction: rtl">
                                            <table cellpadding="0" cellspacing="0" style="height: 100%">
                                                <tr>
                                                    <td style="padding-top: 2px; width: 239px; padding-right: 15px">
                                                        <span style="margin-right: 15px">שם</span>
                                                    </td>
                                                    <td style="border-right: 1px double #DBDBDA; padding-right: 3px; padding-left: 2px;
                                                        width: 102px;">
                                                        <span class="marginTop3">השתתפות עצמית</span>
                                                    </td>
                                                    <td style="border-right: 1px double #DBDBDA; padding-right: 10px; width: 191px;">
                                                        <span class="marginTop3">הערה</span>
                                                    </td>
                                                    <td style="border-right: 1px double #DBDBDA; padding-right: 2px">
                                                        <span class="marginTop3">תקופת אכשרה</span>
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                        <div class="divMushlamTopLeftCorner">
                                        </div>
                                        <div class="divMushlamInnerContainer" style="height: 220px">
                                            <div class="divMushlamMiddleRight">
                                                &nbsp;</div>
                                            <div class="divMushlamMiddleContent" style="height: 220px;">
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <div class="mushlamServicesText" style="border-bottom: 1px solid #E8F0F5; height: 25px;
                                            direction: rtl; display: block">
                                            <div style="float: right; width: 240px;">
                                                <span style="line-height: 20px">
                                                    <%# Eval("ModelDescription") %></span>
                                            </div>
                                            <div class="borderRightOnTable" style="float: right; width: 95px; padding-right: 10px">
                                                <span style="width: 20px; line-height: 25px">
                                                    <%# UIHelper.ReturnOnlyIfPositive(Convert.ToInt32(Eval("ParticipationAmount")), "שקלים")  %>&nbsp;</span>
                                            </div>
                                            <div class="borderRightOnTable" style="float: right; width: 200px; line-height: 25px;
                                                padding-right: 3px;">
                                                <span>
                                                    <%# Eval("Remark") %>&nbsp;</span>
                                            </div>
                                            <div class="borderRightOnTable" style="float: right; padding-right: 10px; line-height: 25px;">
                                                <span style="width: 20px">
                                                    <%# UIHelper.ReturnOnlyIfPositive(Convert.ToInt32(Eval("WaitingPeriod")), "חודשים")%>
                                                    &nbsp;</span>
                                            </div>
                                        </div>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        </div>
                                        <div class="divMushlamMiddleLeft">
                                            &nbsp;
                                        </div>
                                        </div>
                                        <div class="divMushlamBottomRight">
                                        </div>
                                        <div class="divMushlamBottomCenter">
                                        </div>
                                        <div class="divMushlamBottomLeft">
                                        </div>
                                    </FooterTemplate>
                                </asp:Repeater>
                            </div>
                        </div>
                    </div>
                </td>
            </tr>
        </table>
    </div>
    </form>
</body>
</html>
