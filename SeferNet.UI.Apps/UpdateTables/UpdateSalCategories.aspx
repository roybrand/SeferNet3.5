<%@ Page Title="ניהול נושאי סל שרותים" Language="C#" MasterPageFile="~/SeferMasterPage.master"
    AutoEventWireup="true" EnableEventValidation="false"
    Inherits="Admin_UpdateSalCategories" Codebehind="UpdateSalCategories.aspx.cs" %>

<%@ Register TagPrefix="uc1" TagName="sortableColumn" Src="~/UserControls/SortableColumnHeader.ascx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<asp:Content ID="Content1" ContentPlaceHolderID="phHead" runat="Server">
    <link rel="stylesheet" href="../css/General/thickbox.css" type="text/css" media="screen" />
    <script type="text/javascript">

        function ClearAddSection() {
            document.getElementById('<%= txtNewSalCategoryDescription.ClientID %>').value = '';
        }

        function clearSearchFeilds() {
            $("#<%=txtSalCategoryID.ClientID %>").val("");
            $("#<%=txtSalCategoryDescription.ClientID %>").val("");
        }

        function addNewSalCategory() {
            var tWidth = 340; // 335;
            var tHeight = 170; //165;

            var tmpHref = "#TB_inline?inlineId=divAddNewSalCategory&modal=true&height=" + tHeight + "&width=" + tWidth;
            $("#aTB_inline").attr("href", tmpHref);
            $("#aTB_inline").click();
        }

        function doPostBack() {
            var syn = $("#<%=txtNewSalCategoryDescription.ClientID %>").val();
            $("#<%=hdNewSalCategoryDescription.ClientID %>").val(syn);

            setTimeout('__doPostBack(\'btnAddSalCategory\',\'\')', 0);
        }

        
    </script>
    <style type="text/css">
        .mrgTop
        {
            margin-top: 2px;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="pageContent" runat="Server">
    <asp:UpdatePanel runat="server" ID="upUpdateContent">
        <Triggers>
        </Triggers>
        <ContentTemplate>
            <div>
                <div style="margin-top: 5px; margin-right: 10px;">
                    <table cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7">
                        <tr>
                            <td style="padding: 0; height: 10px; background-image: url('../Images/Applic/RTcornerGrey10.gif');
                                background-repeat: no-repeat; background-position: top right">
                            </td>
                            <td style="padding: 0; background-image: url('../Images/Applic/borderGreyH.jpg');
                                background-repeat: repeat-x; background-position: top">
                            </td>
                            <td style="padding: 0; background-image: url('../Images/Applic/LTcornerGrey10.gif');
                                background-repeat: no-repeat; background-position: top left">
                            </td>
                        </tr>
                        <tr>
                            <td style="border-right: solid 2px #909090;">
                                &nbsp;
                            </td>
                            <td align="right">
                                <div style="width: 960px">
                                    <table cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td>
                                                <asp:Label ID="lblSalCategoryID" runat="server" Text="קוד נושא"></asp:Label>&nbsp;
                                            </td>
                                            <td>
                                                <asp:TextBox ID="txtSalCategoryID" runat="server" Width="60px"></asp:TextBox>
                                            </td>
                                            <td style="width: 10px;">
                                            </td>
                                            <td>
                                                <asp:Label ID="lblSalCategoryDescription" runat="server" Text="שם נושא"></asp:Label>&nbsp;
                                            </td>
                                            <td>
                                                <asp:TextBox ID="txtSalCategoryDescription" runat="server" Width="110px"></asp:TextBox>
                                            </td>
                                            <td style="width: 10px;">
                                                &nbsp;
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
                                                            <asp:Button ID="btnSearch" Width="40px" runat="server" Text="חיפוש" CssClass="RegularUpdateButton"
                                                                ValidationGroup="vgrSearch" OnClick="btnSearch_Click"></asp:Button>
                                                        </td>
                                                        <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                            background-repeat: no-repeat;">
                                                            &nbsp;
                                                        </td>
                                                        <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                            background-position: bottom left;">
                                                            &nbsp;
                                                        </td>
                                                        <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                            background-repeat: repeat-x; background-position: bottom;">
                                                            <input type="button" style="width:40px" value="ניקוי" class="RegularUpdateButton" onclick="clearSearchFeilds();" />
                                                        </td>
                                                        <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                            background-repeat: no-repeat;">
                                                            &nbsp;
                                                        </td>
                                                        <td style="width: 40px;">
                                                        </td>
                                                        <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                            background-position: bottom left;">
                                                            &nbsp;
                                                        </td>
                                                        <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                            background-repeat: repeat-x; background-position: bottom;">
                                                            <input type="button" style="width: 80px;" value="הוספת נושא" class="RegularUpdateButton"
                                                                onclick="addNewSalCategory();" />
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
                                </div>
                            </td>
                            <td style="border-left: solid 2px #909090;">
                                <div style="width: 6px;">
                                </div>
                            </td>
                        </tr>
                        <tr style="height: 8px">
                            <td style="background-image: url('../Images/Applic/RBcornerGrey10.gif'); background-repeat: no-repeat;
                                background-position: bottom right">
                            </td>
                            <td style="background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x;
                                background-position: bottom">
                            </td>
                            <td style="background-image: url('../Images/Applic/LBcornerGrey10.gif'); background-repeat: no-repeat;
                                background-position: bottom left">
                            </td>
                        </tr>
                    </table>
                </div>
                <div id="divResults" visible="false" runat="server" style="margin-top: 20px; padding-right: 10px">
                    <table cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7">
                        <tr>
                            <td style="width: 8px; height: 8px; background-image: url('../Images/Applic/RTcornerGrey10.gif');
                                background-repeat: no-repeat; background-position: top right">
                            </td>
                            <td style="background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x;
                                background-position: top">
                            </td>
                            <td style="width: 8px; background-image: url('../Images/Applic/LTcornerGrey10.gif');
                                background-repeat: no-repeat; background-position: top left;">
                            </td>
                        </tr>
                        <tr>
                            <td style="border-right: 2px solid #949494;">
                                &nbsp;
                            </td>
                            <td>
                                <div id="divHeaders" runat="server" style="margin-right: 20px;">
                                    <table cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td style="width: 120px;">
                                                <uc1:sortableColumn ID="ServiceCode" runat="server" Text="קוד הנושא" ColumnIdentifier="SalCategoryID"
                                                    OnSortClick="btnSort_Click" />
                                            </td>
                                            <td style="width: 816px;">
                                                <uc1:sortableColumn ID="ServiceDescription" runat="server" Text="שם הנושא" ColumnIdentifier="SalCategoryDescription"
                                                    OnSortClick="btnSort_Click" />
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                                <div style="direction: ltr; overflow-y: scroll; height: 380px;">
                                    <div style="direction: rtl; margin-right: 5px;">
                                        <asp:GridView ID="gvSalCategoriesResults" runat="server" Style="margin-top: 3px;
                                            direction: rtl" HeaderStyle-CssClass="DisplayNone" SkinID="GridViewForSearchResults"
                                            OnRowDeleting="gvSalCategoriesResults_OnRowDeleting" AutoGenerateColumns="false"
                                            OnRowUpdating="gvSalCategoriesResults_RowUpdating">
                                            <EmptyDataTemplate>
                                                <asp:Label ID="lblEmptyData" runat="server" Text="אין מידע" CssClass="RegularLabel"></asp:Label>
                                            </EmptyDataTemplate>
                                            <Columns>
                                                <asp:BoundField DataField="SalCategoryID" ItemStyle-CssClass="DisplayNone" />
                                                <asp:TemplateField ItemStyle-Width="120px">
                                                    <ItemTemplate>
                                                        <asp:Label ID="lblSalCategoryID" runat="server" Text='<%# Eval("SalCategoryID")%>'
                                                            CssClass="RegularLabel"></asp:Label>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField ItemStyle-Width="670px">
                                                    <ItemTemplate>
                                                        <asp:Label ID="lblSalCategoryDescription" runat="server" Text='<%# Eval("SalCategoryDescription")%>'
                                                            CssClass="RegularLabel"></asp:Label>
                                                    </ItemTemplate>
                                                    <EditItemTemplate>
                                                        <asp:TextBox ID="txtSalCategoryDescription" Width="130px" EnableTheming="false" runat="server"
                                                            Text='<%# Eval("SalCategoryDescription")%>'></asp:TextBox>
                                                    </EditItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField ItemStyle-Width="110px" ItemStyle-HorizontalAlign="Left">
                                                    <ItemTemplate>
                                                        <asp:ImageButton CssClass="mrgTop" ID="imgUpdate" CommandArgument='<%# Eval("SalCategoryID")%>'
                                                            runat="server" CommandName="Update" OnClick="imgUpdate_Click" ImageUrl="~/Images/btn_edit.gif"
                                                            CausesValidation="false" />
                                                    </ItemTemplate>
                                                    <EditItemTemplate>
                                                        <table cellpadding="0" cellspacing="0">
                                                            <tr>
                                                                <td>
                                                                    <asp:ImageButton CssClass="mrgTop" ID="imgCancel" runat="server" CausesValidation="false"
                                                                        OnClick="imgCancel_Click" ImageUrl="~/Images/btn_cancel.gif" />
                                                                </td>
                                                                <td style="width: 10px;">
                                                                </td>
                                                                <td style="vertical-align: middle;">
                                                                    <asp:ImageButton CssClass="mrgTop" ID="imgSave" runat="server" CausesValidation="true"
                                                                        CommandName="Update" ImageUrl="~/Images/btn_approve.gif" ValidationGroup="ctrl" />
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </EditItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField ItemStyle-Width="30px" ItemStyle-HorizontalAlign="Center">
                                                    <ItemTemplate>
                                                        <asp:ImageButton CssClass="mrgTop" ID="btnDelete" OnClientClick="if (!confirm('האם ברצונך למחוק את הקטגוריה?')) return false;" runat="server" ImageUrl="~/Images/Applic/btn_X_red.gif"
                                                            CausesValidation="false" ToolTip="מחיקה" CommandName="Delete" />
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                            </Columns>
                                        </asp:GridView>
                                    </div>
                                </div>
                            </td>
                            <td style="border-left: 2px solid #949494;">
                                &nbsp;
                            </td>
                        </tr>
                        <tr style="height: 10px">
                            <td style="background-image: url('../Images/Applic/RBcornerGrey10.gif'); background-repeat: no-repeat;
                                background-position: bottom right">
                            </td>
                            <td style="background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x;
                                background-position: bottom">
                            </td>
                            <td style="background-image: url('../Images/Applic/LBcornerGrey10.gif'); background-repeat: no-repeat;
                                background-position: bottom left">
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <asp:HiddenField ID="hdNewSalCategoryDescription" runat="server" />
            <div id="divAddNewSalCategory" style="display: none;">
                <table cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7;
                    direction: rtl; text-align: right;">
                    <tr>
                        <td style="padding: 0; height: 10px; background-image: url('../Images/Applic/RTcornerGrey10.gif');
                            background-repeat: no-repeat; background-position: top right">
                        </td>
                        <td style="padding: 0; background-image: url('../Images/Applic/borderGreyH.jpg');
                            background-repeat: repeat-x; background-position: top">
                        </td>
                        <td style="padding: 0; background-image: url('../Images/Applic/LTcornerGrey10.gif');
                            background-repeat: no-repeat; background-position: top left">
                        </td>
                    </tr>
                    <tr>
                        <td style="border-right: solid 2px #909090;">
                            &nbsp;
                        </td>
                        <td>
                            <table cellpadding="0" cellspacing="0">
                                <tr>
                                    <td colspan="2" style="height: 5px; _height: 0;">
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:Label ID="Label7" runat="server">שם נושא חדש:</asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtNewSalCategoryDescription" runat="server" Width="200px"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2" style="height: 5px;">
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        <table cellpadding="0" cellspacing="0" style="margin-top: 10px; width: 100%;">
                                            <tr>
                                                <td>
                                                    <table cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td class="buttonRightCorner">
                                                                &nbsp;
                                                            </td>
                                                            <td class="buttonCenterBackground">
                                                                <asp:Button ID="btnAddSalCategory" runat="server" Text="הוספת הנושא" CssClass="RegularUpdateButton"
                                                                    OnClientClick="doPostBack();"></asp:Button>
                                                            </td>
                                                            <td class="buttonLeftCorner">
                                                                &nbsp;
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                                <td>
                                                    <table cellpadding="0" cellspacing="0" style="float: left; margin-left: 5px;">
                                                        <tr>
                                                            <td class="buttonRightCorner">
                                                                &nbsp;
                                                            </td>
                                                            <td class="buttonCenterBackground">
                                                                <asp:Button ID="btnClearAddSection" runat="server" Text="ניקוי" CssClass="RegularUpdateButton"
                                                                    Width="45px" OnClientClick="ClearAddSection(); return false;" CausesValidation="false">
                                                                </asp:Button>
                                                            </td>
                                                            <td class="buttonLeftCorner">
                                                                &nbsp;
                                                            </td>
                                                            <td class="buttonRightCorner">
                                                                &nbsp;
                                                            </td>
                                                            <td class="buttonCenterBackground">
                                                                <input type="button" value="ביטול" class="RegularUpdateButton" onclick="javascript:tb_remove();ClearAddSection();"
                                                                    style="width: 45px;" />
                                                            </td>
                                                            <td class="buttonLeftCorner">
                                                                &nbsp;
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td style="border-left: solid 2px #909090;">
                            &nbsp;
                        </td>
                    </tr>
                    <tr style="height: 10px">
                        <td style="background-image: url('../Images/Applic/RBcornerGrey10.gif'); background-repeat: no-repeat;
                            background-position: bottom right">
                        </td>
                        <td style="background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x;
                            background-position: bottom">
                        </td>
                        <td style="background-image: url('../Images/Applic/LBcornerGrey10.gif'); background-repeat: no-repeat;
                            background-position: bottom left">
                        </td>
                    </tr>
                </table>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    <a id="aTB_inline" style="display: none;" href="" class="thickbox">Show hidden modal
        content.</a>
    <script type="text/javascript" src="../Scripts/srcScripts/Thickbox.js"></script>
</asp:Content>
