<%@ Reference Page="AdminBasePage.aspx" %>

<%@ Page Title="עדכון הערות לשירות" Language="C#" MasterPageFile="~/SeferMasterPage.master"
    AutoEventWireup="true" Inherits="UpdateEmployeeServiceRemarks"
    UICulture="he-il" Culture="he-il" Codebehind="UpdateEmployeeServiceRemarks.aspx.cs" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<%@ Register Assembly="System.Web.Extensions, Version=1.0.61025.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
    Namespace="System.Web.UI" TagPrefix="asp" %>
<%@ Register src="../UserControls/RemarkClientHandler.ascx" tagname="RemarkClientHandler" tagprefix="uc2" %>
<%@ MasterType VirtualPath="~/SeferMasterPage.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="pageContent" runat="Server">
<script type="text/javascript" src="../Scripts/UpadeRemarkPages.js" defer="defer"></script>

<script language="jscript" type="text/jscript">

    function deleteRow(obj) {
        var toDelete = confirm("האם למחוק הערה זו?");
        if (toDelete) {
                
            var rowID = obj.id.replace("_imgDelete", "");
            var rowIndex = parseInt(rowID.charAt(rowID.length - 1)) - 2;
            var splitID = rowID.split("_");
            var tableID = splitID[0] + "_" + splitID[1] + "_" + splitID[2];

            $("#" + rowID).hide();

                
            if (rowID.indexOf("Current") > -1) {
                if ($("#<%=hfCurrentDeletedRows.ClientID %>").val() == "") {
                    $("#<%=hfCurrentDeletedRows.ClientID %>").val(rowIndex)
                }
                else {
                    $("#<%=hfCurrentDeletedRows.ClientID %>").val($("#<%=hfCurrentDeletedRows.ClientID %>").val() + "," + rowIndex)
                }

                /* Delete the header */
                if (parseInt($("#" + tableID).children("tbody").children("tr").length) -1 == $("#<%=hfCurrentDeletedRows.ClientID %>").val().split(',').length) {
                    $("#" + tableID).children("tbody").children("tr")[0].style.display = "none";
                        
                }
            }
            else {
                if (rowID.indexOf("Future") > -1) {
                    if ($("#<%=hfFutureDeletedRows.ClientID %>").val() == "") {
                        $("#<%=hfFutureDeletedRows.ClientID %>").val(rowIndex)
                    }
                    else {
                        $("#<%=hfFutureDeletedRows.ClientID %>").val($("#<%=hfFutureDeletedRows.ClientID %>").val() + "," + rowIndex)
                    }

                    /* Delete the header */
                    if (parseInt($("#" + tableID).children("tbody").children("tr").length) - 1 == $("#<%=hfFutureDeletedRows.ClientID %>").val().split(',').length) {
                        $("#" + tableID).children("tbody").children("tr")[0].style.display = "none";

                    }
                }
                else {
                    if ($("#<%=hfHistoricDeletedRows.ClientID %>").val() == "") {
                        $("#<%=hfHistoricDeletedRows.ClientID %>").val(rowIndex)
                    }
                    else {
                        $("#<%=hfHistoricDeletedRows.ClientID %>").val($("#<%=hfHistoricDeletedRows.ClientID %>").val() + "," + rowIndex)
                    }

                    /* Delete the header */
                    if (parseInt($("#" + tableID).children("tbody").children("tr").length) - 1 == $("#<%=hfHistoricDeletedRows.ClientID %>").val().split(',').length) {
                        $("#" + tableID).children("tbody").children("tr")[0].style.display = "none";

                    }
                }
            }
        }
    }
        
    function setRemarkText() {
            
        backToDateText();
        if (notValidObjectsList != "") {
            event.returnValue = false;
        }
        else {


            if (listOfInputID != "") {
                var splitList = listOfInputID.split("#");

                $.each(splitList, function () {
                        
                    var hiddenID = "";
                    var rowID = "";
                    var arr = this.split("~");
                    var splitTxtID = arr[0].split("_");


                    hiddenID = arr[0].replace(splitTxtID[splitTxtID.length - 2] + "_" + splitTxtID[splitTxtID.length - 1], "HiddenRemarkMarkup");
                    var hiddenObj = $("#" + hiddenID);

                    if (arr.length == 1) {
                        hiddenObj.val(hiddenObj.val() + $("#" + arr[0]).text());
                    }
                    else {
                        hiddenObj.val(hiddenObj.val() + "#" + $("#" + arr[0]).val() + "~" + arr[1] + "#");
                    }

                });
            }
        }
            
    }
            
    function ShowHistoricRemarks() {

        var trDeptNamesHistory = document.getElementById("trHistoricGrid");
        var btnShowDeptHamesHistory = document.getElementById('<%=btnShowHistoricRemarks.ClientID %>');
        if (trDeptNamesHistory.style.display == "none") {
            trDeptNamesHistory.style.display = "inline";
            btnShowDeptHamesHistory.innerText = "הסתר";
        }
        else {
            trDeptNamesHistory.style.display = "none";
            btnShowDeptHamesHistory.innerText = "הצג";
        }
    }

    function onfocusoutFromDate(txtName) {
        var txtFromDate = document.getElementById(txtName);
        if (txtFromDate.value == '__/__/____')
            txtFromDate.value = '<%=DateTime.Today.ToShortDateString() %>';
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

    function disableSaveButtons() {
        document.getElementById('<%=btnSaveChangesUp.ClientID %>').disabled = true;
        document.getElementById('<%=btnSaveChanges.ClientID %>').disabled = true;
    }

    function SetActiveFrom(txtValidFrom, txtActiveFrom, ShowForPreviousDays) {
        document.getElementById(txtActiveFrom).value = GetActiveFromDate(document.getElementById(txtValidFrom).value, ShowForPreviousDays);
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
</script>

<table id="AllScreen" border="0" width="985px">
    <tr>
        <td style="padding-top: 5px;" align="left">
            <table cellpadding="0" cellspacing="0" style="background-color: #298AE5; height: 30px;"
                width="100%">
                <tr>
                    <td align="left" style="width: 100%">
                        <table cellpadding="0" cellspacing="0" dir="rtl">
                            <tr>
                                <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                    background-position: bottom left;">
                                    &nbsp;
                                </td>
                                <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                    background-repeat: repeat-x; background-position: bottom;">
                                    <asp:Button ID="btnSaveChangesUp" runat="server" Text="שמירה" CssClass="RegularUpdateButton"
                                        Width="50px" ValidationGroup="vldDates" OnClick="UpdateRows" OnClientClick="if(AllRowsAreValid()){setRemarkText(); showProgressBarGeneral('0'); setTimeout(disableSaveButtons, 100);} else {return false;}"></asp:Button>
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
                                    <asp:Button ID="BtnCancelUp" runat="server" Text="ביטול" CssClass="RegularUpdateButton"
                                        CausesValidation="false" Width="50px" OnClick="CancelUpdate"></asp:Button>
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
    <tr id="trGrids">
        <td id="tdGrids">
            <div style="height: 500px; overflow: auto; padding: 2px; direction: ltr" class="ScrollBarDiv">
                <table id="tblGrid" border="0" dir="rtl">
                    <tr>
                        <td style="padding-right: 10px">
                            <table id="tblCurrentRemarks" border="0" width="950px">
                                <tr>
                                    <td class="GridViewHeader">
                                        הערות בתוקף
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:GridView ID="gvCurrentRemarks" runat="server" Width="100%" AutoGenerateColumns="false" ShowHeader="False"
                                            OnRowDataBound="gvRemarks_RowDataBound" HeaderStyle-Height="0" RowStyle-VerticalAlign="Top"
                                            EnableViewState="true" SkinID="GridViewForUpdatePage" HeaderStyle-CssClass="GridViewColumnHeader">
                                            <Columns>
                                                <asp:TemplateField HeaderText="" Visible="false">
                                                    <ItemTemplate>
                                                        <asp:Label ID="lblRecordType" runat="server" Text='<%# Eval("RecordType") %>' />
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="" Visible="false">
                                                    <ItemTemplate>
                                                        <asp:Label ID="lblRemarkID" runat="server" Text='<%# Eval("RemarkID") %>' />
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="Remark Text" Visible="false">
                                                    <ItemTemplate>
                                                        <asp:Label ID="lblRemarkText" runat="server" Text='<%# Eval("RemarkText") %>' />
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="" Visible="false">
                                                    <ItemTemplate>
                                                        <asp:Label ID="lblRemarkTemplate" runat="server" Text='<%# Eval("RemarkTemplate") %>' />
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="" ItemStyle-Width="950px">
                                                    <ItemTemplate>
                                                        <table border="0" dir="rtl">
                                                            <tr>
                                                                <td style="width:800px;padding-right:40px; padding-top:3px; border-top:2px solid Gray; border-right:3px solid Gray; background-color:#EEEEEE">
                                                                <div style="width:780px; white-space:nowrap">
                                                                    <div style="float:right;">
                                                                        <asp:Label ID="lblFromDate" runat="server" EnableTheming="false" CssClass="GridViewHeader" Text="בתוקף מ:"></asp:Label>
                                                                    </div>
                                                                    <div style="direction:ltr;float:right; padding-right:10px;">
                                                                        <asp:ImageButton ImageUrl="~/Images/Applic/calendarIcon.png" ID="btnRunCalendar_Date"
                                                                            runat="server" />
                                                                        <asp:TextBox ID="txtValidFrom" Width="70px" runat="server" Text='<%# Bind("ValidFrom","{0:d}") %>'></asp:TextBox>
                                                                        <ajaxToolkit:CalendarExtender ID="calExtValidFrom" runat="server" Format="dd/MM/yyyy"
                                                                            FirstDayOfWeek="Sunday" TargetControlID="txtValidFrom" PopupPosition="BottomRight"
                                                                            PopupButtonID="btnRunCalendar_Date" OnClientDateSelectionChanged="checkDate">
                                                                        </ajaxToolkit:CalendarExtender>
                                                                        <ajaxToolkit:MaskedEditExtender ID="DateExtender" runat="server" AcceptAMPM="false"
                                                                            ClearMaskOnLostFocus="false" ErrorTooltipEnabled="True" Mask="99/99/9999" MaskType="Date"
                                                                            MessageValidatorTip="true" OnFocusCssClass="MaskedEditFocus" OnInvalidCssClass="MaskedEditError"
                                                                            TargetControlID="txtValidFrom">
                                                                        </ajaxToolkit:MaskedEditExtender>
                                                                    </div>
                                                                    <div style="float:right; padding-right:15px;">
                                                                    <asp:Label ID="lblToDate" runat="server" EnableTheming="false" CssClass="GridViewHeader" Text="בתוקף עד:"></asp:Label>
                                                                    </div>
                                                                    <div style="direction:ltr;float:right; padding-right:5px;">
                                                                        <asp:ImageButton ImageUrl="~/Images/Applic/calendarIcon.png" ID="btnRunCalendar_Date2"
                                                                            runat="server" />
                                                                        <asp:TextBox ID="txtValidTo" Width="70px" runat="server" Text='<%# Bind("ValidTo","{0:d}") %>'></asp:TextBox>
                                                                        <ajaxToolkit:CalendarExtender ID="calExtValidTo" runat="server" Format="dd/MM/yyyy"
                                                                            FirstDayOfWeek="Sunday" TargetControlID="txtValidTo" PopupPosition="BottomRight"
                                                                            PopupButtonID="btnRunCalendar_Date2">
                                                                        </ajaxToolkit:CalendarExtender>
                                                                        <ajaxToolkit:MaskedEditExtender ID="DateExtender2" runat="server" AcceptAMPM="false"
                                                                            ErrorTooltipEnabled="True" Mask="99/99/9999" MaskType="Date" MessageValidatorTip="true"
                                                                            OnFocusCssClass="MaskedEditFocus" OnInvalidCssClass="MaskedEditError" TargetControlID="txtValidTo">
                                                                        </ajaxToolkit:MaskedEditExtender>
                                                                    </div>
                                                                    <div style="float:right; padding-right:20px;">
                                                                        <asp:Label ID="lblActiveFrom" runat="server" EnableTheming="false" CssClass="GridViewHeader" Text="מוצג מתאריך:"></asp:Label>
                                                                    </div>
                                                                    <div style="float:right; padding-right:10px;">
                                                                        <asp:TextBox ID="txtActiveFrom" Width="70px" runat="server" Text='<%# Bind("ActiveFrom","{0:d}") %>'></asp:TextBox>
                                                                        <asp:ImageButton ImageUrl="~/Images/Applic/calendarIcon.png" ID="btnCalendarActiveFrom" runat="server" />
                                                                        <ajaxToolkit:CalendarExtender ID="calExtActiveFrom" runat="server" Format="dd/MM/yyyy"
                                                                            FirstDayOfWeek="Sunday" TargetControlID="txtActiveFrom" PopupPosition="BottomRight" PopupButtonID="btnCalendarActiveFrom">
                                                                        </ajaxToolkit:CalendarExtender>
                                                                        <ajaxToolkit:MaskedEditExtender ID="DateExtender3" runat="server" AcceptAMPM="false"
                                                                            ErrorTooltipEnabled="True" Mask="99/99/9999" MaskType="Date" MessageValidatorTip="true"
                                                                            OnFocusCssClass="MaskedEditFocus" OnInvalidCssClass="MaskedEditError" TargetControlID="txtActiveFrom">
                                                                        </ajaxToolkit:MaskedEditExtender>
                                                                    </div>
                                                                    <div style="float:right; padding-right:10px; width:160px">
                                                                        <asp:HiddenField ID="hdnRemarkID" runat="server" Value='<%# Eval("RemarkID") %>' />
                                                                    </div>
                                                                </div>
                                                                </td>
                                                                <td style="background-color:#EEEEEE;border-top:2px solid Gray;">
                                                                    <asp:Label ID="lblInternetDisplay" runat="server" EnableTheming="false" CssClass="GridViewHeader" Text="באינטרנט"></asp:Label>
                                                                </td>
                                                                <td style="background-color:#EEEEEE;border-top:2px solid Gray;">
                                                                    <asp:CheckBox ID="chkInternetDisplay" runat="server" Checked="false" />
                                                                </td>
                                                                <td style="padding-left:5px; background-color:#EEEEEE;border-top:2px solid Gray; border-left:2px solid Gray;">
                                                                    <img id="imgDelete" runat="server" alt="" style="border: 0;cursor:pointer;" src="../Images/Applic/btn_X_red.gif" onclick="deleteRow(this);" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td colspan="4" style="width:950px;padding-right:10px;border-bottom:3px solid Gray; border-right:3px solid Gray; border-left:2px solid Gray">
                                                                    <asp:Panel runat="server" ID="remarkPanel" Width="900px" ></asp:Panel>
                                                                    <input type="hidden" runat="server" id="HiddenRemarkMarkup" value="" />
                                                                    <asp:Label ID="lblRemarkTextToShow" runat="server" EnableTheming="false" Visible="false"
                                                                        CssClass="RegularLabelNormal" Text="" />

                                                                </td>
                                                            </tr>
                                                        </table>
                                                        <br />
                                                    </ItemTemplate>
                                                </asp:TemplateField>

                                                <asp:BoundField DataField="Deleted" ItemStyle-Width="0px">
                                                    <ItemStyle CssClass="DisplayNone" />
                                                    <HeaderStyle CssClass="DisplayNone" />
                                                </asp:BoundField>

                                            </Columns>
                                        </asp:GridView>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding-right: 10px">
                            <table id="tblFutureRemarks" border="0" width="950px">
                                <tr>
                                    <td class="GridViewHeader">
                                        הערות עתידיות
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:GridView ID="gvFutureRemarks" runat="server" Width="100%" AutoGenerateColumns="false" ShowHeader="False"
                                            OnRowDataBound="gvRemarks_RowDataBound" RowStyle-VerticalAlign="Top" HeaderStyle-Height="0"
                                            EnableViewState="true" SkinID="GridViewForUpdatePage" HeaderStyle-CssClass="GridViewColumnHeader">
                                            <Columns>
                                                <asp:TemplateField HeaderText="" Visible="false">
                                                    <ItemTemplate>
                                                        <asp:Label ID="lblRecordType" runat="server" Text='<%# Eval("RecordType") %>' />
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="" Visible="false">
                                                    <ItemTemplate>
                                                        <asp:Label ID="lblRemarkID" runat="server" Text='<%# Eval("RemarkID") %>' />
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="" Visible="false">
                                                    <ItemTemplate>
                                                        <asp:Label ID="lblRemarkText" runat="server" Text='<%# Eval("RemarkText") %>' />
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="" Visible="false">
                                                    <ItemTemplate>
                                                        <asp:Label ID="lblRemarkTemplate" runat="server" Text='<%# Eval("RemarkTemplate") %>' />
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="" ItemStyle-Width="950px">
                                                    <ItemTemplate>
                                                        <table border="0" dir="rtl">
                                                            <tr>
                                                                <td style="width:800px;padding-right:40px; padding-top:3px; border-top:2px solid Gray; border-right:3px solid Gray; background-color:#EEEEEE">
                                                                <div style="width:780px; white-space:nowrap">
                                                                    <div style="float:right;">
                                                                        <asp:Label ID="lblFromDate" runat="server" EnableTheming="false" CssClass="GridViewHeader" Text="בתוקף מ:"></asp:Label>
                                                                    </div>
                                                                    <div style="direction:ltr;float:right; padding-right:10px;">

                                                                        <asp:ImageButton ImageUrl="~/Images/Applic/calendarIcon.png" ID="btnRunCalendar_Date"
                                                                            runat="server" />
                                                                        <asp:TextBox ID="txtValidFrom" Width="70px" runat="server" Text='<%# Bind("ValidFrom","{0:d}") %>'></asp:TextBox>
                                                                        <ajaxToolkit:CalendarExtender ID="calExtValidFrom" runat="server" Format="dd/MM/yyyy"
                                                                            FirstDayOfWeek="Sunday" TargetControlID="txtValidFrom" PopupPosition="BottomRight"
                                                                            PopupButtonID="btnRunCalendar_Date">
                                                                        </ajaxToolkit:CalendarExtender>
                                                                        <ajaxToolkit:MaskedEditExtender ID="DateExtender7" runat="server" AcceptAMPM="false"
                                                                            ErrorTooltipEnabled="True" Mask="99/99/9999" MaskType="Date" MessageValidatorTip="true"
                                                                            OnFocusCssClass="MaskedEditFocus" OnInvalidCssClass="MaskedEditError" TargetControlID="txtValidFrom">
                                                                        </ajaxToolkit:MaskedEditExtender>
                                                                    </div>
                                                                    <div style="float:right; padding-right:15px;">
                                                                    <asp:Label ID="lblToDate" runat="server" EnableTheming="false" CssClass="GridViewHeader" Text="בתוקף עד:"></asp:Label>
                                                                    </div>
                                                                    <div style="direction:ltr;float:right; padding-right:5px;">

                                                                        <asp:ImageButton ImageUrl="~/Images/Applic/calendarIcon.png" ID="btnRunCalendar_Date2"
                                                                            runat="server" />
                                                                        <asp:TextBox ID="txtValidTo" Width="70px" runat="server" Text='<%# Bind("ValidTo","{0:d}") %>'></asp:TextBox>
                                                                        <ajaxToolkit:CalendarExtender ID="calExtValidTo" runat="server" Format="dd/MM/yyyy"
                                                                            FirstDayOfWeek="Sunday" TargetControlID="txtValidTo" PopupPosition="BottomRight"
                                                                            PopupButtonID="btnRunCalendar_Date2">
                                                                        </ajaxToolkit:CalendarExtender>
                                                                        <ajaxToolkit:MaskedEditExtender ID="DateExtender8" runat="server" AcceptAMPM="false"
                                                                            ErrorTooltipEnabled="True" Mask="99/99/9999" MaskType="Date" MessageValidatorTip="true"
                                                                            OnFocusCssClass="MaskedEditFocus" OnInvalidCssClass="MaskedEditError" TargetControlID="txtValidTo">
                                                                        </ajaxToolkit:MaskedEditExtender>
                                                                    </div>
                                                                    <div style="float:right; padding-right:20px;">
                                                                        <asp:Label ID="lblActiveFrom" runat="server" EnableTheming="false" CssClass="GridViewHeader" Text="מוצג מתאריך:"></asp:Label>
                                                                    </div>
                                                                    <div style="float:right; padding-right:20px;">
                                                                        <asp:TextBox ID="txtActiveFrom" Width="70px" runat="server" Text='<%# Bind("ActiveFrom","{0:d}") %>' ReadOnly="true"></asp:TextBox>
                                                                        <asp:ImageButton ImageUrl="~/Images/Applic/calendarIcon.png" ID="btnCalendarActiveFrom" runat="server" />
                                                                        <ajaxToolkit:CalendarExtender ID="calExtActiveFrom" runat="server" Format="dd/MM/yyyy"
                                                                            FirstDayOfWeek="Sunday" TargetControlID="txtActiveFrom" PopupPosition="BottomRight" PopupButtonID="btnCalendarActiveFrom">
                                                                        </ajaxToolkit:CalendarExtender>
                                                                        <ajaxToolkit:MaskedEditExtender ID="DateExtender3" runat="server" AcceptAMPM="false"
                                                                            ErrorTooltipEnabled="True" Mask="99/99/9999" MaskType="Date" MessageValidatorTip="true"
                                                                            OnFocusCssClass="MaskedEditFocus" OnInvalidCssClass="MaskedEditError" TargetControlID="txtActiveFrom">
                                                                        </ajaxToolkit:MaskedEditExtender>
                                                                    </div>
                                                                    <div style="float:right; padding-right:20px;">
                                                                        <asp:Label ID="lblEmployeeDepts" runat="server" EnableTheming="false" CssClass="GridViewHeader" Text="ביחידה:"></asp:Label>
                                                                    </div>
                                                                    <div style="float:right; padding-right:10px; width:160px">
                                                                        <asp:HiddenField ID="hdnRemarkID" runat="server" Value='<%# Eval("RemarkID") %>' />
                                                                    </div>
                                                                </div>
                                                                </td>
                                                                <td style="background-color:#EEEEEE;border-top:2px solid Gray;">
                                                                    <asp:Label ID="lblInternetDisplay" runat="server" EnableTheming="false" CssClass="GridViewHeader" Text="באינטרנט"></asp:Label>
                                                                </td>
                                                                <td style="background-color:#EEEEEE;border-top:2px solid Gray;">
                                                                    <asp:CheckBox ID="chkInternetDisplay" runat="server" Checked="false" />
                                                                </td>
                                                                <td style="padding-left:5px; background-color:#EEEEEE;border-top:2px solid Gray; border-left:2px solid Gray;">
                                                                    <img id="imgDelete" runat="server" alt="" style="border: 0;cursor:pointer;" src="../Images/Applic/btn_X_red.gif" onclick="deleteRow(this);" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td colspan="4" style="width:950px;padding-right:10px;border-bottom:3px solid Gray; border-right:3px solid Gray; border-left:2px solid Gray">
                                                                    <asp:Panel runat="server" ID="remarkPanel" Width="900px"></asp:Panel>
                                                                    <input type="hidden" runat="server" id="HiddenRemarkMarkup" value="" />
                                                                    <asp:Label ID="lblRemarkTextToShow" runat="server" EnableTheming="false" Visible="false"
                                                                        CssClass="RegularLabelNormal" Text="" />
                                                                </td>
                                                            </tr>
                                                        <br />
                                                    </ItemTemplate>
                                                </asp:TemplateField>

                                                <asp:BoundField DataField="Deleted" ItemStyle-Width="0px">
                                                    <ItemStyle CssClass="DisplayNone" />
                                                    <HeaderStyle CssClass="DisplayNone" />
                                                </asp:BoundField>
                                            </Columns>
                                        </asp:GridView>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
                <!-- TblGrids -->
            </div>
        </td>
        <!-- TDGrids -->
    </tr>
    <!-- TRGrids -->
    <tr>
        <td class="GridViewHeader" dir="rtl" style="padding-right: 30px; padding-top: 15px">
            הערות היסטוריות
            <asp:LinkButton ID="btnShowHistoricRemarks" OnClientClick="ShowHistoricRemarks(); return false"
                CssClass="LinkButtonBoldBlue" runat="server" Text="הצג"></asp:LinkButton>
        </td>
    </tr>
    <tr id="trHistoricGrid" style="display: none;">
        <td>
            <div style="height: 150px; overflow: auto; direction: ltr;text-align:right">
                <table id="tblHistoricRemarks" width="960px" dir="rtl" border="0" style="margin-right:23px">
                    <tr>
                        <td>
                            <asp:GridView ID="gvHistoricRemarks" runat="server" Width="100%" AutoGenerateColumns="false"
                                OnRowDataBound="gvHistoricRemarks_RowDataBound"  RowStyle-VerticalAlign="Top" HeaderStyle-Height="30" 
                                EnableViewState="true" SkinID="GridViewForUpdatePage" HeaderStyle-CssClass="GridViewColumnHeader">
                                <Columns>
                                    <asp:TemplateField HeaderText="" Visible="false">
                                        <ItemTemplate>
                                            <asp:Label ID="lblRemarkID" runat="server" Text='<%# Eval("RemarkID") %>' />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="" ItemStyle-Width="400px">
                                        <ItemTemplate>
                                            <input type="hidden" runat="server" id="HiddenRemarkMarkup" value="" />
                                            <asp:Label ID="lblRemarkTextToShow" runat="server" EnableTheming="false" 
                                                CssClass="RegularLabelNormal" Text='<%# Eval("RemarkTextFormated") %>' />
                                            <br />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="בתוקף מ" ItemStyle-HorizontalAlign="Right">
                                        <ItemTemplate>
                                            <div style="direction:ltr;width:75px;">
                                                <asp:TextBox ID="txtHistoricValidFrom" Width="70px" runat="server" Text='<%# Bind("ValidFrom","{0:d}") %>' Visible="false"></asp:TextBox>
                                                <asp:Label ID="lblHistoricValidFrom" runat="server" EnableTheming="false" 
                                                CssClass="RegularLabelNormal" Text='<%# Eval("ValidFrom","{0:d}") %>' />
                                            </div>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="בתוקף עד" ItemStyle-HorizontalAlign="Right">
                                        <ItemTemplate>
                                            <div style="direction:ltr;width:75px;">
                                                <asp:TextBox ID="txtHistoricValidTo" Width="70px" runat="server" Text='<%# Bind("ValidTo","{0:d}") %>' Visible="false"></asp:TextBox>
                                                <asp:Label ID="lblHistoricValidTo" runat="server" EnableTheming="false" 
                                                CssClass="RegularLabelNormal" Text='<%# Eval("ValidTo","{0:d}") %>' />
                                                </div>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="מוצג מתאריך">
                                        <ItemTemplate>
                                            <div style="direction:ltr;width:80px;">
                                                <asp:TextBox ID="txtActiveFrom" Width="70px" runat="server" Text='<%# Bind("ActiveFrom","{0:d}") %>' ReadOnly="true"></asp:TextBox>
                                            </div>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="ביחידה">
                                        <ItemTemplate>
                                            <asp:HiddenField ID="hdnRemarkID" runat="server" Value='<%# Eval("RemarkID") %>' />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="באינטרנט">
                                        <ItemTemplate>
                                            <asp:CheckBox ID="chkInternetDisplay" runat="server" Checked="false" Enabled="false" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="Deleted" ItemStyle-Width="0px">
                                        <ItemStyle CssClass="DisplayNone" />
                                        <HeaderStyle CssClass="DisplayNone" />
                                    </asp:BoundField>
                                    <asp:TemplateField HeaderText="">
                                        <ItemTemplate>
                                            <img id="imgDelete" runat="server" alt="" style="border: 0;cursor:pointer;" src="../Images/Applic/btn_X_red.gif" onclick="deleteRow(this);" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </td>
                    </tr>
                </table>
            </div>
        </td>
        <!-- TDHistoric-->
    </tr>
    <!-- TRHistoric-->
    <tr>
        <td style="padding-top: 5px;" align="left">
            <table cellpadding="0" cellspacing="0" style="background-color: #298AE5; height: 30px;"
                width="100%">
                <tr>
                    <td align="left" style="width: 100%">
                        <table cellpadding="0" cellspacing="0" dir="rtl">
                            <tr>
                                <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                    background-position: bottom left;">
                                    &nbsp;
                                </td>
                                <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                    background-repeat: repeat-x; background-position: bottom;">
                                    <asp:Button ID="btnSaveChanges" runat="server" Text="שמירה" CssClass="RegularUpdateButton"
                                        Width="50px" ValidationGroup="vldDates" OnClick="UpdateRows" OnClientClick="if(AllRowsAreValid()){setRemarkText(); showProgressBarGeneral('0'); setTimeout(disableSaveButtons, 100);} else {return false;}"></asp:Button>
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
                                    <asp:Button ID="BtnCancel" runat="server" Text="ביטול" CssClass="RegularUpdateButton"
                                        CausesValidation="false" Width="50px" OnClick="CancelUpdate"></asp:Button>
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
        
    <asp:HiddenField ID="hfCurrentDeletedRows" runat="server" />
    <asp:HiddenField ID="hfFutureDeletedRows" runat="server" />
    <asp:HiddenField ID="hfHistoricDeletedRows" runat="server" />
</table>
<uc2:RemarkClientHandler ID="RemarkClientHandler1" runat="server" />
<script type="text/javascript">
        
    listOfInputID = "<%=ListOfInputID %>";

    setDaysTextEvents();
    setHourTextEvents();
    setDateTextEvents();
    setRegularTextEvents();
</script>
</asp:Content>
