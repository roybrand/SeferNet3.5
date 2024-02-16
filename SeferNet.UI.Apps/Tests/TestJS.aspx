<%@ Page Language="C#" AutoEventWireup="true" Inherits="Tests_TestJS" Codebehind="TestJS.aspx.cs" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
<script language=javascript type="text/javascript">
    function ReturnToParent() {

        alert('1');
        //if (window.dialogArguments) {
         //   window.opener = window.dialogArguments;
        //}

        var AreasNames = document.getElementById("txt").value; 
        window.opener.UpdateRemarkAreaView(AreasNames);
        window.close();
    } 
</script>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <input type="text" id="txt" size="100"> 
        <input id="btn" type="button" onclick="ReturnToParent();" >
    </div>
    </form>
</body>
</html>
