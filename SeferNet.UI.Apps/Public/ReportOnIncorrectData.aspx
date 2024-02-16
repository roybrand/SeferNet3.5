<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="Public_ReportOnIncorrectData" Codebehind="ReportOnIncorrectData.aspx.cs" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>דיווח על מידע שגוי</title>
    <link rel="Stylesheet" type="text/css" href="../CSS/General/general.css" />
    <base target="_self" />
    <script language="jscript" type="text/jscript">
        function disableSaveButtons() {
            document.getElementById('<%=btnSave.ClientID %>').disabled = true;
        }

        function showProgressBar(validation_group) {
            //debugger;
            document.getElementById("divProgressBar").style.visibility = "visible";
        }
    </script>
</head>
<body>
    <form id="form1" runat="server" dir="rtl">
    <div style="width: 100%; padding-top: 3px; padding-bottom: 3px;" class="BackColorBlue">
        <div style="margin-right: 5px;">
            <asp:Label runat="server" Style="margin-right: 5px" EnableTheming="false" CssClass="LabelBoldWhite_18">דיווח מידע שגוי</asp:Label>
        </div>
    </div>
    <table style="margin-top:10px">
        <tr>
            <td valign="top">
                <asp:Label runat="server">שם המדווח:</asp:Label>
            </td>
            <td style="padding-top:3px">
                <asp:TextBox ID="txtReporterName" runat="server" Width="290px" Height="20px" TextMode="MultiLine" Rows="10"></asp:TextBox>
                <asp:RequiredFieldValidator ID="vldReporterName" runat="server" ControlToValidate="txtReporterName" 
                  ErrorMessage="חובה להזין שם המדווחה" Display="None" />
            </td>
        </tr>
        <tr>
            <td valign="top">
                <asp:Label runat="server">תיאור הבעיה:</asp:Label>
            </td>
            <td style="padding-top:3px">
                <asp:TextBox ID="txtDescription" runat="server" Width="290px" TextMode="MultiLine" Rows="10"></asp:TextBox>
                <asp:RequiredFieldValidator ID="vldText" runat="server" ControlToValidate="txtDescription" 
                  ErrorMessage="חובה להזין תיאור" Display="None" />
            </td>
        </tr>
        <tr>
            <td colspan="2" align="left" style="padding-top:10px">
                <table cellpadding="0" cellspacing="0">
                    <tr>
                        <td class="buttonRightCorner">
                            &nbsp;
                        </td>
                        <td class="buttonCenterBackground">
                            <asp:Button ID="btnSave" runat="server" Text="אישור" OnClick="btnSave_click" OnClientClick="showProgressBar('vldDates'); setTimeout(disableSaveButtons, 100); "
                            CssClass="RegularUpdateButton" CausesValidation="true"></asp:Button>
                        </td>
                        <td  class="buttonLeftCorner">
                            &nbsp;
                        </td>
                        <td class="buttonRightCorner">
                            &nbsp;
                        </td>
                        <td class="buttonCenterBackground">
                            <asp:Button ID="btnClose" runat="server" Text="ביטול" CssClass="RegularUpdateButton"
                                OnClientClick="self.close(); return false;"></asp:Button>
                        </td>
                        <td  class="buttonLeftCorner">
                            &nbsp;
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td colspan="2">
                <asp:ValidationSummary ID="vldSummary" runat="server" />
            </td>
        </tr>
    </table>
    <div id="divProgressBar" class="progressBarDiv" >
        <asp:Image ID="imgProgressBar" runat="server" ImageUrl ="../Images/Applic/imgProgressBarOuterCircle.png" />
    </div>
    </form>
</body>
</html>
