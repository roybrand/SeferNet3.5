<%@ Reference Page="AdminBasePage.aspx" %>
<%@ Page ValidateRequest="false" Title="עדכון הערה גורפת" Language="C#" MasterPageFile="~/SeferMasterPageIEwide.master" AutoEventWireup="true" Inherits="UpdateSweepingRemarks" UICulture="he-il" Codebehind="UpdateSweepingRemarks.aspx.cs" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<%@ Register Assembly="System.Web.Extensions, Version=1.0.61025.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
    Namespace="System.Web.UI" TagPrefix="asp" %>
<%@ MasterType  VirtualPath="~/SeferMasterPageIEwide.master" %>
<asp:Content ID="ContentHeader" ContentPlaceHolderID="phHead" runat="server">
    <link href="../CLEditor/jquery.cleditor.css" rel="stylesheet" type="text/css" />
    <script src="../CLEditor/jquery.cleditor.js" type="text/javascript"></script>
    <script src="../CLEditor/jquery.cleditor.min.js" type="text/javascript"></script>


</asp:Content>
<asp:Content ID="Content1" ContentPlaceHolderID="pageContent" Runat="Server">
    <script type="text/javascript">
    function BindEvents() {
        $(document).ready(function () {
            $("#<%=txtRemarkText.ClientID%>").cleditor(
        {
            controls: "bold italic underline strikethrough subscript superscript | font  size  style |"
                + " color highlight removeformat | bullets numbering | outdent indent | "
                + " alignleft center alignright justify | undo redo | rule link unlink |"
                + " cut copy paste pastetext | print source"
        }
        );
            });
    }
</script> 

<script type="text/javascript">
    Sys.Application.add_load(BindEvents);
