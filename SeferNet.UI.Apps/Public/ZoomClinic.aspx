<%@ Page Language="C#" Title="פרטי יחידה" AutoEventWireup="true" MasterPageFile="~/seferMasterPageIEwide.master" Theme="SeferGeneral" Inherits="ZoomClinic" EnableEventValidation="false"
    meta:resourcekey="PageResource1" Codebehind="ZoomClinic.aspx.cs" %>

<%@ Register TagName="ucDeptReceptionAndRemarks" TagPrefix="uc" Src="../usercontrols/DeptReceptionAndRemarks.ascx" %>
<%@ MasterType VirtualPath="~/seferMasterPageIEwide.master" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<%@ Register TagPrefix="uc1" TagName="SortableColumnHeader" Src="~/UserControls/SortableColumnHeader.ascx" %>
<asp:Content ID="Content1" ContentPlaceHolderID="pageContent" runat="server">
    <script type="text/javascript">


        function closeQueueOrderPhonesAndHoursPopUp() {
            var divPopUp = document.getElementById("divQueueOrderPhonesAndHours");

            divPopUp.style.display = "none";
        }


        function toggleHalfClock(itemCode, tablePrefix) {

            var tableArr = document.all.tags("table");
            var tableId;
            var partialTableId = tablePrefix + itemCode;
            var tblHours;
            var tagAid = 'ShowDoctorsOtherPlacesLink-' + itemCode;
            var tagA = document.getElementById(tagAid);

            for (var i = 0; i < tableArr.length; i++) {
                if (tableArr[i].id == null || tableArr[i].id == "")
                    continue;
                tableId = tableArr[i].id;

                if (tableId == partialTableId) {
                    tblHours = document.getElementById(tableId);

                    if (tblHours.style.display != "none") {
                        tblHours.style.display = "none";
                        tagA.innerText = "הצג";
                    }
                    else {
                        tblHours.style.display = "inline";
                        tagA.innerText = "הסתר";
                    }

                    break;
                }
            }
        }

        function ToggleQueueOrderPhonesAndHours(ToggleID, divNestID) {
            var tblID = "tblQueueOrderPhonesAndHours-" + ToggleID;
            var tblQueueOrderPhonesAndHours = document.getElementById(tblID);
            var divQueueOrderPhonesAndHours = document.getElementById('divQueueOrderPhonesAndHours');
            var imgID = "imgOrderMethod-" + ToggleID;
            var closeLink = "<tr><td align='left' style='padding-left:5px'><img style='cursor:hand' src='../Images/Applic/btn_ClosePopUpBlue.gif' onclick='javascript:closeQueueOrderPhonesAndHoursPopUp()' /> </td></tr>";

            var yPos = event.clientY + document.body.scrollTop; //getOBJposition(imgID, 'top');
            var xPos = event.clientX + document.body.scrollLeft - 20; //getOBJposition(imgID, 'left');

            //var divServicesAndEvents = document.getElementById("divServicesAndEvents");
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


        function ToggleHandicapped() {
            var tdGvHandicapped = document.getElementById('tdGvHandicapped');
            var tdHandicappedCaption = document.getElementById('ctl00_pageContent_dvClinicDetails_tdHandicappedCaption');

            if (tdHandicappedCaption.innerText == "") {
                return;
            }
            if (tdGvHandicapped.style.display != "none") {
                tdGvHandicapped.style.display = "none";
                tdHandicappedCaption.innerHTML = "פרוט ";
            }
            else {
                tdGvHandicapped.style.display = "inline";
                tdHandicappedCaption.innerHTML = "הסתר ";
            }
        }

        function SetTabToBeShownOnLoad() {
            var txtTabToBeShown = document.getElementById('<%=txtTabToBeShown.ClientID%>');
            if (txtTabToBeShown.value != "") {
                var str = txtTabToBeShown.value;
                var parameters = str.split(',');
                //alert(parameters[0]);
                if (parameters.length == 3) {
                    SetTabToBeShown(parameters[0], parameters[1], parameters[2]);
                }

            }
            else {
                SetTabToBeShown('divClinicDetailsBut', 'trDeptDetails', 'tdClinicDetailsTab', 'tb_clinicDetails');
            }

        }

        function SetTabToBeShown(btnId, sectionId, tabId, selectedTab) {

            var txtTabToBeShown = document.getElementById('<%=txtTabToBeShown.ClientID%>');
            txtTabToBeShown.value = btnId + "," + sectionId + "," + tabId;
            hideAllTabSections();

            if(selectedTab) {
                SimpleService.SetSelectedTabInSession(selectedTab);
            }

            var prefix = "ctl00_pageContent_";
            var sectionFullId = prefix + sectionId;
            var tabFullId = prefix + tabId;
            var btnFullId = prefix + btnId;
            var substitute_DIV_ID = btnFullId + "_Tab";

            var section = document.getElementById(sectionId);
            var tab = document.getElementById(tabFullId);
            var btn = document.getElementById(btnFullId); // it's DIV now

            var substitute_DIV = document.getElementById(substitute_DIV_ID); // substitute DIV

            if (section != null) {
                section.style.display = "inline";
                btn.style.display = "none";
                substitute_DIV.style.display = "inline";
            }

            var divQueueOrderPhonesAndHours = document.getElementById("divQueueOrderPhonesAndHours");
            if (divQueueOrderPhonesAndHours != null)
                divQueueOrderPhonesAndHours.style.display = "none";
        }

        function ClearTxtTabToBeShown() {
            var txtTabToBeShown = document.getElementById('<%=txtTabToBeShown.ClientID%>');
            txtTabToBeShown.value = "";
        }

        function hideAllTabSections() {
            var trDeptDetails = document.getElementById("trDeptDetails");
            var trDeptReception = document.getElementById("trDeptReception");
            var trDoctors = document.getElementById("trDoctors");
            var trSubClinics = document.getElementById("trSubClinics");
            var trMushlamServices = document.getElementById("trMushlamServices");
            var trMedicalAspects = document.getElementById("trMedicalAspects");

            var divClinicDetailsBut = document.getElementById('<%=divClinicDetailsBut.ClientID%>');
            var divClinicHoursBut = document.getElementById('<%=divClinicHoursBut.ClientID%>');
            var divDoctorsEmployeesBut = document.getElementById('<%=divDoctorsEmployeesBut.ClientID%>');
            var divMedicalAspectsBut = document.getElementById('<%=divMedicalAspectsBut.ClientID%>');
            var divSubClinicsBut = document.getElementById('<%=divSubClinicsBut.ClientID%>');
            var divMushlamServicesBut = document.getElementById('<%=divMushlamServicesBut.ClientID%>');

            var divClinicHoursBut_Tab = document.getElementById('<%=divClinicHoursBut_Tab.ClientID%>');
            var divClinicDetailsBut_Tab = document.getElementById('<%=divClinicDetailsBut_Tab.ClientID%>');
            var divDoctorsEmployeesBut_Tab = document.getElementById('<%=divDoctorsEmployeesBut_Tab.ClientID%>');
            var divSubClinicsBut_Tab = document.getElementById('<%=divSubClinicsBut_Tab.ClientID%>');
            var divMushlamServicesBut_Tab = document.getElementById('<%=divMushlamServicesBut_Tab.ClientID%>');
            var divMedicalAspectsBut_Tab = document.getElementById('<%=divMedicalAspectsBut_Tab.ClientID%>');


            divClinicDetailsBut.style.display = "inline";
            divClinicHoursBut.style.display = "inline";
            divDoctorsEmployeesBut.style.display = "inline";
            divMedicalAspectsBut.style.display = "inline";
            divMushlamServicesBut.style.display = "inline";
            divSubClinicsBut.style.display = "inline";

            divClinicHoursBut_Tab.style.display = "none";
            divClinicDetailsBut_Tab.style.display = "none";
            divDoctorsEmployeesBut_Tab.style.display = "none";
            divMushlamServicesBut_Tab.style.display = "none";
            divMedicalAspectsBut_Tab.style.display = "none";
            divSubClinicsBut_Tab.style.display = "none";

            if (trDeptDetails != null) {
                trDeptDetails.style.display = "none";
            }
            if (trDeptReception != null) {
                trDeptReception.style.display = "none";
            }
            if (trDoctors != null) {
                trDoctors.style.display = "none";
            }

            if (trSubClinics != null) {
                trSubClinics.style.display = "none";
            }

            if (trMushlamServices != null) {
                trMushlamServices.style.display = "none";
            }

            if (trMedicalAspects != null) {
                trMedicalAspects.style.display = "none";
            }
        }

        function SetDeptCode(DeptCode) {
            var txtDeptCode = document.getElementById('<%=txtSelectedDeptCode.ClientID%>');
            txtDeptCode.value = DeptCode;
            document.forms[0].submit();
        }

        function ShowEmployeeSectorGridView(idSuffix) {
            var btnShowEmployeeSector = document.getElementById('imgShowEmployeeSector-' + idSuffix);
            var trEmployeeSector = document.getElementById('trEmployeeSector-' + idSuffix);
            if (trEmployeeSector.style.display != "none") {
                trEmployeeSector.style.display = "none";
                btnShowEmployeeSector.src = "../Images/Applic/btn_Plus_Blue_12.gif"

            }
            else {
                trEmployeeSector.style.display = "inline";
                btnShowEmployeeSector.src = "../Images/Applic/btn_Minus_Blue_12.gif"
            }
        }

        function Open_FrmSelectTemplate(deptCodes, currentDeptCode) {
            var Url = "../Templates/FrmSelectTemplate.aspx?Template=PrintZoomClinicOuter&NearestDepts=" + deptCodes + "&CurrentDeptCode=" + currentDeptCode;

            var newWindow = window.open(Url, "newWindow", "scrollbars = yes, menubar = yes, toolbar = yes, resizable = yes");
            newWindow.focus();
        }

    </script>
    <div id="divQueueOrderPhonesAndHours" style="position: absolute; display: none; z-index: 10;
        background-color: White;">
    </div>
    <!-- tab buttons -->
    <table cellpadding="0" cellspacing="0" style="background-image: url('../Images/GradientVerticalBlueAndWhite.jpg');
        background-repeat: repeat-x;" dir="rtl">
        <tr>
            <td style="width: 100%; background-image: url('../Images/Applic/tab_WhiteBlueBackGround.jpg');
                background-position: bottom; background-repeat: repeat-x; margin: 0px 0px 0px 0px;
                padding: 0px 0px 6px 0px;">
                <table cellpadding="0" cellspacing="0" border="0" width="100%">
                    <tr>
                        <td style="margin: 0px 0px 0px 0px; padding: 0px 0px 0px 0px;">
                            <table cellpadding="0" cellspacing="0">
                                <tr>
                                    <td style="width: 10px; height: 30px;"></td>
                                    <%--------------- tdClinicDetailsTab -------------------%>
                                    <td id="tdClinicDetailsTab" align="center" valign="bottom" style="margin: 0px 0px 0px 0px;
                                        padding: 0px 1px 0px 0px;">
                                        <div id="divClinicDetailsBut" runat="server" style="display: none; width: 100%; height: 100%;">
                                            <table cellpadding="0" cellspacing="0" style="margin: 0px 0px 2px 0px;">
                                                <tr>
                                                    <td style="width: 10px; height: 22px; background-image: url('../Images/Applic/btn_BG_grey_right.gif');
                                                        background-position: top; background-repeat: no-repeat;" class="TDpadding0">
                                                    </td>
                                                    <td valign="top" style="background-image: url('../Images/Applic/btn_BG_grey_middle.gif');
                                                        background-position: top; background-repeat: repeat-x;" class="TDpadding0">
                                                        <asp:Button ID="btnClinicDetailsTab" runat="server" Height="18px" Width="80px" Text="פרטי יחידה"
                                                            CssClass="TabButton_14" OnClientClick="SetTabToBeShown('divClinicDetailsBut','trDeptDetails','tdClinicDetailsTab','tb_clinicDetails'); return false;" />
                                                    </td>
                                                    <td style="width: 10px; background-image: url('../Images/Applic/btn_BG_grey_left.gif');
                                                        background-position: top; background-repeat: no-repeat;" class="TDpadding0">
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                        <div id="divClinicDetailsBut_Tab" runat="server" style="display: none; height: 100%;">
                                            <table cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td style="width: 8px; height: 26px; background-image: url('../Images/Applic/tab_Right.gif');
                                                        background-position: top; background-repeat: no-repeat" class="TDpadding0">
                                                    </td>
                                                    <td style="background-image: url('../Images/Applic/tab_Middle.gif'); background-position: top;
                                                        background-repeat: repeat-x" class="TDpadding0">
                                                        <asp:Label ID="lblTabClinicDetails" runat="server" Text="פרטי יחידה" EnableTheming="false"
                                                            CssClass="LabelCaptionBlueBold_18"> </asp:Label>
                                                    </td>
                                                    <td style="width: 8px; background-image: url('../Images/Applic/tab_Left.gif'); background-position: top;
                                                        background-repeat: no-repeat" class="TDpadding0">
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                    </td>
                                    <%---------------- tdClinicHoursTab --------------------%>
                                    <td id="tdClinicHoursTab" align="center" valign="bottom" style="margin: 0px 0px 0px 0px;
                                        padding: 0px 1px 0px 0px;">
                                        <div id="divClinicHoursBut" runat="server" style="display: none; width: 100%; height: 100%;">
                                            <table cellpadding="0" cellspacing="0" style="margin: 0px 0px 2px 0px;">
                                                <tr>
                                                    <td style="width: 10px; height: 22px; background-image: url('../Images/Applic/btn_BG_grey_right.gif');
                                                        background-position: top; background-repeat: no-repeat;" class="TDpadding0">
                                                    </td>
                                                    <td valign="top" style="background-image: url('../Images/Applic/btn_BG_grey_middle.gif');
                                                        background-position: top; background-repeat: repeat-x;" class="TDpadding0">
                                                        <asp:Button ID="btnClinicHoursTab" runat="server" Text="שעות קבלה" CssClass="TabButton_14"
                                                            Width="80px" Height="18px" OnClientClick="SetTabToBeShown('divClinicHoursBut','trDeptReception','tdClinicHoursTab','tb_clinicReception'); return false;" />
                                                    </td>
                                                    <td style="width: 10px; background-image: url('../Images/Applic/btn_BG_grey_left.gif');
                                                        background-position: top; background-repeat: no-repeat;" class="TDpadding0">
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                        <div id="divClinicHoursBut_Tab" runat="server" style="display: none; height: 100%;">
                                            <table cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td style="width: 8px; height: 26px; background-image: url('../Images/Applic/tab_Right.gif');
                                                        background-position: top; background-repeat: no-repeat" class="TDpadding0">
                                                    </td>
                                                    <td style="background-image: url('../Images/Applic/tab_Middle.gif'); background-position: top;
                                                        background-repeat: repeat-x" class="TDpadding0">
                                                        <asp:Label ID="lblTabClinicHours" runat="server" Text="שעות קבלה" EnableTheming="false"
                                                            CssClass="LabelCaptionBlueBold_18"> </asp:Label>
                                                    </td>
                                                    <td style="width: 8px; background-image: url('../Images/Applic/tab_Left.gif'); background-position: top;
                                                        background-repeat: no-repeat" class="TDpadding0">
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                    </td>
                                    <%-- ------------tdDoctorsEmployeesTab----------------%>
                                    <td id="tdDoctorsEmployeesTab" align="center" valign="bottom" style="margin: 0px 0px 0px 0px;
                                        padding: 0px 1px 0px 0px;">
                                        <div id="divDoctorsEmployeesBut" runat="server" style="display: none; width: 100%;
                                            height: 100%;">
                                            <table cellpadding="0" cellspacing="0" style="margin: 0px 0px 2px 0px;">
                                                <tr>
                                                    <td style="width: 10px; height: 22px; background-image: url('../Images/Applic/btn_BG_grey_right.gif');
                                                        background-position: top; background-repeat: no-repeat;" class="TDpadding0">
                                                    </td>
                                                    <td valign="top" style="background-image: url('../Images/Applic/btn_BG_grey_middle.gif');
                                                        background-position: top; background-repeat: repeat-x;" class="TDpadding0">
                                                        <asp:Button ID="btnDoctorsEmployeesTab" runat="server" CssClass="TabButton_14" Width="90px"
                                                            Height="18px" Text="תחומי שירות" OnClientClick="SetTabToBeShown('divDoctorsEmployeesBut','trDoctors','tdDoctorsEmployeesTab','tb_clinicServices'); return false;" />
                                                    </td>
                                                    <td style="width: 10px; background-image: url('../Images/Applic/btn_BG_grey_left.gif');
                                                        background-position: top; background-repeat: no-repeat;" class="TDpadding0">
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                        <div id="divDoctorsEmployeesBut_Tab" runat="server" style="display: none; height: 100%;">
                                            <table cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td style="width: 8px; height: 26px; background-image: url('../Images/Applic/tab_Right.gif');
                                                        background-position: top; background-repeat: no-repeat" class="TDpadding0">
                                                    </td>
                                                    <td style="background-image: url('../Images/Applic/tab_Middle.gif'); background-position: top;
                                                        background-repeat: repeat-x" class="TDpadding0">
                                                        <asp:Label ID="lblTabDoctorsEmployees" runat="server" Text="תחומי שירות" EnableTheming="false"
                                                            CssClass="LabelCaptionBlueBold_18"> </asp:Label>
                                                    </td>
                                                    <td style="width: 8px; background-image: url('../Images/Applic/tab_Left.gif'); background-position: top;
                                                        background-repeat: no-repeat" class="TDpadding0">
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                    </td>
                                    <%-------------- tdMedicalAspects ---------------%>
                                    <td id="tdMedicalAspectsTab" runat="server" align="center" valign="bottom" style="margin: 0px 0px 0px 0px;
                                        padding: 0px 1px 0px 0px;display:none">
                                        <div id="divMedicalAspectsBut" runat="server" style="display: none; width: 100%;
                                            height: 100%;">
                                            <table cellpadding="0" cellspacing="0" style="margin: 0px 0px 2px 0px;">
                                                <tr>
                                                    <td style="width: 10px; height: 22px; background-image: url('../Images/Applic/btn_BG_grey_right.gif');
                                                        background-position: top; background-repeat: no-repeat;" class="TDpadding0">
                                                    </td>
                                                    <td valign="top" style="background-image: url('../Images/Applic/btn_BG_grey_middle.gif');
                                                        background-position: top; background-repeat: repeat-x;" class="TDpadding0">
                                                        <asp:Button ID="btnMedicalAspectsTab" runat="server" CssClass="TabButton_14" Width="90px"
                                                            Height="18px"  Text="היבטים רפואיים" OnClientClick="SetTabToBeShown('divMedicalAspectsBut','trMedicalAspects','tdMedicalAspectsTab','tb_clinicMedicalAspects'); return false;" />
                                                    </td>
                                                    <td style="width: 10px; background-image: url('../Images/Applic/btn_BG_grey_left.gif');
                                                        background-position: top; background-repeat: no-repeat;" class="TDpadding0">
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                        <div id="divMedicalAspectsBut_Tab" runat="server" style="display: none; height: 100%;">
                                            <table cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td style="width: 8px; height: 26px; background-image: url('../Images/Applic/tab_Right.gif');
                                                        background-position: top; background-repeat: no-repeat" class="TDpadding0">
                                                    </td>
                                                    <td style="background-image: url('../Images/Applic/tab_Middle.gif'); background-position: top;
                                                        background-repeat: repeat-x" class="TDpadding0">
                                                        <asp:Label ID="lblTabMedicalAspects" runat="server" Text="היבטים רפואיים" EnableTheming="false"
                                                            CssClass="LabelCaptionBlueBold_18"> </asp:Label>
                                                    </td>
                                                    <td style="width: 8px; background-image: url('../Images/Applic/tab_Left.gif'); background-position: top;
                                                        background-repeat: no-repeat" class="TDpadding0">
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                    </td>
                                    <%-------------- tdMushlamServices ---------------%>
                                    <td id="tdMushlamServicesTab" runat="server" align="center" valign="bottom" style="margin: 0px 0px 0px 0px;
                                        padding: 0px 1px 0px 0px;display:none">
                                        <div id="divMushlamServicesBut" runat="server" style="display: none; width: 100%;
                                            height: 100%;">
                                            <table cellpadding="0" cellspacing="0" style="margin: 0px 0px 2px 0px;">
                                                <tr>
                                                    <td style="width: 10px; height: 22px; background-image: url('../Images/Applic/btn_BG_grey_right.gif');
                                                        background-position: top; background-repeat: no-repeat;" class="TDpadding0">
                                                    </td>
                                                    <td valign="top" style="background-image: url('../Images/Applic/btn_BG_grey_middle.gif');
                                                        background-position: top; background-repeat: repeat-x;" class="TDpadding0">
                                                        <asp:Button ID="Button5" runat="server" CssClass="TabButton_14" Width="90px"
                                                            Height="18px"  Text="שירותי מושלם" OnClientClick="SetTabToBeShown('divMushlamServicesBut','trMushlamServices','tdMushlamServicesTab','tb_clinicMushlamServices'); return false;" />
                                                    </td>
                                                    <td style="width: 10px; background-image: url('../Images/Applic/btn_BG_grey_left.gif');
                                                        background-position: top; background-repeat: no-repeat;" class="TDpadding0">
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                        <div id="divMushlamServicesBut_Tab" runat="server" style="display: none; height: 100%;">
                                            <table cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td style="width: 8px; height: 26px; background-image: url('../Images/Applic/tab_Right.gif');
                                                        background-position: top; background-repeat: no-repeat" class="TDpadding0">
                                                    </td>
                                                    <td style="background-image: url('../Images/Applic/tab_Middle.gif'); background-position: top;
                                                        background-repeat: repeat-x" class="TDpadding0">
                                                        <asp:Label ID="Label7" runat="server" Text="שירותי מושלם" EnableTheming="false"
                                                            CssClass="LabelCaptionBlueBold_18"> </asp:Label>
                                                    </td>
                                                    <td style="width: 8px; background-image: url('../Images/Applic/tab_Left.gif'); background-position: top;
                                                        background-repeat: no-repeat" class="TDpadding0">
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                    </td>
                                    <%--------------tdSubClinicsTab---------------%>
                                    <td id="tdSubClinicsTab" align="center" valign="bottom" style="margin: 0px 0px 0px 0px;
                                        padding: 0px 1px 0px 0px;">
                                        <div id="divSubClinicsBut" runat="server" style="display: none; width: 100%; height: 100%;">
                                            <table cellpadding="0" cellspacing="0" style="margin: 0px 0px 2px 0px;">
                                                <tr>
                                                    <td style="width: 10px; height: 22px; background-image: url('../Images/Applic/btn_BG_grey_right.gif');
                                                        background-position: top; background-repeat: no-repeat;" class="TDpadding0">
                                                    </td>
                                                    <td valign="top" style="background-image: url('../Images/Applic/btn_BG_grey_middle.gif');
                                                        background-position: top; background-repeat: repeat-x;" class="TDpadding0">
                                                        <asp:Button ID="btnSubClinicsTab" runat="server" CssClass="TabButton_14" Width="82px"
                                                            Height="18px" Text="יחידות כפופות" OnClientClick="SetTabToBeShown('divSubClinicsBut','trSubClinics','tdSubClinicsTab'); return false;" />
                                                    </td>
                                                    <td style="width: 10px; background-image: url('../Images/Applic/btn_BG_grey_left.gif');
                                                        background-position: top; background-repeat: no-repeat;" class="TDpadding0">
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                        <div id="divSubClinicsBut_Tab" runat="server" style="display: none; height: 100%;">
                                            <table cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td style="width: 8px; height: 26px; background-image: url('../Images/Applic/tab_Right.gif');
                                                        background-position: top; background-repeat: no-repeat" class="TDpadding0">
                                                    </td>
                                                    <td style="background-image: url('../Images/Applic/tab_Middle.gif'); background-position: top;
                                                        background-repeat: repeat-x" class="TDpadding0">
                                                        <asp:Label ID="lblSubClinics" runat="server" Text="יחידות כפופות" EnableTheming="false"
                                                            CssClass="LabelCaptionBlueBold_18"> </asp:Label>
                                                    </td>
                                                    <td style="width: 8px; background-image: url('../Images/Applic/tab_Left.gif'); background-position: top;
                                                        background-repeat: no-repeat" class="TDpadding0">
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                        <asp:TextBox ID="txtTabToBeShown" runat="server" CssClass="DisplayNone" EnableTheming="false"></asp:TextBox>
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td align="left">
                            <asp:ImageButton ID="btnBack" runat="server" ImageUrl="../Images/Applic/btn_back.png"
                                OnClick="btnBack_Click" />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <!-- Dept details -->
        <tr id="trDeptDetails">
            <td style="padding-bottom: 10px;">
                <div class="BackColorBlue" style="height: 29px;">
                    <div style="float: right; margin-top: 5px; margin-right: 3px; padding-left:5px;">
                        <asp:Image ID="imgAttributed_1" runat="server" ToolTip="שירותי בריאות כללית" />
                    </div>
                    <div style="float: right; margin-top: 5px; margin-right: 3px;  background-color:white;">
                        <asp:Image ID="imgNotShowClinicInInternet" runat="server" ToolTip="לא תוצג באינטרנט" ImageUrl="~/Images/Applic/pic_NotShowInInternet.gif" />
                    </div>
                    <div style="float: right; margin-right: 10px; margin-top: 3px;">
                        <asp:Label ID="lblDeptName" EnableTheming="false" CssClass="LabelBoldWhite_18" runat="server"
                            Text=""></asp:Label>
                    </div>
                    <div style="float: left; margin-top: 4px; margin-left: 2px;" id="divUpdateClinicDetails"
                        runat="server">
                        <table cellpadding="0" cellspacing="0">
                            <tr>
                                <td class="buttonRightCorner">
                                </td>
                                <td class="buttonCenterBackground">
                                    <asp:Button ID="btnUpdateClinicDetails" Width="105px" runat="server" CssClass="RegularUpdateButton"
                                        Text="עדכון פרטי יחידה" OnClick="btnUpdateClinicDetails_Click" />
                                </td>
                                <td class="buttonLeftCorner">
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div style="float: left; margin-left: 10px; margin-top: 5px;">
                        <asp:Label runat="server" ID="lblUpdateDate" EnableTheming="false" CssClass="LabelBoldWhite"
                            Text="עדכון אחרון :"></asp:Label>
                        <asp:Label runat="server" ID="lblUpdateDateFld" EnableTheming="false" CssClass="LabelNormalWhite"></asp:Label>
                        <asp:TextBox ID="txtSelectedDeptCode" runat="server" OnTextChanged="txtSelectedDeptCode_TextChanged"
                            Style="display: none"></asp:TextBox>
                    </div>
                </div>
                <table id="tblClinicDetails" style="width: 990px; border: solid 1px #D4EAFB; background-color: White;
                    height: 453px">
                    <tr>
                        <td valign="top" style="padding-top: 8px">
                            <asp:DetailsView ID="dvClinicDetails" SkinID="dvNoAltRow" Width="100%" AutoGenerateRows="False"
                                runat="server" OnDataBinding="dvClinicDetails_DataBinding" OnDataBound="dvClinicDetails_DataBound"
                                GridLines="None" HeaderStyle-CssClass="DisplayNone" HeaderStyle-Width="150px">
                                <Fields>
                                    <asp:BoundField DataField="typeUnitCode" HeaderText="קוד סוג יחידה">
                                        <ItemStyle CssClass="DisplayNone" />
                                    </asp:BoundField>
                                    <asp:TemplateField>
                                        <ItemTemplate>
                                            <table cellpadding="0" cellspacing="0" style="background-color: #F7F7F7; border: 1px solid #dddddd;
                                                width: 980px; margin-bottom: 8px">
                                                <tr>
                                                    <td valign="top" style="width: 900px">
                                                        <table cellpadding="0" cellspacing="0">
                                                            <tr>
                                                                <td style="width: 75px;" class="BorderBottomLight" valign="top">
                                                                    <asp:Label ID="lblUnitTypeNameCaption" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                        runat="server" Text="סוג היחידה:"></asp:Label>
                                                                </td>
                                                                <td style="width: 190px;" class="BorderBottomLight" valign="top">
                                                                    <asp:Label ID="lblUnitTypeName" runat="server" EnableTheming="false" CssClass="RegularLabel"
                                                                        Text='<%# Bind("UnitTypeName") %>'></asp:Label>&nbsp;&nbsp;
                                                                </td>
                                                                <td valign="top" class="BorderBottomLight"  >
                                                                    <asp:Label ID="lblmanagerNameCaption" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                        runat="server" Text="מנהל:" Width="40px"></asp:Label>
                                                                    <asp:Label ID="lblmanagerName" runat="server" EnableTheming="false" CssClass="RegularLabel"
                                                                        Text='<%# Bind("managerName") %>'></asp:Label>&nbsp;&nbsp;&nbsp;

                                                                    <asp:Label ID="lblAdministrativeManagerNameCaption" CssClass="LabelBoldDirtyBlue"
                                                                        EnableTheming="false" runat="server" Text="מנהל אדמיניסטרטיבי:" Width="125px"></asp:Label>
                                                                    <asp:Label ID="lblDeputyHeadOfDepartmentCaption" CssClass="LabelBoldDirtyBlue"
                                                                        EnableTheming="false" runat="server" Text="סגן מנהל מחלקה:" Width="103px"></asp:Label>

                                                                    <asp:Label ID="lblAdministrativeManagerName" runat="server" EnableTheming="false"
                                                                        CssClass="RegularLabel" Text='<%# Bind("administrativeManagerName") %>'></asp:Label>
                                                                    <asp:Label ID="lblDeputyHeadOfDepartment" runat="server" EnableTheming="false"
                                                                        CssClass="RegularLabel" Text='<%# Bind("deputyHeadOfDepartment") %>'></asp:Label>&nbsp;&nbsp;&nbsp;

                                                                    <asp:Label ID="lblSecretaryNameCaption" CssClass="LabelBoldDirtyBlue"
                                                                        EnableTheming="false" runat="server" Text="מזכירה:" Width="45px"></asp:Label>
                                                                    <asp:Label ID="lblSecretaryName" runat="server" EnableTheming="false"
                                                                        CssClass="RegularLabel" Text='<%# Bind("secretaryName") %>'></asp:Label>
                                                                </td>                                                           

                                                            </tr>
                                                            <tr>
                                                                <td colspan="2" align="right">
                                                                    <asp:Panel ID="pnlQueueOrder" runat="server">
                                                                        <table cellpadding="0" cellspacing="0">
                                                                            <tr>
                                                                                <td style="width: 70px">
                                                                                    <asp:Label ID="lblQueueOrderCaption" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                                                        runat="server" Text="אופן הזימון:"></asp:Label>
                                                                                </td>
                                                                                <td style="padding-right: 7px">
                                                                                    <asp:Label ID="lblQueueOrderDescription" runat="server" Visible="false"></asp:Label>
                                                                                </td>
                                                                                <td id="tdDeptQueueOrderMethods" runat="server" valign="bottom" align="center">
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                        <table id='tblQueueOrderPhonesAndHours-0' style="display: none" cellpadding="0" cellspacing="0">
                                                                            <tr>
                                                                                <td dir="ltr" align="right">
                                                                                    <asp:Label ID="lblDeptQueueOrderPhones" runat="server"></asp:Label>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td>
                                                                                    <asp:GridView ID="gvDeptQueueOrderHours" runat="server" EnableTheming="false" GridLines="None"
                                                                                        AutoGenerateColumns="false" HeaderStyle-CssClass="HeaderStyleBlueBold">
                                                                                        <Columns>
                                                                                            <asp:BoundField HeaderText="יום" DataField="ReceptionDayName" ItemStyle-BackColor="#E1F0FC"
                                                                                                ItemStyle-HorizontalAlign="Center" ItemStyle-Width="25px" ItemStyle-CssClass="RegularLabel" />
                                                                                            <asp:TemplateField HeaderText="משעה" ItemStyle-Width="45px">
                                                                                                <ItemTemplate>
                                                                                                    <table cellpadding="0" cellspacing="0" style="width: 100%; border-bottom: 1px solid #BADBFC;
                                                                                                        border-top: 1px solid #BADBFC;">
                                                                                                        <tr>
                                                                                                            <td align="center">
                                                                                                                <asp:Label ID="lblServiceQueueOrderHours_From" CssClass="RegularLabel" runat="server"
                                                                                                                    Text='<%#Eval("FromHour") %>'></asp:Label>
                                                                                                            </td>
                                                                                                        </tr>
                                                                                                    </table>
                                                                                                </ItemTemplate>
                                                                                            </asp:TemplateField>
                                                                                            <asp:TemplateField HeaderText="עד שעה" ItemStyle-Width="45px">
                                                                                                <ItemTemplate>
                                                                                                    <table cellpadding="0" cellspacing="0" style="width: 100%; border-bottom: 1px solid #BADBFC;
                                                                                                        border-top: 1px solid #BADBFC;">
                                                                                                        <tr>
                                                                                                            <td align="center">
                                                                                                                <asp:Label ID="lblServiceQueueOrderHours_To" CssClass="RegularLabel" runat="server"
                                                                                                                    Text='<%#Eval("ToHour") %>'></asp:Label>
                                                                                                            </td>
                                                                                                        </tr>
                                                                                                    </table>
                                                                                                </ItemTemplate>
                                                                                            </asp:TemplateField>
                                                                                        </Columns>
                                                                                    </asp:GridView>
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </asp:Panel>
                                                                </td>
                                                                <td>
                                                                    <asp:Label ID="lblGeriatricsManagerCaption" CssClass="LabelBoldDirtyBlue"
                                                                        EnableTheming="false" runat="server" Text="מנהל סיעוד:" Width="70px"></asp:Label>

                                                                    <asp:Label ID="lblGeriatricsManager" runat="server" EnableTheming="false"
                                                                        CssClass="RegularLabel" Text='<%# Bind("geriatricsManagerName") %>'></asp:Label>
                                                          
                                                                    <asp:Label ID="lblPharmacologyManagerCaption" CssClass="LabelBoldDirtyBlue"
                                                                        EnableTheming="false" runat="server" Text="מנהל בית מרקחת:" Width="107px"></asp:Label>
                                                              
                                                                    <asp:Label ID="lblPharmacologyManager" runat="server" EnableTheming="false"
                                                                        CssClass="RegularLabel" Text='<%# Bind("pharmacologyManagerName") %>'></asp:Label>
                                                         
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                            <table cellpadding="0" cellspacing="0" style=" margin-bottom: 8px;">
                                                <tr>
                                                    <td style="width:480px; vertical-align:top; background-color: #F7F7F7; border: 1px solid #dddddd;">
                                                        <div style="background-color: #F7F7F7; border-bottom: 1px solid #dddddd;">
                                                            <table cellpadding="0" cellspacing="0" style="width:480px;">
                                                                <tr>
                                                                    <td style="width: 110px;" class="BorderBottomLight" valign="top">&nbsp;
                                                                        <asp:Label ID="lblCityNameCaption" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                            runat="server" Text="ישוב:"></asp:Label>
                                                                    </td>
                                                                    <td style="width: 370px;" class="BorderBottomLight" valign="top">
                                                                        <asp:Label ID="lblCityName" runat="server" EnableTheming="false" CssClass="RegularLabel"
                                                                            Text='<%# Bind("cityName") %>'></asp:Label>&nbsp;
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td valign="top" class="BorderBottomLight">&nbsp;
                                                                        <asp:Label ID="lblAddressCaption" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                            runat="server" Text="כתובת:"></asp:Label>
                                                                    </td>
                                                                    <td valign="top" class="BorderBottomLight">
                                                                        <asp:Label ID="lblAddress" runat="server" EnableTheming="false" CssClass="RegularLabel"
                                                                            Text='<%# Bind("simpleAddress") %>'></asp:Label>&nbsp;
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td colspan="2" style="padding: 0px 0px 0px 0px; margin: 0px 0px 0px 0px" valign="top"
                                                                        class="BorderBottomLight">
                                                                        <table cellpadding="0" cellspacing="0">
                                                                            <tr>
                                                                                <td style="width: 50px">&nbsp;
                                                                                    <asp:Label ID="lblFloorCaption" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                                        runat="server" Text="קומה:"></asp:Label>
                                                                                </td>
                                                                                <td style="width: 58px">
                                                                                    <asp:Label ID="lblFloor" runat="server" EnableTheming="false" CssClass="RegularLabel"
                                                                                        Text='<%# Bind("floor") %>'></asp:Label>
                                                                                </td>
                                                                                <td style="width: 35px">
                                                                                    <asp:Label ID="lblFlatCaption" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                                        runat="server" Text="חדר:"></asp:Label>
                                                                                </td>
                                                                                <td >
                                                                                    <asp:Label ID="lblFlat" runat="server" EnableTheming="false" CssClass="RegularLabel"
                                                                                        Text='<%# Bind("flat") %>'></asp:Label>
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </td>

                                                                </tr>
                                                                <tr>
                                                                    <td valign="top" class="BorderBottomLight">&nbsp;
                                                                        <asp:Label ID="lblBuildingCaption" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                            runat="server" Text="בניין:"></asp:Label>
                                                                    </td> 
                                                                    <td valign="top" class="BorderBottomLight">
                                                                        <asp:Label ID="lblBuilding" runat="server" EnableTheming="false" CssClass="RegularLabel"
                                                                            Text='<%# Bind("building") %>'></asp:Label>&nbsp;
                                                                    </td> 
                                                                </tr>
                                                                <tr>
                                                                    <td valign="top">&nbsp;
                                                                        <asp:Label ID="lblAddressCommentCaption" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                            runat="server" Text="הערה לכתובת:"></asp:Label>
                                                                    </td>
                                                                    <td valign="top">
                                                                        <asp:Label ID="lblAddressComment" runat="server" EnableTheming="false" CssClass="RegularLabel"
                                                                            Text='<%# Bind("addressComment") %>'></asp:Label>&nbsp;
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </div>
                                                        <div style="background-color: #FFFFFF; height:9px"></div>
                                                        <div style="background-color: #F7F7F7; border-bottom: 1px solid #dddddd;border-top: 1px solid #dddddd;">
                                                            <table cellpadding="0" cellspacing="0" style="width:480px;">
                                                                <tr>
                                                                    <td style="width: 108px;" class="BorderBottomLight" valign="top">&nbsp;
                                                                        <asp:Label ID="lblPhonesCaption" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                            runat="server" Text="טלפונים:"></asp:Label>
                                                                    </td>
                                                                    <td style="width: 370px;" class="BorderBottomLight" align="right" valign="top" dir="ltr">
                                                                        <asp:GridView ID="gvPhones" runat="server" EnableTheming="false" GridLines="None" AutoGenerateColumns="false" ShowHeader="false">
                                                                            <Columns>
                                                                                <asp:BoundField  DataField="remark" ItemStyle-HorizontalAlign="right" ItemStyle-CssClass="RegularLabel" />
                                                                                <asp:BoundField  DataField="phone" ItemStyle-HorizontalAlign="right" ItemStyle-VerticalAlign="Top" ItemStyle-Width="118px" ItemStyle-CssClass="RegularLabel" />
                                                                            </Columns>
                                                                        </asp:GridView>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td valign="top" class="BorderBottomLight">&nbsp;
                                                                        <asp:Label ID="lblFaxCaption" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                            runat="server" Text="פקס:"></asp:Label>
                                                                    </td>
                                                                    <td valign="top" align="right" dir="ltr" class="BorderBottomLight">
                                                                        <asp:GridView ID="gvFax" runat="server" EnableTheming="false" GridLines="None" AutoGenerateColumns="false" ShowHeader="false">
                                                                            <Columns>
                                                                                <asp:BoundField  DataField="remark" ItemStyle-HorizontalAlign="right" ItemStyle-CssClass="RegularLabel" />
                                                                                <asp:BoundField  DataField="phone" ItemStyle-HorizontalAlign="right" ItemStyle-VerticalAlign="Top" ItemStyle-Width="118px" ItemStyle-CssClass="RegularLabel" />
                                                                            </Columns>
                                                                        </asp:GridView>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td valign="top" class="BorderBottomLight">&nbsp;
                                                                        <asp:Label ID="lblWhatsAppCaption" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                            runat="server" Text="וואטספ:"></asp:Label>
                                                                    </td>
                                                                    <td valign="top" align="right" dir="ltr" class="BorderBottomLight">
                                                                        <asp:GridView ID="gvWhatsApp" runat="server" EnableTheming="false" GridLines="None" AutoGenerateColumns="false" ShowHeader="false">
                                                                            <Columns>
                                                                                <asp:BoundField  DataField="remark" ItemStyle-HorizontalAlign="right" ItemStyle-CssClass="RegularLabel" />
                                                                                <asp:BoundField  DataField="phone" ItemStyle-HorizontalAlign="right" ItemStyle-VerticalAlign="Top" ItemStyle-Width="118px" ItemStyle-CssClass="RegularLabel" />
                                                                            </Columns>
                                                                        </asp:GridView>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td valign="top">&nbsp;
                                                                        <asp:Label ID="lblEmailCaption" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                            runat="server" Text="e-mail:"></asp:Label>
                                                                    </td>
                                                                    <td valign="top">
                                                                        <table cellpadding="0" cellspacing="0">
                                                                            <tr>
                                                                                <td dir="ltr">
                                                                                    <asp:Label ID="lblEmail" runat="server" EnableTheming="false" CssClass="RegularLabel"
                                                                                        Text='<%# Bind("email") %>'></asp:Label>&nbsp;
                                                                                </td>
                                                                                <td>
                                                                                    <asp:Image ID="imgNotShowEmailInInternet" runat="server" ToolTip="לא תוצג באינטרנט"
                                                                                        ImageUrl="../Images/Applic/pic_NotShowInInternet.gif" Visible='<%# !Convert.ToBoolean(Eval("showEmailInInternet")) %>' />
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </td>
                                                                </tr>                                                            
                                                            </table>
                                                        </div>
                                                        <div style="background-color: #FFFFFF; height:9px"></div>
                                                        <div style="background-color: #F7F7F7; border-bottom: 1px solid #dddddd;border-top: 1px solid #dddddd;">
                                                            <table cellpadding="0" cellspacing="0" style="width: 100%; margin-bottom: 8px">
                                                                <tr>
                                                                    <td style="width: 110px;" class="BorderBottomLight" valign="top">&nbsp;
                                                                        <asp:Label ID="lblTransportationCaption" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                            runat="server" Text="תחבורה:"></asp:Label>
                                                                    </td>
                                                                    <td style="width: 245px;" class="BorderBottomLight" valign="top">
                                                                        <asp:Label ID="lblTransportation" runat="server" EnableTheming="false" CssClass="RegularLabel"
                                                                            Text='<%# Bind("transportation") %>'></asp:Label>&nbsp;
                                                                    </td>
                                                                    <td style="width: 70px;" class="BorderBottomLight" valign="top">
                                                                        <asp:Label ID="lblHandicappedCaption" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                            runat="server" Text="הערכות לנכים:"></asp:Label>
                                                                    </td>
                                                                    <td class="BorderBottomLight" valign="top">
                                                                        <div>
                                                                            <table cellpadding="0" cellspacing="0">
                                                                                <tr>
                                                                                    <td valign="top">
                                                                                        <asp:Label ID="lblHandicapped" runat="server" EnableTheming="false" CssClass="RegularLabel"></asp:Label>&nbsp;
                                                                                    </td>
                                                                                    <td style="padding-left: 10px;" runat="server" valign="top" class="LooksLikeHRef"
                                                                                        onclick="ToggleHandicapped()" id="tdHandicappedCaption">
                                                                                        כן
                                                                                    </td>
                                                                                    <td id="tdGvHandicapped" style="display: none;">
                                                                                        <div style="padding-right: 5px; position: absolute; z-index: 5; width: 100px; background-color: White;
                                                                                            border-top: solid 1px #555555; border-left: solid 1px #555555; border-bottom: solid 2px #888888;
                                                                                            border-right: solid 2px #888888;">
                                                                                            <asp:GridView ID="gvHandicapped" GridLines="None" runat="server" EnableTheming="false"
                                                                                                AutoGenerateColumns="True">
                                                                                                <RowStyle CssClass="ListItemNormalBlack" />
                                                                                            </asp:GridView>
                                                                                        </div>
                                                                                    </td>
                                                                                </tr>
                                                                            </table>
                                                                        </div>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td valign="top">&nbsp;
                                                                        <asp:Label ID="lblParkingCaption" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                            runat="server" Text="חניה:"></asp:Label>
                                                                    </td>
                                                                    <td valign="top">
                                                                        <asp:Label ID="lblParking" runat="server" EnableTheming="false" CssClass="RegularLabel"
                                                                            Text='<%# Bind("parking") %>'></asp:Label>&nbsp;
                                                                    </td>
                                                                    <td valign="top">
                                                                    </td>
                                                                    <td valign="top">
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </div>
                                                        <div style="background-color: #FFFFFF; height:9px"></div>
                                                        <div style="background-color: #F7F7F7; border-top: 1px solid #dddddd;">
                                                            <table cellpadding="0" cellspacing="0" style="width: 100%; margin-bottom: 8px">
                                                                <tr>
                                                                    <td style="width: 110px;" class="BorderBottomLight" valign="top">&nbsp;
                                                                        <asp:Label ID="lblDistrictNameCaption" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                            runat="server" Text="מחוז:"></asp:Label>
                                                                    </td>
                                                                    <td style="width: 245px;" class="BorderBottomLight" valign="top">
                                                                        <div onclick="SetDeptCode('<%# Eval("districtCode") %>')" style="width:243px">
                                                                            <asp:Label ID="lblDistrictName" runat="server" EnableTheming="false" CssClass="LooksLikeHRef"
                                                                                Text='<%# Bind("districtName") %>'></asp:Label>&nbsp;
                                                                        </div>
                                                                    </td>
                                                                    <td style="width: 65px;" class="BorderBottomLight" valign="top">
                                                                        <asp:Label ID="lblPopulationSectorDescriptionCaption" CssClass="LabelBoldDirtyBlue"
                                                                            EnableTheming="false" runat="server" Text="מגזר:"></asp:Label>
                                                                    </td>
                                                                    <td class="BorderBottomLight" valign="top">
                                                                        <asp:Label ID="lblPopulationSectorDescription" runat="server" EnableTheming="false"
                                                                            CssClass="RegularLabel" Text='<%# Bind("populationSectorDescription") %>'></asp:Label>&nbsp;
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td valign="top" class="BorderBottomLight">&nbsp;
                                                                        <asp:Label ID="lblAdditionalDistrictsCaption" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                            runat="server" Text="מחוזות נוספים:"></asp:Label>                                                    
                                                                    </td>
                                                                    <td colspan="3" class="BorderBottomLight">
                                                                        <asp:Label ID="lblAdditionalDistricts" runat="server" EnableTheming="false" CssClass="RegularLabel"
                                                                            Text='<%# Bind("additionaDistrictNames") %>'></asp:Label>&nbsp;                                                    
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td valign="top" class="BorderBottomLight">&nbsp;
                                                                        <asp:Label ID="lblAdministrationNameCaption" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                            runat="server" Text="מנהלת:"></asp:Label>
                                                                    </td>
                                                                    <td valign="top" class="BorderBottomLight">
                                                                        <div onclick="SetDeptCode('<%# Eval("AdministrationCode") %>')" style="width:243px">
                                                                            <asp:Label ID="lblAdministrationName" CssClass="LooksLikeHRef" EnableTheming="False"
                                                                                runat="server" Text='<%# Eval("AdministrationName") %>'></asp:Label>
                                                                            &nbsp;
                                                                        </div>
                                                                    </td>
                                                                    <td valign="top" class="BorderBottomLight">
                                                                        <asp:Label ID="lblDeptCodeCaption" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                            runat="server" Text="קוד יחידה:"></asp:Label>
                                                                    </td>
                                                                    <td valign="top" class="BorderBottomLight">
                                                                        <asp:Label ID="lblDeptCode" runat="server" EnableTheming="false" CssClass="RegularLabel"
                                                                            Text='<%# Bind("deptCode") %>'></asp:Label>&nbsp;
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td valign="top" class="BorderBottomLight">&nbsp;
                                                                        <asp:Label ID="lblSubAdministrationNameCaption" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                            runat="server" Text="כפיפות ניהולית:"></asp:Label>
                                                                    </td>
                                                                    <td valign="top" class="BorderBottomLight">
                                                                        <div onclick="SetDeptCode('<%# Eval("subAdministrationCode") %>')" style="width:243px">
                                                                            <asp:Label ID="lblSubAdministrationName" runat="server" CssClass="LooksLikeHRef"
                                                                                EnableTheming="False" Text='<%# Eval("subAdministrationName") %>'></asp:Label>
                                                                            &nbsp;
                                                                        </div>
                                                                    </td>
                                                                    <td valign="top" class="BorderBottomLight">
                                                                        <asp:Label ID="lblSimul228Caption" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                            runat="server" Text="קוד ישן:"></asp:Label>
                                                                    </td>
                                                                    <td valign="top" class="BorderBottomLight">
                                                                        <asp:Label ID="lblSimul228" runat="server" EnableTheming="false" CssClass="RegularLabel"
                                                                            Text='<%# Bind("Simul228") %>'></asp:Label>&nbsp;
                                                                    </td>
                                                                </tr>
                                                                    <td valign="top" class="BorderBottomLight">&nbsp;
                                                                        <asp:Label ID="lblParentClinicNameCaption" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                            runat="server" Text="מרפאת אם:"></asp:Label>
                                                                    </td>
                                                                    <td valign="top" class="BorderBottomLight">
                                                                        <div onclick="SetDeptCode('<%# Eval("parentClinicCode") %>')" style="width:243px">
                                                                            <asp:Label ID="lblParentClinicName" runat="server" CssClass="LooksLikeHRef"
                                                                                EnableTheming="False" Text='<%# Eval("parentClinicName") %>'></asp:Label>
                                                                            &nbsp;
                                                                        </div>
                                                                    </td>
                                                                    <td valign="top" class="BorderBottomLight">

                                                                    </td>
                                                                    <td valign="top" class="BorderBottomLight">
            
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td valign="top">&nbsp;
                                                                        <asp:Label ID="lblDeptLevelCaption" runat="server" CssClass="LabelBoldDirtyBlue"
                                                                            EnableTheming="false" Text="רמת שירות:"></asp:Label>
                                                                    </td>
                                                                    <td valign="top">
                                                                        <asp:Label ID="lblDeptLevel" runat="server" Text='<%# Eval("deptLevelDescription") %>'></asp:Label>
                                                                        &nbsp;
                                                                    </td>
                                                                    <td valign="top">
                                                                        <asp:Label ID="lblstatusDescriptionCaption" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                            runat="server" Text="סטטוס:"></asp:Label>
                                                                    </td>
                                                                    <td valign="top">
                                                                        <asp:Label ID="lblstatusDescription" runat="server" EnableTheming="false" CssClass="RegularLabel"
                                                                            Text='<%# Bind("statusDescription") %>'></asp:Label>&nbsp;
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td valign="top" colspan="2">&nbsp;
                                                                        <asp:Label ID="lbAllowContactHospitalUnit" runat="server" CssClass="LabelBoldDirtyBlue"
                                                                            EnableTheming="false" Text="לאפשר פניה ליחידה:"></asp:Label>
                                                                        <asp:CheckBox ID="cbAllowContactHospitalUnit" runat="server" Enabled="false" />
                                                                    </td>
                                                                    <td>
                                                                    </td>
                                                                    <td>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </div>
                                                    </td>
                                                    <td style="width:9px"><!-- interm --></td>
                                                    <td style="width:480px; vertical-align:top; background-color: #F7F7F7; border: 1px solid #dddddd;">
                                                        <div style="background-color: #F7F7F7; border-bottom: 1px solid #dddddd;">
                                                            <table cellpadding="0" cellspacing="0">
                                                                <tr>
                                                                    <td style="width: 90px; padding-right: 5px" valign="top">
                                                                        <div style="border-bottom:1px solid #808080; width:90px">
                                                                        <asp:Label ID="lblRemarksCaption" CssClass="LabelBoldDirtyBlue_14" EnableTheming="false"
                                                                            runat="server" Text="הערות ליחידה:"></asp:Label>
                                                                        </div>
                                                                    </td>
                                                                    <td id="tdUpdateClinicRemarks" style="padding-left: 5px" align="left" valign="top"
                                                                        runat="server">
                                                                        <table cellpadding="0" cellspacing="0">
                                                                            <tr>
                                                                                <td class="buttonRightCorner">
                                                                                </td>
                                                                                <td align="center" class="buttonCenterBackground">
                                                                                    <asp:Button ID="btnUpdateClinicRemarks" runat="server" CssClass="RegularUpdateButton"
                                                                                        Text="עדכון הערות" Width="85px" OnClick="btnUpdateClinicRemarks_Click" />
                                                                                </td>
                                                                                <td class="buttonLeftCorner">
                                                                                </td>

                                                                                <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                                    background-position: bottom left;">
                                                                                    &nbsp;
                                                                                </td>
                                                                                <td align="center" style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                                    background-repeat: repeat-x; background-position: bottom;">
                                                                                    <asp:Button ID="btnAddRemarks" Width="95px" runat="server" Text="הוספת הערות" CssClass="RegularUpdateButton"
                                                                                        CausesValidation="false" OnClick="btnAddRemarks_Click"></asp:Button>
                                                                                </td>
                                                                                <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                                                    background-repeat: no-repeat;">
                                                                                    &nbsp;
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td colspan="2" valign="top">
                                                                        <asp:GridView ID="gvRemarks" runat="server" SkinID="SimpleGridViewNoEmtyDataText"
                                                                            Width="450px" EmptyDataText="אין הערות לרופא\עובד" AutoGenerateColumns="False"
                                                                            HeaderStyle-CssClass="DisplayNone" OnRowDataBound="gvRemarks_RowDataBound">
                                                                            <Columns>
                                                                                <asp:TemplateField>
                                                                                    <ItemTemplate>
                                                                                        <table cellpadding="0" cellspacing="0">
                                                                                            <tr>
                                                                                                <td style="margin: 0px 0px 0px 0px; padding: 0px 0px 0px 0px" valign="top">
                                                                                                    <div style="width: 18px;">
                                                                                                        <asp:Image ID="imgInternet" runat="server" />
                                                                                                    </div>
                                                                                                </td>
                                                                                                <td style="vertical-align:top">
                                                                                                    &diams;&nbsp;
                                                                                                </td>
                                                                                                <td>
                                                                                                    <asp:Label ID="lblRemark" runat="server" Text='<% #Bind("RemarkText")%>'></asp:Label>
                                                                                                </td>
                                                                                            </tr>
                                                                                        </table>
                                                                                    </ItemTemplate>
                                                                                </asp:TemplateField>
                                                                            </Columns>
                                                                        </asp:GridView>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </div>
                                                        <div style="background-color: #FFFFFF; height:9px"></div>
                                                        <div style="background-color: #F7F7F7; border-top: 1px solid #dddddd;">
                                                            <table cellpadding="0" cellspacing="0" style="width: 480px; height:100%">
                                                                <tr>
                                                                    <td style="padding-right: 5px" valign="top">
                                                                        <div style="border-bottom:1px solid #808080; width:165px">
                                                                            <asp:Label ID="Label1" CssClass="LabelBoldDirtyBlue_14" EnableTheming="false"
                                                                                runat="server" Text="הערות לנותני שירות ביחידה:"></asp:Label>
                                                                        </div>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td style="padding-right:10px; height:100%">
                                                                        <asp:GridView ID="gvEmployeeAndServiceRemarks" runat="server" SkinID="SimpleGridViewNoEmtyDataText"
                                                                                AutoGenerateColumns="False" HeaderStyle-CssClass="DisplayNone" OnRowDataBound="gvEmployeeAndServiceRemarks_RowDataBound"
                                                                                Width="470px">
                                                                            <Columns>
                                                                                <asp:TemplateField>
                                                                                    <ItemTemplate>
                                                                                        <table style="padding:0">
                                                                                            <tr>
                                                                                                <td colspan="3">
                                                                                                    <asp:Label ID="lblEmployeeName" runat="server" Text='<% #Bind("EmployeeName")%>' CssClass="BlueBoldLabel" EnableTheming="false"></asp:Label>
                                                                                                </td>
                                                                                            </tr>
                                                                                            <tr>
                                                                                                <td style="margin: 0px 0px 0px 0px; padding: 0px 0px 0px 0px; vertical-align:top">
                                                                                                    <div style="width: 15px;">
                                                                                                        <asp:Image ID="imgInternet" runat="server" />
                                                                                                    </div>
                                                                                                </td>
                                                                                                <td valign="top">
                                                                                                    &diams;&nbsp;
                                                                                                </td>
                                                                                                <td><div style="float:right">
                                                                                                    <asp:Label ID="lblService" runat="server"  CssClass="LabelCaptionGreenBold_13" Text='<% #Bind("ServiceName")%>' EnableTheming="false"></asp:Label>
                                                                                                    </div>
                                                                                                    <div style="float:right">
                                                                                                    <asp:Label ID="lblRemark" runat="server" Text='<% #Bind("Remark")%>'></asp:Label>
                                                                                                    </div>
                                                                                                </td>
                                                                                            </tr>
                                                                                        </table>
                                                                                    </ItemTemplate>
                                                                                </asp:TemplateField>
                                                                            </Columns>
                                                                        </asp:GridView>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </table>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="districtCode" HeaderText="קוד מחוז" Visible="False" />
                                </Fields>
                                <FieldHeaderStyle CssClass="DisplayNone" />
                                <HeaderStyle CssClass="DisplayNone" Width="150px"></HeaderStyle>
                            </asp:DetailsView>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <!-- Dept reception -->
        <tr id="trDeptReception">
            <td style="padding-bottom: 10px;">
                <div class="BackColorBlue" style="height: 29px;">
                    <div style="float: right; margin-top: 5px; margin-right: 3px;">
                        <asp:Image ID="imgAttributed_2" runat="server" ToolTip="שירותי בריאות כללית" />
                    </div>
                    <div style="float: right; margin-right: 10px; margin-top: 3px;">
                        <asp:Label ID="lblDeptName_Reception" EnableTheming="false" CssClass="LabelBoldWhite_18"
                            runat="server" Text=""></asp:Label>
                        &nbsp;
                        <asp:Label ID="lblAddress_Reception" EnableTheming="false" CssClass="LabelBoldWhite_18"
                            runat="server" Text=""></asp:Label>
                    </div>
                    <div style="float: left; margin-top: 4px; margin-left: 2px;" id="divUpdateClinicReception"
                        runat="server">
                        <table cellpadding="0" cellspacing="0">
                            <tr>
                                <td class="buttonRightCorner">
                                </td>
                                <td class="buttonCenterBackground">
                                    <asp:Button runat="server" Width="110px" ID="btnUpdateReception" CssClass="RegularUpdateButton"
                                        Text="עדכון שעות קבלה" OnClick="btnUpdateReception_Click" />
                                </td>
                                <td class="buttonLeftCorner">
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div style="float: left; margin-left: 10px; margin-top: 5px;">
                        <asp:Label runat="server" ID="lblUpdateDate_Reception" EnableTheming="false" CssClass="LabelBoldWhite"
                            Text="עדכון אחרון :"></asp:Label>
                        <asp:Label runat="server" ID="lblUpdateDateFld_Reception" EnableTheming="false" CssClass="LabelNormalWhite"></asp:Label>
                    </div>
                </div>
                <table id="tblDeptReception" style="width: 990px; border: solid 1px #D4EAFB; background-color: White;">  
                    
                    <tr>
                        <td>
                            <uc:ucDeptReceptionAndRemarks MarginRightOtherReceptionHoursDiv="20px" ID="ucDeptReceptionAndRemarks" runat="server" />
                        </td>
                    </tr>
                    
                </table>
            </td>
        </tr>
        <!-- Doctors & Doctor's reception -->
        <tr id="trDoctors">
            <td style="padding-bottom: 10px;">
                
                <iframe id="frmDeptServices" runat="server" width="990" height="670" frameborder="0" marginheight="0" marginwidth="0"
                                    scrolling="no"></iframe>
                
            </td>
        </tr>
        <!-- Medical Aspects -->
        <tr id="trMedicalAspects">
            <td valign="top">
                <iframe id="frmMedicalAspects" runat="server" width="990" height="680" frameborder="0" marginheight="0" marginwidth="0"
                                    scrolling="no"></iframe>
            </td>
        </tr>
        <!-- mushlam services -->
        <tr id="trMushlamServices">
            <td valign="top">
                <iframe id="frmMushlamServices" runat="server" width="990" height="400" frameborder="0" marginheight="0" marginwidth="0"
                                    scrolling="no"></iframe>
            </td>
        </tr>
        <!-- subClinic List -->
        <tr id="trSubClinics">
            <td style="padding-bottom: 10px;">
                <iframe id="frmSubClinics" runat="server" width="990" height="650" frameborder="0" marginheight="0" marginwidth="0"
                        scrolling="no"></iframe>
            </td>
        </tr>
    </table>
    
</asp:Content>
