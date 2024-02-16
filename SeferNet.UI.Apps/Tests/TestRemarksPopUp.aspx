<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="Tests_TestRemarksPopUp" Codebehind="TestRemarksPopUp.aspx.cs" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>

    <script type="text/javascript" language="javascript">
        function OpenRemarkWindowDialog(remarkType) {
            var topi = 50;
            var lefti = 100;
            var features = "top:" + topi + "px;left:" + lefti + "px; dialogWidth:650px; dialogheight:600px; help:no; status:no; ";

            var obj = window.showModalDialog("../Admin/RemarksPopUp.aspx?remarkType=" + remarkType, "UpdateItemRemarks", features);

            if (obj != null && obj.SelectedRemark != null) {
                var selectedRemark = obj.SelectedRemark;
                var lbl = document.getElementById('lbl');
                lbl.innerHTML = selectedRemark;
            }
        }
    </script>

</head>
<body>
    <form id="form1" runat="server">
    <div>
        <table style="width: 100%;">
            <tr>
                <td>
                    <input type="image" id="btnUnitTypeListPopUp" style="cursor: hand;" src="../Images/Applic/icon_magnify.gif"
                        onclick="OpenRemarkWindowDialog(1);return false;" />
                </td>
                <td>
                   <div style="border:1px; background-color:ActiveBorder;   width:50px; overflow:hidden;height:20px"  
                        contenteditable></div>
                </td>
                <td>
                    <asp:Label runat="server" ID="lbl" >11</asp:Label>
                </td>
                 <td>
                   <span  style="visibility:hidden">1233</span>
                </td>
            </tr>
        </table>
    </div>
    </form>
</body>
</html>
