<%@ Page Language="C#" AutoEventWireup="true" Inherits="PrintingParameters" Codebehind="PrintingParameters.aspx.cs" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script type="text/javascript">
        function SelectNearestDepts(multiSelect, requireUserPermisions) {
            var topi = 50;
            var lefti = 100;
            var url = "";

            var currentDeptCode = document.getElementById('hdnCurrentDeptCode').value;
            var templatePath = document.getElementById('hdnTemplatePath').value;

            var features = "top:" + topi + "px;left:" + lefti + "px; dialogWidth:610px; dialogheight:600px; help:no; status:no; ";
            var strUrl = "../Public/SelectDepts.aspx?multiSelect=" + multiSelect + "&requireUserPermisions=" + requireUserPermisions  + "&useForPrint=1";

            var obj = window.showModalDialog(strUrl, "SelectDepts", features);

            if (obj != null) {
                url = templatePath + "FrmSelectTemplate.aspx?Template=PrintZoomClinicOuter&NearestDepts=" + obj.Value + "&CurrentDeptCode=" + currentDeptCode;
                //window.submeet();
                //return true;
            }
            else {
                url = templatePath + "FrmSelectTemplate.aspx?Template=PrintZoomClinicOuter&NearestDepts=" + "&CurrentDeptCode=" + currentDeptCode;

                //alert("empty");
                //return false;
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
<body onload="SelectNearestDepts(1, 0);Close();">
    <form id="form1" runat="server">
    <asp:HiddenField ID="hdnCurrentDeptCode" runat="server" />
    <asp:HiddenField ID="hdnTemplatePath" runat="server" />
    </form>
</body>
</html>
