<%@ Reference Page="AdminBasePage.aspx" %>

<%@ Page Language="C#" AutoEventWireup="true" Title="עדכון שעות קבלה ליחידה"
    MasterPageFile="~/seferMasterPageIE.master" Inherits="Admin_UpdateDeptReceptionHours"
    Culture="he-il" UICulture="he-il" Codebehind="UpdateDeptReceptionHours.aspx.cs" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<%@ Register Assembly="System.Web.Extensions, Version=1.0.61025.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
    Namespace="System.Web.UI" TagPrefix="asp" %>
<%@ MasterType VirtualPath="~/seferMasterPageIE.master" %>
<%@ Register Src="../UserControls/GridDeptReceptionHoursUC.ascx" TagName="GridDeptReceptionHoursUC"
    TagPrefix="uc2" %>
    <%@ Register Src="../UserControls/CustomPopUp.ascx" TagName="CustomPopUp"
    TagPrefix="uc3" %>
<asp:Content ID="Content1" ContentPlaceHolderID="pageContent" runat="server">
    
    
    
    <script type="text/javascript">

        var lblWeekDaysNotInDateRangeClientID = '<%=lblWeekDaysNotInDateRange.ClientID %>'

        function ClearlblWeekDaysNotInDateRange() {
            document.getElementById(lblWeekDaysNotInDateRangeClientID).innerHTML = "";
        }

        function ClearAllControlsForTemporapilyClose() {
            // checkboxlistDays
            //alert('ClearAllControlsForTemporapilyClose');
            $('[id*=checkboxlistDays]').prop('checked', false);

            ClearlblWeekDaysNotInDateRange();
        }

        function Check_UncheckAll() {

            if ($('[id*=cbAll]').prop("checked")) {
                //alert('checked')
                $('[id*=checkboxlistDays]').prop('checked', true);
            }
            else {
                //(alert('NOT checked')
                $('[id*=checkboxlistDays]').prop('checked', false);
            }
        }


        function GetScrollPosition(obj) {
            document.getElementById('<%=txtScrollTop.ClientID %>').value = obj.scrollTop;
        }

        function changeReceptionHoursTypes() {
            var res = true;
            $("#" + "<%=hfOnSelectedChangeEventFlag.ClientID %>").val(1);
            if ($("#" + hfUpdateFlagClientID).val() == "1") {
                showAlert("?האם ברצונך לשמור את העדכונים", "שמור", "המשך בלי לשמור", "70", "350");

            }
            else {
                $("#" + "<%=btnSubmitForm.ClientID %>")[0].click();
            }

        }

        function SetCreateTemporarilyClosedFlag() {
            $("#" + "<%=hfCreateTemporarilyClosedFlag.ClientID %>").val(1);
        }

        function alertClickEvent() {
            if (alertReturnValue == 1) {
                $("#" + "<%=hfUpdateFlag.ClientID %>").val(1);
            }

            $("#" + "<%=btnSubmitForm.ClientID %>")[0].click();
        }

        function GoCopyClinicHours() {
            if (confirm('?האם לאשר העתקה "שעות קבלה ליחידה" עבור סוג שעות זה')) {

                return true;
            }
            else {
                return false;
            }

        }

        function ShowTemporarilyClose() {
            document.getElementById('divTemporalilyClosed').style.display = 'block';
            document.getElementById('divReceptionHours').style.display = 'none';
            //ClearAllControlsForTemporapilyClose();
            return false;
        }

        function HideTemporarilyClose() {
            document.getElementById('divTemporalilyClosed').style.display = 'none';
            document.getElementById('divReceptionHours').style.display = 'block';
            return false;
        }

        function ValidateParameters(val, args) {
            var ClosedFrom = document.getElementById('<%=txtClosedFrom.ClientID %>').value;
            var ClosedTo = document.getElementById('<%=txtClosedTo.ClientID %>').value;

            var ArrayFrom = ClosedFrom.split('/');
            var ArrayTo = ClosedTo.split('/');

            var closedFromDate = new Date(ArrayFrom[2], ArrayFrom[1] - 1, ArrayFrom[0]);
            var closedToDate = new Date(ArrayTo[2], ArrayTo[1] - 1, ArrayTo[0]);

            if (closedToDate < closedFromDate)
                    args.IsValid = false;
                else
                    args.IsValid = true;
        }

        function OpenReceptionHoursPreview() {
            var url = "ReceptionHoursPreview.aspx";

            var dialogWidth = 750;
            var dialogHeight = 420;
            var title = "תצוגה מקדימה";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title, "right");

            return false;
        }
    </script>

    <table cellpadding="0" cellspacing="0">
        <tr id="trError" runat="server">
            <td>
                <asp:Label ID="lblGeneralError" runat="server" SkinID="lblError"></asp:Label>
            </td>
        </tr>
    </table>
    <div id="divTemporalilyClosed" style="display:none; width:1200px; justify-content:center;">
        <table width="450px" border="0" style="align-self: center; margin-right:auto; margin-left:auto; border:1px solid grey">
            <tr>
                <td style="background-color: #298AE5; height:30px;" align="center" > 
                    <asp:Label ID="lblTemporarilyCloseTitle" EnableTheming="false" CssClass="LabelBoldWhite_18" runat="server" Text="סגירה זמנית של שעות קבלה ליחידה"></asp:Label>
                    <br />
                    <asp:Label ID="lblDeptName_2" EnableTheming="false" CssClass="LabelBoldWhite_14" runat="server" Text=""></asp:Label>
                </td>

            </tr>
            <tr>
                <td style="padding-right:20px; height:40px;">
                    <asp:Label ID="lblCheckBoxTitle" runat="server" Text="בחירת ימים לסגירת שעות קבלה:"></asp:Label>
                </td>
            </tr>
            <tr>
                <td dir="ltr" align="right" style="padding-right:24px">
                    <asp:CheckBoxList id= "checkboxlistDays" OnClick="ClearlblWeekDaysNotInDateRange();"
                        AutoPostBack = "false" TextAlign = "Right" runat= "server" EnableTheming="false" CssClass="RegularCheckBoxList">
                    <asp:ListItem>&nbsp; א </asp:ListItem>
                    <asp:ListItem>&nbsp; ב </asp:ListItem>
                    <asp:ListItem>&nbsp; ג </asp:ListItem>
                    <asp:ListItem>&nbsp; ד </asp:ListItem>
                    <asp:ListItem>&nbsp; ה </asp:ListItem>
                    <asp:ListItem>&nbsp; ו </asp:ListItem>
                    <asp:ListItem>&nbsp; ש </asp:ListItem>
                    </asp:CheckBoxList>
                </td>
            </tr>
            <tr>
                <td style="padding-right:20px; direction:ltr; text-align:right">
                    <asp:CheckBox ID="cbAll" runat="server" AutoPostBack="false" OnClick = "Check_UncheckAll();" Text=" הכל " CssClass="RegularCheckBoxList" />
                </td>
            </tr>
            <tr>
                <td style="padding-right:20px">
                    <asp:Label ID="lblWeekDaysNotInDateRange" runat="server" CssClass="LabelBoldRed12" EnableTheming="false" Text="lblWeekDaysNotInDateRange"></asp:Label>
                </td>
            </tr>
            <tr>
                <td style="padding-right:20px; height:40px;">
                    <asp:Label ID="lblDatesRange" runat="server" Text="טווח התאריכים בהם היחידה תהיה סגורה:"></asp:Label>
                </td>
            </tr>
            <tr>
                <td>
                    <table>
                        <tr>
                            <td style="padding-right:18px">
                                <asp:Label ID="lblClosedFrom" runat="server" Text="תוקף מ:"></asp:Label>
                            </td>
                            <td dir="ltr" style="vertical-align: top; padding-right: 10px;">
                                <ajaxtoolkit:MaskedEditExtender ID="DateClosedFromExtender" runat="server" AcceptAMPM="false"
                                    ClearMaskOnLostFocus="false" ErrorTooltipEnabled="True" Mask="99/99/9999" MaskType="Date"
                                    MessageValidatorTip="true" OnFocusCssClass="MaskedEditFocus" OnInvalidCssClass="MaskedEditError"
                                    TargetControlID="txtClosedFrom">
                                </ajaxtoolkit:MaskedEditExtender>
                                <div style="width:8px; display:inline-block;">
                                    <ajaxtoolkit:MaskedEditValidator ID="DateValidator" runat="server" ControlExtender="DateClosedFromExtender"
                                        ControlToValidate="txtClosedFrom" Display="Dynamic" InvalidValueBlurredMessage="*"
                                        InvalidValueMessage="התאריך 'תוקף מ' אינו תקין" IsValidEmpty="True" Text="*" ValidationGroup="vgrTemporarilyClosed">
                                    </ajaxtoolkit:MaskedEditValidator>
                                </div>
                                <ajaxtoolkit:CalendarExtender ID="calendarFrom" runat="server" FirstDayOfWeek="Sunday"
                                    Format="dd/MM/yyyy" OnClientDateSelectionChanged="checkDate" PopupButtonID="btnCalendarFrom"
                                    PopupPosition="TopRight" TargetControlID="txtClosedFrom">
                                </ajaxtoolkit:CalendarExtender>
                                <asp:ImageButton ID="btnCalendarFrom" runat="server" ImageUrl="~/Images/Applic/calendarIcon.png" />
                                <asp:TextBox ID="txtClosedFrom" runat="server" Width="70px" ValidationGroup="vgrTemporarilyClosed"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="vldClosedFrom" runat="server" ControlToValidate="txtClosedFrom" Text="*" ErrorMessage="חובה להזין 'תוקף מ'" ValidationGroup="vgrTemporarilyClosed"  ></asp:RequiredFieldValidator>
                            </td>
                            <td>
                                <asp:Label ID="lblClosedTo" runat="server" Text="תוקף עד (כולל):"></asp:Label>
                            </td>
                            <td dir="ltr" style="vertical-align: top; padding-right: 10px;">
                               <ajaxtoolkit:MaskedEditExtender ID="DateClosedToExtender" runat="server" AcceptAMPM="false"
                                    ClearMaskOnLostFocus="false" ErrorTooltipEnabled="True" Mask="99/99/9999" MaskType="Date"
                                    MessageValidatorTip="true" OnFocusCssClass="MaskedEditFocus" OnInvalidCssClass="MaskedEditError"
                                    TargetControlID="txtClosedTo">
                                </ajaxtoolkit:MaskedEditExtender>
                                <div style="width:8px; display:inline-block;">
                                    <ajaxtoolkit:MaskedEditValidator ID="DateClosedToValidator" runat="server" ControlExtender="DateClosedToExtender"
                                        ControlToValidate="txtClosedTo" Display="Dynamic" InvalidValueBlurredMessage="*"
                                        InvalidValueMessage="התאריך 'תוקף עד' אינו תקין" IsValidEmpty="True" Text="*" ValidationGroup="vgrTemporarilyClosed">
                                    </ajaxtoolkit:MaskedEditValidator>
                                </div>
                                <ajaxtoolkit:CalendarExtender ID="calendarTo" runat="server" FirstDayOfWeek="Sunday"
                                    Format="dd/MM/yyyy" OnClientDateSelectionChanged="checkDate" PopupButtonID="btnCalendarTo"
                                    PopupPosition="TopRight" TargetControlID="txtClosedTo">
                                </ajaxtoolkit:CalendarExtender>
                                <asp:ImageButton ID="btnCalendarTo" runat="server" ImageUrl="~/Images/Applic/calendarIcon.png" />
                                <asp:TextBox ID="txtClosedTo" runat="server" Width="70px" ValidationGroup="vgrTemporarilyClosed"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="vldClosedTo" runat="server" ControlToValidate="txtClosedTo" Text="9" ErrorMessage="חובה להזין 'תוקף עד'" ValidationGroup="vgrTemporarilyClosed"  ></asp:RequiredFieldValidator>
                            </td>
                            <td>
		                        <asp:CustomValidator ID="vldCustomTemporarilyClosed" runat="server" Text="*" ErrorMessage="תאריך 'תוקף מי' חייב להיות שווה או קטן מתאריך 'תוקף עד'" CssClass="DisplayNone"
		                        ValidationGroup="vgrTemporarilyClosed" ClientValidationFunction="ValidateParameters" ></asp:CustomValidator>
                            </td>
                        </tr>

                    </table>

                </td>
            </tr>
            <tr>
                <td style="padding-right:30px">
                    <asp:ValidationSummary ID="vldSummaryTemporarilyClosed" runat="server" ValidationGroup="vgrTemporarilyClosed" />
                </td>
            </tr>
            <tr>
                <td align="left" style="padding-left: 10px">
                    <table cellpadding="0" cellspacing="0">
                        <tr>
                            <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                background-position: bottom left;">
                                &nbsp;
                            </td>
                            <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                background-repeat: repeat-x; background-position: bottom;">
                                <asp:Button ID="btnCreateTemporarilyClosed" runat="server" Text="שמירה" CssClass="RegularUpdateButton" ValidationGroup="vgrTemporarilyClosed" 
                                    OnClientClick=" SetCreateTemporarilyClosedFlag()" OnClick="btnCreateTemporarilyClosed_Click" ></asp:Button>
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
                                <asp:Button ID="btnCancelTemporarilyClose" runat="server" CssClass="RegularUpdateButton" Text="ביטול"
                                    CausesValidation="False" OnClientClick="HideTemporarilyClose(); return false;" />
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
    </div>
    <div id="divReceptionHours" style="display:block">
    <table cellspacing="0" cellpadding="0" dir="rtl">
        <tr>
            <td style="padding-right: 10px" colspan="2">
                <!-- Upper Blue Bar -->
                <table cellpadding="2" cellspacing="0" style="background-color: #298AE5; height: 30px;"
                    width="1200px">
                    <tr>
                        <td style="padding-right: 15px">
                            <asp:Label ID="lblDeptName" EnableTheming="false" CssClass="LabelBoldWhite_18" runat="server"
                                Text=""></asp:Label>
                        </td>
                        <td align="left" style="padding-left: 10px">
                            <table cellpadding="0" cellspacing="0">
                                <tr>
                                    <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                        background-position: bottom left;">
                                        &nbsp;
                                    </td>
                                    <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                        background-repeat: repeat-x; background-position: bottom;">
                                        <asp:Button ID="btnUpdate" runat="server" Text="שמירה" CssClass="RegularUpdateButton" ValidationGroup="vgrFirstSectionValidation" 
                                            OnClick="btnUpdateBottom_Click" OnClientClick="javascript:showProgressBarGeneral('vgrFirstSectionValidation');"></asp:Button>
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
                                            CausesValidation="False" OnClick="btnBackToOpenerBottom_Click" />
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
            <td style="padding-right: 10px" colspan="2">
                <!-- Service Hours -->
                <table cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7">
                    <tr>
                        <td style="height: 8px; background-image: url('../Images/Applic/RTcornerGrey10.gif');
                            background-repeat: no-repeat; background-position: top right">
                        </td>
                        <td style=" background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x; background-position: top">
                        </td>
                        <td style=" background-image: url('../Images/Applic/LTcornerGrey10.gif');
                                background-repeat: no-repeat;
                                background-position: top left">
                        </td>
                    </tr>
                    <tr>
                        <td style="border-right: solid 2px #909090;">
                            <div style="width: 2px;">
                            </div>
                        </td>
                        <td>
                            <table cellpadding="0" cellspacing="0">
                                <tr>
                                    <td>
                                        <div style="width: 1180px;">
                                            <table id="tblServiceHours" runat="server" cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td>
                                                        <asp:TextBox ID="txtScrollTop" runat="server" CssClass="DisplayNone" EnableTheming="false"></asp:TextBox>
                                                        <div id="divGvClinicList" onscroll="GetScrollPosition(this)" class="ScrollBarDiv"
                                                            runat="server" style="height: 350px; overflow-y: scroll; overflow-x:hidden;">
                                                            <div style="background-color:#D6E7FF;padding-right:10px;padding-top:3px;">

                                                            <table cellpadding="0" cellspacing="0" border="0">
                                                                <tr>
                                                                    <td style="width:190px">
                                                                        <span class="RegularLabel">סוג שעות:</span>
                                                                        <asp:DropDownList ID="ddlReceptionHoursTypes" runat="server"
                                                                            DataTextField="ReceptionTypeDescription" 
                                                                            DataValueField="ReceptionHoursTypeID">
                                                                        </asp:DropDownList> 
                                                                    </td>
                                                                    <td style="width:675px">&nbsp;</td>
                                                                    <td>
                                                                        <table cellpadding="0" cellspacing="0" id="tblTemporarilyClose" runat="server">
                                                                            <tr>
                                                                                <td class="buttonRightCorner" style="padding-right: 3px">
                                                                                </td>                              
                                                                                <td  class="buttonCenterBackground">
                                                                                    <asp:Button ID="btnTemporarilyClose" Text="סגירה זמנית" Width="120px" runat="server" CssClass="RegularUpdateButton" 
                                                                                        OnClientClick="ShowTemporarilyClose();ClearAllControlsForTemporapilyClose(); return false;" />                                                                               
                                                                                </td>
                                                                                <td class="buttonLeftCorner" style="padding-left: 3px">
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </td>
                                                                    <td >
                                                                        <table cellpadding="0" cellspacing="0">
                                                                            <tr>
                                                                                <td class="buttonRightCorner" style="padding-right: 3px">
                                                                                </td>
                                                                                <td class="buttonCenterBackground">
                                                                                    <asp:Button ID="btnCopyClinicHours" Text="העתקת שעות יחידה" Width="120px" runat="server" CssClass="RegularUpdateButton" 
                                                                                        OnClientClick="return GoCopyClinicHours();" OnClick="btnCopyClinicHours_Click"/>
                                                                                </td>
                                                                                <td class="buttonLeftCorner" style="padding-right: 3px">
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                            <label id="lblOverlapingHoursRemark" style="padding-right:50px; display:none; color:orangered; font-size:13px; font-weight:bold">קיימת כפילות בשעות הקבלה – יש להזין הערות בימים החופפים</label>

                                                            </div>
                                                            <uc2:GridDeptReceptionHoursUC  Width="1160px" ID="gvReceptionHours" runat="server" />
                                                        </div>
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td style="border-left: solid 2px #909090;">
                            <div style="width: 2px;">
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
            <td colspan="2" align="left" style="padding-left: 10px">
                <div style="white-space: nowrap; padding-top:5px; padding-bottom:5px">
                    <div style="display: inline-block; vertical-align: middle;">
                    <asp:Label ID="WarningPreviewHours" runat="server" Text="שימו לב יש ללחוץ על כפתור שמירה לאחר עדכון שעות הפעילות."
                        CssClass="LabelWarningOrange" EnableTheming="false"> </asp:Label>
                    </div>
                    <div style="display: inline-block; vertical-align: middle;">
                    <table cellpadding="0" cellspacing="0" border="0">
                        <tr>
                            <td class="buttonRightCorner">
                            </td>
                            <td class="buttonCenterBackground">
                                <asp:Button ID="btnShowReceptionPreview" Text="תצוגה מקדימה" runat="server" CssClass="RegularUpdateButton"
                                    OnClick="ShowReceptionPreview" />
                            </td>
                            <td class="buttonLeftCorner">
                            </td>
                        </tr>
                    </table>
                    </div>
                </div>
            </td>
        </tr>
        <tr>
            <td style="padding-right: 10px" colspan="2">
                <!-- Lower Blue Bar -->
                <table cellpadding="0" cellspacing="0" style="background-color: #298AE5; height: 30px;"
                    width="1200px">
                    <tr>
                        <td align="left" style="padding-left: 10px">
                            <table cellpadding="0" cellspacing="0">
                                <tr>
                                    <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                        background-position: bottom left;">
                                        &nbsp;
                                    </td>
                                    <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                        background-repeat: repeat-x; background-position: bottom;">
                                        <asp:Button ID="btnUpdateBottom" runat="server" Text="שמירה" CssClass="RegularUpdateButton"
                                            ValidationGroup="vgrFirstSectionValidation" OnClick="btnUpdateBottom_Click" OnClientClick="javascript:showProgressBarGeneral('vgrFirstSectionValidation');">
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
                                        <asp:Button ID="btnBackToOpenerBottom" runat="server" CssClass="RegularUpdateButton"
                                            Text="ביטול" CausesValidation="False" OnClick="btnBackToOpenerBottom_Click" />
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
    </div>

    <asp:Button ID="btnSubmitForm" runat="server" Width="0" Height="0" />    
    <asp:HiddenField ID="hfOnSelectedChangeEventFlag" runat="server" Value="" />
    <asp:HiddenField ID="hfCreateTemporarilyClosedFlag" runat="server" Value="" />
    <asp:HiddenField ID="hfUpdateFlag" runat="server" Value="" />
    <asp:HiddenField ID="hfSelectedHourTypeIDForUpdate" runat="server" />
    <uc3:CustomPopUp ID="customAlert" runat="server" />
</asp:Content>
