<%@ Register TagPrefix="selectDays" TagName="selectDaysItem" Src="~/UserControls/selectDays.ascx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxtoolkit" %>
<%@ Control Language="C#" AutoEventWireup="true" Inherits="UserControls_RemarkClientHandler" Codebehind="RemarkClientHandler.ascx.cs" %>
<script type="text/javascript">
    /*
        To use this control you need to initial the list - listOfInputID.
        The values of list listOfInputID are the id's and the type of the text boxes seperated by #.
    */
    
    
    /* Globals */
    var currentDayText = "";
    var ListOfTextDaysID = "";
    var ListOfTextHoursID = "";
    var ListOfRegularTextID = "";
    var ListOfTextDateID = "";
    var listOfInputID = "";

    var currentHourText = "";
    var currentDateText = "";
    var notValidObjectsList = "";
    
    
    
    var tblSelectedDaysID = "<%=selectDaysUC.ClientID %>_tblDays";


    function focusNextHour(obj, e) {

        // check if we have a field full of data, and the last key was a digit - move to next field
        
        if (obj.value.indexOf('_') == -1 && ((e.keyCode >= 48 && e.keyCode <= 57) || (e.keyCode >= 96 && e.keyCode <= 105))) {
            var splitID = currentHourText.split("_");
            var nextID = currentHourText.replace("_" + splitID[splitID.length - 1], "_" + (parseInt(splitID[splitID.length - 1]) + 2));
            
            if ($("#" + nextID).length > 0)
            {
                $("#" + currentHourText).val(obj.value);
                checkHourValidation(currentHourText);
                $("#" + nextID).focus(); 
            }
            
        }
    }


    function getInputTypeCode(str) {
        
        var reg = /\d+/g;
        
        return (reg.exec(str));

    }

    function getSimpleText(str, ind) {
        var tmpTable = getTable();
        var tmpTbody = document.createElement("tbody");
        var tmpTR = document.createElement("tr");
        var tmpTD = document.createElement("td");
        var span = document.createElement("span");


        tmpTable.style.height = "30px";
        tmpTD.style.paddingTop = "0";

        span.id = "spanSimple_" + ind;

        //setListOfInputIDs(str, "");
        setListOfInputIDs(span.id, "");

        span.innerHTML = str;
        tmpTD.appendChild(span);
        tmpTR.appendChild(tmpTD);
        tmpTbody.appendChild(tmpTR);
        tmpTable.appendChild(tmpTbody);

        return tmpTable;
    }


    /* Set a list with the current inputs id's of the remark. */
    function setListOfInputIDs(objID_Text, inputTypeCode) {
        if (listOfInputID == "") {
            listOfInputID = objID_Text;
            if (inputTypeCode != "") {
                listOfInputID += "~" + inputTypeCode;
            }
        }
        else {
            listOfInputID += "#" + objID_Text;
            if (inputTypeCode != "") {
                listOfInputID += "~" + inputTypeCode;
            }
        }
    }



    /* Return a table with regular text box */
    function getRegularTextBox(txtIndex, inputTypeCode) {
        var text = document.createElement("input");
        var tmpTable = getTable();
        var tmpTbody = document.createElement("tbody");
        var tmpTR = document.createElement("tr");
        var tmpTD = getTD();

        
        text.id = "txtRegular_" + txtIndex;
        text.style.width = "50px";
        text.type = "text";
        text.className = "TextBoxRegular";
        
        
        setListOfInputIDs(text.id, inputTypeCode);

        tmpTD.appendChild(text);
        tmpTR.appendChild(tmpTD);
        tmpTbody.appendChild(tmpTR);
        tmpTable.appendChild(tmpTbody);

        return tmpTable;
    }

    function getRegularTextBox(txtIndex, inputTypeCode, inputValue) {
        var text = document.createElement("input");
        var tmpTable = getTable();
        var tmpTbody = document.createElement("tbody");
        var tmpTR = document.createElement("tr");
        var tmpTD = getTD();

        
        text.id = "txtRegular_" + txtIndex;
        text.style.width = "50px";
        text.type = "text";
        text.className = "TextBoxRegular";
        text.value = inputValue;
        
        
        setListOfInputIDs(text.id, inputTypeCode);

        tmpTD.appendChild(text);
        tmpTR.appendChild(tmpTD);
        tmpTbody.appendChild(tmpTR);
        tmpTable.appendChild(tmpTbody);

        return tmpTable;
    }

    function getLongTextBox(txtIndex, inputTypeCode, inputValue) {
        var text = document.createElement("textarea");
        var tmpTable = getTable();
        var tmpTbody = document.createElement("tbody");
        var tmpTR = document.createElement("tr");
        var tmpTD = getTD();


        text.id = "txtRegular_" + txtIndex;
        text.style.width = "510px";
        text.style.height = "50px";
        text.className = "TextBoxRegular";
        text.value = inputValue;


        setListOfInputIDs(text.id, inputTypeCode);

        tmpTD.appendChild(text);
        tmpTR.appendChild(tmpTD);
        tmpTbody.appendChild(tmpTR);
        tmpTable.appendChild(tmpTbody);

        return tmpTable;
    }

    function getTable() {
        var tmpTable = document.createElement("table");
        tmpTable.style.display = "inline";
        tmpTable.cellpadding = 0;
        tmpTable.cellspacing = 0;

        return tmpTable;
    }


    /* Return a table with hour type text box */
    function getHourTextBox(txtIndex, inputTypeCode) {
        var text = document.createElement("input");
        var tmpTable = getTable();
        var tmpTbody = document.createElement("tbody");
        var tmpTR = document.createElement("tr");
        var tmpTD = getTD();
        var tmpDIV = document.createElement("div");

        tmpDIV.id = "divDynamicHour_" + txtIndex;
        

        text.id = "txtDynamicHour_" + txtIndex;
        text.style.width = "50px";
        text.type = "text";
        text.className = "TextBoxRegular";

        
        
        setListOfInputIDs(text.id, inputTypeCode);

        
        tmpDIV.appendChild(text);
        tmpTD.appendChild(tmpDIV);
        tmpTR.appendChild(tmpTD);

        
        tmpTD = getTD();
        tmpTD.id = "tdHoursNotValid_" + txtIndex;
        tmpTD.innerHTML = "*";
        tmpTD.style.width = "10px";
        tmpTD.style.textAlign = "center";
        tmpTD.style.color = "red";
        tmpTD.style.display = "none";
        tmpTR.appendChild(tmpTD);

        tmpTbody.appendChild(tmpTR);
        tmpTable.appendChild(tmpTbody);

        return tmpTable;
    }

    function getHourTextBox(txtIndex, inputTypeCode, inputValue) {
        var text = document.createElement("input");
        var tmpTable = getTable();
        var tmpTbody = document.createElement("tbody");
        var tmpTR = document.createElement("tr");
        var tmpTD = getTD();
        var tmpDIV = document.createElement("div");

        tmpDIV.id = "divDynamicHour_" + txtIndex;
        

        text.id = "txtDynamicHour_" + txtIndex;
        text.style.width = "50px";
        text.type = "text";
        text.className = "TextBoxRegular";
        text.value = inputValue;
        
        
        setListOfInputIDs(text.id, inputTypeCode);

        
        tmpDIV.appendChild(text);
        tmpTD.appendChild(tmpDIV);
        tmpTR.appendChild(tmpTD);

        
        tmpTD = getTD();
        tmpTD.id = "tdHoursNotValid_" + txtIndex;
        tmpTD.innerHTML = "*";
        tmpTD.style.width = "10px";
        tmpTD.style.textAlign = "center";
        tmpTD.style.color = "red";
        tmpTD.style.display = "none";
        tmpTR.appendChild(tmpTD);

        tmpTbody.appendChild(tmpTR);
        tmpTable.appendChild(tmpTbody);

        return tmpTable;
    }


    /* Return a table with date type text box */
    function getDateTextBox(txtIndex, inputTypeCode) {
        var text = document.createElement("input");
        var tmpTable = getTable();
        var tmpTbody = document.createElement("tbody");
        var tmpTR = document.createElement("tr");
        var tmpTD = getTD();
        var tmpDIV = document.createElement("div");
        var tmpImg = document.createElement("img");

        tmpDIV.id = "divDynamicDate_" + txtIndex;
        

        text.id = "txtDynamicDate_" + txtIndex;
        text.style.width = "65px";
        text.type = "text";
        text.className = "TextBoxRegular";

        
        
        setListOfInputIDs(text.id, inputTypeCode);

        tmpImg.id = "imgDynamicDate_" + txtIndex;
        tmpImg.src = "../Images/Applic/calendarIcon.png";
        tmpImg.style.marginRight = "4px";

        tmpDIV.appendChild(text);
        tmpDIV.appendChild(tmpImg);
        tmpTD.appendChild(tmpDIV);
        tmpTR.appendChild(tmpTD);
        tmpTbody.appendChild(tmpTR);
        tmpTable.appendChild(tmpTbody);

        return tmpTable;
    }

    function getDateTextBox(txtIndex, inputTypeCode, inputValue) {
        var text = document.createElement("input");
        var tmpTable = getTable();
        var tmpTbody = document.createElement("tbody");
        var tmpTR = document.createElement("tr");
        var tmpTD = getTD();
        var tmpDIV = document.createElement("div");
        var tmpImg = document.createElement("img");

        tmpDIV.id = "divDynamicDate_" + txtIndex;
        

        text.id = "txtDynamicDate_" + txtIndex;
        text.style.width = "65px";
        text.type = "text";
        text.className = "TextBoxRegular";
        text.value = inputValue;

        
        
        setListOfInputIDs(text.id, inputTypeCode);

        tmpImg.id = "imgDynamicDate_" + txtIndex;
        tmpImg.src = "../Images/Applic/calendarIcon.png";
        tmpImg.style.marginRight = "4px";

        tmpDIV.appendChild(text);
        tmpDIV.appendChild(tmpImg);
        tmpTD.appendChild(tmpDIV);
        tmpTR.appendChild(tmpTD);
        tmpTbody.appendChild(tmpTR);
        tmpTable.appendChild(tmpTbody);

        return tmpTable;
    }


    function getTD() {
        var tmpTD = document.createElement("td");
        tmpTD.style.padding = 0;
        tmpTD.style.height = 25;
        
        return tmpTD;
    }


    /* Return a table with day type text box */
    function getDayTypeText(txtIndex, inputTypeCode) {
        var text = document.createElement("input");
        var tmpTable = getTable();
        var tmpTbody = document.createElement("tbody");
        var tmpTR = document.createElement("tr");
        var tmpTD = document.createElement("td");
        var tmpImg = document.createElement("img");

        tmpImg.id = "txtImg_" + txtIndex;
        tmpImg.src = "../Images/DDImageDown.bmp";

        
        text.style.width = "50px";
        text.type = "text";
        text.className = "TextBoxRegular";
        text.id = "txtDay_" + txtIndex;
        
        
        setListOfInputIDs(text.id, inputTypeCode);


        tmpTD.style.padding = 0;
        tmpTD.style.height = 20;
        tmpTD.appendChild(text);
        tmpTR.appendChild(tmpTD);

        tmpTD = document.createElement("td");
        tmpTD.rowspan = 2;
        tmpTD.style.padding = 0;
        tmpTD.appendChild(tmpImg);
        tmpTR.appendChild(tmpTD);

        tmpTbody.appendChild(tmpTR);
        tmpTable.appendChild(tmpTbody);

        tmpTR = document.createElement("tr");
        tmpTD = document.createElement("td");

        tmpTD.id = "tdDays_" + txtIndex;
        tmpTR.appendChild(tmpTD);
        tmpTbody.appendChild(tmpTR);
        tmpTable.appendChild(tmpTbody);

        return tmpTable;
    }
    
    function getDayTypeText(txtIndex, inputTypeCode, inputValue) {
        var text = document.createElement("input");
        var tmpTable = getTable();
        var tmpTbody = document.createElement("tbody");
        var tmpTR = document.createElement("tr");
        var tmpTD = document.createElement("td");
        var tmpImg = document.createElement("img");

        tmpImg.id = "txtImg_" + txtIndex;
        tmpImg.src = "../Images/DDImageDown.bmp";

        
        text.style.width = "50px";
        text.type = "text";
        text.className = "TextBoxRegular";
        text.id = "txtDay_" + txtIndex;
        text.value = inputValue;
        
        
        setListOfInputIDs(text.id, inputTypeCode);


        tmpTD.style.padding = 0;
        tmpTD.style.height = 20;
        tmpTD.appendChild(text);
        tmpTR.appendChild(tmpTD);

        tmpTD = document.createElement("td");
        tmpTD.rowspan = 2;
        tmpTD.style.padding = 0;
        tmpTD.appendChild(tmpImg);
        tmpTR.appendChild(tmpTD);

        tmpTbody.appendChild(tmpTR);
        tmpTable.appendChild(tmpTbody);

        tmpTR = document.createElement("tr");
        tmpTD = document.createElement("td");

        tmpTD.id = "tdDays_" + txtIndex;
        tmpTR.appendChild(tmpTD);
        tmpTbody.appendChild(tmpTR);
        tmpTable.appendChild(tmpTbody);

        return tmpTable;
    }

    function setDaysTextEvents() {
        var split = listOfInputID.split("#");

        $.each(split, function () {

            var txtID = this.split("~")[0];
            if (txtID.indexOf("txtDay") > -1) {
                
                $("#" + txtID).focus(function () {
                    backToDateText();
                    checkIfToGetDays(txtID);

                });

                var imgID = txtID.replace("txtDay", "txtImg");
                $("#" + imgID).click(function () {
                    backToDateText();
                    checkIfToGetDays(txtID);

                });
            }
        });
    }

    

    function setHourTextEvents() {
        
        var split = listOfInputID.split("#");
        $.each(split, function () {

            var txtID = this.split("~")[0];
            if (txtID.indexOf("txtDynamicHour") > -1) {
                $("#" + txtID).focus(function () {
                    closeTableDays();
                    backToDateText();
                    setHourMask(txtID, txtID.replace("txtDynamicHour", "divDynamicHour"));
                    

                });

                
            }

        });
    }

    function checkHourValidation(txtID) {
        if ($("#" + txtID).val() != "") {
            var reg = /^(([0-1]?[0-9])|([2][0-3])):([0-5]?[0-9])(:([0-5]?[0-9]))?$/;
            var tdValidID = txtID.replace("txtDynamicHour", "tdHoursNotValid");
            if (reg.test($("#" + txtID).val()) == false) {
                $("#" + tdValidID).show();
                if (notValidObjectsList.indexOf(tdValidID) == -1) {
                    notValidObjectsList += "#" + tdValidID;
                }

            }
            else {

                notValidObjectsList = notValidObjectsList.replace("#" + tdValidID, "");
                $("#" + tdValidID).hide();
            }
        }
    }


    function setDateTextEvents() {
        
        var split = listOfInputID.split("#");
        $.each(split, function () {
            var txtID = this.split("~")[0];
            if (txtID.indexOf("txtDynamicDate") > -1) {
                $("#" + txtID).focus(function () {
                    closeTableDays();
                    setDateMask(txtID, txtID.replace("txtDynamicDate", "divDynamicDate"));

                });
                $("#" + txtID.replace("txtDynamicDate", "imgDynamicDate")).click(function () {
                    closeTableDays();
                    setDateMask(txtID, txtID.replace("txtDynamicDate", "divDynamicDate"));
                    document.getElementById("<%=imgbtnCalendar.ClientID %>").click();

                });
            }
        });
    }


    function setRegularTextEvents() {
        var split = listOfInputID.split("#");
        $.each(split, function () {
            var txtID = this.split("~")[0];
            if (txtID.indexOf("txtRegular") > -1) {
                $("#" + txtID).focus(function () {
                    closeTableDays();
                    backToDateText();
                });
            }
        });
    }


    function setDateMask(txtID, divID) {

        var pos = $("#" + divID).offset();
        var divLeft = pos.left;
        var divTop = pos.top;
        var currVal = $("#" + txtID).val();

        backToDateText();
        currentDateText = txtID;
        
        document.getElementById("divDateMask").style.top = divTop + "px";
        document.getElementById("divDateMask").style.left = divLeft + "px";

        $("#divDateMask").show();
        

        $("#<%=txtDateMask.ClientID %>").val(currVal);
        $("#<%=txtDateMask.ClientID %>").focus();
    }

    function setHourMask(txtID, divID) {
        
        var pos = $("#" + divID).offset();
        var divLeft = pos.left;
        var divTop = pos.top;
        var currVal = $("#" + txtID).val();

        
        currentHourText = txtID;

        document.getElementById("divHoursMask").style.top = divTop + "px";
        document.getElementById("divHoursMask").style.left = divLeft + "px";
        
        $("#divHoursMask").show();


        $("#<%=txtHoursMask.ClientID %>").val(currVal);
        $("#<%=txtHoursMask.ClientID %>").focus();

    }


    function backToHourText() {
        
        if (currentHourText != "") {
            var curVal = $("#<%=txtHoursMask.ClientID %>").val();

            if (curVal != "__:__") {
                $("#" + currentHourText).val(curVal);
            }
            else {
                $("#" + currentHourText).val("");
            }

            $("#divHoursMask").hide();
            checkHourValidation(currentHourText);
        }

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
            alert("לא ניתן לבחור תאריך קטן מתאריך נוכחי");
            sender._selectedDate = new Date();
            // set the date back to the current date
            sender._textbox.set_Value(sender._selectedDate.format(sender._format))
        }
    }

    function checkDate2(sender, args) {
        
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
        //alert(receptionDateFrom);
        var currentDate = new Date();


//        if (receptionDateFrom < currentDate) {
//            alert("לא ניתן לבחור תאריך קטן מתאריך נוכחי");
//            sender._selectedDate = new Date();
//            // set the date back to the current date
//            sender._textbox.set_Value(sender._selectedDate.format(sender._format))
//        }
    }


    function getLastDayOfMonth(_year, _month) {
        
        var dd = new Date(_year, _month, 0);
        return dd.getDate();
        
    }

    function backToDateText() {

        if (currentDateText != "") {
            
            var curVal = $("#<%=txtDateMask.ClientID %>").val();
            if (curVal != "____/__/__") {
                $("#" + currentDateText).val(curVal);
                if (curVal != "") {
                    
                    var date = new Date();
                    
                    var splitDate = curVal.split("/");
                    var day = (splitDate[0].charAt(0) == 0 ? splitDate[0].charAt(1) : splitDate[0]);
                    var month = (splitDate[1].charAt(0) == 0 ? splitDate[1].charAt(1) : splitDate[1]);
                    var year = splitDate[2];
                    var chosenDate = new Date(year, parseInt(month) - 1, day);
                    var today = new Date();
                    var validDay = true;
                    
                    var currMonth = (date.getMonth() + 1) > 9 ? (date.getMonth() + 1) : "0" + (date.getMonth() + 1);
                    var currDay = date.getDate() > 9 ? date.getDate() : "0" + date.getDate();

                    if (month >= 1 && month <= 12) {
                        var lastDayOfMonth = getLastDayOfMonth(year, month);
                        if (day >= 1 && day <= lastDayOfMonth) {
                            today.setHours(0, 0, 0, 0);
                            chosenDate.setHours(0, 0, 0, 0);

//                            if (chosenDate < today) {
//                                alert("לא ניתן לבחור תאריך קטן מתאריך נוכחי");

//                                $("#<%=txtDateMask.ClientID %>").val(currDay + "/" + currMonth + "/" + date.getFullYear());
//                                $("#" + currentDateText).val($("#<%=txtDateMask.ClientID %>").val());

//                            }
                        }
                        else {
                            validDay = false;
                        }
                    }
                    else {
                        validDay = false;
                    }
                    
                    if (!validDay) {
                        alert("התאריך אינו חוקי");

                        $("#<%=txtDateMask.ClientID %>").val(currDay + "/" + currMonth + "/" + date.getFullYear());
                        $("#" + currentDateText).val($("#<%=txtDateMask.ClientID %>").val());

                    }
                }
            }
            else {
                $("#" + currentDateText).val("");
            }
            
        }
        $("#divDateMask").hide();
        
        
    }


    function ViewportWidth() {
        var viewportwidth;
        //var viewportheight;

        // the more standards compliant browsers (mozilla/netscape/opera/IE7) use window.innerWidth and window.innerHeight
        if (typeof window.innerWidth != 'undefined') {
            viewportwidth = window.innerWidth
            //viewportheight = window.innerHeight
        }

        // IE6 in standards compliant mode (i.e. with a valid doctype as the first line in the document)

        else if (typeof document.documentElement != 'undefined'
            && typeof document.documentElement.clientWidth != 'undefined' 
            && document.documentElement.clientWidth != 0) {
            viewportwidth = document.documentElement.clientWidth
            //viewportheight = document.documentElement.clientHeight
        }

        return viewportwidth;
    }
    
    function checkIfToGetDays(objID) {
        var left;
        var top;  
              
        if (tblDaysIsOpen && currentDayText == objID) {
            closeTableDays();

        }
        else {
            
            currentDayText = objID;
            
            var tdID = objID.replace("txtDay", "tdDays");

            var pos = $("#" + tdID).offset();
            var viewportwidth = ViewportWidth();

            if ((viewportwidth - pos.left) < 150)
                left = pos.left - (viewportwidth - pos.left); 
            else
                left = pos.left - 54;
        
            top = pos.top - 2;
            
            setChecks($("#" + currentDayText).val());

            openTableDays(top, left);
            

        }
        document.getElementById(objID).blur();

    }

    function selectedtDaysHasBeenSet() {
        $("#" + currentDayText).val(strSelectedDays);
    }





    
