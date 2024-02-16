<%@ Page Language="C#" AutoEventWireup="true" Inherits="Admin_UpdateStatus"
    Culture="he-IL" UICulture="he-IL" Codebehind="UpdateStatus.aspx.cs" %>
<%@ Reference Page="~/Admin/AdminPopupBasePage.aspx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <base target="_self" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="-1" />
    <link rel="STYLESHEET" href="../CSS/General/general.css" type="text/css" />
    <title>סטטוס</title>
</head>
<body>
    <script type="text/javascript">
        function SelectJQueryClose() {
            window.parent.$("#dialog-modal-select").dialog('close');
            return false;
        }
    </script>
    <script type="text/javascript" language="javascript">

        function OpenModal(url, args) {

            features = "dialogWidth:390px; dialogHeight:180px; scroll:no; status:no; help:no"
            return window.showModalDialog(url, args, features);
        }

        function DisplayStatusDisableRecommendMessage() {

            var args = new Object();
            args.YesButtonText = "שנה סטטוס";
            args.NoButtonText = "חזור לשינוי סטטוס";
            args.Message = "<font size='4'>לתשומת ליבך,</font><br/> ניתן לשנות את סטטוס היחידה ל-\"לא פעיל זמנית\" לתקופת ביניים ורק לאחר מכן להפוך ל-\"לא פעיל\".<br/> כך ניתן להציג מידע אודות סגירתה למשתמשים";

            if (OpenModal("PopupYesNo.aspx", args)) {
                return DisplayStatusDisableWarningMessage(true);
            }
            else {
                return false;
            }
        }

        function DisplayStatusDisableWarningMessage(isDeptMode) {

            var args = new Object();
            args.YesButtonText = "כן";
            args.NoButtonText = "לא";

            if (isDeptMode)
                args.Message = "<font size='4'>לתשומת ליבך,</font><br/> כאשר סטטוס היחידה ישתנה ללא פעיל, כל המידע אודותיה (נותני שירות, שעות קבלה, שירותים ופעילויות) יימחק. האם אתה בטוח שברצונך להמשיך?";
            else {
                if ('<%= ServiceCode %>' != "0") {
                    if ('<%= EmployeeID %>' != "0") {
                        args.Message = "<font size='4'>לתשומת ליבך,</font><br/> כאשר סטטוס השירות הניתן על ידי נותן השירות ביחידה ישתנה ללא פעיל, יימחקו שעות מתן השירות על ידי נותן השירות ביחידה. האם אתה בטוח שברצונך להמשיך?";
                    }
                    else {
                        args.Message = "<font size='4'>לתשומת ליבך,</font><br/> כאשר סטטוס השירות ביחידה ישתנה ללא פעיל, יימחקו שעות הקבלה שלו ביחידה. האם אתה בטוח שברצונך להמשיך?";
                    }
                }
                else {
                    // employee in dept mode
                    if ('<%= DeptCode %>' != "0") {
                        args.Message = "<font size='4'>לתשומת ליבך,</font><br/> כאשר סטטוס נותן השירות ביחידה ישתנה ללא פעיל, יימחקו שעות הקבלה שלו ביחידה. האם אתה בטוח שברצונך להמשיך?";
                    }
                    else {
                        // employee mode
                        args.Message = "<font size='4'>לתשומת ליבך,</font><br/> כאשר סטטוס נותן השירות ישתנה ללא פעיל, כל המידע אודותיו (יחידות מקושרות, שעות קבלה) יימחק. האם אתה בטוח שברצונך להמשיך?";
                    }
                }
            }
            return OpenModal("PopupYesNo.aspx", args);
        }

        function CheckDisableStatus() {

            deptMode = '<%= DeptCode %>' != "0" && '<%= EmployeeID %>' == "0" && '<%= ServiceCode %>' == "0";

            if ( '<%= CurrentStatusIsActive %>' == 'True') {

                var gvDeptStatus = document.getElementById("gvDeptStatus");
                var numOfRows = gvDeptStatus.rows.length;

                // first row is hidden header
                for (i = 1; i < gvDeptStatus.rows.length; i++) {
                    if (typeof (gvDeptStatus.rows[i].cells[1].firstChild.style) != 'undefined') {

                        var toDate = new Date();
                        var yesterday = new Date();
                        yesterday.setDate(yesterday.getDate() - 1);


                        if (gvDeptStatus.rows[i].cells[4].firstChild.value != "") {
                            toStr = gvDeptStatus.rows[i].cells[4].firstChild.value;
                            toArr = toStr.split('/');
                            toDate = new Date(toArr[1] + "/" + toArr[0] + "/" + toArr[2]);
                            toDate.setHours(23, 59, 0, 0);
                        }

                        // no expire date for period 
                        if (gvDeptStatus.rows[i].cells[4].firstChild.value == "" || toDate >= yesterday) {

                            if (gvDeptStatus.rows[i].cells[1].childNodes[2].selectedIndex == "1" && (i < numOfRows - 1) && deptMode) {

                                if (gvDeptStatus.rows[i + 1].cells[1].childNodes[2].selectedIndex == "0") {
                                    return DisplayStatusDisableRecommendMessage();
                                }
                            }
                            else {
                                if (gvDeptStatus.rows[i].cells[1].childNodes[2].selectedIndex == "0") {
                                    return DisplayStatusDisableWarningMessage(deptMode);
                                }
                            }
                        }
                    }
                }
            }

            return true;
        }

        function ShowDeptStatusHistory() {
            var tdDeptStatusHistory = document.getElementById('tdDeptStatusHistory');
            var btnShowDeptStatusHistory = document.getElementById('btnShowDeptStatusHistory');
            if (tdDeptStatusHistory.style.display == "none") {
                tdDeptStatusHistory.style.display = "inline";
                btnShowDeptStatusHistory.innerText = "הסתר היסטוריית סטטוסים";
            }
            else {
                tdDeptStatusHistory.style.display = "none";
                btnShowDeptStatusHistory.innerText = "הצג היסטוריית סטטוסים";
            }
        }


        function ValidatePeriods(currentTxtToDate) {
            var txtFromDateMinimum_ToAdd = document.getElementById('txtFromDateMinimum_ToAdd');
            var txtFromDate_ToAdd = document.getElementById("txtFromDate_ToAdd");
            var btnRunCalendarFrom_DeptStatus_ToAdd = document.getElementById("btnRunCalendarFrom_DeptStatus_ToAdd");
            var ddlStatus_ToAdd = document.getElementById("ddlStatus_ToAdd");

            var btnAddDeptStatusLB = document.getElementById("btnAddDeptStatusLB");
            var btnSaveDeptStatusLB = document.getElementById("btnSaveDeptStatusLB");

            var currentTxtToDateID = currentTxtToDate.id;
            var gvDeptStatus = document.getElementById("gvDeptStatus");

            var lblDeptStatusLB_ErrorMessage = document.getElementById("lblDeptStatusLB_ErrorMessage");
            var trDeptStatusLB_ErrorMessage = document.getElementById("trDeptStatusLB_ErrorMessage");

            var oInputs = new Array();
            var oSelects = new Array();
            var toDateValue = new Array();
            var fromDateValue = new Array();

            var toDateID = new Array();
            var fromDateID = new Array();
            var fromDateLableID = new Array();
            var calendButtonsID = new Array();

            var inputsCount = gvDeptStatus.getElementsByTagName("input").length;
            oInputs = gvDeptStatus.getElementsByTagName("input");
            oSelects = gvDeptStatus.getElementsByTagName("select");

            var index_txtFromDate = 0;
            var index_txtToDate = 0;
            var index_Calendar = 0;
            var currentTxtToDateIndex;

            var toDayDate = new Date();
            toDayDate.setHours(0);
            toDayDate.setMinutes(0);
            toDayDate.setSeconds(0);
            toDayDate.setMilliseconds(0);
            var tomorrowDate = addDays(toDayDate, 1);

            for (var i = 0; i < inputsCount; i++) {

                if (oInputs[i].type == 'text') {
                    if (oInputs[i].id.indexOf("_txtFromDate") > 0) {
                        fromDateValue[index_txtFromDate] = oInputs[i].value;
                        fromDateID[index_txtFromDate] = oInputs[i].id;

                        fromDateLableID[index_txtFromDate] = oInputs[i].id.replace("txtFromDate", "lblFromDate");

                        index_txtFromDate++;
                    }
                    if (oInputs[i].id.indexOf("_txtToDate") > 0) {
                        toDateValue[index_txtToDate] = oInputs[i].value;
                        toDateID[index_txtToDate] = oInputs[i].id;

                        if (currentTxtToDateID == oInputs[i].id) {
                            currentTxtToDateIndex = index_txtToDate;
                        }

                        index_txtToDate++;
                    }

                }

            }

            var newToDate = getDateObject(toDateValue[currentTxtToDateIndex], "/");

            //alert(newToDate.toDateString("dd/MM/yyyy"));
            var currFromDate = getDateObject(fromDateValue[currentTxtToDateIndex], "/");
            var nextToDate;
            if (toDateValue[currentTxtToDateIndex + 1] == '')
                nextToDate = getDateObject("01/01/2050", "/");
            else
                nextToDate = getDateObject(toDateValue[currentTxtToDateIndex + 1], "/");

            //var minToDate = addDays(currFromDate, 1);
            var minToDate = currFromDate;
            var maxToDate = addDays(nextToDate, -2);

            var newToDatePlus = addDays(newToDate, 1);

            if ((newToDate >= minToDate) && (newToDate <= maxToDate) && (newToDate >= tomorrowDate)) {//OK

                var txtNextFromDate = document.getElementById(fromDateID[currentTxtToDateIndex + 1]);
                var lblNextFromdate = document.getElementById(fromDateLableID[currentTxtToDateIndex + 1]);

                lblNextFromdate.innerHTML = newToDatePlus.format("dd/MM/yyyy");
                txtNextFromDate.value = newToDatePlus.format("dd/MM/yyyy");

                for (var i = 0; i < oInputs.length; i++) {
                    oInputs[i].disabled = false;
                }
                for (var i = 0; i < oSelects.length; i++) {
                    oSelects[i].disabled = false;
                }

                btnAddDeptStatusLB.disabled = false;
                btnSaveDeptStatusLB.disabled = false;
                txtFromDate_ToAdd.disabled = false;
                btnRunCalendarFrom_DeptStatus_ToAdd.disabled = false;
                ddlStatus_ToAdd.disabled = false;

                var lastTxtFromDate = document.getElementById(fromDateID[fromDateID.length - 1]);

                var biggestFromDate = getDateObject(lastTxtFromDate.value, "/");
                //var fromDateMinimum_ToAdd = addDays(biggestFromDate, 1);
                var fromDateMinimum_ToAdd = biggestFromDate;

                txtFromDateMinimum_ToAdd.value = fromDateMinimum_ToAdd.format("dd/MM/yyyy");

                lblDeptStatusLB_ErrorMessage.innerHTML = "";
                trDeptStatusLB_ErrorMessage.style.display = "none";

            }
            else {

                for (var i = 0; i < oInputs.length; i++) {
                    oInputs[i].disabled = true;
                }
                for (var i = 0; i < oSelects.length; i++) {
                    oSelects[i].disabled = true;
                }

                btnRunCalendarFrom_DeptStatus_ToAdd.disabled = true;

                var currTxtToDate = document.getElementById(toDateID[currentTxtToDateIndex]);
                currTxtToDate.disabled = false;

                var currCalToDate = document.getElementById(toDateID[currentTxtToDateIndex].replace("_txtToDate", "_btnRunCalendarTo_DeptStatus"));
                currCalToDate.disabled = false;

                btnAddDeptStatusLB.disabled = true;
                btnSaveDeptStatusLB.disabled = true;
                txtFromDate_ToAdd.disabled = true;
                ddlStatus_ToAdd.disabled = true;

                lblDeptStatusLB_ErrorMessage.innerHTML = "* תאריך הסגירה חייב להיות עתידי, גדול מתאריך הפתיחה, וקטן לפחות ביומיים מתאריך הסגירה הבא";
                trDeptStatusLB_ErrorMessage.style.display = "inline";
            }
        }



        function ValidatePeriodAdd() {
            checkDate(null, null);

            var btnAddDeptStatusLB = document.getElementById("btnAddDeptStatusLB");
            var btnSaveDeptStatusLB = document.getElementById("btnSaveDeptStatusLB");
            var btnCancelDeptStatusLB = document.getElementById("btnCancelDeptStatusLB");
            var btnRunCalendarFrom_DeptStatus_ToAdd = document.getElementById("btnRunCalendarFrom_DeptStatus_ToAdd");
            var txtFromDate_ToAdd = document.getElementById("txtFromDate_ToAdd");
            var txtFromDateMinimum_ToAdd = document.getElementById('txtFromDateMinimum_ToAdd');
            var gvDeptStatus = document.getElementById("gvDeptStatus");

            var lblDeptStatusLB_ErrorMessage = document.getElementById("lblDeptStatusLB_ErrorMessage");
            var trDeptStatusLB_ErrorMessage = document.getElementById("trDeptStatusLB_ErrorMessage");

            var toDateID = new Array();
            var oInputs = new Array();
            var oSelects = new Array();
            var index_txtToDate = 0;

            if (gvDeptStatus != null) {

                var inputsCount = gvDeptStatus.getElementsByTagName("input").length;
                oInputs = gvDeptStatus.getElementsByTagName("input");
                oSelects = gvDeptStatus.getElementsByTagName("select");

                var toDayDate = new Date();
                toDayDate.setHours(0);
                toDayDate.setMinutes(0);
                toDayDate.setSeconds(0);
                toDayDate.setMilliseconds(0);

                var tomorrowDate = addDays(toDayDate, 1);

                for (var i = 0; i < inputsCount; i++) {

                    if (oInputs[i].type == 'text') {
                        if (oInputs[i].id.indexOf("_txtToDate") > 0) {
                            toDateID[index_txtToDate] = oInputs[i].id;

                            index_txtToDate++;
                        }
                    }

                }
            }

            var fromDate_ToAdd = getDateObject(txtFromDate_ToAdd.value, "/");
            var fromDateMinimum_ToAdd = getDateObject(txtFromDateMinimum_ToAdd.value, "/");

            if (fromDate_ToAdd >= fromDateMinimum_ToAdd) {// OK

                for (var i = 0; i < oInputs.length; i++) {
                    oInputs[i].disabled = false;
                }
                for (var i = 0; i < oSelects.length; i++) {
                    oSelects[i].disabled = false;
                }

                btnAddDeptStatusLB.disabled = false;

                btnSaveDeptStatusLB.disabled = false;
                btnSaveDeptStatusLB.style.cursor = "hand";

                lblDeptStatusLB_ErrorMessage.innerHTML = "";
                trDeptStatusLB_ErrorMessage.style.display = "none";
            }
            else {// wrong

                for (var i = 0; i < oInputs.length; i++) {
                    oInputs[i].disabled = true;
                }

                for (var i = 0; i < oSelects.length; i++) {
                    oSelects[i].disabled = true;
                }

                //            btnCancelDeptStatusLB.disabled = false;
                txtFromDate_ToAdd.disabled = false;
                btnRunCalendarFrom_DeptStatus_ToAdd.disabled = false;
                btnSaveDeptStatusLB.disabled = true;
                btnSaveDeptStatusLB.style.cursor = "default";

                btnAddDeptStatusLB.disabled = true;

                lblDeptStatusLB_ErrorMessage.innerHTML = "* תאריך חדש לא יכול להיות בעבר, וחייב להיות גדול מתאריך התחלת הסטטוס האחרון";
                trDeptStatusLB_ErrorMessage.style.display = "inline";


            }


        }

        function getDateObject(dateString, dateSeperator) {
            //This function return a date object after accepting 
            //a date string ans dateseparator as arguments
            var curValue = dateString;
            var sepChar = dateSeperator;
            var curPos = 0;
            var cDate, cMonth, cYear;

            //extract day portion
            curPos = dateString.indexOf(sepChar);
            cDate = dateString.substring(0, curPos);

            //extract month portion
            endPos = dateString.indexOf(sepChar, curPos + 1);
            cMonth = dateString.substring(curPos + 1, endPos);

            //extract year portion 
            curPos = endPos;
            endPos = curPos + 5;
            cYear = curValue.substring(curPos + 1, endPos);

            cMonth = parseInt(cMonth, 10) - 1;
            cMonth = cMonth.toString();
            if (cMonth.length == 1)
                cMonth = '0' + cMonth;

            //Create Date Object
            dtObject = new Date(cYear, cMonth, cDate);
            return dtObject;
        }

        function addDays(myDate, days) {
            return new Date(myDate.getTime() + days * 24 * 60 * 60 * 1000);
        }

        function checkDate(sender, args) {
            var from = document.getElementById('txtFromDate_ToAdd').value;

            var selectedDate = from.split('/');

            if (selectedDate[0].charAt(0) == "0" && selectedDate[0].length > 1)
                selectedDate[0] = selectedDate[0].substring(1)

            if (selectedDate[1].charAt(0) == "0" && selectedDate[1].length > 1)
                selectedDate[1] = selectedDate[1].substring(1)

            receptionDateFrom = new Date();
            receptionDateFrom.setUTCFullYear(parseInt(selectedDate[2]));
            receptionDateFrom.setUTCMonth(parseInt(selectedDate[1]) - 1);
            receptionDateFrom.setUTCDate(parseInt(selectedDate[0]));

            var currentDate = new Date();


            if (receptionDateFrom < currentDate) {
                //alert("לא ניתן לבחור תאריך קטן מתאריך נוכחי");

                // set the date back to the current date

                document.getElementById('txtFromDate_ToAdd').value = currentDate.format("dd/MM/yyyy");
            }
        }

        function SaveAndGo() {
            var obj = new Object();
            obj.SaveData = true;
            window.returnValue = obj;
            self.close();
        }
        function JustGo() {
            var obj = new Object();
            obj.SaveData = false;
            window.returnValue = obj;
            self.close();
        }

    </script>

    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnableScriptGlobalization="true"
        EnableScriptLocalization="true" />
    <div style="width: 100%; height: 100%; direction: rtl;">
        <table cellpadding="0" width="100%" cellspacing="0" style="background-color: White;
            border-top: solid 1px #555555; vertical-align: top">
            <tr>
                <td align="right" style="background-color: #298AE5; padding-right: 3px">
                    <asp:Label ID="lblDeptStatusLBHeader" EnableTheming="false" CssClass="LabelBoldWhite_18"
                        runat="server" Text="סטטוס"></asp:Label>
                    <asp:TextBox ID="txtFunctionToExecute" runat="server" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>
                </td>
            </tr>
            <tr>
                <td>
                    <div style="height: 180px; overflow: auto; direction: rtl; text-align: right" class="ScrollBarDiv">
                        <table dir="rtl">
                            <tr>
                                <td align="right" style="padding-right: 10px; padding-top: 10px; padding-bottom: 10px">
                                    <asp:LinkButton ID="btnShowDeptStatusHistory" EnableTheming="false" CssClass="LooksLikeHRef"
                                        runat="server" OnClientClick="ShowDeptStatusHistory(); return false;" Text="הצג היסטוריית סטטוסים"></asp:LinkButton>
                                </td>
                            </tr>
                            <tr>
                                <td align="right" style="padding-right: 12px; display: none" id="tdDeptStatusHistory"
                                    runat="server">
                                    <asp:GridView ID="gvDeptStatusHistory" SkinID="SimpleGridViewNoEmtyDataText" runat="server"
                                        AutoGenerateColumns="false" HeaderStyle-CssClass="DisplayNone" OnRowDataBound="gvDeptStatusHistory_RowDataBound">
                                        <Columns>
                                            <asp:TemplateField ItemStyle-Width="100px">
                                                <ItemTemplate>
                                                    <table cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td>
                                                                <asp:Label ID="lblStatus" Width="120px" EnableTheming="false" CssClass="RegularLabelNormal_13"
                                                                    runat="server" Text='<%#Eval("statusDescription") %>'></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:Label ID="lblFrom" runat="server" Width="15px" EnableTheming="false" CssClass="RegularLabelNormal_13"
                                                                    Text="מ:"></asp:Label>
                                                            </td>
                                                            <td style="width: 110px">
                                                                <asp:Label ID="lblFromDate" Width="95px" EnableTheming="false" CssClass="RegularLabelNormal_13"
                                                                    runat="server" Text='<%#Eval("FromDate","{0:d}") %>'></asp:Label>
                                                            </td>
                                                            <td style="width: 20px">
                                                                <asp:Label ID="lblTo" runat="server" Width="20px" EnableTheming="false" CssClass="RegularLabelNormal_13"
                                                                    Text="עד:"></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:Label ID="lblToDate" Width="80px" EnableTheming="false" CssClass="RegularLabelNormal_13"
                                                                    runat="server" Text='<%#Eval("ToDate","{0:d}") %>'></asp:Label>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                </td>
                            </tr>
                            <tr>
                                <td align="right" style="padding-right: 10px">
                                    <asp:GridView ID="gvDeptStatus" SkinID="SimpleGridViewNoEmtyDataText" runat="server"
                                        AutoGenerateColumns="false" HeaderStyle-CssClass="DisplayNone" OnRowDeleting="gvDeptStatus_RowDeleting"
                                        OnRowDataBound="gvDeptStatus_RowDataBound">
                                        <Columns>
                                            <asp:TemplateField>
                                                <ItemTemplate>
                                                    <asp:TextBox ID="txtStatus" runat="server" Text='<%#Eval("Status") %>' EnableTheming="false"
                                                        CssClass="DisplayNone"></asp:TextBox>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField>
                                                <ItemStyle Width="120px" />
                                                <ItemTemplate>
                                                    <asp:Label ID="lblStatus" EnableTheming="false" CssClass="RegularLabelNormal" Width="100px"
                                                        runat="server" Text='<%#Eval("statusDescription") %>'></asp:Label>
                                                    <asp:DropDownList ID="ddlStatus" DataTextField="statusDescription" DataValueField="status"
                                                        Width="100px" runat="server" EnableTheming="false" CssClass="DisplayNone" AutoPostBack="true"
                                                        OnSelectedIndexChanged="ddlStatus_SelectedIndexChanged">
                                                    </asp:DropDownList>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField ItemStyle-HorizontalAlign="Right">
                                                <ItemTemplate>
                                                    <table cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td>
                                                                <asp:Label ID="lblFrom" runat="server" Width="15px" EnableTheming="false" CssClass="RegularLabelNormal_13"
                                                                    Text="מ:"></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:TextBox ID="txtFromDate" Width="80px" runat="server" Text='<%#Eval("FromDate","{0:d}") %>'></asp:TextBox>
                                                                <asp:Label ID="lblFromDate" Width="80px" EnableTheming="false" CssClass="RegularLabelNormal_13"
                                                                    runat="server" Text='<%#Eval("FromDate","{0:d}") %>'></asp:Label>
                                                            </td>
                                                            <td style="width: 30px">
                                                            </td>
                                                            <td>
                                                                <asp:Label ID="lblTo" runat="server" Width="20px" EnableTheming="false" CssClass="RegularLabelNormal_13"
                                                                    Text="עד:"></asp:Label>
                                                            </td>
                                                            <td style="direction:ltr;width:120px;">
                                                                <ajaxToolkit:MaskedEditValidator ID="txtToDate_DeptStatus_Validator" runat="server"
                                                                    ControlExtender="txtToDate_DeptStatus_Extender" ControlToValidate="txtToDate"
                                                                    IsValidEmpty="True" InvalidValueMessage="תאריך אינו תקין" Display="Dynamic" InvalidValueBlurredMessage="*&nbsp;&nbsp;"
                                                                    ValidationGroup="vldGrSearch" />
                                                                <asp:ImageButton ImageUrl="~/Images/Applic/calendarIcon.png" ID="btnRunCalendarTo_DeptStatus"
                                                                    runat="server" />
                                                                <asp:TextBox ID="txtToDate" name="txtToDate" Width="70px" runat="server" Text='<%#Eval("ToDate","{0:d}") %>'
                                                                    onchange="ValidatePeriods(this);"></asp:TextBox>
                                                                <asp:Label ID="lblToDate" Width="80px" runat="server" EnableTheming="false" CssClass="RegularLabelNormal_13"
                                                                    Text='...'></asp:Label>
                                                                <ajaxToolkit:CalendarExtender ID="calExtToDate_DeptStatus" runat="server" Format="dd/MM/yyyy"
                                                                    FirstDayOfWeek="Sunday" TargetControlID="txtToDate" PopupPosition="BottomRight"
                                                                    PopupButtonID="btnRunCalendarTo_DeptStatus">
                                                                </ajaxToolkit:CalendarExtender>
                                                                <ajaxToolkit:MaskedEditExtender ID="txtToDate_DeptStatus_Extender" runat="server"
                                                                    AcceptAMPM="false" ErrorTooltipEnabled="True" Mask="99/99/9999" MaskType="Date"
                                                                    MessageValidatorTip="true" OnFocusCssClass="MaskedEditFocus" OnInvalidCssClass="MaskedEditError"
                                                                    TargetControlID="txtToDate">
                                                                </ajaxToolkit:MaskedEditExtender>
                                                                
                                                            </td>
                                                            
                                                        </tr>
                                                    </table>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField>
                                                <ItemTemplate>
                                                    <asp:ImageButton ID="btnDelete" runat="server" ImageUrl="~/Images/Applic/btn_X_red.gif"
                                                        CommandName="Delete" />
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField>
                                                <ItemTemplate>
                                                    <asp:HiddenField ID="hdnToDate" runat="server" Value='<%#Eval("ToDate","{0:d}") %>' />
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField>
                                                <ItemTemplate>
                                                    <asp:Label ID="lblPeriodError" runat="server" Text="*" CssClass="LabelBoldRed_13"
                                                        EnableTheming="false" Style="display: none"></asp:Label>
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
            <tr>
                <td align="center" style="padding-top:3px">
                    <table cellpadding="0" cellspacing="0" width="420px" border="0" style="background-color: #F7F7F7">
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
                                &nbsp;
                            </td>
                            <td align="right">
                                <table>
                                    <tr>
                                        <td colspan="4" style="padding-right: 14px">
                                            <asp:Label ID="lblAdd" runat="server" EnableTheming="false" CssClass="LabelCaptionGreenBold_12">הוספת סטטוס:</asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="padding-top: 2px; width: 120px; padding-right: 14px">
                                            <asp:DropDownList ID="ddlStatus_ToAdd" DataTextField="statusDescription" DataValueField="status"
                                                Width="100px" runat="server">
                                            </asp:DropDownList>
                                        </td>
                                        <td style="padding-top: 0px">
                                            <asp:Label ID="lblFrom" runat="server" EnableTheming="false" CssClass="RegularLabelNormal_13"
                                                Text="מ:"></asp:Label>
                                        </td>
                                        <td style="direction:ltr;width:110px;">
                                            <ajaxToolkit:MaskedEditValidator ID="txtFromDate_ToAdd_DeptStatus_Validator" runat="server"
                                                ControlExtender="txtFromDate_ToAdd_DeptStatus_Extender" ControlToValidate="txtFromDate_ToAdd"
                                                IsValidEmpty="false" InvalidValueMessage="תאריך אינו תקין" Display="Dynamic"
                                                InvalidValueBlurredMessage="*&nbsp;&nbsp;" EmptyValueMessage="*&nbsp;&nbsp;" ValidationGroup="vldGrAddStatus" />
                                            <asp:ImageButton ImageAlign="Middle" ImageUrl="~/Images/Applic/calendarIcon.png"
                                                ID="btnRunCalendarFrom_DeptStatus_ToAdd" runat="server" />
                                            <asp:TextBox ID="txtFromDate_ToAdd" Width="70px" runat="server" onchange="ValidatePeriodAdd();"></asp:TextBox>
                                            <ajaxToolkit:CalendarExtender ID="calExtFromDate_DeptStatus_ToAdd" runat="server"
                                                Format="dd/MM/yyyy" FirstDayOfWeek="Sunday" TargetControlID="txtFromDate_ToAdd"
                                                PopupPosition="TopLeft" PopupButtonID="btnRunCalendarFrom_DeptStatus_ToAdd" >
                                            </ajaxToolkit:CalendarExtender>
                                            <ajaxToolkit:MaskedEditExtender ID="txtFromDate_ToAdd_DeptStatus_Extender" runat="server"
                                                AcceptAMPM="false" ErrorTooltipEnabled="True" Mask="99/99/9999" MaskType="Date"
                                                MessageValidatorTip="true" OnFocusCssClass="MaskedEditFocus" OnInvalidCssClass="MaskedEditError"
                                                TargetControlID="txtFromDate_ToAdd">
                                            </ajaxToolkit:MaskedEditExtender>
                                            <asp:TextBox ID="txtFromDateMinimum_ToAdd" runat="server" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>
                                            
                                            
                                        </td>
                                        <td align="right">
                                            <table cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                        background-position: bottom left;">
                                                        &nbsp;
                                                    </td>
                                                    <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                        background-repeat: repeat-x; background-position: bottom;">
                                                        <asp:Button ID="btnAddDeptStatusLB" runat="server" OnClick="btnAddDeptStatusLB_Click"
                                                            Text="הוספה" CssClass="RegularUpdateButton" ValidationGroup="vldGrAddStatus">
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
                            <td style="border-left: solid 2px #909090;">
                                &nbsp;
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
                </td>
            </tr>
            <tr id="trDeptStatusLB_ErrorMessage" runat="server" style="display: none">
                <td style="padding-right: 14px; padding-top:5px" align="right">
                    <asp:Label ID="lblDeptStatusLB_ErrorMessage" runat="server" EnableTheming="false"
                        CssClass="LabelBoldRed_13"></asp:Label>
                </td>
            </tr>
            <tr>
                <td>
                    <asp:Label ID="lblFutureStatusWarning" runat="server" Visible="false" EnableTheming="false"
                        CssClass="LabelBoldRed_13"></asp:Label>
                </td>
            </tr>
        </table>
        
        <div style="left:20px;bottom:10px;text-align:left;position:absolute">
            <table cellpadding="0" cellspacing="0">
                <tr>
                    <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                        background-position: bottom left;">
                        &nbsp;&nbsp;
                    </td>
                    <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                        background-repeat: repeat-x; background-position: bottom;">
                        <asp:Button ID="btnSaveDeptStatusLB" runat="server" OnClick="btnSaveDeptStatus_Click"
                            Text="שמירה" CssClass="RegularUpdateButton" OnClientClick="return CheckDisableStatus();">
                        </asp:Button>
                    </td>
                    <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                        background-repeat: no-repeat;">
                        &nbsp;
                    </td> 
                    <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                        background-position: bottom left;padding-right:4px">
                        &nbsp;
                    </td>
                    <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                        background-repeat: repeat-x; background-position: bottom;">
                        <asp:Button ID="btnCancelDeptStatusLB" runat="server" OnClick="btnCancelDeptStatus_Click"
                            OnClientClick="return SelectJQueryClose();"
                            Text="ביטול" CssClass="RegularUpdateButton"></asp:Button>
                    </td>
                    <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                        background-repeat: no-repeat;">
                        &nbsp;
                    </td>
                </tr>
            </table>
        </div>
    </div>
    </form>

</body>
</html>
