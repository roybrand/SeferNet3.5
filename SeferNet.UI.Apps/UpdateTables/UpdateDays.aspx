<%@ Page Title="עדכון טבלת ימים" Language="C#" MasterPageFile="~/SeferMasterPage.master" AutoEventWireup="true" Inherits="UpdateDays" Codebehind="UpdateDays.aspx.cs" %>

<asp:Content ID="Content1" ContentPlaceHolderID="phHead" Runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="pageContent" Runat="Server">
    <asp:UpdatePanel runat="server">
        <ContentTemplate>
            <asp:GridView SkinID="GridViewUpdateTables" ID="grDays" runat="server" 
                AutoGenerateColumns="false" onrowediting="grDays_RowEditing" 
                onrowupdating="grDays_RowUpdating" onrowdatabound="grDays_RowDataBound" 
                onrowcommand="grDays_RowCommand" 
                onrowcancelingedit="grDays_RowCancelingEdit">
                <Columns>
                    <asp:TemplateField HeaderText="קוד" HeaderStyle-Height="30px" HeaderStyle-HorizontalAlign="Center" ItemStyle-Height="30px" ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                        <ItemTemplate>
                            <asp:Label id="lblCode" runat="server" Text='<%#Eval("ReceptionDayCode") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="יום" HeaderStyle-Height="30px" HeaderStyle-HorizontalAlign="Center" ItemStyle-Height="30px" ItemStyle-Width="70px" ItemStyle-HorizontalAlign="Center">
                        <ItemTemplate>
                            <asp:Label id="lblDay" runat="server" Text='<%#Eval("ReceptionDayName") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    
                    <asp:TemplateField HeaderText="האם מופיע בחיפוש" HeaderStyle-Height="30px" HeaderStyle-HorizontalAlign="Center" ItemStyle-Height="30px" ItemStyle-Width="100px" ItemStyle-HorizontalAlign="Center">
                        <ItemTemplate>
                            <asp:Label ID="lblSearch" runat="server" Text='<%#Eval("UseInSearch") %>'></asp:Label>
                            <asp:CheckBox ID="cbSearch" runat="server" Enabled="false" />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="האם לתצוגה" HeaderStyle-Height="30px" HeaderStyle-HorizontalAlign="Center" ItemStyle-Height="30px" ItemStyle-Width="100px" ItemStyle-HorizontalAlign="Center">
                        <ItemTemplate>
                            <asp:Label ID="lblDisplay" runat="server" Text='<%#Eval("Display") %>'></asp:Label>
                            <asp:CheckBox Enabled="false" ID="cbDisplay" runat="server" />
                        </ItemTemplate>
                        
                    </asp:TemplateField>
                    
                    <asp:TemplateField>
                        <ItemTemplate>
                            <asp:ImageButton runat="server" CommandName="Edit"
                                        ImageUrl="~/Images/btn_edit.gif" CommandArgument='<%#Eval("Display") %>' />
                            
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:ImageButton runat="server" CommandName="Cancel"
                                        ImageUrl="~/Images/btn_cancel.gif" />
                            <asp:ImageButton runat="server" CommandName="Update"
                                        ImageUrl="~/Images/btn_approve.gif" />
                        </EditItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>

