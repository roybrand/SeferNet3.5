<%@ Page Title="" Language="C#" MasterPageFile="~/SeferMasterPageIEwide.Master" AutoEventWireup="true" CodeBehind="updateEmployee.aspx.cs" Inherits="SeferNet.UI.Apps.Admin.updateEmployeeLike" %>
<%@ Register Src="../UserControls/PhonesGridUC.ascx" TagName="PhonesGridUC" TagPrefix="UCphones" %>
<asp:Content ID="Content1" ContentPlaceHolderID="phHead" runat="server">

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="pageContent" runat="server">
    <script type="text/javascript">
        function guidGenerator() {
            var S4 = function () {
                return (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1);
            };
            return (S4() + S4() + "-" + S4() + "-" + S4() + "-" + S4() + "-" + S4() + S4() + S4());
        }

        function OpenPopup(popupType, textControl, hiddenControl) {
            var searchID = guidGenerator();
            url = "GetAllDataPopup.aspx?popupType=" + popupType + "&employeeID=" + '<%= EmployeeID %>' + "&searchID=" + searchID + "&selectedCodes=" + document.getElementById(hiddenControl).value;
            url = url + "&returnValuesTo=" + hiddenControl;
            url = url + "&returnTextTo=" + textControl;
            if (popupType == 2) {
                url = url + "&functionToExecute=setSubmiButtonsEnabled_OpenUpdateExpertPopUp";
            }

            var dialogWidth = 420;
            var dialogHeight = 690;
            var title = "";
            switch (popupType) {
                case 2:
                    title = 'מקצועות לנותן שירות';
                    break;
                case 3:
                    title = 'שירותים לנותן שירות';
                    break;
                case 4:
                    title = 'שפות לנותן שירות';
                    break;
                case 5:
                    title = 'מומחיות לנותן שירות';
                    break;
            }

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);
        }

        function OpenPopupBySector(popupType, sectorType, textControl, hiddenControl) {

            url = "../Public/SelectPopup.aspx?popupType=" + popupType + "&sectorType=" + sectorType +
                "&SelectedValuesList=" + document.getElementById(hiddenControl).value;

            url = url + "&returnValuesTo=" + hiddenControl;
            url = url + "&returnTextTo="+textControl;
            url = url + "&functionToExecute=setSubmiButtonsEnabled";

            var dialogWidth = 420;
            var dialogHeight = 660;
            var title = "מקצועות לנותן שירות";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);
        }

        function OpenStatusModal() {

            var EmployeeID = <%= EmployeeID %>;

            var url = "UpdateStatus.aspx";
            url += "?EmployeeID=" + EmployeeID;
            url += "&functionToExecute=RebindStatus_FromClient";

            var dialogWidth = 500;
            var dialogHeight = 410;
            var title = "סטטוס";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);
        }

        function RebindStatus_FromClient() {
<%--            document.getElementById('<%= cbRebindStatus_FromClient.ClientID  %>').checked = true;
            document.forms[0].submit();--%>
        }

        function CheckDDLHasValue(val, args) {

            ddl = $('#' + val.id).closest("tr").find("select");

            args.IsValid = (ddl.val() != 0);
        }

        function CheckDoctorHasProfessions(val, args) {
            var ddlSector = document.getElementById('<%= ddlSector.ClientID %>');

            var isActive = $("#<%=hfActive.ClientID %>").val();
            if (isActive != 1) {
                args.IsValid = true;
            }
            else {
                if (ddlSector.selectedIndex == 0) {
                    chosenProfessions = document.getElementById('<%= txtProfessions.ClientID  %>');

                    if (chosenProfessions.value.trim() == '') {
                        args.IsValid = false;
                    }
                    else {
                        args.IsValid = true;
                    }
                }
                else {
                    args.IsValid = true;
                }
            }
        }

        function CheckLanguages(val, args) {

            var txtLang = document.getElementById('<%= txtLanguages.ClientID %>').value.trim();

            /* If the employee is active then the language sector could be empty */
            var isActive = $("#<%=hfActive.ClientID %>").val();
            if (isActive != 1) {
                args.IsValid = true;
            }
            else {
                args.IsValid = (txtLang != '' && txtLang != null);
            }

        }

        function setSubmiButtonsEnabled() {
<%--            document.getElementById('<%=btnSaveTop.ClientID %>').disabled = false;
            document.getElementById('<%=btnSaveBottom.ClientID %>').disabled = false;--%>
        }

        function setSubmiButtonsEnabled_OpenUpdateExpertPopUp() {
<%--            document.getElementById('<%=btnSaveTop.ClientID %>').disabled = false;
            document.getElementById('<%=btnSaveBottom.ClientID %>').disabled = false;--%>

            //SelectJQueryClose();
            //OpenUpdateExpertPopUp();
        }

        function ConfirmIntentionToChangeProfessions() {
            return confirm("\t\t      :לצורך הסרת מקצוע מכרטיס נותן השירות\n \t\t\t\t\t\t     1.\n יש לבצע הסרה של המקצוע הרלוונטי של נותן השירות ביחידות בהן הוא עובד דרך מסך \"עדכון פרטי נותן שירות ביחידה, תחומי שירות\" \n \t\t\t\t\t\t     2.\n      לחזור למסך זה ולבצע את הסרת המקצוע מכרטיס נותן השירות");
        }

        function OpenUpdateExpertPopUp() {
            var url = "UpdateEmployeeExpertProfession.aspx";
            url += "?returnValuesTo=hdnSpeciality";
            url += "&returnTextTo=txtSpeciality";

            var dialogWidth = 420;
            var dialogHeight = 660;
            var title = "מומחיות לנותן שירות";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);
        }

        function specialityClick() {
            OpenPopup(5, '<%= txtSpeciality.ClientID %>', '<%= hdnSpeciality.ClientID %>')
        }

    </script>

    <table cellpadding="0" cellspacing="0" width="100%" dir="rtl">
        <tr>
            <td> 
                <table cellpadding="0" cellspacing="0" width="100%">
                    <tr>
                        <td style="padding-right: 10px">
                            <table cellpadding="0" cellspacing="0" width="100%" style="background-color: #298AE5;">
                                <tr class="LabelBoldWhite_18" style="height: 30px">
                                    <td style="padding-right: 5px">
                                        <asp:CheckBox ID="cbRebindStatus_FromClient" runat="server" CssClass="DisplayNone" />
                                        <asp:Label EnableTheming="false" ID="lblDegreeHeader" runat="server">תואר:</asp:Label>
                                        <asp:Label EnableTheming="false" ID="lblDegree" runat="server"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:Label EnableTheming="false" ID="lblFirstNameHeader" runat="server">שם פרטי:</asp:Label>
                                        <asp:Label EnableTheming="false" ID="lblFirstName" runat="server"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:Label EnableTheming="false" ID="lblLastNameHeader" runat="server">שם משפחה:</asp:Label>
                                        <asp:Label EnableTheming="false" ID="lblLastName" runat="server"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:Label EnableTheming="false" ID="lblSpeciality" runat="server"></asp:Label>
                                    </td>
                                    <td align="left" style="vertical-align: middle">
                                        <table cellpadding="0" cellspacing="0" border="0">
                                            <tr class="LabelBoldWhite_13">
                                                <td class="buttonRightCorner">
                                                 &nbsp;
                                                </td>
                                                <td class="buttonCenterBackground">
                                                    <asp:Button ID="btnSaveTop" runat="server" Text="שמירה" CssClass="RegularUpdateButton"
                                                        CausesValidation="true" OnClick="btnSave_click" ValidationGroup="vgrEmployeeValidation" OnClientClick="javascript:showProgressBarGeneral('vgrEmployeeValidation');">
                                                    </asp:Button>
                                                </td>
                                                <td class="buttonLeftCorner">
                                                </td>
                                                <td class="buttonRightCorner">
                                                    &nbsp;
                                                </td>
                                                <td class="buttonCenterBackground">
                                                    <asp:Button ID="btnBackToOpener" runat="server" CssClass="RegularUpdateButton" Text="ביטול"
                                                        CausesValidation="False" OnClick="btnCancel_click" />
                                                </td>
                                                <td class="buttonLeftCorner">
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

            </td>
        </tr>

        <tr>
            <td>
                <asp:ValidationSummary ID="vldSummary" runat="server" ValidationGroup="vgrEmployeeValidation" />
            </td>
        </tr>
        <tr>
            <td>
                <div style="margin-top: 5px; margin-right: 10px; background-color: #F7F7F7;">
                    <table cellpadding="0" cellspacing="0" border="0">
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
                                <table width="965px" cellpadding="0" cellspacing="0" border="0">
                                    <tr>
                                        <td>
                                            <table class="LabelBoldDirtyBlue_12">
                                                <tr>
                                                    <td width="180px">
                                                        פרטים מה-MainFrame:
                                                    </td>
                                                    <td>
                                                        שם פרטי MF:
                                                    </td>
                                                    <td width="180px">
                                                        <asp:Label ID="lblFirstNameMF" runat="server"></asp:Label>
                                                    </td>
                                                    <td>
                                                        שם משפחה MF:
                                                    </td>
                                                    <td width="180px">
                                                        <asp:Label ID="lblLastNameMF" runat="server"></asp:Label>
                                                    </td>
                                                    <td>
                                                        ת.ז.:
                                                    </td>
                                                    <td>
                                                        <asp:Label ID="lblIdMF" runat="server"></asp:Label>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        פרטים לתצוגה בספר השירות:
                                                    </td>
                                                    <td>
                                                        שם פרטי:
                                                    </td>
                                                    <td>
                                                        <asp:TextBox ID="txtFirstName" runat="server" MaxLength="50"></asp:TextBox>
                                                        <asp:RequiredFieldValidator ID="vldFirstName" runat="server" Display="Dynamic" ControlToValidate="txtFirstName"
                                                            ValidationGroup="vgrEmployeeValidation"></asp:RequiredFieldValidator>
                                                    </td>
                                                    <td>
                                                        שם משפחה:
                                                    </td>
                                                    <td>
                                                        <asp:TextBox ID="txtLastName" runat="server" MaxLength="50"></asp:TextBox>
                                                        <asp:RequiredFieldValidator ID="vldLastName" runat="server" Display="Dynamic" ControlToValidate="txtLastName"
                                                            ValidationGroup="vgrEmployeeValidation"></asp:RequiredFieldValidator>
                                                    </td>
                                                    <td>
                                                        תואר:
                                                    </td>
                                                    <td>
                                                        <asp:DropDownList ID="ddlDegree" runat="server" Width="80px">
                                                        </asp:DropDownList>
                                                        <asp:CustomValidator ID="rqdDegree" runat="server" ClientValidationFunction="CheckDDLHasValue"
                                                            ValidationGroup="vgrEmployeeValidation" ErrorMessage="חובה לבחור תואר"></asp:CustomValidator>
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
                        <tr style="height: 8px">
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
            </td>
        </tr>
        <tr>
            <td>
                <div style="margin-top: 7px; margin-right: 10px; background-color: #F7F7F7; display: inline;
                    float: right">
                    <table cellpadding="0" cellspacing="0" border="0">
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
                                
                                <table cellpadding="0" cellspacing="0" style="height: 292px;">
                                    <tr>
                                        <td valign="top">
                                            <asp:UpdatePanel UpdateMode="Conditional" runat="server">
                                                <ContentTemplate>
                                                    <table width="100%" cellpadding="0" cellspacing="3" border="0" class="LabelBoldDirtyBlue_12">
                                                        <tr>
                                                            <td>
                                                                סקטור:
                                                            </td>
                                                            <td valign="top" colspan="2" style="padding-right: 2px">
                                                                <asp:DropDownList Width="100px" ID="ddlSector" runat="server" OnSelectedIndexChanged="ddlSector_selectedIndexChanged"
                                                                    AutoPostBack="true">
                                                                </asp:DropDownList>
                                                                <asp:CustomValidator ID="vldSectorChange" ValidationGroup="vgrEmployeeValidation"
                                                                    runat="server" OnServerValidate="ValidateSectorChange" Display="Dynamic"></asp:CustomValidator>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td valign="top">
                                                                מקצועות:
                                                            </td>
                                                            <td valign="top" style="padding-right: 2px">
                                                                <asp:TextBox ID="txtProfessions" CssClass="TextBoxMultiLine" runat="server" Height="28px"
                                                                    Width="200px" TextMode="MultiLine" ReadOnly="true"></asp:TextBox>
                                                            </td>
                                                            <td valign="top" style="padding-top: 2px">
                                                                <img id="btnProfessions" runat="server" src="../Images/applic/icon_magnify.gif" style="cursor: pointer;" />
                                                                <asp:CustomValidator ID="rqdProfessions" runat="server" ValidationGroup="vgrEmployeeValidation"
                                                                    ErrorMessage="חובה לבחור מקצוע לסקטור זה" ClientValidationFunction="CheckDoctorHasProfessions"></asp:CustomValidator>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td valign="top">
                                                                מומחיות:
                                                            </td>
                                                            <td valign="top" style="padding-right: 2px">
                                                                <asp:TextBox ID="txtSpeciality" CssClass="TextBoxMultiLine" runat="server" Height="28px"
                                                                    Width="200px" TextMode="MultiLine" ReadOnly="true"></asp:TextBox>
                                                            </td>
                                                            <td valign="top" style="padding-top: 2px">
                                                                <asp:ImageButton ID="btnSpeciality" runat="server" ImageUrl="../Images/applic/icon_magnify.gif" OnClientClick="specialityClick()" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td valign="top">
                                                                שירותים:
                                                            </td>
                                                            <td valign="top" style="padding-right: 2px">
                                                                <asp:TextBox ID="txtServices" CssClass="TextBoxMultiLine" runat="server" Height="28px"
                                                                    Width="200px" TextMode="MultiLine" ReadOnly="true"></asp:TextBox>
                                                            </td>
                                                            <td valign="top" style="padding-top: 2px">
                                                                <img style="cursor: pointer" src="../Images/applic/icon_magnify.gif" onclick="OpenPopup(3, '<%= txtServices.ClientID %>', '<%= hdnServices.ClientID %>' );" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td valign="top">
                                                                שפות:
                                                            </td>
                                                            <td valign="top" style="padding-right: 2px">
                                                                <asp:TextBox ID="txtLanguages" CssClass="TextBoxMultiLine" runat="server" Height="28px"
                                                                    Width="200px" TextMode="MultiLine" ReadOnly="true"></asp:TextBox>
                                                            </td>
                                                            <td valign="top" style="padding-top: 2px">
                                                                <img style="cursor: pointer" src="../Images/applic/icon_magnify.gif" onclick="OpenPopup(4, '<%= txtLanguages.ClientID %>', '<%= hdnLanguages.ClientID %>' );" />
                                                                <asp:CustomValidator ID="rqdLanguages" runat="server" ClientValidationFunction="CheckLanguages"
                                                                    ErrorMessage="חובה לבחור שפות" ValidationGroup="vgrEmployeeValidation" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                מחוז:
                                                            </td>
                                                            <td valign="top" colspan="2">
                                                                <asp:DropDownList ID="ddlDistrict" Width="204px" runat="server" AppendDataBoundItems="false">
                                                                </asp:DropDownList>
                                                                <asp:CompareValidator ID="vld" runat="server" Operator="NotEqual" ValueToCompare="-1"
                                                                    ControlToValidate="ddlDistrict" Text="*" ErrorMessage="חובה לבחור מחוז" ValidationGroup="vgrEmployeeValidation"></asp:CompareValidator>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                מגדר:
                                                            </td>
                                                            <td valign="top">
                                                                <asp:DropDownList ID="ddlGender" Width="100px" runat="server">
                                                                </asp:DropDownList>
                                                                <asp:CustomValidator ID="rqdGender" runat="server" ClientValidationFunction="CheckDDLHasValue"
                                                                    ErrorMessage="חובה לבחור מגדר" ValidationGroup="vgrEmployeeValidation"></asp:CustomValidator>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                רשיון רופא:
                                                            </td>
                                                            <td valign="top">
                                                                <asp:Label ID="lblLicenseNumber" runat="server"></asp:Label>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                רשיון מקצוע:
                                                            </td>
                                                            <td valign="top">
                                                                <asp:Label ID="lblProfLicenseNumber" runat="server"></asp:Label>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                סטאטוס:
                                                            </td>
                                                            <td valign="top">
                                                                <asp:LinkButton ID="lnkStatus" CssClass="Link" runat="server" OnClientClick="if (!OpenStatusModal()) return false;"
                                                                    OnClick="RebindStatus"></asp:LinkButton>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                    <asp:HiddenField ID="hfActive" runat="server" />
                                                </ContentTemplate>
                                            </asp:UpdatePanel>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td style="border-left: solid 2px #909090;">
                                <div style="width: 6px;">
                                </div>
                            </td>
                        </tr>
                        <tr style="height: 8px">
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
                <div style="margin-right: 12px; margin-top: 7px; background-color: #F7F7F7; display: inline;
                    float: right">
                    <table cellpadding="0" cellspacing="0">
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
                                <table width="603px">
                                    <tr>
                                        <td>
                                            <table border="0" cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td colspan="3" class="RegularLabel">
                                                        טלפונים:
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="RegularLabelNormal" style="width:80px">
                                                        טלפון בבית:
                                                    </td>
                                                    <td align="right">
                                                        <ucphones:phonesgriduc ID="phoneUC" runat="server" />
                                                    </td>
                                                    <td style="width:200px">
                                                        <asp:CheckBox ID="chkHomePhoneProtected" runat="server" Text="חסוי" CssClass="RegularLabelNormal" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="RegularLabelNormal">
                                                        טלפון נייד:
                                                    </td>
                                                    <td align="right">
                                                        <ucphones:phonesgriduc ID="cellPhoneUC" runat="server" />
                                                    </td>
                                                    <td>
                                                        <asp:CheckBox ID="chkCellPhoneProtected" runat="server" Text="חסוי" CssClass="RegularLabelNormal" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="RegularLabelNormal">
                                                        Email:
                                                    </td>
                                                    <td style="padding-right: 13px;" colspan="2">
                                                        <asp:TextBox ID="txtEmail" Width="190px" runat="server" Style="direction: ltr"></asp:TextBox>
                                                        <asp:RegularExpressionValidator Width="10px" Text="*" ID="RegularExpressionValidator1"
                                                            runat="server" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
                                                            ErrorMessage="כתובת  ה - email שגויה. אנא נסה שנית" ControlToValidate="txtEmail"
                                                            ValidationGroup="vgrEmployeeValidation"> </asp:RegularExpressionValidator>
                                                        &nbsp;
                                                        <asp:CheckBox ID="chkDisplayOnInternet" runat="server" CssClass="RegularLabelNormal"
                                                            Text="הצג באינטרנט" />
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
                        <tr style="height: 8px">
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
                <div style="margin-right: 12px; margin-top: 10px; background-color: #F7F7F7; display: inline;
                    float: right">
                    <table cellpadding="0" cellspacing="0" border="0">
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
                                <table width="605px" style="height: 141px" border="0">
                                    <tr>
                                        <td valign="top">
                                            <table width="100%" border="0">
                                                <tr>
                                                    <td class="RegularLabel" valign="top">
                                                        הערות:
                                                    </td>
                                                    <td align="left" rowspan="2" valign="top">
                                                        <table cellpadding="0" cellspacing="0">
                                                            <tr>
                                                                <td class="buttonRightCorner">
                                                                </td>
                                                                <td class="buttonCenterBackground">
                                                                    <asp:Button ID="btnAddRemark" Text="הוספת הערות" runat="server" CssClass="RegularUpdateButton"
                                                                        OnClick="AddRemarks_click" />
                                                                </td>
                                                                <td class="buttonLeftCorner">
                                                                </td>
                                                                <td>
                                                                    &nbsp;
                                                                </td>
                                                                <td class="buttonRightCorner">
                                                                </td>
                                                                <td class="buttonCenterBackground">
                                                                    <asp:Button ID="btnComments" Text="עדכון הערות" runat="server" CssClass="RegularUpdateButton"
                                                                        OnClick="UpdateRemarks_click" />
                                                                </td>
                                                                <td class="buttonLeftCorner">
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td colspan="2">
                                                        <div style="height:125px; width: 500px; overflow: auto; direction: ltr;" class="ScrollBarDiv">
                                                            <div dir="rtl" style="margin-right: 10px;">
                                                                <asp:Repeater ID="rptRemarks" runat="server" OnItemDataBound="rptRemarks_ItemDataBound">
                                                                    <ItemTemplate>
                                                                        <asp:Label ID="lblDeptName" runat="server" CssClass="LabelBoldDirtyBlue" EnableTheming="false"></asp:Label><br />
                                                                        <asp:Repeater ID="rptInnerRemarks" runat="server" OnItemDataBound="rptInnerRemarks_ItemDataBound">
                                                                            <ItemTemplate>
                                                                                <asp:Image ID="imgDontDisplayRemarkOnInternet" runat="server" Visible="false" ImageUrl="~/Images/Applic/pic_NotShowInInternet.gif" />
                                                                                <font color="gray">&diams;</font>
                                                                                <asp:Label ID="lblRemarkForDept" runat="server" Style="display: inline"></asp:Label>
                                                                                <br />
                                                                            </ItemTemplate>
                                                                        </asp:Repeater>
                                                                        <br />
                                                                    </ItemTemplate>
                                                                </asp:Repeater>
                                                            </div>
                                                        </div>
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
                        <tr style="height: 8px">
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
            </td>
        </tr>
        <tr>
            <td>
                <table cellpadding="0" cellspacing="0" width="100%">
                    <tr>
                        <td style="padding-right: 10px">
                            <table cellpadding="0" cellspacing="0" width="100%" style="background-color: #298AE5;">
                                <tr class="LabelBoldWhite_13" style="height: 30px">
                                    <td align="left" style="vertical-align: middle">
                                        <table cellpadding="0" cellspacing="0" border="0">
                                            <tr>
                                                <td class="buttonRightCorner">
                                                </td>
                                                <td class="buttonCenterBackground">
                                                    <asp:Button ID="btnSaveBottom" runat="server" Text="שמירה" CssClass="RegularUpdateButton"
                                                        CausesValidation="true" OnClick="btnSave_click" ValidationGroup="vgrEmployeeValidation" OnClientClick="javascript:showProgressBarGeneral('vgrEmployeeValidation');">
                                                    </asp:Button>
                                                </td>
                                                <td class="buttonLeftCorner">
                                                </td>
                                                <td class="buttonRightCorner">
                                                    &nbsp;
                                                </td>
                                                <td class="buttonCenterBackground">
                                                    <asp:Button ID="btnCancel" runat="server" CssClass="RegularUpdateButton" Text="ביטול"
                                                        CausesValidation="False" OnClick="btnCancel_click" />
                                                </td>
                                                <td class="buttonLeftCorner">
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
            </td>
        </tr>
    </table>`
    <asp:HiddenField ID="hdnProfessions" runat="server" />
    <asp:HiddenField ID="hdnSpeciality" runat="server" />
    <asp:HiddenField ID="hdnServices" runat="server" />
    <asp:HiddenField ID="hdnLanguages" runat="server" />
    <script type="text/javascript">
        // All of this because Jquery DIALOG not work on this page without ctrl+F.
        // This is an attempt to imitate ctrl+F.
        // IT STILL DOESN'T HELP !!!!! 08/01/2023
        window.onload = function () {
            //alert("before reload");
            if (!window.location.hash) {
                window.location = window.location + '#loaded';
                window.location.reload(true);
            }
        }
</script>

</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="postBackContent" runat="server">
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="postBackPageContent" runat="server">
</asp:Content>
