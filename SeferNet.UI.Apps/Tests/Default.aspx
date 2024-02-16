<%@ Page Language="C#" AutoEventWireup="true" Inherits="Tests_Default" Codebehind="Default.aspx.cs" %>

<%@ Register TagPrefix="PhonesGridUC" TagName="PhonesGridUC" Src="~/UserControls/PhonesGridUC.ascx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script type="text/javascript" src="../Scripts/srcScripts/jquery.js"></script>
    <script language="javascript" type="text/javascript">


        function SelectHandicappedFacilities() {
            var url = "http://localhost/SeferNet/Public/SelectPopUp.aspx";
            var txtHandicappedFacilitiesCodes = document.getElementById('<%=txtHandicappedFacilitiesCodes.ClientID %>');
             var SelectedHandicappedFacilitiesList = txtHandicappedFacilitiesCodes.innerText;
            url = url + "?SelectedValuesList=" + SelectedHandicappedFacilitiesList;
            url = url + "&popupType=8";
            var topi = 50;
            var lefti = 100;
            var features = "top:" + topi + "px;left:" + lefti + "px; dialogWidth:425px; dialogheight:480px; help:no; status:no;";

            var obj = window.showModalDialog(url, "SelectHandicappedFacilities", features);

            if (obj != null) {
                txtHandicappedFacilitiesCodes.innerText = obj.Value;
               
            }
        }
    </script>
        <script type="text/javascript" language="javascript">
            $(document).ready(function () {
                $(document).live("onchange", function () {
                    alert("Hi");
                });
            });
         </script>
</head>
<body">


    <form id="form1" runat="server">
    <div>
    </div>
    <div>
        <asp:TextBox ID="txtHandicappedFacilitiesCodes" EnableViewState="false" runat="server" ></asp:TextBox>
        <input type="image" id="btnHandicappedFacilitiesPopUp" style="cursor: hand;" src="../Images/Applic/icon_magnify.gif"
            onclick="SelectHandicappedFacilities(); return false;" />
           
    </div>
    <div>
        <table style="width: 100%;" id="tbl">
            <tr>
                <td>
                    <asp:ScriptManager ID="ScriptManager1" runat="server">
                    </asp:ScriptManager>
                </td>
                <td>
                </td>
                <td>
                    &nbsp;
                </td>
            </tr>
            <tr>
                <td>
                    <asp:PlaceHolder ID="PlaceHolder1" runat="server">
                        <PhonesGridUC:PhonesGridUC runat="server" ID="PhonesGridUCItem1" />
                    </asp:PlaceHolder>
                </td>
                <td>
                </td>
                <td>
                    <asp:Button ID="Button1" runat="server" Text="Save" OnClick="Button1_Click1" />
                </td>
            </tr>
            <tr>
                <td>
                </td>
                <td>
                    <asp:ValidationSummary ID="ValidationSummary1" runat="server" ShowSummary="true"
                        DisplayMode="BulletList" HeaderText="header" />
                </td>
                <td>
                </td>
            </tr>
        </table>
    </div>
    <asp:GridView ID="GridView1" runat="server">
    </asp:GridView>
    </form>
</body>
</html>
