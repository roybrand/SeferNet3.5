<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ZoomSalService_PrintOptions.aspx.cs" Inherits="SeferNet.UI.Apps.Templates.ZoomSalService_PrintOptions" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<base target="_self"/>
<link href="~/CSS/General/general.css" type="text/css" rel="Stylesheet" />
    <title></title>
    <script type="text/javascript">
        function ReturnSelectedOptions() {
            var elLength = document.form1.elements.length;
            var deptCodes = "";

            for (i = 0; i < elLength; i++) {
                var type = form1.elements[i].type;
                if (type == "checkbox" && form1.elements[i].checked) {
                    if (deptCodes != "")
                        deptCodes = deptCodes + ",";
                    deptCodes = deptCodes + form1.elements[i].name;
                }
                else {
                }
            }

            parent.Open_FrmSelectTemplate(deptCodes);
            SelectJQueryClose();

            return false;
        }

        function ReturnSelectedOptions_OLD() {
            var elLength = document.form1.elements.length;
            var deptCodes = "";

            for (i = 0; i < elLength; i++) {
                var type = form1.elements[i].type;
                if (type == "checkbox" && form1.elements[i].checked) {
                    if (deptCodes != "")
                        deptCodes = deptCodes + ",";
                    deptCodes = deptCodes + form1.elements[i].name;
                }
                else {
                }
            }

            var obj = new Object();

            obj.Value = deptCodes;
            obj.Url = "../Templates/FrmSelectTemplate.aspx?Template=PrintZoomSalService&PrintOptions=" + deptCodes;
            window.returnValue = obj;
            self.close();

            return false;
        }

        function Close() {
            var currentDeptCode = document.getElementById('hdnSelectedDeptCode').value;

            parent.Open_FrmSelectTemplate('', currentDeptCode);
            SelectJQueryClose();
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">

    <div style="margin-right: 90px; text-align:right" class="RegularLabel">
        <div style="margin-bottom:20px; margin-top:40px">
            <label class="BlueBoldLabel" >אפשרויות הדפסה</label>
        </div>
        <div>
            <label for="Common">נתוני שירות</label>
            <input type="checkbox" name="Common" id="Common" runat="server" checked="checked" disabled="disabled"/>
        </div>
        <div>
            <label for="Taarifon">תעריפון</label>
            <input type="checkbox" name="Taarifon" id="Taarifon" runat="server"/>
        </div>
        <div></div>
            <label for="ICD9">code ICD9</label>
            <input type="checkbox" name="ICD9" id="ICD9" runat="server"/>

        <div id="divInternet" runat="server">
            <label for="Internet">פרטי אינטרנט</label>
            <input type="checkbox" name="Internet" id="Internet" runat="server"/>
        </div>
        <!--
        <div>
            <label for="Mushlam">שירותי מושלם</label>
            <input type="checkbox" name="Mushlam" id="Mushlam" runat="server"/>
        </div>
        -->
        <div style="margin-top:20px; margin-left:130px;">
            <table cellpadding="0" cellspacing="0" style="direction:rtl" >
                <tr>
                    <td class="buttonRightCorner">&nbsp;</td>
                    <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                        background-repeat: repeat-x; background-position: bottom;">
                        <asp:Button ID="btnSelect" runat="server" Text="הדפסה" CssClass="RegularUpdateButton" OnClientClick="ReturnSelectedOptions();" />
                    </td>
                    <td class="buttonLeftCorner">&nbsp;</td>
                </tr>
            </table>
        </div>
    </div>
    </form>
    <script type="text/javascript">
        function SelectJQueryClose() {
            window.parent.$("#dialog-modal-select").dialog('close');
            return false;
        }
    </script>

</body>
</html>
