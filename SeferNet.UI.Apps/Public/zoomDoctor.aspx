<%@ Page Language="C#" AutoEventWireup="true" Title="פרטי נותן שירות" EnableEventValidation="false"
    MasterPageFile="~/SeferMasterPageIEwide.master" Inherits="zoomDoctor" Codebehind="zoomDoctor.aspx.cs" %>

<%@ MasterType VirtualPath="~/SeferMasterPageIEwide.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="pageContent" runat="server">
    <script type="text/javascript">


        function toggleBlock(contentPanelId, fieldSetId) {
            var contentPanel = document.getElementById(contentPanelId);
            var fldSet = document.getElementById(fieldSetId);
            if (contentPanel != null && fldSet != null) {
                if (contentPanel.style.display != "none") {
                    contentPanel.style.display = "none";
                    fldSet.style.border = "0px";
                    window.event.srcElement.title = "לחץ לפתיחת רשימה";
                }
                else {
                    contentPanel.style.display = "inline";
                    fldSet.style.border = "1px";
                    fldSet.style.borderStyle = "solid";
                    fldSet.style.borderColor = "#BEBCB7";
                    window.event.srcElement.title = "לחץ לסגירת רשימה";
                }
            }
        }

        function showBlock() {
            var contentPanel = document.getElementById('tblDoctorDetails');
            var fldSet = document.getElementById('fldSetDoctorDetails');
            if (contentPanel != null && fldSet != null)
                showFieldSet(contentPanel, fldSet);

            contentPanel = document.getElementById('divGvClinics');
            fldSet = document.getElementById('fldSetClinics');
            if (contentPanel != null && fldSet != null)
                showFieldSet(contentPanel, fldSet);

            contentPanel = document.getElementById('divGvDoctorHours');
            fldSet = document.getElementById('fldSetDoctorHours');
            if (contentPanel != null && fldSet != null)
                showFieldSet(contentPanel, fldSet);

            contentPanel = document.getElementById('divGvDoctorAbsence');
            fldSet = document.getElementById('fldSetDoctorAbsence');
            if (contentPanel != null && fldSet != null)
                showFieldSet(contentPanel, fldSet);

        }

        function showFieldSet(contentPanel, fldSet) {
            contentPanel.style.display = "inline";
            fldSet.style.border = "1px";
            fldSet.style.borderStyle = "solid";
            fldSet.style.borderColor = "#BEBCB7";
            window.event.srcElement.title = "לחץ לסגירת רשימה";
        }

        function DisplaySection(sectionId) {
            hideAllSections();

            var prefix = "ctl00_pageContent_";
            var sectionFullId = prefix + sectionId;

            var section = document.getElementById(sectionFullId);
            if (section != null) {
                section.style.display = "inline";
                showBlock();

                var btn = window.event.srcElement;

                btn.style.backgroundColor = "#3B3E99";
            }

        }

        /// new section 12/02/2009
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
                SetTabToBeShown('divEmployeeDetailsBut', 'trEmployeeDetails', 'tdEmployeeDetailsTab', 'tb_EmployeeDetails');
            }

        }

        function NoProfessionLicence() {
            alert("לא נמצא רשיון לנותן שירות זה, יש לעדכן את הרשיון בסאפ ולנסות שוב");
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

            var section = document.getElementById(sectionFullId);
            var tab = document.getElementById(tabFullId);
            var btn = document.getElementById(btnFullId);

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

        function hideAllTabSections() {
            var trEmployeeDetails = document.getElementById('<%=trEmployeeDetails.ClientID%>');
            var trEmployeeHours = document.getElementById('<%=trEmployeeHours.ClientID%>');

            var divEmployeeDetailsBut = document.getElementById('<%=divEmployeeDetailsBut.ClientID%>');
            var divEmployeeHoursBut = document.getElementById('<%=divEmployeeHoursBut.ClientID%>');

            var divEmployeeDetailsBut_Tab = document.getElementById('<%=divEmployeeDetailsBut_Tab.ClientID%>');
            var divEmployeeHoursBut_Tab = document.getElementById('<%=divEmployeeHoursBut_Tab.ClientID%>');

            divEmployeeDetailsBut.style.display = "inline";
            divEmployeeHoursBut.style.display = "inline";

            divEmployeeDetailsBut_Tab.style.display = "none";
            divEmployeeHoursBut_Tab.style.display = "none";

            if (trEmployeeDetails != null) {
                trEmployeeDetails.style.display = "none";
            }
            if (trEmployeeHours != null) {
                trEmployeeHours.style.display = "none";
            }

        }

        function ToggleQueueOrderPhonesAndHours(ToggleID) {
            var tblID = "tblQueueOrderPhonesAndHours-" + ToggleID;

            var tblQueueOrderPhonesAndHours = document.getElementById(tblID);
            var divQueueOrderPhonesAndHours = document.getElementById('divQueueOrderPhonesAndHours');
            var imgID = "imgOrderMethod-" + ToggleID;
            var shiftY = 15;
            var closeLink = "<tr><td align='left' style='padding-left:5px'><img style='cursor:hand' src='../Images/Applic/btn_ClosePopUpBlue.gif' onclick='javascript:closeQueueOrderPhonesAndHoursPopUp()' /> </td></tr>";

            var yPos = event.clientY + document.body.scrollTop;
            var xPos = event.clientX + document.body.scrollLeft - 20;


            var divWithScrollBar = document.getElementById("divWithScrollBar");

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
            divQueueOrderPhonesAndHours.style.left = xPos + 20;


            divQueueOrderPhonesAndHours.style.display = "inline";
        }

        function closeQueueOrderPhonesAndHoursPopUp() {
            var divPopUp = document.getElementById("divQueueOrderPhonesAndHours");

            divPopUp.style.display = "NONE";
        }

        function getOBJposition(id, dim) {
            var obj = document.getElementById(id);
            var top = 0; var left = 0;

            if (obj != null || dim.length > 0) {
                dim = dim.toLowerCase();
                while (obj.tagName.length > 0) {
                    if (obj.tagName.toUpperCase() == "BODY") break;
                    if (dim == "top" && obj.tagName != "TR" && obj.tagName != "TBODY") {
                        top += obj.offsetTop;
                        top -= obj.clientTop;
                    }
                    else if (dim == "left" && obj.tagName != "TBODY") {
                        left += obj.offsetLeft;
                        left -= obj.clientLeft;
                    }
                    obj = obj.parentNode;
                }

                if (dim == "top") return top;
                else if (dim == "left") return left;
            }
            else {
                top = left = width = height = -1;
                return false;
            }
        }

        function OpenDoctorReceptionWindow(deptEmployeeID, serviceCode, expirationDate) {
            if (serviceCode == -1)
                var strUrl = "DoctorReceptionPopUp.aspx?deptEmployeeID=" + deptEmployeeID + "&expirationDate=" + expirationDate;
            else
                var strUrl = "DoctorReceptionPopUp.aspx?deptEmployeeID=" + deptEmployeeID + "&serviceCode=" + serviceCode + "&expirationDate=" + expirationDate;

            var dialogWidth = 680;
            var dialogHeight = 680;
            var title = "שעות קבלה לנותן שירות ביחידה";

            OpenJQueryDialog(strUrl, dialogWidth, dialogHeight, title);
        }

        function OpenEmployeeExpirationReceptionWindow(employeeID, expirationDate) {
            var strUrl = "EmployeeReceptionExpirationPopUp.aspx?employeeID=" + employeeID + "&expirationDate=" + expirationDate;
            var dialogWidth = 860;
            var dialogHeight = 400;
            var title = "שעות קבלה של רופא";
            OpenJQueryDialog(strUrl, dialogWidth, dialogHeight, title);
        }

        function AddDeptToEmployee(multiSelect, requireUserPermisions) {
            var strUrl = "../Public/SelectDepts.aspx?multiSelect=" + multiSelect + "&requireUserPermisions=" + requireUserPermisions;
            var dialogWidth = 610;
            var dialogHeight = 580;
            var title = "בחירת יחידות";
            OpenJQueryDialog(strUrl, dialogWidth, dialogHeight, title);
        }

        function Open_FrmSelectTemplate(deptCodes, currentDeptCode) {
            //alert("ZoomDoctor: Open_FrmSelectTemplate");
           // document.getElementById('<%= txtDeptsToBeAdded.ClientID %>').innerText = deptCodes;
            //$("#txtDeptsToBeAdded").val(deptCodes);
            //alert(deptCodes);
            //$("#btnDoPostBack").click();
            window.parent.DoSubmit();
            //window.document.forms(0).submit();
        }

        function OpenReceptionWindowDialog(deptCode, ServiceCodes) {
            var dialogWidth = 880;
            var dialogHeight = 700;
            var title = "שעות קבלה של יחידה";

            var url = "DeptReceptionPopUp.aspx?deptCode=" + deptCode + "&ServiceCodes=" + ServiceCodes;

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);
        }

    </script>
    <div id="divQueueOrderPhonesAndHours" style="position: absolute; display: none; z-index: 10;
        background-color: White;">
    </div>
    <!----- tab buttons ----->
    <table cellpadding="0" cellspacing="0" width="1040px" style="background-image: url('../Images/GradientVerticalBlueAndWhite.jpg');
        background-repeat: repeat-x;">
        <tr>
            <td style="width: 100%; background-image: url('../Images/Applic/tab_WhiteBlueBackGround.jpg');
                background-position: bottom; background-repeat: repeat-x; margin: 0px 0px 0px 0px;
                padding: 0px 0px 6px 0px;">
                <table cellpadding="0" cellspacing="0" border="0" width="1020px" dir="rtl">
                    <tr>
                        <td>
                            <table cellpadding="0" cellspacing="0" border="0">
                                <tr>
                                    <%----------- EmployeeDetailsTab -------------%>
                                    <td id="tdEmployeeDetailsTab" runat="server" align="center" valign="bottom" style="margin: 0px 0px 0px 0px;
                                        padding: 0px 10px 0px 0px;">
                                        <div id="divEmployeeDetailsBut" runat="server" style="display: none; width: 100%;
                                            height: 100%;">
                                            <table cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td style="width: 10px; height: 22px; background-image: url('../Images/Applic/btn_BG_grey_right.gif');
                                                        background-position: top; background-repeat: no-repeat;" class="TDpadding0">
                                                    </td>
                                                    <td valign="top" style="background-image: url('../Images/Applic/btn_BG_grey_middle.gif');
                                                        background-position: top; background-repeat: repeat-x;" class="TDpadding0">
                                                        <asp:Button ID="btnEmployeeDetailsTab" runat="server" Height="18px" Width="115px"
                                                            Text="פרטי נותן שירות" CssClass="TabButton_14" OnClientClick="SetTabToBeShown('divEmployeeDetailsBut','trEmployeeDetails','tdEmployeeDetailsTab','tb_EmployeeDetails'); return false;" />
                                                    </td>
                                                    <td style="width: 10px; background-image: url('../Images/Applic/btn_BG_grey_left.gif');
                                                        background-position: top; background-repeat: no-repeat;" class="TDpadding0">
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                        <div id="divEmployeeDetailsBut_Tab" runat="server" style="display: none; height: 100%;
                                            width: 100%;">
                                            <table cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td style="width: 8px; height: 26px; background-image: url('../Images/Applic/tab_Right.gif');
                                                        background-position: top; background-repeat: no-repeat" class="TDpadding0">
                                                    </td>
                                                    <td style="background-image: url('../Images/Applic/tab_Middle.gif'); background-position: top;
                                                        background-repeat: repeat-x" class="TDpadding0">
                                                        <asp:Label ID="lblTabEmployeeDetails" runat="server" Text="פרטי נותן שירות" EnableTheming="false"
                                                            CssClass="LabelCaptionBlueBold_18">
                                                        </asp:Label>
                                                    </td>
                                                    <td style="width: 8px; background-image: url('../Images/Applic/tab_Left.gif'); background-position: top;
                                                        background-repeat: no-repeat" class="TDpadding0">
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                    </td>
                                    <%----------- EmployeeHoursTab -------------%>
                                    <td id="tdEmployeeHoursTab" runat="server" valign="bottom" align="center" style="margin: 0px 0px 0px 0px;
                                        padding: 0px 1px 0px 0px;">
                                        <div id="divEmployeeHoursBut" runat="server" style="display: none; width: 100%; height: 100%;">
                                            <table cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td style="width: 10px; height: 22px; background-image: url('../Images/Applic/btn_BG_grey_right.gif');
                                                        background-position: top; background-repeat: no-repeat;" class="TDpadding0">
                                                    </td>
                                                    <td valign="top" style="background-image: url('../Images/Applic/btn_BG_grey_middle.gif');
                                                        background-position: top; background-repeat: repeat-x;" class="TDpadding0">
                                                        <asp:Button ID="btnEmployeeHoursTab" runat="server" Height="18px" Width="100px" Text="שעות קבלה"
                                                            CssClass="TabButton_14" OnClientClick="SetTabToBeShown('divEmployeeHoursBut','trEmployeeHours','tdEmployeeHoursTab','tb_EmployeeHours'); return false;" />
                                                    </td>
                                                    <td style="width: 10px; background-image: url('../Images/Applic/btn_BG_grey_left.gif');
                                                        background-position: top; background-repeat: no-repeat;" class="TDpadding0">
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                        <div id="divEmployeeHoursBut_Tab" runat="server" style="display: none; height: 100%;
                                            width: 100%;">
                                            <table cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td style="width: 8px; height: 26px; background-image: url('../Images/Applic/tab_Right.gif');
                                                        background-position: top; background-repeat: no-repeat" class="TDpadding0">
                                                    </td>
                                                    <td style="background-image: url('../Images/Applic/tab_Middle.gif'); background-position: top;
                                                        background-repeat: repeat-x" class="TDpadding0">
                                                        <asp:Label ID="lblTabEmployeeHours" runat="server" Text="שעות קבלה" EnableTheming="false"
                                                            CssClass="LabelCaptionBlueBold_18"></asp:Label>
                                                    </td>
                                                    <td style="width: 8px; background-image: url('../Images/Applic/tab_Left.gif'); background-position: top;
                                                        background-repeat: no-repeat" class="TDpadding0">
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                    </td>
                                    <td>
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
        <!-- Employee details -->
        <tr id="trEmployeeDetails" runat="server">
            <td style="padding-bottom: 10px; padding-left: 5px; padding-right: 5px;">
                <table align="right" id="tblDoctorDetails" style="width:1040px; border: solid 1px #D4EAFB;
                    background-color: White">
                    <tr>
                        <td style="background-color: #2889E4;">
                            <table cellpadding="0" cellspacing="0" width="100%" dir="rtl">
                                <tr>
                                    <td style="height: 28px; padding-right: 5px;">
                                        <asp:Label ID="lblName" runat="server" EnableTheming="false" CssClass="LabelBoldWhite_18"></asp:Label>
                                        <asp:Label ID="lblExpert" runat="server" EnableTheming="false" CssClass="LabelBoldWhite_18"></asp:Label>
                                        <asp:TextBox ID="txtSelectedDeptCode" runat="server" Style="display: none"></asp:TextBox>
                                    </td>
                                    <td align="left" style="padding: 0px 0px 0px 5px">
                                        <table cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td>
                                                    <asp:Label runat="server" ID="lblUpdateDateDetails" EnableTheming="false" CssClass="LabelBoldWhite"
                                                        Text="תאריך עדכון :"></asp:Label>
                                                    <asp:Label runat="server" ID="lblUpdateDateDetailsFld" EnableTheming="false" CssClass="LabelNormalWhite"></asp:Label>
                                                </td>
                                                <td id="tdUpdateEmployee" runat="server" style="margin: 0px 0px 0px 0px; padding: 0px 0px 0px 0px;">
                                                    <table cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                background-position: bottom left;">
                                                                &nbsp;
                                                            </td>
                                                            <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                background-repeat: repeat-x; background-position: bottom;">
                                                                <asp:Button ID="btnUpdateEmployee" Width="105px" runat="server" CssClass="RegularUpdateButton"
                                                                    Text="עדכון נותן שירות" OnClick="btnUpdateEmployee_Click" />
                                                            </td>
                                                            <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                                background-repeat: no-repeat;">
                                                                &nbsp;
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                                <td style="margin: 0px 0px 0px 0px; padding: 0px 10px 0px 0px;">
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td valign="top" dir="ltr">
                            <div id="divWithScrollBar" class="ScrollBarDiv" style="height: 460px; overflow: auto;">
                                <div dir="rtl">
                                    <table cellpadding="0" cellspacing="0" width="1000px">
                                        <tr>
                                            <td style="width: 100%">
                                                <asp:DetailsView SkinID="dvNoAltRow" ID="dvDoctorDetails" runat="server" Width="100%"
                                                    AutoGenerateRows="False" GridLines="None" OnDataBound="dvDoctorDetails_DataBound"
                                                    OnDataBinding="dvDoctorDetails_DataBinding">
                                                    <Fields>
                                                        <asp:TemplateField>
                                                            <ItemTemplate>
                                                                <table cellspacing="0" cellpadding="0" style="background-color: #F7F7F7; border: 1px solid #dddddd;
                                                                    width: 100%">
                                                                    <tr>
                                                                        <td style="width: 450px" class="BorderBottomLight">
                                                                            <table cellspacing="0" cellpadding="0">
                                                                                <tr>
                                                                                    <td style="padding-right: 5px">
                                                                                        <asp:Label ID="lblFirstNameCaption" Width="80px" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                                            runat="server" Text="שם פרטי:"></asp:Label>
                                                                                    </td>
                                                                                    <td>
                                                                                        <asp:Label ID="lblFirstName" CssClass="RegularLabel" EnableTheming="false" runat="server"
                                                                                            Text='<%#Bind("firstName") %>'></asp:Label>
                                                                                    </td>
                                                                                    <td style="padding-right: 15px">
                                                                                        <asp:Label ID="lblLastNameCaption" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                                            runat="server" Text="שם משפחה:"></asp:Label>
                                                                                    </td>
                                                                                    <td style="padding-right: 10px">
                                                                                        <asp:Label ID="lblLastName" CssClass="RegularLabel" EnableTheming="false" runat="server"
                                                                                            Text='<%#Bind("lastName") %>'></asp:Label>
                                                                                    </td>
                                                                                </tr>
                                                                            </table>
                                                                        </td>
                                                                        <td align="right" class="BorderBottomLight">
                                                                            <table cellspacing="0" cellpadding="0" border="0">
                                                                                <tr>
                                                                                    <td>
                                                                                        <asp:Label ID="lblPhoneHomeCaption" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                                            runat="server" Text="טלפון בבית:"></asp:Label>
                                                                                    </td>
                                                                                    <td id="tdHomePhone" runat="server">
                                                                                        <asp:Label ID="lblHomePhone" CssClass="RegularLabel" EnableTheming="false" runat="server"
                                                                                            Text='<%#Bind("homePhone") %>'></asp:Label>&nbsp;
                                                                                    </td>
                                                                                    <td>
                                                                                        <asp:Label ID="lblHomePhoneRestricted" runat="server">(חסוי)</asp:Label>
                                                                                    </td>
                                                                                    <td id="tdHomePhoneLogin" runat="server" style="display: none; padding: 0px 0px 0px 0px;">
                                                                                        <table cellpadding="0" cellspacing="0">
                                                                                            <tr>
                                                                                                <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                                                    background-position: bottom left;">
                                                                                                    &nbsp;
                                                                                                </td>
                                                                                                <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                                                    background-repeat: repeat-x; background-position: bottom;">
                                                                                                    <asp:Button ID="btnHomePhoneLogin" runat="server" CssClass="RegularUpdateButton"
                                                                                                        Text="צפיה" CausesValidation="False" OnClientClick="ShowLoginPopUp(); return false;" />
                                                                                                </td>
                                                                                                <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                                                                    background-repeat: no-repeat;">
                                                                                                    &nbsp;
                                                                                                </td>
                                                                                            </tr>
                                                                                        </table>
                                                                                    </td>
                                                                                    <td style="padding-right: 145px">
                                                                                        <asp:Label ID="lblResumeLink" CssClass="LooksLikeHRef_Disabled" EnableTheming="false"
                                                                                            runat="server" Text="קורות חיים"></asp:Label>
                                                                                    </td>
                                                                                </tr>
                                                                            </table>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td style="width: 450px" class="BorderBottomLight">
                                                                            <table cellspacing="0" cellpadding="0">
                                                                                <tr>
                                                                                    <td style="padding-right: 5px">
                                                                                        <asp:Label ID="lblSectorCaption" Width="80px" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                                            Text="סקטור:" runat="server"></asp:Label>
                                                                                    </td>
                                                                                    <td>
                                                                                        <asp:Label ID="lblSector" CssClass="RegularLabel" EnableTheming="false" runat="server"
                                                                                            Text='<%#Bind("EmployeeSectorDescription")%>'></asp:Label>
                                                                                    </td>
                                                                                </tr>
                                                                            </table>
                                                                        </td>
                                                                        <td class="BorderBottomLight">
                                                                            <table cellspacing="0" cellpadding="0">
                                                                                <tr>
                                                                                    <td>
                                                                                        <asp:Label ID="lblCellPhoneCaption" Width="60px" Text="טלפון נייד:" CssClass="LabelBoldDirtyBlue"
                                                                                            EnableTheming="false" runat="server"></asp:Label>
                                                                                    </td>
                                                                                    <td id="tdCellPhone" runat="server" style="padding-right: 6px;">
                                                                                        <asp:Label ID="lblCellPhone" runat="server" CssClass="RegularLabel" EnableTheming="false"
                                                                                            Text='<%#Bind("cellPhone")%>'></asp:Label>&nbsp;
                                                                                    </td>
                                                                                    <td>
                                                                                        <asp:Label ID="lblCellPhoneRestriced" runat="server">(חסוי)</asp:Label>
                                                                                    </td>
                                                                                    <td id="tdCellPhoneLogin" runat="server" style="display: none; padding: 0px 5px 0px 0px;">
                                                                                        <table cellpadding="0" cellspacing="0">
                                                                                            <tr>
                                                                                                <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                                                    background-position: bottom left;">
                                                                                                    &nbsp;
                                                                                                </td>
                                                                                                <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                                                    background-repeat: repeat-x; background-position: bottom;">
                                                                                                    <asp:Button ID="btnCellPhoneLogin" runat="server" CssClass="RegularUpdateButton"
                                                                                                        Text="צפיה" CausesValidation="False" OnClientClick="ShowLoginPopUp(); return false;" />
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
                                                                        <td style="width: 450px" class="BorderBottomLight">
                                                                            <table cellspacing="0" cellpadding="0">
                                                                                <tr>
                                                                                    <td style="padding-right: 5px">
                                                                                        <asp:Label ID="lblProfessionsCaption" Text="מקצועות:" Width="80px" CssClass="LabelBoldDirtyBlue"
                                                                                            EnableTheming="false" runat="server"></asp:Label>
                                                                                    </td>
                                                                                    <td>
                                                                                        <asp:Label ID="lblProfessions" Text='<%#Bind("professions") %>' CssClass="RegularLabel"
                                                                                            EnableTheming="false" runat="server"></asp:Label>
                                                                                    </td>
                                                                                </tr>
                                                                            </table>
                                                                        </td>
                                                                        <td class="BorderBottomLight">
                                                                            <table cellspacing="0" cellpadding="0">
                                                                                <tr>
                                                                                    <td>
                                                                                        <asp:Label ID="lblEmailCaption" Width="60px" Text="e-mail:" CssClass="LabelBoldDirtyBlue"
                                                                                            EnableTheming="false" runat="server"></asp:Label>
                                                                                    </td>
                                                                                    <td style="padding-right: 10px; direction: ltr">
                                                                                        <asp:Label ID="lblEmail" runat="server" Text='<%#Bind("email")%>' SkinID="lblRegularLabelNormal"></asp:Label>
                                                                                    </td>
                                                                                    <td style="padding-right: 5px">
                                                                                        <asp:Image ID="imgShowEmailInInternet" runat="server" ToolTip="לא תוצג באינטרנט"
                                                                                            ImageUrl="../Images/Applic/pic_NotShowInInternet.gif" />
                                                                                    </td>
                                                                                </tr>
                                                                            </table>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td style="width: 450px" class="BorderBottomLight">
                                                                            <table cellspacing="0" cellpadding="0">
                                                                                <tr>
                                                                                    <td style="padding-right: 5px">
                                                                                        <asp:Label ID="lblServicesCaption" Text="שירותים:" Width="80px" CssClass="LabelBoldDirtyBlue"
                                                                                            EnableTheming="false" runat="server"></asp:Label>
                                                                                    </td>
                                                                                    <td>
                                                                                        <asp:Label ID="lblServices" Text='<%#Bind("sevices") %>' CssClass="RegularLabel"
                                                                                            EnableTheming="false" runat="server"></asp:Label>
                                                                                    </td>
                                                                                </tr>
                                                                            </table>
                                                                        </td>
                                                                        <td class="BorderBottomLight">
                                                                            <table cellpadding="0" cellspacing="0">
                                                                                <tr>
                                                                                    <td style="padding-left:5px">
                                                                                        <asp:Label ID="lblHospital" runat="server" CssClass="LabelBoldDirtyBlue" EnableTheming="false">בית חולים:</asp:Label>
                                                                                    </td>
                                                                                    <td style="Width:150px">
                                                                                        <asp:Label ID="lblHospitalDesc" runat="server" CssClass="RegularLabel"
                                                                                            EnableTheming="false" >-</asp:Label>
                                                                                    </td>
                                                                                    <td style="padding-left:5px">
                                                                                      <asp:Label ID="lblPosition" runat="server" CssClass="LabelBoldDirtyBlue" EnableTheming="false">תפקיד:</asp:Label>  
                                                                                    </td>
                                                                                    <td>
                                                                                      <asp:Label ID="lblPositionDesc" runat="server" CssClass="RegularLabel" EnableTheming="false">-</asp:Label>                                                                                          
                                                                                    </td>
                                                                                </tr>
                                                                            </table>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td style="width: 450px" class="BorderBottomLight">
                                                                            <table cellspacing="0" cellpadding="0">
                                                                                <tr>
                                                                                    <td style="padding-right: 5px">
                                                                                        <asp:Label ID="lblLanguagesCaption" Text="שפות:" Width="80px" CssClass="LabelBoldDirtyBlue"
                                                                                            EnableTheming="false" runat="server"></asp:Label>
                                                                                    </td>
                                                                                    <td>
                                                                                        <asp:Label ID="lblLanguages" runat="server" Text='<%#Bind("languages")%>' CssClass="RegularLabel"
                                                                                            EnableTheming="false"></asp:Label>
                                                                                    </td>
                                                                                </tr>
                                                                            </table>
                                                                        </td>
                                                                        <td rowspan="7" valign="top">
                                                                            <table cellspacing="0" cellpadding="0">
                                                                                <tr>
                                                                                    <td valign="top" style="height: 25px; windows: 80px">
                                                                                        <asp:Label ID="lblCommentsCaption" Width="60px" Text="הערות:" CssClass="LabelBoldDirtyBlue"
                                                                                            EnableTheming="false" runat="server"></asp:Label>
                                                                                    </td>
                                                                                    <td align="left" style="width: 420px">
                                                                                        <!-- Remark buttons -->
                                                                                        <table id="tblUpdateEmployeeRemarks" runat="server" cellpadding="0" cellspacing="0">
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
                                                                                    <td colspan="2" dir="ltr">
                                                                                        <!-- Remarks -->
                                                                                        <div style="height: 120px; overflow: auto">
                                                                                            <div dir="rtl">
                                                                                                <asp:GridView ID="gvClinicsForRemarks" runat="server" SkinID="SimpleGridViewNoEmtyDataText"
                                                                                                    EmptyDataText="אין הערות נותן שירות" AutoGenerateColumns="False" HeaderStyle-CssClass="DisplayNone"
                                                                                                    OnRowDataBound="gvClinicsForRemarks_RowDataBound">
                                                                                                    <Columns>
                                                                                                        <asp:TemplateField>
                                                                                                            <ItemTemplate>
                                                                                                                <table cellpadding="0" cellspacing="0">
                                                                                                                    <tr>
                                                                                                                        <td>
                                                                                                                            <asp:Label ID="lblClinicName" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                                                                                runat="server" Text='<%#Bind("deptName") %>'></asp:Label>
                                                                                                                        </td>
                                                                                                                    </tr>
                                                                                                                    <tr>
                                                                                                                        <td>
                                                                                                                            <asp:GridView ID="gvRemarks" runat="server" SkinID="SimpleGridViewNoEmtyDataText"
                                                                                                                                EmptyDataText="אין הערות לנותן שירות" AutoGenerateColumns="False" HeaderStyle-CssClass="DisplayNone"
                                                                                                                                OnRowDataBound="gvRemarks_RowDataBound">
                                                                                                                                <Columns>
                                                                                                                                    <asp:TemplateField>
                                                                                                                                        <ItemTemplate>
                                                                                                                                            <table cellpadding="0" cellspacing="0">
                                                                                                                                                <tr>
                                                                                                                                                    <td style="margin: 0px 0px 0px 0px; padding: 0px 0px 0px 0px" valign="top">
                                                                                                                                                        <div style="width: 15px;">
                                                                                                                                                            <asp:Image ID="imgInternet" runat="server" />
                                                                                                                                                        </div>
                                                                                                                                                    </td>
                                                                                                                                                    <td valign="top">
                                                                                                                                                        &diams;
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
                                                                                                            </ItemTemplate>
                                                                                                        </asp:TemplateField>
                                                                                                    </Columns>
                                                                                                </asp:GridView>
                                                                                            </div>
                                                                                        </div>
                                                                                    </td>
                                                                                </tr>
                                                                            </table>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td style="width: 450px" class="BorderBottomLight">
                                                                            <table cellspacing="0" cellpadding="0">
                                                                                <tr>
                                                                                    <td style="padding-right: 5px">
                                                                                        <asp:Label ID="lblDistrictNameCaption" Text="מחוז:" Width="80px" CssClass="LabelBoldDirtyBlue"
                                                                                            EnableTheming="false" runat="server"></asp:Label>
                                                                                    </td>
                                                                                    <td>
                                                                                        <asp:Label ID="lblDistrictName" runat="server" Text='<%#Bind("districtName")%>' CssClass="RegularLabel"
                                                                                            EnableTheming="false"></asp:Label>
                                                                                    </td>
                                                                                </tr>
                                                                            </table>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td style="width: 450px" class="BorderBottomLight">
                                                                            <table cellspacing="0" cellpadding="0">
                                                                                <tr>
                                                                                    <td style="padding-right: 5px">
                                                                                        <asp:Label ID="lblSexCaption" Text="מגדר:" Width="80px" CssClass="LabelBoldDirtyBlue"
                                                                                            EnableTheming="false" runat="server"></asp:Label>
                                                                                    </td>
                                                                                    <td>
                                                                                        <asp:Label ID="lblSex" runat="server" Text='<%#Bind("sex")%>' CssClass="RegularLabel"
                                                                                            EnableTheming="false"></asp:Label>
                                                                                    </td>
                                                                                </tr>
                                                                            </table>
                                                                        </td>
                                                                    </tr>
                                                                    <tr id="trEmployeeID" runat="server">
                                                                        <td style="width: 450px" class="BorderBottomLight">
                                                                            <table cellspacing="0" cellpadding="0">
                                                                                <tr>
                                                                                    <td style="padding-right: 5px">
                                                                                        <asp:Label ID="lblEmployeeIDCaption" Text="ת.ז.:" Width="80px" CssClass="LabelBoldDirtyBlue"
                                                                                            EnableTheming="false" runat="server"></asp:Label>
                                                                                    </td>
                                                                                    <td>
                                                                                        <asp:Label ID="lblEmployeeID" runat="server" Text='<%#Bind("employeeID")%>' CssClass="RegularLabel"
                                                                                            EnableTheming="false"></asp:Label>
                                                                                    </td>
                                                                                </tr>
                                                                            </table>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td style="width: 450px" class="BorderBottomLight">
                                                                            <table cellspacing="0" cellpadding="0">
                                                                                <tr>
                                                                                    <td style="padding-right: 5px">
                                                                                        <asp:Label ID="lblLicenseNumberCaption" Text="רשיון רופא:" Width="80px" CssClass="LabelBoldDirtyBlue"
                                                                                            EnableTheming="false" runat="server"></asp:Label>
                                                                                    </td>
                                                                                    <td>
                                                                                        <asp:Label ID="lblLicenseNumber" runat="server" Text='<%#Bind("licenseNumber")%>'
                                                                                            CssClass="RegularLabel" EnableTheming="false"></asp:Label>
                                                                                    </td>
                                                                                </tr>
                                                                            </table>
                                                                        </td>
                                                                    </tr>
                                                                    <tr style="width: 450px" class="BorderBottomLight">
                                                                        <td>
                                                                            <table>
                                                                                <tr>
                                                                                    <td style="padding-right: 5px">
                                                                                        <asp:Label ID="lblProfLicenseNumberCaption" Text="רישיון מקצועי:" Width="80px" CssClass="LabelBoldDirtyBlue"
                                                                                            EnableTheming="false" runat="server"></asp:Label>
                                                                                    </td>
                                                                                    <td>
                                                                                        <asp:Label ID="lblProfLicenseNumber" runat="server" Text='<%#Bind("ProfLicenseNumber")%>'
                                                                                            CssClass="RegularLabel" EnableTheming="false"></asp:Label>
                                                                                    </td>
                                                                                    <td id="tdBtnUpdateEmployeeProfessionLicence" runat="server" style="padding-right:60px">
                                                                                        <table cellpadding="0" cellspacing="0">
                                                                                            <tr>
                                                                                                <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                                                    background-position: bottom left;">
                                                                                                    &nbsp;
                                                                                                </td>
                                                                                                <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                                                    background-repeat: repeat-x; background-position: bottom;">
                                                                                                    <asp:Button ID="btnUpdateEmployeeProfessionLicence" Width="115px" runat="server" CssClass="RegularUpdateButton"
                                                                                                        Text="עדכון רישיון מקצועי" OnClick="btnUpdateEmployeeProfessionLicence_Click" />
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
                                                                        <td style="width: 450px">
                                                                            <table cellspacing="0" cellpadding="0">
                                                                                <tr>
                                                                                    <td style="padding-right: 5px">
                                                                                        <asp:Label ID="lblActiveCaption" Text="סטטוס:" Width="80px" CssClass="LabelBoldDirtyBlue"
                                                                                            EnableTheming="false" runat="server"></asp:Label>
                                                                                    </td>
                                                                                    <td>
                                                                                        <asp:Label ID="lblActive" runat="server" Text='<%#Bind("active")%>' CssClass="RegularLabel"
                                                                                            EnableTheming="false"></asp:Label>
                                                                                    </td>
                                                                                </tr>
                                                                            </table>
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </ItemTemplate>
                                                            <HeaderStyle CssClass="DisplayNone" />
                                                        </asp:TemplateField>
                                                    </Fields>
                                                </asp:DetailsView>
                                            </td>
                                        </tr>
                                        <!-- List of Clinics where the Doctor works -->
                                        <tr>
                                            <td>
                                                <div id="divGvClinics" style="width: 100%; padding-top: 5px;">
                                                    <table cellpadding="0" cellspacing="0" width="100%">
                                                        <tr style="background-color: #E9F5FE">
                                                            <td style="padding-right: 5px; height: 25px; width: 70%">
                                                                <asp:Label ID="lblEmployeeWorkPlacesCaption" runat="server" Text="יחידות בהן עובד נותן שירות"
                                                                    CssClass="LabelCaptionBlueBold_16" EnableTheming="false"></asp:Label>
                                                                <asp:TextBox ID="txtDeptsToBeAdded" runat="server" EnableTheming="false" CssClass="DisplayNone" ></asp:TextBox>
                                                            </td>
                                                            <td style="padding: 0px 0px 0px 10px" align="left">
                                                                <asp:Label runat="server" ID="lblUpdateDateClinics" SkinID="lblUpdateDateSkin" Text="תאריך עדכון :"></asp:Label>
                                                                <asp:Label runat="server" ID="lblUpdateDateClinicsFld" SkinID="lblUpdateDateSkinNormal"></asp:Label>
                                                            </td>
                                                            <td id="tdAddDeptToEmployee" runat="server" style="display: inline; padding-left: 10px;
                                                                width: 10%" align="left">
                                                                <table cellpadding="0" cellspacing="0">
                                                                    <tr>
                                                                        <td class="buttonRightCorner">
                                                                        </td>
                                                                        <td class="buttonCenterBackground">
                                                                            <asp:Button ID="btnAddDept" runat="server" Text="הוספת יחידה" CssClass="RegularUpdateButton"
                                                                                CausesValidation="true" OnClientClick="AddDeptToEmployee(1, 1);return false;">
                                                                            </asp:Button>
                                                                        </td>
                                                                        <td class="buttonLeftCorner">
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="3" width="100%">
                                                                <div>
                                                                    <asp:GridView Width="100%" ID="gvClinics" runat="server" AutoGenerateColumns="False"
                                                                        OnRowDataBound="gvClinics_RowDataBound" HeaderStyle-BackColor="#F7FAFF" HeaderStyle-CssClass="LabelCaptionGreenBold_12"
                                                                        SkinID="GridViewForZoomLists">
                                                                        <Columns>
                                                                            <asp:BoundField DataField="DeptCode">
                                                                                <ItemStyle CssClass="BoundFieldDisplayNone" />
                                                                                <HeaderStyle CssClass="BoundFieldDisplayNone" />
                                                                            </asp:BoundField>
                                                                            <asp:TemplateField HeaderText="קבלה נותן שירות" ItemStyle-VerticalAlign="Top" ItemStyle-HorizontalAlign="Left"
                                                                                ItemStyle-Width="25px">
                                                                                <ItemTemplate>
                                                                                    <div style="padding-left: 5px; padding-top: 5px">
                                                                                        <asp:Image ID="imgClock" runat="server" ToolTip="שעות קבלה נותן שירות" CssClass="cursor_pointer" />
                                                                                    </div>
                                                                                </ItemTemplate>
                                                                            </asp:TemplateField>
                                                                            <asp:TemplateField HeaderText="קבלה יחידה" ItemStyle-VerticalAlign="Top" ItemStyle-HorizontalAlign="Left"
                                                                                ItemStyle-Width="25px">
                                                                                <ItemTemplate>
                                                                                    <!-- שעות יחידה-->
                                                                                    <div style="padding-left: 5px; padding-top: 5px">
                                                                                        <asp:Image ID="imgRecepAndComment" runat="server" ToolTip="שעות קבלה ליחידה" CssClass="cursor_pointer" />
                                                                                    </div>
                                                                                </ItemTemplate>
                                                                            </asp:TemplateField>
                                                                            <asp:TemplateField HeaderText="שם יחידה" ItemStyle-VerticalAlign="Top" HeaderStyle-HorizontalAlign="Right"
                                                                                ItemStyle-Width="200px">
                                                                                <ItemTemplate>
                                                                                    <table cellpadding="0" cellspacing="0">
                                                                                        <tr>
                                                                                            <td>
                                                                                                <asp:HyperLink ID="lnkDept" runat="server" Text='<%#Eval("deptName")%>' CssClass="LooksLikeHRefBold"
                                                                                                    NavigateUrl='<%# "ZoomClinic.aspx?DeptCode=" + Eval("deptCode") %>'></asp:HyperLink>
                                                                                            </td>
                                                                                        </tr>
                                                                                        <tr>
                                                                                            <td>
                                                                                                <asp:GridView ID="gvPositions" runat="server" HeaderStyle-CssClass="DisplayNone"
                                                                                                    RowStyle-CssClass="RegularLabel" SkinID="SimpleGridView">
                                                                                                </asp:GridView>
                                                                                            </td>
                                                                                        </tr>
                                                                                    </table>
                                                                                </ItemTemplate>
                                                                            </asp:TemplateField>
                                                                            <asp:TemplateField HeaderText="כתובת" HeaderStyle-HorizontalAlign="Right" ItemStyle-VerticalAlign="Top"
                                                                                ItemStyle-Width="150px">
                                                                                <ItemTemplate>
                                                                                    <asp:Label ID="lblAddress" Width="150px" Text='<%#Eval("address")%>' runat="server"
                                                                                        EnableTheming="false" CssClass="RegularLabel"></asp:Label>
                                                                                </ItemTemplate>
                                                                            </asp:TemplateField>
                                                                            <asp:BoundField DataField="cityName" ItemStyle-Width="100px" HeaderStyle-HorizontalAlign="Right"
                                                                                HeaderText="יישוב" ItemStyle-CssClass="RegularLabel" ItemStyle-VerticalAlign="Top" />
                                                                            <asp:TemplateField HeaderText="תחומי שירות" ItemStyle-Width="120px" HeaderStyle-HorizontalAlign="Right"
                                                                                ItemStyle-VerticalAlign="Top">
                                                                                <ItemTemplate>
                                                                                    <asp:GridView ID="gvServices" runat="server" HeaderStyle-CssClass="DisplayNone" RowStyle-CssClass="RegularLabel"
                                                                                        SkinID="SimpleGridView">
                                                                                    </asp:GridView>
                                                                                </ItemTemplate>
                                                                            </asp:TemplateField>
                                                                            <asp:TemplateField HeaderText="זימון ביקור" HeaderStyle-HorizontalAlign="Right" ItemStyle-VerticalAlign="Top"
                                                                                ItemStyle-Width="110px">
                                                                                <ItemTemplate>
                                                                                    <div>
                                                                                        <table cellpadding="0" cellspacing="0">
                                                                                            <tr>
                                                                                                <td id="tdEmployeeQueueOrderMethods" class="QueueOrderText" runat="server" valign="bottom"
                                                                                                    align="right">
                                                                                                </td>
                                                                                            </tr>
                                                                                        </table>
                                                                                        <table id='tblQueueOrderPhonesAndHours-<%# Eval("ToggleID") %>' style="display: none"
                                                                                            cellpadding="0" cellspacing="0">
                                                                                            <tr>
                                                                                                <td dir="ltr" align="right">
                                                                                                    <asp:Label ID="lblQueueOrderPhones" runat="server"></asp:Label>
                                                                                                </td>
                                                                                            </tr>
                                                                                            <tr>
                                                                                                <td>
                                                                                                    <asp:GridView ID="gvQueueOrderHours" runat="server" EnableTheming="false" GridLines="None"
                                                                                                        AutoGenerateColumns="false" HeaderStyle-CssClass="LabelCaptionBlueBold_12" BorderWidth="1px"
                                                                                                        BorderStyle="Solid" BorderColor="#BADBFC">
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
                                                                                    </div>
                                                                                </ItemTemplate>
                                                                            </asp:TemplateField>
                                                                            <asp:TemplateField ItemStyle-Width="30px" ItemStyle-HorizontalAlign="Right">
                                                                                <ItemTemplate>
                                                                                    <asp:Image ID="imgReceiveGuests" runat="server" />
                                                                                </ItemTemplate>
                                                                            </asp:TemplateField>
                                                                            <asp:TemplateField HeaderText="טלפון" ItemStyle-VerticalAlign="Top" HeaderStyle-HorizontalAlign="Right"
                                                                                ItemStyle-Width="150px">
                                                                                <ItemTemplate>
                                                                                    <asp:GridView ID="gvPhone" RowStyle-CssClass="RegularLabel" AutoGenerateColumns="false"
                                                                                        runat="server" HeaderStyle-CssClass="DisplayNone" SkinID="SimpleGridView">
                                                                                        <Columns>
                                                                                            <asp:TemplateField>
                                                                                                <ItemTemplate>
                                                                                                    <asp:Label ID="lblPhoneTypeName" Width="25px" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                                                                        runat="server" Text="טל'"></asp:Label>
                                                                                                    <asp:Label ID="lblPhone" runat="server" Text='<%# Eval("Column1") %>'></asp:Label>
                                                                                                </ItemTemplate>
                                                                                            </asp:TemplateField>
                                                                                        </Columns>
                                                                                    </asp:GridView>
                                                                                    <asp:GridView RowStyle-CssClass="RegularLabel" ID="gvFax" AutoGenerateColumns="false"
                                                                                         runat="server" HeaderStyle-CssClass="DisplayNone" SkinID="SimpleGridView">
                                                                                        <Columns>
                                                                                            <asp:TemplateField>
                                                                                                <ItemTemplate>
                                                                                                    <asp:Label ID="lblFaxTypeName" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                                                                        runat="server" Text="פקס"></asp:Label>
                                                                                                    <asp:Label ID="lblFax" runat="server" Text='<%# Eval("Column1") %>'></asp:Label>
                                                                                            </ItemTemplate>
                                                                                            </asp:TemplateField>
                                                                                        </Columns>
                                                                                    </asp:GridView>
                                                                                </ItemTemplate>
                                                                            </asp:TemplateField>
                                                                            <asp:TemplateField HeaderText="סוג הסכם" HeaderStyle-HorizontalAlign="Center" ItemStyle-Width="30px"
                                                                                ItemStyle-HorizontalAlign="Center" ItemStyle-VerticalAlign="Top">
                                                                                <ItemTemplate>
                                                                                    <asp:Image ID="imgAgreementType" runat="server" />
                                                                                </ItemTemplate>
                                                                            </asp:TemplateField>
                                                                            <asp:TemplateField ItemStyle-VerticalAlign="Top">
                                                                                <ItemTemplate>
                                                                                    <table id="tblEditButton" runat="server" cellpadding="0" cellspacing="0">
                                                                                        <tr>
                                                                                            <td style="padding: 0px 0px 0px 0px">
                                                                                                <table cellpadding="0" cellspacing="0">
                                                                                                    <tr>
                                                                                                        <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                                                            background-position: bottom left;">
                                                                                                            &nbsp;
                                                                                                        </td>
                                                                                                        <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                                                            background-repeat: repeat-x; background-position: bottom;">
                                                                                                            <asp:Button ID="btnEditDoctorInClinic" Width="35px" DeptEmployeeID='<%# Eval("deptEmployeeID")%>'
                                                                                                                runat="server" CssClass="RegularUpdateButton" Text="עדכון" OnClick="btnEditDoctorInClinic_Click" />
                                                                                                        </td>
                                                                                                        <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                                                                            background-repeat: no-repeat;">
                                                                                                            &nbsp;
                                                                                                        </td>
                                                                                                    </tr>
                                                                                                </table>
                                                                                            </td>
                                                                                            <td style="padding-top: 4px">
                                                                                                <asp:ImageButton ID="btnDeleteDoctorInClinic" runat="server" ImageUrl="../Images/Applic/btn_X_red.gif"
                                                                                                    DeptEmployeeID='<%# Eval("deptEmployeeID")%>' DeptCode='<%# Eval("deptCode")%>' ToolTip="מחיקה" OnClick="btnDeleteDoctorInClinic_Click"
                                                                                                    OnClientClick="return confirm('?האם הנך בטוח שברצונך למחוק את הרופא\\עובד במרפאה')">
                                                                                                </asp:ImageButton>
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
                                                    </table>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <!-- List of Employee Hours -->
        <tr id="trEmployeeHours" runat="server">
            <td style="padding-bottom: 10px; padding-left: 5px; padding-right: 5px;">
                <table align="right" style="width: 1040px; border: solid 1px #D4EAFB; background-color: White">
                    <tr>
                        <td style="background-color: #2889E4">
                            <table cellpadding="0" cellspacing="0" width="968px">
                                <tr>
                                    <td style="width: 60%; height: 28px; padding-right: 5px">
                                        <asp:Label ID="lblName_ForHours" runat="server" EnableTheming="false" CssClass="LabelBoldWhite_18"></asp:Label>
                                        <asp:Label ID="lblExpert_ForHours" runat="server" EnableTheming="false" CssClass="LabelBoldWhite_18"></asp:Label>
                                    </td>
                                    <td width="40%" align="left" style="padding: 0px 0px 0px 5px">
                                        <table cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td>
                                                    <asp:Label runat="server" ID="lblUpdateDateHours" EnableTheming="false" CssClass="LabelBoldWhite"
                                                        Text="תאריך עדכון :"></asp:Label>
                                                    <asp:Label runat="server" ID="lblUpdateDateHoursFld" EnableTheming="false" CssClass="LabelNormalWhite"></asp:Label>
                                                </td>
                                                <td id="tdUpdateEmployeeHours" runat="server" style="margin: 0px 0px 0px 0px; padding: 0px 0px 0px 0px;">
                                                    <table cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                background-position: bottom left;">
                                                                &nbsp;
                                                            </td>
                                                            <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                background-repeat: repeat-x; background-position: bottom;">
                                                                <asp:Button ID="btnUpdateEmployeeHours" Width="105px" runat="server" CssClass="RegularUpdateButton"
                                                                    Text="עדכון שעות קבלה" OnClick="btnUpdateEmployeeHours_Click" />
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
                        </td>
                    </tr>
                    <tr>
                        <td style="padding-right: 10px">
                            <span class="LabelCaptionGreenBold_18">שעות קבלה לנותן שירות</span>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding: 3px 10px 3px 0px">
                            <div id="divExpireWarning" runat="server">
                                <asp:Label ID="lblExpireWarning" runat="server" EnableTheming="false" CssClass="LooksLikeHRefBold" />
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td style="border-bottom: 2px solid #BADBFC">
                            <table cellpadding="0" cellspacing="0">
                                <tr>
                                    <td style="width: 30px" align="center">
                                        <asp:Label ID="lblDay" runat="server" Text="יום" CssClass="LabelCaptionGreenBold_12"
                                            EnableTheming="false"></asp:Label>
                                    </td>
                                    <td style="width: 40px" align="left">
                                        <asp:Label ID="lblFromHour" runat="server" Text="משעה" CssClass="LabelCaptionGreenBold_12"
                                            EnableTheming="false"></asp:Label>
                                    </td>
                                    <td style="width: 80px" align="center">
                                        <asp:Label ID="lblToHour" runat="server" Text="עד שעה" CssClass="LabelCaptionGreenBold_12"
                                            EnableTheming="false"></asp:Label>
                                    </td>
                                    <td style="width: 250px" align="right">
                                        <asp:Label ID="lblClinicName" runat="server" Text="במרפאה" CssClass="LabelCaptionGreenBold_12"
                                            EnableTheming="false"></asp:Label>
                                    </td>
                                    <td style="width: 250px">
                                        <asp:Label ID="lblProfAndServ" runat="server" Text="תחום שירות" CssClass="LabelCaptionGreenBold_12"
                                            EnableTheming="false"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:Label ID="lblRemarks" runat="server" Text="הערות" CssClass="LabelCaptionGreenBold_12"
                                            EnableTheming="false"></asp:Label>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:GridView ID="gvEmployeeReceptionDays_All" runat="server" AutoGenerateColumns="false"
                                SkinID="SimpleGridViewNoEmtyDataText" Width="100%" HeaderStyle-CssClass="DisplayNone"
                                OnRowDataBound="gvEmployeeReceptionDays_All_RowDataBound">
                                <Columns>
                                    <asp:TemplateField>
                                        <ItemTemplate>
                                            <table cellpadding="0" cellspacing="0" width="100%" style="border-bottom: 2px solid #BADBFC">
                                                <tr>
                                                    <td style="width: 30px; background-color: #E1F0FC;" align="center">
                                                        <asp:Label ID="lblDay" runat="server" Text='<%#Bind("ReceptionDayName") %>'></asp:Label>
                                                    </td>
                                                    <td>
                                                        <asp:GridView ID="gvReceptionHours_All" runat="server" AutoGenerateColumns="false"
                                                            SkinID="SimpleGridViewNoEmtyDataText" HeaderStyle-CssClass="DisplayNone" Width="100%"
                                                            OnRowDataBound="gvReceptionHours_All_RowDataBound">
                                                            <Columns>
                                                                <asp:TemplateField ItemStyle-Width="100%">
                                                                    <ItemTemplate>
                                                                        <table id="tblReceptionHours_Inner" runat="server" width="100%" cellpadding="0" cellspacing="0">
                                                                            <tr>
                                                                                <td style="width: 40px" align="left" valign="top">
                                                                                    <asp:Label ID="lblFromHour" runat="server" Text='<%#Bind("openingHour") %>'></asp:Label>
                                                                                </td>
                                                                                <td style="width: 80px" align="center" valign="top">
                                                                                    <asp:Label ID="lblToHour" runat="server" Text='<%#Bind("closingHour") %>'></asp:Label>
                                                                                </td>
                                                                                <td style="width: 250px" valign="top">
                                                                                    <asp:Label ID="lblClinicName" runat="server" Text='<%#Bind("deptName") %>'></asp:Label>
                                                                                </td>
                                                                                <td style="width: 250px" valign="top">
                                                                                    <asp:Label ID="lblProfessions" runat="server" ></asp:Label>
                                                                                    <asp:Label ID="lblServices" runat="server" ></asp:Label>
                                                                                </td>
                                                                                <td valign="top">
                                                                                    <asp:Label ID="lblReceptionRemarks" runat="server" Text='<%#Bind("receptionRemarks") %>'></asp:Label>
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
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</asp:Content>
