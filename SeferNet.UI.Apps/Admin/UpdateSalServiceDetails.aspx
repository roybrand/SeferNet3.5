<%@ Reference Page="~/Admin/AdminBasePage.aspx" %>
<%@ Page Language="C#" Title="עדכון פרטי שירות לאינטרנט" MasterPageFile="~/seferMasterPage.master"
    Culture="he-il" UICulture="he-il" AutoEventWireup="true"
    Inherits="UpdateSalServiceDetails" Codebehind="UpdateSalServiceDetails.aspx.cs" %>

<%@ Register Assembly="System.Web.Extensions, Version=1.0.61025.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
    Namespace="System.Web.UI" TagPrefix="asp" %>
<%@ MasterType VirtualPath="~/seferMasterPage.master" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<%@ Register Src="../UserControls/PhonesGridUC.ascx" TagName="PhonesGridUC" TagPrefix="UCphones" %>


<asp:Content ID="Content1" ContentPlaceHolderID="pageContent" runat="server">

    <script type="text/javascript" src="../Scripts/BrowserVersions.js"></script>

    <script type="text/javascript">
        
    </script>

    <asp:Label ID="lblGeneralError" runat="server" SkinID="lblError" ></asp:Label>

    <table id="tblMain" cellspacing="0" cellpadding="0">
        <tr>
            <td style="padding-right: 10px">
                <table cellpadding="0" cellspacing="0" style="background-color: #298AE5; height: 30px;"
                    width="100%">
                    <tr>
                        <td style="width: 100px; padding-right: 15px">
                            <asp:Label ID="lblDeptNameCaption" EnableTheming="false" CssClass="LabelBoldWhite_18"
                                runat="server" Text="שם השירות:"></asp:Label>
                        </td>
                        <td style="width: 700px; padding: 0px 0px 0px 0px;">
                            <table cellpadding="0" cellspacing="0">
                                <tr>
                                    <td>
                                        <asp:Label ID="lblSalServiceName" EnableTheming="false" CssClass="LabelBoldWhite_18" runat="server" Text=""></asp:Label>
                                    </td>
                                    <td style="padding: 0px 0px 0px 0px;">
                                        <table id="tblOpenDeptNameLB" runat="server" cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                    background-position: bottom left;">
                                                    &nbsp;
                                                </td>
                                                <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                    background-repeat: repeat-x; background-position: bottom;">
                                                    <asp:Button ID="btnOpenDeptNameLB" Width="135px" runat="server" Text="עדכון שם ורמת שירות"
                                                        CssClass="RegularUpdateButton" CausesValidation="false" OnClientClick="return OpenDeptNamesDialog()">
                                                    </asp:Button>
                                                </td>
                                                <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                    background-repeat: no-repeat;">
                                                    &nbsp;
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td align="left" style="padding-left: 5px">
                            <table cellpadding="0" cellspacing="0">
                                <tr>
                                    <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;background-position: bottom left;">
                                        &nbsp;
                                    </td>
                                    <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                        background-repeat: repeat-x; background-position: bottom;">
                                        <asp:Button ID="btnUpdate" runat="server" Width="45px" Text="שמירה" CssClass="RegularUpdateButton"
                                           CausesValidation="true" OnClick="btnUpdate_Click" ValidationGroup="vgrFirstSectionValidation" ></asp:Button>
                                    </td>
                                    <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                        background-repeat: no-repeat;">
                                        &nbsp;
                                    </td>
                                    <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                        background-position: bottom left;">
                                        &nbsp;
                                    </td>
                                    <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                        background-repeat: repeat-x; background-position: bottom;">
                                        <asp:Button ID="btnBackToOpener" runat="server" CssClass="RegularUpdateButton" Text="ביטול"
                                            CausesValidation="False" />
                                    </td>
                                    <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                        background-repeat: no-repeat;">
                                        &nbsp;
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ValidationSummary ID="ValidationSummary1" runat="server" ValidationGroup="vgrFirstSectionValidation" />
            </td>
        </tr>
        <tr>
            <td style="padding-right: 10px">
                <table cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7">
                    <tr>
                        <td style="height: 10px; background-image: url('../Images/Applic/RTcornerGrey10.gif');
                            background-repeat: no-repeat; background-position: top right">
                        </td>
                        <td style="background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x;
                            background-position: top">
                        </td>
                        <td style="background-image: url('../Images/Applic/LTcornerGrey10.gif'); background-repeat: no-repeat;
                            background-position: top left">
                        </td>
                    </tr>
                    <tr>
                        <td style="border-right: solid 2px #909090;">
                            <div style="width: 6px;">
                            </div>
                        </td>
                        <td>
                            <!-- Sal Service Details -->
                            <table id="tblSalServiceDetails" cellspacing="0" cellpadding="0" style="width: 950px;" border="0">
                                <tr>
                                    <td style="width:110px;">
                                        <asp:Label ID="lblServiceName" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="תיאור:"></asp:Label>
                                    </td>
                                    <td style="width:250px;">
                                        <asp:TextBox ID="txtServiceName" runat="server" Width="200px"></asp:TextBox>
                                    </td>
                                    <td style="width:110px;">
                                        <asp:Label ID="lblEngName" EnableTheming="false" CssClass="LabelBoldDirtyBlue" runat="server" Text="תיאור באנגלית:"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtEngName" runat="server" Width="200px"></asp:TextBox>
                                    </td>
                                 </tr>
                                 <tr>
                                    <td>
                                        <asp:Label ID="lblHealthOfficeCode" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text='קוד משה"ב:'></asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtHealthOfficeCode" runat="server" Width="200px"></asp:TextBox>
                                    </td>
                                    <td>
                                        <asp:Label ID="lblCommon" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="שכיח"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:DropDownList ID="ddlCommon" runat="server" Width="103px"></asp:DropDownList>
                                    </td>
                                 </tr>
                                 <tr>
                                    <td>
                                        <asp:Label ID="lblLimiter" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text='הערות הגבלה:'></asp:Label>
                                    </td>
                                    <td>
                                        <asp:DropDownList ID="ddlLimiter" runat="server" Width="103px"></asp:DropDownList>
                                    </td>
                                    <td>
                                        <asp:Label ID="lblIncludeInBasket" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="כלול בסל:"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:DropDownList ID="ddlIncludeInBasket" runat="server" Width="103px"></asp:DropDownList>
                                    </td>
                                 </tr>
                                 <tr>
                                    <td>
                                        <asp:Label ID="lblFormType" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text='סוג טופס:'></asp:Label>
                                    </td>
                                    <td>
                                        <asp:DropDownList ID="ddlFormType" runat="server" Width="103px"></asp:DropDownList>
                                    </td>
                                    <td></td>
                                    <td></td>
                                 </tr>
                            </table>
                        </td>
                        <td style="border-left: solid 2px #909090;">
                            <div style="width: 6px;">
                            </div>
                        </td>
                    </tr>
                    <tr style="height: 10px">
                        <td style="background-image: url('../Images/Applic/RBcornerGrey10.gif'); background-repeat: no-repeat;
                            background-position: bottom right">
                        </td>
                        <td style="background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x;
                            background-position: bottom">
                        </td>
                        <td style="background-image: url('../Images/Applic/LBcornerGrey10.gif'); background-repeat: no-repeat;
                            background-position: bottom left">
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td style="padding-right: 10px">
                <table cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7">
                    <tr>
                        <td style="height: 10px; background-image: url('../Images/Applic/RTcornerGrey10.gif');
                            background-repeat: no-repeat; background-position: top right">
                        </td>
                        <td style="background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x;
                            background-position: top">
                        </td>
                        <td style="background-image: url('../Images/Applic/LTcornerGrey10.gif'); background-repeat: no-repeat;
                            background-position: top left">
                        </td>
                    </tr>
                    <tr>
                        <td style="border-right: solid 2px #909090;">
                            <div style="width: 6px;">
                            </div>
                        </td>
                        <td>
                            <!-- tblAdministration -->
                            <table id="tblAdministration" cellspacing="0" cellpadding="0" style="width: 950px;"
                                border="0">
                                <tr>
                                    <td style="width:110px;"><asp:Label ID="lblSynonym1" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text='שם נרדף 1:'></asp:Label></td>
                                    <td style="width:250px;"><asp:TextBox ID="txtSynonym1" runat="server" Width="200px"></asp:TextBox></td>
                                    <td style="width:110px;"><asp:Label ID="lblSynonym2" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text='שם נרדף 2:'></asp:Label></td>
                                    <td><asp:TextBox ID="txtSynonym2" runat="server" Width="200px"></asp:TextBox></td>
                                 </tr>
                                 <tr>
                                    <td><asp:Label ID="lblSynonym3" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text='שם נרדף 3:'></asp:Label></td>
                                    <td><asp:TextBox ID="txtSynonym3" runat="server" Width="200px"></asp:TextBox></td>
                                    <td><asp:Label ID="lblSynonym4" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text='שם נרדף 4:'></asp:Label></td>
                                    <td><asp:TextBox ID="txtSynonym4" runat="server" Width="200px"></asp:TextBox></td>
                                 </tr>
                                 <tr>
                                    <td><asp:Label ID="lblSynonym5" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text='שם נרדף 5:'></asp:Label></td>
                                    <td><asp:TextBox ID="txtsynonym5" runat="server" Width="200px"></asp:TextBox></td>
                                    <td></td>
                                    <td></td>
                                 </tr>
                                 <tr>
                                    <td><asp:Label ID="lblBudgetDesc" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="סיווג תקציבי"></asp:Label></td>
                                    <td><asp:DropDownList runat="server" ID="ddlBudgetDesc" Width="103px"></asp:DropDownList></td>
                                    <td><asp:Label ID="lblEshkolDesc" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="אשכול:"></asp:Label></td>
                                    <td><asp:DropDownList runat="server" ID="ddlEshkolDesc" Width="103px"></asp:DropDownList></td>
                                 </tr>
                                 <tr>
                                    <td><asp:Label ID="lblPaymentRules" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="כללי חיוב:"></asp:Label></td>
                                    <td><asp:DropDownList runat="server" ID="ddlPaymentRules" Width="103px"></asp:DropDownList></td>
                                    <td></td>
                                    <td></td>
                                 </tr>
                            </table>
                        </td>
                        <td style="border-left: solid 2px #909090;">
                            <div style="width: 6px;">
                            </div>
                        </td>
                    </tr>
                    <tr style="height: 10px">
                        <td style="background-image: url('../Images/Applic/RBcornerGrey10.gif'); background-repeat: no-repeat;
                            background-position: bottom right">
                        </td>
                        <td style="background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x;
                            background-position: bottom">
                        </td>
                        <td style="background-image: url('../Images/Applic/LBcornerGrey10.gif'); background-repeat: no-repeat;
                            background-position: bottom left">
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td style="padding-right: 10px">
                <table cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7">
                    <tr>
                        <td style="height: 10px; background-image: url('../Images/Applic/RTcornerGrey10.gif');
                            background-repeat: no-repeat; background-position: top right">
                        </td>
                        <td style="background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x;
                            background-position: top">
                        </td>
                        <td style="background-image: url('../Images/Applic/LTcornerGrey10.gif'); background-repeat: no-repeat;
                            background-position: top left">
                        </td>
                    </tr>
                    <tr>
                        <td style="border-right: solid 2px #909090;">
                            <div style="width: 6px;">
                            </div>
                        </td>
                        <td>
                            <!-- Internet Details -->
                            <table id="tblInternetDetails" cellspacing="0" cellpadding="0" style="width: 950px;" border="0">
                                <tr>
                                    <td style="width:110px;"><asp:Label ID="lblServiceNameForInternet" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                            runat="server" Text="שם שירות (לאינטרנט)"></asp:Label></td>
                                    <td style="width:250px;"><asp:TextBox ID="txtServiceNameForInternet" runat="server" EnableTheming="false" CssClass="SimpleTextGrey" Width="200px"></asp:TextBox></td>
                                    <td style="width:110px;"><asp:Label ID="lblServiceDetailsForInternet" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                            runat="server" Text="פירוט השירות (לאינטרנט)"></asp:Label></td>
                                    <td><asp:TextBox ID="txtServiceDetailsForInternet" runat="server" EnableTheming="false" CssClass="SimpleTextGrey" Width="200px"></asp:TextBox></td>
                                 </tr>
                                 <tr>
                                    <td><asp:Label ID="lblServiceBriefForInternet" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                            runat="server" Text="תקציר השירות"></asp:Label></td>
                                    <td><asp:TextBox ID="txtServiceBriefForInternet" runat="server" EnableTheming="false" Width="200px"></asp:TextBox></td>
                                    <td><asp:Label ID="lblQueueOrderForInternet" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                            runat="server" Text="זימון תור"></asp:Label></td>
                                    <td><asp:DropDownList ID="ddlQueueOrderForInternet" runat="server" EnableTheming="false" Width="103px"></asp:DropDownList></td>
                                 </tr>
                                 <tr>
                                    <td><asp:Label ID="lblShowServiceInInternet" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                            runat="server" Text="הצגה באינטרנט"></asp:Label></td>
                                    <td><asp:DropDownList ID="ddlShowServiceInInternet" runat="server" EnableTheming="false" Width="103px"></asp:DropDownList></td>
                                    <td></td>
                                    <td></td>
                                 </tr>
                            </table>
                        </td>
                        <td style="border-left: solid 2px #909090;">
                            <div style="width: 6px;">
                            </div>
                        </td>
                    </tr>
                    <tr style="height: 10px">
                        <td style="background-image: url('../Images/Applic/RBcornerGrey10.gif'); background-repeat: no-repeat;
                            background-position: bottom right">
                        </td>
                        <td style="background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x;
                            background-position: bottom">
                        </td>
                        <td style="background-image: url('../Images/Applic/LBcornerGrey10.gif'); background-repeat: no-repeat;
                            background-position: bottom left">
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td style="padding-right: 10px">
                <table cellpadding="0" cellspacing="0" style="background-color: #298AE5; height: 30px;"
                    width="100%">
                    <tr>
                        <td style="width: 560px">
                            <asp:CheckBox ID="cbMakeRedirectAfterPostBack" runat="server" CssClass="DisplayNone" />
                        </td>
                        <td align="left" style="padding-left: 5px">
                            <table cellpadding="0" cellspacing="0">
                                <tr>
                                    <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                        background-position: bottom left;">
                                        &nbsp;
                                    </td>
                                    <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                        background-repeat: repeat-x; background-position: bottom;">
                                        <asp:Button ID="btnUpdate_Bottom" runat="server" Text="שמירה" CssClass="RegularUpdateButton"
                                            OnClick="btnUpdate_Click"  CausesValidation="true" ValidationGroup="vgrFirstSectionValidation"></asp:Button>
                                    </td>
                                    <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                        background-repeat: no-repeat;">
                                        &nbsp;
                                    </td>
                                    <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                        background-position: bottom left;">
                                        &nbsp;
                                    </td>
                                    <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                        background-repeat: repeat-x; background-position: bottom;">
                                        <asp:Button ID="btnBackToOpener_Bottom" runat="server" CssClass="RegularUpdateButton"
                                            Text="ביטול" CausesValidation="False" />
                                    </td>
                                    <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                        background-repeat: no-repeat;">
                                        &nbsp;
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>               
            </td>
        </tr>
    </table>
</asp:Content>
