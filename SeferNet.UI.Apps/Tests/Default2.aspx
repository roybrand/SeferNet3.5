<%@ Page Language="C#" AutoEventWireup="true" Inherits="Tests_Default2" Codebehind="Default2.aspx.cs" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>

    <script type="text/javascript" language="javascript">
        function validateHours(val, args) {
         
            var openingTime = document.getElementById('txtToHour').value;
            var openingTimeArr = openingTime.split(':');
            var FromHour = openingTimeArr[0];
            var FromMinute = openingTimeArr[1];

            var closingTime = document.getElementById('txtToHour').value;
            var closingTimeArr = closingTime.split(':');
            var ToHour = closingTimeArr[0];
            if (ToHour == "00")
                ToHour = "24";
            var ToMinute = closingTimeArr[1];

            var FromHourInt = parseInt(FromHour, 10);
            var ToHourInt = parseInt(ToHour, 10);

            var FromMinuteInt = parseInt(FromMinute, 10);
            var ToMinuteInt = parseInt(ToMinute, 10);

            var receptionDateFrom = new Date();
            receptionDateFrom.setHours(FromHourInt, FromMinute, 0, 0);

            var receptionDateTo = new Date();
            receptionDateTo.setHours(ToHourInt, ToMinute, 0, 0);

            if (receptionDateFrom < receptionDateTo)
                args.IsValid = true;
            else
                args.IsValid = false;
        }


    </script>

</head>
<body>
    <form id="form1" runat="server">
    <div>
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <table>
         <tr>
                <td>
                    <asp:Label ID="Label1" runat="server" Text="מ שעה :"></asp:Label>
                </td>
            </tr>
            <tr>
                <td>
                    <asp:TextBox ID="txtFromHour" runat="server" Width="50px" Text='<%# Eval("openingHour") %>'></asp:TextBox>
                    <cc1:MaskedEditExtender ID="FromHourExtender" runat="server" ErrorTooltipEnabled="True"
                        Mask="99:99" MaskType="Time" TargetControlID="txtFromHour" Enabled="True">
                    </cc1:MaskedEditExtender>
                    <cc1:MaskedEditValidator ID="FromHourValidator" runat="server" ControlExtender="FromHourExtender"
                        ControlToValidate="txtFromHour" InvalidValueMessage="שעת הפתיחה אינה תקינה" Display="Dynamic"
                        InvalidValueBlurredMessage="*" ValidationGroup="vldGrEdit" ErrorMessage="שעת הפתיחה אינה תקינה"
                        meta:resourcekey="FromHourValidatorResource1" />
                </td>
            </tr>
       
            <tr>
                <td>
                    <asp:Label ID="Label3" runat="server" Text="עד שעה :"></asp:Label>
                </td>
            </tr>
            <tr>
                <td>
                </td>
            </tr>
            <tr>
                <td>
                    <asp:TextBox ID="txtToHour" runat="server" Width="50px" meta:resourcekey="txtToHourResource2"></asp:TextBox>
                    <cc1:MaskedEditExtender ID="ClosingHourExtender" runat="server" ErrorTooltipEnabled="True"
                        UserTimeFormat="TwentyFourHour" Mask="99:99" MaskType="Time" TargetControlID="txtToHour"
                        Enabled="True">
                    </cc1:MaskedEditExtender>
                    <cc1:MaskedEditValidator ID="ClosingHourValidator" runat="server" ControlExtender="ClosingHourExtender"
                        ControlToValidate="txtToHour" InvalidValueMessage="שעת הסגירה אינה תקינה" Display="Dynamic"
                        InvalidValueBlurredMessage="*" ValidationGroup="vldGrAdd" ErrorMessage="שעת הסגירה אינה תקינה" />
                    <asp:CustomValidator ControlToValidate="txtToHour" ClientValidationFunction="validateHours"
                        ErrorMessage="השעות אינן תקינות" Text="*" ValidationGroup="vldGrAdd" ID="vldCheckHours"
                        runat="server"></asp:CustomValidator>
                </td>
            </tr>
            <tr valign="middle">
                <td valign="middle">
                    <asp:ImageButton runat="server" ID="imgAdd" CausesValidation="true" CommandName="add"
                        OnClick="imgAdd_Click" ImageUrl="~/Images/btn_add.gif" ValidationGroup="vldGrAdd" />
                </td>
            </tr>
        </table>
    </div>
    <cc1:ToolkitScriptManager ID="ToolkitScriptManager1" runat="server">
    </cc1:ToolkitScriptManager>
    <asp:ScriptManager ID="ScriptManager2" runat="server">
    </asp:ScriptManager>
    </form>
</body>
</html>
