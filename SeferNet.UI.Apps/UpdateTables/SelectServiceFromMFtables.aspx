<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="UpdateTables_SelectServiceFromMFtables" Codebehind="SelectServiceFromMFtables.aspx.cs" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>בחירה מטבלאות MF</title>
    <base target="_self" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="-1" />
    <link rel="STYLESHEET" href="../CSS/General/general.css" type="text/css" />
    <script type="text/javascript" language="javascript">
        function SelectService(code, desc) {
            parent.SetServiceCodeAndDescription(code, desc);
            SelectJQueryClose();
        }

        function SelectJQueryClose() {
            window.parent.$("#dialog-modal-select").dialog('close');
            return false;
        }
    </script>
</head>
<body dir="rtl">
    <form id="form1" runat="server">
    <asp:ScriptManager runat="server">
    </asp:ScriptManager>
    <table style="margin: 10px" border="0">
        <tr>
            <td>
                <asp:Label ID="Label1" runat="server">מספר טבלה:</asp:Label>
            </td>
            <td>
                <asp:CheckBoxList ID="lstChkMFTables" CssClass="RegularLabel" 
                                                runat="server" RepeatDirection="Horizontal">
                    <asp:ListItem Value="601" Selected="True">601</asp:ListItem>
                    <asp:ListItem Value="606">606</asp:ListItem>
                </asp:CheckBoxList>
            </td>
            <td>
                <table cellpadding="0" cellspacing="0">
                    <tr>
                        <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                            background-position: bottom left;">
                            &nbsp;
                        </td>
                        <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                            background-repeat: repeat-x; background-position: bottom;">
                            <asp:Button ID="btnSearch" runat="server" Text="חיפוש" CssClass="RegularUpdateButton"
                                OnClick="btnSearch_Click"></asp:Button>
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
    <div style="margin: 12px">
        <asp:Label ID="Label2" runat="server">תיאור שירות:</asp:Label>
        <asp:TextBox runat="server" ID="txtSearchOldDesc"></asp:TextBox>
        <cc1:AutoCompleteExtender ID="acSearchService" runat="server" TargetControlID="txtSearchOldDesc"
            UseContextKey="True" DelimiterCharacters="" Enabled="True" CompletionSetCount="100"
            CompletionListCssClass="flyout-background" CompletionListItemCssClass="flyout-item"
            CompletionListHighlightedItemCssClass="flyout-item-hover" MinimumPrefixLength="1"
            ServiceMethod="GetServicesFromMFTables" CompletionInterval="100" ServicePath="">
        </cc1:AutoCompleteExtender>
    </div>
    <div id="pnlResults" runat="server" visible="false" style="margin: 5px; padding-right: 5px; height: 350px; overflow: auto; width: 380px;
        direction: ltr; border: 1px solid gray">
        <div style="direction: rtl;">
            <asp:GridView ID="gvResults" runat="server" AutoGenerateColumns="false" Width="360px"
                OnRowDataBound="gvResults_DataBound">
                <Columns>
                    <asp:BoundField DataField="serviceCode" HeaderText="קוד" ItemStyle-Width="40px" />
                    <asp:BoundField DataField="Description" HeaderText="תיאור" ItemStyle-Width="200px" />                    
                    <asp:TemplateField>
                        <HeaderTemplate>
                            <asp:Label Text="מקושר" runat="server"></asp:Label>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <asp:Label ID="lblSelected" runat="server"></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField>
                        <ItemTemplate>
                            <asp:LinkButton ID="lnkSelect" runat="server" Text="בחר" />
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>
    </form>
</body>
</html>
