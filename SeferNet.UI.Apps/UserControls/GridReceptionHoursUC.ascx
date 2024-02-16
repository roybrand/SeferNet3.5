<%@ Control Language="C#" AutoEventWireup="true"
    Inherits="UserControls_GridReceptionHoursUC" Codebehind="GridReceptionHoursUC.ascx.cs" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagPrefix="MultiDDlSelect_UC" TagName="MultiDDlSelect_UCItem" Src="~/UserControls/MultiDDlSelect.ascx" %>
<%@ Register TagPrefix="MultiDDlSelect_UCDays" TagName="MultiDDlSelect_UCItemDays" Src="~/UserControls/MultiDDlSelectUC.ascx" %>

<link href="../CSS/General/general.css" type="text/css" rel="stylesheet" />

<script type="text/javascript" src="../Scripts/BrowserVersions.js"></script>

<script type="text/javascript" src="../Scripts/Applic/General.js"></script>

<script type="text/javascript" src="../Scripts/LoadJqueryIfNeeded.js"></script>

<script type="text/javascript">
    
    //large GridView has low performance if it is in Update panel
    //this  is solution
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

    function validateHours(val, args) {
        var flag = "";

        var closingTime = $('#' + val.id).closest("tr").find("input:text[id$='txtToHour']").val();
        var closingTimeArr = closingTime.split(':');
        var ToHour = closingTimeArr[0];

        if (ToHour == "00")
            ToHour = "24";

        var fromHourID = $('#' + val.id).closest("tr").find("input:text[id$='txtToHour']").attr('id');
        fromHourID = fromHourID.replace('txtToHour', 'txtFromHour');

        var openingTime = $('#' + fromHourID).val();
        var openingTimeArr = openingTime.split(':');

        var FromHour = openingTimeArr[0];
        var FromMinute = openingTimeArr[1];

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

        if (receptionDateFrom < receptionDateTo || flag == "1")
            args.IsValid = true;
        else
            args.IsValid = false;
    }

    function clearRemark() {

        var inpTitleRemark = document.getElementById('inpTitleRemark');

        var hdnRemarkText = document.getElementById('<%=this.HdnRemarkText %>');
        hdnRemarkText.value = "";

        var hdnRemarkMask = document.getElementById('<%=this.HdnRemarkMask %>');
        hdnRemarkMask.value = "";

        var hdnRemarkID = document.getElementById('<%=this.HdnRemarkID %>');
        hdnRemarkID.value = "";

        if (inpTitleRemark != null)
            inpTitleRemark.value = "";
    }

    function OpenRemarkWindowDialog(remarkType, mode, ctrl) {

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
                + "&RemarkText=" + escape(hdnRemarkMask.value) +
                +"&title=1";
            url += "&mode=header";
        }
        else if (mode == 'edit') {

        
            var remarkNum = document.getElementById('<%= hdnRemarkID_E.ClientID %>');
            var remarkMask = document.getElementById('<%= hdnRemarkMask_E.ClientID %>');

            if (remarkNum != null) {
                url = "../Admin/AddRemark.aspx?RemarkType=" + remarkType
                + "&RemarkID=" + remarkNum.value
                + "&RemarkText=" + escape(remarkMask.value) +
                    "&title=1";
                url += "&mode=edit";
            }
        }

        OpenJQueryDialog(url, dialogWidth, dialogHeight, title);
        return false;

    }

    function SetRemark() {
        //---- after AddRemark dialog closed
        var headerOrEditMode = document.getElementById('<%=txtWherePutRemark.ClientID %>').value;

        var selectedRemark = document.getElementById("<%=txtSelectedRemark_FromDialog.ClientID %>").value;
        var selectedRemarkMask = document.getElementById('<%=txtSelectedRemarkMask_FromDialog.ClientID %>').value;
        var selectedRemarkID = document.getElementById('<%=txtSelectedRemarkID_FromDialog.ClientID %>').value;

        var ctrl_Coused_OpenRemarkWindowDialog_id = ""; //

        if (headerOrEditMode == 'header') {

            ctrl_Coused_OpenRemarkWindowDialog_id = "btnUnitTypeListPopUpHeader";

            //txtRemarkID = $('#<%=dgReceptionHours.ClientID %>').find("input[id$='inpTitleRemark']").attr('id');
            txtRemarkID = $('#' + ctrl_Coused_OpenRemarkWindowDialog_id).closest("tr").find("input[id$='inpTitleRemark']").attr('id');
            
            var hdnRemarkText = document.getElementById('<%=this.HdnRemarkText %>');
            //hdnRemarkText.value = escape(selectedRemark);
            hdnRemarkText.value = selectedRemark;

            var hdnRemarkMask = document.getElementById('<%=this.HdnRemarkMask %>');
            //hdnRemarkMask.value = escape(selectedRemarkMask);
            hdnRemarkMask.value = selectedRemarkMask;

            var hdnRemarkID = document.getElementById('<%=this.HdnRemarkID %>');
            hdnRemarkID.value = selectedRemarkID;

            //Within the included web resource and the WebUIValidation.js is a method we need to call, 
            //the Page_ClientValidate , which is a method that is used to test if all controls meet
            //the validation criteria that have been assigned to them.
            Page_ClientValidate('vldGrAdd');
        }
        else if (headerOrEditMode == 'edit') {

            ctrl_Coused_OpenRemarkWindowDialog_id = "btnUnitTypeListPopUp";

            hdnRemarkText = document.getElementById('<%= hdnRemarkText_E.ClientID %>');
            hdnRemarkText.value = selectedRemark;

            var hdnRemarkMask = document.getElementById('<%= hdnRemarkMask_E.ClientID %>');
            hdnRemarkMask.value = selectedRemarkMask;

            var hdnRemarkID = document.getElementById('<%= hdnRemarkID_E.ClientID %>');
            hdnRemarkID.value = selectedRemarkID;

            var lblRemarkMask_E_c = document.getElementsByName('lblRemarkMask_E_c');
            var lblRemarkMask_E = document.getElementsByName('lblRemarkMask_E');
            var lblRemarkID_E = document.getElementsByName('lblRemarkID_E');

            //txtRemarkID = $('#' + ctrl.id).closest("tr").find("input[id$='lblRemarkText_E']").attr('id');
            txtRemarkID = $('#' + ctrl_Coused_OpenRemarkWindowDialog_id).closest("tr").find("input[id$='lblRemarkText_E']").attr('id');

            //Within the included web resource and the WebUIValidation.js is a method we need to call, 
            //the Page_ClientValidate , which is a method that is used to test if all controls meet
            //the validation criteria that have been assigned to them.
            Page_ClientValidate('vldGrEdit');

        }

        //$('#' + ctrl.id).closest("tr").find("[id$='" + txtRemarkID + "']").val(selectedRemark);
        //$('#' + ctrl.id).closest("tr").find("[id$='" + txtRemarkID + "']").attr('title', selectedRemark);

        $('#' + ctrl_Coused_OpenRemarkWindowDialog_id).closest("tr").find("[id$='" + txtRemarkID + "']").val(selectedRemark);
        $('#' + ctrl_Coused_OpenRemarkWindowDialog_id).closest("tr").find("[id$='" + txtRemarkID + "']").attr('title', selectedRemark);


        //if (inpTitleRemark != null)
        //    inpTitleRemark.value = selectedRemark;
}

    function ClearRemarkIfEmpty(ctrl) {
        txtRemarkID = $('#' + ctrl.id).closest("tr").find("input[id$='lblRemarkText_E']").attr('id');
        txtRemark = document.getElementById(txtRemarkID);
        if (txtRemark.value == '') {
            hdnRemarkText = document.getElementById('<%= hdnRemarkText_E.ClientID %>');
            hdnRemarkText.value = '';

            var hdnRemarkMask = document.getElementById('<%= hdnRemarkMask_E.ClientID %>');
            hdnRemarkMask.value = '';

            var hdnRemarkID = document.getElementById('<%= hdnRemarkID_E.ClientID %>');
            hdnRemarkID.value = '';
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
            alert(".לא ניתן לבחור תאריך קטן מתאריך נוכחי");
            sender._selectedDate = new Date();
            // set the date back to the current date
            sender._textbox.set_Value(sender._selectedDate.format(sender._format))
        }
        
        validateTime(null, sender);
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

            from = $('#' + val.id).closest("table").parent().parent().find("input:text[id$='txtFromDate']").val()

            to = $('#' + val.id).closest("tr").find("input:text[id$='txtToDate']").val()



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
            if (receptionDateFrom <= receptionDateTo)
                args.IsValid = true;
            else
                args.IsValid = false;
        }

        validateTime(null, from);
    }

    function validateTime(event, sender, nextField) {

        let button;
        let elementNameArray;

        let defaultElementId;

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

        setError(fromElement, false);
        setError(toElement, false);
        
        setButton(button, false);

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
            if (remark.title != 'למחרת') {
            setError(fromElement, true);
            setError(toElement, true);
                return false;
            }
        }

        if (event != null) FocusNextFieldIfNeeded(element, nextField, event)

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
        if(isSet){
            element.style.backgroundColor ='#FD8989';
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

        if(elementNameArray[4] == 'ctl01') {
            remarkNameArray = [...elementNameArray.slice(0, elementNameArray.length - 1), 'inpTitleRemark'];
        }
        else {
            remarkNameArray = [...elementNameArray.slice(0, elementNameArray.length - 1), 'lblRemarkText_E'];
        }

        return document.getElementById(remarkNameArray.join('_'));
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

<script type="text/javascript">

    function ConfirmExpirationDate() {
        //var message = "הוזנו שעות חופפות לשירות באותה היחידה.\n האם לאשר עדכון תוקף לשעות הקיימות והוספת שעות קבלה חדשות ?";
        //result = window.confirm(message);

        var topi = 50;
        var lefti = 100;
        var features = "top:" + topi + "px;left:" + lefti + "px; dialogWidth:340px; dialogheight:200px; help:no; status:no;scroll:no ";

        var obj = window.showModalDialog("../Admin/ConfirmHoursOverlapping.aspx", "ConfirmWindow", features);
        if (obj != null) {
            if (obj.Continue == true)
                result = true;
        }
        else {
            result = false;
        }

        if (!result) {
            document.getElementById('<%=hdnAgreedToChangeOverlappedHoursExpiration.ClientID %>').value = 0;
        }
        else {
            document.getElementById('<%=hdnAgreedToChangeOverlappedHoursExpiration.ClientID %>').value = 1;
        }

        //documet.getElementById("ctl00_pageContent_gvReceptionHours_dgReceptionHours_ctl01_imgPostBack").click();
        document.getElementById('<%=imgPostBack.ClientID %>').click();
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

    .calendar {
        border: 1px solid blue;
        background-color: antiquewhite;
        color: blueviolet;
    }

</style>

<asp:UpdatePanel runat="server" ID="UpdPanelHours" UpdateMode="Always">
    <ContentTemplate>
        <asp:GridView ID="dgReceptionHours" runat="server" dir="rtl" AutoGenerateColumns="False"
            GridLines="Both" AllowSorting="True" ShowFooter="false" EnableTheming="true"
            BorderWidth="1px" OnRowDataBound="dgReceptionHours_RowDataBound" OnRowCancelingEdit="dgReceptionHours_RowCancelingEdit"
            OnRowDeleted="dgReceptionHours_RowDeleted" OnRowDeleting="dgReceptionHours_RowDeleting"
            OnRowEditing="dgReceptionHours_RowEdit" meta:resourcekey="dgReceptionHoursResource1"
            Width="980px">
            <Columns>
                <%--Hidden column --%>
                <asp:TemplateField Visible="false">
                    <ItemTemplate>
                        <asp:Label ID="lblDeptCode" runat="server" Text='<%# Eval("DeptCode") %>'></asp:Label>
                        <asp:Label ID="lblItemsCodes" runat="server" Text='<%# Eval("ItemId") %>'></asp:Label>
                        <asp:Label ID="lblDays2" runat="server" Text='<%# Eval("ReceptionDay") %>'></asp:Label>
                        <asp:Label ID="lblRemarkText" runat="server" Text='<%# Eval("RemarkText") %>'></asp:Label>
                        <asp:Label ID="lblRemarkID" runat="server" Text='<%# Eval("RemarkID") %>'></asp:Label>
                        <asp:Label ID="lblID" runat="server" Text='<%# Eval("ID_Original") %>'></asp:Label>
                        <asp:Label ID="lblAdd_ID" runat="server" Text='<%# Eval("Add_ID") %>'></asp:Label>
                        <asp:Label ID="lblReceptionIds" runat="server" Text='<%# Eval("ReceptionId") %>'></asp:Label>
                    </ItemTemplate>
                </asp:TemplateField>
                <%--Dept Name--%>
                <asp:TemplateField>
                    <HeaderTemplate>
                        <asp:UpdatePanel runat="server" ID="updPanelDept">
                            <ContentTemplate>
                                <table border="0px">
                                    <tr>
                                        <td>
                                            <asp:Label runat="server" ID="lblTitleDeptItemsService" Text=" יחידה:"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="padding-top: 5px">
                                            <asp:DropDownList ID="ddlDept" runat="server" Width="125px" AutoPostBack="True" OnSelectedIndexChanged="ddlDept_SelectedIndexChanged" />
                                        </td>
                                    </tr>
                                </table>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <div style="margin-right: 5px; margin-left: 3px">
                            <asp:Label ID="lblDept" runat="server" Text='<%# Eval("DeptName") %>' meta:resourcekey="lblDeptResource1"
                                CssClass="SimpleBold" EnableTheming="false"></asp:Label>
                        </div>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:UpdatePanel runat="server" ID="updPanelE">
                            <ContentTemplate>
                                <table>
                                    <tr>
                                        <td style="padding-top: 5px">
                                            <asp:DropDownList ID="ddlDeptE" Width="125px" runat="server" AutoPostBack="True"
                                                OnSelectedIndexChanged="ddlDept_SelectedIndexChanged" Visible='<%# IsVisualLabels %>'>
                                            </asp:DropDownList>
                                        </td>
                                    </tr>
                                </table>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </EditItemTemplate>
                </asp:TemplateField>
                <%-- Agreement --%>
                <asp:TemplateField>
                    <HeaderTemplate>
                                <table>
                                    <tr>
                                        <td>
                                            <asp:Label runat="server" ID="lblTitleAgreementType" Text=" סוג הסכם:"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="padding-top: 5px">
                                            <asp:DropDownList ID="ddlAgreementType" runat="server" Width="60px" AutoPostBack="True" />
                                        </td>
                                    </tr>
                                </table>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <div style="margin-right: 5px; margin-left: 0px">
                            <asp:Label ID="lblAgreementTypeDescription" runat="server" Text='<%# Eval("AgreementTypeDescription") %>' meta:resourcekey="lblDeptResource1"
                                CssClass="SimpleBold" EnableTheming="false"></asp:Label>
                            <asp:Label ID="lblAgreementType" runat="server" Text='<%# Eval("AgreementType") %>' 
                                CssClass="DisplayNone" EnableTheming="false"></asp:Label>                        
                        </div>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <div style="margin-right: 5px; margin-left: 0px">
                            <asp:Label ID="lblAgreementTypeDescription" runat="server" Text='<%# Eval("AgreementTypeDescription") %>' meta:resourcekey="lblDeptResource1"
                                CssClass="SimpleBold" EnableTheming="false"></asp:Label>
                             <asp:Label ID="lblAgreementType" runat="server" Text='<%# Eval("AgreementType") %>' 
                                CssClass="DisplayNone" EnableTheming="false"></asp:Label>                            
                        </div>
                    </EditItemTemplate>
                </asp:TemplateField>
                <%-- Professions --%>
                <asp:TemplateField>
                    <HeaderTemplate>
                        <table>
                            <tr>
                                <td>
                                </td>
                            </tr>
                            <tr>
                                <td style="padding-right: 4px">
                                    <asp:Label runat="server" ID="lblTitleDeptItems" Text=" תחומי שירות:"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <MultiDDlSelect_UC:MultiDDlSelect_UCItem runat="server" ID="MultiDDlSelect_DepartItems">
                                    </MultiDDlSelect_UC:MultiDDlSelect_UCItem>
                                </td>
                            </tr>
                        </table>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <div style="margin-right: 5px">
                            <asp:Label runat="server" ID="lblItemsNames" Text='<%# Eval("ItemDesc") %>' meta:resourcekey="lblItemsNamesResource1"
                                CssClass="SimpleBold" EnableTheming="false"></asp:Label>
                        </div>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <div style="padding-top: 5px;padding-right:3px">
                            <MultiDDlSelect_UC:MultiDDlSelect_UCItem runat="server" ID="MultiDDlSelect_DepartItemsE">
                            </MultiDDlSelect_UC:MultiDDlSelect_UCItem>
                        </div>
                    </EditItemTemplate>
                </asp:TemplateField>
                <%--Days--%>
                <asp:TemplateField meta:resourcekey="TemplateFieldResource3">
                    <HeaderTemplate>
                        <table>
                            <tr>
                                <td>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:Label ID="Label1" runat="server" Text="ימים:"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <MultiDDlSelect_UCDays:MultiDDlSelect_UCItemDays runat="server" ID="MultiDDlSelect_Days"
                                        Width="30px"></MultiDDlSelect_UCDays:MultiDDlSelect_UCItemDays>
                                </td>
                            </tr>
                        </table>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <table style="padding:0 0 0 0;">
                            <tr>
                                <td>
                                    <asp:Image runat="server" ID="imgShowOverlap" ToolTip="שים לב, קיימת חפיפה בשעת הקבלה !"
                                        ImageUrl="~/Images/imgConflict.gif" Visible="false" />
                                </td>
                                <td>
                                    <div style="padding-right: 5px">
                                        <asp:Label runat="server" ID="lblDays" Text='<%# Eval("ReceptionDay") %>' meta:resourcekey="lblDaysResource1"></asp:Label>
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </ItemTemplate>
                    <ItemStyle Width="30px" />
                    <EditItemTemplate>
                        <div style="padding-top: 5px; margin-right: 3px">
                            <MultiDDlSelect_UCDays:MultiDDlSelect_UCItemDays runat="server" ID="mltDdlDayE" Width="30px">
                            </MultiDDlSelect_UCDays:MultiDDlSelect_UCItemDays>
                        </div>
                    </EditItemTemplate>
                </asp:TemplateField>
                <%--conflict icon--%>
                <asp:TemplateField>
                    <HeaderTemplate>
                        <div style="vertical-align: top">
                            <asp:Image runat="server" ID="imgConflict" ToolTip="שים לב, קיימת חפיפה בשעת הקבלה !"
                                ImageUrl="~/Images/imgConflict.gif" Visible="false" />
                        </div>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <asp:Image runat="server" ID="imgConflict" ToolTip="שים לב, קיימת חפיפה בשעת הקבלה !"
                            ImageUrl="~/Images/imgConflict.gif" Visible="false" />
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:Image runat="server" ID="imgConflict" ToolTip="שים לב, קיימת חפיפה בשעת הקבלה !"
                            ImageUrl="~/Images/imgConflict.gif" Visible="false" />
                    </EditItemTemplate>
                    <ItemStyle Width="30px" />
                </asp:TemplateField>
                <%--From hour--%>
                <asp:TemplateField meta:resourcekey="TemplateFieldResource4">
                    <HeaderTemplate>
                        <table>
                            <tr>
                                <td>
                                    <asp:Label ID="Label2" runat="server" Text="משעה:"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td style="padding-top: 5px">
                                    <div style="width: 55px;">
                                        <asp:TextBox ID="txtFromHour" runat="server" dir="ltr" Width="35px" onkeydown="return keyispressed(event, this);" onkeyup="return validateTime(event, this)"  MaxLength="5" autocomplete="off"></asp:TextBox>
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <div style="padding-right: 0px">
                            <asp:Label runat="server" ID="lblOpeningHour" Text='<%# Eval("openingHour") %>' meta:resourcekey="lblOpeningHourResource1"></asp:Label>
                        </div>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <div style="margin-right: 3px">
                            <asp:TextBox ID="txtFromHour" runat="server" dir="ltr" Text='<%# Eval("openingHour") %>' Width="50px" onkeydown="return keyispressed(event, this);" onkeyup="return validateTime(event, this)"  MaxLength="5" autocomplete="off"></asp:TextBox>
                        </div>
                    </EditItemTemplate>
                </asp:TemplateField>
                <%--To hour--%>
                <asp:TemplateField meta:resourcekey="TemplateFieldResource5">
                    <HeaderTemplate>
                        <table>
                            <tr>
                                <td>
                                    <asp:Label ID="Label3" runat="server" Text="עד שעה:"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td style="padding-top: 5px;">
                                    <div style="width: 55px;">
                                        <asp:TextBox ID="txtToHour" runat="server" dir="ltr" Width="35px" onkeydown="return keyispressed(event, this);" onkeyup="return validateTime(event, this)"  MaxLength="5" autocomplete="off"></asp:TextBox>
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <div style="padding-right: 5px">
                            <asp:Label runat="server" ID="lblClosingHour" Text='<%# Eval("closingHour") %>' meta:resourcekey="lblClosingHourResource1"></asp:Label>
                        </div>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <div style="margin-right: 3px">
                            <asp:TextBox ID="txtToHour" runat="server" dir="ltr" Text='<%# Eval("closingHour") %>' Width="35px" onkeydown="return keyispressed(event, this);" onkeyup="return validateTime(event, this)"  MaxLength="5" autocomplete="off"></asp:TextBox>
                        </div>
                    </EditItemTemplate>
                </asp:TemplateField>
                <%--ReceptionRoom Column--%>
                <asp:TemplateField meta:resourcekey="TemplateFieldResource10">
                    <HeaderTemplate>
                        <table>
                            <tr>
                                <td style="padding-right: 3px">
                                    <asp:ImageButton ImageUrl="~/Images/btn_room.gif" ID="btnSpreadRoomNumber"
                                        OnClick="btnSpreadRoomNumber_Click" runat="server" />
                                </td>
                            </tr>
                            <tr>
                                <td style="padding-top: 3px">
                                    <asp:TextBox id="txtReceptionRoom" runat="server" style="width: 35px" />
                                </td>
                            </tr>
                        </table>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <div>
                            <asp:Label runat="server" ID="lblReceptionRoom" Text='<%# Eval("ReceptionRoom") %>' meta:resourcekey="lblReceptionRoomResource1"></asp:Label>
                        </div>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <div>
                            <asp:TextBox id="txtReceptionRoom" runat="server" Text='<%# Eval("ReceptionRoom") %>' style="width: 35px" />
                        </div>
                    </EditItemTemplate>
                </asp:TemplateField>

                <%-- Receive guests --%>
                <asp:TemplateField>
                    <HeaderTemplate>
                        <table>
                            <tr>
                                <td>
                                    <asp:Image ID="imgReceiveGuests" runat="server" ImageUrl="~/Images/Applic/ReceiveGuestsSmall.png" ToolTip="מקבל אורחים" />
                                </td>
                            </tr>
                            <tr>
                                <td style="padding-right: 3px">
                                    <asp:CheckBox ID="cbReceiveGuests" runat="server"></asp:CheckBox>
                                </td>
                            </tr>
                        </table>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <div style="width: 20px">
                            <asp:Image ID="imgReceiveGuests" runat="server" ImageUrl="~/Images/Applic/ReceiveGuestsSmall.png" />
                        </div>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:CheckBox runat="server" ID="cbReceiveGuests" ></asp:CheckBox>
                    </EditItemTemplate>
                </asp:TemplateField>

                <%--remark--%>
                <asp:TemplateField>
                    <HeaderTemplate>
                        <table>
                            <tr>
                                <td>
                                    <asp:HiddenField ID="hdnRemarkText" runat="server" />
                                    <asp:HiddenField ID="hdnRemarkMask" runat="server" />
                                    <asp:HiddenField ID="hdnRemarkID" runat="server" />
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:Label ID="lblTitleRemark" runat="server" Text="הערה :"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <table>
                                        <tr>
                                            <td valign="top" style="padding-top: 2px">
                                                <input type="text" runat="server" id="inpTitleRemark" readonly="readonly" style="height: 14px" onchange="(event) => onRemarkChange(event)" />
                                            </td>
                                            <td>
                                                <input type="image" id="btnUnitTypeListPopUpHeader" style="cursor: pointer;" src="../Images/Applic/icon_magnify.gif"
                                                    onclick="OpenRemarkWindowDialog('ReceptionHours','header',this);return false;" validationgroup="vldGrAdd"
                                                    causesvalidation="true" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <div style="padding-right: 10px">
                            <asp:Label runat="server" ID="lblRemark" Text='<%# Eval("RemarkText") %>'></asp:Label>
                        </div>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <div style="padding-right: 5px; padding-top: 2px">
                            <input type="text" id="lblRemarkText_E" style="width: 95px" runat="server" onchange="ClearRemarkIfEmpty(this);" readonly
                                value='<%# Eval("RemarkText") %>' />
                            <input type="image" id="btnUnitTypeListPopUp" style="cursor: pointer; vertical-align: top"
                                src="../Images/Applic/icon_magnify.gif" onclick="OpenRemarkWindowDialog('ReceptionHours','edit',this);return false;"
                                validationgroup="vldGrEdit" causesvalidation="true" />
                        </div>
                    </EditItemTemplate>
                </asp:TemplateField>
                <%--valid from--%>
                <asp:TemplateField>
                    <HeaderTemplate>
                        <table width="102px">
                            <tr>
                                <td style="padding-right: 8px">
                                    <asp:Label ID="Label4" runat="server" Text="תוקף מ:" meta:resourcekey="Label4Resource1"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td style="padding-top: 1px;direction:ltr;" valign="middle">
                                    <cc1:MaskedEditExtender ID="FromDateExtender" runat="server" ErrorTooltipEnabled="True"
                                        Mask="99/99/9999" MaskType="Date" TargetControlID="txtFromDate" ClearMaskOnLostFocus="false"
                                        Enabled="True">
                                    </cc1:MaskedEditExtender>
                                    <cc1:MaskedEditValidator ID="FromDateValidator" runat="server" ControlExtender="FromDateExtender"
                                        ControlToValidate="txtFromDate" InvalidValueMessage="התאריך אינו תקין" Display="Dynamic"
                                        InvalidValueBlurredMessage="*" ValidationGroup="vldGrAdd" ErrorMessage="התאריך אינו תקין" />
                                    <asp:ImageButton ImageUrl="~/Images/Applic/calendarIcon.png" ID="btnRunCalendar"
                                        runat="server" meta:resourcekey="btnRunCalendarResource2" />
                                    <asp:TextBox ID="txtFromDate" dir="ltr" Width="65px" runat="server" Text='' onkeyup="FocusNextFieldIfNeeded(this, 'txtToDate', event);"></asp:TextBox>
                                    <cc1:CalendarExtender ID="calExtFromDate_DeptName" runat="server" Format="dd/MM/yyyy"
                                        FirstDayOfWeek="Sunday" TargetControlID="txtFromDate" PopupPosition="BottomRight"
                                        PopupButtonID="btnRunCalendar" Enabled="True" OnClientDateSelectionChanged="checkDate">
                                    </cc1:CalendarExtender>
                                    
                                </td>
                            </tr>
                        </table>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <div style="padding-right: 7px">
                            <asp:Label runat="server" ID="lblValidFrom"></asp:Label>
                        </div>
                    </ItemTemplate>
                    <ItemStyle Width="102px" />
                    <EditItemTemplate>
                        <table id="tblValidFrom">
                            <tr>
                                <td style="direction:ltr; width: 95px">
                                    <cc1:MaskedEditExtender ID="FromDateExtender" runat="server" ErrorTooltipEnabled="True"
                                        Mask="99/99/9999" MaskType="Date" ClearMaskOnLostFocus="false" TargetControlID="txtFromDate"
                                        Enabled="True">
                                    </cc1:MaskedEditExtender>
                                    <cc1:MaskedEditValidator ID="FromDateValidator" runat="server" ControlExtender="FromDateExtender"
                                        ControlToValidate="txtFromDate" InvalidValueMessage="התאריך אינו תקין" Display="Dynamic"
                                        InvalidValueBlurredMessage="*" ValidationGroup="vldGrEdit" ErrorMessage="התאריך אינו תקין" />
                                    <asp:ImageButton ImageUrl="~/Images/Applic/calendarIcon.png" ID="btnRunCalendar"
                                        runat="server" meta:resourcekey="btnRunCalendarResource1" />
                                    <asp:TextBox ID="txtFromDate" dir="ltr" Width="65px" runat="server" Text='<%# Eval("ValidFrom","{0:d}") %>'
                                        onkeyup="FocusNextFieldIfNeeded(this, 'txtToDate', event)"></asp:TextBox>
                                    <cc1:CalendarExtender ID="calExtFromDate_DeptName" runat="server" Format="dd/MM/yyyy"
                                        FirstDayOfWeek="Sunday" TargetControlID="txtFromDate" PopupPosition="BottomRight"
                                        PopupButtonID="btnRunCalendar" Enabled="True" OnClientDateSelectionChanged="checkDate">
                                    </cc1:CalendarExtender>
                                    
                                </td>
                            </tr>
                        </table>
                    </EditItemTemplate>
                    <ItemStyle />
                </asp:TemplateField>
                <%--valid to--%>
                <asp:TemplateField>
                    <HeaderTemplate>
                        <table width="115px" border="0" cellpadding="0" cellspacing="0">
                            <tr>
                                <td style="padding-right: 15px">
                                    <asp:Label ID="Label5" runat="server" Text="תוקף עד:"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td style="padding-top: 2px;direction:ltr;">
                                    <cc1:MaskedEditValidator ID="txtToDate_DeptStatus_Validator" runat="server" ControlExtender="txtToDate_DeptStatus_Extender"
                                        ControlToValidate="txtToDate" InvalidValueMessage="התאריך אינו תקין" Display="Dynamic"
                                        InvalidValueBlurredMessage="*" ValidationGroup="vldGrAdd" ErrorMessage="התאריך אינו תקין" />
                                    <asp:CustomValidator runat="server" ID="CompareDatesValidatorHeader" ControlToValidate="txtToDate"
                                        ClientValidationFunction="compareDates" Text="*" ErrorMessage="טווח תאריכים אינו תקין"
                                        ValidateEmptyText="false" ValidationGroup="vldGrAdd"></asp:CustomValidator>
                                    <asp:ImageButton ImageUrl="~/Images/Applic/calendarIcon.png" ID="btnRunCalendarTo"
                                        runat="server" meta:resourcekey="btnRunCalendarToResource1" />
                                    <asp:TextBox ID="txtToDate" dir="ltr" Width="65px" runat="server" Text='' onkeyup="FocusNextFieldIfNeeded(this, 'imgAdd', event);"></asp:TextBox>
                                    <cc1:CalendarExtender ID="calExtToDate_DeptStatus" runat="server" Format="dd/MM/yyyy" CssClass="calendar"
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
                    <ItemTemplate>
                        <asp:Label runat="server" ID="lblValidTo"></asp:Label>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <table width="115px" border="0" id="tblValidTo" style="vertical-align: baseline">
                            <tr>
                                <td style="direction:ltr; width: 135px;">
                                    <cc1:MaskedEditValidator ID="txtToDate_E_ValidatorE2" runat="server" ControlExtender="txtToDate_E_ExtenderE2"
                                        ControlToValidate="txtToDate" InvalidValueMessage="התאריך אינו תקין" Display="Dynamic"
                                        Text="*" InvalidValueBlurredMessage="*" ValidationGroup="vldGrEdit" ErrorMessage="התאריך אינו תקין"
                                        meta:resourcekey="txtToDate_E_ValidatorE2Resource1" />
                                    <asp:CustomValidator runat="server" ID="CompareDatesValidatorEdit" ControlToValidate="txtToDate"
                                        ClientValidationFunction="compareDates" Text="*" ErrorMessage="טווח תאריכים אינו תקין"
                                        ValidationGroup="vldGrEdit" ValidateEmptyText="false"></asp:CustomValidator>
                                    <asp:ImageButton ImageUrl="~/Images/Applic/calendarIcon.png" ID="btnRunCalendarToE2"
                                        runat="server" meta:resourcekey="btnRunCalendarToE2Resource1" />
                                    <asp:TextBox ID="txtToDate" dir="ltr" Width="65px" runat="server" Text='<%# Eval("ValidTo","{0:d}") %>'
                                        onkeyup="FocusNextFieldIfNeeded(this, 'imgSave', event)"></asp:TextBox>
                                    <cc1:CalendarExtender ID="calExtToDate_E2" runat="server" Format="dd/MM/yyyy" FirstDayOfWeek="Sunday"
                                        TargetControlID="txtToDate" PopupPosition="BottomRight" PopupButtonID="btnRunCalendarToE2"
                                        Enabled="True">
                                    </cc1:CalendarExtender>
                                    <cc1:MaskedEditExtender ID="txtToDate_E_ExtenderE2" runat="server" ErrorTooltipEnabled="True"
                                        Mask="99/99/9999" MaskType="Date" TargetControlID="txtToDate" CultureAMPMPlaceholder="AM;PM"
                                        CultureDateFormat="DMY" CultureDatePlaceholder="/" CultureDecimalPlaceholder="."
                                        CultureThousandsPlaceholder="," CultureTimePlaceholder=":" Enabled="True">
                                    </cc1:MaskedEditExtender>
                                </td>
                            </tr>
                        </table>
                    </EditItemTemplate>
                </asp:TemplateField>
                <%-- delete button --%>
                <asp:TemplateField>
                    <ItemTemplate>
                        <div style="width: 20px">
                            <asp:ImageButton ID="imgDelete" runat="server" CommandName="delete" OnClick="imgDelete_Click"
                                ImageUrl="~/Images/Applic/btn_X_red.gif" />
                        </div>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:HiddenField ID="lblRemarkID_E" runat="server"    />
                        <asp:HiddenField ID="lblRemarkMask_E_c" runat="server"    />
                        <asp:Label runat="server" Visible="False" ID="lblRemarkMask_E" Width="1px" Text='<%# Bind("RemarkText") %>'
                            CssClass="DisplayNone"></asp:Label>
                    </EditItemTemplate>
                </asp:TemplateField>
                <%--udpate  button--%>
                <asp:TemplateField>
                    <HeaderTemplate>
                        <table border="0" width="45px" cellpadding="0" cellspacing="0">
                            <tr>
                                <td style="padding-top: 10px">
                                    <asp:Button runat="server" ID="imgAdd" Enabled="false" Text="הוספה" CausesValidation="true" CommandName="add"
                                                OnClick="imgAdd_Click" Width="48px" CssClass="button_disabled" />

                                    <asp:CustomValidator ID="vldCustomAdd" runat="server" ValidationGroup="vldGrAdd"
                                                         Display="Dynamic" OnServerValidate="CheckAddParams" ErrorMessage="*" Text="חובה להזין שדות חובה"></asp:CustomValidator>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:Button runat="server" ID="imgClear" Text="נקה" CausesValidation="true" CommandName="clear"
                                                OnClientClick="javascript:clearRemark()" OnClick="imgClear_Click" Width="48px" CssClass="button" />
                                </td>
                            </tr>
                        </table>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <asp:Button runat="server" ID="imgUpdate" Enabled="true" Text="עדכון" CausesValidation="true" CommandName="edit"
                                    OnClick="imgUpdate_Click" Width="48px" CssClass="button" />
                    </ItemTemplate>
                    <ItemStyle Width="30px" />
                    <EditItemTemplate>
                        <table>
                            <tr>
                                <td style="width:50px">
                                    <asp:Button runat="server" ID="imgSave" Enabled="false" Text="אישור" CausesValidation="true" CommandName="save"
                                                OnClick="imgSave_Click" Width="48px" CssClass="button_disabled" meta:resourcekey="imgSaveResource1" />
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:Button runat="server" ID="imgCancel" Enabled="true" Text="ביטול" CausesValidation="true" CommandName="cancel"
                                                Width="48px" CssClass="button" />
                                </td>
                            </tr>
                        </table>
                    </EditItemTemplate>
                    <ItemStyle HorizontalAlign="center" Wrap="false" />
                </asp:TemplateField>

            </Columns>
            <SelectedRowStyle ForeColor="GhostWhite" />
            <HeaderStyle BackColor="#F3EBE0" CssClass="SimpleBold" />
        </asp:GridView>
        <div id="hdnDiv">
            <asp:TextBox ID="txtWherePutRemark" runat="server" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>

            <asp:TextBox ID="txtSelectedRemark_FromDialog" runat="server" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>
            <asp:TextBox ID="txtSelectedRemarkMask_FromDialog" runat="server" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>
            <asp:TextBox ID="txtSelectedRemarkID_FromDialog" runat="server" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>
            <asp:TextBox ID="txtSelectedEnableOverMidnightHours_FromDialog" runat="server" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>
            <asp:TextBox ID="txtSelectedEnableOverlappingHours_FromDialog" runat="server" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>

            <asp:HiddenField ID="hdnRemark" runat="server" />
            <asp:HiddenField ID="hdnRemarkText_E" runat="server" />
            <asp:HiddenField ID="hdnRemarkMask_E" runat="server" />
            <asp:HiddenField ID="hdnRemarkID_E" runat="server" />
            <%--            <asp:HiddenField ID="hdnHeaderFromHourClientID" runat="server" />
            <asp:HiddenField ID="hdnHeaderToHourClientID" runat="server" />
            <asp:HiddenField ID="hdnHeaderValidFromClientID" runat="server" />
            <asp:HiddenField ID="hdnHeaderValidToClientID" runat="server" />--%>
            <asp:HiddenField ID="hdnEnableOverMidnightHours" runat="server" />
            <asp:HiddenField ID="hdnAgreedToChangeOverlappedHoursExpiration" runat="server" />
            <asp:ImageButton runat="server" ID="imgPostBack" ImageUrl="~/Images/add.gif" OnClick="imgPostBack_Click" CssClass="DisplayNone" CausesValidation="false" />
        </div>
    </ContentTemplate>
</asp:UpdatePanel>

<% ScriptManager.RegisterClientScriptBlock(this.Page, typeof(string), "CheckTime", "validateTime()", true); %>