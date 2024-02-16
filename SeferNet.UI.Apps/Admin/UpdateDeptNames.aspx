<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="UpdateDeptNames" Culture="he-il" UICulture="he-il" Codebehind="UpdateDeptNames.aspx.cs" %>

<%@ Reference Page="~/Admin/AdminPopupBasePage.aspx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="-1" />
    <base target="_self" />
    <link rel="STYLESHEET" href="../CSS/General/general.css" type="text/css" />
    <title>עדכון שם ורמת שירות</title>
</head>
<body>
    <script type="text/javascript">
        function SelectJQueryClose() {
            window.parent.$("#dialog-modal-select").dialog('close');
            return false;
        }
    </script>

    <script language="JavaScript" src="../Scripts/ValidationMethods/Validation1.js" type="text/javascript"></script>
    <script  src="../Scripts/LoadJqueryIfNeeded.js" type="text/javascript"></script>

    <script type="text/javascript" language="javascript">
        function ShowDeptNamesHistory() {
            var trDeptNamesHistory = document.getElementById("trDeptNamesHistory");
            var btnShowDeptHamesHistory = document.getElementById('<%=btnShowDeptHamesHistory.ClientID %>');
            if (trDeptNamesHistory.style.display == "none") {
                trDeptNamesHistory.style.display = "inline";
                btnShowDeptHamesHistory.innerText = "הסתר היסטורית שמות";
            }
            else {
                trDeptNamesHistory.style.display = "none";
                btnShowDeptHamesHistory.innerText = "הצג היסטורית שמות";
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
                document.getElementById('lblError').innerHTML = "לא ניתן לבחור תאריך קטן מתאריך נוכחי";
                sender._selectedDate = new Date();
                // set the date back to the current date
                sender._textbox.set_Value(sender._selectedDate.format(sender._format))
            }
        }

        function checkDateOnChange(textBoxID) {
            var textBox = document.getElementById(textBoxID);
            var from = textBox.value;
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

            // compare with last existing ToDate
            if ($("body").find("[id*='txtToDate']").length > 0) {
                lastDateIndex = $("body").find("[id*='txtToDate']").length - 1;
                dateValue = $("body").find("[id*='txtToDate']")[lastDateIndex].value;

                var dateArr = dateValue.split('/');

                if (dateArr[0].charAt(0) == "0" && dateArr[0].length > 1)
                    dateArr[0] = dateArr[0].substring(1)

                if (dateArr[1].charAt(0) == "0" && dateArr[1].length > 1)
                    dateArr[1] = dateArr[1].substring(1)

                lastToDate = new Date();
                lastToDate.setUTCFullYear(parseInt(dateArr[2]));
                lastToDate.setUTCMonth(parseInt(dateArr[1]) - 1);
                lastToDate.setUTCDate(parseInt(dateArr[0]));

                if (receptionDateFrom <= lastToDate)
                    document.getElementById('lblError').innerHTML = "* תאריך חדש לא יכול להיות בעבר, וחייב להיות גדול מתאריך התחלת הסטטוס האחרון";

            }
            else {
                if (receptionDateFrom < currentDate) {
                    document.getElementById('lblError').innerHTML = "* לא ניתן לבחור תאריך קטן מתאריך נוכחי";

                    var d = new Date();

                    var LeadingZero_1 = '';
                    var LeadingZero_2 = '';

                    var curr_date = d.getDate();
                    var curr_month = d.getMonth();
                    curr_month++; //This is because months start at 0 value
                    var curr_year = d.getFullYear();

                    if (curr_date < 10)
                        LeadingZero_1 = '0';
                    if (curr_month < 10)
                        LeadingZero_2 = '0';

                    textBox.value = LeadingZero_1 + curr_date + "/" + LeadingZero_2 + curr_month + "/" + curr_year;
                }
            }


        }

        function selfClose() {
            self.close();
        }

        function GiveErrorMessage(errMessage) {
            alert(errMessage);
        }

        function JustGo() {
            SelectJQueryClose();
        }

        function JustGo_OLD() {
            var obj = new Object();
            obj.DataWasSaved = false;
            obj.NewDeptName = "";
            window.returnValue = obj;
            self.close();
        }

        function CheckDeptNameConsistency(val, args) {
            //debugger;
            var txtDeptNameToAdd = document.getElementById('<%=txtDeptNameToAdd.ClientID %>');
            var txtCityName = document.getElementById('<%=txtCityName.ClientID %>');
            var txtClinicType = document.getElementById('<%=txtClinicType.ClientID %>');
            if (txtDeptNameToAdd.value != "") {
                args.IsValid = true;
            }
            else {
                if (txtCityName.value != "" && txtClinicType.value != "") {
                    args.IsValid = true;
                }
                else {
                    args.IsValid = false;
                }
            }
        }

        function replaceApostrophe() {
            var txtDeptNameToAdd = document.getElementById('<%=txtDeptNameToAdd.ClientID %>');
            txtDeptNameToAdd.value = txtDeptNameToAdd.value.replace(/'/g, "`");
            var txtCityName = document.getElementById('<%=txtCityName.ClientID %>');
            txtCityName.value = txtCityName.value.replace(/'/g, "`");
        }
    </script>

    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnableScriptGlobalization="true"
        EnableScriptLocalization="true" />
    <table cellpadding="0" cellspacing="0" style="direction: rtl; width: 100%; background-color: White;">
        <tr>
            <td align="right" style="background-color: #298AE5; padding-right: 5px; height: 24px">
                <asp:Label ID="lblDeptNameLBHeader" EnableTheming="false" CssClass="LabelBoldWhite_18"
                    runat="server" Text="עדכון שם ורמת שירות"></asp:Label>
            </td>
        </tr>
        <tr>
            <td style="padding-right: 4px; padding-top: 6px">
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
                        <td>
                            <!--content-->
                            <table cellpadding="0" cellspacing="0" style="width: 670px">
                                <tr>
                                    <td style="padding: 0px 0px 0px 0px" dir="ltr" align="right">
                                        <div style="height: 170px; overflow-y: scroll" class="ScrollBarDiv">
                                            <table cellpadding="0" cellspacing="0" dir="rtl">
                                                <tr>
                                                    <td align="right" style="padding-right: 10px">
                                                        <asp:LinkButton ID="btnShowDeptHamesHistory" EnableTheming="false" CssClass="LooksLikeHRef"
                                                            runat="server" OnClientClick="ShowDeptNamesHistory(); return false;" Text="הצג היסטורית שמות"></asp:LinkButton>
                                                    </td>
                                                </tr>
                                                <tr id="trDeptNamesHistory" style="display: none">
                                                    <td align="right" style="padding-right: 10px;">
                                                        <asp:GridView ID="gvDeptNamesHistory" SkinID="SimpleGridViewNoEmtyDataText" runat="server"
                                                            AutoGenerateColumns="false" HeaderStyle-CssClass="DisplayNone" OnRowDataBound="gvDeptNamesHistory_RowDataBound">
                                                            <Columns>
                                                                <asp:TemplateField ItemStyle-Width="425px">
                                                                    <ItemTemplate>
                                                                        <asp:Label ID="lblDeptName" Width="420px" EnableTheming="false" CssClass="RegularLabelNormal_13"
                                                                            runat="server" Text='<%#Eval("deptName") %>'></asp:Label>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField ItemStyle-Width="80px">
                                                                    <ItemTemplate>
                                                                        <asp:Label ID="lblFromDate" Width="80px" EnableTheming="false" CssClass="RegularLabelNormal_13"
                                                                            runat="server" Text='<%#Eval("fromDate","{0:d}") %>'></asp:Label>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField ItemStyle-Width="80px">
                                                                    <ItemTemplate>
                                                                        <asp:Label ID="lblToDate" Width="80px" EnableTheming="false" CssClass="RegularLabelNormal_13"
                                                                            runat="server" Text='<%#Eval("toDate","{0:d}") %>'></asp:Label>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                            </Columns>
                                                        </asp:GridView>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td style="padding-right:10px">
                                                        <asp:Label runat="server" Width="420px">שם</asp:Label>
                                                        <asp:Label runat="server" Width="90px">מתאריך</asp:Label>                                                    
                                                        <asp:Label runat="server" Width="70px">עד תאריך</asp:Label>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td align="right" style="padding-right: 10px; padding-left: 10px">
                                                        <asp:GridView ID="gvDeptNames" SkinID="SimpleGridViewNoEmtyDataText" runat="server"
                                                            AutoGenerateColumns="false" HeaderStyle-CssClass="DisplayNone" 
                                                            OnRowDataBound="gvDeptNames_RowDataBound">
                                                            <Columns>
                                                                <asp:TemplateField ItemStyle-Width="420px">
                                                                    <ItemTemplate>
                                                                        <asp:Label ID="lblDeptName" runat="server" Text='<%#Eval("deptName") %>'></asp:Label><br/>
                                                                        <asp:Label ID="lblDeptNameFreePart" EnableTheming="false" runat="server" Text='<%#Eval("deptNameFreePart") %>'></asp:Label>                                                                        
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField>
                                                                    <ItemTemplate>
                                                                        <asp:Label ID="lblFromDate" Width="95px" runat="server" Text='<%#Eval("fromDate","{0:d}") %>' ></asp:Label>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField>
                                                                    <ItemTemplate>
                                                                     <div style="margin-left:5px">
                                                                        <asp:TextBox ID="txtToDate" runat="server" Width="75px" Text='<%#Eval("ToDate","{0:d}") %>' Visible="false" ></asp:TextBox>
                                                                        <asp:Label ID="lblToDate" runat="server" Text='...' Width="75px"></asp:Label>
                                                                        </div>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>             
                                                                <asp:TemplateField>
                                                                    <ItemTemplate>
                                                                        <asp:ImageButton ID="btnDelete" runat="server" ImageUrl="~/Images/Applic/btn_X_red.gif" OnClick="btnDelete_click"  />                                                                        
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>                                                      
                                                                <asp:TemplateField>
                                                                    <ItemTemplate>
                                                                        <table cellpadding="0" cellspacing="0">
                                                                            <tr>
                                                                                <td style="padding-right: 5px">
<%--                                                                                    <asp:RequiredFieldValidator ID="vldDeptName_ToDate" ControlToValidate="txtToDate"
                                                                                        runat="server" ValidationGroup="vldDeptName" ErrorMessage="תאריך ריק" Display="Dynamic"
                                                                                        Text="*"> 
                                                                                    </asp:RequiredFieldValidator>  --%>                                                                                 
                                                                                </td>
                                                                            </tr>
                                                                        </table>
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
                                    <td align="right" style="padding-right: 27px; padding-left: 10px; border-bottom: 1px solid #808080">
                                        <asp:Label ID="lblAddName" runat="server" Text="עדכון שם יחידה" EnableTheming="false" CssClass="LabelCaptionGreenBold_12"></asp:Label>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right" style="padding-right: 27px; padding-top: 5px; padding-left: 10px">
                                        <table cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblClinicNameTitle" runat="server" Text="שם יחידה" EnableTheming="false" CssClass="LabelCaptionGreenBold_12"></asp:Label>
                                                </td>
                                                <td style="padding-right:10px">
                                                    <asp:Label ID="lblClinicTypeTitle" runat="server" Text="סוג יחידה" EnableTheming="false" CssClass="LabelCaptionGreenBold_12"></asp:Label>
                                                </td>
                                                <td style="padding-right:10px">
                                                    <asp:Label ID="lblCityNameTitle" runat="server" Text="ישוב" EnableTheming="false" CssClass="LabelCaptionGreenBold_12"></asp:Label>
                                                </td>
                                                <td style="padding-right:15px">
                                                    <asp:Label ID="lblFromDateTitle" runat="server" Text="מתאריך" EnableTheming="false" CssClass="LabelCaptionGreenBold_12"></asp:Label>
                                                </td>
                                                <td>
                                                </td>
                                                <td>
                                                </td>
                                            </tr>
                                      
                                            <tr>
                                                <td style="padding-top: 3px; padding-bottom: 2px">
                                                    <asp:TextBox ID="txtDeptNameToAdd" EnableTheming="false" CssClass="TexBoxNormal_13" Width="200px" runat="server"></asp:TextBox>
                                                </td>
                                                <td style="padding-right:7px">
                                                    <asp:TextBox ID="txtClinicType" SkinID="TexBoxNormal_13" Width="120px" runat="server"></asp:TextBox>
                                                    <asp:DropDownList ID="ddlClinicType" Width="140px" AutoPostBack="false" runat="server">
                                                        <asp:ListItem Value="מרפאה עצמאית" Text="מרפאה עצמאית"></asp:ListItem>
                                                        <asp:ListItem Value="רופאים עצמאיים" Text="רופאים עצמאיים"></asp:ListItem>
                                                    </asp:DropDownList>
                                                </td>
                                                <td style="padding-right:7px">
                                                    <asp:TextBox ID="txtCityName" SkinID="TexBoxNormal_13" Width="120px" runat="server"></asp:TextBox>
                                                </td>
                                                <td style="padding-top: 3px; padding-bottom: 2px; padding-right: 2px;width:100px; display:inline-block" dir="ltr">

                                                    <ajaxToolkit:MaskedEditValidator ID="val_txtDeptNameToAdd_FromDate" runat="server"
                                                        ControlExtender="mask_txtDeptNameToAdd_FromDate" ControlToValidate="txtDeptNameToAdd_FromDate"
                                                        IsValidEmpty="True" InvalidValueMessage="תאריך אינו תקין" Display="Dynamic" InvalidValueBlurredMessage="*&nbsp;&nbsp;"
                                                        ValidationGroup="vldDeptName" />

                                                    <asp:ImageButton ImageUrl="~/Images/Applic/calendarIcon.png" ID="btnRunCalendar_DeptNameToAdd" runat="server" />

                                                    <asp:TextBox ID="txtDeptNameToAdd_FromDate" SkinID="TexBoxNormal_13" Width="70px" runat="server"></asp:TextBox>

                                                    <ajaxToolkit:CalendarExtender ID="calExtFromDate_DeptName" runat="server" Format="dd/MM/yyyy"
                                                        FirstDayOfWeek="Sunday" TargetControlID="txtDeptNameToAdd_FromDate" PopupPosition="BottomRight"
                                                        PopupButtonID="btnRunCalendar_DeptNameToAdd">
                                                    </ajaxToolkit:CalendarExtender>

                                                    <ajaxToolkit:MaskedEditExtender ID="mask_txtDeptNameToAdd_FromDate" runat="server"
                                                        AcceptAMPM="false" ErrorTooltipEnabled="True" Mask="99/99/9999" MaskType="Date"
                                                        MessageValidatorTip="true" OnFocusCssClass="MaskedEditFocus" OnInvalidCssClass="MaskedEditError"
                                                        TargetControlID="txtDeptNameToAdd_FromDate">
                                                    </ajaxToolkit:MaskedEditExtender>
                                                    
                                                </td>                                               
                                                <td style="padding-top: 2px; padding-bottom: 2px; padding-right:5px">
                                                    <table cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                background-position: bottom left;">
                                                                &nbsp;
                                                            </td>
                                                            <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                background-repeat: repeat-x; background-position: bottom;">
                                                                <asp:Button ID="btnAddDeptNameLB" runat="server" OnClick="btnAddDeptNameLB_Click" OnClientClick="replaceApostrophe()"
                                                                    Text="הוספה" CssClass="RegularUpdateButton" CausesValidation="true" ValidationGroup="valGrAddDeptName">
                                                                </asp:Button>
                                                            </td>
                                                            <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                                background-repeat: no-repeat;">
                                                                &nbsp;
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                                <td>
                                                    <asp:RequiredFieldValidator ID="vldDeptNameToAdd_FromDate" ControlToValidate="txtDeptNameToAdd_FromDate"
                                                        runat="server" ValidationGroup="valGrAddDeptName" ErrorMessage="תאריך ריק" Display="Dynamic"
                                                        Text="*"> 
                                                    </asp:RequiredFieldValidator>

                                                    <asp:RequiredFieldValidator ID="vldDeptNameToAdd" ControlToValidate="txtDeptNameToAdd"
                                                        Display="Dynamic" ErrorMessage="שם מרפאה ריק" runat="server" ValidationGroup="valGrAddDeptName"
                                                        Text="*"> 
                                                    </asp:RequiredFieldValidator>

                                                    <asp:RegularExpressionValidator ID="vldRegexDeptNameToAdd" runat="server" ControlToValidate="txtDeptNameToAdd"
                                                        ValidationGroup="valGrAddDeptName" Text="*">
                                                    </asp:RegularExpressionValidator>

                                                    <asp:CustomValidator ID="vldPreservedWordsDeptNameToAdd" runat="server" ClientValidationFunction="CheckPreservedWords"
                                                        ValidationGroup="valGrAddDeptName" ControlToValidate="txtDeptNameToAdd" Text="*">
                                                    </asp:CustomValidator>

                                                    <asp:CustomValidator ID="vldDeptNameToAdd_Concistency" runat="server" ClientValidationFunction="CheckDeptNameConsistency"
                                                        ValidationGroup="valGrAddDeptName" Text="*" ErrorMessage="שם יחידה יכול להיות ריק רק אם שדות סוג ועיר מלאים" Display="Dynamic">
                                                    </asp:CustomValidator>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="4">
                                                    <asp:Label id="lblError" EnableTheming="false" runat="server" CssClass="LabelBoldRed_13"></asp:Label>
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
            <td style="padding-right: 4px; padding-top: 6px">
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
                        <td>
                            <!--content-->
                            <asp:UpdatePanel runat="server" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <table cellpadding="0" cellspacing="0" style="width: 670px">
                                        <tr>
                                            <td style="padding-right: 25px; padding-top: 5px" align="right">
                                                <asp:Label ID="lblDeptLevel" Width="90px" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                    runat="server" Text="רמת שירות:"></asp:Label>
                                                <asp:DropDownList ID="ddlDeptLevel" runat="server" DataValueField="deptLevelCode"
                                                    DataTextField="deptLevelDescription" Width="100px" AutoPostBack="true" OnSelectedIndexChanged="ddlDeptLevel_selectedIndexChanged">
                                                </asp:DropDownList>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="padding-right: 25px; padding-top: 10px" align="right">
                                                <asp:Panel ID="pnlDisplayPriority" runat="server">
                                                    <asp:Label ID="lblDisplayPriority" Width="90px" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                        runat="server" Text="עדיפות בחיפוש:"></asp:Label>
                                                    <asp:DropDownList ID="ddlDisplayPriority" runat="server" Width="100px">
                                                        <asp:ListItem Value="-1">ללא עדיפות</asp:ListItem>
                                                        <asp:ListItem Value="1">1</asp:ListItem>
                                                        <asp:ListItem Value="2">2</asp:ListItem>
                                                        <asp:ListItem Value="3">3</asp:ListItem>
                                                        <asp:ListItem Value="4">4</asp:ListItem>
                                                        <asp:ListItem Value="5">5</asp:ListItem>
                                                    </asp:DropDownList>
                                                </asp:Panel>
                                            </td>
                                        </tr>
                                    </table>
                                </ContentTemplate>
                            </asp:UpdatePanel>
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
            <td style="padding-left: 10px; padding-top: 10px; padding-bottom: 5px">
                <table cellpadding="0" cellspacing="0">
                    <tr>
                        <td style="width: 2450px; padding: 0px 0px 0px 0px; margin: 0px 0px 0px 0px;">
                            <asp:ValidationSummary ID="vldValidationSummary" ValidationGroup="valGrAddDeptName"
                                runat="server" />
                            <asp:ValidationSummary ID="vldValidationSummary_2" ValidationGroup="vldDeptName"
                                runat="server" />
                        </td>
                        <td valign="top" align="left" style="width: 245px; padding: 0px 0px 0px 0px; margin: 0px 0px 0px 0px;">
                            <table cellpadding="0" cellspacing="0">
                                <tr>
                                    <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                        background-position: bottom left;">
                                        &nbsp;
                                    </td>
                                    <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                        background-repeat: repeat-x; background-position: bottom;">
                                        <asp:Button ID="btnSaveDeptName" runat="server" OnClick="btnSaveDeptName_Click" Text=" עדכון "
                                            CssClass="RegularUpdateButton" CausesValidation="true" ValidationGroup="vldDeptName">
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
                                        <asp:Button ID="btnCancelDeptNameLB" runat="server" OnClientClick="javascript:JustGo();"
                                            Text=" ביטול " CssClass="RegularUpdateButton" CausesValidation="false" ValidationGroup="valGrAddDeptName">
                                        </asp:Button>
                                    </td>
                                    <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                        background-repeat: no-repeat;">
                                        &nbsp;
                                    </td>
                                    <td class="DisplayNone">
                                        <asp:TextBox ID="txtErrorMessageAfterSave" runat="server" />
                                        <asp:CheckBox ID="cbSaveToBeMade" runat="server" />
                                        <asp:CheckBox ID="cbChangesWareMade" runat="server" />
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
            </td>
        </tr>
    </table>
    </form>
</body>
</html>
