<%@ Page Title="עדכון תחום" Language="C#" MasterPageFile="~/SeferMasterPageIE.master"
    AutoEventWireup="true" Inherits="UpdateTables_UpdateSpecificService" Codebehind="UpdateSpecificService.aspx.cs" %>

<%@ Register Src="~/UserControls/MultiDDlSelect.ascx" TagName="multiSelect" TagPrefix="uc1" %>
<asp:Content ID="Content1" ContentPlaceHolderID="phHead" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="pageContent" runat="Server">
    <script type="text/javascript" language="javascript">
    function ClickOnPage(){
        //this.ClickOnPage2
    }

    function SelectProfession() {

        var hdnProfessionListCodes = document.getElementById('<%=hdnCategoriesListCodes.ClientID %>');
        var hdnProfessionList = document.getElementById('<%=hdnCategoriesList.ClientID %>');
        var txtParentCategories = document.getElementById('<%=txtParentCategories.ClientID %>');        
        var SelectedCategoriesList = hdnProfessionListCodes.value;

        var url = "../Public/SelectPopUp.aspx";
        url += "?SelectedValuesList=" + SelectedCategoriesList;
        url += "&popupType=17";
        url += "&ServiceCode=" + <%= m_serviceCode %>; 
        url += "&returnValuesTo=hdnCategoriesListCodes";
        url += "&returnTextTo=hdnCategoriesList,txtParentCategories";

        var dialogWidth = 430;
        var dialogHeight = 650;
        var title = "בחר תחום ראשי";

        OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

        return false;
        }


    function SelectOldService()
    {
        var url = "SelectServiceFromMFtables.aspx";

        var dialogWidth = 440;
        var dialogHeight = 650;
        var title = "MF - בחר תחום ב";

        OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

        return false;
    }

    function SetServiceCodeAndDescription(serviceCode, serviceDescription) {

        document.getElementById('<%= hdnServiceCode.ClientID %>').value = serviceCode;
        document.getElementById('<%= txtServiceCodeOld.ClientID %>').value = serviceCode;
        document.getElementById('<%= txtServiceDescOld.ClientID %>').value = serviceDescription;
        document.getElementById('<%= hdnServiceDesc.ClientID %>').value = serviceDescription;
        document.getElementById('<%= txtDesc.ClientID %>').value = serviceDescription;  
}

    function ToggleExpert(chk)
    {
        var pnlExpert = document.getElementById('<%= pnlExpert.ClientID %>');
        var txtServiceDesc = document.getElementById('<%= txtDesc.ClientID %>');
        var txtExpert = document.getElementById('<%= txtExpertDesc.ClientID %>');
        

        pnlExpert.disabled = !chk.checked;

        if (!pnlExpert.disabled)
        {
            txtExpert.value = txtServiceDesc.value;
        }
        else
        {
            txtExpert.value = '';
        }
    }

    function CheckValidAttribution(val, args)
    {
        communityChecked = document.getElementById('<%= chkIsCommunity.ClientID %>').checked;
        mushlamChecked = document.getElementById('<%= chkIsMushlam.ClientID %>').checked;
        hospitalChecked = document.getElementById('<%= chkIsHospital.ClientID %>').checked;

        if (!communityChecked && !mushlamChecked && !hospitalChecked)
        {
            args.IsValid = false;
        }
        else
        {
            args.IsValid = true;
        }
    }

    function CheckSectorToShowWith(val, args)
    {
        var ddlSectorToShow_selectedIndex = document.getElementById('<%= ddlSectorToShow.ClientID %>').selectedIndex;

        var txtItems = $('input[name*="txtItems"]');
        var sectors = txtItems[0].value.split(",");

        if (sectors.length > 1 && ddlSectorToShow_selectedIndex == 0)
        {
            args.IsValid = false;
        }
        else
        {
            args.IsValid = true;
        }

    }    
    </script>
