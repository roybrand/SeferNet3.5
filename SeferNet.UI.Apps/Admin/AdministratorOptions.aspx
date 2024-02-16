<%@ Reference Page="AdminBasePage.aspx" %>
<%@ Page Language="C#"  Title="����� �����"  MasterPageFile="~/SeferMasterPage.master" AutoEventWireup="true" Inherits="Administrators" Codebehind="AdministratorOptions.aspx.cs" %>
<%@ MasterType   VirtualPath="~/seferMasterPage.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="pageContent" runat="server" >
    <script type="text/javascript">
        function showProgressBar() {
            document.getElementById("divPrBar").style.visibility = "visible";
    }
    </script>

    <asp:Button ID="btnRefreshCache" CssClass="btnClass14"   ToolTip="���� ������ ���� �����" Width="200px" Height="30px" runat="server" Text="���� ������ �������" OnClick="btnRefreshCache_Click" 
        OnClientClick="showProgressBar();" />
<br />
<asp:Button ID="btnTestLoadBalanceService" CssClass="btnClass14"   
    ToolTip="���� ������ �� ���� ����� ������" Width="251px" Height="30px" 
    runat="server" Text="���� ������ �� ���� ����� ������" 
    onclick="btnTestLoadBalanceService_Click"/>
<br />
    <asp:Button ID="btnResetTemplates" CssClass="btnClass14"   
    ToolTip="��� ������" Width="251px" Height="30px" 
    runat="server" Text="��� ������" onclick="btnResetTemplates_Click" 
    />
<br />
    <asp:Button ID="btnUpdateProfLicence" CssClass="btnClass14"   
    ToolTip="����� �������� �����" Width="251px" Height="30px" 
    runat="server" Text="����� �������� �����" onclick="btnUpdateProfLicence_Click"
        OnClientClick="showProgressBar();" 
    />
    <table style="width:100%" >
        <tr>
            <td style="width:100%;" align="center">
                <div id="divPrBar" style="margin-top:5px;width:100%;visibility:hidden;height:32px; align-items:center">
                    <asp:Image ID="img" runat="server" ImageUrl="~/Images/Applic/progressBar.gif" />
                </div>
            </td>
        </tr>

    </table>


</asp:Content>