</script>    
<script type="text/javascript">
    var txtCityCodeClientID = '<%=txtCityCode.ClientID %>';
    var txtCityNameOnlyClientID = '<%=txtCityNameOnly.ClientID %>';
    var txtCityNameToCompareClientID = '<%=txtCityNameToCompare.ClientID %>';
    var txtCityNameClientID = '<%=txtCityName.ClientID %>';
    var txtProfessionListCodesClientID = '<%=txtProfessionListCodes.ClientID %>';
    var txtProfessionListClientID = '<%=txtProfessionList.ClientID %>';
    var btnProfessionListPopUpClientID = '<%=btnProfessionListPopUp.ClientID %>';
    var txtProfessionList_ToCompareClientID = '<%=txtProfessionList_ToCompare.ClientID %>';
    var chkDisplayOnInternet_ClientID = '<%=cbInternetDisplay.ClientID %>';
    var txtOpenNow_ClientID = '<%=txtOpenNow.ClientID %>';
    var lblAlert_ClientID = '<%=lblAlert.ClientID %>';
    var txtRemarkValidFrom_ClientID = '<%=txtValidFrom.ClientID %>';
    var txtShowForPreviousDaysForSelectedRemark_ClientID = '<%=txtShowForPreviousDaysForSelectedRemark.ClientID %>';
    var txtRemarkActiveFrom_ClientID = '<%=txtRemarkActiveFrom.ClientID %>';

    // "UnitTypes" management functions
    
    function ClearUnitTypeList() {
        if (document.getElementById('<%=txtUnitTypeList_ToCompare.ClientID %>').value != document.getElementById('<%=txtUnitTypeList.ClientID %>').value) {
            document.getElementById('<%=txtUnitTypeList_ToCompare.ClientID %>').value = "";
            document.getElementById('<%=txtUnitTypeList.ClientID %>').value = "";
            document.getElementById('<%=txtUnitTypeListCodes.ClientID %>').value = "";

            document.getElementById('<%=txtExcludedDeptCodes.ClientID %>').value = "";
            document.getElementById('<%=txtExcludedDeptList.ClientID %>').value = "";
        }
    }

    function SelectUnitType() {
        var txtUnitTypeListCodes = document.getElementById('<%=txtUnitTypeListCodes.ClientID %>');
        var txtUnitTypeList = document.getElementById('<%=txtUnitTypeList.ClientID %>');
        var SelectedUnitTypeList = txtUnitTypeListCodes.innerText;

        var url = "../public/SelectPopUp.aspx";
        url = url + "?SelectedValuesList=" + SelectedUnitTypeList;
        url = url + "&popupType=6";
        url += "&returnValuesTo=txtUnitTypeListCodes";
        url += "&returnTextTo=txtUnitTypeList";
        url += "&functionToExecute=ClearExcludedDeptCodes";

            var dialogWidth = 420;
            var dialogHeight = 650;
            var title = "בחר סוג יחידה";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return false;
    }

    function ClearExcludedDeptCodes() {
        document.getElementById('<%=txtExcludedDeptCodes.ClientID %>').value = "";
        document.getElementById('<%=txtExcludedDeptList.ClientID %>').value = "";
    }

    function SyncronizeUnitTypeList() {
        document.getElementById('<%=txtUnitTypeList_ToCompare.ClientID %>').value = document.getElementById('<%=txtUnitTypeList.ClientID %>').value;
    }

    function featuresForPopUp() {
        var topi = 50;
        var lefti = 100;
        var features = "top:" + topi + "px;left:" + lefti + "px; dialogWidth:420px; dialogheight:620px; help:no; status:no;";
        return features;
    }

    function getSelectedUnitTypeCode(source, eventArgs) {
        document.getElementById('<%=txtUnitTypeListCodes.ClientID %>').value = eventArgs.get_value();
        document.getElementById('<%=txtUnitTypeList_ToCompare.ClientID %>').value = eventArgs.get_text();
        document.getElementById('<%=txtUnitTypeList.ClientID %>').value = eventArgs.get_text();
        
        document.forms[0].submit();
    }


    function SelectDistricts() {
        var txtDistrictCodes = document.getElementById('<%=txtDistrictCodes.ClientID %>');
        var txtDistrictList = document.getElementById('<%=txtDistrictList.ClientID %>');
        var txtDistrictsPermitted = document.getElementById('<%=txtDistrictsPermitted.ClientID %>');
        var txtDistrictListClone = document.getElementById('<%=txtDistrictListClone.ClientID %>');

        var SelectedDistrictsList = txtDistrictCodes.innerText;
        var url = "../Public/SelectPopUp.aspx";
        url += "?SelectedValuesList=" + SelectedDistrictsList;
        url += "&popupType=7";
        url += "&PermittedDistricts=" + txtDistrictsPermitted.value;
        url += "&returnValuesTo=txtDistrictCodes";
        url += "&returnTextTo=txtDistrictList,txtDistrictListClone";
        //url += "&functionToExecute=ClearExcludedDeptCodes";

        var dialogWidth = 420;
        var dialogHeight = 660;
        var title = "בחר מחוז";

        OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

        return false;
    }

    function getDistrictCode(source, eventArgs) {
        document.getElementById('<%=txtDistrictCodes.ClientID %>').value = eventArgs.get_value();
        document.getElementById('<%=txtDistrictList.ClientID %>').value = eventArgs.get_text();
        document.getElementById('<%=txtAdminCodes.ClientID %>').value = "";
        document.getElementById('<%=txtAdminList.ClientID %>').value = "";

        document.getElementById('<%=btnDistrictsPopUp.ClientID %>').focus();

        window.document.forms(0).submit();
    }

    function ClearDistricts() {
        document.getElementById('<%=txtDistrictCodes.ClientID %>').value = "";
        document.getElementById('<%=txtDistrictList.ClientID %>').value = "";
        document.getElementById('<%=txtAdminCodes.ClientID %>').value = "";
        document.getElementById('<%=txtAdminList.ClientID %>').value = "";
        document.getElementById('<%=txtExcludedDeptCodes.ClientID %>').value = "";
        document.getElementById('<%=txtExcludedDeptList.ClientID %>').value = "";

        document.getElementById('<%=btnDistrictsPopUp.ClientID %>').focus();

        window.document.forms(0).submit();
    }

    function RestoreDistricts() {
        document.getElementById('<%=txtDistrictList.ClientID %>').value = document.getElementById('<%=txtDistrictListClone.ClientID %>').value;
    }

    // "Admins" management functions
    function getAdminCode(source, eventArgs) {
        document.getElementById('<%=txtAdminCodes.ClientID %>').value = eventArgs.get_value();
        document.getElementById('<%=txtAdminList.ClientID %>').value = eventArgs.get_text();

        document.getElementById("btnAdminPopUp").focus();
    }

    function ClearAdmin() {
        document.getElementById('<%=txtAdminCodes.ClientID %>').value = "";
        document.getElementById('<%=txtAdminList.ClientID %>').value = "";
        document.getElementById('<%=txtExcludedDeptCodes.ClientID %>').value = "";
        document.getElementById('<%=txtExcludedDeptList.ClientID %>').value = "";
        document.getElementById("btnAdminPopUp").focus();
    }

    function SelectAdmins() {
        var txtAdminCodes = document.getElementById('<%=txtAdminCodes.ClientID %>');
        var txtAdminList = document.getElementById('<%=txtAdminList.ClientID %>');
        var txtDistrictCodes = document.getElementById('<%=txtDistrictCodes.ClientID %>');

        var SelectedValuesList = txtDistrictCodes.innerText + ';' + txtAdminCodes.innerText;
        var url = "../Public/SelectPopUp.aspx";
        url = url + "?SelectedValuesList=" + SelectedValuesList;
        url = url + "&popupType=10";
        url += "&returnValuesTo=txtAdminCodes";
        url += "&returnTextTo=txtAdminList";
        url += "&functionToExecute=PopulationSectorsChanged";

        var dialogWidth = 420;
        var dialogHeight = 660;
        var title = "בחר מנהלת";

        OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

        return false;
    }

    function SelectExcludedClinics() {
        var txtAdminCodes = document.getElementById('<%=txtAdminCodes.ClientID %>');
        var txtDistrictCodes = document.getElementById('<%=txtDistrictCodes.ClientID %>');
        var txtUnitTypeListCodes = document.getElementById('<%=txtUnitTypeListCodes.ClientID %>');
        var ddlSubUnitType = document.getElementById('<%=ddlSubUnitType.ClientID %>');
        var ddlPopulationSectors = document.getElementById('<%=ddlPopulationSectors.ClientID %>');

        var txtExcludedDeptCodes = document.getElementById('<%=txtExcludedDeptCodes.ClientID %>');
        var txtExcludedDeptList = document.getElementById('<%=txtExcludedDeptList.ClientID %>');

        var ddlSubUnitType_SelectedValue = "";
        if (ddlSubUnitType != null)
            ddlSubUnitType_SelectedValue = ddlSubUnitType.options[ddlSubUnitType.selectedIndex].value;

        var SelectedValuesList = txtDistrictCodes.innerText + ';'
            + txtAdminCodes.innerText + ';'
            + txtExcludedDeptCodes.innerText + ';'
            + txtUnitTypeListCodes.innerText + ';'
            + ddlSubUnitType_SelectedValue + ';'
            + ddlPopulationSectors.options[ddlPopulationSectors.selectedIndex].value;

        var url = "../Public/SelectPopUp.aspx";
        url = url + "?SelectedValuesList=" + SelectedValuesList;
        url = url + "&popupType=25";

        url += "&returnValuesTo=txtExcludedDeptCodes";
        url += "&returnTextTo=txtExcludedDeptList";

        var dialogWidth = 420;
        var dialogHeight = 660;
        var title = "בחר יחידות לא כלולות";

        OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

        return false;
    }

    function PopulationSectorsChanged() {
        document.getElementById('<%=txtExcludedDeptCodes.ClientID %>').value = "";
        document.getElementById('<%=txtExcludedDeptList.ClientID %>').value = "";
    }

    function SubUnitTypeChanged() {
        document.getElementById('<%=txtExcludedDeptCodes.ClientID %>').value = "";
        document.getElementById('<%=txtExcludedDeptList.ClientID %>').value = "";
    }

    function OnDDCityCodeSelected(source, eventArgs) {

        var txtCityCode = document.getElementById(txtCityCodeClientID);
        var txtCityNameOnly = document.getElementById(txtCityNameOnlyClientID);

        var value = eventArgs.get_value();
        var valueArray = value.split("~");

        txtCityCode.value = valueArray[0];
        txtCityNameOnly.value = valueArray[1];

        var txtCityName = document.getElementById(txtCityNameClientID);
        txtCityName.value = eventArgs.get_text();
    }

    function ClearProfessionList() {
        if (document.getElementById(txtProfessionList_ToCompareClientID).value != document.getElementById(txtProfessionListClientID).value) {
            document.getElementById(txtProfessionList_ToCompareClientID).value = "";
            document.getElementById(txtProfessionListClientID).value = "";
            document.getElementById(txtProfessionListCodesClientID).value = "";
        }
    }

    function SyncronizeProfessionList() {
        document.getElementById(txtProfessionList_ToCompareClientID).value = document.getElementById(txtProfessionListClientID).value;
    }

    function getSelectedProfessionCode(source, eventArgs) {
        document.getElementById(txtProfessionListCodesClientID).value = eventArgs.get_value();
        document.getElementById(txtProfessionList_ToCompareClientID).value = eventArgs.get_text();
        document.getElementById(txtProfessionListClientID).value = eventArgs.get_text();

        document.getElementById(btnProfessionListPopUpClientID).focus();
    }

    function SelectProfession() {
        var url = "../Public/SelectPopUp.aspx";
        var txtProfessionListCodes = document.getElementById(txtProfessionListCodesClientID);
        var txtProfessionList = document.getElementById(txtProfessionListClientID);
        var SelectedProfessionList = txtProfessionListCodes.innerText;
        url = url + "?SelectedValuesList=" + SelectedProfessionList;
        url = url + "&popupType=12";
        url += "&returnValuesTo=txtProfessionListCodes";
        url += "&returnTextTo=txtProfessionList";

        var dialogWidth = 420;
        var dialogHeight = 660;
        var title = "בחר שירות/מקצוע";

        OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

        return false;
    }

    function SelectCities() {
        var txtCitiesListCodes = document.getElementById('<%=txtCityCode.ClientID %>');
        var txtCitiesList = document.getElementById('<%=txtCityName.ClientID %>');
        var txtCitiesListToCompare = document.getElementById('<%=txtCityNameToCompare.ClientID %>');
        var SelectedDistrictCodes = document.getElementById('<%=txtDistrictCodes.ClientID %>').value;
        var SelectedCitiesList = txtCitiesListCodes.value;

        var url = "../public/SelectPopUp.aspx";
        url += "?SelectedValuesList=" + SelectedCitiesList;
        url += "&SelectedDistrictCodes=" + SelectedDistrictCodes;
        url += "&popupType=9";
        url += "&returnValuesTo=txtCityCode";
        url += "&returnTextTo=txtCityName,txtCityNameToCompare";

        var dialogWidth = 420;
        var dialogHeight = 660;
        var title = "בחר ישוב";

        OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

        return false;
    }

    function ClearCitySearchControlOnChangeCityName() {
        if (document.getElementById(txtCityNameToCompareClientID).value != document.getElementById(txtCityNameClientID).value) {
            ClearCitySearchControls();
        }
    }

    function ClearCitySearchControls() {
        document.getElementById(txtCityCodeClientID).value = "";
        document.getElementById(txtCityNameClientID).value = "";
        document.getElementById(txtCityNameOnlyClientID).value = "";
        document.getElementById(txtCityNameToCompareClientID).value = "";
    }