<div style="width:980px; align-content:center; margin:auto; width: 50%;"> 
    <table cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7;
        margin: 10px">
        <tr>
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
        <tr>
            <td style="border-right: solid 2px #909090;">
                <div style="width: 6px;">
                </div>
            </td>
            <td>
                <table style="margin: 5px" cellspacing="4">
                    <tr>
                        <td colspan="2">
                            <asp:Panel ID="pnlAdd" runat="server" Visible="false" Width="400px" BorderColor="Red">
                                <table cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td style="width:80px">
                                            <asp:Label ID="Label1" runat="server" Text="תחום ב-MF" ></asp:Label>
                                            <asp:HiddenField ID="hdnServiceDesc" runat="server" />
                                            <asp:HiddenField ID="hdnServiceCode" runat="server" />
                                            <asp:CustomValidator ID="vldCode" runat="server"  ValidationGroup="mainValid"
                                            ErrorMessage="חובה לבחור קוד" Text="*" OnServerValidate="CheckInsertedCode" ></asp:CustomValidator>
                                            
                                        </td>
                                        <td>
                                            <asp:TextBox ID="txtServiceCodeOld" runat="server" ReadOnly="true" Width="30px"></asp:TextBox>
                                            <asp:TextBox ID="txtServiceDescOld" runat="server" ReadOnly="true" Width="162px"></asp:TextBox>
                                            <input type="image" id="imgSelectOldService" style="vertical-align: bottom; cursor: pointer;"
                                                src="../Images/Applic/icon_magnify.gif" onclick="SelectOldService();return false;" />
                                        </td>
                                    </tr>
                                </table>
                            </asp:Panel>
                        </td>
                    </tr>
                    <tr>
                        <td style="width: 90px">
                            <asp:Label ID="Label2" runat="server">תיאור חדש</asp:Label>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="txtDesc"
                                ErrorMessage="תיאור הוא שדה חובה" Text="*" ValidationGroup="mainValid"></asp:RequiredFieldValidator>
                        </td>
                        <td>
                            <asp:TextBox ID="txtDesc" runat="server" Width="200px"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label ID="Label3" runat="server">סוג תחום</asp:Label>
                        </td>
                        <td>
                            <asp:DropDownList ID="ddlServiceType" runat="server">
                                <asp:ListItem Value="profession">מקצוע</asp:ListItem>
                                <asp:ListItem Value="service">שירות</asp:ListItem>
                            </asp:DropDownList>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label ID="Label4" runat="server">סקטור</asp:Label>
                            <asp:CustomValidator runat="server" OnServerValidate="CheckSelectedSector" ErrorMessage="חובה לבחור סקטור למקצוע"
                                ValidationGroup="mainValid"></asp:CustomValidator>
                        </td>
                        <td>
                            <uc1:multiSelect ID="ddlSectors" runat="server" Width="199px" CssClass="multiDropDown" />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label ID="Label10" runat="server">סקטור לתצוגה</asp:Label>
                            <asp:CustomValidator ID="vldSectorToShowWith" runat="server" ValidationGroup="mainValid"
                                ClientValidationFunction="CheckSectorToShowWith" ErrorMessage="חובה לבחור סקטור לתצוגה אם נבחר יתר מסקטור אחד" Text="*"></asp:CustomValidator>

                        </td>
                        <td>
                            <asp:DropDownList ID="ddlSectorToShow" runat="server" AppendDataBoundItems="true">
                                 <asp:ListItem Value="-1" Text=""></asp:ListItem>                           
                            </asp:DropDownList>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label ID="Label5" runat="server">קהילה</asp:Label>
                        </td>
                        <td>
                            <asp:CheckBox ID="chkIsCommunity" runat="server" />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label ID="Label6" runat="server">מושלם</asp:Label>
                        </td>
                        <td>
                            <asp:CheckBox ID="chkIsMushlam" runat="server" />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label ID="Label7" runat="server">בתי חולים</asp:Label>
                            <asp:CustomValidator ID="vldAttribution" runat="server" ValidationGroup="mainValid"
                                ClientValidationFunction="CheckValidAttribution" ErrorMessage="חובה לבחור לפחות שיוך אחד"></asp:CustomValidator>
                        </td>
                        <td>
                            <asp:CheckBox ID="chkIsHospital" runat="server" />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label ID="Label8" runat="server">תחום ראשי</asp:Label>
                        </td>
                        <td>
                            <asp:TextBox ID="txtParentCategories" runat="server" Width="200px"></asp:TextBox>
                            <input type="image" id="btnProfessionListPopUp" style="vertical-align: bottom; cursor: pointer;"
                                src="../Images/Applic/icon_magnify.gif" onclick="SelectProfession();return false;" />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label ID="Label9" runat="server">מומחיות</asp:Label>
                        </td>
                        <td>
                            <asp:CheckBox ID="chkExpert" runat="server" onclick="ToggleExpert(this);" />
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <asp:Panel ID="pnlExpert" runat="server">
                                <asp:Label runat="server" Width="91px">מומחה ב-</asp:Label>
                                <asp:TextBox ID="txtExpertDesc" runat="server" Width="200px"></asp:TextBox>
                            </asp:Panel>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label ID="Label11" runat="server">לתצוגה באינטרנט</asp:Label>
                        </td>
                        <td>
                            <asp:CheckBox ID="cbDisplayInInternet" runat="server" />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label ID="Label12" runat="server">דורש זימון</asp:Label>
                        </td>
                        <td>
                            <asp:CheckBox ID="cbRequiresQueueOrder" runat="server" />
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <asp:ValidationSummary ID="vldSummary" runat="server" ValidationGroup="mainValid" />
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2" align="left" style="padding-top: 10px">
                            <table cellpadding="0" cellspacing="0" style="display: inline">
                                <tr>
                                    <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                        background-position: bottom left;">
                                        &nbsp;
                                    </td>
                                    <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                        background-repeat: repeat-x; background-position: bottom;">
                                        <asp:Button runat="server" ID="btnSave" CssClass="RegularUpdateButton" Text="שמירה"
                                            OnClick="btnSave_click" ValidationGroup="mainValid" />
                                    </td>
                                    <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                        background-repeat: no-repeat;">
                                        &nbsp;
                                    </td>
                                </tr>
                            </table>
                            <table cellpadding="0" cellspacing="0" style="display: inline">
                                <tr>
                                    <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                        background-position: bottom left;">
                                        &nbsp;
                                    </td>
                                    <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                        background-repeat: repeat-x; background-position: bottom;">
                                        <asp:Button runat="server" ID="btnCancel" CssClass="RegularUpdateButton" Text="ביטול"
                                            OnClick="btnCancel_click" />
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
</div>
    <div style="margin-top: 10px; padding-right: 200px">
        <asp:HiddenField ID="hdnCategoriesListCodes" runat="server" />
        <asp:HiddenField ID="hdnCategoriesList" runat="server" />
    </div>
</asp:Content>
