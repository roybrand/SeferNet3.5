<%@ Reference Page="AdminBasePage.aspx" %>

<%@ Page Language="C#" AutoEventWireup="true" Title="הוספה/עדכון תחומי שירות ראשי" MasterPageFile="~/seferMasterPageIE.master" Inherits="UpdateServiceCategories" EnableEventValidation="false" Codebehind="UpdateServiceCategories.aspx.cs" %>

<%@ MasterType VirtualPath="~/seferMasterPageIE.master" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="pageContent" runat="server">

 
    <script type="text/javascript">
    
         function DeptSelected(source, eventArgs) {

            var values = eventArgs.get_value();
            if (values == null) return;
            document.getElementById('<%= hdnDeptCode.ClientID %>').value = values;

        }

        function selectRowOnLoad(rowPrefix, rowInd) {
            rowInd = rowInd + 2;
            if (rowInd < 10)
                rowInd = "0" + rowInd;
            var newIndex = parseInt(rowInd, 10) + 5;
            if (newIndex < 10) {
                newIndex = "0" + newIndex;
            }
            else {
                newIndex = newIndex + "";
            }
            var newClientIdPrefix = rowPrefix.replace(rowInd, newIndex);

            var row = document.getElementById(newClientIdPrefix + "_btnUpdateUser");
            if (row == null)
                row = document.getElementById(rowPrefix + "_btnUpdateUser");
            //ctl00_pageContent_gvUsers_ctl02_btnUpdateUser
            if (row != null)
                row.focus();
        }

        //--- new concept: unated service = profession + service
        function SelectUnitedServices() {
            var txtAttributedServicesCodes = document.getElementById('<%=txtAttributedServicesCodes.ClientID %>');
            var txtAttributedServices = document.getElementById('<%=txtAttributedServices.ClientID %>');
            var SelectedProfessionList = txtAttributedServicesCodes.innerText;

            var url = "../Public/SelectPopUp.aspx";
            url += "?SelectedValuesList=" + SelectedProfessionList;
            url += "&popupType=15"; 
            url += "&returnValuesTo=txtAttributedServicesCodes";
            url += "&returnTextTo=txtAttributedServices";

            var dialogWidth = 420;
            var dialogHeight = 650;
            var title = "בחר תחומים מקושרים";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return false;
        }

        function SelectMF_Specialities051() {
            var txtAttributedServicesCodes = document.getElementById('<%=txtMF_Specialities051Codes.ClientID %>');
            var txtAttributedServices = document.getElementById('<%=txtMF_Specialities051Description.ClientID %>');
            var SelectedList = txtAttributedServicesCodes.innerText;

            var url = "../Public/SelectPopUp.aspx";
            url = url + "?SelectedValuesList=" + SelectedList;
            url = url + "&popupType=16";
            url = url + "&IsSingleSelectMode=true";  
            url += "&returnValuesTo=txtMF_Specialities051Codes";
            url += "&returnTextTo=txtMF_Specialities051Description";

            var dialogWidth = 420;
            var dialogHeight = 650;
            var title = "בחר תחום אב";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return false;
        }

    </script>

    <table cellpadding="0" cellspacing="0">
        <tr>
            <td style="padding-right: 8px">
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
                        <td align="right">
                            <div style="width: 960px">
                                <table cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td valign="top" align="right" style="padding-right: 10px; padding-left: 5px;" valign="middle">
                                            <asp:Label ID="lblParentServiceCategory" runat="server" Text="תחום אב"></asp:Label>
                                        </td>
                                        <td>
                                            <asp:TextBox ID="txtMF_Specialities051Description" CssClass="TextBoxMultiLine" TextMode="MultiLine" ReadOnly="true" runat="server" Width="200px"></asp:TextBox>
                                        </td>
                                        <td valign="top" style="padding-top:2px">
                                            <img id="btnParentServiceCategory" runat="server" src="../Images/applic/icon_magnify.gif" onclick="return SelectMF_Specialities051();" style="cursor: hand;" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td align="right" style="padding-right: 10px; padding-left: 5px;">
                                            <asp:Label ID="lblServiceCategoryCode" runat="server" Text="קוד"></asp:Label>
                                        </td>
                                        <td>
                                            <asp:TextBox ID="txtServiceCategoryCode" ReadOnly="true" runat="server" Width="200px"></asp:TextBox>
                                        </td>
                                        <td></td>
                                    </tr>
                                    <tr>
                                        <td align="right" style="padding-right: 10px; padding-left: 5px;">
                                            <asp:Label ID="lblServiceCategoryDescription" runat="server" Text="תיאור"></asp:Label>
                                        </td>
                                        <td>
                                            <asp:TextBox ID="txtServiceCategoryDescription" runat="server" Width="200px"></asp:TextBox>
                                        </td>
                                        <td>
                                            <asp:RequiredFieldValidator ControlToValidate="txtServiceCategoryDescription" ValidationGroup="vgrSave" ID="vldTxtServiceCategoryDescription" runat="server" Text="*"></asp:RequiredFieldValidator>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td valign="top" align="right" style="padding-right: 10px; padding-left: 5px;">
                                            <asp:Label ID="lblAttributedServices" runat="server" Text="תחומים מקושרים"></asp:Label>
                                        </td>
                                        <td>
                                            <asp:TextBox ID="txtAttributedServices" CssClass="TextBoxMultiLine" TextMode="MultiLine" ReadOnly="true" runat="server" Width="200px"></asp:TextBox>
                                        </td>
                                        <td valign="top" style="padding-top:2px">
                                            <img id="btnAttributedServices" runat="server" src="../Images/applic/icon_magnify.gif" style="cursor: hand;" onclick="return SelectUnitedServices();" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="3" style="display:none">
                                            <asp:TextBox ID="txtAttributedServicesCodes" CssClass="TextBoxMultiLine" TextMode="MultiLine" runat="server" Width="200px"></asp:TextBox>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="3" style="display:none">
                                            <asp:TextBox ID="txtMF_Specialities051Codes" CssClass="TextBoxMultiLine" TextMode="MultiLine" runat="server" Width="200px"></asp:TextBox>
                                        </td>
                                    </tr>
                                </table>
                                <table cellpadding="0" cellspacing="0" width="100%">
                                    <tr>
                                        <td style="padding-right: 120px; ">
                                            <table cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                        background-position: bottom left;">
                                                        &nbsp;
                                                    </td>
                                                    <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                        background-repeat: repeat-x; background-position: bottom;">
                                                        <asp:Button ID="btnSave" runat="server" Text="שמירה" CssClass="RegularUpdateButton"
                                                            ValidationGroup="vgrSave" onclick="btnSave_Click"></asp:Button>
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
                                                        <asp:Button ID="btnCancel" runat="server" Text="ביטול" 
                                                            CssClass="RegularUpdateButton" Width="50px" ValidationGroup="grSearchParameters" onclick="btnCancel_Click"></asp:Button>
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
                            </div>
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
    </table>
    <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Conditional" runat="server" >
        <ContentTemplate>
            <asp:Button ID="btnDoPostBack" runat="server" CssClass="DisplayNone" />
            <asp:HiddenField ID="hdnDeptCode" runat="server" />
            <asp:HiddenField ID="hdnMinheletValue" runat="server" />
        </ContentTemplate>
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="btnSave" EventName="Click" />
        </Triggers>
        
    </asp:UpdatePanel>
    
</asp:Content>
