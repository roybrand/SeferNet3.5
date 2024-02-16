<%@ Reference Page="~/Admin/AdminBasePage.aspx" %>

<%@ Page Language="C#" Title="עדכון טבלת המרה" AutoEventWireup="true" MasterPageFile="~/seferMasterPage.master" EnableEventValidation="false" Inherits="UpdateUnitTypeConversion"
    meta:resourcekey="PageResource1" Codebehind="UpdateUnitTypeConversion.aspx.cs" %>

<%@ MasterType VirtualPath="~/seferMasterPage.master" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<asp:Content ID="Content1" ContentPlaceHolderID="phHead" runat="Server">
<script src="../Scripts/updateItems.js" type="text/javascript"></script>

<script type="text/javascript">
    function ScrollDivToSelected() {
        //alert("Hi");
        var scrollPosition = document.getElementById('<%=txtScrollTop.ClientID %>').value;
        document.getElementById('<%=divGvUnitTypeConversion.ClientID %>').scrollTop = scrollPosition;
    }

    function GetScrollPosition(obj) {
        document.getElementById('<%=txtScrollTop.ClientID %>').value = obj.scrollTop;
    }

    function body_onload() {
        //alert("Hi");
    }

    //window.onload = ScrollDivToSelected; 
</script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="pageContent" runat="Server">
<div id="progress" class="SearchProgressBar">
    <asp:UpdateProgress ID="UpdateProgress1" runat="server" 
        AssociatedUpdatePanelID="UpdatePanel1">
        <ProgressTemplate>
            <asp:Image ID="img" runat="server" ImageUrl="~/Images/Applic/progressBar.gif" />
        </ProgressTemplate>
    </asp:UpdateProgress>
</div>

