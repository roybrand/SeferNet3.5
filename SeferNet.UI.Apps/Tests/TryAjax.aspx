<%@ Page Language="C#" AutoEventWireup="true" Inherits="Tests_TryAjax" Codebehind="TryAjax.aspx.cs" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>Untitled Page</title>
   <script runat=server >
       
     [System.Web.Services.WebMethod]
    [System.Web.Script.Services.ScriptMethod]
    public static string getNumber(string num)
    {
       return "this is your number: "+num;
    }

       
       </script>
    
</head>
<body>
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods=true    >    
        </asp:ScriptManager>
    <div>
        <asp:TextBox ID="TextBox1" runat="server"></asp:TextBox>
    
    </div>
        
         <asp:Button ID="btn" Text = "get number" runat="server" OnClientClick="getNumberClient(); return false;" />
    </form>
</body>
<script>
        function getNumberClient()
        {
            //alert("kkkk");
            //debugger;
            var num = PageMethods.getNumber("5");
            document.getElementById("TextBox1").value=num;
        }
        function OnComplete(result)
        {
            alert(result);
        }
    </script>
</html>
