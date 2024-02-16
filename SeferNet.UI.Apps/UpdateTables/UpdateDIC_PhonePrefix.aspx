<%@ Reference Page="~/Admin/AdminBasePage.aspx" %>
<%@ Page Language="C#" Title="עדכון טבלת קידומת טלפון" AutoEventWireup="true" MasterPageFile="~/seferMasterPage.master" Inherits="UpdateDIC_HandicappedFacilities" Codebehind="UpdateDIC_PhonePrefix.aspx.cs" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="AjaxControl" %>
<%@ MasterType  VirtualPath="~/seferMasterPage.master" %>


<asp:Content ID="Content1" ContentPlaceHolderID="pageContent" runat="server">
<script type="text/javascript">
    function intOnly(i) {
        if (i.value.length > 0) {
            i.value = i.value.replace(/[^\d]+/g, '');
        }
    }
</script>
   
<asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Always" runat="server">
    <ContentTemplate>

     <table cellpadding="0" cellspacing="0">
        <tr>
            <td colspan="2">&nbsp;
            </td>
        </tr>
        <tr>
            <td style="padding-right:20px">
                <div id="divPhonePrefix" runat="server" class="ScrollBarDiv" style="height: 500px; overflow-y: scroll;">
                <asp:GridView ID="gvPhonePrefix" runat="server" SkinID="GridViewTree"
                     AutoGenerateColumns="False" OnRowDataBound="gvPhonePrefix_RowDataBound" AllowSorting="true" >
                    <Columns>
                        <asp:TemplateField ItemStyle-CssClass="DisplayNone" HeaderStyle-CssClass="DisplayNone">
                            <ItemTemplate>
                                <asp:Label ID="lblPrefixCode" runat="server" Text='<%# Eval("prefixCode") %>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField ItemStyle-Width="70px" HeaderText="קידומת">
                            <ItemTemplate>
                                <asp:Label ID="lblPrefixValue" runat="server" Text='<%# Eval("prefixValue") %>'></asp:Label>
                            </ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtPrefixValue" runat="server" onKeyUp="javascript:intOnly(this);" Text='<%# Eval("prefixValue") %>' Width="50px"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvUpdatePrefixValue" ControlToValidate="txtPrefixValue" runat="server" ValidationGroup="vgrUpdatePrefixValue" Text="*"></asp:RequiredFieldValidator>
                            </EditItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField ItemStyle-Width="90px" HeaderText="סוג מכשיר">
                            <ItemTemplate>
                                <asp:Label ID="lblPhoneType" runat="server" Text='<%# Eval("phoneTypeName") %>'></asp:Label>
                            </ItemTemplate>
                            <EditItemTemplate>
                                <asp:DropDownList ID="ddlPhoneType" DataTextField="PhoneTypeName" DataValueField="PhoneTypeCode" runat ="server" ></asp:DropDownList>
                            </EditItemTemplate>
                        </asp:TemplateField>
                        
                        <asp:TemplateField HeaderText="" ItemStyle-Width="110px">
                            <ItemTemplate>
                                <div style="width:100px">
                                <asp:ImageButton ID="imgUpdate" runat="server"
                                    OnClick="imgUpdate_Click" ImageUrl="~/Images/btn_edit.gif" ToolTip="עדכן קידומת" CausesValidation="false" />
                                <asp:ImageButton ID="imgDelete" ToolTip="מחק קידומת" runat="server" OnClick="imgDelete_Click"
                                    ImageUrl="~/Images/action_stop.gif"  />
                                <AjaxControl:ConfirmButtonExtender ConfirmText="האם למחוק את הקידומת הזה ?" ID="CBtnExtend_imgDelete"
                                    TargetControlID="imgDelete" runat="server">
                                </AjaxControl:ConfirmButtonExtender>
                                </div>
                            </ItemTemplate>
                            <EditItemTemplate>
                                <table cellpadding="0" cellspacing="0" width="100px">
                                    <tr>
                                        <td>
                                            <asp:ImageButton ID="imgCancel" runat="server" CausesValidation="false" CommandName="canel"
                                                OnClick="imgCancel_Click" ImageUrl="~/Images/btn_cancel.gif"  />
                                        </td>
                                        <td>
                                            <asp:ImageButton ID="imgSave" runat="server" CausesValidation="true" CommandName="save"
                                                OnClick="imgSave_Click" ImageUrl="~/Images/btn_approve.gif" ValidationGroup="vgrUpdatePrefixValue"  />
                                        </td>
                                    </tr>
                                </table>
                            </EditItemTemplate>
                            <ItemStyle Width="45px" />
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
                </div>
            </td>
            <td valign="top" style="padding-right:20px">
                 <table cellpadding="0" cellspacing="0">
                    <tr>
                        <td style="display:none" >
                             <asp:Label runat="server" ID="lblTxtPhonePrefix" Text="קוד" ></asp:Label>
                        </td>
                        <td style="display:none"  align="left">
                            <asp:TextBox ID="txtprefixCode" Width="60px"  runat="server" EnableViewState="False" ></asp:TextBox>
                        </td>
                        <td>
                            <asp:Label runat="server" ID="lblPrefixValue" Text="קידומת" ></asp:Label>
                        </td>
                        <td  align="left">
                            <asp:TextBox ID="txtPrefixValue" onKeyUp="javascript:intOnly(this);" Width="60px" runat="server" EnableViewState="False" ></asp:TextBox>
                            <asp:RequiredFieldValidator ValidationGroup="vgrAddPrefixValue" Text="*" ErrorMessage="נא להזין קידומת" ID="rfvPrefixValue" runat="server" ControlToValidate="txtPrefixValue"></asp:RequiredFieldValidator>
                        </td>
                        <td>
                            <asp:Label runat="server" ID="lblphoneType" Text="סוג מכשיר" ></asp:Label>
                        </td>
                        <td  align="left">
                            <asp:DropDownList ID="ddlPhoneTypeNew"  EnableViewState="true" DataTextField="PhoneTypeName" DataValueField="PhoneTypeCode" runat ="server" ></asp:DropDownList>
                        </td>
                        <td style="padding-right:15px">
                            <table cellpadding="0" cellspacing="0" style="margin: 0px 0px 2px 0px;">
                                <tr>
                                    <td class="buttonRightCorner">
                                    </td>
                                    <td class="buttonCenterBackground">
                                        <asp:Button ID="btnInsert" OnClick="btnInsert_Click" runat="server" Width="50px" Text="הוסף"
                                            CssClass="RegularUpdateButton" ValidationGroup="vgrAddPrefixValue" CausesValidation="true" />
                                    </td>
                                    <td class="buttonLeftCorner">
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="7" style="padding-right:20px">
                            <asp:Label ID="lblError" runat="server" ForeColor="red"></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="7">
                            <asp:ValidationSummary ID="vsAddPrefixValue" runat="server" ValidationGroup="vgrAddPrefixValue" />
                        </td>
                    </tr>
                 </table>
            </td>
        </tr>
     </table>
    </ContentTemplate>
</asp:UpdatePanel>
 
 
</asp:Content>
