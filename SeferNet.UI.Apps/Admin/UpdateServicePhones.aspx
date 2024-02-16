<%@ Page Language="C#" AutoEventWireup="true" Inherits="UpdateServicePhones" Codebehind="UpdateServicePhones.aspx.cs" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<%@ Register Src="../UserControls/PhonesGridUC.ascx" TagName="PhonesGridUC" TagPrefix="UCphones" %>
<%@ Reference Page="~/Admin/AdminPopupBasePage.aspx" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="-1" />
    <base target="_self" />
    <link rel="STYLESHEET" href="../CSS/General/general.css" type="text/css" />
    <title>עידכון טלפונים לשירות</title>
</head>
<body>
    <script type="text/javascript">
        function SelectJQueryClose() {
            window.parent.$("#dialog-modal-select").dialog('close');
            return false;
        }
    </script>
    <script type="text/javascript" src="../Scripts/LoadJqueryIfNeeded.js"></script>
    <script type="text/javascript" language="javascript">
        function PermitCollerRefresh(refresh) {
            return refresh;
        }

        function OpenQueueOrder(url) {
            url = url + "?x_Dept_Employee_ServiceID=" + '<%= X_Dept_Employee_ServiceID %>';
            var text = window.showModalDialog(url, window, "top:100px;dialogHeight:540px; dialogWidth:690px;status:no");
            if (text != null) {
                document.getElementById('<%= lblQueuePhones.ClientID %>').innerHTML = text;
                document.getElementById('<%= txtQueueOrderHasChanged.ClientID %>').value = 1;
            }
        }

        function CheckQueueOrder(val, args) {

            var queueOrder = document.getElementById('<%= lblQueuePhones.ClientID %>').innerHTML;

            //args.IsValid = (queueOrder != "");
            args.IsValid = true;
        }

        function QueueOrderFromDeptClicked(checkbox) {
            if (checkbox.checked)
                $('#divQueueOrderMethod').hide();
            else
                $('#divQueueOrderMethod').show();
        }

    </script>
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnableScriptGlobalization="true"
        EnableScriptLocalization="true" />
        <table cellpadding="0" cellspacing="0" width="100%" border="0">
            <tr class="BackColorBlue">
                <td dir="rtl" style="padding: 5px 10px 2px 0px; width:100%" >
                    <asp:Label ID="lblPageTitle" CssClass="LabelBoldWhite_18"
                        EnableTheming="false" Text="עידכון טלפונים לשירות" runat="server"></asp:Label>
                </td>
            </tr>
        </table>

        <table cellpadding="0" cellspacing="0" width="100%" border="0">
            <tr>
                <td style="display:none">
                    <asp:TextBox ID="txtQueueOrderHasChanged" runat="server"></asp:TextBox>
                </td>
            </tr>
            <tr>
                <td align="right" style="padding: 10px 10px 0px 0px; margin:0px 0px 0px 0px">
                    <table cellpadding="0" cellspacing="0" style="border:1px solid #999999">
                        <tr>
                            <td align="right" style="padding:5px 10px 0px 0px">
                                <asp:Label CssClass="LabelBoldDirtyBlue" EnableTheming="false" ID="lblShowPhones"
                                    runat="server" Text="הצג טלפונים מפרטי נותן שירות ביחידה"></asp:Label>
                                <asp:CheckBox ID="chkShowPhonesFromDept" runat="server" OnCheckedChanged="TogglePhonesPanel"
                                    AutoPostBack="true" />
                            </td>
                        </tr>
                        <tr style="height: 25px">
                            <td align="right" dir="ltr" style="padding:20px 10px 5px 10px ">
                                <asp:Panel ID="pnlPhones" runat="server">
                                    <!-- Place for Phones -->
                                    <UCphones:PhonesGridUC ID="ServicePhonesUC" runat="server" />
                                </asp:Panel>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr style="display:none">
                <td align="right" style="padding:20px 10px 0px 0px;"  dir="rtl">
                    <table style="border:1px solid #999999;height:80px;width:419px"> 
                            <tr>
                                <td style="padding-right:8px" valign="top">
                                    <asp:CheckBox ID="chkQueueOrderFromDept" runat="server" OnCheckedChanged="chkQueueOrderFromDept_checked"
                                        Text="הצג אופן זימון מפרטי נותן שירות ביחידה" CssClass="LabelBoldDirtyBlue"
                                        onclick="QueueOrderFromDeptClicked(this);" AutoPostBack="false" />
                                </td>
                            </tr>                       
                            <tr>
                                <td  style="padding-right:12px">
                                    <asp:panel id="divQueueOrderMethod" runat="server">
                                        <asp:CustomValidator ID="rqdQueueOrder" ClientValidationFunction="CheckQueueOrder"
                                            ErrorMessage="חובה להזין אופן זימון" runat="server" Text="*" Display="Dynamic" />
                                        <asp:Label ID="lblQueueHeader" runat="server" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                            Text="אופן הזימון:"></asp:Label>&nbsp;
                                        <asp:Label ID="lblQueuePhones" runat="server" dir="rtl"></asp:Label>
                                        &nbsp;&nbsp;&nbsp;
                                        <asp:LinkButton ID="lnkUpdateInvatation" 
                                            OnClientClick="OpenQueueOrder('SelectQueueMethod.aspx');return false;"
                                            CssClass="choiseField" runat="server" Text="עדכון אופן הזימון"></asp:LinkButton>
                                    </asp:panel>
                                    
                                </td>                                
                            </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td align="right" style="padding:30px 10px 0px 0px">
                    <table cellpadding="0" cellspacing="0" border="0" dir="rtl">
                        <tr>
                            <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                background-position: bottom left;">
                                &nbsp;&nbsp;
                            </td>
                            <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                background-repeat: repeat-x; background-position: bottom;">

                                <asp:Button ID="btnSave" runat="server" OnClick="btnSave_Click"
                                    Text="שמירה" CssClass="RegularUpdateButton" >
                                </asp:Button>
                            </td>
                            <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                background-repeat: no-repeat;">
                                &nbsp;
                            </td> 
                            <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                background-position: bottom left;padding-right:4px">
                                &nbsp;
                            </td>
                            <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                background-repeat: repeat-x; background-position: bottom;">
                                <asp:Button ID="btnCancel" runat="server" OnClick="btnCancel_Click"
                                    Text="ביטול" CssClass="RegularUpdateButton" ></asp:Button>
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

    </form>
</body>
</html>
