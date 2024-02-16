<%@ Control Language="C#" AutoEventWireup="true"
    Inherits="UserControls_GridDeptReceptionHoursUC" Codebehind="GridDeptReceptionHoursUC.ascx.cs" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagPrefix="MultiDDlSelect_UC" TagName="MultiDDlSelect_UCItem" Src="~/UserControls/MultiDDlSelectUC.ascx" %>
<link href="../CSS/General/general.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="../Scripts/Applic/General.js"></script>
<script type="text/javascript" src="../Scripts/BrowserVersions.js"></script>
<script type="text/javascript">

    // large GridView has low performance if it is in Update panel
    //this  is solution
    var hfUpdateFlagClientID = "<%=hfUpdateFlag.ClientID %>";
    var pageRequestManager = Sys.WebForms.PageRequestManager.getInstance();
    pageRequestManager.add_pageLoading(onPageLoading);

    function onPageLoading(sender, e) {
        var gv = $get("dgReceptionHours");
        if (gv != null)
            gv.parentNode.removeNode(gv);
    }
        
    function onfocusoutFromDate(txtName) {

        var txtFromDate = document.getElementById(txtName);

        //txtFromDate.value = Date().getDay() + '/' + new Date().getMonth() + '/' + new Date().getFullYear();

        if (txtFromDate.value == '__/__/____')
            txtFromDate.value = '<%=DateTime.Today.ToShortDateString() %>';

    }

    function isValidTime(myTime) {
        var splitTime = myTime.split(":");
        var res = true;
        var hour = parseInt(splitTime[0]);
        var minutes = parseInt(splitTime[1]);

        if (hour > 23) {
            res = false;
        }
                    
        if (minutes > 59) {
            res = false;
        }
        
        return res;
    }

    function validateHours(val, args) {
        //alert("validateHours");
        if (event.srcElement.type != "image") {
            if (event.srcElement.id.indexOf("From") > -1) {
                args.IsValid = isValidTime(event.srcElement.value);
            }
            else {
                if (isValidTime(event.srcElement.value)) {
                    checkIfFromIsNotBigger(args);
                }
                else {
                    args.IsValid = false;
                }


            }
        }
        else {
   
            var tmpSplit = event.srcElement.id.split("_");
            var tmpLength = event.srcElement.id.split("_").length;

            var reg = /\d+/;
            var rowIndex = parseInt(tmpSplit[tmpLength - 2].match(reg));

            
            /* Because the validation event is set to 2 textboxes it happans twice,
               So at the second time there is no need to check again. */
            
            if (overLapCheckCounters % 2 != 0) {
                checkIfOverlapHours(rowIndex);
                
            }
            overLapCheckCounters++;
            args.IsValid = overLapValid;

            if (args.IsValid == true)
                selectedEnableOverlappingHours = "";
        }
    }

    function checkIfFromIsNotBigger(args) {

        var flag = "";
        //var txtFromHourClientID = document.getElementsByName('<%=this.hdnHeaderFromHourClientID.ClientID %>')[0].value;
        var txtFromHourClientID = document.getElementById('<%=this.hdnHeaderFromHourClientID.ClientID %>').value;

        var openingTime = document.getElementById(txtFromHourClientID).value;
        var openingTimeArr = openingTime.split(':');
       
        var FromHour = openingTimeArr[0];
        var FromMinute = openingTimeArr[1];

        var txtToHourClientID = document.getElementById('<%=this.hdnHeaderToHourClientID.ClientID %>').value;
        var closingTime = document.getElementById(txtToHourClientID).value;

        var closingTimeArr = closingTime.split(':');
        var ToHour = closingTimeArr[0];

        if (ToHour == "00")
            ToHour = "24";

        var hdnEnableOverMidnightHours = document.getElementById('<%=this.hdnEnableOverMidnightHours.ClientID %>');
        if (hdnEnableOverMidnightHours != null) {
            var enableOverMidnightHours = hdnEnableOverMidnightHours.value;

            if (enableOverMidnightHours == "True") {
                FromHour = "00";
                ToHour = "24";
                flag = "1";
            }
        }

        var ToMinute = closingTimeArr[1];

        var FromHourInt = parseInt(FromHour, 10);
        var ToHourInt = parseInt(ToHour, 10);

        var FromMinuteInt = parseInt(FromMinute, 10);
        var ToMinuteInt = parseInt(ToMinute, 10);

        var receptionDateFrom = new Date();

        receptionDateFrom.setHours(FromHourInt, FromMinute, 0, 0);

        var receptionDateTo = new Date();
        receptionDateTo.setHours(ToHourInt, ToMinute, 0, 0);

        var latestPermittedTomorrowDate = new Date();
        latestPermittedTomorrowDate.setHours(4, 0, 0, 0);  //time less then "04:00" is considered to be "over midnight hour"

        if (receptionDateFrom < receptionDateTo || receptionDateTo <= latestPermittedTomorrowDate || flag == "1") {
            //alert(receptionDateFrom);
            //alert(receptionDateTo);

            //alert(latestPermittedTomorrowDate);
            //alert(flag);

            args.IsValid = true;
        }
        else {
            //alert("Not Valid")
            args.IsValid = false;
        }

    }

    var selectedEnableOverlappingHours = "";

    function OpenRemarkWindowDialog(remarkType, mode) {
        var dialogWidth = 1040;
        var dialogHeight = 720;
        var title = "בחר הערה";

        var inpTitleRemark = null;
        var url = "";

        document.getElementById('<%=txtWherePutRemark.ClientID %>').value = mode;

        if (mode == 'header') {
            var hdnRemarkID = document.getElementById('<%=this.HdnRemarkID %>');
            var hdnRemarkMask = document.getElementById('<%=this.HdnRemarkMask %>');

            url = "../Admin/AddRemark.aspx?RemarkType=" + remarkType
                + "&RemarkID=" + hdnRemarkID.value
                + "&RemarkText=" + escape(hdnRemarkMask.value) 
                +"&title=1";
            url += "&mode=header";
        }
        else if (mode == 'edit') {
            var remarkNum = document.getElementById('<%= hdnRemarkID_E.ClientID %>');
            var remarkMask = document.getElementById('<%= hdnRemarkMask_E.ClientID %>');

            if (remarkNum != null) {
                url = "../Admin/AddRemark.aspx?RemarkType=" + remarkType
                + "&RemarkID=" + remarkNum.value
                + "&RemarkText=" + escape(remarkMask.value) 
                + "&title=1";
                url += "&mode=edit";
            }
        }

        OpenJQueryDialog(url, dialogWidth, dialogHeight, title);
        return false;
        
    }

    function SetRemark() {

        var headerOrEditMode = document.getElementById('<%=txtWherePutRemark.ClientID %>').value;

        var inpTitleRemark = document.getElementById('inpTitleRemark');
        var SelectedRemark = "0";
        var SelectedRemarkMask = "0";

        if (headerOrEditMode == 'header') {
            inpTitleRemark = document.getElementById('inpTitleRemark');

            var hdnRemarkText = document.getElementById('<%=this.HdnRemarkText %>');
            SelectedRemark = document.getElementById("<%=txtSelectedRemark_FromDialog.ClientID %>").value;
            //alert(SelectedRemark);
            hdnRemarkText.value = SelectedRemark;

            var hdnRemarkMask = document.getElementById('<%=this.HdnRemarkMask %>');
            SelectedRemarkMask = document.getElementById('<%=txtSelectedRemarkMask_FromDialog.ClientID %>').value;
            //alert(SelectedRemark + " " + SelectedRemarkMask);
            hdnRemarkMask.value = SelectedRemarkMask;

           var hdnRemarkID = document.getElementById('<%=this.HdnRemarkID %>');
            hdnRemarkID.value = document.getElementById('<%=txtSelectedRemarkID_FromDialog.ClientID %>').value;
        }
        else if (headerOrEditMode == 'edit') {

            var hdnRemarkText = document.getElementById('<%=this.HdnRemarkText_E %>');
            SelectedRemark = document.getElementById("<%=txtSelectedRemark_FromDialog.ClientID %>").value;
            hdnRemarkText.value = SelectedRemark;

            var hdnRemarkMask = document.getElementById('<%=this.HdnRemarkMask_E %>');
            SelectedRemarkMask = document.getElementById('<%=txtSelectedRemarkMask_FromDialog.ClientID %>').value;

            hdnRemarkMask.value = SelectedRemarkMask;

            var hdnRemarkID = document.getElementById('<%=this.HdnRemarkID_E %>');
            hdnRemarkID.value = document.getElementById('<%=txtSelectedRemarkID_FromDialog.ClientID %>').value;

            //var lblRemarkMask_E_c = document.getElementsByName('lblRemarkMask_E_c');
            var lblRemarkMask_E_c = document.getElementsByName('lblRemarkMask_E_c_name');
            var lblRemarkMask_E = document.getElementsByName('lblRemarkMask_E');
            //var lblRemarkID_E = document.getElementsByName('lblRemarkID_E');
            var lblRemarkID_E = document.getElementsByName('lblRemarkID_E_name');

            
            //lblRemarkMask_E_c[0].value = selectedRemarkMask;
            //lblRemarkID_E[0].value = selectedRemarkID;

            //alert("edit" + SelectedRemark + " " + SelectedRemarkMask);

            //inpTitleRemark = document.getElementById('lblRemarkText_E');
            inpTitleRemark = $("input:text[id*=lblRemarkText_E]").get(0);

            //Within the included web resource and the WebUIValidation.js is a method we need to call, 
            //the Page_ClientValidate , which is a method that is used to test if all controls meet
            //the validation criteria that have been assigned to them.
            //Page_ClientValidate('vldGrEdit');
        }

        if (inpTitleRemark != null) {
            inpTitleRemark.value = SelectedRemark;
        }

    }

    function DeleteRemark(){
        var hdnRemarkText = document.getElementById('<%=this.HdnRemarkText_E %>');
        hdnRemarkText.value = "";

        var hdnRemarkMask = document.getElementById('<%=this.HdnRemarkMask_E %>');
            hdnRemarkMask.value = "";

            var hdnRemarkID = document.getElementById('<%=this.HdnRemarkID_E %>');
            hdnRemarkID.value = "";

            inpTitleRemark = $("input:text[id*=lblRemarkText_E]").get(0);
            if (inpTitleRemark != null)
                inpTitleRemark.value = "";
    }

    function clearRemark() {

        var inpTitleRemark = document.getElementById('inpTitleRemark');

        var hdnRemarkText = document.getElementById('<%=this.HdnRemarkText %>');
        hdnRemarkText.value = "";

        var hdnRemarkMask = document.getElementById('<%=this.HdnRemarkMask %>');
        hdnRemarkMask.value = "";

        var hdnRemarkID = document.getElementById('<%=this.HdnRemarkID %>');
        hdnRemarkID.value = "";

        var hdnRemarkHtml = document.getElementById('<%=this.HdnRemarkHtml %>');
        hdnRemarkHtml.value = "";

        if (inpTitleRemark != null)
            inpTitleRemark.value = "";

        var lblRemarkHTML_E = document.getElementsByName('lblRemarkHTML_E');
        if (lblRemarkHTML_E != null)
            lblRemarkHTML_E.innerHTML = "";

    }

    function checkDate(sender, args) {

        var from = sender._selectedDate.format(sender._format);
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
            alert(".לא ניתן לבחור תאריך קטן מתאריך נוכחי");
            sender._selectedDate = new Date();
            // set the date back to the current date
            sender._textbox.set_Value(sender._selectedDate.format(sender._format))
        }

        validateTime();
    }

    function compareDates(val, args) {

        var receptionDateFrom = null;
        var receptionDateTo = null;
        var hdnHeaderValidFromClientID = null;
        var hdnHeaderValidToClientID = null;
        var pos = null;
        var from = null;
        var to = null;

        var objectID = val.id;
        if (objectID != null) {

            hdnHeaderValidFromClientID = document.getElementsByName('<%=this.hdnHeaderValidFromClientID.ClientID %>')[0].value;
            from = document.getElementsByName(hdnHeaderValidFromClientID)[0].value;

            hdnHeaderValidToClientID = document.getElementsByName('<%=this.hdnHeaderValidToClientID.ClientID %>')[0].value;
            to = document.getElementsByName(hdnHeaderValidToClientID)[0].value;
        }

        if (from != null) {
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

        validateTime();
    }
    
    function timeOverlapping(fromHourOld, toHourOld, fromHourNew, toHourNew, validFromOld, validToOld, validFromNew, validToNew) {
        var overLapping = false;
        //alert("timeOverlapping");
        var tmpFromHourOld = parseInt(fromHourOld.split(":")[0].charAt(0) == 0 ? fromHourOld.split(":")[0].charAt(1) : fromHourOld.split(":")[0] + fromHourOld.split(":")[1]);
        var tmpToHourOld = parseInt(toHourOld.split(":")[0].charAt(0) == 0 ? toHourOld.split(":")[0].charAt(1) : toHourOld.split(":")[0] + toHourOld.split(":")[1]);
        var tmpfromHourNew = parseInt(fromHourNew.split(":")[0].charAt(0) == 0 ? fromHourNew.split(":")[0].charAt(1) : fromHourNew.split(":")[0] + fromHourNew.split(":")[1]);
        var tmptoHourNew = parseInt(toHourNew.split(":")[0].charAt(0) == 0 ? toHourNew.split(":")[0].charAt(1) : toHourNew.split(":")[0] + toHourNew.split(":")[1]);

        if (tmpFromHourOld > tmpfromHourNew) {
            if (tmptoHourNew <= tmpFromHourOld) {
                overLapping = true;
            }
        }
        else {
            if (tmpfromHourNew >= tmpToHourOld) {
                overLapping = true;
            }
        }

        if (!overLapping) {
            if (validToOld != '') {
                var toOldParts = validToOld.match(/(\d+)/g);
                var fromNewParts = validFromNew.match(/(\d+)/g);

                var toOld = new Date(Date.parse(toOldParts[1] + '-' + toOldParts[0] + '-' + toOldParts[2]));
                var fromNew = new Date(Date.parse(fromNewParts[1] + '-' + fromNewParts[0] + '-' + fromNewParts[2]));

                //if (toOld <= fromNew)
                //    overLapping = true;
                if (toOldParts[2] < fromNewParts[2]) {
                    overLapping = true;
                }
                else if (toOldParts[2] = fromNewParts[2]) {
                    if (toOldParts[1] < fromNewParts[1]) {
                        overLapping = true;
                    }
                    else if (toOldParts[1] = fromNewParts[1]) {
                        if (toOldParts[0] <= fromNewParts[0]) {
                            overLapping = true;
                        }
                    }
                }
            }
            else if (validToNew != '') {
                var toNewParts = validToNew.match(/(\d+)/g);
                var fromOldParts = validFromOld.match(/(\d+)/g);

                if (toNewParts[2] < fromOldParts[2]) {
                    overLapping = true;
                }
                else if (toNewParts[2] = fromOldParts[2]) {
                    if (toNewParts[1] < fromOldParts[1]) {
                        overLapping = true;
                    }
                    else if (toNewParts[1] = fromOldParts[1]) {
                        if (toNewParts[0] <= fromOldParts[0]) {
                            overLapping = true;
                        }
                    }
                }

            }

        }


        return !overLapping;
    }

    function TimeSettings() {
        this.day;
        this.fromHour;
        this.toHour;
        this.validFrom;
        this.validTo;
    }

    var dgReceptionHoursID = "<%=dgReceptionHours.ClientID %>";
    var overLapCheckCounters = 1;
    var overLapValid = false;

    function setTimeSettings(TimeSettingsObj, rowIndex) {
        var tmpRowIndex = rowIndex;
        if (rowIndex < 10) {
            tmpRowIndex = "0" + rowIndex;
        }
        
        if (rowIndex == 1) {
            TimeSettingsObj.day = $("#" + dgReceptionHoursID + "_ctl" + tmpRowIndex + "_MultiDDlSelect_Days_txtItems").val();
        }
        else {
            TimeSettingsObj.day = $("#" + dgReceptionHoursID + "_ctl" + tmpRowIndex + "_mltDdlDayE_txtItems").val();
        }
        TimeSettingsObj.fromHour = $("#" + dgReceptionHoursID + "_ctl" + tmpRowIndex + "_txtFromHour").val();
        TimeSettingsObj.toHour = $("#" + dgReceptionHoursID + "_ctl" + tmpRowIndex + "_txtToHour").val();
        TimeSettingsObj.validFrom = $("#" + dgReceptionHoursID + "_ctl" + tmpRowIndex + "_txtFromDate").val();
        TimeSettingsObj.validTo = $("#" + dgReceptionHoursID + "_ctl" + tmpRowIndex + "_txtToDate").val();
    }

    function checkIfOverlapHours(rowIndex) {
        //alert("checkIfOverlapHours rowIndex = " + rowIndex);
        //var rows = $("#<%=dgReceptionHours.ClientID %>").attr('rows');

        var gridView = document.getElementById("<%=dgReceptionHours.ClientID %>");
        //var rows = gridView.getElementsByTagName("tr");
        var rows = gridView.rows;

        //alert("rows = " + rows);
        //alert(rows.length);
        var i = 0;
        var updatedRowImage;
        var overLap = false;
        var myTimeSettingsObj = new TimeSettings();

        //return;

        setTimeSettings(myTimeSettingsObj, rowIndex);
        $.each(rows, function () {

            if (rowIndex - 1 == i) {
                if (rowIndex - 1 == 0) {
                    updatedRowImage = $(this).find("#imgAlertOverLapHeader");
                }
                else {
                    updatedRowImage = $(this).find("#imgAlertOverLapData");
                }

            }
            else {
                var rowDay = $(this).find("td").eq(2).find("span").html();
                var arrDays = myTimeSettingsObj.day.split(",");

                if (strExist(arrDays, rowDay)) {
                    //alert("strExist");
                    var fromHourOld = $(this).find("td").eq(4).find("span").html();
                    var toHourOld = $(this).find("td").eq(5).find("span").html();
                    var validFromOld = $(this).find("td").eq(8).find("span").html();
                    var validToOld = $(this).find("td").eq(9).find("span").html();

                    /* Check if the remark is EnableOverlappingHours */
                    if ($(this).find("td").eq(6).find("input").val() != "True" && selectedEnableOverlappingHours != "True") {
                        if (timeOverlapping(fromHourOld, toHourOld, myTimeSettingsObj.fromHour, myTimeSettingsObj.toHour, validFromOld, validToOld, myTimeSettingsObj.validFrom, myTimeSettingsObj.validTo)) {
                            $(this).find("#imgAlertOverLapData").show();
                            overLap = true;
                            //alert(overLap);
                        }
                        else {
                            $(this).find("#imgAlertOverLapData").hide();
                        }
                    }
                    else {
                        $(this).find("#imgAlertOverLapData").hide();
                    }
                }
                else {
                    $(this).find("#imgAlertOverLapData").hide();
                }
            }

            i++;
        });
        // lblRemark may not exists on page - need to check if it is not null
        var lblRemark = document.getElementById("lblOverlapingHoursRemark");

        if (overLap) {
            updatedRowImage.show();
            if (lblRemark != null) {
                lblRemark.style.display = 'inline';
            }

        }
        else {
            updatedRowImage.hide();
            if (lblRemark != null) {
                lblRemark.style.display = 'none';
            }
        }
        
        overLapValid = !overLap;

    }

    function strExist(arrStr, str) {
        var found = false;
        var count = 0;

        $.each(arrStr, function () {
            if (this == str)
                found = true;
        });
        
        return found;
    }

    function validateTime(event, sender) {

        let button;
        let elementNameArray;

        let element;

        if (typeof (sender) === 'undefined' || isTimeElement(sender) === false) {

            defaultElementId = getOpenRowElementId(); // Return element if update row is 1 and above (not row zero)

            if (defaultElementId == "") {
                element = getDefaultElement();
            }
            else {
                element = document.getElementById(defaultElementId);
            }
        }
        else {
            element = sender;
        }

        button = getButton(element);

        elementNameArray = element.id.split('_');

        const elementName = elementNameArray[elementNameArray.length - 1];
        
        const fromElementNameArray = [...elementNameArray.slice(0, elementNameArray.length - 1), 'txtFromHour'];
        const fromElementName = fromElementNameArray.join("_");
        const fromElement = document.getElementById(fromElementName);
        
        const toElementNameArray = [...elementNameArray.slice(0, elementNameArray.length - 1), 'txtToHour'];
        const toElementName = toElementNameArray.join("_");
        const toElement = document.getElementById(toElementName);
        
        const remark = getRemark(elementNameArray);

        setButton(button, false);

        setError(fromElement, false);

        setError(toElement, false);

        if (fromElement.value === "") { }

        const isFromValid = validateTimeElement(event, fromElement);
        const isToValid = validateTimeElement(event, toElement);
        
        if (isFromValid == false) {
            if (fromElement.value.length > 0) setError(fromElement, true);
            return false;
        }

        if (elementName.includes("FromHour") && fromElement.value.length == 5 && event != null && event.key != 'ArrowLeft' && event.key != 'ArrowRight') {
            toElement.focus();
        }

        if (isToValid == false) {
            if (toElement.value.length > 0) setError(toElement, true);
            return false;
        }

        const fromTime = fromElement.value;

        const toTime = toElement.value;

        var fromDate = new Date(2000, 1, 1, fromTime.substring(0, 2), fromTime.substring(3, 5));
        var toDate = new Date(2000, 1, 1, toTime.substring(0, 2), toTime.substring(3, 5));
        var midnight = new Date(2000, 1, 1, 0, 0);
        
        var fromMinutes = fromTime.substring(3, 5);
        var toMinutes = toTime.substring(3, 5);

        if (fromMinutes.length < 2 || toMinutes.length < 2) {
            //Skip date check if minuts deleted by client
        }
        else if (toDate.getTime() == midnight.getTime()) {
            //Skip date check if toDate is 00:00
        }
        else if (fromDate >= toDate) {
            if (remark.value != 'למחרת') {
                setError(fromElement, true);
                setError(toElement, true);
                return false;
            }
        }

        setError(fromElement, false);
        setError(toElement, false);

        setButton(button, true);
    }

    function validateTimeElement(event, element) {

        let timeValue = element.value;

        if (timeValue.length > 1 && parseInt(timeValue[0] + timeValue[1]) > 24) {
            return false;
        }

        if ((timeValue.length == 2) && event.key != "Backspace" && !timeValue.includes(':')) {
            element.value += ':';
        }

        if (timeValue.length < 5) {
            return false;
        }

        if (timeValue.indexOf(":") < 0) {
            return false;
        }

        var hours = timeValue.split(':')[0];
        var minutes = timeValue.split(':')[1];

        if (hours == "" || isNaN(hours) || parseInt(hours) > 23) {
            return false;
        }

        if (minutes == "" || isNaN(minutes) || parseInt(minutes) > 59) {
            return false;
        }
        else if (parseInt(minutes) == 0) {
            minutes = "00";
        }
        else if (minutes < 10) {
            minutes = "0" + minutes;
        }

        timeValue.value = hours + ":" + minutes;

        return true;
    }

    function isTimeElement(element) {

        let regExp1 = new RegExp('^ctl00_pageContent_gvReceptionHours_dgReceptionHours_[a-z0-9]{5}_txtFromHour');
        let regExp2 = new RegExp('^ctl00_pageContent_gvReceptionHours_dgReceptionHours_[a-z0-9]{5}_txtToHour');

        if (regExp1.test(element.id)) return true;
        else if (regExp2.test(element.id)) return true;
        else return false;
    }

    function getDefaultElement() {
        return document.getElementById('ctl00_pageContent_gvReceptionHours_dgReceptionHours_ctl01_txtFromHour');
    }

    function getOpenRowElementId() {

        let elementNameArray;
        let result = "";
        const regExp = new RegExp("^ctl00_pageContent_gvReceptionHours_dgReceptionHours_[a-z0-9]{5}_imgSave$");

        document.querySelectorAll('*').forEach(function (node) {
            if (regExp.test(node.id)) {

                elementNameArray = node.id.split('_');

                result = [...elementNameArray.slice(0, elementNameArray.length - 1), 'txtFromHour'].join('_');
            }
        });

        return result;
    }

    function setError(element, isSet) {

        if (isSet) {
            element.style.backgroundColor = '#FD8989';
        }
        else {
            element.style.backgroundColor = 'white';
        }
    }

    function setButton(button, isEnable) {
        if (isEnable) {
            button.disabled = false;
            button.classList.add('button');
            button.classList.remove('button_disabled');
        }
        else {
            button.disabled = true;
            button.classList.remove('button');
            button.classList.add('button_disabled');
        }
    }

    function getButton(element) {

        const elementIdArray = element.id.split('_');

        let buttonIdArray = element.id.split('_');

        const gridViewRow = elementIdArray[4];

        let button;

        let buttonId;

        buttonIdArray[4] = gridViewRow;

        if (gridViewRow == 'ctl01') {
            buttonIdArray[5] = 'imgAdd';
        }
        else {
            buttonIdArray[5] = 'imgSave';
        }

        buttonId = buttonIdArray.join('_');

        button = document.getElementById(buttonId);

        return button;
    }

    function getRemark(elementNameArray) {
        let remarkNameArray;
        let remarkName;

        if (elementNameArray[4] == 'ctl01') {
            remarkName = 'inpTitleRemark';
        }
        else {
            remarkNameArray = [...elementNameArray.slice(0, elementNameArray.length - 1), 'lblRemarkText_E'];
            remarkName = remarkNameArray.join('_');
        }

        return document.getElementById(remarkName);
    }

    function keyispressed(event, element) {

        if (event.key == 'ArrowLeft' || event.key == 'ArrowRight') {
            //Allow right and left key
        }
        else if (isNaN(event.key) && event.which != 8 && event.key != ':') {
            event.preventDefault();
        }
        else if (event.key == ':' && element.value.includes(':')) {
            event.preventDefault();
        }

        return true;
    }
</script>
<style>
    .button {
        margin: 0;
        border: 1px solid #021ae8;
        border-radius: 3px;
        color: #021ae8;
        font-weight: bold;
        background-color: #e3f2fd;
    }

    .button:hover {
        border: 1px solid #000e82;
        color: #000e82;
        cursor: pointer;
    }

    .button_disabled {
        
    }
</style>
<asp:UpdatePanel runat="server" UpdateMode="Conditional" ID="UpdPanel1">

    <ContentTemplate>
        <asp:GridView ID="dgReceptionHours" runat="server" dir="rtl" AutoGenerateColumns="False"
            AllowSorting="True" EnableTheming="True" OnRowDataBound="dgReceptionHours_RowDataBound"
            OnRowDeleting="dgReceptionHours_RowDeleting" OnRowCancelingEdit="dgReceptionHours_RowCancelingEdit"
            meta:resourcekey="dgReceptionHoursResource1">
            <Columns>
                <asp:TemplateField Visible="False" meta:resourcekey="TemplateFieldResource1">
                    <ItemTemplate>
                        <asp:Label ID="lblDays2" runat="server" Text='<%# Eval("ReceptionDay") %>' meta:resourcekey="lblDays2Resource1"></asp:Label>
                        <asp:Label ID="lblRemarkText" runat="server" Text='<%# Eval("RemarkText") %>' meta:resourcekey="lblRemarkTextResource1"></asp:Label>
                        <asp:Label ID="lblRemarkID" runat="server" Text='<%# Eval("RemarkID") %>' meta:resourcekey="lblRemarkIDResource1"></asp:Label>
                        <asp:Label ID="lblAdd_ID" runat="server" Text='<%# Eval("Add_ID") %>'></asp:Label>
                        <asp:Label ID="lblReceptionId" runat="server" Text='<%# Eval("ReceptionId") %>' meta:resourcekey="lblReceptionIdsResource1"></asp:Label>
                        <asp:Label ID="lblEnableOverMidnightHours" runat="server" Text='<%# Eval("EnableOverMidnightHours") %>'></asp:Label>
                    </ItemTemplate>
                </asp:TemplateField>
                <%--Days Column--%>
                <asp:TemplateField meta:resourcekey="TemplateFieldResource3">
                    <HeaderTemplate>
                        
                        <table>
                        
                            <tr>
                                <td align="right">
                                    <asp:Label ID="Label1" runat="server" Text=": ימים " meta:resourcekey="Label1Resource1"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td align="right">
                                    <MultiDDlSelect_UC:MultiDDlSelect_UCItem runat="server" ID="MultiDDlSelect_Days">
                                    </MultiDDlSelect_UC:MultiDDlSelect_UCItem>
                                </td>
                            </tr>
                        </table>
                    </HeaderTemplate>
                    <HeaderStyle HorizontalAlign="Center" />
                    <ItemTemplate>
                        <table>
                            <tr>
                                <td>
                                </td>
                            </tr>
                            <tr>
                                <td align="center">
                                    <asp:Label runat="server" ID="lblDays" Text='<%# Eval("ReceptionDay") %>' meta:resourcekey="lblDaysResource1"></asp:Label>
                                </td>
                            </tr>
                        </table>
                    </ItemTemplate>
                    <ItemStyle Width="95px" HorizontalAlign="Center" />
                    <EditItemTemplate>
                        <table>
                            <tr align="left">
                                <td>
                                </td>
                            </tr>
                            <tr align="left">
                                <td align="left">
                                    <MultiDDlSelect_UC:MultiDDlSelect_UCItem runat="server" ID="mltDdlDayE"></MultiDDlSelect_UC:MultiDDlSelect_UCItem>
                                </td>
                            </tr>
                        </table>
                    </EditItemTemplate>
                </asp:TemplateField>
                <%--OverLap Images Column--%>
                <asp:TemplateField>
                    <HeaderTemplate>
                        <img style="display:none;" id="imgAlertOverLapHeader" src="../Images/imgConflict.gif" title="קיימת כפילות בשעות הקבלה – יש להזין הערות בימים החופפים" />
                    </HeaderTemplate>
                    <ItemTemplate>
                        <img style="display:none;" id="imgAlertOverLapData" src="../Images/imgConflict.gif" title="קיימת כפילות בשעות הקבלה – יש להזין הערות בימים החופפים" />
                    </ItemTemplate>
                </asp:TemplateField>
                <%--From Hour Column--%>
                <asp:TemplateField meta:resourcekey="TemplateFieldResource4">
                    <HeaderTemplate>
                        <table>
                            <tr>
                                <td style="padding-right: 3px">
                                    <asp:Label ID="Label2" runat="server" Text=":משעה" meta:resourcekey="Label2Resource1"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td valign="bottom">
                                    <asp:TextBox ID="txtFromHour" runat="server" dir="ltr" Width="50px" onkeydown="return keyispressed(event, this);" onkeyup="return validateTime(event, this)"  MaxLength="5" autocomplete="off"></asp:TextBox>
                                </td>
                            </tr>
                        </table>
                    </HeaderTemplate>
                    <HeaderStyle Width="100px" />
                    <ItemTemplate>
                        <div style="margin-right: 20px">
                            <asp:Label runat="server" ID="lblOpeningHour" Text='<%# Eval("openingHour") %>' meta:resourcekey="lblOpeningHourResource1"></asp:Label>
                        </div>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <table width="100px">
                            <tr>
                                <td>
                                    <asp:TextBox ID="txtFromHour" runat="server" Text='<%# Eval("openingHour") %>' dir="ltr" Width="50px" onkeydown="return keyispressed(event, this);" onkeyup="return validateTime(event, this)"  MaxLength="5" autocomplete="off"></asp:TextBox>
                                </td>
                            </tr>
                        </table>
                    </EditItemTemplate>
                </asp:TemplateField>
                <%--To Hour Column--%>
                <asp:TemplateField>
                    <HeaderTemplate>
                        <table>
                            <tr>
                                <td style="padding-right: 2px">
                                    <asp:Label ID="Label3" runat="server" Text=":עד שעה" meta:resourcekey="Label3Resource1"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:TextBox ID="txtToHour" runat="server" dir="ltr" Width="50px" onkeydown="return keyispressed(event, this);" onkeyup="return validateTime(event, this)"  MaxLength="5" autocomplete="off"></asp:TextBox>
                                </td>
                            </tr>
                        </table>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <div style="margin-right: 17px; width: 70px">
                            <asp:Label runat="server" ID="lblClosingHour" Text='<%# Eval("closingHour") %>' meta:resourcekey="lblClosingHourResource1"></asp:Label>
                        </div>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <table width="100px">
                            <tr>
                                <td>
                                    <asp:TextBox ID="txtToHour" runat="server" Text='<%# Eval("closingHour") %>' dir="ltr" Width="50px" onkeydown="return keyispressed(event, this);" onkeyup="return validateTime(event, this)"  MaxLength="5" autocomplete="off"></asp:TextBox>
                                </td>
                            </tr>
                        </table>
                    </EditItemTemplate>
                    <ItemStyle Width="100px" />
                </asp:TemplateField>
                <asp:TemplateField>
                    <ItemTemplate>
                        <asp:HiddenField runat="server" ID="hdEnableOverlappingHours" Value='<%# Eval("EnableOverlappingHours") %>' />
                    </ItemTemplate>
                </asp:TemplateField>
                <%--Remark Column--%>
                <asp:TemplateField meta:resourcekey="TemplateFieldResource6">
                    <HeaderTemplate>
                        <table>
                            <tr>
                                <td>
                                    <asp:HiddenField ID="hdnRemarkText" runat="server" />
                                    <asp:HiddenField ID="hdnRemarkMask" runat="server" />
                                    <asp:HiddenField ID="hdnRemarkID" runat="server" />
                                    <asp:HiddenField ID="hdnRemarkHtml" runat="server" />
                                </td>
                            </tr>
                            <tr>
                                <td style="padding-right: 5px">
                                    <asp:Label ID="lblTitleRemark" runat="server" Text="הערה :" meta:resourcekey="lblTitleRemarkResource2"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <table id="tblTitleRemark" style="vertical-align: top">
                                        <tr>
                                            <td>
                                                <input type="text" id="inpTitleRemark" readonly="readonly" style="width: 245px" />
                                            </td>
                                            <td>
                                                <input type="image" id="btnRemark" style="cursor: pointer;" src="../Images/Applic/icon_magnify.gif"
                                                    onclick="OpenRemarkWindowDialog('ReceptionHours','header'); return false;" validationgroup="vldGrAdd"
                                                    causesvalidation="true" />
                                            </td>
                                            <tr>
                                                <td>
                                                </td>
                                            </tr>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <div style="margin-right: 10px">
                            <asp:Label runat="server" ID="lblRemark" Text='<%# Eval("RemarkText") %>' meta:resourcekey="lblRemarkResource1"></asp:Label>
                        </div>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <table>
                            <tr>
                                <td valign="top" style="padding-right: 4px">
                                    <input type="text" id="lblRemarkText_E" readonly="readonly" value='<%# Eval("RemarkText") %>' 
                                       runat="server" style="width: 245px" />
                                </td>
                                <td>
                                    <input type="image" id="btnRemark" style="cursor: pointer;" src="../Images/Applic/icon_magnify.gif"
                                        onclick="OpenRemarkWindowDialog('ReceptionHours','edit');return false;" validationgroup="vldGrEdit"
                                        causesvalidation="true" />
                                </td>
                                <td>
                                    <input type="image" id="btnDelRemark" style="cursor: pointer;" src="../Images/Applic/btn_X_red.gif"
                                        onclick="DeleteRemark();return false;" validationgroup="vldGrEdit" title="למחוק הערה"
                                        causesvalidation="true" />
                                </td>
                            </tr>
                        </table>
                    </EditItemTemplate>
                    <ItemStyle Width="245px" />
                </asp:TemplateField>
                <%--Valid From Column --%>
                <asp:TemplateField>
                    <HeaderTemplate>
                        <table style="width:120px;">
                            <tr>
                                <td style="padding-right: 2px">
                                    <asp:Label ID="Label4" runat="server" Text="תוקף מ:" meta:resourcekey="Label4Resource1"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td style="direction:ltr;">
                                    <cc1:MaskedEditValidator ID="FromDateValidator" runat="server" ControlExtender="FromDateExtender"
                                        ControlToValidate="txtFromDate" InvalidValueMessage="התאריך אינו תקין" Display="Dynamic"
                                        InvalidValueBlurredMessage="*" ValidationGroup="vldGrAdd" ErrorMessage="התאריך אינו תקין" />
                                    <asp:ImageButton ImageUrl="~/Images/Applic/calendarIcon.png" ID="btnRunCalendar"
                                        runat="server" meta:resourcekey="btnRunCalendarResource2" />
                                    <asp:TextBox ID="txtFromDate" Width="80px" runat="server" Text='<%# Eval("ValidFrom","{0:d}") %>'
                                        onkeyup="FocusNextFieldIfNeeded(this, 'txtToDate', event);"></asp:TextBox>
                                    <cc1:CalendarExtender ID="calExtFromDate_DeptName" runat="server" Format="dd/MM/yyyy"
                                        FirstDayOfWeek="Sunday" TargetControlID="txtFromDate" PopupPosition="BottomRight"
                                        PopupButtonID="btnRunCalendar" Enabled="True" OnClientDateSelectionChanged="checkDate">
                                    </cc1:CalendarExtender>
                                    <cc1:MaskedEditExtender ID="FromDateExtender" runat="server" ErrorTooltipEnabled="True"
                                        Mask="99/99/9999" MaskType="Date" TargetControlID="txtFromDate" ClearMaskOnLostFocus="false"
                                        Enabled="True">
                                    </cc1:MaskedEditExtender>
                                    
                                </td>
                            </tr>
                        </table>
                    </HeaderTemplate>
                    <HeaderStyle Width="110px" />
                    <ItemTemplate>
                        <div style="padding-right: 4px">
                            <asp:Label runat="server" ID="lblValidFrom" Text='<%# Eval("ValidFrom","{0:d}") %>'
                                meta:resourcekey="lblValidFromResource1"></asp:Label>
                        </div>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <table width="120px">
                            <tr>
                                <td style="direction:ltr;">
                                    <cc1:MaskedEditValidator ID="FromDateValidator" runat="server" ControlExtender="FromDateExtender"
                                        ControlToValidate="txtFromDate" InvalidValueMessage="התאריך אינו תקין" Display="Dynamic"
                                        InvalidValueBlurredMessage="*" ValidationGroup="vldGrEdit" ErrorMessage="התאריך אינו תקין"
                                        Text="*" />
                                    
                                    <asp:ImageButton ImageUrl="~/Images/Applic/calendarIcon.png" ID="btnRunCalendar"
                                        runat="server" meta:resourcekey="btnRunCalendarResource1" />
                                    <asp:TextBox ID="txtFromDate" Width="80px" runat="server" Text='<%# Eval("ValidFrom","{0:dd/MM/yyyy}") %>'
                                        onkeyup="FocusNextFieldIfNeeded(this, 'txtToDate', event);"></asp:TextBox>
                                    <cc1:CalendarExtender ID="calExtFromDate_DeptName" runat="server" Format="dd/MM/yyyy"
                                        FirstDayOfWeek="Sunday" TargetControlID="txtFromDate" PopupPosition="BottomRight"
                                        PopupButtonID="btnRunCalendar" Enabled="True" OnClientDateSelectionChanged="checkDate">
                                    </cc1:CalendarExtender>
                                    <cc1:MaskedEditExtender ID="FromDateExtender" runat="server" ErrorTooltipEnabled="True"
                                        Mask="99/99/9999" MaskType="Date" TargetControlID="txtFromDate" ClearMaskOnLostFocus="false"
                                        Enabled="True">
                                    </cc1:MaskedEditExtender>
                                    
                                </td>
                            </tr>
                        </table>
                    </EditItemTemplate>
                </asp:TemplateField>
                <%-- Valid To Column --%>
                <asp:TemplateField>
                    <HeaderTemplate>
                        <table>
                            <tr>
                                <td style="padding-right: 2px">
                                    <asp:Label ID="Label5" runat="server" Text="תוקף עד:" meta:resourcekey="Label5Resource1"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td style="direction:ltr;">
                                    <cc1:MaskedEditValidator ID="txtToDate_DeptStatus_Validator" runat="server" ControlExtender="txtToDate_DeptStatus_Extender"
                                        ControlToValidate="txtToDate" InvalidValueMessage="התאריך אינו תקין" Display="Dynamic"
                                        Text="*" InvalidValueBlurredMessage="*" ValidationGroup="vldGrAdd" ErrorMessage="התאריך אינו תקין" />
                                    <asp:CustomValidator runat="server" ID="CompareDatesValidatorHeader" ControlToValidate="txtToDate"
                                        ClientValidationFunction="compareDates" Text="*" ErrorMessage="טווח תאריכים אינו תקין"
                                        ValidateEmptyText="false" ValidationGroup="vldGrAdd"></asp:CustomValidator>
                                    <asp:ImageButton ImageUrl="~/Images/Applic/calendarIcon.png" ID="btnRunCalendarTo"
                                        runat="server" meta:resourcekey="btnRunCalendarToResource1" />
                                    <asp:TextBox ID="txtToDate" Width="80px" runat="server" Text='<%# Eval("ValidTo","{0:d}") %>'
                                        onkeyup="FocusNextFieldIfNeeded(this, 'imgAdd', event);"></asp:TextBox>
                                    <cc1:CalendarExtender ID="calExtToDate_DeptStatus" runat="server" Format="dd/MM/yyyy"
                                        FirstDayOfWeek="Sunday" TargetControlID="txtToDate" PopupPosition="BottomRight"
                                        PopupButtonID="btnRunCalendarTo" Enabled="True">
                                    </cc1:CalendarExtender>
                                    <cc1:MaskedEditExtender ID="txtToDate_DeptStatus_Extender" runat="server" ErrorTooltipEnabled="True"
                                        Mask="99/99/9999" MaskType="Date" TargetControlID="txtToDate" Enabled="True">
                                    </cc1:MaskedEditExtender>
                                    
                                </td>
                            </tr>
                        </table>
                    </HeaderTemplate>
                    <HeaderStyle Width="130px" />
                    <ItemTemplate>
                        <div style="padding-right: 4px">
                            <asp:Label runat="server" ID="lblValidTo" Text='<%# Eval("ValidTo","{0:dd/MM/yyyy}") %>'
                                meta:resourcekey="lblValidToResource1"></asp:Label>
                        </div>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <table width="130px">
                            <tr>
                                <td style="direction:ltr;">
                                    <cc1:MaskedEditValidator ID="txtToDate_E_ValidatorE2" runat="server" ControlExtender="txtToDate_E_ExtenderE2"
                                        ControlToValidate="txtToDate" InvalidValueMessage="התאריך אינו תקין" Display="Dynamic"
                                        InvalidValueBlurredMessage="*" ValidationGroup="vldGrEdit" ErrorMessage="התאריך אינו תקין" />
                                    <asp:CustomValidator runat="server" ID="CompareDatesValidatorEdit" ControlToValidate="txtToDate"
                                        ClientValidationFunction="compareDates" Text="*" ErrorMessage="טווח תאריכים אינו תקין"
                                        ValidationGroup="vldGrEdit" ValidateEmptyText="false"></asp:CustomValidator>
                                    <asp:ImageButton ImageUrl="~/Images/Applic/calendarIcon.png" ID="btnRunCalendarToE2"
                                        runat="server" onkeyup="FocusNextFieldIfNeeded(this, 'imgAdd', event);" />
                                    <asp:TextBox ID="txtToDate" Width="80px" runat="server" Text='<%# Eval("ValidTo","{0:d}") %>'
                                        onkeyup="FocusNextFieldIfNeeded(this, 'imgSave', event);"></asp:TextBox>
                                    <cc1:CalendarExtender ID="calExtToDate_E2" runat="server" Format="dd/MM/yyyy" FirstDayOfWeek="Sunday"
                                        TargetControlID="txtToDate" PopupPosition="BottomRight" PopupButtonID="btnRunCalendarToE2"
                                        Enabled="True">
                                    </cc1:CalendarExtender>
                                    <cc1:MaskedEditExtender ID="txtToDate_E_ExtenderE2" runat="server" CultureName="he-IL"
                                        ErrorTooltipEnabled="True" Mask="99/99/9999" MaskType="Date" TargetControlID="txtToDate"
                                        CultureAMPMPlaceholder="AM;PM" CultureCurrencySymbolPlaceholder="₪" CultureDateFormat="DMY"
                                        CultureDatePlaceholder="/" CultureDecimalPlaceholder="." CultureThousandsPlaceholder=","
                                        CultureTimePlaceholder=":" Enabled="True">
                                    </cc1:MaskedEditExtender>
                                    
                                </td>
                            </tr>
                        </table>
                    </EditItemTemplate>
                </asp:TemplateField>
                <%-- Delete Column--%>
                <asp:TemplateField meta:resourcekey="TemplateFieldResource9">
                    <ItemTemplate>
                        <asp:ImageButton ID="imgDelete" runat="server" CommandName="delete" OnClick="imgDelete_Click"
                            ImageUrl="~/Images/Applic/btn_X_red.gif" meta:resourcekey="imgDeleteResource1" />
                    </ItemTemplate>
                    <ItemStyle Width="25px" />
                    <EditItemTemplate>
                        <div style="width: 25px">
                            <input type="text" id="lblRemarkID_E" name="lblRemarkID_E_name" style="display: none; width: 1px" value="<%# Eval("RemarkID") %>" />
                            <input type="text" id="lblRemarkHTML_E" style="display: none; width: 1px" />
                            <input type="text" id="lblRemarkMask_E_c" name="lblRemarkMask_E_c_name" value="<%# Eval("RemarkText") %>" style="display: none;
                                width: 1px" />
                            <asp:Label runat="server" Visible="False" ID="lblRemarkMask_E" Width="1px" Text='<%# Bind("RemarkText") %>'
                                meta:resourcekey="lblRemarkMask_EResource1" CssClass="DisplayNone"></asp:Label>
                        </div>
                    </EditItemTemplate>
                </asp:TemplateField>
                <%--Update column--%>
                <asp:TemplateField>
                    <HeaderTemplate>
                        <table border="0" style="margin-left: 10px">
                            <tr>
                                <td style="padding-top: 5px">
                                    <asp:Button runat="server" ID="imgAdd" Enabled="false" Text="הוספה" CausesValidation="true" CommandName="add"
                                                ValidationGroup="vldGrAdd" OnClick="imgAdd_Click" Width="48px" CssClass="button_disabled" />
                                </td>
                            </tr>
                            <tr valign="middle">
                                <td valign="middle">
                                    <asp:Button runat="server" ID="imgClear" Text="נקה" CausesValidation="true" CommandName="clear"
                                                OnClientClick="javascript:clearRemark()" OnClick="imgClear_Click" Width="48px" CssClass="button" />
                                </td>
                            </tr>
                        </table>
                    </HeaderTemplate>
                    <HeaderStyle Width="40px" />
                    <ItemTemplate>
                        <div style="margin-right: 3px">
                            <asp:Button runat="server" ID="imgUpdate" Enabled="true" Text="עדכון" CausesValidation="true" CommandName="update"
                                        OnClick="imgUpdate_Click" Width="48px" CssClass="button" ValidationGroup="vldGrEdit" />
                        </div>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <table>
                            <tr>
                                <td>
                                    <asp:Button runat="server" ID="imgCancel" Enabled="true" Text="ביטול" CausesValidation="true" CommandName="cancel"
                                                OnClick="imgCancel_Click" Width="48px" CssClass="button" />
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:Button runat="server" ID="imgSave" Enabled="false" Text="אישור" CausesValidation="true" CommandName="save"
                                                OnClick="imgSave_Click" Width="48px" CssClass="button_disabled" />
                                </td>
                            </tr>
                        </table>
                    </EditItemTemplate>
                </asp:TemplateField>

            </Columns>
            <SelectedRowStyle ForeColor="GhostWhite" />
            <HeaderStyle BackColor="#F3EBE0" CssClass="SimpleBold" />
        </asp:GridView>
        <div id="hdnDiv">
            <asp:TextBox ID="txtWherePutRemark" runat="server" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>

            <asp:TextBox ID="txtSelectedRemarkID_FromDialog" runat="server" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>
            <asp:TextBox ID="txtSelectedRemark_FromDialog" runat="server" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>
            <asp:TextBox ID="txtSelectedRemarkMask_FromDialog" runat="server" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>
            <asp:TextBox ID="txtSelectedEnableOverMidnightHours_FromDialog" runat="server" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>
            <asp:TextBox ID="txtSelectedEnableOverlappingHours_FromDialog" runat="server" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>

            <asp:HiddenField ID="hdnRemark" runat="server" />
            <asp:HiddenField ID="hdnRemarkText_E" runat="server" />
            <asp:HiddenField ID="hdnRemarkMask_E" runat="server" />
            <asp:HiddenField ID="hdnRemarkID_E" runat="server" />
            <asp:HiddenField ID="hdnRemarkHtml_E" runat="server" />
            <asp:HiddenField ID="hdnHeaderFromHourClientID" runat="server" />
            <asp:HiddenField ID="hdnHeaderToHourClientID" runat="server" />
            <asp:HiddenField ID="hdnHeaderValidFromClientID" runat="server" />
            <asp:HiddenField ID="hdnHeaderValidToClientID" runat="server" />
            <asp:HiddenField ID="hdnEditValidFromClientID" runat="server" />
            <asp:HiddenField ID="hdnEditValidToClientID" runat="server" />
            <asp:HiddenField ID="hdnEnableOverMidnightHours" runat="server" />
        </div>
        <asp:HiddenField ID="hfUpdateFlag" runat="server" Value="" />
    </ContentTemplate>

</asp:UpdatePanel>

<% ScriptManager.RegisterClientScriptBlock(this.Page, typeof(string), "CheckTime", "validateTime()", true); %>
