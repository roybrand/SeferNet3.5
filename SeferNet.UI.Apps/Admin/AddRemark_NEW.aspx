<%@ Page Title=" " Language="C#" MasterPageFile="~/SeferMasterPageIEwide.master" AutoEventWireup="true"
    UICulture="he-il" Culture="he-il" Inherits="Admin_AddRemark_NEW"
    ValidateRequest="false" Codebehind="AddRemark_NEW.aspx.cs" %>
    
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxtoolkit" %>
<%@ Register Src="../UserControls/MultiDDlSelect.ascx" TagName="MultiDDlSelect" TagPrefix="uc1" %>
<%@ Register TagPrefix="uc1" TagName="sortableColumn" Src="~/UserControls/SortableColumnHeader.ascx" %>
<%@ Register src="../UserControls/RemarkClientHandler.ascx" tagname="RemarkClientHandler" tagprefix="uc2" %>

<%@ Register TagPrefix="uc3" TagName="RemarkControl" Src="../UserControls/RemarkControl.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="pageContent" runat="Server">
<%--    <link rel="stylesheet" href="Scripts/jquery-ui/jquery-ui.css"/>
    <script type="text/javascript" src="../Scripts/jquery/jquery.js"></script> 
    <script type="text/javascript" src="../Scripts/jquery-ui/jquery-ui.js"></script>--%>
        <script type="text/javascript" defer="defer">
            var txtHandicappedFacilitiesCodesClientID = '<%=txtHandicappedFacilitiesCodes.ClientID %>';
            var txtHandicappedFacilitiesListClientID = '<%=txtHandicappedFacilitiesList.ClientID %>';

            function getSelectedHandicappedFacilityCode(source, eventArgs) {

                document.getElementById(txtHandicappedFacilitiesCodesClientID).value = eventArgs.get_value();
                //document.getElementById(txtHandicappedFacilitiesList_ToCompareClientID).value = eventArgs.get_text();
                document.getElementById(txtHandicappedFacilitiesListClientID).value = eventArgs.get_text();
            }
        </script>
    <script language="javascript" type="text/javascript" defer="defer">

        var lastPage = "<%=lastPage %>";
        var isModalWindow = "<%=isModalWindow %>";

        var txtShowForPreviousDaysForSelectedRemark_ClientID = '<%=txtShowForPreviousDaysForSelectedRemark.ClientID %>';
        var txtRemarkValidFrom_ClientID = '<%=txtRemarkValidFrom.ClientID %>';
        var txtRemarkActiveFrom_ClientID = '<%=txtRemarkActiveFrom.ClientID %>';
        var chkDisplayOnInternet_ClientID = '<%=chkDisplayOnInternet.ClientID %>';
        var txtOpenNow_ClientID = '<%=txtOpenNow.ClientID %>';
        var lblAlert_ClientID = '<%=lblAlert.ClientID %>';

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

        function CheckSelect(currentItemID, currGeneralRemarkID, currRemarkFormatText, ShowForPreviousDays, OpenNow) {
            closeTableDays();
            tblDaysIsOpen = false;
            document.getElementById("<%=hfCurrGeneralRemarkID.ClientID %>").value = currGeneralRemarkID;
            document.getElementById("<%=hfCurrRemarkFormatText.ClientID %>").value = currRemarkFormatText;

            document.getElementById("<%=hfPrepareSelectedRemark.ClientID %>").value = 1; //new

           document.getElementById(txtShowForPreviousDaysForSelectedRemark_ClientID).value = ShowForPreviousDays;
           document.getElementById(txtOpenNow_ClientID).value = OpenNow;

           if (document.getElementById(txtOpenNow_ClientID).value == 1 && document.getElementById(chkDisplayOnInternet_ClientID).checked) {
               document.getElementById(lblAlert_ClientID).style.display = "block";
           }
           else {
               document.getElementById(lblAlert_ClientID).style.display = "none";
           }

           document.getElementById(txtRemarkActiveFrom_ClientID).value = GetActiveFromDate(document.getElementById(txtRemarkValidFrom_ClientID).value, ShowForPreviousDays);

           var allRadios = document.getElementsByTagName("input");

           for (i = 0; i < allRadios.length; i++) {
               if (allRadios[i].type == "radio") {
                   allRadios[i].checked = false;
               }
           }

           try {
               CheckDataToEnableControls();
                //document.getElementById("<%=btnSave.ClientID %>").removeAttribute("disabled");
            }
            catch (e) {
                document.getElementById("<%=btnSaveClientSide.ClientID %>").removeAttribute("disabled");
            }

            document.getElementById(currentItemID).checked = true;

            setRemarks(currRemarkFormatText);

            $('[id*=txtGenaralRemarkID]').val(currGeneralRemarkID);

            document.getElementById("<%=btnBindRemark.ClientID %>").click();
            //return false;
        }

        function RadioButtonClick(rbClientID, currGeneralRemarkID, remarkText) {

            var allRadios = document.getElementsByTagName("input");

            for (i = 0; i < allRadios.length; i++) {
                if (allRadios[i].type == "radio") {
                    allRadios[i].checked = false;
                }
            }
            alert(currGeneralRemarkID);
            //$("[id*='" + rbClientID + "']").prop("checked", true);
            var rdbutton = getElementById(rbClientID);
            rdbutton.checked = true;
            //getElementById(rbClientID).checked = true;
            $('[id*=txtGenaralRemarkID]').val(currGeneralRemarkID);
            //$('[id*=txtGenaralRemarkText]').val(remarkText);

 
        }

        function RadioButtonClick_2(rbClientID, currGeneralRemarkID, remarkText) {
            var allRadios = document.getElementsByTagName("input");

            for (i = 0; i < allRadios.length; i++) {
                if (allRadios[i].type == "radio") {
                    allRadios[i].checked = false;
                }
            }

            $("[id*='" + rbClientID + "']").prop("checked", true);
            $('[id*=txtGenaralRemarkID]').val(currGeneralRemarkID);
            $('[id*=txtGenaralRemarkText]').val(remarkText);
            alert("Hi");
            //$("[id*=rbHeaderASP]").prop("checked", true);
            //alert($("[id*=rbHeaderASP]").is(':checked'));
        }

            //document.getElementById("<%=hfPrepareSelectedRemark.ClientID %>").value = 1;
            //this.form.submit();

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

        function scrolldiv(top) {
            var div = document.getElementById("<%=divRemarksGrid.ClientID %>")
            div.scrollTop = top;
        }


        function setRemarkText() {
            var txtRemarkIsOfReachTextFormat = document.getElementById('<%= txtRemarkIsOfReachTextFormat.ClientID %>');
            if (txtRemarkIsOfReachTextFormat.value == "") {
                backToDateText();
                if (notValidObjectsList != "") {
                    event.returnValue = false;
                }
                else {
                    var remark = "";
                    var splitList = listOfInputID.split("#");

                    $.each(splitList, function () {

                        var arr = this.split("~");
                        if (arr.length == 1) {
                            remark += $("#" + arr[0]).text();
                        }
                        else {
                            remark += "#" + $("#" + arr[0]).val() + "~" + arr[1] + "#";
                        }

                    });

                    document.getElementById("<%=txtFormatedRemark.ClientID %>").value = remark;
                }
            }
            else {
                document.getElementById("<%=txtFormatedRemark.ClientID %>").value = document.getElementById("<%=txtRemarkText.ClientID %>").value;
            }
        }

        function cancel() {
            try {
                SelectJQueryClose();
            } catch (e) {
                cancel_when_opened_as_NOT_JQueryDialog();
            }
        }

        function cancel_when_opened_as_NOT_JQueryDialog() {
            if (lastPage == "") {
                self.close();
            }
            else {
                document.location.href = lastPage;
            }
        }

        function CloseItselfAsModalWindow() {
            var obj = new Object();

            var remarkID = document.getElementById("<%=hfCurrGeneralRemarkID.ClientID %>").value;

            var remark = document.getElementById("<%=txtFormatedRemark.ClientID %>").value;
            remark = getFormatedRemark(remark);

            var whereToPutRemark = window.parent.$("[id$='txtWherePutRemark']").val;

            window.parent.$("[id$='txtSelectedRemarkID_FromDialog']").val(remarkID); // OK
            window.parent.$("[id$='txtSelectedRemark_FromDialog']").val(remark); // OK
            window.parent.$("[id$='txtSelectedRemarkMask_FromDialog']").val(remark);

            var SelectedEnableOverMidnightHours = $("input:hidden[id$=hdnRemarkID][value=" + remarkID + "]")
                .nextAll("input:hidden[id$=hdnEnableOverMidnightHours]").get(0).value;
            window.parent.$("[id$='txtSelectedEnableOverMidnightHours_FromDialog']").val(SelectedEnableOverMidnightHours);

            var SelectedEnableOverlappingHours = $("input:hidden[id$=hdnRemarkID][value=" + remarkID + "]")
                .nextAll("input:hidden[id$=hdnEnableOverlappingHours]").get(0).value;
            window.parent.$("[id$='txtSelectedEnableOverlappingHours_FromDialog']").val(SelectedEnableOverlappingHours);

            parent.SetRemark();

            SelectJQueryClose();
        }

        function CloseItselfAsModalWindow_OLD() {

            var obj = new Object();
            var remarkID = document.getElementById("<%=hfCurrGeneralRemarkID.ClientID %>").value;

            var remark = document.getElementById("<%=txtFormatedRemark.ClientID %>").value;
            remark = getFormatedRemark(remark);

            obj.SelectedRemark = escape(remark);

            obj.SelectedRemarkMask = escape(remark);

            obj.SelectedRemarkID = document.getElementById("<%=hfCurrGeneralRemarkID.ClientID %>").value;

            obj.SelectedEnableOverMidnightHours = $("input:hidden[id$=hdnRemarkID][value=" + remarkID + "]")
                .nextAll("input:hidden[id$=hdnEnableOverMidnightHours]").get(0).value;

            obj.SelectedEnableOverlappingHours = $("input:hidden[id$=hdnRemarkID][value=" + remarkID + "]")
                .nextAll("input:hidden[id$=hdnEnableOverlappingHours]").get(0).value;

            window.returnValue = obj;

            self.close();
        }


        function getFormatedRemark(remark) {

            var res = "";
            var arrOfText = remark.split("#");
            for (var i = 0; i < arrOfText.length; i++) {
                var val = arrOfText[i].split("~")[0];

                if (res == "") {
                    res += val;
                }
                else {
                    res += " " + val;
                }
            }

            return res;
        }

        function onfocusoutFromDate(txtName) {

            var txtFromDate = document.getElementById(txtName);
            if (txtFromDate.value == '__/__/____')
                txtFromDate.value = '<%=DateTime.Today.ToShortDateString() %>';
        }

        function CheckValidDates() {
            var offset = $("#<%=txtRemarkValidTo.ClientID %>").offset();

            var fromStr = document.getElementById('<%= txtRemarkValidFrom.ClientID %>').value;
            var toStr = document.getElementById('<%= txtRemarkValidTo.ClientID %>').value;
            var activeFromStr = document.getElementById('<%= txtRemarkActiveFrom.ClientID %>').value;

            if (fromStr != '' && toStr != '') {

                fromArr = fromStr.split('/');
                toArr = toStr.split('/');

                var fromDate = new Date(fromArr[1] + "/" + fromArr[0] + "/" + fromArr[2]);
                var toDate = new Date(toArr[1] + "/" + toArr[0] + "/" + toArr[2]);

                if (toDate < fromDate) {
                    msg = 'טווח תאריכים לא תקין';
                    title = 'טווח תאריכים לא תקין';
                    jq_alert("AddRemark_ClearValidToAndAlert", msg, title, offset);
                }
            }

        }

        function AddRemark_ClearValidToAndAlert() {
            document.getElementById('<%= txtRemarkValidTo.ClientID %>').value = '';
        }


        function setRemarks(currRemarkFormatText) {
            ListOfTextDaysID = "";
            ListOfTextHoursID = "";
            ListOfRegularTextID = "";
            ListOfTextDateID = "";
            currentHourText = "";
            currentDateText = "";
            listOfInputID = "";

            currRemarkFormatText = currRemarkFormatText.replace("&#39;", "'");

            var divRemark = $("#divRemarks");

            var txtRemarkText = document.getElementById('<%= txtRemarkText.ClientID %>');
            var txtRemarkIsOfReachTextFormat  = document.getElementById('<%= txtRemarkIsOfReachTextFormat.ClientID %>');

            if (currRemarkFormatText == "#10#") {
                txtRemarkText.style.display = "block";
                divRemark.hide();
                txtRemarkText.value = "";//currRemarkFormatText;

                txtRemarkIsOfReachTextFormat.value = "1";
                return;
            }
            else {
                divRemark.show();
                //divRemarksRTF.style.display = "none";
                txtRemarkText.style.display = "none";
                txtRemarkIsOfReachTextFormat.value = "";
            }

            //var arrOfInputCodes = currRemarkFormatText.split(/[^#\d+#]/g);
            //var arrOfText = currRemarkFormatText.split(/[#]\d+[#]/g); 

            var arrCombined = currRemarkFormatText.split("#");
            var arrOfInputCodes = new Array();
            var arrOfInputValues = new Array();
            var arrOfText = new Array();
            var codesIndex;
            var textIndex;

            if (currRemarkFormatText.indexOf("#") == 0) {   // even elements are codes [~values], not even - text
                codesIndex = 0;
                textIndex = 1;
            }
            else {
                codesIndex = 1;
                textIndex = 0;
            }

            var i = 0;
            var ii = 0;
            while (i <= arrCombined.length) {

                if (codesIndex < arrCombined.length) {
                    arrOfInputCodes[ii] = arrCombined[codesIndex];

                    var subArray = arrOfInputCodes[ii].split("~");
                    if (subArray.length > 1) {
                        arrOfInputCodes[ii] = "#" + subArray[1] + "#";
                        arrOfInputValues[ii] = subArray[0];
                    }
                    else {
                        arrOfInputCodes[ii] = "#" + subArray[0] + "#";
                        arrOfInputValues[ii] = '';
                    }
                }

                if (textIndex < arrCombined.length) {
                    arrOfText[ii] = arrCombined[textIndex];
                }

                codesIndex = codesIndex + 2;
                textIndex = textIndex + 2;
                i = i + 2;
                ii = ii + 1;
            }


            var objInd = 0;

            divRemark.empty();
            $("#divDateMask").hide();

            for (var i = 0; i < arrOfText.length; i++) {
                var simpleTextTable = getSimpleText(arrOfText[i], objInd);
                objInd++;
                divRemark.append(simpleTextTable);
                if (i < arrOfInputCodes.length) {

                    var inputTypeCode = getInputTypeCode(arrOfInputCodes[i]);
                    var tmpTable;
                    switch (true) {
                        case (inputTypeCode < 19):

                            if (currRemarkFormatText.replace(/^\s*/, "").replace(/\s*$/, "") != '#10#')
                                tmpTable = getRegularTextBox(objInd, inputTypeCode, arrOfInputValues[i]);
                            else
                                tmpTable = getLongTextBox(objInd, inputTypeCode, arrOfInputValues[i]);

                            break;
                        case (inputTypeCode >= 20 && inputTypeCode <= 29):
                            tmpTable = getDayTypeText(objInd, inputTypeCode, arrOfInputValues[i]);
                            break;
                        case (inputTypeCode >= 30 && inputTypeCode <= 39):
                            tmpTable = getDateTextBox(objInd, inputTypeCode, arrOfInputValues[i]);
                            break;
                        case (inputTypeCode >= 40 && inputTypeCode <= 49):
                            tmpTable = getHourTextBox(objInd, inputTypeCode, arrOfInputValues[i]);
                            break;
                    }
                    objInd++;

                    divRemark.append(tmpTable);
                }
            }


            setRegularTextEvents();
            setDaysTextEvents();
            setHourTextEvents();
            setDateTextEvents();

        }

        function CalendarShown(sender, args) {

            var divSetMaxDate = document.getElementById("divSetMaxDate");
            var element = document.getElementById("<%=txtRemarkValidTo.ClientID %>");

            var rect = element.getBoundingClientRect();

            var calendarTop = sender._popupDiv.parentElement.style.top
            var calendarLeft = sender._popupDiv.parentElement.style.left;

            divSetMaxDate.innerHTML =
                "<table cellpadding='0' cellspacing='0' style='border:solid 1px #555555;'>" +
                "<tr><td class='RegularLabel' style='padding-left:5px; padding-right:5px; width:180px;height:27px' align='center'>" +
                "<input type='button' id='btnValidToDateMax' style='height:20px' onclick='SetValidToDateMax();CheckDataToEnableControls()' value='ללא תוקף' />" +
                "</td></tr>" +
                "</table>";
            divSetMaxDate.style.display = "block";
            divSetMaxDate.style.left = calendarLeft;

            if ((event.clientY - calendarTop.replace("px", "") > 0)) // put button above calendar
            {
                divSetMaxDate.style.top = (parseInt(calendarTop.replace("px", "")) - 27) + "px";
            }
            else { // put button above calendar
                divSetMaxDate.style.top = (parseInt(calendarTop.replace("px", "")) + 187) + "px";
            }
        }

        function CalendarBlurDelayed() {
            setTimeout(CalendarBlur, 150);
        }

        function CalendarBlur() {
            var divSetMaxDate = document.getElementById("divSetMaxDate");
            divSetMaxDate.style.display = "none";
        }
        function SetValidToDateMax() {
            document.getElementById("<%=txtRemarkValidTo.ClientID %>").value = '31/12/9999';
        }

        function DisableSaveButtons() {
            document.getElementById('<%=btnSave.ClientID %>').disabled = true;
        }
        function EnableSaveButtons() {
            document.getElementById('<%=btnSave.ClientID %>').disabled = false;
        }

        function EnableActiveFrom() {
            document.getElementById('<%=btnCalendarActiveFrom.ClientID %>').disabled = false;
            document.getElementById('<%=txtRemarkActiveFrom.ClientID %>').disabled = false;
        }

        function DisableActiveFrom() {
            document.getElementById('<%=btnCalendarActiveFrom.ClientID %>').disabled = true;
            document.getElementById('<%=txtRemarkActiveFrom.ClientID %>').disabled = true;
        }


        function CheckDataToEnableControls() {
            var fromStr = document.getElementById('<%= txtRemarkValidFrom.ClientID %>').value;
            var toStr = document.getElementById('<%= txtRemarkValidTo.ClientID %>').value;
            var activeFromStr = document.getElementById('<%= txtRemarkActiveFrom.ClientID %>').value;

            var CurrGeneralRemarkIDStr = document.getElementById("<%=hfCurrGeneralRemarkID.ClientID %>").value;

            if (fromStr != '' && toStr != '' && CurrGeneralRemarkIDStr != '') {

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
            var fromStr = document.getElementById('<%= txtRemarkValidFrom.ClientID %>').value;
            var toStr = document.getElementById('<%= txtRemarkValidTo.ClientID %>').value;
            var activeFromStr = document.getElementById('<%= txtRemarkActiveFrom.ClientID %>').value;
            var strAlertText = "";

            fromArr = fromStr.split('/');
            toArr = toStr.split('/');
            activeFromArr = activeFromStr.split('/');

            var fromDate = new Date(fromArr[1] + "/" + fromArr[0] + "/" + fromArr[2]);
            var toDate = new Date(toArr[1] + "/" + toArr[0] + "/" + toArr[2]);
            var activeFromDate = new Date(activeFromArr[1] + "/" + activeFromArr[0] + "/" + activeFromArr[2]);

            if (activeFromDate > toDate) {
                strAlertText = "התאריך לא יכול להיות גדול מתאריך תוקף";
            }

            if (activeFromDate > fromDate) {
                strAlertText = strAlertText + "\r\n" + " התאריך לא יכול להיות גדול מתאריך בתוקף מ";
            }

            if (strAlertText != "") {
                alert(strAlertText);
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
    <script type="text/javascript">
        function SelectQueueOrder() {
            //var txtQueueOrderCodes = document.getElementById(txtQueueOrderCodesClientID);
            //var SelectedCodesList = txtQueueOrderCodes.innerText;

            var url = "../Public/SelectPopUp.aspx";
            //url = url + "?SelectedValuesList=" + SelectedCodesList;
            url = url + "?SelectedValuesList=1";
            url = url + "&popupType=29";
            url += "&returnValuesTo='txtQueueOrderCodes'";
            url += "&returnTextTo='txtQueueOrder'";

            var dialogWidth = 420;
            var dialogHeight = 660;
            var title = "בחר אופן זימון";
            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return false;
        }
    </script>

    <div id="divSetMaxDate" style="position: absolute; width: 180px; display: block; z-index: 10; background-color: White;">
    </div>
    <table style="width: 960px;" cellpadding="0" cellspacing="0" border="0" dir="rtl">
        <tr style="background-color: #298AE5;">
            <td colspan="2" class="LabelBoldWhite_18" style="padding-bottom: 5px; padding-right: 5px">
                <asp:Label ID="lblPopupHeader" runat="server" EnableTheming="false" Text="הוספת הערות ..."></asp:Label>
            </td>
        </tr>
        <tr>
            <td style="padding-top: 2px; padding-bottom: 0px; padding-right: 2px" colspan="2">
                <table id="Border1" cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7; width: 990px;">

                    <tr id="BorderTop1">
                        <td style="height: 8px; background-image: url('../Images/Applic/RTcornerGrey10.gif'); background-repeat: no-repeat; background-position: top right"></td>
                        <td style="background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x; background-position: top"></td>
                        <td style="background-image: url('../Images/Applic/LTcornerGrey10.gif'); background-repeat: no-repeat; background-position: top left"></td>
                    </tr>
                    <tr id="trParameters">
                        <td id="BorderRight" style="width: 6px; border-right: solid 2px #909090;">&nbsp;
                        </td>
                        <td>
                            <table width="100%">
                                <tr>
                                    <td valign="top">
                                        <asp:Label ID="lblRemarkCategory" runat="server" Text="קטגוריה:"> </asp:Label>
                                    </td>
                                    <td valign="middle">
                                        <asp:DropDownList ID="ddlRemarkCategory" runat="server" Height="24px" Width="161px">
                                        </asp:DropDownList>
                                    </td>
                                    <td style="padding-right: 10px;" valign="top">
                                        <asp:Label ID="lblFilter" runat="server" Text="טקסט חופשי:" Width="80px"></asp:Label>
                                    </td>
                                    <td valign="middle">
                                        <asp:TextBox ID="txtFilterRemarks" runat="server" Width="251px"></asp:TextBox>
                                    </td>
                                    <td valign="middle" width="60px">
                                        <table border="0" cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td class="buttonRightCorner"></td>
                                                <td class="buttonCenterBackground">
                                                    <asp:Button ID="btnSearch" runat="server" CausesValidation="false" CssClass="RegularUpdateButton"
                                                        OnClick="btnSearch_click" Text="חיפוש" />
                                                </td>
                                                <td class="buttonLeftCorner"></td>
                                            </tr>
                                        </table>
                                    </td>
                                    <td>
                                        <table border="0" cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td class="buttonRightCorner"></td>
                                                <td class="buttonCenterBackground">
                                                    <asp:Button ID="btnShowAll" runat="server" CausesValidation="false" CssClass="RegularUpdateButton"
                                                        OnClick="btnShowAll_click" Text="הצג הכל" />
                                                </td>
                                                <td class="buttonLeftCorner"></td>
                                            </tr>
                                        </table>
                                    </td>
                                    <td>
                                        <input type="image" id="btnQueueOrderPopUp" style="cursor: pointer;" src="../Images/Applic/icon_magnify.gif" onclick="SelectQueueOrder(); return false;" />
                                    </td>
                                </tr>
                                <tr>
                                    <td >
                                        <asp:Label ID="lblInfo" runat="server" Visible="False"></asp:Label>
                                    </td>
                                </tr>
                                <tr>
                                    <td >
                                        <asp:TextBox ID="txtHandicappedFacilitiesList" ReadOnly="false"
                                            runat="server" Width="150px" TextMode="MultiLine"
                                            Height="20px" CssClass="TextBoxMultiLine" EnableTheming="false"></asp:TextBox>
                                        <ajaxtoolkit:AutoCompleteExtender runat="server" ID="autoCompleteHandicappedFacilities" TargetControlID="txtHandicappedFacilitiesList"
                                            ServicePath="~/AjaxWebServices/AutoComplete.asmx" ServiceMethod="GetHandicappedFacilitiesByName"
                                            MinimumPrefixLength="1" CompletionInterval="1000" CompletionListItemCssClass="CompletionListItemStyle"
                                            UseContextKey="True" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                            EnableCaching="true" OnClientItemSelected="getSelectedHandicappedFacilityCode"
                                            
                                            />
                                        <asp:TextBox ID="txtHandicappedFacilitiesCodes" runat="server" TextMode="multiLine"
                                            EnableTheming="false"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td >
                                        <asp:TextBox ID="txtClinicName" 
                                            Width="213px" 
                                            runat="server" 
                                            MaxLength="50" 
                                            EnableTheming="true"
                                            Height="20px"></asp:TextBox>
                                        <ajaxtoolkit:AutoCompleteExtender runat="server" ID="AutoCompleteClinicName" TargetControlID="txtClinicName"
                                            BehaviorID="acClinicName" ServicePath="~/AjaxWebServices/AutoComplete.asmx" 
                                            ServiceMethod="GetClinicByName"
                                            MinimumPrefixLength="1" CompletionInterval="500" CompletionListItemCssClass="CompletionListItemStyle"
                                            UseContextKey="false" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
                                            EnableCaching="false" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
                                            CompletionListCssClass="CopmletionListStyleWidth" 
                                           
                                            />
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td id="BorderLeft" style="width: 6px; border-left: solid 2px #909090;">&nbsp;
                        </td>
                    </tr>
                    <tr id="BorderBottom1" style="height: 8px">
                        <td style="background-image: url('../Images/Applic/RBcornerGrey10.gif'); background-repeat: no-repeat; background-position: bottom right"></td>
                        <td style="background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x; background-position: bottom"></td>
                        <td style="background-image: url('../Images/Applic/LBcornerGrey10.gif'); background-repeat: no-repeat; background-position: bottom left"></td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td style="padding-top: 2px; padding-bottom: 0px; padding-right: 2px" colspan="2">
                <table id="Border2" cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7; width: 990px;">

                    <tr id="BorderTop2">
                        <td style="height: 8px; width: 8px; background-image: url('../Images/Applic/RTcornerGrey10.gif'); background-repeat: no-repeat; background-position: top right"></td>
                        <td style="background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x; background-position: top"></td>
                        <td style="background-image: url('../Images/Applic/LTcornerGrey10.gif'); background-repeat: no-repeat; background-position: top left; width: 8px;"></td>
                    </tr>
                    <tr>
                        <td id="BorderRight2" style="width: 6px; border-right: solid 2px #909090;">&nbsp;
                        </td>
                        <td>
                            <table border="0">
                                <tr id="GridViewHeaders" runat="server">
                                    <td align="right" style="padding-right: 25px;">
                                        <div style="width:560px" >
                                        <uc1:sortablecolumn id="hdrRemark" runat="server" columnidentifier="remark" onsortclick="btnSort_Click"
                                            text="הערה" />
                                        </div>
                                    </td>
                                    <td align="right">
                                        <div style="width:60px" >
                                        <uc1:sortablecolumn id="hdrShowForPreviousDays" runat="server" columnidentifier="ShowForPreviousDays"
                                            onsortclick="btnSort_Click" text="ימים לתצוגה מראש" tooltip="ימים לתצוגה מראש" />
                                        </div>
                                    </td>
                                    <td align="right">
                                        <div style="width:65px" >
                                        <uc1:sortablecolumn id="hdrOpenNow" runat="server" columnidentifier="OpenNow"
                                            onsortclick="btnSort_Click" text="משפיע על פתוח כעת" tooltip="משפיע על פתוח כעת" />
                                        </div>
                                    </td>
                                    <td align="right">
                                        <div style="width:85px" >
                                        <uc1:sortablecolumn id="hdrRemarkCategory" runat="server" columnidentifier="RemarkCategoryName"
                                            onsortclick="btnSort_Click" text="קטגוריה" tooltip="סינון לפי קטגוריה" />

                                        </div>
                                    </td>
                                </tr>
                                <tr id="trGridView">
                                    <td style="padding-right: 0px; padding-left: 0px;" colspan="4">
                                        <div id="divRemarksGrid" enableviewstate="false" runat="server" class="ScrollBarDiv" style="overflow-y: scroll; direction: ltr; width: 960px; height: 250px;">
                                            <%--border-bottom: solid 1px #CBCBCB--%>
                                            <div style="direction: rtl;">
                                                <asp:UpdatePanel runat="server" UpdateMode="Conditional" ID="UpdPanel1">
                                                    <ContentTemplate>

                                                        <asp:GridView Width="940px" ID="dgRemarks" runat="server" AutoGenerateColumns="false" HorizontalAlign="Right"
                                                            OnRowDataBound="dgRemarks_RowDataBound" ShowFooter="false" ShowHeader="false"
                                                            SkinID="GridViewForSearchResults">
                                                            <Columns>
                                                                <asp:TemplateField ItemStyle-Width="700px">
                                                                    <ItemTemplate>
                                                                        <table>
                                                                            <tr><td>
                                                                                
                                                                        <asp:RadioButton ID="radioRemark" runat="server" CssClass="choiseField"
                                                                            EnableTheming="False" Text="radioButtonText" />
                                                                        <asp:HiddenField ID="hdnRemarkID" runat="server" />
                                                                        <asp:HiddenField ID="hdnRemarkFormatText" runat="server" />
                                                                        <asp:HiddenField ID="hdnEnableOverlappingHours" runat="server" Value='<%# Eval("EnableOverlappingHours") %>' />
                                                                        <asp:HiddenField ID="hdnEnableOverMidnightHours" runat="server" Value='<%# Eval("EnableOverMidnightHours") %>' />
                                                                           </td> </tr>
                                                                            <tr><td>
                                                                                <asp:Panel id="divRemarkText" HorizontalAlign="Right" runat="server" style="text-align:right">
                                                                                    </asp:Panel>
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField ControlStyle-Width="90px">
                                                                    <ItemTemplate>
                                                                        <asp:Label ID="lblShowForPreviousDays" runat="server" CssClass="choiseField" EnableTheming="False"
                                                                            Text="LShowForPreviousDays"></asp:Label>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField ControlStyle-Width="50px">
                                                                    <ItemTemplate>
                                                                        <asp:Label ID="lblOpenNow" runat="server" CssClass="choiseField" EnableTheming="False"
                                                                            Text=""></asp:Label>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField ControlStyle-Width="100px">
                                                                    <ItemTemplate>
                                                                        <asp:Label ID="lblCategory" runat="server" CssClass="choiseField" EnableTheming="False"
                                                                            Text="LCategory"></asp:Label>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                            </Columns>
                                                        </asp:GridView>
                                                    </ContentTemplate>
                                                    <Triggers>
                                                        <asp:AsyncPostBackTrigger ControlID="btnSearch" EventName="Click" />
                                                        <asp:AsyncPostBackTrigger ControlID="btnShowAll" EventName="Click" />
                                                    </Triggers>
                                                </asp:UpdatePanel>
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td id="BorderLeft2" style="border-left: solid 2px #909090;">
                            <div style="width: 6px;">
                            </div>
                        </td>
                    </tr>
                    <tr id="BorderBottom2" style="height: 10px">
                        <td style="background-position: bottom right; background-image: url('../Images/Applic/RBcornerGrey10.gif'); background-repeat: no-repeat;"></td>
                        <td style="background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x; background-position: bottom"></td>
                        <td style="background-image: url('../Images/Applic/LBcornerGrey10.gif'); background-repeat: no-repeat; background-position: bottom left"></td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td colspan="2">
                <div style="direction: rtl;">
                    <asp:UpdatePanel runat="server" UpdateMode="Conditional" ID="UpdatePanel2">
                        <ContentTemplate>
                            <table>
                                <tr>
                                    <td>
                                        <uc3:RemarkControl id="rcRemarkControl" runat="server" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:Button ID="btnBindRemark" Text="post back" runat="server" CausesValidation="false" CssClass="RegularUpdateButton" />
                                    </td>
                                </tr>
                            </table>
                            
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
            </td>
        </tr>
        <tr>
            <td colspan="2" style="padding-top: 2px;">
                <table id="Border3" border="0" cellpadding="0" cellspacing="0" style="width: 990px;">
                    <tr id="BorderTop3">
                        <td style="height: 8px; width: 8px; background-image: url('../Images/Applic/RTcornerGrey10.gif'); background-repeat: no-repeat; background-position: top right"></td>
                        <td style="background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x; background-position: top"></td>
                        <td style="background-image: url('../Images/Applic/LTcornerGrey10.gif'); background-repeat: no-repeat; background-position: top left; width: 8px;"></td>
                    </tr>
                    <tr>
                        <td style="border-right: solid 2px #909090;">
                            <div style="width: 6px;">
                            </div>
                        </td>
                        <td>
                            <table border="0" width="100%">
                                <tr>
                                    <td>
                                        <asp:Panel ID="pnlDeptsForEmployee" runat="server" Visible="false" Width="730px">
                                            <table>
                                                <tr>
                                                    <td colspan="2" style="padding-right: 5px; padding-bottom: 10px;">
                                                        <span class="LabelCaptionGreenBold_14">עריכת ההערה הנבחרת</span>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td style="width: 50px" valign="middle">
                                                        <asp:Label ID="lblDept" runat="server" CssClass="GridViewHeader" Text="יחידה:" EnableTheming="false">
                                                        </asp:Label>
                                                    </td>
                                                    <td valign="bottom" width="200px">
                                                        <uc1:multiddlselect id="ddlMDDepts" runat="server" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </asp:Panel>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <table>
                                            <tr>
                                                <td style="width: 550px; padding-right: 0px;">
                                                    <span class="GridViewHeader">הערה:</span>
                                                </td>
                                                <td style="width: 125px; padding-right: 10px;">
                                                    <span id="lblFromDate" runat="server" class="GridViewHeader">בתוקף מ:</span>
                                                </td>
                                                <td style="width: 130px">
                                                    <span id="lblTodate" runat="server" class="GridViewHeader">עד:</span>
                                                </td>
                                                <td>
                                                    <span id="lblActiveFrom" runat="server" class="GridViewHeader">יוצג החל מ:</span>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td>

                                        <table>
                                            <tr>
                                                <td id="tdRemark" class="ViewField1" dir="rtl" width="540px" rowspan="2">
                                                    <div id="divRemarks" style="border: solid 1px #cecbce; height: 65px; width: 540px; padding-right: 5px; padding-top: 8px">
                                                    </div>
                                                    <asp:TextBox runat="server" ID="txtRemarkText" EnableTheming="false" TextMode="MultiLine" Height="70px" Width="540px" CssClass="DisplayNone"></asp:TextBox>
                                                    <asp:TextBox ID="txtRemarkIsOfReachTextFormat" runat="server" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>
                                                </td>
                                                <td dir="ltr" style="vertical-align: top; padding-right: 10px;">
                                                    <ajaxtoolkit:MaskedEditExtender ID="DateFromExtender" runat="server" AcceptAMPM="false"
                                                        ClearMaskOnLostFocus="false" ErrorTooltipEnabled="True" Mask="99/99/9999" MaskType="Date"
                                                        MessageValidatorTip="true" OnFocusCssClass="MaskedEditFocus" OnInvalidCssClass="MaskedEditError"
                                                        TargetControlID="txtRemarkValidFrom">
                                                    </ajaxtoolkit:MaskedEditExtender>
                                                    <div style="width:8px; display:inline-block;">
                                                        <ajaxtoolkit:MaskedEditValidator ID="DateValidator" runat="server" ControlExtender="DateFromExtender"
                                                            ControlToValidate="txtRemarkValidFrom" Display="Dynamic" InvalidValueBlurredMessage="*"
                                                            InvalidValueMessage="התאריך אינו תקין" IsValidEmpty="True" Text="*">
                                                        </ajaxtoolkit:MaskedEditValidator>
                                                    </div>
                                                    <ajaxtoolkit:CalendarExtender ID="calendarFrom" runat="server" FirstDayOfWeek="Sunday"
                                                        Format="dd/MM/yyyy" OnClientDateSelectionChanged="checkDate" PopupButtonID="btnCalendarFrom"
                                                        PopupPosition="TopRight" TargetControlID="txtRemarkValidFrom">
                                                    </ajaxtoolkit:CalendarExtender>
                                                    <asp:ImageButton ID="btnCalendarFrom" runat="server" ImageUrl="~/Images/Applic/calendarIcon.png" />
                                                    <asp:TextBox ID="txtRemarkValidFrom" runat="server" Width="70px" onChange="SetActiveFrom();CheckDataToEnableControls();"></asp:TextBox>
                                                </td>
                                                <td dir="ltr" style="padding-right: 10px; vertical-align: top;">
                                                    <ajaxtoolkit:MaskedEditExtender ID="Maskededitextender1" runat="server" AcceptAMPM="false"
                                                        ErrorTooltipEnabled="True" Mask="99/99/9999" MaskType="Date" MessageValidatorTip="true"
                                                        OnFocusCssClass="MaskedEditFocus" OnInvalidCssClass="MaskedEditError" TargetControlID="txtRemarkValidTo">
                                                    </ajaxtoolkit:MaskedEditExtender>
                                                    <div style="width:8px; display:inline-block;">
                                                        <ajaxtoolkit:MaskedEditValidator ID="Maskededitvalidator1" runat="server" ControlExtender="DateFromExtender"
                                                            ControlToValidate="txtRemarkValidTo" Display="Dynamic" InvalidValueBlurredMessage="*"
                                                            InvalidValueMessage="התאריך אינו תקין" IsValidEmpty="True" Text="*">
                                                        </ajaxtoolkit:MaskedEditValidator>
                                                    </div>
                                                    <ajaxtoolkit:CalendarExtender ID="Calendarextender1" runat="server" FirstDayOfWeek="Sunday"
                                                        Format="dd/MM/yyyy" OnClientDateSelectionChanged="CheckValidDates" PopupButtonID="btnCalendarTo"
                                                        PopupPosition="TopRight" TargetControlID="txtRemarkValidTo" OnClientHiding="CalendarBlurDelayed" OnClientShown="CalendarShown">
                                                    </ajaxtoolkit:CalendarExtender>
                                                    <asp:CompareValidator ID="vldDatesRange" runat="server" ControlToCompare="txtRemarkValidTo"
                                                        ControlToValidate="txtRemarkValidFrom" Operator="LessThanEqual" Text="*" Type="Date"></asp:CompareValidator>
                                                    <asp:ImageButton ID="btnCalendarTo" runat="server" ImageUrl="~/Images/Applic/calendarIcon.png" CausesValidation="false" />
                                                    <asp:TextBox ID="txtRemarkValidTo" runat="server" Width="70px" onchange="CheckDataToEnableControls();"></asp:TextBox>
                                                    <asp:RequiredFieldValidator ID="vldRemarkValidTo" runat="server" ControlToValidate="txtRemarkValidTo" Text="*" ErrorMessage="חובה לבחור בתוקף עד"></asp:RequiredFieldValidator>
                                                </td>
                                                <td dir="ltr" style="padding-right: 10px; vertical-align: top;">
                                                    
                                                    <ajaxtoolkit:MaskedEditExtender ID="ActiveFromMaskedEditExtender" runat="server" AcceptAMPM="false"
                                                        ErrorTooltipEnabled="True" Mask="99/99/9999" MaskType="Date"
                                                        MessageValidatorTip="true" OnFocusCssClass="MaskedEditFocus" OnInvalidCssClass="MaskedEditError"
                                                        TargetControlID="txtRemarkActiveFrom">
                                                    </ajaxtoolkit:MaskedEditExtender>
                                                    <div style="width:8px; display:inline-block;">
                                                    <ajaxtoolkit:MaskedEditValidator ID="Maskededitvalidator2" runat="server" ControlExtender="ActiveFromMaskedEditExtender"
                                                        ControlToValidate="txtRemarkActiveFrom" Display="Dynamic" InvalidValueBlurredMessage="*"
                                                        InvalidValueMessage="התאריך אינו תקין" IsValidEmpty="True" Text="*" EnableClientScript="False"
                                                        ClearMaskOnLostFocus="true">
                                                    </ajaxtoolkit:MaskedEditValidator>
                                                    </div>
                                                    <ajaxtoolkit:CalendarExtender ID="calendarActiveFrom" runat="server" FirstDayOfWeek="Sunday"
                                                        Format="dd/MM/yyyy" OnClientDateSelectionChanged="checkDate" PopupButtonID="btnCalendarActiveFrom"
                                                        PopupPosition="TopRight" TargetControlID="txtRemarkActiveFrom">
                                                    </ajaxtoolkit:CalendarExtender>
                                                    <asp:ImageButton ID="btnCalendarActiveFrom" runat="server" ImageUrl="~/Images/Applic/calendarIcon.png" />
                                                    <asp:TextBox ID="txtShowForPreviousDaysForSelectedRemark" runat="server" Width="40px" CssClass="DisplayNone" EnableTheming="false" Enabled="False"></asp:TextBox>
                                                    <asp:TextBox ID="txtOpenNow" runat="server" Width="40px" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>
                                                    <asp:TextBox ID="txtRemarkActiveFrom" runat="server" Width="70px" onchange="CheckActiveFrom();"></asp:TextBox>

                                                </td>
                                            </tr>
                                            <tr>
                                                <td align="right" colspan="3" style="padding-left: 10px; padding-right: 10px; vertical-align: top;">
                                                    <asp:CheckBox ID="chkDisplayOnInternet" runat="server" EnableViewState="true" Checked="true" OnClick="Show_lblAlert();" />
                                                    <span id="lblShowInInternet" runat="server" class="GridViewHeader">באינטרנט?</span>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                </td>
                                                <td colspan="3" style="padding-right:20px; height:25px; vertical-align:central">
                                                    <div style="width:320px">
                                                    <span id="lblAlert" runat="server" style="display:none; width:320px; font-size:14px; height:25px; font-weight:bold; vertical-align:central;">כאשר ההערה בתוקף – לא יוצג "פתוח כעת" באינטרנט</span>
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:ValidationSummary ID="vldSummary" runat="server" Enabled="false" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td style="border-left: solid 2px #909090;">
                            <div style="width: 6px;">
                            </div>
                        </td>
                    </tr>
                    <tr id="BorderBottom3" style="height: 8px">
                        <td style="background-image: url('../Images/Applic/RBcornerGrey10.gif'); background-repeat: no-repeat; background-position: bottom right"></td>
                        <td style="background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x; background-position: bottom"></td>
                        <td style="background-image: url('../Images/Applic/LBcornerGrey10.gif'); background-repeat: no-repeat; background-position: bottom left"></td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td style="height: 5px;" colspan="2"></td>
        </tr>
        <tr style="height: 30px;" valign="middle">
            <td style="text-align: left; background-color: #298ae5; padding-right:5px;" colspan="2">
                <div style="width: 190px;">
                    <div class="button_RightCorner"></div>
                    <div class="button_CenterBackground">
                        <asp:Button ID="btnSave" runat="server" Height="19px" Width="60px" CssClass="RegularUpdateButton" OnClick="btnSave_Click"
                            Text="שמירה" OnClientClick="SetEligibleDateForActiveFrom(); setRemarkText(); showProgressBarGeneral(''); setTimeout(DisableSaveButtons, 100); " />
                        <asp:Button ID="btnSaveAndGoEdit" runat="server" Height="19px" Width="60px" CssClass="DisplayNone" OnClick="btnSaveAndGoEdit_Click"
                            Text="עדכון" OnClientClick="setRemarkText(); showProgressBarGeneral(''); setTimeout(DisableSaveButtons, 100); " />
                        <input id="btnSaveClientSide" runat="server" disabled="disabled" type="button" value="שמירה" class="RegularUpdateButton" onclick="setRemarkText(); CloseItselfAsModalWindow();" style="display: none; width: 60px;" />
                    </div>
                    <div class="button_LeftCorner"></div>

                    <div class="button_RightCorner" style="margin-right: 20px;"></div>
                    <div class="button_CenterBackground">

                        <input type="button" value="ביטול" onclick="cancel();" style="width: 60px; height: 19px;" class="RegularUpdateButton" />
                    </div>
                    <div class="button_LeftCorner"></div>
                </div>
            </td>

        </tr>
    </table>




    <asp:HiddenField ID="hfCurrRemarkFormatText" runat="server" />
    <asp:HiddenField ID="hfCurrGeneralRemarkID" runat="server" />
    <asp:HiddenField ID="txtFormatedRemark" runat="server" />
    <asp:HiddenField ID="txtHeaderOrEditMode" runat="server" />
    <asp:HiddenField ID="hfPrepareSelectedRemark" runat="server" />
    <script type="text/javascript">
        try {
            document.getElementById("<%=btnSave.ClientID %>").setAttribute("disabled", "disabled");
            document.getElementById("<%=btnCalendarActiveFrom.ClientID %>").setAttribute("disabled", "disabled");
            document.getElementById("<%=txtRemarkActiveFrom.ClientID %>").setAttribute("disabled", "disabled");
        }
        catch (e) { }

    </script>


    <uc2:RemarkClientHandler ID="RemarkClientHandler1" runat="server" />

    <script type="text/javascript">
        function SelectJQueryClose() {
            window.parent.$("#dialog-modal-select").dialog('close');
            return false;
        }
</script>
</asp:Content>
