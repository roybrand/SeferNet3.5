<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="Public_DeptReceptionPopUp" ViewStateMode="Disabled" Theme="SeferGeneral" Codebehind="DeptReceptionPopUp.aspx.cs" %>
<%@ Register TagName="ucReceptionAndRemarks" TagPrefix="uc" Src="../usercontrols/DeptReceptionAndRemarks.ascx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>שעות קבלה של יחידה</title>
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="-1" />
    <link rel="Stylesheet" href="~/CSS/General/general.css" type="text/css" />
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.1/themes/base/jquery-ui.css"/>
    <link rel="stylesheet" href="https://code.jquery.com/resources/demos/style.css"/>
    <%--<script type="text/javascript" src="../scripts/LoadJqueryIfNeeded.js"></script>--%>

    

</head>
<body>
    <form id="form1" runat="server">
    <!-- Dept reception -->
    <div style="height: 340px;">
        
        <table align="right" id="tblDeptReception" dir="rtl" style="background-color: White"
            width="810px">
            <tr>
                <td style="background-color: #2889E4">
                    <table cellpadding="0" cellspacing="0" width="100%">
                        <tr>
                            <td align="right" style="height: 28px; padding-right: 5px">
                                <asp:Label ID="lblDeptName" EnableTheming="false" CssClass="LabelBoldWhite_18" runat="server"
                                    Text=""></asp:Label>
                            </td>
                            <td dir="ltr" style="margin: 0px 0px 0px 0px; padding: 0px 0px 0px 5px" align="left">
                                <asp:Label ID="lblPhone" EnableTheming="false" CssClass="LabelBoldWhite_18" runat="server"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2" style="padding-right: 5px">
                                <asp:Label ID="lblDistrictName" EnableTheming="false" CssClass="LabelBoldWhite" runat="server"
                                    Text=""></asp:Label>
                                &nbsp;
                                <asp:Label ID="lblAddress" EnableTheming="false" CssClass="LabelBoldWhite" runat="server"
                                    Text=""></asp:Label>
                                &nbsp;
                                <asp:Label ID="lblCityName" EnableTheming="false" CssClass="LabelBoldWhite" runat="server"></asp:Label>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td>
                    <uc:ucReceptionAndRemarks ID="ucDeptReceptionAndRemarks" DisplayOnlyFirstTwoTables="true" runat="server" />
                </td>
            </tr>
            
        </table>
    </div>
    <table cellpadding="0" cellspacing="0">
        <tr>
            <td style="position: absolute; bottom: 15px; left: 15px;" align="left">
                <table cellpadding="0" cellspacing="0" dir="rtl">
                    <tr>
                        <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                            background-position: bottom left;">
                            &nbsp;
                        </td>
                        <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                            background-repeat: repeat-x; background-position: bottom;">
                            <asp:Button ID="btnClose" runat="server" Text="סגירה" CssClass="RegularUpdateButton"
                                OnClientClick="JQueryDialogClose();"></asp:Button>
                        </td>
                        <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                            background-repeat: no-repeat;">
                            &nbsp;
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    <div id="dialog-modal-select" title="Modal Dialog Select" style="display:none; vertical-align:top; width:100%;">
        <iframe id="modalSelectIFrame" style="width:100%; height:100%; background-color:white;" title="Dialog Title">
    </iframe>
    </div>
    </form>

    <script type="text/javascript" src="https://code.jquery.com/jquery-3.6.0.js"></script>
    <script type="text/javascript" src="https://code.jquery.com/ui/1.13.1/jquery-ui.js"></script>

    <script type="text/javascript">
        function OpenJQueryDialog(url, dialogWidth, dialogHeight, Title) {
            $('#dialog-modal-select').dialog({ autoOpen: false, bgiframe: true, modal: true });
            $('#dialog-modal-select').dialog("option", "width", dialogWidth);
            $('#dialog-modal-select').dialog("option", "height", dialogHeight);
            $('#dialog-modal-select').dialog("option", "title", Title);
            $('#dialog-modal-select').dialog('open');
            $('#dialog-modal-select').parent().appendTo($("form:first"));
            $("#modalSelectIFrame").attr('src', url);

            return false;
        }
    </script>
    <script type="text/javascript">
        function JQueryDialogClose() {
            window.parent.$("#dialog-modal-select").dialog('close');
            return false;
        }
    </script>
</body>
</html>
