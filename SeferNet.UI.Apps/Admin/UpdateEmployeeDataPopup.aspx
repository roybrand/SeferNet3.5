<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="Admin_UpdateEmployeeDataPopup" Codebehind="UpdateEmployeeDataPopup.aspx.cs" %>
<%@ Reference Page="~/Admin/AdminPopupBasePage.aspx" %>
<%@ Register Src="../UserControls/MultiSelectAndUpdate.ascx" TagName="MultiSelectAndUpdate"
    TagPrefix="uc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <base target="_self" />
    <script type="text/javascript" src="https://code.jquery.com/jquery-3.6.0.js"></script>
    <script type="text/javascript" src="https://code.jquery.com/ui/1.13.1/jquery-ui.js"></script>  
    <title>הגדרת מקצוע לרופא</title>
    <meta http-equiv="Pragma" content="no-cache" />
</head>
<body dir="rtl">
    <form id="form1" runat="server">
    <div style="padding-right:10px" class="BlueBar">
        <asp:Label ID="lblMainHeader" runat="server" EnableTheming="false" CssClass="LabelBoldWhite_18" ></asp:Label>
    </div>
    <div style="margin: 10px 5px 10px 0px;">
        <asp:Label ID="lblHeader" runat="server"></asp:Label>
    </div>
    <div>
        <uc1:MultiSelectAndUpdate ID="multiSelectList" runat="server" />
    </div>
    </form>
</body>
</html>
