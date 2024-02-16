<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="Admin_GetAllDataPopup" Codebehind="GetAllDataPopup.aspx.cs" %>

<%@ Register Src="../UserControls/MultiSelectAndUpdate.ascx" TagName="MultiSelectAndUpdate"
    TagPrefix="uc1" %>

<%@ Reference Page="~/Admin/AdminPopupBasePage.aspx" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <base target="_self" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="-1" />
    <link rel="STYLESHEET" href="../CSS/General/general.css" type="text/css" />    
    <script type="text/javascript" src="../Scripts/srcScripts/jquery.js"></script>

    <%--<script type="text/javascript" src="https://code.jquery.com/jquery-3.6.0.js"></script>--%>
    <%--<script type="text/javascript" src="https://code.jquery.com/ui/1.13.1/jquery-ui.js"></script>--%>  
    
    <title></title>
</head>
<body dir="rtl">
    <form id="form1" runat="server">
    <div style="width: 100%; padding-bottom:2px" class="BlueBar">&nbsp;
        <asp:Label ID="lblMainHeader" runat="server" EnableTheming="false" CssClass="LabelBoldWhite_18"></asp:Label>
    </div>
    <div style="margin: 10px 5px 10px 0px;">
        <asp:Label ID="lblHeader" runat="server"></asp:Label>
    </div>
    <uc1:MultiSelectAndUpdate ID="multiSelectList" runat="server" />
    </form>

<script type="text/javascript">
    function SelectJQueryClose() {
        window.parent.$("#dialog-modal-select").dialog('close');
        return false;
    }
</script>
</body>
</html>
