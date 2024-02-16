<%@ Page Language="C#" AutoEventWireup="true" Inherits="Tests_DefaultPhones"  Codebehind="DefaultPhones.aspx.cs" %>
<%@ Register TagPrefix="PhonesGridUC" TagName="PhoneGrid" Src="~/UserControls/PhonesGridUC.ascx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server"  >
    <div>
        <table style="width: 100%;" >
            <tr>
                <td>
                    <asp:ScriptManager ID="ScriptManager1" runat="server"  EnablePartialRendering="true" >
                                        </asp:ScriptManager>
                </td>
                <td >
                    <PhonesGridUC:PhoneGrid ID="gvPhones11" runat="server"  />
                </td>
                <td>
                    <asp:Button ID="Button1" runat="server" Text="Button" onclick="Button1_Click" />
                </td>
            </tr>
            <tr>
                <td>
                    &nbsp;
                </td>
                <td>
                    <PhonesGridUC:PhoneGrid ID="gvPhones22" runat="server" />
                </td>
                <td>
                    &nbsp;
                </td>
            </tr>
            <tr>
                <td>
                    &nbsp;
                </td>
                <td>
                    &nbsp;
                    <asp:Button ID="btnSave11" runat="server" OnClick="btnSave11_Click" Text="Save" />
                    <asp:GridView ID="GridView11" runat="server">
                    </asp:GridView>
                </td>
                <td>
                    <asp:GridView ID="GridView22" runat="server">
                    </asp:GridView>
                </td>
            </tr>
        </table>
    </div>
    </form>
</body>
</html>
