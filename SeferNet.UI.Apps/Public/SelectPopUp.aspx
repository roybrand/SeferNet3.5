<%@ Page Language="C#" EnableViewState="false" AutoEventWireup="true" Inherits="SelectPopUp" Codebehind="SelectPopUp.aspx.cs" %>


<%@ Register src="../UserControls/MultiSelectAndUpdate.ascx" tagname="MultiSelectAndUpdate" tagprefix="uc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html>
<head runat="server">
    <base target="_self" />    
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Cache-Control" content="no-cache" />    
    <meta http-equiv="Expires" content="-1" />
    <link rel="STYLESHEET" href="../CSS/General/general.css" type="text/css" />
    
    <script type="text/javascript" src="../Scripts/srcScripts/jquery.js"></script>
    <%--<script type="text/javascript" src="https://code.jquery.com/jquery-3.6.0.js"></script>--%>
    <%--<script type="text/javascript" src="https://code.jquery.com/ui/1.13.1/jquery-ui.js"></script>--%>  
    <title></title>
</head>
<body dir="rtl">
    <form id="form1" runat="server">
        <div style="margin:10px 5px 10px 0px">
            <asp:label ID="lblHeader" runat="server"></asp:label>
        </div>
              
        <uc1:MultiSelectAndUpdate ID="multiSelectList" runat="server" ShowAddProfessionsButton="false" />
  
    </form>

<script type="text/javascript">
    function SelectJQueryClose() {
        window.parent.$("#dialog-modal-select").dialog('close');
        window.parent.$("#dialog-modal-inner").dialog('close');
        return false;
    }
</script>

</body>
</html>
