<%@ Page Language="C#" AutoEventWireup="true"
    MasterPageFile="~/SeferMasterPageIEwide.master" Inherits="Reports_ReportsParameters"
    Title="פרמטרים לדוחות" Codebehind="ReportsParameters.aspx.cs" %>

<%@ Reference Page="~/Admin/AdminBasePage.aspx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ MasterType VirtualPath="~/SeferMasterPageIEwide.master" %>
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
            var url = "../Reports/Reports_CreateExcel.aspx";
            window.open(url, "CreateExcel", "height=800, width=1000, top=50, left=100");
            return false;
        }

        function SelectCities() {
            var txtCitiesListCodes = document.getElementById('<%=txtCitiesListCodes.ClientID %>');
            var txtCitiesList = document.getElementById('<%=txtCitiesList.ClientID %>');
            var SelectedCitiesList = txtCitiesListCodes.innerText;
            var SelectedDistrictCodes = document.getElementById('<%=txtDistrictCodes.ClientID %>').value;

            var url = "../public/SelectPopUp.aspx";
            url += "?SelectedValuesList=" + SelectedCitiesList;
            url += "&SelectedDistrictCodes=" + SelectedDistrictCodes;
            url += "&popupType=9";

            url += "&returnValuesTo=txtCitiesListCodes";
            url += "&returnTextTo=txtCitiesList";

            var dialogWidth = 420;
            var dialogHeight = 650;
            var title = "בחר עיר";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return false;
        }

        function SelectDistrict() {
            var txtDistrictCodes = document.getElementById('<%=txtDistrictCodes.ClientID %>');
            var txtDistrictList = document.getElementById('<%=txtDistrictList.ClientID %>');
            var selectedCodes = txtDistrictCodes.innerText;

            var url = "../public/SelectPopUp.aspx";
            url += "?SelectedValuesList=" + selectedCodes;
            url += "&popupType=19";
            url += "&unitTypeCodes=" + getUnitTypeCodesForDistrict();

            url += "&returnValuesTo=txtDistrictCodes";
            url += "&returnTextTo=txtDistrictList";
            url += "&functionToExecute=setFocusOnAdminClinic";

            var dialogWidth = 420;
            var dialogHeight = 650;
            var title = "בחר מחוז";

            txtDistrictList.focus();

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return false;
        }

        function setFocusOnAdminClinic() {
            var ddlAdminClinic = document.getElementById('<%=ddlAdminClinic.ClientID %>');
            try {
                ddlAdminClinic.focus();
                __doPostBack();
            }
            catch (err) { }
        }

        function SelectChangeType() {
            var txtChangeTypeCodes = document.getElementById('<%=txtChangeTypeCodes.ClientID %>');
            var txtChangeType = document.getElementById('<%=txtChangeType.ClientID %>');
            var selectedCodes = txtChangeTypeCodes.innerText;

            var url = "../public/SelectPopUp.aspx";
            url += "?SelectedValuesList=" + selectedCodes;
            url += "&popupType=27";
            url += "&returnValuesTo=txtChangeTypeCodes";
            url += "&returnTextTo=txtChangeType";

            var dialogWidth = 420;
            var dialogHeight = 650;
            var title = "בחר תחום השינוי";

            txtChangeType.focus();

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return false;
        }

        function SelectUpdateUser() {
            var txtUpdateUserCodes = document.getElementById('<%=txtUpdateUserCodes.ClientID %>');
            var txtUpdateUser = document.getElementById('<%=txtUpdateUser.ClientID %>');
            var selectedCodes = txtUpdateUserCodes.innerText;

            var url = "../public/SelectPopUp.aspx";
            url += "?SelectedValuesList=" + selectedCodes;
            url += "&popupType=28";
            url += "&returnValuesTo=txtUpdateUserCodes";
            url += "&returnTextTo=txtUpdateUser";

            var dialogWidth = 420;
            var dialogHeight = 650;
            var title = "בחר המעדכן";

            txtUpdateUser.focus();

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);
            return false;
        }

        function SelectEmployee() {
            var url = "../public/SelectEmployeePopUp.aspx";
            var dialogWidth = 520;
            var dialogHeight = 520;
            var title = "נותני שירות";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);
            return false;
        }

        function SelectClinics() {

            var txtDistrictCodes = document.getElementById('<%=txtDistrictCodes.ClientID %>');

            if (txtDistrictCodes.innerText == "") {
                alert("לחיפוש יחידה ספציפית יש לבחור בשדה מחוז");
                return;
            }

            var ddlAdminClinic = document.getElementById('<%=ddlAdminClinic.ClientID %>');

            var AdminCodes = ddlAdminClinic.options[ddlAdminClinic.selectedIndex].value;
            if (AdminCodes == '-1') {
                AdminCodes = ''
            }

            var unitTypeListCodes = "";
            var SubUnitType = "";
            var PopulationSectors = "";

            var txtDeptCodes = document.getElementById('<%=txtDeptCodes.ClientID %>');
            var txtDepts = document.getElementById('<%=txtDepts.ClientID %>');

            var SelectedValuesList = txtDistrictCodes.innerText + ';'
                + AdminCodes + ';'
                + txtDeptCodes.innerText + ';'
                + unitTypeListCodes + ';'
                + SubUnitType + ';'
                + PopulationSectors;
            var url = "../Public/SelectPopUp.aspx";
            url += "?SelectedValuesList=" + SelectedValuesList;
            url += "&popupType=25";


            url += "&returnValuesTo=txtDeptCodes";
            url += "&returnTextTo=txtDepts";

            var dialogWidth = 420;
            var dialogHeight = 650;
            var title = "בחר מרפאה";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return false;
        }

        function getUnitTypeCodesForDistrict() {
            if (isSearchModeChecked("Hospitals") && (isSearchModeChecked("Community") || isSearchModeChecked("Mushlam")))
                return "60,65"; // Districts and hospitals
            else
                if (isSearchModeChecked("Hospitals"))
                    return "60"; // Hospitals only
            return "65"; // Districts only

        }

        function SelectProfession() {
            var url = "../public/SelectPopUp.aspx";

            var txtProfessionListCodes = document.getElementById('<%=txtProfessionListCodes.ClientID %>');
            var txtProfessionList = document.getElementById('<%=txtProfessionList.ClientID %>');
            var SelectedProfessionList = txtProfessionListCodes.innerText;

            var ddlReport = $get('<%=ddlReport.ClientID %>')
            var ddlReportSelectedVal = ddlReport.options[ddlReport.selectedIndex].value;

            url += "?SelectedValuesList=" + SelectedProfessionList;
            url += "&popupType=2";
            if (ddlReportSelectedVal == "4"
                || ddlReportSelectedVal == "5"
                || ddlReportSelectedVal == "6"
                || ddlReportSelectedVal == "7") {
                var ddlEmployeeSector = $get('<%=ddlEmployeeSector.ClientID %>')
                if (ddlEmployeeSector.selectedIndex > 0) {
                    var ddlEmployeeSectorSelectedVal = ddlEmployeeSector.options[ddlEmployeeSector.selectedIndex].value;
                    url += "&sectorType=" + ddlEmployeeSectorSelectedVal;
                }
            }

            var membership = GetSelectedValues();
            url += "&AgreementTypes=" + membership;

            url += "&returnValuesTo=txtProfessionListCodes";
            url += "&returnTextTo=txtProfessionList";

            var dialogWidth = 420;
            var dialogHeight = 650;
            var title = "בחר מקצוע";
            //alert(url);
            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return false;
        }

        function SelectExpertProfession() {
            var txtProfessionListCodes = document.getElementById('<%=txtExpertProfListCodes.ClientID %>');

            var txtProfessionList = document.getElementById('<%=txtExpertProfList.ClientID %>');
            var SelectedProfessionList = txtProfessionListCodes.innerText;

            var ddlReport = $get('<%=ddlReport.ClientID %>')
            var ddlReportSelectedVal = ddlReport.options[ddlReport.selectedIndex].value;

            var url = "../public/SelectPopUp.aspx";
            url += "?SelectedValuesList=" + SelectedProfessionList;
            url += "&popupType=2";
            if (ddlReportSelectedVal == "4"
                || ddlReportSelectedVal == "5"
                || ddlReportSelectedVal == "6"
                || ddlReportSelectedVal == "7") {
                var ddlEmployeeSector = $get('<%=ddlEmployeeSector.ClientID %>')
                if (ddlEmployeeSector.selectedIndex > 0) {
                    var ddlEmployeeSectorSelectedVal = ddlEmployeeSector.options[ddlEmployeeSector.selectedIndex].value;
                    url = url + "&sectorType=" + ddlEmployeeSectorSelectedVal;
                }
            }

            var membership = GetSelectedValues();
            url += "&AgreementTypes=" + membership;

            url += "&returnValuesTo=txtExpertProfListCodes";
            url += "&returnTextTo=txtExpertProfList";

            var dialogWidth = 420;
            var dialogHeight = 650;
            var title = "בחר מומחיות";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return false;
        }

        function SelectServices() {
            var txtServicesListCodes = document.getElementById('<%=txtServicesListCodes.ClientID %>');
            var txtServicesList = document.getElementById('<%=txtServicesList.ClientID %>');
            var SelectedServicesList = txtServicesListCodes.innerText;

            var url = "../public/SelectPopUp.aspx";
            url += "?SelectedValuesList=" + SelectedServicesList;

            var ddlReport = $get('ctl00_pageContent_ddlReport')
            var ddlReportSelectedVal = ddlReport.options[ddlReport.selectedIndex].value;

            if (ddlReportSelectedVal == "3" || ddlReportSelectedVal == "19") {
                url = url + "&popupType=15"; // services & professions
            }
            else {
                url = url + "&popupType=3"; // services
            }

            if ($get('ctl00_pageContent_lstMembership_lstModes_1').checked) {
                url = url + "&isInCommunity=1";
            }
            if ($get('ctl00_pageContent_lstMembership_lstModes_2').checked) {
                url = url + "&isInMushlam=1";
            }
            if ($get('ctl00_pageContent_lstMembership_lstModes_3').checked) {
                url = url + "&isInHospitals=1";
            }

            if (ddlReportSelectedVal == "4"
                || ddlReportSelectedVal == "5"
                || ddlReportSelectedVal == "6"
                || ddlReportSelectedVal == "7") {
                var ddlEmployeeSector = $get('<%=ddlEmployeeSector.ClientID %>')
                if (ddlEmployeeSector.selectedIndex > 0) {
                    var ddlEmployeeSectorSelectedVal = ddlEmployeeSector.options[ddlEmployeeSector.selectedIndex].value;
                    url = url + "&sectorType=" + ddlEmployeeSectorSelectedVal;
                }
            }

            var membership = GetSelectedValues();
            url += "&AgreementTypes=" + membership;
            url += "&returnValuesTo=txtServicesListCodes";
            url += "&returnTextTo=txtServicesList";

            var dialogWidth = 420;
            var dialogHeight = 650;
            var title = "בחר שירות/ מקצוע";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return false;
        }

        function SelectUnitType() {
            var url = "../public/SelectPopUp.aspx";
            var txtUnitTypeListCodes = document.getElementById('<%=txtUnitTypeListCodes.ClientID %>');

            var txtUnitTypeList = document.getElementById('<%=txtUnitTypeList.ClientID %>');
            var SelectedUnitTypeList = txtUnitTypeListCodes.innerText;
            url = url + "?SelectedValuesList=" + SelectedUnitTypeList;
            url = url + "&popupType=6";
            url += "&returnValuesTo=txtUnitTypeListCodes";
            url += "&returnTextTo=txtUnitTypeList";

            var dialogWidth = 420;
            var dialogHeight = 650;
            var title = "בחר סוג יחידה";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return false;
        }

        function SelectSubClinicUnitType() {
            var txtUnitTypeListCodes = document.getElementById('<%=txtSubClinicUnitTypeListCodes.ClientID %>');

            var txtUnitTypeList = document.getElementById('<%=txtSubClinicUnitTypeList.ClientID %>');
            var SelectedUnitTypeList = txtUnitTypeListCodes.innerText;

            var url = "../public/SelectPopUp.aspx";
            url = url + "?SelectedValuesList=" + SelectedUnitTypeList;
            url = url + "&popupType=6";

            url += "&returnValuesTo=txtSubClinicUnitTypeListCodes";
            url += "&returnTextTo=txtSubClinicUnitTypeList";

            var dialogWidth = 420;
            var dialogHeight = 650;
            var title = "בחר סוג יחידה";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return false;
        }

        function SelectObjectType() {
            var txtCodes = document.getElementById('<%=txtObjectTypeCodes.ClientID %>');
            var txtList = document.getElementById('<%=txtObjectType.ClientID %>');
            var SelectedList = txtCodes.innerText;

            var url = "../public/SelectPopUp.aspx";
            url = url + "?SelectedValuesList=" + SelectedList;
            url = url + "&popupType=11";
            url += "&returnValuesTo=txtObjectTypeCodes";
            url += "&returnTextTo=txtObjectType";

            var dialogWidth = 420;
            var dialogHeight = 650;
            var title = "בחר טיפוס";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return false;
        }

        function SelectEvent() {
            var url = "../public/SelectPopUp.aspx";
            var txtCodes = document.getElementById('<%=txtEventCodes.ClientID %>');
            var txtList = document.getElementById('<%=txtEvent.ClientID %>');
            var SelectedList = txtCodes.innerText;
            url = url + "?SelectedValuesList=" + SelectedList;
            url = url + "&popupType=14";
            url += "&returnValuesTo=txtEventCodes";
            url += "&returnTextTo=txtEvent";

            var dialogWidth = 420;
            var dialogHeight = 650;
            var title = "בחר פעילות";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return false;
        }

        function SelectEmployeeLanguage() {
            var txtCodes = document.getElementById('<%=txtEmployeeLanguageCodes.ClientID %>');
            var txtList = document.getElementById('<%=txtEmployeeLanguage.ClientID %>');
            var SelectedList = txtCodes.innerText;

            var url = "../public/SelectPopUp.aspx";
            url += "?SelectedValuesList=" + SelectedList;
            url += "&popupType=4";
            url += "&returnValuesTo=txtEmployeeLanguageCodes";
            url += "&returnTextTo=txtEmployeeLanguage";

            var dialogWidth = 420;
            var dialogHeight = 650;
            var title = "בחר שפה";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return false;
        }

        function SelectRemark() {
            var txtCodes = document.getElementById('<%=txtRemarkCodes.ClientID %>');
            var txtList = document.getElementById('<%=txtRemark.ClientID %>');
            var SelectedList = txtCodes.innerText;

            var url = "../public/SelectPopUp.aspx";
            url += "?SelectedValuesList=" + SelectedList;
            url += "&popupType=13";
            url += "&returnValuesTo=txtRemarkCodes";
            url += "&returnTextTo=txtRemark";

            var dialogWidth = 420;
            var dialogHeight = 650;
            var title = "בחר הערה";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return false;
        }

        function compareDates(val, args) {

            var receptionDateFrom = null;
            var receptionDateTo = null;
            var pos = null;
            var from = null;
            var to = null;

            if (val.id == '<%=ValidatorEventFinishDate.ClientID %>') {

                from = document.getElementById('<%=TxtEventStartDate.ClientID %>').value;
                to = document.getElementById('<%=TxtEventFinishDate.ClientID %>').value;
            }
            else if (val.id == '<%=ValidatorValidTo.ClientID %>') {

                from = document.getElementById('<%=txtValidFrom.ClientID %>').value;
                to = document.getElementById('<%=txtValidTo.ClientID %>').value;
            }

            if (from != null && from != "") {
                var dateFormat = from.split('/');

                if (dateFormat[0].charAt(0) == "0" && dateFormat[0].length > 1)
                    dateFormat[0] = dateFormat[0].substring(1)

                if (dateFormat[1].charAt(0) == "0" && dateFormat[1].length > 1)
                    dateFormat[1] = dateFormat[1].substring(1)

                receptionDateFrom = new Date();
                receptionDateFrom.setUTCFullYear(parseInt(dateFormat[2]));
                receptionDateFrom.setUTCMonth(parseInt(dateFormat[1]) - 1);
                receptionDateFrom.setUTCDate(parseInt(dateFormat[0]));
            }
            if (to != null) {
                var dateFormatTo = to.split('/');

                if (dateFormatTo[0].charAt(0) == "0" && dateFormatTo[0].length > 1)
                    dateFormatTo[0] = dateFormatTo[0].substring(1)

                if (dateFormatTo[1].charAt(0) == "0" && dateFormatTo[1].length > 1)
                    dateFormatTo[1] = dateFormatTo[1].substring(1)

                receptionDateTo = new Date();
                receptionDateTo.setUTCFullYear(parseInt(dateFormatTo[2]));
                receptionDateTo.setUTCMonth(parseInt(dateFormatTo[1]) - 1);
                receptionDateTo.setUTCDate(parseInt(dateFormatTo[0]));
            }

            if (to == null)
                args.IsValid = true;
            else {

                if (receptionDateFrom < receptionDateTo)
                    args.IsValid = true;
                else
                    args.IsValid = false;
            }
        }

        function ClearVlidFromTo() {
            document.getElementById('<%= txtValidFrom.ClientID.ToString()%>').value = "";
            document.getElementById('<%= txtValidTo.ClientID.ToString()%>').value = "";
        }

        function UnCheckCbValidNow() {
            document.getElementById('<%= cbValidNow.ClientID.ToString()%>').checked = false;
        }

        function SetScrollPositionForNotSelected() {
            var lstReportFields = document.getElementById('<% = lstReportFields.ClientID %>');
            var hdnScrollPosition = document.getElementById('<% = hdnScrollPositionForNotSelected.ClientID %>');
            if (hdnScrollPosition.value != "") {
                lstReportFields.scrollTop = hdnScrollPosition.value;
            }
        }

        function GetScrollPositionForNotSelected() {
            var lstReportFields = document.getElementById('<% = lstReportFields.ClientID %>');
            var hdnScrollPosition = document.getElementById('<% = hdnScrollPositionForNotSelected.ClientID %>');
            hdnScrollPosition.value = lstReportFields.scrollTop;
        }

        function SetScrollPositionForSelected() {
            var lstSelectedFields = document.getElementById('<% = lstSelectedFields.ClientID %>');
            var hdnScrollPosition = document.getElementById('<% = hdnScrollPositionForSelected.ClientID %>');
            if (hdnScrollPosition.value != "") {
                lstSelectedFields.scrollTop = hdnScrollPosition.value;
            }
        }

        function GetScrollPositionForSelected() {
            var lstSelectedFields = document.getElementById('<% = lstSelectedFields.ClientID %>');
            var hdnScrollPosition = document.getElementById('<% = hdnScrollPositionForSelected.ClientID %>');
            hdnScrollPosition.value = lstSelectedFields.scrollTop;
            //alert(lstReportFields.scrollTop);
        }

        function validateTime(event, element) {

            const button = document.getElementById('ctl00_pageContent_btnExcel');

            const elementNameArray = element.id.split('_');

            const elementErrorLabelID = elementNameArray[elementNameArray.length - 1].replace('txt', 'label') + 'Error';

            const errorElement = document.getElementById(elementErrorLabelID);

            let timeValue = element.value;

            if (timeValue.length == 0) {
                setButton(button, true);
                return false;
            }

            setButton(button, false);

            if (timeValue.length > 1 && parseInt(timeValue[0] + timeValue[1]) > 24) {
                setError(errorElement, "*");
                return false;
            }

            if ((timeValue.length == 2) && event.key != "Backspace" && !timeValue.includes(':')) {
                element.value += ':';
            }

            if (timeValue.length < 5) {
                return false;
            }

            if (timeValue.indexOf(":") < 0) {
                setError(errorElement, "*");
                return false;
            }

            var hours = timeValue.split(':')[0];
            var minutes = timeValue.split(':')[1];

            if (hours == "" || isNaN(hours) || parseInt(hours) > 23) {
                setError(errorElement, "*");
                return false;
            }

            if (minutes == "" || isNaN(minutes) || parseInt(minutes) > 59) {
                setError(errorElement, "*");
                return false;
            }
            else if (parseInt(minutes) == 0) {
                minutes = "00";
            }
            else if (minutes < 10) {
                minutes = "0" + minutes;
            }

            timeValue.value = hours + ":" + minutes;

            setButton(button, true);

            document.getElementById(elementErrorLabelID).innerText = '';

            return true;
        }

        function setButton(button, isEnable) {
            if (isEnable) {
                button.style.opacity = '1';
                button.style.cursor = 'pointer';
                button.removeAttribute('disabled');
            }
            else {
                button.style.opacity = '0.5';
                button.style.cursor = 'unset';
                button.setAttribute("disabled", "disabled");
            }
        }

        function setError(element, error) {
            element.innerText = error;
        }

        function keyispressed(event, element) {

            if (event.key == 'ArrowLeft' || event.key == 'ArrowRight') {
                //Allow right and left key
            }
            else if (isNaN(event.key) && event.which != 8 && event.key != ':' && event.key != 'Tab') {
                event.preventDefault();
            }
            else if (event.key == ':' && element.value.includes(':')) {
                event.preventDefault();
            }

            return true;
        }

    </script>
    <asp:UpdatePanel ID="upReportParams" UpdateMode="Always" runat="server">
        <ContentTemplate>
            <table cellpadding="0" cellspacing="0" id="tblOuter" border="0" style="height: 540px"
                dir="rtl">
                <tr>
                    <td colspan="2">
                    </td>
                </tr>
                <tr>
                    <td style="padding-right: 13px" colspan="2">
                        <asp:Label ID="Label2" runat="server" EnableTheming="false" CssClass="RegularUpdateButton"
                            Text="דוחות"></asp:Label>
                    </td>
                </tr>
                <tr id='ReportName' style="padding-top: 0px; padding-bottom: 0px">
                    <td style="padding-right: 12px; padding-top: 1px; padding-bottom: 1px;" colspan="2">
                        <table cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7">
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
                                    <div style="width: 900px;">
                                        <asp:DropDownList ID="ddlReport" AutoPostBack="true" Width="450px" runat="server"
                                            DataValueField="ID" DataTextField="reportTitle" OnSelectedIndexChanged="ddlReport_SelectedIndexChanged"
                                            Font-Size="13pt">
                                        </asp:DropDownList>
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
                <tr style='height: 400px;'>
                    <%-------------Search Parameters--------------------------------------%>
                    <td id='tdSearchParameters' valign="top">
                        <table>
                            <tr id='SearchParametersCaption'>
                                <td style="padding-right: 13px">
                                    <asp:Label ID="Label1" runat="server" EnableTheming="false" CssClass="RegularUpdateButton"
                                        Text="תנאי חיפוש"></asp:Label>
                                </td>
                            </tr>
                            <tr id='trSearchParameters'>
                                <td style="padding-right: 10px">
                                    <table cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7">
                                        <tr id='BorderTop'>
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
                                        <tr id='tdSearchParameters_'>
                                            <td id='borderRight' style="border-right: solid 2px #909090;">
                                                <div style="width: 6px;">
                                                </div>
                                            </td>
                                            <td id='tdSearchParameters__'>
                                                <div id="divRepParameters" style="width: 400px; height: 1050px" runat="server">
                                                    <!---------------------------------------->
                                                    <table border="0" cellpadding="0" cellspacing="0" id="tblParams" width="100%">
                                                       <!--------------Membership---------------------------->
                                                        <tr id="trMembership" runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td style="padding-right: 1px; padding-top: 5px; width:80px">
                                                                <asp:Label ID="LblMembership" runat="server" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                    Text="שיוך ארגוני:"></asp:Label>
                                                            </td>
                                                            <td style="width:260px">
                                                                <uc1:ModeSelector ID="lstMembership" runat="server" AutoPostBack = "true"
                                                                 OnSelectedIndexChanged = "Membership_SelectedIndexChanged" />
                                                            </td>
                                                            <td style="width:50px"></td>
                                                            <td></td>
                                                        </tr>
                                                        <!--------------District---------------------------->
                                                        <tr id='trDistrict' runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td valign="bottom" style="width:80px">
                                                                <asp:Label ID="Label10" runat="server" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                                    Text="מחוז:"></asp:Label>
                                                            </td>
                                                            <td style="padding-left: 1px;">
                                                                <asp:TextBox ID="txtDistrictList" runat="server" Height="20px" CssClass="TextBoxMultiLine"
                                                                    EnableTheming="false" TextMode="MultiLine" Width="250px" 
                                                                    ontextchanged="District_TextChanged" AutoPostBack="True"></asp:TextBox>
                                                            </td>
                                                            <td>
                                                                <input id="btnDistrict" onclick="SelectDistrict(); return false;" src="../Images/Applic/icon_magnify.gif"
                                                                    style="cursor: pointer;" type="image" runat="server" />
                                                            </td>
                                                            <td style="display: none;">
                                                                <asp:TextBox ID="txtDistrictCodes" runat="server" TextMode="multiLine" Width="16px"
                                                                    Height="19px"></asp:TextBox>
                                                            </td>
                                                        </tr>
                                                        <%--<tr id="trDistrict" runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td width="120px" valign="bottom">
                                                                <asp:Label ID="Label6" runat="server" EnableTheming="false" Text="מחוז:" CssClass="LabelBoldDirtyBlue"></asp:Label>
                                                            </td>
                                                            <td width="260">
                                                                <asp:DropDownList ID="ddlDistrict" Width="100%" ctlGroup="QueryParameterCtl" HeaderControl="lblDistrict"
                                                                    AutoPostBack="true" DataFieldName="dept.districtCode" runat="server" AppendDataBoundItems="True"
                                                                    DataTextField="districtName" DataValueField="districtCode" OnSelectedIndexChanged="ddlDistrict_SelectedIndexChanged">
                                                                </asp:DropDownList>
                                                            </td>
                                                            <td>
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>--%>
                                                        <!--------------AdminClinic----------------------------->
                                                        <tr id='trAdminClinic' runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td valign="bottom" style="width:80px">
                                                                <asp:Label ID="lblAdminClinic" Width="30px" runat="server" EnableTheming="false"
                                                                    CssClass="LabelBoldDirtyBlue" Text="מנהלת:"></asp:Label>
                                                            </td>
                                                            <td align="right">
                                                                <asp:DropDownList ID="ddlAdminClinic" Width="254px" ctlGroup="QueryParameterCtl" HeaderControl="lblAdminClinic"
                                                                    AutoPostBack="true" DataFieldName="deptCode" runat="server" AppendDataBoundItems="True"
                                                                    DataTextField="deptname" DataValueField="deptCode">
                                                                    <%--<asp:ListItem Text="כל המנהלות" Value=""></asp:ListItem>--%>
                                                                </asp:DropDownList>
                                                            </td>
                                                            <td>
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>
                                                        <!------------City----------------------------->
                                                        <tr id='trCity' runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td valign="bottom" style="width:80px">
                                                                <asp:Label ID="lblCity" runat="server" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                                    Text="ישוב:"></asp:Label>
                                                            </td>
                                                            <td style="padding-left: 1px;">
                                                                <asp:TextBox ID="txtCitiesList" runat="server" Height="20px" CssClass="TextBoxMultiLine"
                                                                    EnableTheming="false" TextMode="MultiLine" Width="250px"></asp:TextBox>
                                                            </td>
                                                            <td>
                                                                <input id="btnSelectCities" onclick="SelectCities(); return false;" src="../Images/Applic/icon_magnify.gif"
                                                                    style="cursor: pointer;" type="image" runat="server" />
                                                            </td>
                                                            <td style="display: none;">
                                                                <asp:TextBox ID="txtCitiesListCodes" runat="server" TextMode="multiLine" Width="16px"
                                                                    Height="19px"></asp:TextBox>
                                                            </td>
                                                        </tr>
                                                        <!--------------UnitType--------------------------->
                                                        <tr id='trUnitType' runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td id="tdUnitType" style="padding-right: 1px; padding-top: 5px;width:80px" runat="server">
                                                                <asp:Label ID="lblUnitType" runat="server" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                    Text="סוג יחידה:"></asp:Label>
                                                            </td>
                                                            <td style="padding-left: 1px;">
                                                                <asp:TextBox ID="txtUnitTypeList" runat="server" Width="250px" TextMode="MultiLine"
                                                                    Height="20px" CssClass="TextBoxMultiLine" EnableTheming="false" OnTextChanged="txtUnitTypeList_TextChanged"></asp:TextBox>
                                                            </td>
                                                            <td>
                                                                <input type="image" runat="server" id="btnUnitTypeListPopUp" style="cursor: hand;"
                                                                    src="../Images/Applic/icon_magnify.gif" onclick="SelectUnitType();" />
                                                            </td>
                                                            <td style="display: none;">
                                                                <asp:TextBox ID="txtUnitTypeListCodes" runat="server" TextMode="multiLine" Width="16px"
                                                                    Height="19px"></asp:TextBox>
                                                            </td>
                                                        </tr>
                                                        <!--------------SubClinicUnitType--------------------------->
                                                        <tr id='trSubClinicUnitType' runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td id="tdSubClinicUnitType" style="padding-right: 1px; padding-top: 5px;width:80px" runat="server">
                                                                <asp:Label ID="lbSubCliniclUnitType" runat="server" CssClass="LabelBoldDirtyBlue"
                                                                    EnableTheming="false" Text="סוג יחידה כפופה:"></asp:Label>
                                                            </td>
                                                            <td style="padding-left: 1px;">
                                                                <asp:TextBox ID="txtSubClinicUnitTypeList" runat="server" Width="250px" TextMode="MultiLine"
                                                                    Height="20px" CssClass="TextBoxMultiLine" EnableTheming="false"></asp:TextBox><%--OnTextChanged="txtUnitTypeList_TextChanged"--%>
                                                            </td>
                                                            <td>
                                                                <input type="image" runat="server" id="btnSubClinicUnitTypeListPopUp" style="cursor: hand;"
                                                                    src="../Images/Applic/icon_magnify.gif" onclick="SelectSubClinicUnitType();" />
                                                            </td>
                                                            <td style="display: none;">
                                                                <asp:TextBox ID="txtSubClinicUnitTypeListCodes" runat="server" TextMode="multiLine"
                                                                    Width="16px" Height="19px"></asp:TextBox>
                                                            </td>
                                                        </tr>


                                                        <!---------SubUnitType------------------------>
                                                        <tr id='trSubUnitType' runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td style="padding-right:1px; padding-top:5px;width:80px" runat="server">
                                                                <asp:Label Width="60px" ID="lblSubUnitType" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                                    runat="server" Text="שיוך:"></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="ddlSubUnitType" runat="server" Width="254px" DataTextField="subUnitTypeName"
                                                                    DataValueField="subUnitTypeCode">
                                                                </asp:DropDownList>
                                                            </td>
                                                            <td valign="top">
                                                            </td>
                                                            <td style="display: none;">
                                                                <asp:TextBox ID="txtSubUnitTypeListCodes" runat="server" TextMode="multiLine" Width="16px"
                                                                    Height="18px"></asp:TextBox>
                                                            </td>
                                                        </tr>
                                                        <!-------------Sector -- מיגזר --------------------------------->
                                                        <tr id='trSector' runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td style="padding-right: 1px; padding-top: 5px;width:80px">
                                                                <asp:Label ID="lblSector" runat="server" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                    Text="מיגזר:"></asp:Label>
                                                            </td>
                                                            <td style="padding-top: 1px">
                                                                <asp:DropDownList ID="ddlSector" Width="254px" ctlGroup="QueryParameterCtl" HeaderControl="lblSector"
                                                                    runat="server" DataFieldName="dept.populationSectorCode" DataTextField="PopulationSectorDescription"
                                                                    DataValueField="PopulationSectorID" AppendDataBoundItems="True">
                                                                </asp:DropDownList>
                                                            </td>
                                                            <td>
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>
                                                        <!-----------Services------------------------------->
                                                        <tr id='trServices' runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td style="padding-right: 1px; padding-top: 5px;width:80px">
                                                                <asp:Label ID="lblServices" runat="server" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                    Text="שירות:"></asp:Label><%--Width="40px"--%>
                                                            </td>
                                                            <td style="padding-left: 1px;">
                                                                <asp:TextBox ID="txtServicesList" runat="server" Height="20px" TextMode="MultiLine"
                                                                    CssClass="TextBoxMultiLine" EnableTheming="false" Width="250px"></asp:TextBox>
                                                            </td>
                                                            <td>
                                                                <input id="btnServicesListPopUp" onclick="SelectServices()" src="../Images/Applic/icon_magnify.gif"
                                                                    style="cursor:pointer;" type="image" value="בחר" />
                                                            </td>
                                                            <td style="display: none;">
                                                                <asp:TextBox ID="txtServicesListCodes" runat="server" EnableTheming="false" TextMode="MultiLine"
                                                                    Width="36px" Height="19px"></asp:TextBox><%--CssClass="DisplayNone"--%>
                                                            </td>
                                                        </tr>
                                                        <!-------------- EmployeeSector ---------------------------->
                                                        <tr id="trEmployeeSector" runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td style="padding-right: 1px; padding-top: 8px; width: 80px;" id="td2" runat="server">
                                                                <asp:Label ID="LabelEmployeeSector" runat="server" EnableTheming="false" Text="סקטור:"
                                                                    CssClass="LabelBoldDirtyBlue"></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="ddlEmployeeSector" Width="254px" AutoPostBack="true" runat="server"
                                                                    AppendDataBoundItems="True" OnSelectedIndexChanged="ddlEmployeeSector_SelectedIndexChanged">
                                                                </asp:DropDownList>
                                                            </td>
                                                            <td>
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>
                                                        <!------------Profession------------------------------>
                                                        <tr id='trProfession' runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td style="padding-right: 1px; padding-top: 5px;width:80px">
                                                                <asp:Label ID="Label7" runat="server" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                    Text="מקצוע:"></asp:Label>
                                                            </td>
                                                            <td style="padding-left: 1px;">
                                                                <asp:TextBox ID="txtProfessionList" runat="server" Height="20px" CssClass="TextBoxMultiLine"
                                                                    EnableTheming="false" TextMode="MultiLine" Width="250px"></asp:TextBox>
                                                            </td>
                                                            <td>
                                                                <input id="btnProfessionListPopUp" runat="server" onclick="SelectProfession(); "
                                                                    src="../Images/Applic/icon_magnify.gif" style="cursor: pointer;" type="image" />
                                                            </td>
                                                            <td style="display: none;">
                                                                <asp:TextBox ID="txtProfessionListCodes" runat="server" TextMode="multiLine" Width="16px"
                                                                    Height="19px"></asp:TextBox>
                                                            </td>
                                                        </tr>
                                                        <!------------ExpertProfession------------------------------>
                                                        <tr id='trExpertProfession' runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td style="padding-right: 1px; padding-top: 5px;width:80px">
                                                                <asp:Label ID="Label8" runat="server" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                    Text="מומחיות:"></asp:Label>
                                                            </td>
                                                            <td style="padding-left: 1px;">
                                                                <asp:TextBox ID="txtExpertProfList" runat="server" Height="20px" CssClass="TextBoxMultiLine"
                                                                    EnableTheming="false" TextMode="MultiLine" Width="250px"></asp:TextBox>
                                                            </td>
                                                            <td>
                                                                <input id="btnExpertProfListPopUp" runat="server" onclick="SelectExpertProfession(); "
                                                                    src="../Images/Applic/icon_magnify.gif" style="cursor: hand;" type="image" />
                                                            </td>
                                                            <td style="display: none;">
                                                                <asp:TextBox ID="txtExpertProfListCodes" runat="server" TextMode="multiLine" Width="16px"
                                                                    Height="19px"></asp:TextBox>
                                                            </td>
                                                        </tr>
                                                        <!--------------Status----------------------------->
                                                        <tr id="trStatus" runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td style="padding-right: 1px; padding-top: 5px;width:80px">
                                                                <asp:Label ID="lblDeptStatus" runat="server" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                                    Text="סטטוס:"></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="ddlStatus" Width="254px" AppendDataBoundItems="True" runat="server"
                                                                    DataTextField="statusDescription" DataValueField="status">
                                                                </asp:DropDownList>
                                                            </td>
                                                            <td>
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>

                                                         <!--------------SubClinicStatus----------------------------->
                                                        <tr id="trSubClinicStatus" runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td style="padding-right: 1px; padding-top: 5px;width:80px">
                                                                <asp:Label ID="lblSubClinicStatus" runat="server" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                                    Text="סטטוס יחידה כפופה:"></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="ddlSubClinicStatus" Width="254px" AppendDataBoundItems="True" runat="server"
                                                                    DataTextField="statusDescription" DataValueField="status">
                                                                </asp:DropDownList>
                                                            </td>
                                                            <td>
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>
                                                        <!--------------DeptEmpStatus----------------------------->
                                                        <tr id="trDeptEmpStatus" runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td style="padding-right: 3px; padding-top: 5px;width:80px">
                                                                <asp:Label ID="lblDeptEmpStatus" runat="server" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                                    Text="סטטוס ביחידה:"></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="ddlDeptEmpStatus" Width="254px" AppendDataBoundItems="True"
                                                                    runat="server" DataTextField="statusDescription" DataValueField="status">
                                                                </asp:DropDownList>
                                                            </td>
                                                            <td>
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>
                                                        <!--------------ServiceGivenBy---------------------------->
                                                        <tr id="trServiceGivenBy" runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td style="padding-right: 1px; padding-top: 8px; width: 80px" id="td1" runat="server">
                                                                <asp:Label ID="Label4" runat="server" EnableTheming="false" Text="ניתן ע``י:" CssClass="LabelBoldDirtyBlue"></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="ddlServiceGivenBy" Width="254px" AutoPostBack="true" runat="server"
                                                                    AppendDataBoundItems="True">
                                                                </asp:DropDownList>
                                                            </td>
                                                            <td>
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>
                                                        <!------------ObjectType------------------------------>
                                                        <tr id="trObjectType" runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td style="padding-right: 1px; padding-top: 5px;width:80px">
                                                                <asp:Label ID="Label5" runat="server" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                    Text="טיפוס:"></asp:Label>
                                                            </td>
                                                            <td style="padding-left: 1px;">
                                                                <asp:TextBox ID="txtObjectType" runat="server" Height="20px" CssClass="TextBoxMultiLine"
                                                                    EnableTheming="false" TextMode="MultiLine" Width="250px"></asp:TextBox>
                                                            </td>
                                                            <td>
                                                                <input id="btnObjectType" onclick="SelectObjectType(); " src="../Images/Applic/icon_magnify.gif"
                                                                    style="cursor: pointer;" type="image" />
                                                            </td>
                                                            <td style="display: none;">
                                                                <asp:TextBox ID="txtObjectTypeCodes" runat="server" TextMode="multiLine" Width="16px"
                                                                    Height="19px"></asp:TextBox>
                                                            </td>
                                                        </tr>
                                                        <!-------------- EmployeeIndependent --------------------------->
                                                        <tr id="trDeptProperty" runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td style="padding-right: 1px; padding-top: 8px; width: 80px" id="tdDeptProperty"
                                                                runat="server">
                                                                <asp:Label ID="LabelDeptProperty" runat="server" EnableTheming="false" Text="שינויים עתידיים של:"
                                                                    CssClass="LabelBoldDirtyBlue"></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="DdlDeptProperty" Width="254px" AutoPostBack="true" runat="server"
                                                                    AppendDataBoundItems="True">
                                                                </asp:DropDownList>
                                                            </td>
                                                            <td>
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>
                                                        <%---------------Valid from Date---------------------------%>
                                                        <tr id="trValidFrom" runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td style="width:80px">
                                                                <asp:Label ID="LabelValidFrom" runat="server" Text="תוקף מ:" CssClass="LabelBoldDirtyBlue"
                                                                    EnableTheming="false"></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:TextBox ID="txtValidFrom" Width="80px" runat="server" onchange="UnCheckCbValidNow()"></asp:TextBox>
                                                                <asp:ImageButton ID="btnRunCalendarValidFrom" ImageUrl="~/Images/Applic/calendarIcon.png"
                                                                    runat="server" />
                                                                <cc1:CalendarExtender ID="calendarExtValidFrom" runat="server" Format="dd/MM/yyyy"
                                                                    TargetControlID="txtValidFrom" FirstDayOfWeek="Sunday" PopupPosition="BottomRight"
                                                                    PopupButtonID="btnRunCalendarValidFrom" Enabled="True">
                                                                </cc1:CalendarExtender>
                                                            </td>
                                                            <td>
                                                                <cc1:MaskedEditExtender ID="ValidFrom_Extender" runat="server" ErrorTooltipEnabled="True"
                                                                    TargetControlID="txtValidFrom" Mask="99/99/9999" MaskType="Date" Enabled="True">
                                                                    <%--ClearMaskOnLostFocus="false"--%>
                                                                </cc1:MaskedEditExtender>
                                                                <cc1:MaskedEditValidator ID="ValidFrom_Validator" runat="server" ControlToValidate="txtValidFrom"
                                                                    Display="Dynamic" ControlExtender="ValidFrom_Extender" InvalidValueMessage="התאריך אינו תקין"
                                                                    InvalidValueBlurredMessage="*" ValidationGroup="ValidGroup_ValidFromTo" Text="*"
                                                                    ErrorMessage="התאריך אינו תקין" ToolTip="התאריך אינו תקין" /><%--TooltipMessage="התאריך אינו תקין3"--%>
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>
                                                        <%---------------Valid To Date--------------------------%>
                                                        <tr id="trValidTo" runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td style="width:80px">
                                                                <asp:Label ID="LblValidTo" runat="server" Text="תוקף עד:" CssClass="LabelBoldDirtyBlue"
                                                                    EnableTheming="false"></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:TextBox ID="txtValidTo" Width="80px" runat="server" onchange="UnCheckCbValidNow()"></asp:TextBox>
                                                                <asp:ImageButton ID="btnRunCalendarValidTo" ImageUrl="~/Images/Applic/calendarIcon.png"
                                                                    runat="server" />
                                                                <cc1:CalendarExtender ID="calendarExtValidTo" runat="server" Format="dd/MM/yyyy"
                                                                    TargetControlID="txtValidTo" FirstDayOfWeek="Sunday" PopupPosition="BottomRight"
                                                                    PopupButtonID="btnRunCalendarValidTo" Enabled="True">
                                                                </cc1:CalendarExtender>
                                                                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                                                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                                                <asp:CheckBox ID="cbValidNow" runat="server" CssClass="RegularLabel" OnClick="ClearVlidFromTo()" AutoPostBack="false" Text="בתוקף" />
                                                            </td>
                                                            <td>
                                                                <cc1:MaskedEditExtender ID="ValidTo_Extender" runat="server" ErrorTooltipEnabled="True"
                                                                    TargetControlID="txtValidTo" Mask="99/99/9999" MaskType="Date" Enabled="True">
                                                                </cc1:MaskedEditExtender>
                                                                <cc1:MaskedEditValidator ID="ValidTo_Validator" runat="server" ErrorMessage="התאריך אינו תקין"
                                                                    ControlToValidate="txtValidTo" InvalidValueMessage="התאריך אינו תקין" Display="Dynamic"
                                                                    ControlExtender="ValidTo_Extender" Text="*" InvalidValueBlurredMessage="*" ValidationGroup="ValidGroup_ValidFromTo"
                                                                    ToolTip="התאריך אינו תקין" />
                                                                <asp:CustomValidator runat="server" ID="ValidatorValidTo" ErrorMessage="טווח תאריכים אינו תקין"
                                                                    ControlToValidate="txtValidTo" Text="*" ValidateEmptyText="false" ValidationGroup="ValidGroup_ValidFromTo"
                                                                    ClientValidationFunction="compareDates" ToolTip="טווח תאריכים אינו תקין"></asp:CustomValidator>
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>
                                                        <!-------------- Employee Agreement Type --------------------------->
                                                        <tr id="trAgreementType" runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td style="padding-right: 1px; padding-top: 8px; width: 80px" id="td5" runat="server">
                                                                <asp:Label ID="lblAgreementType" runat="server" EnableTheming="false" Text="סוג הסכם:"
                                                                    CssClass="LabelBoldDirtyBlue"></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="ddlAgreementType" Width="254px" AutoPostBack="true" runat="server"
                                                                    AppendDataBoundItems="True">
                                                                </asp:DropDownList>
                                                            </td>
                                                            <td>
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>
                                                        <!-------------- EmployeeSex---------------------------->
                                                        <tr id="trEmployeeSex" runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td style="padding-right: 1px; padding-top: 8px; width:80px" id="td3" runat="server">
                                                                <asp:Label ID="LblEmployeeSex" runat="server" EnableTheming="false" Text="מגדר:"
                                                                    CssClass="LabelBoldDirtyBlue"></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="DdlEmployeeSex" Width="254px" AutoPostBack="true" runat="server"
                                                                    AppendDataBoundItems="True">
                                                                </asp:DropDownList>
                                                            </td>
                                                            <td>
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>
                                                        <!-------------- EmployeePosition --------------------------->
                                                        <tr id="trEmployeePosition" runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td style="padding-right: 1px; padding-top: 8px; width:80px" id="td4" runat="server">
                                                                <asp:Label ID="LblEmployeePosition" runat="server" EnableTheming="false" Text="תפקיד:"
                                                                    CssClass="LabelBoldDirtyBlue"></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="DdlEmployeePosition" Width="254px" AutoPostBack="true" runat="server"
                                                                    AppendDataBoundItems="True">
                                                                </asp:DropDownList>
                                                            </td>
                                                            <td>
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>
                                                        <!------------EmployeeLanguage------------------------------>
                                                        <tr id="trEmployeeLanguage" runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td style="padding-right: 1px; padding-top: 5px;width:80px">
                                                                <asp:Label ID="LblEmployeeLanguage" runat="server" CssClass="LabelBoldDirtyBlue"
                                                                    EnableTheming="false" Text="שפות:"></asp:Label>
                                                            </td>
                                                            <td style="padding-left: 1px;">
                                                                <asp:TextBox ID="txtEmployeeLanguage" runat="server" Height="20px" CssClass="TextBoxMultiLine"
                                                                    EnableTheming="false" TextMode="MultiLine" Width="250px"></asp:TextBox>
                                                            </td>
                                                            <td>
                                                                <input id="BtnEmployeeLanguage" onclick="SelectEmployeeLanguage(); " src="../Images/Applic/icon_magnify.gif"
                                                                    style="cursor: pointer;" type="image" />
                                                            </td>
                                                            <td style="display: none;">
                                                                <asp:TextBox ID="txtEmployeeLanguageCodes" runat="server" TextMode="multiLine" Width="16px"
                                                                    Height="19px"></asp:TextBox>
                                                            </td>
                                                        </tr>
                                                        <!------------Events------------------------------>
                                                        <tr id="trEvent" runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td style="padding-right: 1px; padding-top: 5px;width:80px">
                                                                <asp:Label ID="LabelEvent" runat="server" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                    Text="פעילויות:"></asp:Label>
                                                            </td>
                                                            <td style="padding-left: 1px;">
                                                                <asp:TextBox ID="txtEvent" runat="server" Height="20px" CssClass="TextBoxMultiLine"
                                                                    EnableTheming="false" TextMode="MultiLine" Width="250px"></asp:TextBox>
                                                            </td>
                                                            <td>
                                                                <input id="ImageEvent" onclick="SelectEvent(); " src="../Images/Applic/icon_magnify.gif"
                                                                    style="cursor: pointer;" type="image" />
                                                            </td>
                                                            <td style="display: none;">
                                                                <asp:TextBox ID="txtEventCodes" runat="server" TextMode="multiLine" Width="16px"
                                                                    Height="19px"></asp:TextBox>
                                                            </td>
                                                        </tr>
                                                        <!---------------EventStartDate_cond--------------------------->
                                                        <tr id="trEventStartDate" runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td style="width:80px">
                                                                <asp:Label ID="LabelEventStartDate" runat="server" Text="התחלת פעילות:" CssClass="LabelBoldDirtyBlue"
                                                                    EnableTheming="false"></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:TextBox ID="TxtEventStartDate" Width="80px" runat="server"></asp:TextBox>
                                                                <asp:ImageButton ID="ImageButton_EventStartDate" ImageUrl="~/Images/Applic/calendarIcon.png"
                                                                    runat="server" />
                                                                <cc1:CalendarExtender ID="CalendarExtender_EventStartDate" runat="server" Format="dd/MM/yyyy"
                                                                    TargetControlID="TxtEventStartDate" FirstDayOfWeek="Sunday" PopupPosition="BottomRight"
                                                                    PopupButtonID="ImageButton_EventStartDate" Enabled="True">
                                                                </cc1:CalendarExtender>
                                                            </td>
                                                            <td>
                                                                <cc1:MaskedEditExtender ID="MaskedEditExtender_EventStartDate" runat="server" ErrorTooltipEnabled="True"
                                                                    TargetControlID="TxtEventStartDate" Mask="99/99/9999" MaskType="Date" Enabled="True">
                                                                    <%--ClearMaskOnLostFocus="false"--%>
                                                                </cc1:MaskedEditExtender>
                                                                <cc1:MaskedEditValidator ID="MaskedEditValidator_EventStartDate" runat="server" ControlToValidate="TxtEventStartDate"
                                                                    Display="Dynamic" ControlExtender="MaskedEditExtender_EventStartDate" InvalidValueMessage="התאריך אינו תקין"
                                                                    InvalidValueBlurredMessage="*" ValidationGroup="ValidGroup_EventStartFinish"
                                                                    Text="*" ErrorMessage="התאריך אינו תקין" ToolTip="התאריך אינו תקין" /><%--TooltipMessage="התאריך אינו תקין3"--%>
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>
                                                        <!---------------EventFinishDate -------------------------->
                                                        <tr id="trEventFinishDate" runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td style="width:80px">
                                                                <asp:Label ID="LabelEventFinishDate" runat="server" Text="סיום פעילות:" CssClass="LabelBoldDirtyBlue"
                                                                    EnableTheming="false"></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:TextBox ID="TxtEventFinishDate" Width="80px" runat="server"></asp:TextBox>
                                                                <asp:ImageButton ID="btnRunEventFinishDate" ImageUrl="~/Images/Applic/calendarIcon.png"
                                                                    runat="server" />
                                                                <cc1:CalendarExtender ID="CalendarExtender_EventFinishDate" runat="server" Format="dd/MM/yyyy"
                                                                    TargetControlID="txtEventFinishDate" FirstDayOfWeek="Sunday" PopupPosition="BottomRight"
                                                                    PopupButtonID="btnRunEventFinishDate" Enabled="True">
                                                                </cc1:CalendarExtender>
                                                            </td>
                                                            <td>
                                                                <cc1:MaskedEditExtender ID="MaskedEditExtender_EventFinishDate" runat="server" ErrorTooltipEnabled="True"
                                                                    TargetControlID="txtEventFinishDate" Mask="99/99/9999" MaskType="Date" Enabled="True">
                                                                </cc1:MaskedEditExtender>
                                                                <cc1:MaskedEditValidator ID="MaskedEditValidator_EventFinishDate" runat="server"
                                                                    ErrorMessage="התאריך אינו תקין" ControlToValidate="txtEventFinishDate" InvalidValueMessage="התאריך אינו תקין"
                                                                    Display="Dynamic" ControlExtender="MaskedEditExtender_EventFinishDate" Text="*"
                                                                    InvalidValueBlurredMessage="*" ValidationGroup="ValidGroup_EventStartFinish"
                                                                    ToolTip="התאריך אינו תקין" />
                                                                <asp:CustomValidator runat="server" ID="ValidatorEventFinishDate" ErrorMessage="טווח תאריכים אינו תקין"
                                                                    ControlToValidate="txtEventFinishDate" Text="*" ValidateEmptyText="false" ValidationGroup="ValidGroup_EventStartFinish"
                                                                    ClientValidationFunction="compareDates" ToolTip="טווח תאריכים אינו תקין"></asp:CustomValidator>
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>
                                                        <!-------------- RemarkType --------------------------->
                                                        <tr id="trRemarkType" runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td style="padding-right: 1px; padding-top: 8px; width: 65px" id="td6" runat="server">
                                                                <asp:Label ID="LblRemarkType" runat="server" EnableTheming="false" Text="סוג הערה:"
                                                                    CssClass="LabelBoldDirtyBlue"></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="ddlRemarkType" Width="254px" AutoPostBack="true" runat="server"
                                                                    AppendDataBoundItems="True">
                                                                </asp:DropDownList>
                                                            </td>
                                                            <td>
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>
                                                        <!------------Remark------------------------------>
                                                        <tr id="trRemark" runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td style="padding-right: 1px; padding-top: 5px;width:80px">
                                                                <asp:Label ID="LblRemark" runat="server" CssClass="LabelBoldDirtyBlue" EnableTheming="false"
                                                                    Text="הערה:"></asp:Label>
                                                            </td>
                                                            <td style="padding-right: 1px; padding-left: 1px;">
                                                                <asp:TextBox ID="txtRemark" runat="server" Height="20px" CssClass="TextBoxMultiLine"
                                                                    EnableTheming="false" TextMode="MultiLine" Width="250px"></asp:TextBox>
                                                            </td>
                                                            <td>
                                                                <input id="btnRemark" onclick="SelectRemark(); " src="../Images/Applic/icon_magnify.gif"
                                                                    style="cursor: pointer;" type="image" />
                                                            </td>
                                                            <td style="display:none">
                                                                <asp:TextBox ID="txtRemarkCodes" runat="server" TextMode="multiLine" Width="36px"
                                                                    Height="19px"></asp:TextBox>
                                                            </td>
                                                        </tr>
                                                        <!-------------- IsConstantRemark --------------------------->
                                                        <tr id="trIsConstantRemark" runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td style="padding-right: 1px; padding-top: 8px; width: 80px" id="td7" runat="server">
                                                                <asp:Label ID="LblIsConstantRemark" runat="server" EnableTheming="false" Text="הערה קבועה:"
                                                                    CssClass="LabelBoldDirtyBlue"></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="DdlIsConstantRemark" Width="254px" AutoPostBack="true" runat="server"
                                                                    AppendDataBoundItems="True">
                                                                </asp:DropDownList>
                                                            </td>
                                                            <td>
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>
                                                        <!-------------- IsSharedRemark --------------------------->
                                                        <tr id="trIsSharedRemark" runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td style="padding-right: 1px; padding-top: 8px; width: 80px" id="td8" runat="server">
                                                                <asp:Label ID="LblIsSharedRemark" runat="server" EnableTheming="false" Text="הערה גורפת:"
                                                                    CssClass="LabelBoldDirtyBlue"></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="DdlIsSharedRemark" Width="254px" AutoPostBack="true" runat="server"
                                                                    AppendDataBoundItems="True">
                                                                </asp:DropDownList>
                                                            </td>
                                                            <td>
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>
                                                        <!-------------- ShowInInternet--------------------------->
                                                        <tr id="trShowInInternet" runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td style="padding-right: 1px; padding-top: 8px; width: 80px" id="td9" runat="server">
                                                                <asp:Label ID="LblShowInInternet" runat="server" EnableTheming="false" Text="לתצוגה באינטרנט:"
                                                                    CssClass="LabelBoldDirtyBlue"></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="DdlShowInInternet" Width="254px" AutoPostBack="true" runat="server"
                                                                    AppendDataBoundItems="True">
                                                                </asp:DropDownList>
                                                            </td>
                                                            <td>
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>
                                                        <!-------------- ShowRemarkInInternet--------------------------->
                                                        <tr id="trShowRemarkInInternet" runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td style="padding-right: 1px; padding-top: 8px; width: 80px" id="tdShowRemarkInInternet"
                                                                runat="server">
                                                                <asp:Label ID="LabelShowRemarkInInternet" runat="server" EnableTheming="false" Text="לתצוגה באינטרנט:"
                                                                    CssClass="LabelBoldDirtyBlue"></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="DdlShowRemarkInInternet" Width="254px" AutoPostBack="true" runat="server"
                                                                    AppendDataBoundItems="True">
                                                                </asp:DropDownList>
                                                            </td>
                                                            <td>
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>
                                                        <!-------------- IsFutureRemark --------------------------->
                                                        <tr id="trIsFutureRemark" runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td style="padding-right: 1px; padding-top: 8px; width: 80px" id="td10" runat="server">
                                                                <asp:Label ID="LblIsFutureRemark" runat="server" EnableTheming="false" Text="הערה עתידית:"
                                                                    CssClass="LabelBoldDirtyBlue"></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="DdlIsFutureRemark" Width="254px" AutoPostBack="true" runat="server"
                                                                    AppendDataBoundItems="True">
                                                                </asp:DropDownList>
                                                            </td>
                                                            <td>
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>
                                                        <!-------------- IsValidRemark --------------------------->
                                                        <tr id="trIsValidRemark" runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td style="padding-right: 1px; padding-top: 8px; width: 80px" id="tdIsValidRemark" runat="server">
                                                                <asp:Label ID="LblIsValidRemark" runat="server" EnableTheming="false" Text="הערות בתוקף:"
                                                                    CssClass="LabelBoldDirtyBlue"></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="DdlIsValidRemark" Width="254px" AutoPostBack="true" runat="server"
                                                                    AppendDataBoundItems="True">
                                                                </asp:DropDownList>
                                                            </td>
                                                            <td>
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>
                                                        <!-------------- RemarkAtrributedToAllClinics --------------------------->
                                                        <tr id="trRemarkAttributedToAllClinics" runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td style="padding-right: 1px; padding-top: 8px; width: 80px" id="tdRemarkAttributedToAllClinics"
                                                                runat="server">
                                                                <asp:Label ID="Label9" runat="server" EnableTheming="false" Text="הערה לכל המרפאות:"
                                                                    CssClass="LabelBoldDirtyBlue"></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="DdlRemarkAttributedToAllClinics" Width="254px" AutoPostBack="true"
                                                                    runat="server" AppendDataBoundItems="True">
                                                                </asp:DropDownList>
                                                            </td>
                                                            <td>
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>
                                                        <!---------------ReceptionHoursSpan--------------------------->
                                                        <tr id="trReceptionHoursSpan" runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td style="width:80px">
                                                                <asp:Label ID="LabelReceptionHoursSpan" runat="server" Text="גודל הפער:" CssClass="LabelBoldDirtyBlue"
                                                                    EnableTheming="false"></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:TextBox ID="txtReceptionHoursSpan" runat="server" dir="ltr" Width="35px" onkeydown="return keyispressed(event, this);" onkeyup="return validateTime(event, this)"  MaxLength="5" autocomplete="off"></asp:TextBox>
                                                            </td>
                                                            <td>
                                                                <label id="labelReceptionHoursSpanError" style="color: red"></label>
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>
                                                        <!-------------- IncludeSubClinicEmployees --------------------------->
                                                        <tr id="trIncludeSubClinicEmployees" runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td style="padding-right: 1px; padding-top: 8px; width: 80px" id="td11" runat="server">
                                                                <asp:Label ID="LabelIncludeSubClinicEmployees" runat="server" EnableTheming="false"
                                                                    Text="להוסיף יחידות כפופות:" CssClass="LabelBoldDirtyBlue"></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="DdlIncludeSubClinicEmployees" Width="100%" AutoPostBack="true"
                                                                    runat="server" AppendDataBoundItems="True">
                                                                </asp:DropDownList>
                                                            </td>
                                                            <td>
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>
                                                        <!---------------DeptCode Span--------------------------->
                                                        <tr id="trDeptCode" runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td style="width:80px">
                                                                <asp:Label ID="lblDeptCode" runat="server" Text="קוד יחידה:" CssClass="LabelBoldDirtyBlue"
                                                                    EnableTheming="false"></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:TextBox ID="txtDepts" runat="server" Height="20px" TextMode="MultiLine"
                                                                    CssClass="TextBoxMultiLine" EnableTheming="false" Width="250px"></asp:TextBox>
                                                            </td>
                                                            <td>
                                                                <input id="btnDepts" onclick="SelectClinics(); return false;" src="../Images/Applic/icon_magnify.gif"
                                                                    style="cursor:pointer;" type="image" runat="server" />
                                                            </td>
                                                            <td style="display:none">
                                                                <asp:TextBox ID="txtDeptCodes" runat="server" TextMode="multiLine" Width="36px" EnableTheming="false"
                                                                    Height="19px"></asp:TextBox>                                                            
                                                            </td>
                                                        </tr>
                                                        <!-------------- Employee ------------------------------->
                                                        <tr id='trEmployee' runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td valign="bottom" style="width:80px">
                                                                <asp:Label ID="lblEmployee" Width="80px" runat="server" EnableTheming="false"
                                                                    CssClass="LabelBoldDirtyBlue" Text="שם נותן השירות:"></asp:Label>
                                                            </td>
                                                            <td align="right">
                                                                <asp:TextBox ID="txtEmployee" runat="server" Height="20px" TextMode="MultiLine"
                                                                    CssClass="TextBoxMultiLine" EnableTheming="false" Width="250px"></asp:TextBox>
                                                            </td>
                                                            <td>
                                                                <input id="btnEmployee" onclick="SelectEmployee(); return false;" src="../Images/Applic/icon_magnify.gif"
                                                                style="cursor:pointer;" type="image" runat="server" />
                                                            </td>
                                                            <td style="display: none;">
                                                                <asp:TextBox ID="txtEmployeeCodes" runat="server" TextMode="multiLine" Width="36px" EnableTheming="false"
                                                                    Height="19px"></asp:TextBox>                                                            
                                                            </td>
                                                        </tr>
                                                        <!-------------- ChangeType ----------------------------->
                                                        <tr id='trChangeType' runat="server" style="margin: 2px 0px 2px 0px;width:80px">
                                                            <td valign="bottom">
                                                                <asp:Label ID="lblChangeType" Width="80px" runat="server" EnableTheming="false"
                                                                    CssClass="LabelBoldDirtyBlue" Text="תחום השינוי:"></asp:Label>
                                                            </td>
                                                            <td align="right">
                                                                <asp:TextBox ID="txtChangeType" runat="server" Height="20px" TextMode="MultiLine"
                                                                    CssClass="TextBoxMultiLine" EnableTheming="false" Width="250px"></asp:TextBox>
                                                            </td>
                                                            <td>
                                                                <input id="btnChangeType" onclick="SelectChangeType(); return false;" src="../Images/Applic/icon_magnify.gif"
                                                                style="cursor:pointer;" type="image" runat="server" />
                                                            </td>
                                                            <td style="display:none">
                                                                <asp:TextBox ID="txtChangeTypeCodes" runat="server" TextMode="multiLine" Width="36px" EnableTheming="false"
                                                                    Height="19px"></asp:TextBox>                                                            
                                                            </td>
                                                        </tr>
                                                        <!-------------- UpdateUser ----------------------------->
                                                        <tr id='trUpdateUser' runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td valign="bottom" style="width:80px">
                                                                <asp:Label ID="lblUpdateUser" Width="80px" runat="server" EnableTheming="false"
                                                                    CssClass="LabelBoldDirtyBlue" Text="שם המעדכן:"></asp:Label>
                                                            </td>
                                                            <td align="right">
                                                                <asp:TextBox ID="txtUpdateUser" runat="server" Height="20px" TextMode="MultiLine"
                                                                    CssClass="TextBoxMultiLine" EnableTheming="false" Width="250px"></asp:TextBox>
                                                            </td>
                                                            <td>
                                                                <input id="btnUpdateUser" onclick="SelectUpdateUser(); return false;" src="../Images/Applic/icon_magnify.gif"
                                                                style="cursor:pointer;" type="image" runat="server" />
                                                            </td>
                                                            <td style="display: none">
                                                                <asp:TextBox ID="txtUpdateUserCodes" runat="server" TextMode="multiLine" Width="36px" EnableTheming="false"
                                                                    Height="19px"></asp:TextBox>                                                            
                                                            </td>
                                                        </tr>
                                                        <%---------------from Date---------------------------%>
                                                        <tr id="trFromDate" runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td style="width:80px">
                                                                <asp:Label ID="lblFromDate" runat="server" Text="מתאריך:" CssClass="LabelBoldDirtyBlue"
                                                                    EnableTheming="false"></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:TextBox ID="txtFromDate" Width="80px" runat="server"></asp:TextBox>
                                                                <asp:ImageButton ID="ImageButton_FromDate" ImageUrl="~/Images/Applic/calendarIcon.png"
                                                                    runat="server" />
                                                                <cc1:CalendarExtender ID="CalendarExtender_FromDate" runat="server" Format="dd/MM/yyyy"
                                                                    TargetControlID="txtFromDate" FirstDayOfWeek="Sunday" PopupPosition="BottomRight"
                                                                    PopupButtonID="ImageButton_FromDate" Enabled="True">
                                                                </cc1:CalendarExtender>
                                                            </td>
                                                            <td>
                                                                <cc1:MaskedEditExtender ID="MaskedEditExtender_FromDate" runat="server" ErrorTooltipEnabled="True"
                                                                    TargetControlID="txtFromDate" Mask="99/99/9999" MaskType="Date" Enabled="True">
                                                                    <%--ClearMaskOnLostFocus="false"--%>
                                                                </cc1:MaskedEditExtender>
                                                                <cc1:MaskedEditValidator ID="MaskedEditValidator_FromDate" runat="server" ControlToValidate="txtFromDate"
                                                                    Display="Dynamic" ControlExtender="MaskedEditExtender_FromDate" InvalidValueMessage="התאריך אינו תקין"
                                                                    InvalidValueBlurredMessage="*" ValidationGroup="ValidGroup_FromTo" Text="*"
                                                                    ErrorMessage="התאריך אינו תקין" ToolTip="התאריך אינו תקין" /><%--TooltipMessage="התאריך אינו תקין3"--%>
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>
                                                        <%---------------To Date--------------------------%>
                                                        <tr id="trToDate" runat="server" style="margin: 2px 0px 2px 0px">
                                                            <td style="width:80px">
                                                                <asp:Label ID="lblToDate" runat="server" Text="עד תאריך:" CssClass="LabelBoldDirtyBlue"
                                                                    EnableTheming="false"></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:TextBox ID="txtToDate" Width="80px" runat="server"></asp:TextBox>
                                                                <asp:ImageButton ID="ImageButton_ToDate" ImageUrl="~/Images/Applic/calendarIcon.png"
                                                                    runat="server" />
                                                                <cc1:CalendarExtender ID="CalendarExtender_ToDate" runat="server" Format="dd/MM/yyyy"
                                                                    TargetControlID="txtToDate" FirstDayOfWeek="Sunday" PopupPosition="BottomRight"
                                                                    PopupButtonID="ImageButton_ToDate" Enabled="True">
                                                                </cc1:CalendarExtender>
                                                            </td>
                                                            <td>
                                                                <cc1:MaskedEditExtender ID="MaskedEditExtender_ToDate" runat="server" ErrorTooltipEnabled="True"
                                                                    TargetControlID="txtToDate" Mask="99/99/9999" MaskType="Date" Enabled="True">
                                                                </cc1:MaskedEditExtender>
                                                                <cc1:MaskedEditValidator ID="MaskedEditValidator_ToDate" runat="server" ErrorMessage="התאריך אינו תקין"
                                                                    ControlToValidate="txtToDate" InvalidValueMessage="התאריך אינו תקין" Display="Dynamic"
                                                                    ControlExtender="MaskedEditExtender_ToDate" Text="*" InvalidValueBlurredMessage="*" ValidationGroup="ValidGroup_FromTo"
                                                                    ToolTip="התאריך אינו תקין" />
                                                                <asp:CustomValidator runat="server" ID="ValidatorToDate" ErrorMessage="טווח תאריכים אינו תקין"
                                                                    ControlToValidate="txtToDate" Text="*" ValidateEmptyText="false" ValidationGroup="ValidGroup_FromTo"
                                                                    ClientValidationFunction="compareDates" ToolTip="טווח תאריכים אינו תקין"></asp:CustomValidator>
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>

                                                    </table>
                                                    <!---------------------------------------->

                                                </div>
                                            </td>
                                            <td id="BorderLeft" style="border-left: solid 2px #909090;">
                                                <div style="width: 6px;">
                                                </div>
                                            </td>
                                            <tr id="BorderBottom" style="height: 10px">
                                                <td style="background-image: url('../Images/Applic/RBcornerGrey10.gif'); background-repeat: no-repeat; background-position: bottom right">
                                                </td>
                                                <td style="background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x; background-position: bottom">
                                                </td>
                                                <td style="background-image: url('../Images/Applic/LBcornerGrey10.gif'); background-repeat: no-repeat; background-position: bottom left">
                                                </td>
                                            </tr>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                    <%-------------Fields List------------------------------------------------------------%>
                    <td id="FieldsList" valign="top" style="padding-right: 3px">
                        <table width="60px">
                            <tr>
                                <td colspan="3">
                                    <table>
                                        <tr id="FieldsListCaption">
                                            <td style="padding-right: 6px">
                                                <asp:Label ID="Label3" runat="server" EnableTheming="false" CssClass="RegularUpdateButton">שדות להצגה</asp:Label>
                                            </td>
                                        </tr>
                                        <tr id="trFieldsList">
                                            <td>
                                                <table cellpadding="0" cellspacing="0" style="background-color: #F7F7F7">
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
                                                            <div id="divRepFields" style="height: 405px; width:460px" runat="server">
                                                                <%--width: 360px;--%>
                                                                <table>
                                                                    <tr>
                                                                        <td id="tdAllFields" style="vertical-align:top">
                                                                            <%-- style="width: 100px"--%>
                                                                            <table border="0">
                                                                                <tr>
                                                                                    <td>
                                                                                        <asp:Label ID="lblReportFields" runat="server" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                                                            Text="בחר שדות לדוח:"></asp:Label>
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td>
                                                                                        <asp:ListBox ID="lstReportFields" runat="server" Rows="7" SelectionMode="Multiple"
                                                                                            Width="175px" Height="350px"></asp:ListBox>
                                                                                    </td>
                                                                                </tr>

                                                                                <tr id="trShowCodes" runat="server" style="margin: 2px 0px 2px 0px" dir="ltr">
                                                                                    <td align="right">
                                                                                        <asp:CheckBox ID="cbShowCodes" runat="server" CssClass="LabelBoldDirtyBlue" AutoPostBack="false" Text=":הצגת קודי שדות" />
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
                                                                                            Text="בחר    >" CausesValidation="False" OnClick="btnAddFields_Click" ToolTip="בחר שדות מסומנים "
                                                                                            OnClientClick=" GetScrollPositionForNotSelected();"/>
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
                                                                                            Text="<  הסר  " CausesValidation="False" OnClick="btnRemoveFields_Click" ToolTip="הסר שדות מסומנים" 
                                                                                            OnClientClick=" GetScrollPositionForSelected();"
                                                                                            />
                                                                                    </td>
                                                                                    <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                                                        background-repeat: no-repeat;">
                                                                                    </td>
                                                                                </tr>
                                                                            </table>
                                                                        </td>
                                                                        <td id="tdSelectedFields" style="vertical-align:top">
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
                                                                                            Width="175px" Height="350px"></asp:ListBox>
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
                                                    CausesValidation="False" OnClick="btnExcel_Click" />                                            
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
            <asp:HiddenField ID="hdnScrollPositionForNotSelected" runat="server" />  
            <asp:HiddenField ID="hdnScrollPositionForSelected" runat="server" /> 
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
</asp:Content>