</script>
<script type="text/jscript">
    function SaveRemarkInHidden() {
        var tdRemark = document.getElementById("tdRemark");
        var txtRemarkFormatedText = document.getElementById('<%=txtRemarkFormatedText.ClientID %>');
        var str = '';        

            var childNodes = document.getElementById("tdRemark").childNodes;
            for (var i = 0; i < childNodes.length; i++) {
                //alert(childNodes[i].nodeType + "," + childNodes[i].value + "," + childNodes[i].innerHTML);
                if (childNodes[i].value != undefined)
                    str += '#' + childNodes[i].value + '#';
                if (childNodes[i].innerHTML != undefined)
                    str += childNodes[i].innerHTML;
            }
            txtRemarkFormatedText.value = str;
    }

    function SaveRTFRemarkInHidden() {
        var txtRemarkText = document.getElementById('<%=txtRemarkText.ClientID %>');
        var txtRemarkFormatedText = document.getElementById('<%=txtRemarkFormatedText.ClientID %>');
        txtRemarkFormatedText.value = txtRemarkText.value;
    }

    function ShowProgressBar() {
        if (Page_ClientValidate("vldGrSave")) {
            document.getElementById("divProgressBarGeneral").style.visibility = "visible";
        }
    }

    function Show_lblAlert() {
        if (document.getElementById(txtOpenNow_ClientID).value == 1 && document.getElementById(chkDisplayOnInternet_ClientID).checked) {
            document.getElementById(lblAlert_ClientID).style.display = "block";
        }
        else {
            document.getElementById(lblAlert_ClientID).style.display = "none";
        }
    }
    function SetActiveFrom() {
        var ShowForPreviousDays = document.getElementById(txtShowForPreviousDaysForSelectedRemark_ClientID).value;
        document.getElementById(txtRemarkActiveFrom_ClientID).value = GetActiveFromDate(document.getElementById(txtRemarkValidFrom_ClientID).value, ShowForPreviousDays);
    }

    function GetActiveFromDate(dateString, days) {
        var dateParts = dateString.split("/");

        // month is 0-based, that's why we need dataParts[1] - 1
        //var dateObject = new Date(+dateParts[2], dateParts[1] - 1, +dateParts[0]);

        var dateObject = new Date(+dateParts[2], dateParts[1] - 1, +dateParts[0] - days);
        var currentDateObject = new Date();
        currentDateObject.getDate();
        if (isNaN(dateObject)) {
            return "";
        }
        else {
            if (dateObject <= currentDateObject) {
                dateObject = currentDateObject;
                return "היום";
            }
            else {
                return getFormattedDate(dateObject);
            }
        }

    }

    function getFormattedDate(date) {
        var year = date.getFullYear();

        var month = (1 + date.getMonth()).toString();
        month = month.length > 1 ? month : '0' + month;

        var day = date.getDate().toString();
        day = day.length > 1 ? day : '0' + day;

        return day + '/' + month + '/' + year;
    }

    function EnableActiveFrom() {
        document.getElementById('<%=btnCalendarActiveFrom.ClientID %>').disabled = false;
            document.getElementById('<%=txtRemarkActiveFrom.ClientID %>').disabled = false;
    }

    function DisableActiveFrom() {
        document.getElementById('<%=btnCalendarActiveFrom.ClientID %>').disabled = true;
            document.getElementById('<%=txtRemarkActiveFrom.ClientID %>').disabled = true;
        }

    function CheckValidDates() {
        var fromStr = document.getElementById('<%= txtValidFrom.ClientID %>').value;
            var toStr = document.getElementById('<%= txtValidTo.ClientID %>').value;
            var activeFromStr = document.getElementById('<%= txtRemarkActiveFrom.ClientID %>').value;

            if (fromStr != '' && toStr != '') {

                fromArr = fromStr.split('/');
                toArr = toStr.split('/');

                var fromDate = new Date(fromArr[1] + "/" + fromArr[0] + "/" + fromArr[2]);
                var toDate = new Date(toArr[1] + "/" + toArr[0] + "/" + toArr[2]);

                if (toDate < fromDate) {
                    alert('טווח תאריכים לא תקין');
                    document.getElementById('<%= txtValidTo.ClientID %>').value = '';

                }
            }

        }

    function DisableSaveButtons() {
        document.getElementById('<%=btnSave.ClientID %>').disabled = true;
    }
    function EnableSaveButtons() {
        document.getElementById('<%=btnSave.ClientID %>').disabled = false;
    }

    function CheckDataToEnableControls() {
        var fromStr = document.getElementById('<%= txtValidFrom.ClientID %>').value;
            var toStr = document.getElementById('<%= txtValidTo.ClientID %>').value;
            var activeFromStr = document.getElementById('<%= txtRemarkActiveFrom.ClientID %>').value;

            if (fromStr != '' && toStr != '') {

                fromArr = fromStr.split('/');
                toArr = toStr.split('/');

                var fromDate = new Date(fromArr[1] + "/" + fromArr[0] + "/" + fromArr[2]);
                var toDate = new Date(toArr[1] + "/" + toArr[0] + "/" + toArr[2]);

                if (toDate >= fromDate) {
                    EnableSaveButtons();
                    EnableActiveFrom();
                }
                else {
                    DisableSaveButtons();
                    DisableActiveFrom();
                }
            }
            else {
                DisableSaveButtons();
                DisableActiveFrom();
            }
    }

    function CheckActiveFrom() {
        var fromStr = document.getElementById('<%= txtValidFrom.ClientID %>').value;
            var toStr = document.getElementById('<%= txtValidTo.ClientID %>').value;
            var activeFromStr = document.getElementById('<%= txtRemarkActiveFrom.ClientID %>').value;

            fromArr = fromStr.split('/');
            toArr = toStr.split('/');
            activeArr = activeFromStr.split('/');

            var fromDate = new Date(fromArr[1] + "/" + fromArr[0] + "/" + fromArr[2]);
            var toDate = new Date(toArr[1] + "/" + toArr[0] + "/" + toArr[2]);
            var activeDate = new Date(activeArr[1] + "/" + activeArr[0] + "/" + activeArr[2]);

            if (activeDate > toDate) {
                alert("התאריך לא יכול להיות גדול מתאריך תוקף");
                document.getElementById('<%= txtRemarkActiveFrom.ClientID %>').value = "";
            }

        }

    function SetEligibleDateForActiveFrom() {
        var activeFromStr = document.getElementById('<%= txtRemarkActiveFrom.ClientID %>').value;

            if (activeFromStr == "היום") {
                var today = new Date();
                var dd = today.getDate();
                var mm = today.getMonth() + 1;

                var yyyy = today.getFullYear();
                if (dd < 10) {
                    dd = '0' + dd;
                }
                if (mm < 10) {
                    mm = '0' + mm;
                }

                document.getElementById('<%= txtRemarkActiveFrom.ClientID %>').value = dd + '/' + mm + '/' + yyyy;
            }
        }

