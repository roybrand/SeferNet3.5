<%@ Page Language="C#" AutoEventWireup="true" Inherits="Tests_DefaultMultDDl" Codebehind="DefaultMultDDl.aspx.cs" %>

<%@ Register TagPrefix="MultiDDlSelect_UC" TagName="MultiDDlSelect_UCItem" Src="~/UserControls/MultiDDlSelect.ascx" %>
<%@ Register TagPrefix="MultiDDlSelect_UCNew" TagName="MultiDDlSelect_UCItemNew"
    Src="~/UserControls/MultiDDlSelectUC.ascx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>MultiSelect Drop-Down List</title>
    <link href="../CSS/MultiSelectListBox.css" media="all" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <br />
        <asp:Label runat="server" ID="MessageLabel" />
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePartialRendering="true">
            <Scripts>
                <asp:ScriptReference Path="~/Scripts/GridReceptionHoursUC.js" />
            </Scripts>
        </asp:ScriptManager>
    </div>
    <asp:UpdatePanel runat="server" ID="pnl" UpdateMode="Always">
    <ContentTemplate>
    <div align="center">
        <table>
            <tr>
                <td style="width: 679px;">
                    <asp:Label ID="lblCaption" runat="server" Font-Bold="True" Font-Names="Trebuchet MS"
                        Text="MultiSelect Drop-Down Samples" BackColor="#E0E0E0" Width="810px"></asp:Label>
                </td>
                <td>
                    <MultiDDlSelect_UC:MultiDDlSelect_UCItem runat="server" ID="MultiDDlSelect_Days"  OnImgButtonClicked="MultiDDlSelect_Days_ImgButtonClicked" 
                        Width="50"></MultiDDlSelect_UC:MultiDDlSelect_UCItem>
                </td>
                 <td>
                    <MultiDDlSelect_UCNew:MultiDDlSelect_UCItemNew runat="server" ID="MultiDDlSelect_New"  OnImgButtonClicked="MultiDDlSelect_Days_ImgButtonClicked" 
                        Width="50"></MultiDDlSelect_UCNew:MultiDDlSelect_UCItemNew>
                </td>
            </tr>
        </table>
    </div>
    <br />
    <br />
    </ContentTemplate>
    </asp:UpdatePanel><table border="1">
        <tr>
            <th>
                <asp:Button ID="Button1" runat="server" Text="Button" 
                    onclick="Button1_Click1" />
            </th>
            <th>
                header cell 2
            </th>
            <th>
                header cell 3
            </th>
        </tr>
       
       
    </table>
    </form>
</body>
</html>