<table cellpadding="0" cellspacing="0" style="width:990px">
    <tr>
        <td dir="rtl" valign="top" align="right">
            <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Always">
                <ContentTemplate>
                    <table cellpadding="0" cellspacing="0">
                        <tr>
                            <td dir="ltr">
                                <div id="divGvUnitTypeConversion" onscroll="GetScrollPosition(this)" runat="server" style="border:solid 1px #555555;">
                                <div dir="rtl">
                                <asp:GridView skinid="GridViewUpdateTables" ID="gvUnitTypeConversion" runat="server"
                                    onsorting="gvUnitTypeConversion_Sorting" 
                                    onrowdatabound="gvUnitTypeConversion_RowDataBound">
                                    <Columns>
                                        <asp:TemplateField Visible="false">
                                            <ItemTemplate>
                                                <asp:Label runat="server" ID="lblConvertId" Text='<%# Eval("ConvertId") %>'></asp:Label>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="סוג סימול" SortExpression="SugSimul" ItemStyle-Width="35px">
                                            <ItemTemplate>
                                                <asp:Label runat="server" ID="lblSugSimul" Text='<%# Eval("SugSimul") %>'></asp:Label>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="תיאור" SortExpression="SimulDesc" ItemStyle-Width="100px">
                                            <ItemTemplate>
                                                <asp:Label runat="server" ID="lblSimulDesc" Text='<%# Eval("SimulDesc") %>'></asp:Label>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="תת סוג סימול" SortExpression="TatSugSimul" ItemStyle-Width="40px">
                                            <ItemTemplate>
                                                <asp:Label runat="server" ID="lblTatSugSimul" Text='<%# Eval("TatSugSimul") %>'></asp:Label>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="תיאור" SortExpression="TatSugSimulDesc" ItemStyle-Width="100px">
                                            <ItemTemplate>
                                                <asp:Label runat="server" ID="lblTatSugSimulDesc" Text='<%# Eval("TatSugSimulDesc") %>'></asp:Label>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="תת התמחות" SortExpression="TatHitmahut" ItemStyle-Width="45px">
                                            <ItemTemplate>
                                                <asp:Label runat="server" ID="lblTatHitmahut" Text='<%# Eval("TatHitmahut") %>'></asp:Label>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="תיאור" SortExpression="HitmahutDesc" ItemStyle-Width="100px">
                                            <ItemTemplate>
                                                <asp:Label runat="server" ID="lblHitmahutDesc" Text='<%# Eval("HitmahutDesc") %>'></asp:Label>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="רמת פעילות" SortExpression="RamatPeilut" ItemStyle-Width="40px">
                                            <ItemTemplate>
                                                <asp:Label runat="server" ID="lblRamatPeilut" Text='<%# Eval("RamatPeilut") %>'></asp:Label>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="תיאור" SortExpression="RamatPeilutDesc" ItemStyle-Width="100px">
                                            <ItemTemplate>
                                                <asp:Label runat="server" ID="lblRamatPeilutDesc" Text='<%# Eval("RamatPeilutDesc") %>'></asp:Label>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="סוג מרפאה" SortExpression="key_TypUnit" ItemStyle-Width="40px">
                                            <ItemTemplate>
                                                <asp:Label runat="server" ID="lblKey_TypUnit" Text='<%# Eval("key_TypUnit") %>'></asp:Label>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="תיאור" SortExpression="UnitTypeName" ItemStyle-Width="130px">
                                            <ItemTemplate>
                                                <asp:Label runat="server" ID="lblUnitTypeName" Text='<%# Eval("UnitTypeName") %>'></asp:Label>
                                            </ItemTemplate>
                                            <EditItemTemplate>
                                                <asp:DropDownList ID="ddlUnitType" DataValueField="UnitTypeCode" DataTextField="UnitTypeName" Width="125px" runat="server"></asp:DropDownList>
                                            </EditItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="מגזר" SortExpression="PopulationSectorDescription" ItemStyle-Width="80px">
                                            <ItemTemplate>
                                                <asp:Label runat="server" ID="lblPopulationSectorDescription" Text='<%# Eval("PopulationSectorDescription") %>'></asp:Label>
                                            </ItemTemplate>
                                            <EditItemTemplate>
                                                <asp:DropDownList ID="ddlPopulationSector" DataValueField="PopulationSectorID" AppendDataBoundItems="true"
                                                    DataTextField="PopulationSectorDescription" Width="75px" runat="server"></asp:DropDownList>
                                            </EditItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="פעיל" SortExpression="Active"  ItemStyle-Width="30px">
                                            <ItemTemplate>
                                                <asp:CheckBox ID="cbActive" runat="server" Checked='<%# Eval("Active") %>' Enabled="false" />
                                            </ItemTemplate>
                                            <EditItemTemplate>
                                                <asp:CheckBox ID="cbActive" runat="server" Checked='<%# Eval("Active") %>' />
                                            </EditItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="" ItemStyle-Width="100px" ItemStyle-HorizontalAlign="Center" >
                                            <ItemTemplate>
                                                <asp:ImageButton ID="imgUpdate" runat="server" OnClick="imgUpdate_Click" ImageUrl="~/Images/btn_edit.gif" ToolTip="עדכן סוג יחידה"/>
                                            </ItemTemplate>
                                            <EditItemTemplate>
                                                <asp:ImageButton ID="imgCancel" runat="server" CausesValidation="false"
                                                    OnClick="imgCancel_Click" ImageUrl="~/Images/btn_cancel.gif"  />
                                                <asp:ImageButton ID="imgSave" runat="server" CausesValidation="true" CommandName="save"
                                                    OnClick="imgSave_Click" ImageUrl="~/Images/btn_approve.gif"  />
                                            </EditItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                                </div>
                                </div>
                            </td>
                        </tr>
                    </table>
                </ContentTemplate>
            </asp:UpdatePanel>
        </td>
    </tr>
    <tr>
        <td>
            <asp:TextBox ID="txtScrollTop" runat="server" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>
        </td>
    </tr>
</table>
</asp:Content>
