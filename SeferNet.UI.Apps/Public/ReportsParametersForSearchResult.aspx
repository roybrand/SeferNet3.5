<%@ Page Language="C#" AutoEventWireup="true"
    MasterPageFile="~/SeferMasterPageIEWide.master" Inherits="Reports_ReportsParametersForSearchResult"
    Title="פרמטרים לדוחות" Codebehind="ReportsParametersForSearchResult.aspx.cs" %>

<%@ Reference Page="~/Admin/AdminBasePage.aspx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ MasterType VirtualPath="~/SeferMasterPageIEWide.master" %>
<%@ Register Src="~/UserControls/SearchModeSelector.ascx" TagName="ModeSelector"
    TagPrefix="uc1" %>
<asp:Content ID="Content1" ContentPlaceHolderID="pageContent" runat="server">
 
    <script type="text/javascript" language="javascript">

        function FeaturesForModalDialogPopupWithParams(width, height) {
            var topi = 50;
            var lefti = 100;
            var features = "top:" + topi + "px;left:" + lefti + "px; dialogWidth:" + width + "px; dialogheight:" + height + "px; help:no; status:no;";
            return features;
        }

        function RefreshMembership() {

            if (typeof (MarkCelectedCheckboxes) == 'function') {
                MarkCelectedCheckboxes();
            }
        }

        function lstSelectedFields_doubleClick() {
            document.getElementById('<%= btnRemoveFields.ClientID.ToString()%>').click();
        }

        function lstReportFields_doubleClick() {
            document.getElementById('<%=btnAddSelectedFields.ClientID.ToString()%>').click();
        }

        function CreateExcel() {
            var url = "../Public/ReportsSearchResult_CreateExcel.aspx";
            window.open(url, "CreateExcel", "height=800, width=1000, top=50, left=100");

            JQueryDialogClose();
            return false;
        }

    </script>
    <asp:UpdatePanel ID="upReportParams" UpdateMode="Always" runat="server">
        <ContentTemplate>
            <table cellpadding="0" cellspacing="0" id="tblOuter" width="100%" border="0" style="height: 500px"
                dir="rtl">
                <tr>
                    <td style="padding-right: 13px">
                        <asp:Label ID="Label2" runat="server" EnableTheming="false" CssClass="RegularUpdateButton"
                            Text="דוח תוצאות חיפוש - שדות להצגה"></asp:Label>
                    </td>
                </tr>

                <tr style='height: 400px;'>
                    <%-------------Fields List------------------------------------------------------------%>
                    <td id="FieldsList" valign="top" style="padding-right: 3px">
                        <table width="60px">
                            <tr>
                                <td colspan="3">
                                    <table>
                                        <tr id="trFieldsList">
                                            <td>
                                                <table cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7">
                                                    <tr id="trBorderTop">
                                                        <td style="height: 8px; background-image: url('../Images/Applic/RTcornerGrey10.gif');
                                                            background-repeat: no-repeat; background-position: top right">
                                                        </td>
                                                        <td style="background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x;
                                                            background-position: top">
                                                        </td>
                                                        <td style="background-image: url('../Images/Applic/LTcornerGrey10.gif'); background-repeat: no-repeat;
                                                            background-position: top left">
                                                        </td>
                                                    </tr>
                                                    <tr id="trFieldsList_">
                                                        <td id="trBorderLeft" style="border-right: solid 2px #909090;">
                                                            <div style="width: 6px;">
                                                            </div>
                                                        </td>
                                                        <td id="tdFieldsList_">
                                                            <div id="divRepFields" style="height: 405px" runat="server">
                                                                <%--width: 360px;--%>
                                                                <table>
                                                                    <tr>
                                                                        <td id="tdAllFields">
                                                                            <%-- style="width: 100px"--%>
                                                                            <table border="0px">
                                                                                <tr>
                                                                                    <td>
                                                                                        <asp:Label ID="lblReportFields" runat="server" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                                                            Text="בחר שדות לדוח:"></asp:Label>
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td>
                                                                                        <asp:ListBox ID="lstReportFields" runat="server" Rows="7" SelectionMode="Multiple"
                                                                                            Width="150px" Height="400px"></asp:ListBox>
                                                                                    </td>
                                                                                </tr>
                                                                            </table>
                                                                        </td>
                                                                        <td id="tdButtons">
                                                                            <%--style="width: 15px"--%>
                                                                            <table cellpadding="0" cellspacing="0" frame="void" border="0">
                                                                                <tr>
                                                                                    <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                                        background-position: bottom left;">
                                                                                    </td>
                                                                                    <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                                        background-repeat: repeat-x; background-position: bottom;">
                                                                                        <asp:Button ID="btnAddAll" Width="75px" runat="server" CssClass="RegularUpdateButton"
                                                                                            Text="בחר הכל >>" CausesValidation="False" OnClick="btnAddAll_Click" ToolTip="בחר הכל" />
                                                                                    </td>
                                                                                    <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                                                        background-repeat: no-repeat;">
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                                        background-position: bottom left;">
                                                                                    </td>
                                                                                    <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                                        background-repeat: repeat-x; background-position: bottom;" align="left">
                                                                                        <asp:Button ID="btnAddSelectedFields" Width="55px" runat="server" CssClass="RegularUpdateButton"
                                                                                            Text="בחר    >" CausesValidation="False" OnClick="btnAddFields_Click" ToolTip="בחר שדות מסומנים " />
                                                                                    </td>
                                                                                    <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                                                        background-repeat: no-repeat;">
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                                        background-position: bottom left;">
                                                                                    </td>
                                                                                    <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                                        background-repeat: repeat-x; background-position: bottom;">
                                                                                        <asp:Button ID="btnRemoveAll" Width="75px" runat="server" CssClass="RegularUpdateButton"
                                                                                            Text="<< הסר הכל" CausesValidation="False" OnClick="btnRemoveAll_Click" ToolTip="הסר הכל" />
                                                                                    </td>
                                                                                    <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                                                        background-repeat: no-repeat;">
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                                        background-position: bottom left;">
                                                                                    </td>
                                                                                    <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                                        background-repeat: repeat-x; background-position: bottom;" align="right">
                                                                                        <asp:Button ID="btnRemoveFields" Width="55px" runat="server" CssClass="RegularUpdateButton"
                                                                                            Text="<  הסר  " CausesValidation="False" OnClick="btnRemoveFields_Click" ToolTip="הסר שדות מסומנים" />
                                                                                    </td>
                                                                                    <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                                                        background-repeat: no-repeat;">
                                                                                    </td>
                                                                                </tr>
                                                                            </table>
                                                                        </td>
                                                                        <td id="tdSelectedFields">
                                                                            <%--style="width: 100px"--%>
                                                                            <table>
                                                                                <tr>
                                                                                    <td>
                                                                                        <asp:Label ID="lblSelectedFields" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                                                            runat="server" Text="שדות לדוח:"></asp:Label>
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td>
                                                                                        <asp:ListBox ID="lstSelectedFields" runat="server" Rows="7" SelectionMode="Multiple"
                                                                                            Width="150px" Height="400px"></asp:ListBox>
                                                                                        <asp:TextBox ID="txtDummyTextBoxToValidate" runat="server" CssClass="DisplayNone" EnableTheming="false">It's just to have RequiredFieldValidator on page</asp:TextBox>
                                                                                        <asp:RequiredFieldValidator ID="vldReqDummyValue" runat="server" ControlToValidate="txtDummyTextBoxToValidate" Display="Dynamic" ErrorMessage="*" />
                                                                                    </td>
                                                                                </tr>
                                                                            </table>
                                                                        </td>
                                                                        <td align="right">
                                                                            <table cellpadding="0" cellspacing="0" style="display: none">
                                                                                <tr>
                                                                                    <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                                        background-position: bottom left;">
                                                                                        &nbsp;
                                                                                    </td>
                                                                                    <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                                        background-repeat: repeat-x; background-position: bottom;">
                                                                                        <asp:Button ID="btnUp" Width="15px" runat="server" CssClass="RegularUpdateButtonWebdings"
                                                                                            EnableTheming="false" Text="5" CausesValidation="False" /><%--OnClick="btnUp_Click"--%>
                                                                                    </td>
                                                                                    <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                                                        background-repeat: no-repeat;">
                                                                                        &nbsp;
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td colspan="3">
                                                                                        <br />
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                                        background-position: bottom left;">
                                                                                    </td>
                                                                                    <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                                        background-repeat: repeat-x; background-position: bottom;">
                                                                                        <asp:Button ID="btnDown" Width="15px" runat="server" CssClass="RegularUpdateButtonWebdings"
                                                                                            EnableTheming="false" Text="6" CausesValidation="False" /><%--OnClick="btnDown_Click" --%>
                                                                                    </td>
                                                                                    <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                                                        background-repeat: no-repeat;">
                                                                                    </td>
                                                                                </tr>
                                                                            </table>
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </div>
                                                        </td>
                                                        <td id="trBorderRigth" style="border-left: solid 2px #909090;">
                                                            <div style="width: 6px;">
                                                            </div>
                                                        </td>
                                                    </tr>
                                                    <tr id="trBorderBottom" style="height: 10px">
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
                                    </table>
                                    <!------------------------------------------------------------->
                                </td>
                            </tr>
                            <tr align="left">
                                <td align="left" style="visibility:hidden">
                                    <table id="tablExecuteReport" cellpadding="0" cellspacing="0" align="left">
                                        <tr align="left">
                                            <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                background-position: bottom left;">
                                            </td>
                                            <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                background-repeat: repeat-x; background-position: bottom;">
                                                <asp:Button ID="btnGetReport" runat="server" CssClass="RegularUpdateButton" Text="הפק דוח"
                                                    CausesValidation="true" PostBackUrl="~/Reports/RS_ReportResult.aspx" />
                                            </td>
                                            <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                background-repeat: no-repeat;">
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td align="left">
                                    <table cellpadding="0" cellspacing="0" align="left">
                                        <tr align="left">
                                            <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                background-position: bottom left;">
                                            </td>
                                            <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                background-repeat: repeat-x; background-position: bottom;">
                                                <asp:Button ID="btnExcel" Width="60px" CssClass="RegularUpdateButton" runat="server" Text="הפק דוח"
                                                    CausesValidation="False" OnClick="btnExcel_Click"
                                                    OnClientClick="showProgressBarGeneral('');"/>                                            
                                            </td>
                                            <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                background-repeat: no-repeat;">
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td align="left" style="padding-left:10px;width:80px">
                                    <table id="tablResetParams" cellpadding="0" cellspacing="0" align="left">
                                        <tr>
                                            <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                background-position: bottom left;">
                                            </td>
                                            <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                background-repeat: repeat-x; background-position: bottom;">
                                                <asp:Button ID="btnResetParams" Width="40px" runat="server" CssClass="RegularUpdateButton" Text="ניקוי"
                                                    CausesValidation="true" OnClick="btnResetParams_Click" />
                                            </td>
                                            <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                background-repeat: no-repeat;">
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </ContentTemplate>
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="btnDown" EventName="click" />
            <asp:AsyncPostBackTrigger ControlID="btnUp" EventName="click" />
            <asp:AsyncPostBackTrigger ControlID="btnRemoveAll" EventName="click" />
            <asp:AsyncPostBackTrigger ControlID="btnAddAll" EventName="click" />
            <asp:AsyncPostBackTrigger ControlID="btnRemoveFields" EventName="click" />
            <asp:AsyncPostBackTrigger ControlID="btnAddSelectedFields" EventName="click" />
        </Triggers>
    </asp:UpdatePanel>
    <script type="text/javascript">
        function JQueryDialogClose() {
            window.parent.$("#dialog-modal-select").dialog('close');
            return false;
        }
    </script>
</asp:Content>
