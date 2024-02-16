<%@ Page Language="C#" AutoEventWireup="true" Inherits="Admin_SelectEmployeeDeptsPopup" Codebehind="SelectEmployeeDeptsPopup.aspx.cs" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@ Register Src="~/UserControls/MultiSelectAndUpdate.ascx" TagPrefix="uc1" TagName="multiSelect" %>
<%@ Reference Page="~/Admin/AdminPopupBasePage.aspx" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>בחירת יחידות</title>
    <base target="_self" />
    <script type="text/javascript" src="../Scripts/srcScripts/jquery.js"></script>
</head>
<body dir="rtl">
    <form id="form1" runat="server">
    <div style="margin: 10px 5px 10px 0px;">
        <asp:Label ID="lblHeader" runat="server"></asp:Label>
    </div>
    <uc1:multiSelect ID="multiSelectList" runat="server" />
    </form>
<script type="text/javascript">
    function SelectJQueryClose() {
        window.parent.$("#dialog-modal-select").dialog('close');
        return false;
    }
</script>
</body>
</html>
