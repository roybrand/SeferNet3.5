<%@ Page language="c#" AutoEventWireup="True" Inherits="ExceptionLogger.Report" Codebehind="~/ReportsForDeveloper/Report.aspx.cs" %>

<%@ Register Assembly="BasicFrame.WebControls.BasicDatePicker" Namespace="BasicFrame.WebControls"
    TagPrefix="BDP" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" >
<HTML>
	<HEAD>
		<title>Report</title>
		<meta content="Microsoft Visual Studio .NET 7.1" name="GENERATOR" />
		<meta content="C#" name="CODE_LANGUAGE" />
		<meta content="JavaScript" name="vs_defaultClientScript" />
		<meta content="http://schemas.microsoft.com/intellisense/ie5" name="vs_targetSchema" />
	</HEAD>
	<body MS_POSITIONING="GridLayout" >
		<form id="Form1" method="post" runat="server">
			<asp:DataGrid ID="DataGrid1" SkinID="DataGridReport"  runat="server">
			</asp:DataGrid>
            <div style="text-align: left">
                <table>
                    <tr>
                        <td align="left" style="width: 100px; background-color: #99ffff">
                            AppName</td>
                        <td align="left" style="width: 423px; background-color: #99ffff">
                            <asp:TextBox ID="txtAppName" runat="server"></asp:TextBox></td>
                    </tr>
                    <tr>
                        <td align="left" style="width: 100px; background-color: #99ffff">
                            Begin Date</td>
                        <td align="left" style="width: 423px; background-color: #99ffff">
                            <BDP:BDPLite ID="dtBeginDate" runat="server" />
                        </td>
                    </tr>
                    <tr>
                        <td align="left" style="width: 100px; background-color: #99ffff">
                            End Date</td>
                        <td align="left" style="width: 423px; background-color: #99ffff">
                            <BDP:BDPLite ID="dtEndDate" runat="server" />
                        </td>
                    </tr>
                    
                    <tr>
                        <td align="left" style="width: 100px; background-color: #99ffff">
                            Message</td>
                        <td align="left" style="width: 423px; background-color: #99ffff">
                            <asp:TextBox ID="txtMessage" runat="server"></asp:TextBox></td>
                    </tr>
                    <tr>
                        <td align="left" style="width: 100px; background-color: #99ffff">
                            Target Site</td>
                        <td align="left" style="width: 423px; background-color: #99ffff">
                            <asp:TextBox ID="txtTargetSite" runat="server"></asp:TextBox></td>
                    </tr>
                    <tr>
                        <td align="left" style="width: 100px; background-color: #99ffff">
                            Referer</td>
                        <td align="left" style="width: 423px; background-color: #99ffff">
                            <asp:TextBox ID="txtReferer" runat="server"></asp:TextBox></td>
                    </tr>
                    <tr>
                        <td align="left" style="width: 100px; background-color: #99ffff">
                            Path</td>
                        <td align="left" style="width: 423px; background-color: #99ffff">
                            <asp:TextBox ID="txtPath" runat="server"></asp:TextBox>&nbsp;<asp:Button ID="Button1"
                                runat="server" OnClick="Button1_Click" Text="Search!" /></td>
                    </tr>
                </table>
                <br />
            </div>
        </form>
	</body>
</HTML>
