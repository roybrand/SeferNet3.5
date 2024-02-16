<%@ Page Title="ניהול קשר מקצועות לנושאים" Language="C#" MasterPageFile="~/SeferMasterPage.master"
    AutoEventWireup="true" EnableEventValidation="false"
    Inherits="Admin_UpdateSalCategoryProfessions" Codebehind="UpdateSalCategoryProfessions.aspx.cs" %>

<%@ Register TagPrefix="uc1" TagName="sortableColumn" Src="~/UserControls/SortableColumnHeader.ascx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<asp:Content ID="Content1" ContentPlaceHolderID="phHead" runat="Server">
    <link rel="stylesheet" href="../css/General/thickbox.css" type="text/css" media="screen" />
    <script type="text/javascript">

        function ClearAddSection() {
            document.getElementById('<%= ddlNewSalCategory.ClientID %>').value = '';
            document.getElementById('<%= ddlNewProfession.ClientID %>').value = '';
        }

        function clearSearchFeilds() {
            $("#<%=ddlSalCategory.ClientID %>").selectedIndex = 0;
            $("#<%=ddlProfession.ClientID %>").selectedIndex = 0;
        }

        function addNewSalProfessionToCategory() {
            alert("hey");
            var tWidth = 340; // 335;
            var tHeight = 170; //165;

            var tmpHref = "#TB_inline?inlineId=divAddNewSalProfessionToCategory&modal=true&height=" + tHeight + "&width=" + tWidth;

            $("#aTBOpenPopup_inline").attr("href", tmpHref);
            $("#aTBOpenPopup_inline").click();
        }

        function ShowNewSalProfessionToCategory() {
            $("#fade").show();
            $("#divWhiteContent").show();
        }

        function HideNewSalProfessionToCategory() {
            $("#fade").hide();
            $("#divWhiteContent").hide();
        }

        function doPostBack() {
            var salCategoryID = $("#<%=ddlNewSalCategory.ClientID %>").val();
            var professionCode = $("#<%=ddlNewProfession.ClientID %>").val();

            $("#<%=hdNewSalCategoryID.ClientID %>").val(salCategoryID);
            $("#<%=hdNewProfessionCode.ClientID %>").val(professionCode);

            setTimeout('__doPostBack(\'btnAddSalProfessionToCategory\',\'\')', 0);
        }

        function SetScrollPosition() {
            var divGridView = document.getElementById('divGridView');
            var hdScrollPosition = document.getElementById('<% = hdScrollPosition.ClientID %>');

            if (hdScrollPosition.value != "") {
                divGridView.scrollTop = hdScrollPosition.value;
            }
        }
        function GetScrollPosition() {
            var divGridView = document.getElementById('divGridView');
            var hdScrollPosition = document.getElementById('<% = hdScrollPosition.ClientID %>');
            hdScrollPosition.value = divGridView.scrollTop;
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
                                            <asp:Label ID="lblSalCategoryID" runat="server" Text="נושא"></asp:Label>&nbsp;
                                        </td>
                                        <td>
                                            <asp:DropDownList ID="ddlSalCategory" runat="server" Width="150px" DataValueField="SalCategoryID"
                                                DataTextField="SalCategoryDescription">
                                            </asp:DropDownList>
                                        </td>
                                        <td style="width: 10px;">
                                        </td>
                                        <td>
                                            <asp:Label ID="lblProfession" runat="server" Text="מקצוע"></asp:Label>&nbsp;
                                        </td>
                                        <td>
                                            <asp:DropDownList ID="ddlProfession" runat="server" Width="150px" DataValueField="Code"
                                                DataTextField="Description">
                                            </asp:DropDownList>
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
                                                        <asp:Button ID="btnAddNew" runat="server" Width="116px" Text="הוספת קישור" 
                                                            CssClass="RegularUpdateButton" onclick="btnAddNew_Click"></asp:Button>
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
                                        <td style="width: 220px;">
                                            <uc1:sortableColumn ID="SalCategoryDescription" runat="server" Text="נושא" ColumnIdentifier="SalCategoryDescription"
                                                OnSortClick="btnSort_Click" />
                                        </td>
                                        <td style="width: 816px;">
                                            <uc1:sortableColumn ID="ProfessionDescription" runat="server" Text="מקצוע" ColumnIdentifier="ProfessionDescription"
                                                OnSortClick="btnSort_Click" />
                                        </td>
                                    </tr>
                                </table>
                            </div>
                            <div id="divGridView" onscroll="GetScrollPosition()" style="direction: ltr; overflow-y: scroll; height: 380px;">
                                <div style="direction: rtl; margin-right: 5px;">
                                    <asp:GridView ID="gvSalProfessionToCategoriesResults" runat="server" Style="margin-top: 3px;
                                        direction: rtl" HeaderStyle-CssClass="DisplayNone" SkinID="GridViewForSearchResults"
                                        OnRowDeleting="gvSalProfessionToCategoriesResults_OnRowDeleting" AutoGenerateColumns="false"
                                        OnRowDataBound="gvSalProfessionToCategoriesResults_RowDataBound">
                                        <EmptyDataTemplate>
                                            <asp:Label ID="lblEmptyData" runat="server" Text="אין מידע" CssClass="RegularLabel"></asp:Label>
                                        </EmptyDataTemplate>
                                        <Columns>
                                            <asp:BoundField DataField="SalProfessionToCategoryID" ItemStyle-CssClass="DisplayNone" />
                                            <asp:BoundField DataField="SalCategoryID" ItemStyle-CssClass="DisplayNone" />
                                            <asp:BoundField DataField="ProfessionCode" ItemStyle-CssClass="DisplayNone" />
                                            <asp:TemplateField ItemStyle-Width="200px">
                                                <ItemTemplate>
                                                    <asp:Label ID="lblSalCategoryDescription" runat="server" Text='<%# Eval("SalCategoryDescription")%>'
                                                        CssClass="RegularLabel"></asp:Label>
                                                </ItemTemplate>
                                                <EditItemTemplate>
                                                    <asp:Label runat="server" ID="lblSalCategoryID" Text='<%# Eval("SalCategoryID")%>'
                                                        Style="display: none"></asp:Label>
                                                    <asp:Label runat="server" ID="lblSalProfessionToCategoryID" Text='<%# Eval("SalProfessionToCategoryID")%>'
                                                        Style="display: none"></asp:Label>
                                                    <asp:DropDownList ID="ddlSalCategory" Width="150px" EnableTheming="false" runat="server"
                                                        DataValueField="SalCategoryID" DataTextField="SalCategoryDescription">
                                                    </asp:DropDownList>
                                                </EditItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField ItemStyle-Width="590px">
                                                <ItemTemplate>
                                                    <asp:Label ID="lblProfessionDescription" runat="server" Text='<%# Eval("ProfessionDescription")%>'
                                                        CssClass="RegularLabel"></asp:Label>
                                                </ItemTemplate>
                                                <EditItemTemplate>
                                                    <asp:Label runat="server" ID="lblProfessionCode" CssClass="DisplayNone" Text='<%# Eval("ProfessionCode")%>'
                                                        Style="display: none"></asp:Label>
                                                    <asp:DropDownList ID="ddlProfession" Width="150px" EnableTheming="false" runat="server"
                                                        DataValueField="Code" DataTextField="Description">
                                                    </asp:DropDownList>
                                                </EditItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField ItemStyle-Width="110px" ItemStyle-HorizontalAlign="Left">
                                                <ItemTemplate>
                                                    <asp:ImageButton ID="btnUpdate" EnableTheming="false" 
                                                        runat="server" ImageUrl="../Images/btn_edit.gif" SalProfessionToCategoryID='<%# Eval("SalProfessionToCategoryID")%>'
                                                        ProfessionCode='<%# Eval("ProfessionCode")%>' SalCategoryID='<%# Eval("SalCategoryID")%>'
                                                        OnClick="btnUpdate_Click">
                                                    </asp:ImageButton>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField ItemStyle-Width="30px" ItemStyle-HorizontalAlign="Center">
                                                <ItemTemplate>
                                                    <asp:ImageButton CssClass="mrgTop" ID="btnDelete" runat="server" ImageUrl="~/Images/Applic/btn_X_red.gif"
                                                            OnClientClick="if (!confirm('האם ברצונך למחוק את הקישור?')) return false;" CausesValidation="false" ToolTip="מחיקה" CommandName="Delete" />
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
        <asp:HiddenField ID="hdNewSalCategoryID" runat="server" />
        <asp:HiddenField ID="hdNewProfessionCode" runat="server" />
        <asp:HiddenField ID="hdScrollPosition" runat="server" />
        <asp:HiddenField ID="hdSalProfessionToCategoryID" runat="server" />

    <div id="divWhiteContent" class="white_content" style="display:none; width:340px; height:140px;">
    <table style="width:100%; height:100%">
        <tr>
            <td style="width:100%; height:100%" align="center" valign="middle">
                <div id="divAddNewSalProfessionToCategory" style="display: block;">
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
                                <asp:Label ID="lblNewSalCategoryID" runat="server">בחר נושא לקישור:</asp:Label>
                            </td>
                            <td>
                                <asp:DropDownList ID="ddlNewSalCategory" runat="server" Width="200px" DataValueField="SalCategoryID"
                                    DataTextField="SalCategoryDescription" AutoPostBack="true"
                                    OnSelectedIndexChanged="ddlNewSalCategory_SelectedIndexChanged" >
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2" style="height: 5px;">
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label ID="lblNewProfessionCode" runat="server">בחר מקצוע לקישור:</asp:Label>
                            </td>
                            <td>
                                <asp:DropDownList ID="ddlNewProfession" runat="server" Width="200px" DataTextField="Description"
                                    DataValueField="Code">
                                </asp:DropDownList>
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
                                                        <asp:Button ID="btnAddSalProfessionToCategory" Width="90px" runat="server" Text="הוספת הקישור"
                                                            CssClass="RegularUpdateButton" OnClientClick="doPostBack();"></asp:Button>
                                                        <asp:Button ID="btnUpdateSalProfessionToCategory" Width="90px" runat="server" Text="עדכון הקישור"
                                                            CssClass="RegularUpdateButton" OnClick="btnUpdateSalProfessionToCategory_Click"></asp:Button>
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
                                                        <input type="button" value="ביטול" class="RegularUpdateButton" onclick="HideNewSalProfessionToCategory();"
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
            </td>
        </tr>
    </table>

    </div>
    <div id="fade" class="black_overlay"></div>
    <a id="aTBOpenPopup_inline" style="display: none;" href="" class="thickbox">Show hidden
        modal content.</a>
<%--    <script type="text/javascript" src="../Scripts/srcScripts/Thickbox.js"></script>--%>
    </ContentTemplate>
</asp:Content>
