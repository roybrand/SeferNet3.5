<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="Admin_SelectQueueMethod" Codebehind="SelectQueueMethod.aspx.cs" %>

<%@ Reference Page="~/Admin/AdminPopupBasePage.aspx" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ Register Src="../UserControls/PhonesGridUC.ascx" TagName="PhonesGridUC" TagPrefix="UCphones" %>
<%@ Register Src="~/UserControls/QueueOrderHoursUC.ascx" TagName="QueueOrderHoursUC"
    TagPrefix="uc1" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <base target="_self" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="-1" />
    <link rel="STYLESHEET" href="../CSS/General/general.css" type="text/css" />
    <title>אופן זימון</title>
    <script type="text/javascript">
        function SelectJQueryClose() {
            window.parent.$("#dialog-modal-select").dialog('close');
            return false;
        }
    </script>
    <script type="text/javascript">



        function ToggleDivHours(obj) {
            hidden = document.getElementById('<%= hiddenDivHoursStyle.ClientID %>');

            if (document.getElementById('divHours').style.display == 'block') {
                hidden.value = document.getElementById('divHours').style.display = 'none';

                DisableValidators();                

            }
            else {
                
                if (typeof (Page_Validators) != 'undefined') {
                    for (i = 0; i < Page_Validators.length; i++) {
                        Page_Validators[i].enabled = true;
                        //ValidatorEnable(Page_Validators[i], true);
                    }
                }
                hidden.value = document.getElementById('divHours').style.display = 'block';
                pnlPhone = document.getElementById(obj.id.replace('chkQueueOrderMethod', 'pnlSpecialNumber'));
                pnlPhone.style.display = 'block';
                                
            }
        }

        function DisableValidators() {
            if (typeof (Page_Validators) != 'undefined') {
                for (i = 0; i < Page_Validators.length; i++) {

                    Page_Validators[i].IsValid = true;
                    Page_Validators[i].enabled = false;
                    //ValidatorEnable(Page_Validators[i], false);
                }
            }
        }      
    
    </script>

</head>
<body>
    <form id="form1" runat="server" dir="rtl">
    <asp:ScriptManager ID="ScriptManager1" runat="server" />
    <table width="100%" border="0" cellpadding="0" cellspacing="0">
        <tr class="BackColorBlue">
            <td class="LabelBoldWhite_18" valign="top" style="padding-right:5px;padding-top:2px;padding-bottom:2px">
                <asp:Label ID="lblHeader" runat="server" Text="עדכון אופן זימון" EnableTheming="false"></asp:Label>
            </td>
        </tr>
        <tr>
            <td valign="top" style="padding-top:10px">
                <table style="margin-right: 10px" border="0">
                    <tr>
                        <td>
                            <asp:RadioButtonList ID="rbList" runat="server" AutoPostBack="true" 
                                OnSelectedIndexChanged="rbList_SelectedIndexChanged" CssClass="LabelMultiLineBoldDirtyBlue_12">
                            </asp:RadioButtonList>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding-right: 20px">
                            <asp:Repeater ID="rptQueueOrderMethods" runat="server" OnItemDataBound="rptQueueOrderMethods_ItemDataBound">
                                <ItemTemplate>
                                    <table border="0">
                                        <tr>
                                            <td style="width:135px">
                                                <asp:CheckBox ID="chkQueueOrderMethod" runat="server" CssClass="RegularLabelNormal" />

                                            </td>
                                            <td align="right">
                                                <asp:Label ID="lblPhone" runat="server" Visible="false"></asp:Label>
                                                <asp:Panel ID="pnlSpecialNumber" runat="server" Visible="false">
                                                    <UCphones:PhonesGridUC ID="phoneUC" runat="server"  />
                                                </asp:Panel>
                                            </td>
                                            <td>
                                                <asp:HiddenField ID="hiddenValue" runat="server" />
                                            </td>
                                        </tr>
                                    </table>
                                </ItemTemplate>
                            </asp:Repeater>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td style="padding-right:40px">   
                <asp:CustomValidator ID="vldQueueMethod" runat="server" ErrorMessage="* נא לבחור אחת מתתי האפשרויות" 
                    onservervalidate="vldQueueMethod_ServerValidate" CssClass="LabelBoldDirtyBlue"></asp:CustomValidator>
            </td>
        </tr>
        <tr>
            <td align="right" style="padding-right: 80px">
                <div id="divHours" runat="server" class="ScrollBarDiv" style="height: 150px; overflow: auto;
                    direction: ltr; display: none;">
                    <uc1:QueueOrderHoursUC ID="queueHoursControl" runat="server" />
                </div>
            </td>
        </tr>
        <tr>
            <td align="left" valign="bottom" style="position: absolute; bottom: 20px; left: 15px;">
                <table cellpadding="0" cellspacing="0">
                    <tr>
                        <td class="buttonRightCorner">
                            &nbsp;
                        </td>
                        <td class="buttonCenterBackground">
                            <asp:Button ID="btnSave" Text="שמירה" runat="server" CssClass="RegularUpdateButton"
                                OnClick="btnSave_Click" CausesValidation="true" />
                        </td>
                        <td class="buttonLeftCorner">
                            &nbsp;
                        </td>
                        <td class="buttonRightCorner" style="padding-right: 10px">
                        </td>
                        <td class="buttonCenterBackground">
                            <asp:Button ID="Button1" Text="ביטול" runat="server" CssClass="RegularUpdateButton"
                                OnClientClick="self.close();" />
                        </td>
                        <td class="buttonLeftCorner" style="padding-left: 5px">
                            &nbsp;
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    <asp:HiddenField ID="hiddenEnableValidators" runat="server" />
    <asp:HiddenField ID="hiddenDivHoursStyle" runat="server" />
    </form>
</body>
</html>