</script>


<selectDays:selectDaysItem runat="server" ID="selectDaysUC"></selectDays:selectDaysItem>
<div id="divHoursMask" style="position:absolute;display:none;z-index:10;">
<asp:TextBox ID="txtHoursMask" runat="server" Width="50px" onblur="backToHourText();" onkeyup="focusNextHour(this, event);"></asp:TextBox>
        <ajaxtoolkit:MaskedEditExtender ID="FromHourExtender" runat="server" ErrorTooltipEnabled="True"
            Mask="99:99" MaskType="Time" TargetControlID="txtHoursMask" Enabled="True">
        </ajaxtoolkit:MaskedEditExtender>
                
</div>

<div id="divDateMask" style="direction:ltr;position:absolute;display:none;z-index:10;width:94px;">
    <ajaxtoolkit:MaskedEditExtender ID="Maskededitextender2" runat="server" AcceptAMPM="false"
        ErrorTooltipEnabled="True" Mask="99/99/9999" MaskType="Date" MessageValidatorTip="true"
        OnFocusCssClass="MaskedEditFocus" OnInvalidCssClass="MaskedEditError" TargetControlID="txtDateMask">
    </ajaxtoolkit:MaskedEditExtender>
    
    <ajaxtoolkit:CalendarExtender ID="Calendarextender2" runat="server" FirstDayOfWeek="Sunday"
        Format="dd/MM/yyyy" PopupButtonID="imgbtnCalendar" OnClientDateSelectionChanged="checkDate2"
        PopupPosition="TopRight" TargetControlID="txtDateMask">
    </ajaxtoolkit:CalendarExtender>
    <asp:ImageButton ID="imgbtnCalendar" runat="server" ImageUrl="~/Images/Applic/calendarIcon.png" />
    <asp:TextBox ID="txtDateMask" runat="server" Width="65px" Height="16px"></asp:TextBox>
</div>