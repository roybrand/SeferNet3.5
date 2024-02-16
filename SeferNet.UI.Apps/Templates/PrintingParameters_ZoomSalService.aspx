<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PrintingParameters_ZoomSalService.aspx.cs" Inherits="SeferNet.UI.Apps.Templates.PrintingParameters_ZoomSalService" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script type="text/javascript">
        function SelectPrintOptions() {
            var topi = 400;
            var lefti = 620;
            var url = "";

            var templatePath = document.getElementById('hdnTemplatePath').value;

            var features = "dialogtop:" + topi + "px;dialogLeft:" + lefti + "px; dialogWidth:340px; dialogheight:340px; help:no; status:no;";
            var strUrl = "../Templates/ZoomSalService_PrintOptions.aspx"

            var obj = window.showModalDialog(strUrl, "Select_PrintOptions", features);

            if (obj != null) {
                url = templatePath + "FrmSelectTemplate.aspx?Template=PrintZoomSalService&PrintOptions=" + obj.Value;
            }
            else {
                url = templatePath + "FrmSelectTemplate.aspx?Template=PrintZoomSalService&PrintOptions=";
            }

            OpenInNewWindow(url, 0, '', '', 1);

        }

        function OpenInNewWindow(url, IsWinDialog, sizeX, sizeY, resize) {
            var parameters;
            if (IsWinDialog == '0') {
                parameters = "scrollbars = yes, menubar = yes, toolbar = yes";

                if (sizeX != "")
                    parameters += ",width=" + sizeX + "px";
                if (sizeY != "")
                    parameters += ",height=" + sizeY + "px";
                if (resize == '1')
                    parameters += ",resizable=yes";

                var newWindow = window.open(url, "newWindow2", parameters);
                //newWindow.focus();
            }
            else {
                parameters = "help:no; status:no;";
                if (sizeX != "")
                    parameters += "dialogWidth:" + sizeX + "px;";
                if (sizeY != "")
                    parameters += "dialogheight:" + sizeY + "px;";
                if (resize == "1")
                    parameters += "resizable:yes;";

                window.showModalDialog(url, "newWindowDialog2", parameters);
            }
        }

        function Close() {
            self.close();
        }
    </script>
</head>
<body onload="SelectPrintOptions();Close();">
    <form id="form1" runat="server">
    <asp:HiddenField ID="hdnTemplatePath" runat="server" />
    </form>
</body>
</html>
