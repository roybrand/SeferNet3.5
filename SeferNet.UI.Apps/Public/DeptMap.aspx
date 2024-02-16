<%@ Page Language="C#" AutoEventWireup="true" Inherits="Public_DeptMap" Codebehind="DeptMap.aspx.cs" %>

<%@ Register src="../UserControls/DeptMapUC.ascx" tagname="DeptMapUC" tagprefix="uc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script language="javascript" type="text/javascript">
        // <![CDATA[

        if (window.attachEvent) {
            window.attachEvent('onload',
            function () {
                //document.forms[0].attachEvent('onsubmit', onsubmitMe);

                //instead of onload we will do it on demend ( when the search window asks from it )
                //populateFrameWithHdnIfEmpty();

                PopulateMapFrameIfRequired();
                SpreadClosestPointsOnMap();

            });
        }
        if (window.addEventListener) {
            window.addEventListener('load',
            function () {
                PopulateMapFrameIfRequired();
                SpreadClosestPointsOnMap();
            },
            false);
        }

        function SpreadClosestPointsOnMap() {
            var hdnXML = $get('<%=DeptMapUC1.hdnClinicJsonClientId %>');
            if (hdnXML.value != '') {
                //DeptMapControl
                sendCommand('SendData', hdnXML.value);
            }
        }

        function PopulateMapFrameIfRequired() {
            if (typeof (populateFrameWithHdnIfEmpty) == 'function') {
                populateFrameWithHdnIfEmpty();
            }
        }

// ]]>
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
    <div>          
        <uc1:DeptMapUC ID="DeptMapUC1" runat="server"  />    
    </div>
    </form>
</body>
</html>
