<%@ Reference Page="~/Admin/AdminBasePage.aspx" %>
<%@ Page Language="C#" Title="עדכון פרטי יחידה" MasterPageFile="~/seferMasterPageIEwide.master"
    Culture="he-il" UICulture="he-il" AutoEventWireup="true"
    Inherits="UpdateClinicDetails" Codebehind="UpdateClinicDetails.aspx.cs" %>

<%@ Register Assembly="System.Web.Extensions, Version=1.0.61025.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
    Namespace="System.Web.UI" TagPrefix="asp" %>
<%@ MasterType VirtualPath="~/seferMasterPageIEwide.master" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<%@ Register Src="../UserControls/PhonesGridUC.ascx" TagName="PhonesGridUC" TagPrefix="UCphones" %>


<asp:Content ID="Content1" ContentPlaceHolderID="pageContent" runat="server">

    <script type="text/javascript" src="../Scripts/BrowserVersions.js"></script>

    <script type="text/javascript">
        var txtDistrictListClientID = '<%=txtDistrictList.ClientID %>';
        var txtDistrictCodesClientID = '<%=txtDistrictCodes.ClientID %>';
        var cbManualCoordinatesClientID = '<%=cbManualCoordinates.ClientID %>';
        var txtCoordinateXClientID = '<%=txtCoordinateX.ClientID %>';
        var txtCoordinateYClientID = '<%=txtCoordinateY.ClientID %>';
        var cbUpdateDeptName = '<%=cbUpdateDeptName.ClientID %>';
        var cbDeptNameToBeChangedManually = '<%=cbDeptNameToBeChangedManually.ClientID %>';
        var cbDeptNameFreePartExists = '<%=cbDeptNameFreePartExists.ClientID %>';


        function getSelectedCityCode(source, eventArgs) {

            var cityCodeTextBox = document.getElementById('<%=txtCityCode.ClientID %>');
            cityCodeTextBox.value = eventArgs.get_value();

            var txtCityName = document.getElementById('<%=txtCityName.ClientID %>');
            txtCityName.value = eventArgs.get_text();
            //alert(" Key : " + eventArgs.get_text() + "  Value :  " + eventArgs.get_value()); 

            var txtCityCodeHasBeenCleaned = document.getElementById('<%=txtCityCodeHasBeenCleaned.ClientID %>');
            txtCityCodeHasBeenCleaned.value = "1";

            window.document.forms(0).submit();
        }

        function getSelectedSubAdminCode(source, eventArgs) {
            var txtSubAdministrationCode = document.getElementById('<%=txtSubAdministrationCode.ClientID %>');
            var values = eventArgs.get_value();
            var valuesArr = values.split(",");
            txtSubAdministrationCode.value = eventArgs.get_value();

            var txtSubAdministrationName = document.getElementById('<%=txtSubAdministrationName.ClientID %>');

            txtSubAdministrationName.value = eventArgs.get_text();

            var txtSubAdministrationCodeHasBeenCleaned = document.getElementById('<%=txtSubAdministrationCodeHasBeenCleaned.ClientID %>');
            txtSubAdministrationCodeHasBeenCleaned.value = "1";

            var ddlPopulationSector = document.getElementById('<%=ddlPopulationSector.ClientID %>');
            ddlPopulationSector.focus();
        }

        function getSelectedParentClinicCode(source, eventArgs) {
            var txtParentClinicCode = document.getElementById('<%=txtParentClinicCode.ClientID %>');
            var values = eventArgs.get_value();
            var valuesArr = values.split(",");
            txtParentClinicCode.value = eventArgs.get_value();

            var txtParentClinicName = document.getElementById('<%=txtParentClinicName.ClientID %>');

            txtParentClinicName.value = eventArgs.get_text();

            var txtParentClinicCodeHasBeenCleaned = document.getElementById('<%=txtParentClinicCodeHasBeenCleaned.ClientID %>');
            txtParentClinicCodeHasBeenCleaned.value = "1";

            var ddlPopulationSector = document.getElementById('<%=ddlPopulationSector.ClientID %>');
            ddlPopulationSector.focus();
        }

        function getSelectedStreetCode(source, eventArgs) {
 
            var txtStreetCode = document.getElementById('<%=txtStreetCode.ClientID %>');
            txtStreetCode.value = eventArgs.get_value();

            var txtStreet = document.getElementById('<%=txtStreet.ClientID %>');
            txtStreet.value = eventArgs.get_text();

            var txtNeighborhoodAndSite = document.getElementById('<%=txtNeighborhoodAndSite.ClientID %>');
            txtNeighborhoodAndSite.disabled = true;

            var txtStreetCodeHasBeenCleaned = document.getElementById('<%=txtStreetCodeHasBeenCleaned.ClientID %>');
            txtStreetCodeHasBeenCleaned.value = "1";
        }

        function getSelectedNeighborhoodAndSiteCode(source, eventArgs) {

            var txtNeighborhoodAndSiteCode = document.getElementById('<%=txtNeighborhoodAndSiteCode.ClientID %>');
            var txtIsSite = document.getElementById('<%=txtIsSite.ClientID %>');
            var txtNeighborhoodAndSite = document.getElementById('<%=txtNeighborhoodAndSite.ClientID %>');
            var autocompleteValue = eventArgs.get_value().split(",");

            txtNeighborhoodAndSiteCode.value = autocompleteValue[0];
            txtIsSite.value = autocompleteValue[1];

            txtNeighborhoodAndSite.value = eventArgs.get_text();
        }

        function ClearCityCode() {
            var txtCityCodeHasBeenCleaned = document.getElementById('<%=txtCityCodeHasBeenCleaned.ClientID %>');
            if (txtCityCodeHasBeenCleaned.value == "1") {
                txtCityCodeHasBeenCleaned.value = "";
                window.document.forms(0).submit();
                return false;
            }

            var txtCityCode = document.getElementById('<%=txtCityCode.ClientID %>');
            var txtCityName = document.getElementById('<%=txtCityName.ClientID %>');
            txtCityCode.value = "";
            txtCityName.value = "";

            ClearStreetCode();
            ClearHouseNumber();
        }

        function ClearStreetCode() {
            var txtStreetCodeHasBeenCleaned = document.getElementById('<%=txtStreetCodeHasBeenCleaned.ClientID %>');
            if (txtStreetCodeHasBeenCleaned.value == "1") {
                txtStreetCodeHasBeenCleaned.value = "";
                return false;
            }

            var txtStreetCode = document.getElementById('<%=txtStreetCode.ClientID %>');
            var txtStreet = document.getElementById('<%=txtStreet.ClientID %>');
            var txtHouse = document.getElementById('<%=txtHouse.ClientID %>');

            var txtNeighborhoodAndSiteCode = document.getElementById('<%=txtNeighborhoodAndSiteCode.ClientID %>');
            var txtNeighborhoodAndSite = document.getElementById('<%=txtNeighborhoodAndSite.ClientID %>');

            txtStreetCode.value = "";
            txtStreet.value = "";
            txtHouse.value = "";
            txtNeighborhoodAndSiteCode.value = "";
            txtNeighborhoodAndSite.value = "";

            txtNeighborhoodAndSite.disabled = false;
            //setTimeout(ConfirmRemovingManualCoordinatesIfAddressChanged, 100);
        }

        function ClearHouseNumber() {
            var txtHouse = document.getElementById('<%=txtHouse.ClientID %>');
            var txtFloor = document.getElementById('<%=txtFloor.ClientID %>');
            var txtFlat = document.getElementById('<%=txtFlat.ClientID %>');
            txtHouse.value = "";
            txtFloor.value = "";
            txtFlat.value = "";
        }
        function ClearSubAdministrationCode() {
            var txtSubAdministrationCodeHasBeenCleaned = document.getElementById('<%=txtSubAdministrationCodeHasBeenCleaned.ClientID %>');
            if (txtSubAdministrationCodeHasBeenCleaned.value == "1") {
                txtSubAdministrationCodeHasBeenCleaned.value = "";
                return false;
            }

            var txtSubAdministrationCode = document.getElementById('<%=txtSubAdministrationCode.ClientID %>');
            var txtSubAdministrationName = document.getElementById('<%=txtSubAdministrationName.ClientID %>');
            txtSubAdministrationCode.value = "";
            txtSubAdministrationName.value = "";
        }
        function ClearParentClinicCode() {
            var txtParentClinicCodeHasBeenCleaned = document.getElementById('<%=txtParentClinicCodeHasBeenCleaned.ClientID %>');
            if (txtParentClinicCodeHasBeenCleaned.value == "1") {
                txtParentClinicCodeHasBeenCleaned.value = "";
                return false;
            }

            var txtParentClinicCode = document.getElementById('<%=txtParentClinicCode.ClientID %>');
            var txtParentClinicName = document.getElementById('<%=txtParentClinicName.ClientID %>');
            txtParentClinicCode.value = "";
            txtParentClinicName.value = "";
        }

        function ConfirmRemovingManualCoordinatesIfAddressChanged() {
            var cbManualCoordinates = document.getElementById(cbManualCoordinatesClientID);

            if (cbManualCoordinates.checked == true) {
                var answer = window.confirm("שונתה כתובת יחידה אך יש ליחידה סימון של קואורדינטות ידניות. במקרה זה קואורדינטות של היחידה לא יחושבו מחדש! האם ברצונך להסיר את הסימון הנ``ל ולחשב קואורדינטות בהתאם לכתובת שנבחרה?");
                if (answer) {
                    cbManualCoordinates.checked = false;
                }
            }
        }

        function WantToSaveData(FunctionToBeExecutedOnParent) {

            var url = "../Admin/ConfirmSavingPopUp.aspx";
            url += "?functionToExecute=" + FunctionToBeExecutedOnParent;

            var dialogWidth = 420;
            var dialogHeight = 200;
            var title = "Confirm";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return false;
        }

        function Check_cbSaveDataBeforeLeaveToUpdateRemarks(check) {

            document.getElementById('<%=cbCauseUpdateRemarksClick.ClientID %>').checked = true;

            if (check == 1) {
                document.getElementById('<%=cbSaveDataBeforeLeave.ClientID %>').checked = true;
            }
            else {
                document.getElementById('<%=cbSaveDataBeforeLeave.ClientID %>').checked = false;
            }

            document.forms[0].submit();
        }

        function Check_cbSaveDataBeforeLeaveToAddRemarks(check) {

            document.getElementById('<%=cbCauseAddRemarksClick.ClientID %>').checked = true;

            if (check == 1) {
                document.getElementById('<%=cbSaveDataBeforeLeave.ClientID %>').checked = true;
            }
            else {
                document.getElementById('<%=cbSaveDataBeforeLeave.ClientID %>').checked = false;
            }

            document.forms[0].submit();
        }

        function HaveToRenameClinic() {
            //debugger;
            if (!Page_ClientValidate("vgrFirstSectionValidation")) {
                return false;
            }

            var cbDeptNameToBeChangedCB = document.getElementById(cbDeptNameToBeChangedManually);
            var cbDeptNameFreePartExistsCB = document.getElementById(cbDeptNameFreePartExists);
            if (cbDeptNameToBeChangedCB.checked) {
                alert("שים לב : סוג יחידה השתנה, יש לשנות את שם היחידה עקב זאת");
                return false;

                //var obj = OpenDeptNamesDialog();

                //if (obj != null) {
                //    //if (obj.DataWasSaved == true) {
                //    if (obj.DataWasChanged == true) {
                //        showProgressBarGeneral('vgrFirstSectionValidation');
                //        return true;
                //    }
                //    else {
                //        return false;
                //    }
                //}
                //else
                //    return false;

            }
            else {
                showProgressBarGeneral('vgrFirstSectionValidation');
                return true;
            }
        }

        //------ Light Boxes --------------------------
        function OpenDeptNameLB() {
            var cbDeptNameLB_IsOpened = document.getElementById('<%=cbDeptNameLB_IsOpened.ClientID %>');
            cbDeptNameLB_IsOpened.checked = true;
        }
        function OpenDeptNamesDialog() {
            var url = "UpdateDeptNames.aspx?DeptCode=" + '<%= CurrentDeptCode %>';

            var deptCode = document.getElementById('<%=txtDeptCode.ClientID %>').value;
            //var deptCode = txtDeptCode.value;

            var ddlUnitType = document.getElementById('<%=ddlUnitType.ClientID %>');
            var clinicType = ddlUnitType.options[ddlUnitType.selectedIndex].value;
            var clinicTypeText = ddlUnitType.options[ddlUnitType.selectedIndex].text

            var cityName = document.getElementById('<%=txtCityName.ClientID %>').value;
            //debugger;
            var position = cityName.indexOf(' - מחוז');
            if (position > 0) {
                cityName = cityName.substring(0, position);
            }

            var ddlDistrict = document.getElementById('<%=ddlDistrict.ClientID %>');
            var districtCode = ddlDistrict.options[ddlDistrict.selectedIndex].value;
            var districtName = ddlDistrict.options[ddlDistrict.selectedIndex].text

            url = url + "&clinicType=" + clinicType;
            url = url + "&clinicTypeText=" + clinicTypeText;
            url = url + "&cityName=" + cityName;
            url = url + "&districtName=" + districtName;

            var dialogWidth = 730;
            var dialogHeight = 480;
            var title = "עדכון שם ורמת שירות";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return false;
        }

        function SetClinicName(newDeptName) {
            if (newDeptName != "" && newDeptName != "undefined") {
                document.getElementById('<%=txtNewClinicName.ClientID %>').value = newDeptName;
                document.getElementById('<%=lblDeptName.ClientID %>').innerHTML = newDeptName;
                //document.getElementById(cbDeptNameToBeChangedManually).checked = false;

                setSubmiButtonsEnabled();
            }

       }

        function SetDropDownSelected(ddList, txtBox) {
            var index = ddList.selectedIndex;
            var value = ddList.options[index].value;
            txtBox.value = value;
        }


        function ValidateStreetVcAddressComment(val, args) {
            var txtStreet = document.getElementById('<%=txtStreet.ClientID %>');
            var txtAddressComment = document.getElementById('<%=txtAddressComment.ClientID %>');

            var txtNeighborhoodAndSiteCode = document.getElementById('<%=txtNeighborhoodAndSiteCode.ClientID %>');

            if (txtStreet.value == "" && txtAddressComment.value == "" && txtNeighborhoodAndSiteCode.value == "") {
                args.IsValid = false;
            }
            else {
                args.IsValid = true;
            }
        }

        function StreeNameVsStreetCode(val, args) {
            var txtStreet = document.getElementById('<%=txtStreet.ClientID %>');
            var txtStreetCode = document.getElementById('<%=txtStreetCode.ClientID %>');
            if (txtStreet.value != "" && txtStreetCode.value == "") {
                args.IsValid = false;
            }
            else {
                args.IsValid = true;
            }
        }

        function GetOrderMethods() {
            url = "SelectQueueMethod.aspx?deptCode=" + document.getElementById('<%=txtDeptCode.ClientID %>').value;

            var dialogWidth = 700;
            var dialogHeight = 500;
            var title = "אופן זימון";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return;
        }

        function SetQueueInClinic(text) {
            document.getElementById('<%=lblQueueOrder.ClientID %>').innerText = text;
            document.getElementById('<%=txtQueueOrder.ClientID %>').value = text;
        }

        function UpdateStatus() {

            var deptCode = document.getElementById('<%=txtDeptCode.ClientID %>').value;

            var url = "UpdateStatus.aspx";
            url += "?deptCode=" + deptCode;
            url += "&functionToExecute=Update_btnDeptStatus";

            var dialogWidth = 500;
            var dialogHeight = 410;
            var title = "סטטוס";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            //return true;
        }

        function Update_btnDeptStatus(newStatus) {

            var btnDeptStatus = document.getElementById('<%=btnDeptStatus.ClientID %>');

            switch (newStatus) {
                case 0:
                    btnDeptStatus.innerText = "לא פעיל";
                    break;
                case 1:
                    btnDeptStatus.innerText = "פעיל";
                    break;
                case 2:
                    btnDeptStatus.innerText = "לא פעיל זמנית";
                    break;
                default:
                    break;
            }
        }

        // Function to highlight typed text in auto suggest results
        function ClientPopulated(source, eventArgs) {
            if (source._currentPrefix != null) {
                var list = source.get_completionList();
                var search = source._currentPrefix.toLowerCase();
                for (var i = 0; i < list.childNodes.length; i++) {
                    var text = list.childNodes[i].innerHTML;
                    var index = text.toLowerCase().indexOf(search);
                    if (index != -1) {
                        var value = text.substring(0, index);
                        value += '<span class="AutoComplete_ListItemHiliteText">';
                        value += text.substr(index, search.length);
                        value += '</span>';
                        value += text.substring(index + search.length);
                        //list.childNodes[i].innerHTML = value;
                        list.childNodes[i].value = value;
                    }
                }
            }
        }

        function MakePostBack() {
            var cbMakeRedirectAfterPostBack = document.getElementById('<%=cbMakeRedirectAfterPostBack.ClientID %>');
            var btnBackToOpener = document.getElementById('<%=btnBackToOpener.ClientID %>');
            if (cbMakeRedirectAfterPostBack.checked == true) {
                btnBackToOpener.click();
            }
        }

        function ClearDistricts() {

            if (document.getElementById(txtDistrictListClientID).value == "") {

                document.getElementById(txtDistrictCodesClientID).value = "";
                document.getElementById(txtDistrictListClientID).value = "";
            }
        }

        function getDistrictCode(source, eventArgs) {

            document.getElementById(txtDistrictCodesClientID).value = eventArgs.get_value();
            document.getElementById(txtDistrictListClientID).value = eventArgs.get_text();
        }

        function SelectDistricts(unitTypeCodes) {
            var url = "../Public/SelectPopUp.aspx";

            var txtDistrictCodes = document.getElementById(txtDistrictCodesClientID);
            var txtDistrictList = document.getElementById(txtDistrictListClientID);
            var SelectedDistrictsList = txtDistrictCodes.innerText;
            url += "?SelectedValuesList=" + SelectedDistrictsList;
            url += "&popupType=7&unitTypeCodes=" + unitTypeCodes; //getContextKeyForDistrict();

            url += "&returnValuesTo=txtDistrictCodes";
            url += "&returnTextTo=txtDistrictList";
            url += "&functionToExecute=setSubmiButtonsEnabled";

            var dialogWidth = 420;
            var dialogHeight = 660;
            var title = "בחר מחוז";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return true;
        }

        function featuresForPopUp() {
            var topi = 50;
            var lefti = 100;
            var features = "top:" + topi + "px;left:" + lefti + "px; dialogWidth:410px; dialogheight:620px; help:no; status:no;";
            return features;
        }

        function Toggle_cbManualCoordinates() {
            var cbManualCoordinates = document.getElementById(cbManualCoordinatesClientID);
            var txtCoordinateX = document.getElementById(txtCoordinateXClientID);
            var txtCoordinateY = document.getElementById(txtCoordinateYClientID);
            if (cbManualCoordinates.checked == true) {
                txtCoordinateX.disabled = false;
                txtCoordinateY.disabled = false;
            }
            else {
                txtCoordinateX.disabled = true;
                txtCoordinateY.disabled = true;
            }
        }
    </script>
    
    <script type="text/javascript">
        function setSubmiButtonsEnabled() {
            document.getElementById('<%=btnUpdate.ClientID %>').disabled = false;
            document.getElementById('<%=btnUpdate_Bottom.ClientID %>').disabled = false;
        }

        function ValidateDefenceType(val, args) {
            var ddlTypeOfDefence = document.getElementById('<%=ddlTypeOfDefence.ClientID %>');
            var cbIsCommunity = document.getElementById('<%=cbIsCommunity.ClientID %>');

            if (cbIsCommunity.checked) {
                if (ddlTypeOfDefence[ddlTypeOfDefence.selectedIndex].value == "-1")
                    args.IsValid = false;
                else
                    args.IsValid = true;
            }
            else {
                args.IsValid = true;
            }
        }

        function ValidateClinicUnified(val, args) {
            var ddlUnifiedClinic = document.getElementById('<%=ddlUnifiedClinic.ClientID %>');
            var cbIsCommunity = document.getElementById('<%=cbIsCommunity.ClientID %>');

            if (cbIsCommunity.checked) {
                if (ddlUnifiedClinic[ddlUnifiedClinic.selectedIndex].value == "-1")
                    args.IsValid = false;
                else
                    args.IsValid = true;
            }
            else {
                args.IsValid = true;
            }
        }

        function ValidatePolicyOfDefence(val, args) {
            var ddlDefencePolicy = document.getElementById('<%=ddlDefencePolicy.ClientID %>');
            var cbIsCommunity = document.getElementById('<%=cbIsCommunity.ClientID %>');

            if (cbIsCommunity.checked) {
                if (ddlDefencePolicy[ddlDefencePolicy.selectedIndex].value == "-1")
                    args.IsValid = false;
                else
                    args.IsValid = true;
            }
            else {
                args.IsValid = true;
            }
        }

    </script>

    <asp:Label ID="lblGeneralError" runat="server" SkinID="lblError" ></asp:Label>

    <table id="tblMain" cellspacing="0" cellpadding="0">
        <tr>
            <td style="padding-right: 10px">
                <table cellpadding="0" cellspacing="0" style="background-color: #298AE5; height: 27px;"
                    width="100%">
                    <tr>
                        <td style="width: 90px; padding-right: 15px; padding-left: 15px;">
                            <asp:Label ID="lblDeptNameCaption" EnableTheming="false" CssClass="LabelBoldWhite_18"
                                runat="server" Text="שם היחידה:"></asp:Label>
                        </td>
                        <td style="width: 700px; padding: 0px 0px 0px 0px;">
                            <table cellpadding="0" cellspacing="0">
                                <tr>
                                    <td style="padding-left:15px;">
                                        <asp:Label ID="lblDeptName" EnableTheming="false" CssClass="LabelBoldWhite_18" runat="server"
                                            Text=""></asp:Label>
                                    </td>
                                    <td style="padding: 0px 0px 0px 0px;">
                                        <table id="tblOpenDeptNameLB" runat="server" cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                    background-position: bottom left;">&nbsp;
                                                     <asp:CheckBox runat="server" ID="cbCauseUpdateRemarksClick" CssClass="DisplayNone" />
                                                     <asp:CheckBox runat="server" ID="cbCauseAddRemarksClick" CssClass="DisplayNone" />
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
                        <td align="left" style="padding-left: 5px; ">
                            <asp:CheckBox ID="cbDeptNameLB_IsOpened" runat="server" CssClass="DisplayNone" EnableTheming="false" />
                            <asp:CheckBox ID="cbSaveDataBeforeLeave" runat="server" CssClass="DisplayNone" EnableTheming="false" />
                            <asp:CheckBox ID="cbUpdateDeptName" runat="server"  CssClass="DisplayNone"  EnableTheming="false" />
                            <asp:CheckBox ID="cbDeptNameFreePartExists" runat="server"  CssClass="DisplayNone"  EnableTheming="false" />
                            <asp:CheckBox ID="cbDeptNameToBeChangedManually" runat="server"  CssClass="DisplayNone"  EnableTheming="false" />
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
                                        <asp:Button ID="btnUpdate" runat="server" Width="45px" Text="שמירה" CssClass="RegularUpdateButton"
                                           CausesValidation="true" OnClick="btnUpdate_Click" ValidationGroup="vgrFirstSectionValidation" 
                                            OnClientClick="javascript:return HaveToRenameClinic();"></asp:Button>
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
                                            CausesValidation="False" OnClick="btnBackToOpener_Click" />
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
                            <!-- tblDetails -->
                            <table id="tblDetails" cellspacing="0" cellpadding="0" style="width: 955px;" border="0">
                                <tr>
                                    <td valign="top">
                                        <table cellpadding="0" cellspacing="0" width="470px" border="0" >
                                            <tr>
                                                <td>
                                                    <table cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td >
                                                                <asp:Label ID="lblDeptUnitType" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                                    runat="server" Text="סוג יחידה:"></asp:Label>
                                                            </td>
                                                            <td style="width:210px">
                                                                <asp:DropDownList ID="ddlUnitType" runat="server" DataValueField="UnitTypeCode" DataTextField="UnitTypeName"
                                                                    Width="204px" AutoPostBack="True" OnSelectedIndexChanged="ddlUnitType_SelectedIndexChanged">
                                                                </asp:DropDownList>
                                                                <asp:TextBox ID="txt_ddlUnitType" runat="server" CssClass="DisplayNone" EnableTheming="false"></asp:TextBox>
                                                            </td>
                                                            <td>&nbsp;&nbsp;&nbsp;</td>
                                                            <td style="width:150px" >
                                                                <div style="border:1px solid #888888; width:150px;">
                                                                    <asp:CheckBox ID="cbShowUnitInInternet" runat="server" />
                                                                    <asp:Label ID="lblShowUnitInInternet" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                                        runat="server" Text="הצג יחידה באינטרנט"></asp:Label>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                        <tr id="trSubDeptUnitType" runat="server">
                                                            <td>
                                                                <asp:Label ID="lblSubUnitType" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                                    runat="server" Text="שיוך:"></asp:Label>
                                                            </td>
                                                            <td colspan="2">
                                                                <asp:DropDownList ID="ddlSubUnitType" runat="server" AppendDataBoundItems="true" 
                                                                    DataValueField="subUnitTypeCode" DataTextField="subUnitTypeName" Width="204px">
                                                                </asp:DropDownList>
                                                                <asp:CompareValidator ID="vldSubUnitType" ErrorMessage="חובה לבחור את שיוך המרפאה" ValidationGroup="vgrFirstSectionValidation" Text="*" runat="server" ControlToValidate="ddlSubUnitType" Operator="NotEqual" ValueToCompare="-1"></asp:CompareValidator>
                                                            </td>
                                                            <td rowspan="3" valign="top" style="padding-top:3px; padding-bottom:3px" >
                                                                <div style="border:1px solid #888888; width:150px; height:65px">
                                                                    <asp:CheckBox ID="cbIsCommunity" runat="server" />
                                                                    <asp:Label ID="lblIsCommunity" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                                        runat="server" Text="קהילה"></asp:Label><br />
                                                                    <asp:CheckBox ID="cbIsMushlam" runat="server" />
                                                                    <asp:Label ID="lblIsMushlam" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                                        runat="server" Text="מושלם"></asp:Label><br />
                                                                    <asp:CheckBox ID="cbIsHospital" runat="server" />
                                                                    <asp:Label ID="lblIsHospital" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                                        runat="server" Text="בית חולים"></asp:Label>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td >
                                                                <asp:Label ID="lblManagerName" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                                    runat="server" Text="מנהל:"></asp:Label>
                                                            </td>
                                                            <td colspan="2">
                                                                <asp:TextBox ID="txtManagerName" runat="server" Width="200px"></asp:TextBox>
                                                                <asp:TextBox ID="txtManagerNameHidden" runat="server" CssClass="DisplayNone" EnableTheming="false"></asp:TextBox>
                                                                <asp:Label ID="lblManagerNameValidation" runat="server" SkinID="lblError"></asp:Label>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="width: 100px" valign="top">
                                                                <asp:Label ID="lblAdministrativeManagerName" EnableTheming="false" CssClass="LabelMultiLineBoldDirtyBlue_12"
                                                                    runat="server" Text="מנהל אדמיניסטרטיבי:" ></asp:Label>
                                                            </td>
                                                            <td colspan="2" valign="top">
                                                                <asp:TextBox ID="txtAdministrativeManagerName" runat="server" Width="200px"></asp:TextBox>
                                                                <asp:TextBox ID="txtAdministrativeManagerNameHidden" runat="server" CssClass="DisplayNone" EnableTheming="false"></asp:TextBox>
                                                                <asp:Label ID="lblAdministrativeManagerNameValidation" runat="server" SkinID="lblError"></asp:Label>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td valign="top">
                                                    <table id="tblQueueOrder" border="0" runat="server" cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td style="width: 95px">
                                                                <asp:Label ID="lblQueueOrderCaption" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                                    runat="server" Text="אופן הזימון:"></asp:Label>
                                                            </td>
                                                            <td valign="top" dir="ltr" align="right">
                                                                <asp:Label CssClass="RegularLabel" EnableTheming="false" ID="lblQueueOrder"
                                                                    runat="server"></asp:Label>
                                                            </td>
                                                            <td valign="top" style="padding-right:5px">
                                                                <asp:TextBox ID="txtQueueOrder" runat="server" CssClass="DisplayNone" EnableTheming="false"></asp:TextBox>
                                                                <asp:LinkButton ID="btnUpdateQueueOrder" OnClientClick="return GetOrderMethods();"
                                                                    CssClass="LinkButtonBoldBlue" runat="server" Text="עדכון&nbsp;אופן&nbsp;הזימון"></asp:LinkButton>
                                                                <asp:TextBox ID="txtDeptCode" runat="server" Width="50px" CssClass="DisplayNone" EnableTheming="false"></asp:TextBox>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <asp:Label ID="lblDeptShalaCode" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                                    runat="server" Text="קוד יחידה ש.ל.ה:"></asp:Label>
                                                            </td>
                                                            <td colspan="2">
                                                                <asp:TextBox ID="txtlDeptShalaCode" Width="100px" runat="server"></asp:TextBox>
                                                                <asp:CompareValidator ID="vldEmployeeID" runat="server" Text="*" ValidationGroup="vgrFirstSectionValidation" 
                                                                    ErrorMessage="קוד יחידה ש.ל.ה אמור להיות מספרי" ControlToValidate="txtlDeptShalaCode" Operator="DataTypeCheck" Type="Integer"></asp:CompareValidator>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                    <td valign="top">
                                        <table cellpadding="0" cellspacing="0" width="450px" border="0">
                                            <tr>
                                                <td align="right">
                                                    <asp:Label ID="lblRemarks" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="הערות:"></asp:Label>
                                                    <asp:TextBox ID="txtNewClinicName" runat="server" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>
                                                </td>
                                                <td style="padding: 0px 0px 0px 0px;" align="right">
                                                    <table cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                background-position: bottom left;">
                                                                &nbsp;
                                                            </td>
                                                            <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                background-repeat: repeat-x; background-position: bottom;">
                                                                <asp:Button ID="btnUpdateRemarks" runat="server" Text="עדכון הערות" CssClass="RegularUpdateButton"
                                                                    CausesValidation="false" OnClick="btnUpdateRemarks_Click" OnClientClick="return WantToSaveData('Check_cbSaveDataBeforeLeaveToUpdateRemarks');">
                                                                </asp:Button>
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
                                                                <asp:Button ID="btnAddRemarks" runat="server" Text="הוספת הערות" CssClass="RegularUpdateButton"
                                                                    CausesValidation="false" OnClick="btnAddRemarks_Click" OnClientClick="return WantToSaveData('Check_cbSaveDataBeforeLeaveToAddRemarks');">
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
                                            <tr>
                                                <td colspan="2">
                                                    <asp:GridView ID="gvRemarks" runat="server" SkinID="SimpleGridViewNoEmtyDataText"
                                                        EmptyDataText="אין הערות לרופא\עובד" AutoGenerateColumns="False" HeaderStyle-CssClass="DisplayNone"
                                                        OnRowDataBound="gvRemarks_RowDataBound">
                                                        <Columns>
                                                            <asp:TemplateField>
                                                                <ItemTemplate>
                                                                    <div style="width: 18px;display:inline">
                                                                        <asp:Image ID="imgInternet" runat="server" />
                                                                    </div>
                                                                    <asp:Label ID="lblRemark" runat="server" Text='<% #Bind("RemarkText")%>' />
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
                            <!-- tblAddressAndPhones -->
                            <table id="tblAddressAndPhones" cellspacing="0" cellpadding="0" style="width: 955px;"
                                border="0">
                                <tr>
                                    <td valign="top">
                                        <table cellpadding="0" cellspacing="0" width="310px" border="0">
                                            <tr>
                                                <td style="width: 93px">
                                                    <asp:Label ID="lblCityName" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="ישוב:"></asp:Label>
                                                </td>
                                                <td colspan="2">
                                                    <asp:TextBox ID="txtCityName" Width="200px" runat="server" onchange="ClearCityCode();"></asp:TextBox>
                                                    <asp:TextBox runat="server" ID="txtCityCode" CssClass="DisplayNone" EnableTheming="false"></asp:TextBox> 
                                                    <asp:RequiredFieldValidator ID="rqdCity" runat="server" ControlToValidate="txtCityName" ValidationGroup="vgrFirstSectionValidation" ErrorMessage="שם יישוב הינו שדה חובה"></asp:RequiredFieldValidator>
                                                    <ajaxToolkit:AutoCompleteExtender runat="server" ID="autoCompleteCities" TargetControlID="txtCityName"
                                                        ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="GetCitiesAndDistricts"
                                                        MinimumPrefixLength="1" CompletionInterval="1000" CompletionListItemCssClass="CompletionListItemStyle"
                                                        UseContextKey="True" OnClientItemSelected="getSelectedCityCode" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                                        EnableCaching="true" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                                        CompletionListCssClass="CopmletionListStyle"
                                                        />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblStreet" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="רחוב:"></asp:Label>
                                                </td>
                                                <td colspan="2">
                                                    <table cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td>
                                                                <asp:TextBox ID="txtStreet" runat="server" Width="115px" onchange="ClearStreetCode();"></asp:TextBox>
                                                                <asp:TextBox ID="txtStreetCodeHasBeenCleaned" runat="server" EnableTheming="false" Width="10px" CssClass="DisplayNone"></asp:TextBox>
                                                                <asp:TextBox ID="txtCityCodeHasBeenCleaned" runat="server" EnableTheming="false" Width="10px" CssClass="DisplayNone"></asp:TextBox>
                                                                <ajaxToolkit:AutoCompleteExtender runat="server" ID="autoCompleteStreets" TargetControlID="txtStreet"
                                                                    ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="GetStreetsByCityCode"
                                                                    MinimumPrefixLength="1" CompletionInterval="1000" CompletionListItemCssClass="CompletionListItemStyle"
                                                                    UseContextKey="True" OnClientItemSelected="getSelectedStreetCode" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                                                    EnableCaching="true" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                                                    CompletionListCssClass="CopmletionListStyle" />
                                                                <asp:TextBox ID="txtStreetCode"  EnableTheming="false" runat="server" CssClass="DisplayNone"></asp:TextBox>
                                                            </td>
                                                            <td>
                                                                <asp:CustomValidator ID="vldStreeNameVsStreetCode" ClientValidationFunction="StreeNameVsStreetCode"
                                                                    Text="*" ErrorMessage="שם רחוב לא תקין, יש לבחור רחוב מרשימת רחובות או להזין הערה לכתובת" ValidationGroup="vgrFirstSectionValidation"
                                                                    runat="server"></asp:CustomValidator>
                                                            </td>
                                                            <td>
                                                                <asp:Label ID="lblHouse" EnableTheming="false" CssClass="LabelBoldDirtyBlue" runat="server"
                                                                    Text="מס:"></asp:Label>
                                                            </td>
                                                            <td align="left">
                                                                <asp:TextBox ID="txtHouse" runat="server" Width="49px"></asp:TextBox>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblFloor" EnableTheming="false" CssClass="LabelBoldDirtyBlue" runat="server"
                                                        Text="קומה:"></asp:Label>
                                                </td>
                                                <td colspan="2">
                                                    <table cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td style="width: 120px">
                                                                <asp:TextBox ID="txtFloor" runat="server" Width="49px"></asp:TextBox>
                                                            </td>
                                                            <td>
                                                                <asp:Label ID="lblFlat" EnableTheming="false" CssClass="LabelBoldDirtyBlue" runat="server"
                                                                    Text="חדר:"></asp:Label>
                                                            </td>
                                                            <td style="width: 52px">
                                                                <asp:TextBox ID="txtFlat" runat="server" Width="49px"></asp:TextBox>
                                                            </td>
                                                        </tr>

                                                    </table>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblBuilding" EnableTheming="false" CssClass="LabelBoldDirtyBlue" runat="server"
                                                        Text="בניין:"></asp:Label>
                                                </td>
                                                <td colspan="2">
                                                    <asp:TextBox ID="txtBuilding" runat="server" Width="200px"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblNeighborhood" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="שכונה\אתר:"></asp:Label>
                                                </td>
                                                <td colspan="2">
                                                    <asp:TextBox ID="txtNeighborhoodAndSite" runat="server" Width="200px" onchange="setTimeout(ConfirmRemovingManualCoordinatesIfAddressChanged, 100);"></asp:TextBox>
                                                    <ajaxToolkit:autocompleteextender runat="server" ID="autoCompleteNeighborhood" TargetControlID="txtNeighborhoodAndSite"
                                                        ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="GetNeighbourhoodsAndSitesByCityCode"
                                                        MinimumPrefixLength="1" CompletionInterval="1000" CompletionListItemCssClass="CompletionListItemStyle"
                                                        UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                                        EnableCaching="false" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                                        CompletionListCssClass="CopmletionListStyle" OnClientItemSelected="getSelectedNeighborhoodAndSiteCode" />
                                                    <asp:TextBox id="txtNeighborhoodAndSiteCode" runat="server" Width="90px" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>
                                                    <asp:TextBox id="txtIsSite" runat="server" Width="10px" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td valign="top">
                                                    <asp:Label ID="lblAddrComment" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="הערה לכתובת:"></asp:Label>
                                                </td>
                                                <td valign="top" colspan="2">
                                                    <asp:TextBox ID="txtAddressComment" runat="server" Width="200px" Rows="3" TextMode="MultiLine"></asp:TextBox>
                                                    <asp:CustomValidator ID="vldStreetVcAddressComment" ClientValidationFunction="ValidateStreetVcAddressComment"
                                                        Text="*" ErrorMessage="חובה להזין שם רחוב או הערה לכתובת או שכונה\אתר" ValidationGroup="vgrFirstSectionValidation"
                                                        runat="server"></asp:CustomValidator>                                                
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="3"></td>
                                            </tr>
                                            <tr>
                                                <td><asp:Label ID="lblCoordinateX" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="קורדינת X:"></asp:Label></td>
                                                <td><asp:TextBox ID="txtCoordinateX" runat="server" Width="100px"></asp:TextBox>
                                                </td>
                                                <td rowspan="2" valign="top" style="padding-right:10px">
                                                    <asp:CheckBox ID="cbManualCoordinates" runat="server" OnClick="Toggle_cbManualCoordinates();" CssClass="LabelBoldDirtyBlue" Text="עדכון קואורדינטות ידני" />

                                                </td>
                                            </tr>
                                            <tr>
                                                <td><asp:Label ID="lblCoordinateY" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="קורדינת Y:"></asp:Label></td>
                                                <td><asp:TextBox ID="txtCoordinateY" runat="server" Width="100px"></asp:TextBox></td>

                                            </tr>
                                            <tr id="trLinkToBlank" runat="server">
                                                <td colspan="3">
                                                    <asp:Label ID="lblLinkToBlank17" Width="125px" runat="server" CssClass="LabelBoldDirtyBlue" EnableTheming="false" Text="קישור לטופס זימון תור"></asp:Label>
                                                    <asp:TextBox ID="txtLinkToBlank17" runat="server" Width="165px"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr id="trLinkToContactUs" runat="server">
                                                <td colspan="3">
                                                    <asp:Label ID="lblLinkToContactUs" Width="125px" runat="server" CssClass="LabelBoldDirtyBlue" EnableTheming="false" Text="קישור ליצירת קשר"></asp:Label>
                                                    <asp:TextBox ID="txtLinkToContactUs" runat="server" Width="165px"></asp:TextBox>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                    <td valign="top">
                                        <table cellpadding="0" cellspacing="0" width="630px" border="0">
                                            <tr style="height: 25px">
                                                <td style="width:30px">
                                                    <asp:Image ID="imgClinicPhone" runat="server" ImageUrl="~/Images/Applic/phone-round.png" ToolTip="טלפון" />
                                                </td>
                                                <td align="right" dir="ltr" style="width:600px">
                                                    <!-- Place for Phones -->
                                                    <UCphones:PhonesGridUC ID="ClinicPhonesUC" runat="server" />
                                                </td>
                                            </tr>
                                            <tr style="height: 25px">
                                                <td>
                                                    <asp:Image ID="imgClinicFax" runat="server" ImageUrl="~/Images/Applic/fax-round.png" ToolTip="פאקס" />
                                                </td>
                                                <td align="right" dir="ltr">
                                                    <!-- Place for Faxes -->
                                                    <UCphones:PhonesGridUC ID="ClinicFaxesUC" runat="server" />
                                                </td>
                                            </tr>
                                            <tr style="height: 25px">
                                                <td>
                                                    <asp:Image ID="imgDirectPhone" runat="server" ImageUrl="~/Images/Applic/phone-direct.png" ToolTip="טלפון ישיר" />
                                                </td>
                                                <td align="right" dir="ltr">
                                                    <!-- Place for Direct Phones -->
                                                    <UCphones:PhonesGridUC ID="ClinicDirectPhonesUC" runat="server" />
                                                </td>
                                            </tr>
                                            <tr style="height: 25px">
                                                <td>
                                                    <asp:Image ID="imgWhatsApp" runat="server" ImageUrl="~/Images/Applic/whatsapp.png" ToolTip="וואטספ" />
                                                </td>
                                                <td align="right" dir="ltr">
                                                    <!-- Place for WhatsApp -->
                                                    <UCphones:PhonesGridUC ID="ClinicWhatsAppUC" runat="server" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td align="right" colspan="2">
                                                    <asp:CheckBox ID="cbCascadeUpdateSubClinicPhones" runat="server" />
                                                    <asp:Label ID="lblCascadeUpdateSubClinicPhones" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="עדכון טלפונים גם ביחידות כפופות"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td align="right" colspan="2">
                                                    <asp:CheckBox ID="cbCascadeUpdateDoctorInClinicPhones" runat="server" />
                                                    <asp:Label ID="lblCascadeUpdateDoctorInClinicPhones" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="עדכון טלפונים גם לעובדי היחידה"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td align="right" colspan="2">
                                                    <asp:CheckBox ID="cbCascadeUpdateServicesInClinicPhones" runat="server" />
                                                    <asp:Label ID="lblCascadeUpdateServicesInClinicPhones" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="עדכון טלפונים גם לשרותי היחידה"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td align="right" colspan="2">
                                                    <asp:Label ID="lblEmail" EnableTheming="false" CssClass="LabelBoldDirtyBlue" runat="server"
                                                        Text="E-mail:"></asp:Label>
                                                    <asp:TextBox ID="txtEmail" style="direction:ltr" runat="server" Width="140px"></asp:TextBox>
                                                    <asp:RegularExpressionValidator Width="10px" Text="*" ID="RegularExpressionValidator1"
                                                        runat="server"
                                                        ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" ErrorMessage="כתובת  ה - email שגויה. אנא נסה שנית"
                                                        ControlToValidate="txtEmail" ValidationGroup="vgrFirstSectionValidation"></asp:RegularExpressionValidator>
                                                    <asp:CheckBox ID="cbShowEmailInInternet" runat="server" />
                                                    <asp:Label ID="lblShowEmailInInternet" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="הצג באינטרנט"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td align="right" colspan="2">
                                                    <asp:CheckBox ID="cbAllowContactHospitalUnit" runat="server" />
                                                    <asp:Label ID="lbAllowContactHospitalUnit" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="לאפשר פניה ליחידה"></asp:Label>
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
            </td>
        </tr>
        <tr>
            <td style="padding-right: 10px">
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
                            <!-- tblTransport -->
                            <table id="tblTransport" cellspacing="0" cellpadding="0" style="width: 955px;" border="0">
                                <tr>
                                    <td valign="top">
                                        <table cellpadding="0" cellspacing="0" width="315px">
                                            <tr>
                                                <td style="width: 93px">
                                                    <asp:Label ID="lblTransport" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="תחבורה:"></asp:Label>
                                                </td>
                                                <td colspan="2" style="padding-right:1px">
                                                    <asp:TextBox ID="txtTransport" runat="server" Width="200px"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr id="tr1" runat="server">
                                                <td>
                                                    <asp:Label ID="lblParking" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="חניה:"></asp:Label>
                                                </td>
                                                <td colspan="2">
                                                    <asp:DropDownList Width="204px" ID="ddlParking" runat="server" AppendDataBoundItems="true"
                                                        DataTextField="parkingInClinicDescription" DataValueField="parkingInClinicCode">
                                                        <asp:ListItem Value="-1" Text="בחר"></asp:ListItem>
                                                    </asp:DropDownList>
                                                    <asp:TextBox ID="txt_ddlParking" runat="server" CssClass="DisplayNone" Width="5px" EnableTheming="false"></asp:TextBox>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                    <td valign="top" align="right">
                                        <table cellpadding="0" cellspacing="0" width="630px" border="0">
                                            <tr>
                                                <td align="right">
                                                    <asp:Label ID="lblHandicappedFacilities" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="הערכות לנכים:"></asp:Label>
                                                </td>
                                                <td>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="2">
                                                    <asp:CheckBoxList ID="cbHandicappedFacilities" runat="server" DataTextField="FacilityDescription"
                                                        DataValueField="FacilityCode" CssClass="CheckBoxListFlat" EnableTheming="false"
                                                        OnDataBound="cbHandicappedFacilities_DataBound" RepeatColumns="4" RepeatDirection="Horizontal">
                                                    </asp:CheckBoxList>
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
            </td>
        </tr>
        <tr>
            <td style="padding-right: 10px">
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
                            <!-- tblAdministration -->
                            <table id="tblAdministration" cellspacing="0" cellpadding="0" style="width: 955px;"
                                border="0">
                                <tr>
                                    <td valign="top">
                                        <table cellpadding="0" cellspacing="0" width="450px">
                                            <tr>
                                                <td style="width: 93px">
                                                    <asp:Label ID="lblDistrictName" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="מחוז:"></asp:Label>
                                                </td>
                                                <td>
                                                    <asp:DropDownList ID="ddlDistrict" runat="server" DataValueField="districtCode" DataTextField="districtName"
                                                        Width="204px" OnSelectedIndexChanged="ddlDistrict_SelectedIndexChanged" AutoPostBack="True"
                                                        AppendDataBoundItems="True" CssClass="DropDownList" EnableTheming="false">
                                                        <asp:ListItem Text=" " Value="-1"></asp:ListItem>
                                                    </asp:DropDownList>
                                                    <asp:CompareValidator ID="rqdDistrict" runat="server" ErrorMessage="חובה לבחור מחוז" Operator="NotEqual" ValidationGroup="vgrFirstSectionValidation" ValueToCompare="-1"  ControlToValidate="ddlDistrict"></asp:CompareValidator>
                                                </td>
                                                <td style="width: 130px"></td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblAdditionalDistricts" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="מחוזות נוספים:"></asp:Label>
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtDistrictList" runat="server" onchange="ClearDistricts();" Width="200px"
                                                        TextMode="MultiLine" Height="20px" CssClass="TextBoxMultiLine" EnableTheming="false"></asp:TextBox>
                                                    <ajaxToolkit:autocompleteextender runat="server" BehaviorID="autoCompleteDistricts" 
                                                        ID="autoCompleteDistricts" TargetControlID="txtDistrictList"
                                                        ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="getDistricts"
                                                        MinimumPrefixLength="1" CompletionInterval="500" CompletionListItemCssClass="CompletionListItemStyle"
                                                        UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                                        EnableCaching="false" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                                        CompletionListCssClass="CopmletionListStyleWidth" 
                                                        OnClientItemSelected="getDistrictCode" />
                                                </td>
                                                <td align="right">
                                                    <div style="margin-top:2px;">
                                                        <input type="image" id="btnDistrictsPopUp" runat="server" style="cursor: pointer;" src="../Images/Applic/icon_magnify.gif"
                                                             />
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="3">
                                                    <div style="display: none;">
                                                        <asp:TextBox ID="txtDistrictCodes" runat="server" TextMode="MultiLine"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </asp:TextBox>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr id="tr2" runat="server">
                                                <td>
                                                    <asp:Label ID="lblAdministrationName" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="מנהלת:"></asp:Label>
                                                </td>
                                                <td >
                                                    <asp:DropDownList ID="ddlAdministration" runat="server" DataValueField="AdministrationCode"
                                                        DataTextField="AdministrationName" Width="204px" AppendDataBoundItems="true"
                                                        EnableViewState="true">
                                                        <asp:ListItem Text=" " Value="-1"></asp:ListItem>
                                                    </asp:DropDownList>
                                                    <asp:TextBox ID="txt_ddlAdministration" runat="server" CssClass="DisplayNone" EnableTheming="false"></asp:TextBox>
                                                </td>
                                                <td></td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblSubAdministrationName" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="כפיפות ניהולית:"></asp:Label>
                                                </td>
                                                <td >
                                                    <asp:TextBox ID="txtSubAdministrationName" runat="server" Width="200px"
                                                        onchange="ClearSubAdministrationCode();"></asp:TextBox>
                                                    <asp:TextBox ID="txtSubAdministrationCode" Width="30px" runat="server" CssClass="DisplayNone" EnableTheming="false"></asp:TextBox>
                                                    <asp:TextBox ID="txtSubAdministrationCodeHasBeenCleaned" runat="server" EnableTheming="false" Width="10px" CssClass="DisplayNone"></asp:TextBox>
                                                    <ajaxToolkit:AutoCompleteExtender runat="server" ID="autoCompleteSubAdministration"
                                                        TargetControlID="txtSubAdministrationName" ServicePath="~/AjaxWebServices/AutoComplete.asmx"
                                                        ServiceMethod="GetClinicByName" MinimumPrefixLength="1" CompletionInterval="500"                                                        
                                                        CompletionListItemCssClass="CompletionListItemStyle" UseContextKey="false" OnClientItemSelected="getSelectedSubAdminCode"
                                                        CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle" EnableCaching="true"
                                                        CompletionSetCount="12" DelimiterCharacters="" OnClientPopulated="ClientPopulated" 
                                                        Enabled="True" CompletionListCssClass="CopmletionListStyle"/>
                                                </td>
                                                <td></td>
                                            </tr>

                                        </table>
                                    </td>
                                    <td valign="top">
                                        <table cellpadding="0" cellspacing="0" width="450px" border="0">
                                            <tr>
                                                <td style="width: 70px" align="right">
                                                    <asp:Label ID="lblPopulationSector" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="מגזר:"></asp:Label>
                                                </td>
                                                <td align="right">
                                                    <asp:DropDownList ID="ddlPopulationSector" runat="server" DataValueField="PopulationSectorID"
                                                        DataTextField="PopulationSectorDescription" Width="180px" AppendDataBoundItems="true">
                                                        <asp:ListItem Value="-1" Text="בחר"></asp:ListItem>
                                                    </asp:DropDownList>
                                                    <asp:TextBox ID="txt_ddlPopulationSector" runat="server" CssClass="DisplayNone" EnableTheming="false"></asp:TextBox>
                                                </td>
                                                <td style="vertical-align:top; padding-right:5px">
                                                    <asp:Label ID="lblReligion" EnableTheming="false" CssClass="LabelBoldDirtyBlue" Width="80px"
                                                        runat="server" Text="מועדים למגזר"></asp:Label>
                                                    <asp:DropDownList ID="ddlReligion" runat="server" DataValueField="ReligionCode"
                                                        DataTextField="ReligionDescription" Width="100px" AppendDataBoundItems="true">
                                                        <asp:ListItem Value="0" Text="בחר"></asp:ListItem>
                                                    </asp:DropDownList>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblParentClinicName" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="מרפאת אם:"></asp:Label>
                                                </td>
                                                <td  colspan="2">
                                                    <asp:TextBox ID="txtParentClinicName" runat="server" Width="175px"
                                                        onchange="ClearParentClinicCode();"></asp:TextBox>
                                                    <asp:TextBox ID="txtParentClinicCode" Width="30px" runat="server" CssClass="DisplayNone" EnableTheming="false"></asp:TextBox>
                                                    <asp:TextBox ID="txtParentClinicCodeHasBeenCleaned" runat="server" EnableTheming="false" Width="10px" CssClass="DisplayNone"></asp:TextBox>
                                                    <ajaxToolkit:AutoCompleteExtender runat="server" ID="autoCompleteParentClinic"
                                                        TargetControlID="txtParentClinicName" ServicePath="~/AjaxWebServices/AutoComplete.asmx"
                                                        ServiceMethod="GetClinicByName" MinimumPrefixLength="1" CompletionInterval="500"                                                        
                                                        CompletionListItemCssClass="CompletionListItemStyle" UseContextKey="false" OnClientItemSelected="getSelectedParentClinicCode"
                                                        CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle" EnableCaching="true"
                                                        CompletionSetCount="12" DelimiterCharacters="" OnClientPopulated="ClientPopulated" 
                                                        Enabled="True" CompletionListCssClass="CopmletionListStyle"/>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblDeptCodeCaption" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="קוד יחידה:"></asp:Label>
                                                </td>
                                                <td colspan="2">
                                                    <asp:Label ID="lblDeptCode" CssClass="SimpleTextGrey" EnableTheming="false" runat="server"
                                                        Width="200px"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblSimul228Caption" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="קוד ישן:"></asp:Label>
                                                </td>
                                                <td colspan="2">
                                                    <asp:Label ID="lblSimul228" CssClass="SimpleTextGrey" EnableTheming="false" runat="server"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblDeptStatus" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="סטטוס:"></asp:Label>
                                                </td>
                                                <td>
                                                    <asp:LinkButton ID="btnDeptStatus"  CssClass="LinkButtonBoldBlue"
                                                        runat="server" Text="פעיל"></asp:LinkButton>
                                                </td>
                                                <td>
                                                    <table id="tblSendMailToChangeStatusToActive" runat="server" cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                background-position: bottom left;">
                                                                &nbsp;
                                                            </td>
                                                            <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                background-repeat: repeat-x; background-position: bottom;">
                                                                <asp:Button ID="btnSendMailToChangeStatusToActive" runat="server" Text="שלח בקשה להפיכה ל: פעיל" CssClass="RegularUpdateButton"
                                                                    CausesValidation="false" OnClick="btnSendMailToChangeStatusToActive_Click" >
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
                            <!-- tblSimul -->
                            <table id="tblSimul" cellspacing="0" cellpadding="0" style="width: 955px;" border="0">
                                <tr>
                                    <td valign="top" style="width:473px">
                                        <table cellpadding="0" cellspacing="0"  border="0" >
                                            <tr>
                                                <td style="width:137px">
                                                    <asp:Label ID="lbldeptNameSimulCaption" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="שם יחידה בסימול"></asp:Label>
                                                </td>
                                                <td>
                                                    <asp:Label ID="lbldeptNameSimul" runat="server" EnableTheming="false" CssClass="SimpleTextGrey"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblStatusSimulCaption" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="סטטוס בסימול"></asp:Label>
                                                </td>
                                                <td>
                                                    <asp:Label ID="lblStatusSimul" runat="server" EnableTheming="false" CssClass="SimpleTextGrey"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblOpenDateSimulCaption" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="תאריך פתיחה בסימול"></asp:Label>
                                                </td>
                                                <td>
                                                    <asp:Label ID="lblOpenDateSimul" runat="server" CssClass="SimpleTextGrey" EnableTheming="false"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblClosingDateSimulCaption" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="תאריך סגירה בסימול"></asp:Label>
                                                </td>
                                                <td>
                                                    <asp:Label ID="lblClosingDateSimul" runat="server" CssClass="SimpleTextGrey" EnableTheming="false"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblSimulManageDescriptionCaption" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="כפיפות ניהולית בסימול"></asp:Label>
                                                </td>
                                                <td>
                                                    <asp:Label ID="lblSimulManageDescription" runat="server" CssClass="SimpleTextGrey"
                                                        EnableTheming="false"></asp:Label>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                    <td valign="top" style="text-align:right">
                                        <table cellpadding="0" cellspacing="0" border="0">
                                            <tr>
                                                <td style="width:160px">
                                                    <asp:Label ID="lblCodeSugSimul501Caption" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="סוג סימול"></asp:Label>
                                                </td>
                                                <td>
                                                    <asp:Label ID="lblCodeSugSimul501" runat="server" CssClass="SimpleTextGrey" EnableTheming="false"></asp:Label>
                                                    <asp:Label ID="lblSugSimul501" runat="server" CssClass="SimpleTextGrey" EnableTheming="false"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblCodeTatSugSimul502Caption" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="תת סוג סימול"></asp:Label>
                                                </td>
                                                <td>
                                                    <asp:Label ID="lblCodeTatSugSimul502" runat="server" CssClass="SimpleTextGrey" EnableTheming="false"></asp:Label>
                                                    <asp:Label ID="lblTatSugSimul502" runat="server" CssClass="SimpleTextGrey" EnableTheming="false"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblCodeTatHitmahut503Caption" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="תת היתמחות"></asp:Label>
                                                </td>
                                                <td>
                                                    <asp:Label ID="lblCodeTatHitmahut503" runat="server" CssClass="SimpleTextGrey" EnableTheming="false"></asp:Label>
                                                    <asp:Label ID="lblTatHitmahut503" runat="server" CssClass="SimpleTextGrey" EnableTheming="false"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblCodeRamatPeilut504Caption" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="רמת פעילות"></asp:Label>
                                                </td>
                                                <td>
                                                    <asp:Label ID="lblCodeRamatPeilut504" runat="server" CssClass="SimpleTextGrey" EnableTheming="false"></asp:Label>
                                                    <asp:Label ID="lblRamatPeilut504" runat="server" CssClass="SimpleTextGrey" EnableTheming="false"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblUnitTypeNameSimulCaption" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="סוג יחידה לפי טבלת המרה"></asp:Label>
                                                </td>
                                                <td>
                                                    <asp:Label ID="lblUnitTypeCode" runat="server" CssClass="SimpleTextGrey" EnableTheming="false"></asp:Label>
                                                    <asp:Label ID="lblUnitTypeNameSimul" runat="server" CssClass="SimpleTextGrey" EnableTheming="false"></asp:Label>
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
            </td>
        </tr>
        <tr>
            <td style="padding-right: 10px">
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
                            <!-- Emergency situation fields -->
                            <table id="tblEmergency" cellspacing="0" cellpadding="0" style="width: 955px;" border="0">
                                <tr>
                                    <td valign="top">
                                        <table cellpadding="0" cellspacing="0"  border="0" >
                                            <tr>
                                                <td style="width:160px">
                                                    <asp:Label ID="lblTypeOfDefence" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="סוג מיגון"></asp:Label>
                                                </td>
                                                <td style="width:180px">
                                                    <asp:DropDownList ID="ddlTypeOfDefence" runat="server" DataValueField="TypeOfDefenceCode"
                                                        DataTextField="TypeOfDefenceDefinition" Width="160px" AppendDataBoundItems="true"
                                                        EnableViewState="true">
                                                        <asp:ListItem Text="בחר" Value="-1"></asp:ListItem>
                                                    </asp:DropDownList>
