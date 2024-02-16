<%@ Page Title="ניהול מקצועות לאינטרנט" Language="C#" MasterPageFile="~/SeferMasterPageIEwide.master"
    AutoEventWireup="true" EnableEventValidation="false"
    Inherits="Admin_UpdateProfessionsForInternet" Codebehind="UpdateProfessionsForInternet.aspx.cs" %>

<%@ Register TagPrefix="uc1" TagName="sortableColumn" Src="~/UserControls/SortableColumnHeader.ascx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<asp:Content ID="Content1" ContentPlaceHolderID="phHead" runat="Server">
    <script type="text/javascript">

        function clearSearchFeilds() {
            $("#<%=txtProfessionCode.ClientID %>").val("");
            $("#<%=txtProfessionDescription.ClientID %>").val("");
        }

        function hideProgressBar() {
            document.getElementById("divProgressBar11").style.visibility = "hidden";
        }

        function showProgressBar2(validation_group) {
            var isValid = Page_ClientValidate(validation_group);
            if (isValid) {
                document.getElementById("divProgressBar11").style.visibility = "visible";
            }
        }

        function GetDivScrollPosition() {
            var scrollPosition = document.getElementById('divGvServiceResults').scrollTop;
            var txt_ScrollPosition = document.getElementById('<%=txt_ScrollPosition.ClientID %>');
                txt_ScrollPosition.value = scrollPosition;
            }

            function SetDivScrollPosition() {
                var divGvServiceResults = document.getElementById('divGvServiceResults');
                var txt_ScrollPosition = document.getElementById('<%=txt_ScrollPosition.ClientID %>');
                if (divGvServiceResults != null)
                    divGvServiceResults.scrollTop = txt_ScrollPosition.value;
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
                                                <asp:Label ID="lblProfessionCode" runat="server" Text="קוד מקצוע"></asp:Label>&nbsp;
                                            </td>
                                            <td>
                                                <asp:TextBox ID="txtProfessionCode" runat="server" Width="60px"></asp:TextBox>
                                            </td>
                                            <td style="width: 10px;">
                                                <asp:CompareValidator ID="vldProfessionCode" runat="server" ControlToValidate="txtProfessionCode"
                                                        Operator="DataTypeCheck" Type="Integer" Text="*" ValidationGroup="vgrSearch">
                                                </asp:CompareValidator>
                                            </td>
                                            <td>
                                                <asp:Label ID="lblProfessionDescription" runat="server" Text="שם מקצוע"></asp:Label>&nbsp;
                                            </td>
                                            <td>
                                                <asp:TextBox ID="txtProfessionDescription" runat="server" Width="110px"></asp:TextBox>
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
                                                            <input type="button" value="ניקוי" style="width:40px" class="RegularUpdateButton" onclick="clearSearchFeilds();" />
                                                        </td>
                                                        <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                            background-repeat: no-repeat;">
                                                            &nbsp;
                                                        </td>
                                                        <td style="width: 40px;">
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                            <td>
                                                <asp:TextBox ID="txt_ScrollPosition" runat="server" EnableTheming="false" CssClass="DisplayNone" ></asp:TextBox>
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
                <!-- Progress image -->
                <div id="divProgressBar11" style="margin-top:55px;visibility:hidden;position:fixed;background:url('../Images/Applic/progressBar2.gif') center no-repeat;width:100%;height:32px;"></div>

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
                                            <td style="width: 60px;">
                                                <uc1:sortableColumn ID="ProfessionCode" runat="server" Text="קוד מקצוע" ColumnIdentifier="ProfessionCode"
                                                    OnSortClick="btnSort_Click" />
                                            </td>
                                            <td style="width: 10px;"></td>
                                            <td style="width: 160px;">
                                                <uc1:sortableColumn ID="ProfessionDescription" runat="server" Text="שם מקצוע" ColumnIdentifier="ProfessionDescription"
                                                    OnSortClick="btnSort_Click" />
                                            </td>
                                            <td style="width: 180px;">
                                                <uc1:sortableColumn ID="ProfessionDescriptionForInternet" runat="server" Text="תאור מקצוע לאינטרנט" 
                                                    ColumnIdentifier="ProfessionDescriptionForInternet" OnSortClick="btnSort_Click" />
                                            </td>
                                            <td style="width: 380px;">
                                                <asp:Label ID="lblProfessionExtraDataHeader" runat="server" EnableTheming="false" CssClass="ColumnHeader" Text="הערה מקצוע לאינטרנט"></asp:Label>
                                            </td>

                                            <td style="width: 70px;">
                                                <uc1:sortableColumn ID="ShowProfessionInInternet" runat="server" Text="הצגה באינטרנט" 
                                                    ColumnIdentifier="ShowProfessionInInternet" OnSortClick="btnSort_Click" />
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                                <div id="divGvServiceResults" style="direction: ltr; overflow-y: scroll; height: 380px;" onscroll="GetDivScrollPosition()">
                                    <div style="direction: rtl; margin-right: 5px;">
                                        <asp:GridView ID="gvProfessionsResults" runat="server" Style="margin-top: 3px;
                                            direction: rtl" HeaderStyle-CssClass="DisplayNone" SkinID="GridViewForSearchResults"
                                            AutoGenerateColumns="false" OnRowUpdating="gvProfessionsResults_RowUpdating" OnRowDataBound="gvProfessionsResults_RowDataBound">
                                            <EmptyDataTemplate>
                                                <asp:Label ID="lblEmptyData" runat="server" Text="אין מידע" CssClass="RegularLabel"></asp:Label>
                                            </EmptyDataTemplate>
                                            <Columns>
                                                <asp:BoundField DataField="ProfessionCode" ItemStyle-CssClass="DisplayNone" />
                                                <asp:TemplateField ItemStyle-Width="70px"  ItemStyle-HorizontalAlign="Right">
                                                    <ItemTemplate>&nbsp;&nbsp;
                                                        <asp:Label ID="lblProfessionCode" runat="server" Text='<%# Eval("ProfessionCode")%>'
                                                            CssClass="RegularLabel"></asp:Label>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField ItemStyle-Width="160px">
                                                    <ItemTemplate>
                                                        <asp:Label ID="lblProfessionDescription" runat="server" Text='<%# Eval("ProfessionDescription")%>'
                                                            CssClass="RegularLabel"></asp:Label>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField ItemStyle-Width="180px">
                                                    <ItemTemplate>
                                                        <asp:Label ID="lblProfessionDescriptionForInternet" runat="server" Text='<%# Eval("ProfessionDescriptionForInternet")%>'
                                                            CssClass="RegularLabel"></asp:Label>&nbsp;
                                                    </ItemTemplate>
                                                    <EditItemTemplate>
                                                        <asp:TextBox ID="txtProfessionDescriptionForInternet" TextMode="MultiLine" Width="180px" Height="50px" EnableTheming="false" runat="server"
                                                            Text='<%# Eval("ProfessionDescriptionForInternet")%>'></asp:TextBox>
                                                    </EditItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField ItemStyle-Width="380px">
                                                    <ItemTemplate>
                                                        <asp:Label ID="lblProfessionExtraData" runat="server" Text='<%# Eval("ProfessionExtraData")%>'
                                                            CssClass="RegularLabel"></asp:Label>&nbsp;
                                                    </ItemTemplate>
                                                    <EditItemTemplate>
                                                        <asp:TextBox ID="txtProfessionExtraData" TextMode="MultiLine" Width="360px" Height="50px" EnableTheming="false" runat="server"
                                                            Text='<%# Eval("ProfessionExtraData")%>'></asp:TextBox>
                                                    </EditItemTemplate>
                                                </asp:TemplateField>

                                                <asp:TemplateField ItemStyle-Width="34px" ItemStyle-HorizontalAlign="Center">
                                                    <ItemTemplate>
                                                        <asp:Label ID="lblShowProfessionInInternet" runat="server" Text='<%# Eval("ShowProfessionInInternet")%>'
                                                            CssClass="RegularLabel"></asp:Label>
                                                    </ItemTemplate>
                                                    <EditItemTemplate>
                                                        <asp:CheckBox ID="cbShowProfessionInInternet" EnableTheming="false" runat="server"></asp:CheckBox>
                                                    </EditItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField ItemStyle-Width="100px" ItemStyle-HorizontalAlign="Left">
                                                    <ItemTemplate>
                                                        <asp:ImageButton CssClass="mrgTop" ID="imgUpdate" CommandArgument='<%# Eval("ProfessionCode")%>'
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
                                                            </tr>
                                                            <tr>
                                                                <td style="vertical-align: middle;">
                                                                    <asp:ImageButton CssClass="mrgTop" ID="imgSave" runat="server" CausesValidation="true"
                                                                        CommandName="Update" ImageUrl="~/Images/btn_approve.gif" ValidationGroup="ctrl" />
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </EditItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField ItemStyle-Width="30px" ItemStyle-HorizontalAlign="Center" Visible="false">
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
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