</script>
<table id="tblHidden" style="display:none" dir="rtl">
    <tr>
        <td>
            <asp:TextBox ID="txtDicRemarkID" runat="server"></asp:TextBox>
        </td> 
    </tr>
</table>
<table cellspacing="0" cellpadding="0" dir="rtl">
    <tr>
        <td style="padding-right:10px"><!-- Upper Blue Bar -->
            <table cellpadding="0" cellspacing="0" style="width:100%">
                <tr><td style="background-color:#298AE5; height:18px;">&nbsp;</td></tr>
            </table>
        </td>
    </tr>
    <tr>
        <td style="padding-right:10px; padding-top:5px">
            <table cellpadding="0" cellspacing="0" border="0" style=" background-color:#F7F7F7">
                <tr>
                    <td style="height:8px; background-image:url('../Images/Applic/RTcornerGrey10.gif'); background-repeat:no-repeat; background-position: top right">
                    </td>
                    <td style="background-image:url('../Images/Applic/borderGreyH.jpg'); background-repeat:repeat-x; background-position: top">
                    </td>
                    <td style="background-image:url('../Images/Applic/LTcornerGrey10.gif'); background-repeat:no-repeat; background-position: top left">
                    </td>
                </tr>
                <tr>
                    <td colspan="3" style="border-right:solid 2px #909090;border-left:solid 2px #909090;">
                        <asp:ValidationSummary ID="vldSum" ValidationGroup="vldGrSave" runat="server" />
                    </td>
                </tr>
                <tr>
                    <td style="border-right:solid 2px #909090;">
                        <div style="width:6px;"></div>
                    </td>
                    <td align="right" style="padding-right:15px">
                    <div style="width:950px">
                        <table cellpadding="0" cellspacing="0" border="0" > 
                            <tr> 
                                <td align="right" style="width:90px;">
                                    <asp:Label ID="lblDistricts" runat="server" Text="מחוזות"></asp:Label>
                                </td>
                                <td valign="top">
                                    <table cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td>
                                                <asp:TextBox ID="txtDistrictList" runat="server" onchange="RestoreDistricts();" Width="400px"
                                                    ReadOnly="false" TextMode="MultiLine" Height="40px" 
                                                    CssClass="TextBoxMultiLine" EnableTheming="false"></asp:TextBox>
                                                <ajaxToolkit:AutoCompleteExtender runat="server" ID="autoCompleteDistricts" TargetControlID="txtDistrictList"
                                                    ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="getDistricts"
                                                    MinimumPrefixLength="1" CompletionInterval="500" CompletionListItemCssClass="CompletionListItemStyle"
                                                    UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                                    EnableCaching="true" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                                    CompletionListCssClass="CopmletionListStyleWidth" OnClientItemSelected="getDistrictCode" />
                                                <asp:TextBox ID="txtDistrictCodes" runat="server" TextMode="multiLine" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>
                                            </td>
                                            <td valign="top" align="right">
                                                <input type="image" id="btnDistrictsPopUp" runat="server" style="cursor: pointer;" src="../Images/Applic/icon_magnify.gif"
                                                    onclick="return SelectDistricts()" />
                                            </td>
                                            <td>
                                                <asp:RequiredFieldValidator ID="vldTxtDistrictCodes" runat="server" Display="Dynamic" Text="*" ErrorMessage="חובה לבחור מחוז אחד לפחות" ControlToValidate="txtDistrictCodes" ValidationGroup="vldGrSave"></asp:RequiredFieldValidator>
                                            </td>
                                            <td>

                                                <asp:TextBox ID="txtDistrictsPermitted" runat="server" EnableTheming="false" CssClass="DisplayNone" ></asp:TextBox>
                                                <asp:TextBox ID="txtDistrictListClone" runat="server" EnableTheming="false" CssClass="DisplayNone" ></asp:TextBox>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td align="right">
                                    <asp:Label ID="lblAdministrations" runat="server" Text="מנהלות"></asp:Label>
                                </td>
                                <td valign="top">
                                    <table cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td>
                                                <asp:TextBox ID="txtAdminList" runat="server" onchange="ClearAdmin();" 
                                                    Width="400px" TextMode="MultiLine" Height="40px" CssClass="TextBoxMultiLine" 
                                                    EnableTheming="false"></asp:TextBox>   
                                                <ajaxToolkit:AutoCompleteExtender runat="server" ID="autoCompleteAdmins" TargetControlID="txtAdminList"
                                                    ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="GetAdminByName_DistrictDepended"
                                                    MinimumPrefixLength="1" CompletionInterval="500" CompletionListItemCssClass="CompletionListItemStyle"
                                                    UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                                    EnableCaching="true" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                                    CompletionListCssClass="CopmletionListStyleWidth" OnClientItemSelected="getAdminCode" />
                                                <asp:TextBox ID="txtAdminCodes" runat="server" TextMode="multiLine" EnableTheming="false" cssClass="DisplayNone"></asp:TextBox>
                                            </td>
                                            <td valign="top">
                                                <input type="image" id="btnAdminPopUp" style="cursor: pointer;" src="../Images/Applic/icon_magnify.gif"
                                                    onclick="return SelectAdmins()" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td align="right">
                                    <asp:Label ID="lblSectors" runat="server" Text="מגזרים"></asp:Label>
                                </td>
                                <td valign="top">
                                        <asp:DropDownList ID="ddlPopulationSectors" runat="server" Width="219px" AppendDataBoundItems="true"
                                            DataTextField="PopulationSectorDescription" 
                                            DataValueField="PopulationSectorID"
                                            onchange="PopulationSectorsChanged()">
                                            <asp:ListItem Value="-1" Text=" "></asp:ListItem>
                                        </asp:DropDownList>
                                </td>
                            </tr>
                            <tr>
                                <td align="right">
                                    <asp:Label ID="lblUnitTypes" runat="server" Text="סוגי יחידות"></asp:Label>
                                </td>
                                <td valign="top">
                                    <table cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td>
                                                <asp:TextBox ID="txtUnitTypeList" ReadOnly="false" onfocus="SyncronizeUnitTypeList();"
                                                    onchange="ClearUnitTypeList();" runat="server" Width="400px" TextMode="MultiLine"
                                                    Height="40px" CssClass="TextBoxMultiLine" EnableTheming="false"></asp:TextBox>
                                                <asp:TextBox ID="txtUnitTypeList_ToCompare" runat="server" CssClass="DisplayNone" EnableTheming="false"></asp:TextBox>
                                                <ajaxToolkit:AutoCompleteExtender runat="server" ID="autoCompleteUnitType" TargetControlID="txtUnitTypeList"
                                                    ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="getUnitTypesByName"
                                                    MinimumPrefixLength="1" CompletionInterval="500" CompletionListItemCssClass="CompletionListItemStyle"
                                                    UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                                    EnableCaching="true" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                                    CompletionListCssClass="CopmletionListStyleWidth" OnClientItemSelected="getSelectedUnitTypeCode"  />
                                                <asp:TextBox ID="txtUnitTypeListCodes" runat="server" EnableTheming="false" CssClass="DisplayNone" TextMode="MultiLine"></asp:TextBox>
                                            </td>
                                            <td valign="top" >
                                                <input type="image" id="btnUnitTypeListPopUp" style="cursor: pointer;" src="../Images/Applic/icon_magnify.gif"
                                                    onclick="return SelectUnitType()" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:Label ID="lblSubUnitType" runat="server" Visible="false">שיוך</asp:Label>
                                </td>
                                <td>
                                    <asp:DropDownList ID="ddlSubUnitType" runat="server" Visible="false"
                                        Width="219px" DataTextField="subUnitTypeName" 
                                        DataValueField="subUnitTypeCode" Height="20px"
                                        onchange="SubUnitTypeChanged()"></asp:DropDownList>
                                </td>
                            </tr>
                            <tr>
                                <td align="right">
                                    <asp:Label ID="lblCity" runat="server" Text="ישוב"></asp:Label>
                                </td>
                                <td valign="top">
                                    <table cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td align="right" style="width: 180px;">
                                                <asp:TextBox ID="txtCityName" Width="400px" runat="server" Height="30px" TextMode="MultiLine" onchange="ClearCitySearchControlOnChangeCityName();"/>
                                                <asp:TextBox ID="txtCityNameOnly" Width="100px" runat="server" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>
                                                <asp:TextBox ID="txtCityNameToCompare" runat="server" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>
                                                <asp:TextBox runat="server" ID="txtCityCode" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>
                                                <ajaxToolkit:AutoCompleteExtender runat="server" ID="autoCompleteCities" TargetControlID="txtCityName"
                                                    BehaviorID="acCities" ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="GetCitiesAndDistricts_MultipleDistricts"
                                                    MinimumPrefixLength="1" CompletionInterval="1000" CompletionListItemCssClass="CompletionListItemStyle"
                                                    UseContextKey="True" OnClientItemSelected="OnDDCityCodeSelected" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                                    EnableCaching="false" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                                    CompletionListCssClass="CopmletionListStyle" />
                                            </td>
                                            <td style="width: 40px;" valign="top">
                                                <input type="image" id="btnCitiesListPopUp" runat="server" style="cursor: pointer;"
                                                src="../Images/Applic/icon_magnify.gif" onclick="SelectCities(); return false;" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td align="right">
                                    <asp:Label ID="lblProfessions" runat="server" Text="שירות/מקצוע"></asp:Label>
                                </td>
                                <td valign="top">
                                    <table cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td align="right">
                                                <asp:TextBox ID="txtProfessionList" onfocus="SyncronizeProfessionList();"
                                                    onchange="ClearProfessionList();" ReadOnly="false" runat="server" Width="400px"
                                                    TextMode="MultiLine" Height="40px" CssClass="TextBoxMultiLine" EnableTheming="false"></asp:TextBox>
                                                <asp:TextBox ID="txtProfessionList_ToCompare" runat="server" CssClass="DisplayNone"
                                                    EnableTheming="false">
                                                </asp:TextBox>
                                                <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteProfessions" TargetControlID="txtProfessionList"
                                                    ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="GetServicesAndEventsByName"
                                                    MinimumPrefixLength="1" CompletionInterval="500" CompletionListItemCssClass="CompletionListItemStyle"
                                                    UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                                    EnableCaching="false" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                                    CompletionListCssClass="CopmletionListStyleWidth" OnClientItemSelected="getSelectedProfessionCode" />
                                                <asp:TextBox ID="txtProfessionListCodes" runat="server" CssClass="DisplayNone" TextMode="multiLine"
                                                    EnableTheming="false"></asp:TextBox>                                                    
                                            </td>
                                            <td valign="top">
                                                <input type="image" id="btnProfessionListPopUp" runat="server" style="cursor: pointer;"
                                                src="../Images/Applic/icon_magnify.gif" onclick="SelectProfession(); return false;" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr> 
                                <td align="right" style="width:90px;">
                                    <asp:Label ID="lblExcludedDepts" runat="server" Text="יחידות לא כלולות"></asp:Label>
                                </td>
                                <td valign="top">
                                    <table cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td>
                                                <asp:TextBox ID="txtExcludedDeptList" runat="server" 
                                                    Width="400px"
                                                    TextMode="MultiLine" Height="40px" 
                                                    CssClass="TextBoxMultiLine" EnableTheming="false" Enabled="false"></asp:TextBox>
                                                <%--<ajaxToolkit:AutoCompleteExtender runat="server" ID="ACExcludedDepts" TargetControlID="txtDistrictList"
                                                    ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="getDistricts"
                                                    MinimumPrefixLength="1" CompletionInterval="500" CompletionListItemCssClass="CompletionListItemStyle"
                                                    UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                                    EnableCaching="true" CompletionSetCount="12" DelimiterCharacters="" Enabled="False"
                                                    CompletionListCssClass="CopmletionListStyleWidth" OnClientItemSelected="getDistrictCode" />--%>
                                                <asp:TextBox ID="txtExcludedDeptCodes" runat="server" TextMode="multiLine" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>
                                            </td>
                                            <td valign="top" align="right">
                                                <input type="image" id="btnExcludedClinicsPopUp" runat="server" style="cursor: pointer;" src="../Images/Applic/icon_magnify.gif"
                                                     onclick="return SelectExcludedClinics()"/>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:Label ID="lblValidFrom" runat="server" Text="בתוקף מ"></asp:Label>
                                </td>
                                <td >
                                    <table cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td>
                                                <asp:TextBox ID="txtValidFrom" Width="70px" runat="server" Text='<%# Bind("ValidFrom","{0:d}") %>'  onChange="SetActiveFrom();CheckDataToEnableControls();"></asp:TextBox>
                                                <asp:ImageButton ImageUrl="~/Images/Applic/calendarIcon.png" ID="btnRunCalendar_Date" runat="server"/>
                                                <ajaxToolkit:CalendarExtender ID="calExtValidFrom" runat="server" 
                                                    Format="dd/MM/yyyy" FirstDayOfWeek="Sunday"
                                                    TargetControlID="txtValidFrom" 
                                                    PopupPosition="BottomRight"
                                                    PopupButtonID="btnRunCalendar_Date">
                                                </ajaxToolkit:CalendarExtender>
                                                <ajaxToolkit:maskededitextender 
                                                    id="DateExtender" 
                                                    runat="server" 
                                                    acceptampm="false"
                                                    errortooltipenabled="True" 
                                                    mask="99/99/9999" 
                                                    masktype="Date"
                                                    messagevalidatortip="true"
                                                    onfocuscssclass="MaskedEditFocus" 
                                                    oninvalidcssclass="MaskedEditError" 
                                                    targetcontrolid="txtValidFrom">
                                                </ajaxToolkit:maskededitextender>
                                                <ajaxToolkit:MaskedEditValidator ID="DateValidator" runat="server" 
                                                    ControlExtender="DateExtender"
                                                    ControlToValidate="txtValidFrom"
                                                    IsValidEmpty="True"
                                                    InvalidValueMessage="התאריך אינו תקין"
                                                    Display="Dynamic"
                                                    InvalidValueBlurredMessage="*"
                                                    ValidationGroup="vldGrSave"
                                                    />
                                            </td>
                                            <td style="padding-right:15px; padding-left:5px">
                                                <asp:Label ID="lblValidTo" runat="server" Text="בתוקף עד"></asp:Label>
                                            </td>
                                            <td>
                                                <asp:TextBox ID="txtValidTo" Width="70px" runat="server" Text='<%# Bind("ValidTo","{0:d}") %>' onchange="CheckValidDates(); CheckDataToEnableControls();"></asp:TextBox>
                                                <asp:ImageButton ImageUrl="~/Images/Applic/calendarIcon.png" ID="btnRunCalendar_Date2" runat="server"/>
                                                <ajaxToolkit:CalendarExtender ID="calExtValidTo" runat="server" 
                                                    Format="dd/MM/yyyy" FirstDayOfWeek="Sunday"
                                                    TargetControlID="txtValidTo" 
                                                    PopupPosition="BottomRight"
                                                    PopupButtonID="btnRunCalendar_Date2">
                                                </ajaxToolkit:CalendarExtender>
                                                <ajaxToolkit:maskededitextender 
                                                    id="DateExtender2" 
                                                    runat="server" 
                                                    acceptampm="false"
                                                    errortooltipenabled="True" 
                                                    mask="99/99/9999" 
                                                    masktype="Date"
                                                    messagevalidatortip="true"
                                                    onfocuscssclass="MaskedEditFocus" 
                                                    oninvalidcssclass="MaskedEditError" 
                                                    targetcontrolid="txtValidTo">
                                                </ajaxToolkit:maskededitextender>
                                                <ajaxToolkit:MaskedEditValidator ID="DateValidator2" runat="server" 
                                                    ControlExtender="DateExtender2"
                                                    ControlToValidate="txtValidTo"
                                                    IsValidEmpty="True"
                                                    InvalidValueMessage="התאריך אינו תקין"
                                                    Display="Dynamic"
                                                    InvalidValueBlurredMessage="*"
                                                    ValidationGroup="vldGrSave"
                                                    />
                                                 <asp:CompareValidator ID="vldDatesRange" runat="server" 
                                                            ControlToValidate="txtValidFrom"  ControlToCompare="txtValidTo" Operator="LessThanEqual"
                                                            Text="*" ValidationGroup="vldGrSave" Type="Date"></asp:CompareValidator>
                                            </td>
                                            <td style="padding-right:10px; padding-left:5px">
                                                <asp:Label ID="lblActiveFrom" runat="server" Text="יוצג החל מ:"></asp:Label>
                                            </td>
                                            <td>
                                                <asp:TextBox ID="txtRemarkActiveFrom" runat="server" Width="70px" onchange="CheckActiveFrom();"></asp:TextBox>
                                                <asp:TextBox ID="txtShowForPreviousDaysForSelectedRemark" runat="server" Width="40px" CssClass="DisplayNone" EnableTheming="false" Enabled="False"></asp:TextBox>
                                                <asp:TextBox ID="txtOpenNow" runat="server" Width="40px" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>

                                                <asp:ImageButton ImageUrl="~/Images/Applic/calendarIcon.png" ID="btnCalendarActiveFrom" runat="server"/>
                                                <ajaxToolkit:CalendarExtender ID="calExtActiveFrom" runat="server" 
                                                    Format="dd/MM/yyyy" FirstDayOfWeek="Sunday"
                                                    TargetControlID="txtRemarkActiveFrom" 
                                                    PopupPosition="BottomRight"
                                                    PopupButtonID="btnCalendarActiveFrom">
                                                </ajaxToolkit:CalendarExtender>
                                                <ajaxToolkit:maskededitextender 
                                                    id="DateExtender3" 
                                                    runat="server" 
                                                    acceptampm="false"
                                                    errortooltipenabled="True" 
                                                    mask="99/99/9999" 
                                                    masktype="Date"
                                                    messagevalidatortip="true"
                                                    onfocuscssclass="MaskedEditFocus" 
                                                    oninvalidcssclass="MaskedEditError" 
                                                    targetcontrolid="txtRemarkActiveFrom">
                                                </ajaxToolkit:maskededitextender>
                                                <ajaxToolkit:MaskedEditValidator ID="MaskedEditValidator1" runat="server" 
                                                    ControlExtender="DateExtender3"
                                                    ControlToValidate="txtRemarkActiveFrom"
                                                    IsValidEmpty="True"
                                                    InvalidValueMessage="התאריך אינו תקין"
                                                    Display="Dynamic"
                                                    InvalidValueBlurredMessage="*"
                                                    ValidationGroup="vldGrSave"
                                                    />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:Label ID="lblInternetDisplay" runat="server" Text="הצג באינטרנט"></asp:Label>
                                </td>
                                <td style="height:30px">
                                    <div style="width:40px; float:right;">
                                    <asp:CheckBox ID="cbInternetDisplay" runat="server" Checked="false" OnClick="Show_lblAlert();"/>
                                    </div>
                                    <div style="width:320px; float:right;">
                                    <span id="lblAlert" runat="server" style="width:320px; font-size:14px; height:25px; font-weight:bold; vertical-align:central;">כאשר ההערה בתוקף – לא יוצג "פתוח כעת" באינטרנט</span>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:Label ID="lblRemark" runat="server" Text="הערה"></asp:Label>
                                </td>
                                <td id="tdRemark" width="800px" dir="rtl" class="ViewField1">
                                    <asp:PlaceHolder ID="plhEditRemark" runat="server"></asp:PlaceHolder>
                                    <asp:TextBox runat="server" ID="txtRemarkText" EnableTheming="false" TextMode="MultiLine" Height="100px" Width="800px" Visible="false"></asp:TextBox>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2" style="display:none">
                                    <asp:TextBox ID="txtRemarkFormatedText" Width="600px" runat="server" ></asp:TextBox>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                </td>
                                <td>
                                    <table cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td style="background-image:url(../Images/Applic/regButtonBG_Right.gif); background-repeat:no-repeat; background-position:bottom left;">&nbsp;
                                            </td>
                                            <td style="vertical-align:bottom; background-image:url(../Images/Applic/regButtonBG_Middle.gif); background-repeat:repeat-x; background-position:bottom;">
                                                <asp:Button id="btnSave" runat="server" Text="שמירה" cssClass="RegularUpdateButton" 
                                                    ValidationGroup="vldGrSave" Width="50px" onclick="btnSave_Click" OnClientClick="SetEligibleDateForActiveFrom();SaveRemarkInHidden(); ShowProgressBar();"></asp:Button>
                                            </td>
                                            <td style="background-position:right bottom; background-image:url(../Images/Applic/regButtonBG_Left.gif); background-repeat:no-repeat;">&nbsp;
                                            </td>
                                            <td style="background-image:url(../Images/Applic/regButtonBG_Right.gif); background-repeat:no-repeat; background-position:bottom left;">&nbsp;
                                            </td>
                                            <td style="vertical-align:bottom; background-image:url(../Images/Applic/regButtonBG_Middle.gif); background-repeat:repeat-x; background-position:bottom;">
                                                <asp:Button id="btnCancel" runat="server" Text="ביטול" cssClass="RegularUpdateButton" Width="50px" onclick="btnCancel_Click"></asp:Button>
                                            </td>
                                            <td style="background-position:right bottom; background-image:url(../Images/Applic/regButtonBG_Left.gif); background-repeat:no-repeat;">&nbsp;
                                            </td>
                                        </tr>
                                    </table>
                                
                                </td>
                            </tr>
                        </table>
                    
                    </div>
                    </td>
                    <td style="border-left:solid 2px #909090;">
                        <div style="width:6px;"></div>
                    </td>
                </tr>
                <tr style="height:10px">
                    <td style="background-image:url('../Images/Applic/RBcornerGrey10.gif'); background-repeat:no-repeat; background-position: bottom right">
                    </td>
                    <td style="background-image:url('../Images/Applic/borderGreyH.jpg'); background-repeat:repeat-x; background-position: bottom">
                    </td>
                    <td style="background-image:url('../Images/Applic/LBcornerGrey10.gif'); background-repeat:no-repeat; background-position: bottom left">
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td style="padding-right:10px; padding-top:5px"><!-- Bottom Blue Bar -->
            <table cellpadding="0" cellspacing="0" style="width:100%">
                <tr><td style="background-color:#298AE5; height:18px;">&nbsp;</td></tr>
            </table>
        </td>
    </tr>
                    
        
</table>

</asp:Content>

