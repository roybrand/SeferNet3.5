<%@ Page Title="עדכון טבלת פעילויות" Language="C#" MasterPageFile="~/SeferMasterPage.master"
    AutoEventWireup="true" Inherits="UpdateTables_UpdateEvents" Codebehind="UpdateEvents.aspx.cs" %>

<asp:Content ID="Content1" ContentPlaceHolderID="pageContent" runat="Server">

    <script type="text/javascript" language="javascript" src="../Scripts/LoadJqueryIfNeeded.js"></script>

    <script type="text/javascript">

        function ChooseFile(obj) {
            document.getElementById('uploadFile').click();

            fileName = document.getElementById('uploadFile').value;

            $('#' + obj.id).closest('table').closest('tr').find("input:text[id$='txtChosenFile']").val(fileName);
        }

        function SetScroll(val) {
            if (val > 0)
                document.getElementById('divScroll').scrollTop = val + 5;
        }
    
    </script>

    <asp:UpdatePanel runat="server">
        <ContentTemplate>
            <table width="950px">
                <tr>
                    <td>
                        <input type="hidden" id="scrollPosition" runat="server" />
                        <div id="divScroll" style="height: 550px; direction: ltr; overflow-y:scroll" 
                                onscroll="javascript:document.getElementById('<%= scrollPosition.ClientID %>').value = this.scrollTop; ">
                            <div style="direction: rtl">
                                <asp:GridView ID="gvEvents" Width="650px" runat="server" SkinID="GridViewTree" AutoGenerateColumns="false"
                                    OnRowDataBound="gvEvents_RowDataBound" OnRowEditing="gvEvents_RowEditing" OnRowCancelingEdit="gvEvents_cancelEdit">
                                    <Columns>
                                        <asp:TemplateField HeaderText="קוד" ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                            <%--event code--%>
                                            <ItemTemplate>
                                                <asp:Label ID="lblEventCode" runat="server" Text='<%# Eval("EventCode") %>' />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="תיאור" ItemStyle-VerticalAlign="Middle">
                                            <%--event name--%>
                                            <ItemTemplate>
                                                <asp:Label ID="lblEventName" runat="server" Text='<%# Eval("EventName") %>' />
                                            </ItemTemplate>
                                            <EditItemTemplate>
                                                <asp:TextBox ID="txtEventName" runat="server" Text='<%# Eval("EventName") %>' />
                                            </EditItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="פעיל" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="40px">
                                            <%--is active--%>
                                            <ItemTemplate>
                                                <asp:CheckBox ID="chkIsActive" runat="server" Checked='<%# Eval("IsActive") %>' />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="קבצים משויכים" ItemStyle-VerticalAlign="Top">
                                            <%--attached files--%>
                                            <ItemTemplate>
                                                <asp:GridView ID="gvAttachedFiles" runat="server" AutoGenerateColumns="false" ShowHeader="false">
                                                    <Columns>
                                                        <asp:TemplateField>
                                                            <ItemTemplate>
                                                                <asp:Label ID="lblFileDescription" runat="server" Text='<%# Eval("FileDescription") %>' />
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <%--<asp:TemplateField>
                                                <ItemTemplate>
                                                    <asp:ImageButton style="padding-right:10px;" ID="btnDeleteFile" runat="server" ImageUrl="~/Images/Applic/btn_X_red.gif"
                                                     OnClick="btnDeleteFile_click" CommandArgument='<%# Eval("EventFileID") %>' />
                                                </ItemTemplate>
                                            </asp:TemplateField>--%>
                                                    </Columns>
                                                </asp:GridView>
                                            </ItemTemplate>
                                            <EditItemTemplate>
                                                <table style="margin-top: 15px">
                                                    <tr>
                                                        <td>
                                                            <asp:TextBox ID="txtChosenFile" runat="server" Width="200px"></asp:TextBox>
                                                            <input id="uploadFile" type="file" style="display: none" />
                                                        </td>
                                                        <td>
                                                            <table cellpadding="0" cellspacing="0">
                                                                <tr>
                                                                    <td class="buttonRightCorner">
                                                                        &nbsp;
                                                                    </td>
                                                                    <td class="buttonCenterBackground">
                                                                        <asp:Button ID="btnChooseFile" Text="בחירת קובץ" runat="server" CausesValidation="false"
                                                                            CssClass="RegularUpdateButton" OnClientClick="ChooseFile(this); return false;" />
                                                                    </td>
                                                                    <td class="buttonLeftCorner">
                                                                        &nbsp;
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </table>
                                                <asp:GridView ID="gvEditAttachedFiles" runat="server" AutoGenerateColumns="false"
                                                    ShowHeader="false">
                                                    <Columns>
                                                        <asp:TemplateField>
                                                            <ItemTemplate>
                                                                <asp:Label ID="lblFileDescription" runat="server" Text='<%# Eval("FileDescription") %>' />
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField>
                                                            <ItemTemplate>
                                                                <asp:ImageButton ID="btnDeleteFile" runat="server" CommandArgument='<%# Eval("EventFileID") %>'
                                                                    Style="padding-right: 10px;" OnClick="btnDeleteFile_click" ImageUrl="~/Images/Applic/btn_X_red.gif" />
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                    </Columns>
                                                </asp:GridView>
                                            </EditItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField>
                                            <ItemTemplate>
                                                <asp:ImageButton ID="btnUpdate" CommandName="Edit" runat="server" ImageUrl="~/Images/btn_edit.gif" />
                                            </ItemTemplate>
                                            <EditItemTemplate>
                                                <asp:ImageButton ID="btnSaveRow" runat="server" OnClick="btnSaveRow_click" ImageUrl="~/Images/btn_approve.gif" />
                                                <asp:ImageButton ID="btnCancel" runat="server" CommandName="Cancel" ImageUrl="~/Images/btn_cancel.gif"
                                                    OnClick="btnCancel_click" />
                                            </EditItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </div>
                    </td>
                    <td valign="top">
                        <asp:Panel ID="Panel1" runat="server" BorderStyle="Solid" BorderWidth="1px" Width="250px"
                            BorderColor="Black" Style="padding: 5px; margin-right: 5px">
                            <table style="margin-right: 10px">
                                <tr>
                                    <td>
                                        <asp:Label ID="lblCode" runat="server">קוד:</asp:Label>
                                    </td>
                                    <td>
                                        <asp:Label ID="lblCodeNumber" runat="server"></asp:Label>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:Label ID="lblDesc" runat="server">תיאור:</asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtAddDecription" runat="server"></asp:TextBox>
                                        <asp:RequiredFieldValidator ID="vldDesc" runat="server" ControlToValidate="txtAddDecription"
                                            ValidationGroup="AddEvent"></asp:RequiredFieldValidator>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:Label ID="lblIsActive" runat="server">האם פעיל:</asp:Label>
                                    </td>
                                    <td>
                                        <asp:CheckBox ID="chkIsActive" runat="server" />
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center" colspan="2">
                                        <table cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td class="buttonRightCorner">
                                                    &nbsp;
                                                </td>
                                                <td class="buttonCenterBackground">
                                                    <asp:Button ID="btnAdd" Text="הוסף" runat="server" CssClass="RegularUpdateButton"
                                                        OnClick="btnAdd_Click" ValidationGroup="AddEvent" />
                                                </td>
                                                <td class="buttonLeftCorner">
                                                    &nbsp;
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </asp:Panel>
                    </td>
                </tr>
            </table>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