<%--                                                    <asp:CustomValidator ID="vldDefenceType" ErrorMessage="חובה לבחור את סוג מיגון" Text="*" runat="server" Display="Dynamic" EnableClientScript="true"
                                                         ValidationGroup="vgrFirstSectionValidation" ClientValidationFunction="ValidateDefenceType"></asp:CustomValidator>--%>
                                                </td>
                                                <td style="width:80px;">
                                                    <asp:Label ID="lblUnifiedClinic" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="מרפאה אחודה"></asp:Label>
                                                </td>
                                                <td style="width:70px;">
                                                    <asp:DropDownList ID="ddlUnifiedClinic" runat="server" DataValueField="IsUnifiedClinic"
                                                        DataTextField="IsUnifiedClinicText" Width="48px" AppendDataBoundItems="true"
                                                        EnableViewState="true">
                                                        <asp:ListItem Text="בחר" Value="-1"></asp:ListItem>
                                                    </asp:DropDownList>
<%--                                                    <asp:CustomValidator ID="vldClinicUnified" ErrorMessage="חובה לבחור האם מרפאה אחודה" Text="*" runat="server" 
                                                         ValidationGroup="vgrFirstSectionValidation" ClientValidationFunction="ValidateClinicUnified"></asp:CustomValidator>--%>
                                                </td>
                                                <td style="width:120px;">
                                                    <asp:Label ID="lblElectricalPanel" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="לוח חשמל לגנרציה"></asp:Label>
                                                </td>
                                                <td>
                                                    <asp:DropDownList ID="ddlElectricalPanel" runat="server" DataValueField="HasElectricalPanel"
                                                        DataTextField="HasElectricalPanelText" Width="48px" AppendDataBoundItems="true"
                                                        EnableViewState="true">
                                                        <asp:ListItem Text="בחר" Value="-1"></asp:ListItem>
                                                    </asp:DropDownList> 

                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblDefencePolicy" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="מדיניות התגוננות מקסימלית"></asp:Label>
                                                </td>
                                                <td>
                                                    <asp:DropDownList ID="ddlDefencePolicy" runat="server" DataValueField="DefencePolicyCode"
                                                        DataTextField="DefencePolicyDefinition" Width="160px" AppendDataBoundItems="true"
                                                        EnableViewState="true">
                                                        <asp:ListItem Text="בחר" Value="-1"></asp:ListItem>
                                                    </asp:DropDownList>
