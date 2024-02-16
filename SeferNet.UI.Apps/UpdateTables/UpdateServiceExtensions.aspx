<%@ Page Title="ניהול חוזרים לשירותים" Language="C#" MasterPageFile="~/SeferMasterPage.master" 
    Inherits="UpdateServiceExtensions" AutoEventWireup="true" CodeBehind="UpdateServiceExtensions.aspx.cs" %>
<%@ Register TagPrefix="uc1" TagName="sortableColumn" Src="~/UserControls/SortableColumnHeader.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="phHead" runat="server">
        <script type="text/javascript">
            function clearSearchFeilds() {
                $("#<%=txtServiceCode.ClientID %>").val("");
                $("#<%=txtServiceCode.ClientID %>").val("");
                $("#<%=txtServiceName.ClientID %>").val("");
                $("#<%=ddlServiceStatus.ClientID %>").get(0).selectedIndex = 0;
                $("#<%=ddlExtensionExists.ClientID %>").get(0).selectedIndex = 0;
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
                if(divGvServiceResults != null)
                    divGvServiceResults.scrollTop = txt_ScrollPosition.value;
            }
        </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="pageContent" runat="server">
    <div>
        <div id="divSearchPanel" style="margin-top: 5px; margin-right: 10px;">
            <table cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7">
                <tr>
                    <td style="padding:0;height: 10px; background-image: url('../Images/Applic/RTcornerGrey10.gif');
                        background-repeat: no-repeat; background-position: top right">
                    </td>
                    <td style="padding:0;background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x;
                        background-position: top">
                    </td>
                    <td style="padding:0;background-image: url('../Images/Applic/LTcornerGrey10.gif'); background-repeat: no-repeat;
                        background-position: top left">
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
                                    <td style="width:70px;">
                                        <asp:Label ID="Label1" runat="server" Text="קוד שירות:"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtServiceCode" runat="server" Width="60px"></asp:TextBox>
                                    </td>
                                    <td style="width:10px;">
                                        <asp:CompareValidator ID="vldServiceCode" runat="server" ControlToValidate="txtServiceCode"
                                                Operator="DataTypeCheck" Type="Integer" Text="*" ValidationGroup="vgrSearch">
                                        </asp:CompareValidator>
                                    </td>
                                    <td style="width:65px;">
                                        <asp:Label ID="Label2" runat="server" Text="שם שירות:"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtServiceName" runat="server" Width="200px"></asp:TextBox>
                                    </td>
                                    <td style="width:10px;"></td>

                                    <td style="padding-right: 5px;width:45px; ">
                                        <asp:Label ID="lblStatus" runat="server" Text="סטטוס:"> </asp:Label>
                                    </td>
                                    <td valign="middle">
                                        <asp:DropDownList ID="ddlServiceStatus" runat="server" Height="24px" Width="100px">
                                        </asp:DropDownList>
                                    </td>
                                    <td style="padding-right: 20px;width:60px; ">
                                        <asp:Label ID="lblExtensionExists" runat="server" Text="קיים חוזר:"> </asp:Label>
                                    </td>
                                    <td valign="middle">
                                        <asp:DropDownList ID="ddlExtensionExists" runat="server" Height="24px" Width="100px">
                                        </asp:DropDownList>
                                    </td>
                                    <td style="width:100px;"></td>
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
                                                        ValidationGroup="vgrSearch" OnClick="btnSearch_Click" OnClientClick="showProgressBar2('vgrSearch');"></asp:Button>
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
                                                    <input type="button" value="ניקוי" class="RegularUpdateButton" onclick="clearSearchFeilds();" />
                                                    
                                                </td>
                                                <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                    background-repeat: no-repeat;">
                                                    &nbsp;
                                                </td>
                                                <td style="width:40px;"></td>
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
        <!-- Progress image -->
        <div id="divProgressBar11" style="margin-top:55px;visibility:hidden;position:fixed;background:url('../Images/Applic/progressBar2.gif') center no-repeat;width:100%;height:32px;"></div>

        <div id="divResults" visible="false" runat="server" style="margin-top: 20px; padding-right:10px">
            <table cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7">
                <tr>
                    <td style="width:8px;height: 10px; background-image: url('../Images/Applic/RTcornerGrey10.gif');
                        background-repeat: no-repeat; background-position: top right">
                    </td>
                    <td style="background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x;
                        background-position: top">
                    </td>
                    <td style="width:8px;background-image: url('../Images/Applic/LTcornerGrey10.gif'); background-repeat: no-repeat;
                        background-position: top left;">
                    </td>
                </tr>
                <tr>
                    <td style="border-right:2px solid #949494;">&nbsp;</td>
                    <td>
                    <div id="divHeaders" runat="server" style="margin-right: 20px;">
                        <table cellpadding="0" cellspacing="0">
                            <tr>
                                <td style="width:90px;">
                                    <uc1:sortableColumn ID="ServiceCode" runat="server" Text="קוד שירות"
                                        ColumnIdentifier="ServiceCode" OnSortClick="btnSort_Click" />
                                </td>
                                <td style="width:460px;">
                                    <uc1:sortableColumn ID="ServiceName" runat="server" Text="שם שירות"
                                        ColumnIdentifier="ServiceName" OnSortClick="btnSort_Click" />
                                </td>
                                <td style="width:60px;">
                                    <uc1:sortableColumn ID="ServiceStatus" runat="server" Text="פעיל"
                                        ColumnIdentifier="Active" OnSortClick="btnSort_Click" />
                                </td>
                                <td style="width:80px;">
                                    <uc1:sortableColumn ID="ServiceReturnExist" runat="server" Text="יש חוזר"
                                        ColumnIdentifier="ServiceReturnExist" OnSortClick="btnSort_Click" />
                                </td>

                                <td style="width:120px;">
                                    <uc1:sortableColumn ID="DateUpdate" runat="server" Text="תאריך עדכון אחרון"
                                        ColumnIdentifier="DateUpdate" OnSortClick="btnSort_Click" />
                                </td>
                            </tr>
                        </table>
                    </div>

                    <div id="divGvServiceResults" style="direction: ltr; overflow-y:scroll;
                        height: 380px; width:958px" onscroll="GetDivScrollPosition()">
                        <div style="direction: rtl; margin-right: 5px;">
                            <asp:GridView ID="gvServiceResults" runat="server" Style="margin-top: 3px; direction: rtl"
                                HeaderStyle-CssClass="DisplayNone" SkinID="GridViewForSearchResults"
                                AutoGenerateColumns="false" onrowupdating="gvServiceResults_RowUpdating"  >
                                <EmptyDataTemplate>
                                    <asp:Label ID="lblEmptyData" runat="server" Text="אין מידע" CssClass="RegularLabel"></asp:Label>
                                </EmptyDataTemplate>
                                <Columns>
                                    <asp:BoundField DataField="ServiceCode" ItemStyle-CssClass="DisplayNone" />
                                    <asp:TemplateField ItemStyle-Width="90px">
                                        <ItemTemplate>
                                            <asp:Label ID="Label3" runat="server" Text='<%# Eval("ServiceCode")%>' CssClass="RegularLabel"></asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField ItemStyle-Width="480px">
                                        <ItemTemplate>
                                            <asp:Label ID="Label4" runat="server" Text='<%# Eval("ServiceName")%>' CssClass="RegularLabel"></asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField ItemStyle-Width="60px">
                                        <ItemTemplate>
                                            <asp:Label runat="server" Text='<%# Eval("Active")%>' CssClass="RegularLabel"></asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateField> 
                                    <asp:TemplateField ItemStyle-Width="60px">
                                        <ItemTemplate>
                                            <asp:Label runat="server" Text='<%# Eval("ServiceReturnExist")%>' CssClass="RegularLabel"></asp:Label>
                                        </ItemTemplate>
                                        <EditItemTemplate>
                                            <asp:CheckBox ID="cbServiceReturnExist" runat="server" Checked='<%# Eval("ServiceReturnExistBit")%>'/>
                                        </EditItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField ItemStyle-Width="120px">
                                        <ItemTemplate>
                                            <asp:Label runat="server" Text='<%# Eval("DateUpdate")%>'></asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateField>   
                                    <asp:TemplateField ItemStyle-Width="110px" ItemStyle-HorizontalAlign="Left">
                                        <ItemTemplate>
                                            <asp:ImageButton CssClass="mrgTop" ID="imgUpdate" CommandArgument='<%# Eval("ServiceCode")%>' runat="server"
                                             CommandName="Update" OnClick="imgUpdate_Click" ImageUrl="~/Images/btn_edit.gif" CausesValidation="false" />
                                        </ItemTemplate>
                                        <EditItemTemplate>
                                            <table cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td>
                                                        <asp:ImageButton CssClass="mrgTop" ID="imgCancel" runat="server" CausesValidation="false"
                                                            OnClick="imgCancel_Click" ImageUrl="~/Images/btn_cancel.gif" />
                                                    </td>
                                                    <td style="width:10px;"></td>
                                                    <td style="vertical-align:middle;">
                                                        <asp:ImageButton CssClass="mrgTop" ID="imgSave" runat="server" CausesValidation="true" CommandName="Update"
                                                            ImageUrl="~/Images/btn_approve.gif" ValidationGroup="ctrl" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </EditItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>

                    </td>
                    <td style="border-left:2px solid #949494;">&nbsp;</td>
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

</asp:Content>
