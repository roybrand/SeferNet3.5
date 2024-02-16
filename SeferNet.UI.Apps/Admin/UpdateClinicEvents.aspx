<%@ Reference Page="AdminBasePage.aspx" %>

<%@ Page Language="C#" MasterPageFile="~/seferMasterPage.master" AutoEventWireup="true" Inherits="UpdateClinicEvents" Title="עדכון פעילויות במרפאה" Codebehind="UpdateClinicEvents.aspx.cs" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<%@ Register Assembly="System.Web.Extensions, Version=1.0.61025.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
    Namespace="System.Web.UI" TagPrefix="asp" %>
<%@ MasterType VirtualPath="~/seferMasterPage.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="pageContent" runat="Server">
  

    <script type="text/javascript">
        function onfocusoutFromDate(txtName) {
            var txtFromDate = document.getElementById(txtName);
            //txtFromDate.value = Date().getDay() + '/' + new Date().getMonth() + '/' + new Date().getFullYear();
            if (txtFromDate.value == '__/__/____')
                txtFromDate.value = '<%=DateTime.Today.ToShortDateString() %>';
        }

        function UpdateFromDeptPhones() {
            var cbUpdateFromDeptPhones = document.getElementById('<%=cbUpdateFromDeptPhones.ClientID %>');

            var DeptFirstPhone_PrePrefix = document.getElementById('<%=txtDeptFirstPhone_PrePrefix.ClientID %>');
            var DeptFirstPhone_Prefix = document.getElementById('<%=txtDeptFirstPhone_Prefix.ClientID %>');
            var DeptFirstPhone_Phone = document.getElementById('<%=txtDeptFirstPhone_Phone.ClientID %>');
            var DeptFirstPhone_Extension = document.getElementById('<%=txtDeptFirstPhone_Extension.ClientID %>');

            var ddlPhonePrePrefix = document.getElementById('<%=ddlPhonePrePrefix.ClientID %>');
            var ddlPhonePrefix = document.getElementById('<%=ddlPhonePrefix.ClientID %>');
            var txtPhone = document.getElementById('<%=txtPhone.ClientID %>');
            var txtExtension = document.getElementById('<%=txtExtension.ClientID %>');
            var pnlPhone = document.getElementById('<%= pnlPhone.ClientID %>');


            var count = -1;

            pnlPhone.disabled = cbUpdateFromDeptPhones.checked;

            if (cbUpdateFromDeptPhones.checked == true) {


                txtPhone.value = DeptFirstPhone_Phone.value;
                txtExtension.value = DeptFirstPhone_Extension.value;

                for (var i = 0; i < ddlPhonePrefix.length; i++) {
                    if (ddlPhonePrefix.options[i].value == DeptFirstPhone_Prefix.value)
                        count = i;
                }

                if (count != -1)
                    ddlPhonePrefix.selectedIndex = count;

                count = -1;
                for (var i = 0; i < ddlPhonePrePrefix.length; i++) {
                    if (ddlPhonePrePrefix.options[i].value == DeptFirstPhone_PrePrefix.value)
                        count = i;
                }

                if (count != -1)
                    ddlPhonePrePrefix.selectedIndex = count;
                else
                    ddlPhonePrePrefix.selectedIndex = 0;
            }
        }

        function ShowDayOfWeek(date, targetControlID) {
            var dateParts = date.value.split("/");
            var reformattedDate = dateParts[1] + "/" + dateParts[0] + "/" + dateParts[2];
            var daysList = ["א`", "ב`", "ג`", "ד`", "ו`", "ה`", "ש`"];
            var targetControl = document.getElementById(targetControlID);
            var myDate = new Date(eval('"' + reformattedDate + '"'));
            //alert(reformattedDate);
            //alert(targetControlID);
            if (dateParts.length == 3)
            //targetControl.value = daysList[myDate.getDay()];
                targetControl.value = daysList[myDate.getDay()];
            else
                targetControl.value = "";

        }

        function ShowDuration(txtFromHourID, txtToHourID, txtDurationID) {

            var txtFromHour = document.getElementById(txtFromHourID);
            var txtToHour = document.getElementById(txtToHourID);
            var txtDuration = document.getElementById(txtDurationID);

            var fromHourParts = txtFromHour.value.split(":");
            var toHourParts = txtToHour.value.split(":");
            var res = (toHourParts[0] - fromHourParts[0]) + (toHourParts[1] - fromHourParts[1]) / 60;

            if (!isNaN(res))
                txtDuration.value = res.toFixed(1);
            else
                txtDuration.value = "";
        }

        function ValidateAllPhoneControls(source, args) {
            var txtPhone = document.getElementById('<%=txtPhone.ClientID %>');
            var ddlPhonePrefix = document.getElementById('<%=ddlPhonePrefix.ClientID %>');
            var ddlPhonePrePrefix = document.getElementById('<%=ddlPhonePrePrefix.ClientID %>');
            var txtExtension = document.getElementById('<%=txtExtension.ClientID %>');

            var phonePrePrefixSelected = ddlPhonePrePrefix.options[ddlPhonePrePrefix.selectedIndex].value;
            var phonePrefixSelected = ddlPhonePrefix.options[ddlPhonePrefix.selectedIndex].value;

            if (txtPhone.value != "" && phonePrePrefixSelected == "-1" && phonePrefixSelected == "-1")
                args.IsValid = false;
            else if (txtPhone.value == ""
            && (phonePrePrefixSelected != "-1" || phonePrefixSelected != "-1" || txtExtension.value != ""))
                args.IsValid = false;
            else
                args.IsValid = true;

        }


        function ddlPayOrder_OnChange() {
            var ddlPayOrder = document.getElementById('<%=ddlPayOrder.ClientID%>');
            var txtMemberPrice = document.getElementById('<%=txtMemberPrice.ClientID%>');
            var txtFullMemberPrice = document.getElementById('<%=txtFullMemberPrice.ClientID%>');
            var txtCommonPrice = document.getElementById('<%=txtCommonPrice.ClientID%>');
            var selectedValue = ddlPayOrder.options[ddlPayOrder.selectedIndex].value;
            if (selectedValue != 3) { // free
                txtMemberPrice.value = '';
                txtFullMemberPrice.value = '';
                txtCommonPrice.value = '';

                txtMemberPrice.disabled = true;
                txtFullMemberPrice.disabled = true;
                txtCommonPrice.disabled = true;

                txtMemberPrice.style.backgroundColor = "#F7F7F7";
                txtFullMemberPrice.style.backgroundColor = "#F7F7F7";
                txtCommonPrice.style.backgroundColor = "#F7F7F7";
            }
            else {
                txtMemberPrice.disabled = false;
                txtFullMemberPrice.disabled = false;
                txtCommonPrice.disabled = false;

                txtMemberPrice.style.backgroundColor = "White";
                txtFullMemberPrice.style.backgroundColor = "White";
                txtCommonPrice.style.backgroundColor = "White";
            }
        }

        function ValidatePayOrder(sender, args) {
            var ddlPayOrder = document.getElementById('<%=ddlPayOrder.ClientID%>');
            var txtMemberPrice = document.getElementById('<%=txtMemberPrice.ClientID%>');
            var txtFullMemberPrice = document.getElementById('<%=txtFullMemberPrice.ClientID%>');
            var txtCommonPrice = document.getElementById('<%=txtCommonPrice.ClientID%>');
            var selectedValue = ddlPayOrder.options[ddlPayOrder.selectedIndex].value;
            if (selectedValue == -1) {
                sender.errormessage = "נא לבחור ערך";
                args.IsValid = false;
            }
            else {
                if (selectedValue == 3 && txtMemberPrice.value == '' && txtFullMemberPrice.value == '' && txtCommonPrice.value == '') {
                    sender.errormessage = "נא להזין מחיר"
                    args.IsValid = false;
                }

                else
                    args.IsValid = true;
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
        }
    
    </script>
    

    <div id="progress" style="position: absolute; top: 300px; left: 500px">
        <asp:UpdateProgress ID="UpdateProgress1" runat="server">
            <ProgressTemplate>
                <asp:Image ID="img" runat="server" ImageUrl="~/Images/Applic/progressBar.gif" />
            </ProgressTemplate>
        </asp:UpdateProgress>
    </div>
    <table id="tblMain" width="980px" cellspacing="0" cellpadding="0" dir="rtl">
        <tr>
            <td style="padding-right: 10px">
                <table cellpadding="0" cellspacing="0" style="background-color: #298AE5; height: 30px;"
                    width="100%">
                    <tr>
                        <td style="width: 800px; padding-right: 10px">
                            <asp:Label ID="lblEventName" EnableTheming="false" CssClass="LabelBoldWhite_18" runat="server"
                                Text=""></asp:Label>
                            &nbsp;
                            <asp:Label ID="lblDeptName" EnableTheming="false" CssClass="LabelBoldWhite_18" runat="server"
                                Text=""></asp:Label>
                        </td>
                        <td align="left">
                            <table cellpadding="0" cellspacing="0">
                                <tr>
                                    <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                        background-position: bottom left;">
                                        &nbsp;
                                    </td>
                                    <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                        background-repeat: repeat-x; background-position: bottom;">
                                        <asp:Button ID="btnSave" runat="server" Text="שמירה" CssClass="RegularUpdateButton"
                                            ValidationGroup="vldDeptEvent" OnClick="btnSave_Click"></asp:Button>
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
                                        <asp:Button ID="btnCancel" runat="server" CssClass="RegularUpdateButton" Text="ביטול"
                                            CausesValidation="False" OnClick="btnCancel_Click" />
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
        <tr id="trError" runat="server">
            <td>
                <asp:Label ID="lblGeneralError" runat="server" SkinID="lblError"></asp:Label>
            </td>
        </tr>
        <tr>
            <td>
                <asp:ValidationSummary ID="vldSummary" runat="server" ValidationGroup="vldDeptEvent" />
            </td>
        </tr>
        <tr>
            <td>
                <table cellpadding="0" cellspacing="0">
                    <tr>
                        <td style="padding-right: 10px; padding-top: 5px;" valign="top">
                            <!-- Right side -->
                            <table cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7">
                                <tr>
                                    <td style="height: 10px; background-image: url('../Images/Applic/RTcornerGrey10.gif');
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
                                    <td valign="top">
                                        <!-- tblDetails Right -->
                                        <div style="height: 450px">
                                            <table width="460px" cellpadding="0" cellspacing="0">
                                                <tr id="trEventName" runat="server">
                                                    <td style="width: 50px">
                                                        <asp:Label ID="lblEventNameForDDL" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                            runat="server" Text="שם פעילות:"></asp:Label>
                                                    </td>
                                                    <td colspan="2">
                                                        <asp:DropDownList ID="ddlEventName" runat="server" DataValueField="EventCode" AppendDataBoundItems="true"
                                                            DataTextField="EventName" Width="300px" AutoPostBack="false">
                                                            <asp:ListItem Text="בחר" Value="-1"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:CompareValidator ID="vldEventName" runat="server" ControlToValidate="ddlEventName"
                                                            Operator="NotEqual" Text="*" ValueToCompare="-1" ValidationGroup="vldDeptEvent"></asp:CompareValidator>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td valign="top">
                                                        <asp:Label ID="lblFromDate" EnableTheming="false" CssClass="LabelBoldDirtyBlue" runat="server"
                                                            Text="להציג מ:"></asp:Label>
                                                    </td>
                                                    <td colspan="2">
                                                        <table cellpadding="0" cellspacing="0">
                                                            <tr>
                                                                <td style="direction:ltr;width:117px;text-align:right;">
                                                                    <ajaxToolkit:MaskedEditValidator ID="val_txtFromDate" runat="server" ControlExtender="mask_txtFromDate"
                                                                        ControlToValidate="txtFromDate" IsValidEmpty="True" InvalidValueMessage="התאריך אינה תקינה"
                                                                        Display="Dynamic" InvalidValueBlurredMessage="*" ValidationGroup="vldDeptEvent" />
                                                                    <asp:RequiredFieldValidator ID="vldFromDateReq" runat="server" ControlToValidate="txtFromDate"
                                                                        Text="*" Display="Dynamic" ValidationGroup="vldDeptEvent"></asp:RequiredFieldValidator>
                                                                    <asp:ImageButton ImageUrl="~/Images/Applic/calendarIcon.png" ID="btnRunCalendar_FromDate"
                                                                        runat="server" />
                                                                    <asp:TextBox ID="txtFromDate" SkinID="TexBoxNormal_13" Width="70px" runat="server"></asp:TextBox>
                                                                    <ajaxToolkit:CalendarExtender ID="calExt_txtFromDate" runat="server" Format="dd/MM/yyyy"
                                                                        FirstDayOfWeek="Sunday" TargetControlID="txtFromDate" PopupPosition="BottomRight"
                                                                        PopupButtonID="btnRunCalendar_FromDate" OnClientDateSelectionChanged="checkDate">
                                                                    </ajaxToolkit:CalendarExtender>
                                                                    <ajaxToolkit:MaskedEditExtender ID="mask_txtFromDate" runat="server" AcceptAMPM="false"
                                                                        ErrorTooltipEnabled="True" Mask="99/99/9999" MaskType="Date" MessageValidatorTip="true"
                                                                        OnFocusCssClass="MaskedEditFocus" OnInvalidCssClass="MaskedEditError" TargetControlID="txtFromDate">
                                                                    </ajaxToolkit:MaskedEditExtender>
                                                                    
                                                                </td>
                                                                <td style="padding-right: 10px; padding-left: 5px;" valign="top">
                                                                    <asp:Label ID="lblToDate" EnableTheming="false" CssClass="LabelBoldDirtyBlue" runat="server"
                                                                        Text="עד:"></asp:Label>
                                                                </td>
                                                                <td style="direction:ltr;width:117px;text-align:right;">
                                                                    <ajaxToolkit:MaskedEditValidator ID="val_txtToDate" runat="server" ControlExtender="mask_txtToDate"
                                                                        ControlToValidate="txtToDate" IsValidEmpty="True" InvalidValueMessage="התאריך אינה תקינה"
                                                                        Display="Dynamic" InvalidValueBlurredMessage="*" ValidationGroup="vldDeptEvent" />
                                                                    <asp:RequiredFieldValidator Display="Dynamic" ID="vldToDateReq" runat="server" ControlToValidate="txtToDate"
                                                                        Text="*" ValidationGroup="vldDeptEvent"></asp:RequiredFieldValidator>
                                                                    <asp:ImageButton ImageUrl="~/Images/Applic/calendarIcon.png" ID="btnRunCalendar_ToDate"
                                                                        runat="server" />
                                                                    <asp:TextBox ID="txtToDate" SkinID="TexBoxNormal_13" Width="70px" runat="server"></asp:TextBox>
                                                                    <ajaxToolkit:CalendarExtender ID="calExt_txtToDate" runat="server" Format="dd/MM/yyyy"
                                                                        FirstDayOfWeek="Sunday" TargetControlID="txtToDate" PopupPosition="BottomRight"
                                                                        PopupButtonID="btnRunCalendar_ToDate">
                                                                    </ajaxToolkit:CalendarExtender>
                                                                    <ajaxToolkit:MaskedEditExtender ID="mask_txtToDate" runat="server" AcceptAMPM="false"
                                                                        ErrorTooltipEnabled="True" Mask="99/99/9999" MaskType="Date" MessageValidatorTip="true"
                                                                        OnFocusCssClass="MaskedEditFocus" OnInvalidCssClass="MaskedEditError" TargetControlID="txtToDate">
                                                                    </ajaxToolkit:MaskedEditExtender>
                                                                    
                                                                </td>
                                                                <td style="padding-right: 5px">
                                                                    <asp:CheckBox ID="cbDisplayInInternet" runat="server" />
                                                                    <asp:Label ID="lblDisplayInInternet" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                                        runat="server" Text="להציג באינטרנט"></asp:Label>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <asp:Label ID="lblEventDescription" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                            runat="server" Text="תאור:"></asp:Label>
                                                    </td>
                                                    <td colspan="2">
                                                        <asp:TextBox ID="txtEventDescription" Width="300px" runat="server"></asp:TextBox>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <asp:Label ID="lblTargetPopulation" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                            runat="server" Text="מיועד עבור:"></asp:Label>
                                                    </td>
                                                    <td colspan="2">
                                                        <asp:TextBox ID="txtTargetPopulation" Width="300px" runat="server"></asp:TextBox>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <asp:Label ID="lblRegistrationStatus" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                            runat="server" Text="הרשמה:"></asp:Label>
                                                    </td>
                                                    <td colspan="2">
                                                        <asp:DropDownList ID="ddlRegistrationStatus" runat="server" Width="150px" DataTextField="registrationStatusDescription"
                                                            DataValueField="registrationStatus" AppendDataBoundItems="true" AutoPostBack="false">
                                                            <asp:ListItem Value="-1" Text="בחר"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:CompareValidator ID="CompareValidator1" runat="server" ControlToValidate="ddlRegistrationStatus"
                                                            Operator="NotEqual" Text="*" ValueToCompare="-1" ValidationGroup="vldDeptEvent"></asp:CompareValidator>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <asp:Label ID="lblPayOrder" EnableTheming="false" CssClass="LabelBoldDirtyBlue" runat="server"
                                                            Text="עלות:"></asp:Label>
                                                    </td>
                                                    <td colspan="2">
                                                        <asp:DropDownList ID="ddlPayOrder" runat="server" AppendDataBoundItems="true" OnChange="ddlPayOrder_OnChange()"
                                                            Width="150px" DataValueField="PayOrder" DataTextField="PayOrderDescription">
                                                            <asp:ListItem Value="-1" Text="בחר"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:CustomValidator ID="vldPayOrder" runat="server" ClientValidationFunction="ValidatePayOrder"
                                                            ValidationGroup="vldDeptEvent" Text="*"></asp:CustomValidator>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td style="padding-right: 20px">
                                                        <asp:Label ID="lblMemberPrice" runat="server" EnableTheming="false" CssClass="LabelNormalDirtyBlue_12"
                                                            Text="&diams;&nbsp;כללית"></asp:Label>
                                                    </td>
                                                    <td colspan="2">
                                                        <asp:TextBox ID="txtMemberPrice" runat="server" Width="120px"></asp:TextBox>
                                                        <asp:Label ID="lblNIS_1" runat="server" EnableTheming="false" CssClass="LabelNormalDirtyBlue_12"
                                                            Text="ש``ח"></asp:Label>
                                                        <asp:CompareValidator ID="vldMemberPrice" runat="server" Text="*" ControlToValidate="txtMemberPrice"
                                                            ValidationGroup="vldDeptEvent" Operator="DataTypeCheck" Type="Double"></asp:CompareValidator>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td style="padding-right: 20px">
                                                        <asp:Label ID="lblFullMemberPrice" runat="server" EnableTheming="false" CssClass="LabelNormalDirtyBlue_12"
                                                            Text="&diams;&nbsp;מושלם"></asp:Label>
                                                    </td>
                                                    <td colspan="2">
                                                        <asp:TextBox ID="txtFullMemberPrice" runat="server" Width="120px"></asp:TextBox>
                                                        <asp:Label ID="lblNIS_2" runat="server" EnableTheming="false" CssClass="LabelNormalDirtyBlue_12"
                                                            Text="ש``ח"></asp:Label>
                                                        <asp:CompareValidator ID="vldFullMemberPrice" runat="server" Text="*" ControlToValidate="txtFullMemberPrice"
                                                            ValidationGroup="vldDeptEvent" Operator="DataTypeCheck" Type="Double"></asp:CompareValidator>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td style="padding-right: 20px">
                                                        <asp:Label ID="lblCommonPrice" runat="server" EnableTheming="false" CssClass="LabelNormalDirtyBlue_12"
                                                            Text="&diams;&nbsp;אחרים"></asp:Label>
                                                    </td>
                                                    <td colspan="2">
                                                        <asp:TextBox ID="txtCommonPrice" runat="server" Width="120px"></asp:TextBox>
                                                        <asp:Label ID="lblNIS_3" runat="server" EnableTheming="false" CssClass="LabelNormalDirtyBlue_12"
                                                            Text="ש``ח"></asp:Label>
                                                        <asp:CompareValidator ID="vldCommonPrice" runat="server" Text="*" ControlToValidate="txtCommonPrice"
                                                            ValidationGroup="vldDeptEvent" Operator="DataTypeCheck" Type="Double"></asp:CompareValidator>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td style="padding-top: 5px;">
                                                        <asp:Label ID="lblPhone" EnableTheming="false" CssClass="LabelBoldDirtyBlue" runat="server"
                                                            Text="טל` בירורים:"></asp:Label>
                                                    </td>
                                                    <td style="padding-top: 5px">
                                                        <div id="pnlPhone" style="display: inline;width:400px" runat="server">
                                                            <asp:TextBox ID="txtPhone" Width="80px" runat="server"></asp:TextBox>
                                                            <asp:DropDownList ID="ddlPhonePrefix" runat="server" DataValueField="prefixCode"
                                                                DataTextField="prefixValue" AppendDataBoundItems="True">
                                                                <asp:ListItem Text=" " Value="-1"></asp:ListItem>
                                                            </asp:DropDownList>
                                                            <asp:DropDownList ID="ddlPhonePrePrefix" runat="server">
                                                                <asp:ListItem Value="-1" Text=" "></asp:ListItem>
                                                                <asp:ListItem Value="1" Text="1"></asp:ListItem>
                                                                <asp:ListItem Value="2" Text="*"></asp:ListItem>
                                                            </asp:DropDownList>
                                                            <asp:Label ID="lblExtension" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                                runat="server" Text="שלוחה:"></asp:Label>
                                                            <asp:TextBox ID="txtExtension" Width="25px" runat="server"></asp:TextBox>
                                                            <asp:CompareValidator ID="vldPhone" runat="server" ControlToValidate="txtPhone" ValidationGroup="vldDeptEvent"
                                                                Operator="DataTypeCheck" Type="Integer" Text="*"></asp:CompareValidator>
                                                            <asp:CompareValidator ID="vldExtension" runat="server" ControlToValidate="txtExtension"
                                                                ValidationGroup="vldDeptEvent" Operator="DataTypeCheck" Type="Integer" Text="*"></asp:CompareValidator>
                                                            <asp:CustomValidator ID="vldAllPhoneControls" ClientValidationFunction="ValidateAllPhoneControls"
                                                                runat="server" Text="*" ValidationGroup="vldDeptEvent"></asp:CustomValidator>
                                                        </div>                                                                                                              
                                                    </td>
                                                    <td>
                                                      <asp:CheckBox ID="cbUpdateFromDeptPhones" runat="server" />
                                                        <asp:Label ID="lblUpdateFromDeptPhones" EnableTheming="false" CssClass="LabelNormalDirtyBlue_12"
                                                            runat="server" Text="מפרטי יחידה"></asp:Label>
                                                    </td>
                                                </tr>
                                                <tr style="display: none">
                                                    <td>
                                                        <asp:TextBox ID="txtDeptFirstPhone_PrePrefix" runat="server"></asp:TextBox>
                                                        <asp:TextBox ID="txtDeptFirstPhone_Prefix" runat="server"></asp:TextBox>
                                                        <asp:TextBox ID="txtDeptFirstPhone_Phone" runat="server"></asp:TextBox>
                                                        <asp:TextBox ID="txtDeptFirstPhone_Extension" runat="server"></asp:TextBox>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td style="padding-top: 5px" colspan="3">
                                                        <asp:Label ID="lblRemark" EnableTheming="false" Width="67px" CssClass="LabelBoldDirtyBlue"
                                                            runat="server" Text="הערה:"></asp:Label>
                                                        <asp:TextBox ID="txtRemark" runat="server" Width="360px"></asp:TextBox>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td colspan="3" style="padding-top:10px">
                                                        <table cellpadding="0" cellspacing="0">
                                                            <tr>
                                                                <td>
                                                                    <asp:Label EnableTheming="false" CssClass="LabelBoldDirtyBlue" runat="server" Width="60px">קבצים מקושרים:</asp:Label>
                                                                </td>
                                                                <td style="padding-right:4px">
                                                                    <asp:HiddenField ID="hdnFilePath" runat="server" />
                                                                </td>
                                                                <td align="left">                      
                                                                    <input type="file" id="inputUploadFile" runat="server"  />                                                                    
                                                                </td>
                                                                <td>
                                                                <table cellpadding="0" cellspacing="0">
                                                                        <tr>
                                                                            <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                                background-position: bottom left;">
                                                                                &nbsp;
                                                                            </td>
                                                                            <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                                background-repeat: repeat-x; background-position: bottom;">
                                                                                <asp:Button ID="btnAddFile" runat="server" Text="הוספה" CssClass="RegularUpdateButton"
                                                                                    CausesValidation="false" OnClick="AddFile_Click"></asp:Button>
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
                                                                <td>&nbsp;</td>
                                                                <td colspan="2" style="padding-right:9px">
                                                                    <asp:GridView ID="gvAttachedFiles" runat="server" AutoGenerateColumns="false" ShowHeader="false"
                                                                        SkinID="GridViewForZoomLists" Width="100%" >
                                                                        <Columns>
                                                                            <asp:TemplateField>
                                                                                <ItemTemplate>
                                                                                    <asp:Label ID="lblFileDesc" runat="server" Text='<%# Eval("FileDescription") %>'></asp:Label>
                                                                                </ItemTemplate>                                                                                
                                                                            </asp:TemplateField>
                                                                            <asp:TemplateField>
                                                                                <ItemTemplate>
                                                                                    <asp:ImageButton runat="server" ID="lnkDeleteFileAttached" ImageUrl="~/Images/Applic/btn_X_red.gif"
                                                                                        CommandArgument='<%# Eval("DeptEventFileID") %>' OnClick="FileDelete_Click" />
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
                        <td style="padding-right: 5px; padding-top: 5px; height: 300px" valign="top">
                            <!-- Left side -->
                            <table cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7">
                                <tr>
                                    <td style="height: 10px; background-image: url('../Images/Applic/RTcornerGrey10.gif');
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
                                    <td valign="top">
                                        <!-- tblDetails Left -->
                                        <div style="height: 450px">
                                            <table width="460px" cellpadding="0" cellspacing="0" border="0">
                                                <tr>
                                                    <td>
                                                        <asp:Label ID="lblDetailesCaption" runat="server" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                            Text="פרטי מפגשים"></asp:Label>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td style="margin: 0px 0px 0px 0px; padding: 0px 0px 0px 0px;">
                                                        <table cellpadding="0" cellspacing="0" border="0">
                                                            <tr>
                                                                <td>
                                                                    <asp:Label ID="lblDay" runat="server" EnableTheming="false" CssClass="LabelNormalDirtyBlue_12"
                                                                        Text="יום"></asp:Label>
                                                                </td>
                                                                <td>
                                                                </td>
                                                                <td style="padding-right: 10px">
                                                                    <asp:Label ID="lblFromHour" runat="server" EnableTheming="false" CssClass="LabelNormalDirtyBlue_12"
                                                                        Text="משעה"></asp:Label>
                                                                </td>
                                                                <td>
                                                                </td>
                                                                <td style="padding-right: 5px">
                                                                    <asp:Label ID="lblToHour" runat="server" EnableTheming="false" CssClass="LabelNormalDirtyBlue_12"
                                                                        Text="עד"></asp:Label>
                                                                </td>
                                                                <td>
                                                                </td>
                                                                <td style="padding-right: 10px">
                                                                    <asp:Label ID="lblAddDeptEventParticulars" runat="server" Text="כמות מפגשים" EnableTheming="false"
                                                                        CssClass="LabelNormalDirtyBlue_12"></asp:Label>
                                                                </td>
                                                                <td>
                                                                </td>
                                                                <td>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td style="text-align:right;direction:ltr;width: 130px; margin: 0px 0px 0px 0px; padding: 0px 0px 0px 0px;">
                                                                    <asp:ImageButton ImageUrl="~/Images/Applic/calendarIcon.png" ID="btnRunCalendar_Date"
                                                                        runat="server" />
                                                                    
                                                                    <asp:TextBox ID="txtDate" Width="70px" runat="server"></asp:TextBox>
                                                                    <asp:TextBox ID="txtDay" Width="20px" runat="server"></asp:TextBox>
                                                                    <ajaxToolkit:CalendarExtender ID="calExtFromDate_DeptName" runat="server" Format="dd/MM/yyyy"
                                                                        FirstDayOfWeek="Sunday" TargetControlID="txtDate" PopupPosition="BottomRight"
                                                                        PopupButtonID="btnRunCalendar_Date" OnClientDateSelectionChanged="checkDate">
                                                                    </ajaxToolkit:CalendarExtender>
                                                                    <ajaxToolkit:MaskedEditExtender ID="DateExtender" runat="server" AcceptAMPM="false"
                                                                        ErrorTooltipEnabled="True" Mask="99/99/9999" MaskType="Date" MessageValidatorTip="true"
                                                                        OnFocusCssClass="MaskedEditFocus" OnInvalidCssClass="MaskedEditError" TargetControlID="txtDate">
                                                                    </ajaxToolkit:MaskedEditExtender>
                                                                </td>
                                                                <td style="width: 10px">
                                                                    <ajaxToolkit:MaskedEditValidator ID="DateValidator" runat="server" ControlExtender="DateExtender"
                                                                        ControlToValidate="txtDate" IsValidEmpty="True" InvalidValueMessage="התאריך אינו תקין"
                                                                        Display="Dynamic" InvalidValueBlurredMessage="*" ValidationGroup="vgrAddEvent"
                                                                        Text="*" />
                                                                </td>
                                                                <td style="padding-right: 10px;">
                                                                    <asp:TextBox ID="txtFromHour" runat="server" dir="ltr" Width="40px"></asp:TextBox>
                                                                    <ajaxToolkit:MaskedEditExtender ID="FromHourExtender" runat="server" AcceptAMPM="false"
                                                                        ErrorTooltipEnabled="True" Mask="99:99" MaskType="Time" MessageValidatorTip="true"
                                                                        OnFocusCssClass="MaskedEditFocus" OnInvalidCssClass="MaskedEditError" TargetControlID="txtFromHour">
                                                                    </ajaxToolkit:MaskedEditExtender>
                                                                </td>
                                                                <td style="width: 10px">
                                                                    <ajaxToolkit:MaskedEditValidator ID="FromHourValidator" runat="server" ControlExtender="FromHourExtender"
                                                                        ControlToValidate="txtFromHour" IsValidEmpty="False" InvalidValueMessage="השעה אינה תקינה"
                                                                        Display="Dynamic" EmptyValueBlurredText="*&nbsp;&nbsp;" InvalidValueBlurredMessage="*&nbsp;&nbsp;" ValidationGroup="vgrAddEvent"
                                                                        Text="*&nbsp;&nbsp;" />
                                                                </td>
                                                                <td style="padding-right: 5px">
                                                                    <asp:TextBox ID="txtToHour" runat="server" dir="ltr" Width="40px"></asp:TextBox>
                                                                    <ajaxToolkit:MaskedEditExtender ID="ToHourExtender" runat="server" AcceptAMPM="false"
                                                                        ErrorTooltipEnabled="True" Mask="99:99" MaskType="Time" MessageValidatorTip="true"
                                                                        OnFocusCssClass="MaskedEditFocus" OnInvalidCssClass="MaskedEditError" TargetControlID="txtToHour">
                                                                    </ajaxToolkit:MaskedEditExtender>
                                                                </td>
                                                                <td style="width: 10px">
                                                                    <ajaxToolkit:MaskedEditValidator ID="MaskedEditValidator1" runat="server" ControlExtender="ToHourExtender"
                                                                        ControlToValidate="txtToHour" IsValidEmpty="False" InvalidValueMessage="השעה אינה תקינה"
                                                                        Display="Dynamic" EmptyValueBlurredText="*&nbsp;&nbsp;" InvalidValueBlurredMessage="*&nbsp;&nbsp;" ValidationGroup="vgrAddEvent"
                                                                        Text="*&nbsp;&nbsp;" />
                                                                </td>
                                                                <td style="width: 90px; padding-right: 10px">
                                                                    <asp:TextBox ID="txtNumberParticularsToAdd" runat="server" Width="20px"></asp:TextBox>
                                                                    <asp:CompareValidator ID="vldNumberParticularsComp" runat="server" ControlToValidate="txtNumberParticularsToAdd"
                                                                        Text="*&nbsp;&nbsp;" ValidationGroup="vgrAddEvent" Operator="DataTypeCheck" Type="Integer"></asp:CompareValidator>
                                                                    <asp:RequiredFieldValidator ID="vldNumberParticulars" runat="server" ControlToValidate="txtNumberParticularsToAdd"
                                                                        Text="*&nbsp;&nbsp;" ValidationGroup="vgrAddEvent"></asp:RequiredFieldValidator>
                                                                </td>
                                                                <td style="width: 20px">
                                                                    &nbsp;
                                                                </td>
                                                                <td style="margin: 0px 0px 0px 0px; padding: 0px 5px 0px 0px;">
                                                                    <table cellpadding="0" cellspacing="0">
                                                                        <tr>
                                                                            <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                                background-position: bottom left;">
                                                                                &nbsp;
                                                                            </td>
                                                                            <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                                background-repeat: repeat-x; background-position: bottom;">
                                                                                <asp:Button ID="btnAddDeptEventParticulars" runat="server" Text="הוספה" CssClass="RegularUpdateButton"
                                                                                    ValidationGroup="vgrAddEvent" OnClick="btnAddDeptEventParticulars_Click"></asp:Button>
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
                                                    <td style="padding-top: 10px">
                                                        <asp:GridView ID="gvEventParticulars" runat="server" SkinID="GridViewForUpdatePage"
                                                            AutoGenerateColumns="false" OnRowDataBound="gvEventParticulars_RowDataBound"
                                                            OnRowDeleting="gvEventParticulars_RowDeleting">
                                                            <Columns>
                                                                <asp:TemplateField HeaderText="יום" ItemStyle-Width="140px">
                                                                    <ItemTemplate>
                                                                        <table cellpadding="0" cellspacing="0">
                                                                            <tr>
                                                                                <td style="text-align:right;width:140px;direction:ltr;margin: 0px 0px 0px 0px; padding: 0px 0px 0px 0px;">
                                                                                    <ajaxToolkit:MaskedEditValidator ID="DateValidator" runat="server" ControlExtender="DateExtender"
                                                                                        ControlToValidate="txtDate" IsValidEmpty="True" InvalidValueMessage="התאריך אינה תקינה"
                                                                                        Display="Dynamic" InvalidValueBlurredMessage="*&nbsp;&nbsp;" ValidationGroup="vgrAddEvent" />
                                                                                    <asp:ImageButton ImageUrl="~/Images/Applic/calendarIcon.png" ID="btnRunCalendar_Date"
                                                                                        runat="server" />
                                                                                    <asp:TextBox ID="txtDate" Width="70px" runat="server" Text='<%# Bind("Date","{0:d}") %>'></asp:TextBox>
                                                                                    <asp:TextBox ID="txtDay" Width="20px" runat="server"></asp:TextBox>
                                                                                    
                                                                                    
                                                                                    <ajaxToolkit:CalendarExtender ID="calExtFromDate_DeptName" runat="server" Format="dd/MM/yyyy"
                                                                                        FirstDayOfWeek="Sunday" TargetControlID="txtDate" PopupPosition="BottomRight"
                                                                                        PopupButtonID="btnRunCalendar_Date" OnClientDateSelectionChanged="checkDate">
                                                                                    </ajaxToolkit:CalendarExtender>
                                                                                    <ajaxToolkit:MaskedEditExtender ID="DateExtender" runat="server" AcceptAMPM="false"
                                                                                        ErrorTooltipEnabled="True" Mask="99/99/9999" MaskType="Date" MessageValidatorTip="true"
                                                                                        OnFocusCssClass="MaskedEditFocus" OnInvalidCssClass="MaskedEditError" TargetControlID="txtDate">
                                                                                    </ajaxToolkit:MaskedEditExtender>
                                                                                    
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField HeaderText="משעה" ItemStyle-Width="45px">
                                                                    <ItemTemplate>
                                                                        <table cellpadding="0" cellspacing="0">
                                                                            <tr>
                                                                                <td>
                                                                                    <asp:TextBox ID="txtFromHour" runat="server" dir="ltr" Width="40px" Text='<%# Bind("OpeningHour") %>'></asp:TextBox>
                                                                                    <ajaxToolkit:MaskedEditExtender ID="FromHourExtender" runat="server" AcceptAMPM="false"
                                                                                        ErrorTooltipEnabled="True" Mask="99:99" MaskType="Time" MessageValidatorTip="true"
                                                                                        OnFocusCssClass="MaskedEditFocus" OnInvalidCssClass="MaskedEditError" TargetControlID="txtFromHour">
                                                                                    </ajaxToolkit:MaskedEditExtender>
                                                                                    <ajaxToolkit:MaskedEditValidator ID="FromHourValidator" runat="server" ControlExtender="FromHourExtender"
                                                                                        ControlToValidate="txtFromHour" IsValidEmpty="False" EmptyValueMessage="יש להזין שעה"
                                                                                        InvalidValueMessage="השעה אינה תקינה" Display="Dynamic" TooltipMessage="יש להזין שעה"
                                                                                        EmptyValueBlurredText="*" InvalidValueBlurredMessage="*" ValidationGroup="vgrAddEvent" />
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField HeaderText="עד" ItemStyle-Width="55px">
                                                                    <ItemTemplate>
                                                                        <table cellpadding="0" cellspacing="0">
                                                                            <tr>
                                                                                <td>
                                                                                    <asp:TextBox ID="txtToHour" runat="server" dir="ltr" Width="40px" Text='<%# Bind("ClosingHour") %>'></asp:TextBox>
                                                                                    <ajaxToolkit:MaskedEditExtender ID="ToHourExtender" runat="server" AcceptAMPM="false"
                                                                                        ErrorTooltipEnabled="True" Mask="99:99" MaskType="Time" MessageValidatorTip="true"
                                                                                        OnFocusCssClass="MaskedEditFocus" OnInvalidCssClass="MaskedEditError" TargetControlID="txtToHour">
                                                                                    </ajaxToolkit:MaskedEditExtender>
                                                                                    <ajaxToolkit:MaskedEditValidator ID="MaskedEditValidator1" runat="server" ControlExtender="ToHourExtender"
                                                                                        ControlToValidate="txtToHour" IsValidEmpty="False" EmptyValueMessage="יש להזין שעה"
                                                                                        InvalidValueMessage="השעה אינה תקינה" Display="Dynamic" TooltipMessage="יש להזין שעה"
                                                                                        EmptyValueBlurredText="*" InvalidValueBlurredMessage="*" ValidationGroup="vgrAddEvent" />
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField HeaderText="משך" ItemStyle-Width="70px">
                                                                    <ItemTemplate>
                                                                        <table cellpadding="0" cellspacing="0">
                                                                            <tr>
                                                                                <td>
                                                                                    <asp:TextBox ID="txtDuration" runat="server" Width="25px"></asp:TextBox>
                                                                                    <asp:Label ID="lblDuration" runat="server" Text="שעות" EnableTheming="false" CssClass="LabelNormalDirtyBlue_12"></asp:Label>
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:CommandField ShowDeleteButton="True" ButtonType="Image" DeleteText="לםחוק רשומה"
                                                                    DeleteImageUrl="~/Images/Applic/btn_X_red.gif" />
                                                            </Columns>
                                                        </asp:GridView>
                                                    </td>
                                                </tr>
                                            </table>
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
                </table>
            </td>
        </tr>
        <tr>
            <td style="padding-right: 10px; padding-top: 5px">
                <table cellpadding="0" cellspacing="0" style="background-color: #298AE5; height: 30px;"
                    width="100%">
                    <tr>
                        <td align="left" style="width: 100%">
                            <table cellpadding="0" cellspacing="0">
                                <tr>
                                    <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                        background-position: bottom left;">
                                        &nbsp;
                                    </td>
                                    <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                        background-repeat: repeat-x; background-position: bottom;">
                                        <asp:Button ID="btnSaveBottom" runat="server" Text="שמירה" CssClass="RegularUpdateButton"
                                            ValidationGroup="vldDeptEvent" OnClick="btnSave_Click"></asp:Button>
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
                                        <asp:Button ID="btnCancelBottom" runat="server" CssClass="RegularUpdateButton" Text="ביטול"
                                            CausesValidation="False" OnClick="btnCancel_Click" />
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
