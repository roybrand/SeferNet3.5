<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ReportSearchResult.aspx.cs" Culture="he-IL" UICulture="he-IL" Inherits="SeferNet.UI.Apps.Public.ReportSearchResult_aspx" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <base target="_self" />
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <asp:Button ID="btnGenerateExcel" runat="server" OnClick="btnGenerateExcel_Click" Text="Generate Excel" />
        </div>
    </form>
</body>
</html>
