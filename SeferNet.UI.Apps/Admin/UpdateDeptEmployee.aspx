<%@ Reference Page="AdminBasePage.aspx" %>

<%@ Page Title="עדכון פרטי נותן שירות ביחידה" Language="C#" MasterPageFile="~/seferMasterPageIE.master"
    AutoEventWireup="true" Culture="he-il" UICulture="he-il"
    Inherits="Admin_UpdateDeptEmployee" Codebehind="UpdateDeptEmployee.aspx.cs" %>

<%@ Register TagPrefix="PhonesGridUC" TagName="PhonesGridUC" Src="~/UserControls/PhonesGridUC.ascx" %>
<%@ Register Src="../UserControls/GridReceptionHoursUC.ascx" TagName="GridReceptionHoursUC"
    TagPrefix="uc1" %>
<%@ Register Assembly="System.Web.Extensions, Version=1.0.61025.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
    Namespace="System.Web.UI" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="pageContent" runat="Server">

    <script type="text/javascript" src="../Scripts/BrowserVersions.js"></script>
    <script type="text/javascript" defer="defer">
        var ddlAgreementTypeClientID = '<%=ddlAgreementType.ClientID %>';
        var cbReceiveGuestsClientID = '<%=cbReceiveGuests.ClientID %>';
    </script>
    <script language="javascript" type="text/javascript">

        function OpenPositions(url) {

            var url = "../Public/SelectPopUp.aspx";
            url += "?popupType=1";
            url += "&deptEmployeeID=" + '<%= DeptEmployeeID %>' + "&employeeID=" + '<%= EmployeeID %>' + "&deptCode=" + '<%= DeptCode %>';
            url += "&returnValuesTo='txtQueueOrderCodes'";
            url += "&returnTextTo=txtPositions";

            var dialogWidth = 420;
            var dialogHeight = 660;
            var title = "בחר תפקידים";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return false;
        }

        function OpenServices(url) {
            // UpdateEmployeeDataPopup.aspx?popupType=3
            var url = "../Public/SelectPopUp.aspx";
            url += "?popupType=30";
            url += "&deptEmployeeID=" + '<%= DeptEmployeeID %>' + "&employeeID=" + '<%= EmployeeID %>' + "&deptCode=" + '<%= DeptCode %>';
            url += "&returnValuesTo=txtServiceCodes";
            //url += "&returnTextTo=txtPositions";
            url += "&functionToExecute=CauseUpdateAndRebindServices";

            var dialogWidth = 420;
            var dialogHeight = 660;
            var title = "בחר שירותים";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return false;
        }

        function OpenQueueOrder(url) {
            url = "SelectQueueMethod.aspx?DeptEmployeeID=" + '<%= DeptEmployeeID %>';

            var dialogWidth = 700;
            var dialogHeight = 500;
            var title = "אופן זימון";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return;
        }

        function SetQueueEmployeeInClinic(text) {
            document.getElementById('<%= lblQueuePhones.ClientID %>').innerHTML = text;
        }

        function UpdateEmployeeStatus(clickedLinkClientID) {

            var url = "UpdateStatus.aspx?EmployeeID=" + '<%= EmployeeID %>' + '&DeptCode=' + '<%= DeptCode %>' + '&DeptEmployeeID=' + '<%= DeptEmployeeID %>' + '&AgreementType=' + '<%= AgreementType %>';
            url += "&functionToExecute=Update_lnkStatus_EmployeeInDept" + "," + clickedLinkClientID;

            var dialogWidth = 500;
            var dialogHeight = 410;
            var title = "סטטוס";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);
        }

        function Update_lnkStatus_EmployeeInDept(newStatus, LinkClientID) {
            var lnkStatus = "";

            switch (LinkClientID) {
                case 0:
                    lnkStatus = document.getElementById('ctl00_pageContent_lnkStatus');
                    break;
                case 1:
                    lnkStatus = document.getElementById('ctl00_pageContent_lnkStatus');
                    break;
                case 2:
                    lnkStatus = document.getElementById('ctl00_pageContent_lnkStatus');
                    break;
                default:
                    break;
            }

            switch (newStatus) {
                case 0:
                    lnkStatus.text = "לא פעיל";
                    break;
                case 1:
                    lnkStatus.text = "פעיל";
                    break;
                case 2:
                    lnkStatus.text = "לא פעיל זמנית";
                    break;
                default:
                    break;
            }
        }

        function UpdateDeptEmployeeServicePhones(x_Dept_Employee_ServiceID) {

            url = "UpdateServicePhones.aspx?x_Dept_Employee_ServiceID=" + x_Dept_Employee_ServiceID;

            var dialogWidth = 700;
            var dialogHeight = 500;
            var title = "עידכון טלפונים לשירות";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return;
        }

        function UpdateDeptEmployeeServiceQueueOrder(x_Dept_Employee_ServiceID) {
            url = "SelectQueueMethod.aspx?x_Dept_Employee_ServiceID=" + x_Dept_Employee_ServiceID;

            var dialogWidth = 700;
            var dialogHeight = 500;
            var title = "אופן זימון";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return;
        }

        function SetQueueEmployeeServiceInClinic() {
            document.getElementById('<%= cbRebindServices.ClientID %>').checked = true;
            __doPostBack();
        }

        function RebindPhones() {
            document.getElementById('<%= cbRebindPhones.ClientID %>').checked = true;
            __doPostBack();
        }

        function CheckQueueOrder(val, args) {

            var queueOrder = document.getElementById('<%= lblQueuePhones.ClientID %>').innerHTML;

            args.IsValid = (queueOrder != "");
        }


        function UpdateEmployeeServiceStatus(clickedLinkClientID, serviceCode) {

            var url = "UpdateStatus.aspx?EmployeeID=" + '<%= EmployeeID %>' + "&DeptCode=" + '<%= DeptCode %>' + "&ServiceCode=" + serviceCode;
            url += "&functionToExecute=Update_lnkStatus_Service" + "," + clickedLinkClientID;

            var dialogWidth = 500;
            var dialogHeight = 410;
            var title = "סטטוס";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);
        }

        function Update_lnkStatus_Service(newStatus, LinkClientID) {

            LinkClientID = "ctl00_pageContent_gvServices_ct" + LinkClientID + "_lnkStatus";

            var lnkStatus = document.getElementById(LinkClientID); 

            lnkStatus.text = newStatus;
            return;
        }

        function GetScrollPosition_divGvServices(obj) {
            document.getElementById('<%=txtScrollTop.ClientID %>').value = obj.scrollTop;
        }
        function SetScrollPosition_DivGvServices() {
            var scrollPosition = document.getElementById('<%=txtScrollTop.ClientID %>').value;
            document.getElementById("divGvServices").scrollTop = scrollPosition;
        }

        function GetScrollPosition_divGvProfessions(obj) {
            document.getElementById('<%=txtScrollTop.ClientID %>').value = obj.scrollTop;
        }
        function SetScrollPosition_DivGvServices() {
            var scrollPosition = document.getElementById('<%=txtScrollTop.ClientID %>').value;
            document.getElementById("divGvProfessions").scrollTop = scrollPosition;
        }

        function ToggleQueueOrderPhonesAndHours(ToggleID, divNestID) {
            var tblID = "tblQueueOrderPhonesAndHours-" + ToggleID;
            var tblQueueOrderPhonesAndHours = document.getElementById(tblID);
            var divQueueOrderPhonesAndHours = document.getElementById('divQueueOrderPhonesAndHours');
            var imgID = "imgOrderMethod-" + ToggleID;
            var closeLink = "<tr><td align='left' style='padding-left:5px'><img style='cursor:hand' src='../Images/Applic/btn_ClosePopUpBlue.gif' onclick='javascript:closeQueueOrderPhonesAndHoursPopUp()' /> </td></tr>";

            var yPos = event.clientY + document.body.scrollTop; //getOBJposition(imgID, 'top');
            var xPos = event.clientX + document.body.scrollLeft - 20; //getOBJposition(imgID, 'left');

            var divNest = document.getElementById(divNestID);

            divQueueOrderPhonesAndHours.innerHTML =
            "<table cellpadding='0' cellspacing='0' style='background-color:White; border-top:solid 1px #555555; border-left:solid 1px #555555; border-bottom:solid 2px #888888; border-right:solid 2px #888888;'>" +
                "<tr><td>" +
                    "<table width='100%'>" +
                        tblQueueOrderPhonesAndHours.innerHTML +
                    "</table>" +
                "</td></tr>" +
                closeLink +
            "</table>";

            divQueueOrderPhonesAndHours.style.top = yPos + 10;
            divQueueOrderPhonesAndHours.style.left = xPos + 10;

            divQueueOrderPhonesAndHours.style.display = "inline";
        }

        function closeQueueOrderPhonesAndHoursPopUp() {
            var divPopUp = document.getElementById("divQueueOrderPhonesAndHours");

            divPopUp.style.display = "NONE";
        }

        function OnAgreementTypeSelectedIndexChange() {
            var ddlAgreementType = document.getElementById(ddlAgreementTypeClientID);
            var cbReceiveGuests = document.getElementById(cbReceiveGuestsClientID);
            //alert(ddlAgreementType.options[ddlAgreementType.selectedIndex].text.indexOf("עצמאי"));
            if (ddlAgreementType.options[ddlAgreementType.selectedIndex].text.indexOf("עצמאי") >= 0)
                cbReceiveGuests.checked = false;
            else
                cbReceiveGuests.checked = true;

        }

        function SetCbReceiveGuestsHasBeenChanged(obj) {
            var cbReceiveGuestsHasBeenChanged = document.getElementById('<%=cbReceiveGuestsHasBeenChanged.ClientID %>');
            cbReceiveGuestsHasBeenChanged.checked = true;
            //alert(obj.checked);
        }

        function checkValidators() {
            var rtnVal = true;
            
            for (i = 0; i < Page_Validators.length; i++)
            {
                ValidatorValidate(Page_Validators[i]);
                if (!Page_Validators[i].isvalid) { //at least one is not valid.
                    rtnVal = false;
                    break; //exit for-loop, we are done.
                }
            }

            if (rtnVal) { showProgressBarGeneral(); }
            return rtnVal;
        }

        function GoCopyClinicHoursToEmployeeHours(parameters) {
            if (confirm('?האם לאשר העתקה "שעות קבלה ליחידה" עבור שירות זה')) {
                document.getElementById('<%=txtParametersToCopyClinicHoursToEmployeeHours.ClientID %>').value = parameters;
                return true;
            }
            else {
                return false;
            }

        }
    </script>
    <script type="text/javascript">
        function CauseUpdateAndRebindServices() {
            document.getElementById("<%=btnCauseRebindServices.ClientID %>").click();
        }

        function OpenReceptionHoursPreview(url) {
            var dialogWidth = 750;
            var dialogHeight = 400;
            var title = "תצוגה מקדימה";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return false;
        }
    </script>

    <div id="divQueueOrderPhonesAndHours" style="position: absolute; display: none; z-index: 10;
        background-color: White;">
    </div>

    <div style="height: 25px; background-color: #298ae5; width: 1042px;">
        <table cellpadding="0" cellspacing="0" width="100%">
            <tr class="LabelBoldWhite_18">
                <td style="padding-right: 10px;">
                    <asp:Label EnableTheming="false" ID="lblNameHeader" runat="server">שם:</asp:Label>
                    <asp:Label EnableTheming="false" ID="lblPersonName" runat="server"></asp:Label>
                </td>
                <td>
                    <asp:Label EnableTheming="false" ID="lblSectorHeader" runat="server">סקטור:</asp:Label>
                    <asp:Label EnableTheming="false" ID="lblSector" runat="server"></asp:Label>
                </td>
                <td>
                    <asp:Label EnableTheming="false" ID="lblSpecialityHeader" runat="server">מומחיות:</asp:Label>
                    <asp:Label EnableTheming="false" ID="lblSpeciality" runat="server"></asp:Label>
                </td>
                <td align="left" class="LabelBoldWhite_13" valign="top">
                    <table cellpadding="0" cellspacing="0">
                        <tr>
                            <td class="buttonRightCorner">
                            </td>
                            <td class="buttonCenterBackground">
                                <asp:Button ID="btnSave" Text="שמירה" runat="server" CssClass="RegularUpdateButton" ValidationGroup="vgrSave"
                                    OnClick="btnSave_Click" CausesValidation="true" OnClientClick="javascript:showProgressBarGeneral('vgrSave');" />
                            </td>
                            <td class="buttonLeftCorner">
                            </td>
                            <td class="buttonRightCorner" style="padding-right: 5px">
                            </td>
                            <td class="buttonCenterBackground">
                                <asp:Button ID="btnCancel" Text="ביטול" runat="server" CssClass="RegularUpdateButton"
                                    OnClick="btnCancel_Click" CausesValidation="false" />
                            </td>
                            <td class="buttonLeftCorner" style="padding-left: 5px">
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </div>
    <table border="0">
        <tr>
            <td colspan="3">
                <asp:ValidationSummary ID="vldValidationSummary" ValidationGroup="vgrSave" runat="server" DisplayMode="BulletList" />
            </td>
        </tr>
        <tr>
            <td colspan="3" class="DisplayNone">
                <asp:TextBox ID="txtScrollTop" runat="server" EnableTheming="false"></asp:TextBox>

                <asp:TextBox ID="txtDeptEmployeeID" runat="server"></asp:TextBox>
                <asp:TextBox ID="txtServiceCodes" runat="server"></asp:TextBox>

                <asp:Button ID="btnCauseRebindServices" runat="server" Text="Rebind" OnClick="UpdateEmployeeServices"/>
            </td>
        </tr>
        <tr>
            <td valign="top" style="height:100%">
                <div style="width: 430px; height:110px; vertical-align: top;" class="BorderedTable">
                    <table border="0" style="margin: 0px; height:100%">
                        <tr style="vertical-align: text-top">
                            <td>
                                <asp:Label ID="lblPositions" runat="server" EnableTheming="false" CssClass="LabelBoldDirtyBlue">תפקידים:</asp:Label>
                            </td>
                            <td>
                                <asp:TextBox ID="txtPositions" runat="server" Height="20px" Width="330px" TextMode="MultiLine"
                                    CssClass="TextBoxMultiLine" ReadOnly="true"></asp:TextBox>
                            </td>
                            <td style="padding-top: 2px">
                                <asp:ImageButton ID="btnRoles" runat="server" ImageUrl="../Images/applic/icon_magnify.gif"
                                    OnClientClick="OpenPositions('UpdateEmployeeDataPopup.aspx?popupType=1');return false;" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label ID="lblAgreementType" runat="server" EnableTheming="false" CssClass="LabelBoldDirtyBlue">סוג הסכם:</asp:Label>
                            </td>
                            <td colspan="2">
                                <asp:DropDownList ID="ddlAgreementType" runat="server" DataTextField="AgreementTypeDescription" DataValueField="AgreementTypeID"></asp:DropDownList>
                                <asp:TextBox ID="txtAgreementType" runat="server" Width="50px" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>
                                <asp:CheckBox ID="cbReceiveGuests" OnClick="SetCbReceiveGuestsHasBeenChanged(this)" AutoPostBack="true" runat="server" EnableTheming="false" Text="מקבל אורחים" CssClass="RegularCheckBoxList" />
                                <asp:CheckBox ID="cbReceiveGuestsHasBeenChanged" runat="server" EnableTheming="false" Text="מקבל אורחים" CssClass="DisplayNone" />
                                <asp:CheckBox ID="cbRebindServices" runat="server" EnableTheming="false" Text="MakeRebind" CssClass="DisplayNone" />
                                <asp:CheckBox ID="cbRebindPhones" runat="server" EnableTheming="false" Text="MakeRebind" CssClass="DisplayNone" />

                             </td>
                        </tr>
                        <tr>
                            <td colspan="3" valign="middle">
                                <table>
                                    <tr>
                                        <td valign="middle">
                                            <asp:Label ID="lblStatus" runat="server" EnableTheming="false" CssClass="LabelBoldDirtyBlue">סטאטוס:</asp:Label>
                                        </td>
                                        <td>
                                            <asp:LinkButton ID="lnkStatus" CssClass="Link" runat="server" OnClick="RebindStatus" OnClientClick="UpdateEmployeeStatus();"></asp:LinkButton>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <asp:Panel ID="pnlQueueOrder" runat="server">
                                    <table cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td>
                                                <asp:CustomValidator ID="rqdQueueOrder" ClientValidationFunction="CheckQueueOrder"  ValidationGroup="vgrSave"
                                                    ErrorMessage="חובה להזין אופן זימון" runat="server" Text="*" Display="Dynamic" />
                                                <asp:Label ID="lblQueueHeader" runat="server" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                    Text="אופן הזימון:"></asp:Label>&nbsp;
                                                <asp:Label ID="lblQueuePhones" runat="server" dir="ltr"></asp:Label>
                                            </td>
                                            <td style="padding-right: 5px">
                                                <asp:LinkButton ID="lnkUpdateInvatation" OnClientClick="OpenQueueOrder('SelectQueueMethod.aspx');return false;"
                                                    CssClass="choiseField" runat="server" Text="עדכון אופן הזימון"></asp:LinkButton>
                                            </td>
                                        </tr>
                                    </table>
                                </asp:Panel>
                            </td>
                        </tr>
                    </table>
                </div>
            </td>
            <td valign="top" style="padding-right: 10px;">
                <div style="padding-top: 0px; padding-right: 10px; height: 110px" class="BorderedTable">
                    <asp:UpdatePanel ID="updatePanel" runat="server" UpdateMode="Always">
                        <ContentTemplate>
                            <table border="0" cellpadding="0" cellspacing="0" width="410px">
                                <tr style="vertical-align: text-top">
                                    <td class="LabelBoldDirtyBlue">
                                        <asp:CustomValidator ID="rqdPhoneOrFax" runat="server" Display="Dynamic" OnServerValidate="CheckPhoneOrFaxValid"
                                            ErrorMessage="חובה להזין אחד מהשדות טלפון או פקס" />
                                        טלפונים לרופא ביחידה:
                                    </td>
                                    <td align="left" valign="top">
                                        <asp:CheckBox ID="chkShowPhonesFromDept" runat="server" OnCheckedChanged="TogglePhonesPanel"
                                            AutoPostBack="true" />
                                    </td>
                                    <td>
                                        <asp:Label CssClass="LabelBoldDirtyBlue" EnableTheming="false" ID="lblShowPhones"
                                            runat="server" Text="הצג טלפונים מפרטי יחידה"></asp:Label>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="3">
                                        <asp:Panel ID="pnlPhones" runat="server">
                                            <table width="100%">
                                                <tr>
                                                    <td dir="ltr" colspan="2" align="right">
                                                        <PhonesGridUC:PhonesGridUC ID="phoneUC" runat="server" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td dir="ltr" colspan="2" align="right">
                                                        <PhonesGridUC:PhonesGridUC ID="faxUC" runat="server" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </asp:Panel>
                                    </td>
                                </tr>
                            </table>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
            </td>
            <td valign="top" align="left" style="padding-top: 2px; width:151px">
                <table cellpadding="0" cellspacing="0">
                    <tr>
                        <td class="buttonRightCorner" style="padding-right: 5px;">
                        </td>
                        <td class="buttonCenterBackground">
                            <asp:Button ID="btnAddRemark" Text="הוספת הערה" Width="90px" runat="server" CssClass="RegularUpdateButton"
                                OnClick="btnAddRemark_Click" />
                        </td>
                        <td class="buttonLeftCorner">
                        </td>
                    </tr>
                    <tr style="height: 5px">
                        <td>
                        </td>
                    </tr>
                    <tr>
                        <td class="buttonRightCorner" style="padding-right: 5px;">
                        </td>
                        <td class="buttonCenterBackground">
                            <asp:Button ID="btnUpdateRemarks" Text="עדכון הערות" Width="90px" runat="server" CssClass="RegularUpdateButton"
                                OnClick="btnUpdateRemarks_Click" />
                        </td>
                        <td class="buttonLeftCorner">
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>

    <table width="100%">
        <tr>
            <td>
                <table cellpadding="0" cellspacing="0" style="border: 1px solid #E3E5F0; width:1040px;">
                    <tr style="background-color: #E8F4FD">
                        <td style="padding:5px 10px 5px 5px;"><div style="float:right">
                            <asp:Label ID="lblServices" runat="server" EnableTheming="false" CssClass="LabelCaptionBlueBold_14"
                                Text='תחומי שירות'></asp:Label></div>
                            <div style="float:left">
                            <table id="tblBtnAddService" runat="server" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td class="buttonRightCorner" style="padding-right: 5px;">
                                    </td>
                                    <td class="buttonCenterBackground" style="padding:0px 0px 0px 0px">
                                        <asp:Button ID="btnAddService" Text="הוספת תחומי שירות" runat="server" CssClass="RegularUpdateButton"
                                            OnClick="RebindServicesGrid"  Width="130px"
                                            OnClientClick="if (!OpenServices('UpdateEmployeeDataPopup.aspx?popupType=3')) return false;" />
                                    </td>
                                    <td class="buttonLeftCorner">
                                    </td>
                                </tr>
                            </table>
                            </div>
                        </td>
                    </tr>
                    <tr id="trServicesHeader" runat="server">
                        <td style="padding-right:20px">
                            <asp:Panel ID="pnlServicesHeader" runat="server">
                                <asp:Label ID="Label1" Width="200px" EnableTheming="false" CssClass="LabelCaptionGreenBold_12"
                                    runat="server">שם</asp:Label>
                                <asp:Label ID="Label3" Width="65px" runat="server" EnableTheming="false" CssClass="LabelCaptionGreenBold_12">סטטוס</asp:Label>
                                <asp:Label ID="Label4" Width="115px" runat="server" EnableTheming="false" CssClass="LabelCaptionGreenBold_12">אופן הזימון</asp:Label>
                                <asp:Label ID="Label5" Width="120px" runat="server" EnableTheming="false" CssClass="LabelCaptionGreenBold_12">טלפונים לשירות</asp:Label>
                                <asp:Label ID="Label6" Width="100px" EnableTheming="false" CssClass="LabelCaptionGreenBold_12"
                                    runat="server">הערות</asp:Label>
                            </asp:Panel>
                        </td>
                    </tr>
                    <tr id="trServices" runat="server">
                        <td>
                            <div class="ScrollBarDiv" id="divGvServices" onscroll="GetScrollPosition_divGvServices(this)" style="height: 150px; overflow-y: auto; width: 1035px; text-align: right">
                                <asp:GridView ID="gvServices" runat="server" AutoGenerateColumns="False" EnableTheming="false"
                                    Width="1035px" ShowHeader="False" GridLines="None" OnRowCommand="gvServices_RowCommand"
                                    OnRowDataBound="gvServices_RowDataBound" 
                                    OnRowDeleting="gvServices_RowDeleting" OnRowEditing="gvServices_RowEditing">
                                    <RowStyle BackColor="#F3F3F3" VerticalAlign="Top" />
                                    <AlternatingRowStyle BackColor="#FEFEFE" VerticalAlign="Top"/>
                                    <Columns>
                                        <asp:TemplateField ItemStyle-Width="17px">
                                            <ItemTemplate>
                                                <asp:Image ID="imgService" runat="server" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField ItemStyle-Width="270px">  
                                            <ItemTemplate>
                                                <div style="width:270px">
                                                <table>
                                                    <tr>
                                                        <td style="width:210px">
                                                            <asp:Label ID="lblServiceDescription" EnableTheming="false" CssClass="RegularLabel" runat="server" Text='<%#Eval("serviceDescription") %>'></asp:Label>

                                                        </td>
                                                        <td style="width:60px; vertical-align:top; padding-top:6px;">
                                                            <asp:LinkButton ID="lnkStatus" runat="server" 
                                                                OnClick="RebindServices" CssClass="LooksLikeHRef11" Text='<%# Eval("StatusDescription") %>'></asp:LinkButton>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td colspan="2">
                                                            <table cellpadding="0" cellspacing="0">
                                                                <tr>
                                                                    <td class="buttonRightCorner" style="padding-right: 3px">
                                                                    </td>
                                                                    <td class="buttonCenterBackground">
                                                                        <asp:Button ID="btnUpdate" Text="עדכון הערות" Width="80px" runat="server" CommandName="UpdateEmployeeServiceRemarks"
                                                                            CssClass="RegularUpdateButton" CommandArgument='<%# Eval("ServiceCode")%>'/>
                                                                    </td>
                                                                    <td class="buttonLeftCorner">
                                                                    </td>
                                                                    <td class="buttonRightCorner" style="padding-right: 3px">
                                                                    </td>
                                                                    <td class="buttonCenterBackground">
                                                                        <asp:Button ID="btnAddRemark" Text="הוספת הערות" Width="80px" runat="server" CommandName="AddEmployeeServiceRemark"
                                                                            CssClass="RegularUpdateButton" CommandArgument='<%# Eval("ServiceCode")%>' />
                                                                    </td>
                                                                    <td class="buttonLeftCorner">
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </table>

                                                </div>
                                            </ItemTemplate>
                                        </asp:TemplateField>                                              

                                        <asp:TemplateField ItemStyle-Width="120px">
                                            <ItemTemplate>
                                                <table width="120px" cellpadding="0" cellspacing="0">
                                                    <tr>
                                                        <td id="tdEmployeeServiceQueueOrderMethods" runat="server" onclick='<%# "UpdateDeptEmployeeServiceQueueOrder(" + Eval("x_Dept_Employee_ServiceID") + ")"%>' title="עדכון אופן הזימון" valign="bottom" style="cursor:pointer"
                                                            align="right">
                                                        </td>
                                                    </tr>
                                                </table>
                                                <table id='tblQueueOrderPhonesAndHours-<%# Eval("ToggleID") %>' style="display: none" cellpadding="0" cellspacing="0">
                                                    <tr>
                                                        <td dir="ltr" align="right">
                                                            <asp:Label ID="lblEmployeeServiceQueueOrderPhones" EnableTheming="false" CssClass="RegularLabel" runat="server"></asp:Label>
                                                        </td>
                                                        <tr>
                                                            <td>
                                                                <asp:GridView ID="gvEmployeeServiceQueueOrderHours" runat="server" EnableTheming="false"
                                                                    GridLines="None" AutoGenerateColumns="false" HeaderStyle-CssClass="HeaderStyleBlueBold"
                                                                    EnableViewState="false">
                                                                    <Columns>
                                                                        <asp:BoundField HeaderText="יום" DataField="ReceptionDayName" ItemStyle-BackColor="#E1F0FC"
                                                                            ItemStyle-HorizontalAlign="Center" ItemStyle-Width="25px" ItemStyle-CssClass="RegularLabel" />
                                                                        <asp:TemplateField HeaderText="משעה" ItemStyle-Width="45px">
                                                                            <ItemTemplate>
                                                                                <div style="padding-right:5px; border-bottom: 1px solid #BADBFC; border-top: 1px solid #BADBFC;">
                                                                                    <asp:Label ID="lblServiceQueueOrderHours_From" CssClass="RegularLabel" runat="server"
                                                                                        Text='<%#Eval("FromHour") %>'></asp:Label>
                                                                                </div>
                                                                            </ItemTemplate>
                                                                        </asp:TemplateField>
                                                                        <asp:TemplateField HeaderText="עד שעה" ItemStyle-Width="45px">
                                                                            <ItemTemplate>
                                                                                <div style="width: 100%;padding-right:7px;
                                                                                        border-bottom: 1px solid #BADBFC; border-top: 1px solid #BADBFC;">
                                                                                    <asp:Label ID="lblServiceQueueOrderHours_To" CssClass="RegularLabel" runat="server"
                                                                                        Text='<%#Eval("ToHour") %>'></asp:Label>
                                                                                </div>
                                                                            </ItemTemplate>
                                                                        </asp:TemplateField>
                                                                    </Columns>
                                                                </asp:GridView>
                                                            </td>
                                                        </tr>
                                                    </tr>
                                                </table>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField ItemStyle-Width="120px">
                                            <ItemTemplate>
                                                <div style="width:110px;cursor:pointer" onclick='<%# "UpdateDeptEmployeeServicePhones(" + Eval("x_Dept_Employee_ServiceID") + ")"%>'  title="עדכון טלפונים לשירות">
                                                    <div id="divLblUpdatePhones" runat="server" style="padding-top:6px">
                                                        <asp:Label ID="lblUpdatePhones" runat="server" EnableTheming="false" Text="עדכון" CssClass="LooksLikeHRef"></asp:Label>
                                                    </div>
                                                    <asp:GridView ID="gvServicePhones" runat="server" EnableTheming="false" AutoGenerateColumns="false"
                                                        HeaderStyle-CssClass="DisplayNone" GridLines="None">
                                                        <RowStyle CssClass="column_style_bottom_HrefLike" />
                                                        <Columns>
                                                            <asp:TemplateField ItemStyle-BorderWidth="0">
                                                                <ItemTemplate>
                                                                    <div>
                                                                    <asp:Label ID="lblPhoneTypeName" Width="20px" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                                        runat="server" Text='<%#Eval("shortPhoneTypeName") %>'></asp:Label>
                                                                    <asp:Label ID="lblPhone" Width="80px" EnableTheming="false" CssClass="RegularLabel" runat="server" Text='<%# Eval("phoneNumber") %>'></asp:Label>
                                                                    </div>
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                        </Columns>
                                                    </asp:GridView>
                                                </div>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField ItemStyle-Width="330px">
                                            <ItemTemplate>
                                                <asp:GridView ID="gvServiceRemarks" runat="server" EnableTheming="false" AutoGenerateColumns="false"
                                                    HeaderStyle-CssClass="DisplayNone" GridLines="None">
                                                    <Columns>
                                                        <asp:TemplateField >
                                                            <ItemTemplate>
                                                                <table>
                                                                    <tr>
                                                                        <td style="color: gray;" valign="top">&diams;&nbsp;
                                                                        </td>
                                                                        <td>
                                                                            <asp:Label ID="lblRemarkText" Width="270px" EnableTheming="false" CssClass="RegularLabel" runat="server" Text='<%#Eval("RemarkText") %>'></asp:Label>
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                             </ItemTemplate>
                                                        </asp:TemplateField>
                                                    </Columns>
                                                </asp:GridView>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField>
                                            <ItemStyle HorizontalAlign="Left" />
                                            <ItemTemplate>
                                                <table cellpadding="0" cellspacing="0">
                                                    <tr>
                                                        <td colspan="3" align="left">
                                                            <asp:ImageButton ID="btnDeleteService" ToolTip="מחיקת שירות" CommandName="Delete" runat="server" CommandArgument='<%# Eval("ServiceCode") %>'
                                                                ImageUrl="../Images/Applic/btn_X_red.gif" OnClientClick="return confirm('?האם הנך בטוח שברצונך למחוק את השירות')" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td class="buttonRightCorner" style="padding-right: 3px">
                                                        </td>
                                                        <td class="buttonCenterBackground">
                                                            <asp:Button ID="btnCopyClinicHours" Text="העתקת שעות יחידה" Width="120px" runat="server" CssClass="RegularUpdateButton"  />
                                                        </td>
                                                        <td class="buttonLeftCorner">
                                                        </td>
                                                    </tr>
                                                </table>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </td>
                    </tr>
                    <tr id="trInsteadServices" runat="server">
                        <td style="height:180px; width:100%; padding-right:320px" align="center">
                            <span class="RegularLabel"> לא ניתן לעדכן נתונים אלה לנותן שירות "לא פעיל"!</span><br />
                            <span class="RegularLabel"> קודם יש לשנות סטטוס נותן השירות ורק אחרי זה לעדכן את הנתונים</span>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>

    <table width="100%">
        <tr>
            <td>
                <table cellpadding="0" dir="rtl" cellspacing="0" width="985px" style="background-image: url('../Images/GradientVerticalBlueAndWhite.jpg');
                    background-repeat: repeat-x;">
                    <!-- tab buttons -->
                    <tr>
                        <td colspan="2" style="background-image: url('../Images/Applic/tab_WhiteBlueBackGround.jpg');
                            background-position: top; background-repeat: repeat-x; margin: 0px 0px 0px 0px;
                            padding: 0px 0px 0px 0px;">
                            <table cellpadding="0" cellspacing="0" border="0">
                                <tr>
                                    <td style="width: 10px; height: 30px;">
                                    </td>
                                    <td id="tdReceptionInDeptTab" runat="server" align="center" valign="top" style="margin: 0px 0px 0px 0px;
                                        padding: 0px 1px 0px 0px;">
                                        <div id="divReceptionInDeptBut" runat="server" style="padding-top: 2px; width: 100%;
                                            height: 100%;" visible="false">
                                            <table cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td style="width: 7px; height: 22px; background-image: url('../Images/Applic/btn_BG_grey_right.gif');
                                                        background-position: top; background-repeat: no-repeat;">
                                                    </td>
                                                    <td valign="top" style="background-image: url('../Images/Applic/btn_BG_grey_middle.gif');
                                                        background-position: top; background-repeat: repeat-x;">
                                                        <asp:LinkButton ID="btnReceptionInDeptTab" runat="server" OnClick="btnReceptionInDeptTab_Click"
                                                            CssClass="TabButton_14" Font-Underline="false"></asp:LinkButton>
                                                    </td>
                                                    <td style="width: 8px; background-image: url('../Images/Applic/btn_BG_grey_left.gif');
                                                        background-position: top; background-repeat: no-repeat;">
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                        <div id="divReceptionInDeptBut_Tab" runat="server" style="height: 100%; width: 100%">
                                            <table cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td style="width: 6px; height: 32px; background-image: url('../Images/Applic/tab_Right.gif');
                                                        background-position: top; background-repeat: no-repeat">
                                                    </td>
                                                    <td style="background-image: url('../Images/Applic/tab_Middle.gif'); background-position: top;
                                                        background-repeat: repeat-x;" valign="top">
                                                        <asp:Label ID="lblReceptionInDeptTab" runat="server" EnableTheming="false" CssClass="LabelCaptionBlueBold_14"></asp:Label>
                                                    </td>
                                                    <td style="width: 6px; background-image: url('../Images/Applic/tab_Left.gif'); background-position: top;
                                                        background-repeat: no-repeat">
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                    </td>
                                    <td valign="top" align="center" style="margin: 0px 0px 0px 0px; padding: 0px 1px 0px 0px;">
                                        <div id="divReceptionInAllBut" runat="server" style="padding-top: 2px; height: 100%;
                                            width: 100%">
                                            <table cellpadding="0" cellspacing="0" border="0">
                                                <tr>
                                                    <td width="7px" style="height: 22px; background-image: url('../Images/Applic/btn_BG_grey_right.gif');
                                                        background-position: top; background-repeat: no-repeat;">
                                                    </td>
                                                    <td valign="top" style="background-image: url('../Images/Applic/btn_BG_grey_middle.gif');
                                                        background-position: top; background-repeat: repeat-x;">
                                                        <asp:Button ID="btnReceptionInAllTab" runat="server" Width="100%" Text="שעות קבלה בכל היחידות"
                                                            CssClass="TabButton_14" CausesValidation="false" OnClick="btnReceptionInAllTab_Click" />
                                                    </td>
                                                    <td style="width: 8px; background-image: url('../Images/Applic/btn_BG_grey_left.gif');
                                                        background-position: top; background-repeat: no-repeat;">
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                        <div id="divReceptionInAllBut_Tab" runat="server" style="height: 100%;" visible="false">
                                            <table cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td style="width: 7px; height: 32px; background-image: url('../Images/Applic/tab_Right.gif');
                                                        background-position: top; background-repeat: no-repeat">
                                                    </td>
                                                    <td style="background-image: url('../Images/Applic/tab_Middle.gif'); background-position: top;
                                                        background-repeat: repeat-x" valign="top">
                                                        <asp:Label ID="lblReceptionInAllTab" runat="server" Text="שעות קבלה בכל היחידות"
                                                            EnableTheming="false" CssClass="LabelCaptionBlueBold_14"></asp:Label>
                                                    </td>
                                                    <td style="width: 8px; background-image: url('../Images/Applic/tab_Left.gif'); background-position: top;
                                                        background-repeat: no-repeat">
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtTabToBeShown" runat="server" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr id="trReceptionHours" runat="server">
                        <td colspan="2">
                            <asp:Panel runat="server">
                                <asp:UpdatePanel runat="server" UpdateMode="Always">
                                    <ContentTemplate>
                                        <asp:Panel ID="pnlReceptionHours" runat="server">
                                            <uc1:GridReceptionHoursUC ID="gvReceptionHours" runat="server" />
                                        </asp:Panel>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </asp:Panel>
                        </td>
                    </tr>
                    <tr id="trPreviewFutureHours" runat="server">
                        <td align="left" width="1000px" style="padding-left: 10px">
                            <asp:Label ID="WarningPreviewHours" runat="server" Text="שימו לב יש ללחוץ על כפתור שמירה לאחר עדכון שעות הפעילות"
                                CssClass="LabelWarningOrange" EnableTheming="false">
                            </asp:Label>
                        </td>
                        <td align="left" style="padding: 2px 0px 0px 5px">
                            <table cellpadding="0" cellspacing="0" border="0">
                                <tr>
                                    <td class="buttonRightCorner">
                                    </td>
                                    <td class="buttonCenterBackground">
                                        <asp:Button ID="Button1" Text="תצוגה מקדימה" runat="server" CssClass="RegularUpdateButton"
                                            OnClick="ShowReceptionPreview" />
                                    </td>
                                    <td class="buttonLeftCorner">
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr id="trInsteadReceptionHours" runat="server">
                        <td colspan="2" style="width:980px; height:180px;" align="center">
                            <span class="RegularLabel"> לא ניתן לעדכן נתונים אלה לנותן שירות "לא פעיל"!</span><br />
                            <span class="RegularLabel"> קודם יש לשנות סטטוס נותן השירות ורק אחרי זה לעדכן את הנתונים</span>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    <div style="height: 25px; background-color: #298ae5; width: 1042px">
        <table cellpadding="0" cellspacing="0" width="100%">
            <tr class="LabelBoldWhite_13">
                <td>
                    <asp:TextBox ID="txtParametersToCopyClinicHoursToEmployeeHours" runat="server" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>
                </td>
                <td align="left" style="vertical-align: middle">
                    <table cellpadding="0" cellspacing="0">
                        <tr>
                            <td class="buttonRightCorner">
                            </td>
                            <td class="buttonCenterBackground">
                                <asp:Button ID="btnSaveBottom" Text="שמירה" runat="server" CssClass="RegularUpdateButton" ValidationGroup="vgrSave"
                                    OnClick="btnSave_Click" CausesValidation="true" OnClientClick="javascript:showProgressBarGeneral('vgrSave');" />
                            </td>
                            <td class="buttonLeftCorner">
                            </td>
                            <td class="buttonRightCorner" style="padding-right: 5px">
                            </td>
                            <td class="buttonCenterBackground">
                                <asp:Button ID="btnCancelBottom" Text="ביטול" runat="server" CssClass="RegularUpdateButton"
                                    OnClick="btnCancel_Click" CausesValidation="false" />
                            </td>
                            <td class="buttonLeftCorner" style="padding-left: 5px">
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </div>
</asp:Content>
