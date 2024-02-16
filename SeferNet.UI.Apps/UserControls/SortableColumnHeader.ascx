<%@ Control Language="C#" AutoEventWireup="true" Inherits="SortableColumnHeader" Codebehind="SortableColumnHeader.ascx.cs" %>

<asp:LinkButton runat="server" OnClick="SortOrder_Click" CssClass="ColumnHeader">
<table cellpadding="0" cellspacing="0">
    <tr>
        <td style="vertical-align:middle;">
            <asp:LinkButton ID="lnkHeaderText" runat="server" CssClass="ColumnHeader" 
                EnableTheming="false" onclick="SortOrder_Click" CausesValidation="false"></asp:LinkButton>
        </td>
        <td style="vertical-align:middle;padding-right:4px;">
            <asp:ImageButton ID="imgSortOrder" runat="server" CausesValidation="false"  
                ImageUrl="~/Images/Applic/icon_sort.gif" onclick="SortOrder_Click" />            
        </td>
    </tr>
</table>
</asp:LinkButton>