<%--                                                    <asp:CustomValidator ID="vldPolicyOfDefence" ErrorMessage="חובה לבחור את קוד מדיניות התגוננות" Text="*" runat="server" 
                                                         ValidationGroup="vgrFirstSectionValidation" ClientValidationFunction="ValidatePolicyOfDefence"></asp:CustomValidator>--%>

                                                </td>
                                                <td>

                                                </td>
                                                <td>

                                                </td>
                                                <td>
                                                    <asp:Label ID="lblGenerator" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="גנרטור לכל המרפאה"></asp:Label>
                                                </td>
                                                <td>
                                                    <asp:DropDownList ID="ddlGenerator" runat="server" DataValueField="HasGenerator"
                                                        DataTextField="HasGeneratorText" Width="48px" AppendDataBoundItems="true"
                                                        EnableViewState="true">
                                                        <asp:ListItem Text="בחר" Value="-1"></asp:ListItem>
                                                    </asp:DropDownList> 
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                    <td valign="top" style="text-align:right">
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
                                            OnClick="btnUpdate_Click" CausesValidation="true" ValidationGroup="vgrFirstSectionValidation"
                                            OnClienClick="javascript:return HaveToRenameClinic();"></asp:Button>
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
                                            Text="ביטול" CausesValidation="False" OnClick="btnBackToOpener_Click"/>
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
