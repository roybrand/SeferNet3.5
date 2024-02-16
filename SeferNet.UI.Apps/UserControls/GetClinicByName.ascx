<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="GetClinicByName.ascx.cs" Inherits="SeferNet.UI.Apps.UserControls.GetClinicByName" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>

<div>
    <div style="float:right">
        <asp:TextBox ID="txtDeptName" 
            Width="150px" 
            runat="server" 
            MaxLength="50" 
            EnableTheming="true"
            Height="20px"></asp:TextBox>
        <ajaxtoolkit:AutoCompleteExtender runat="server" ID="AutoCompleteClinicName" TargetControlID="txtDeptName"
            BehaviorID="acClinicName" ServicePath="~/AjaxWebServices/AutoComplete.asmx" 
            ServiceMethod="GetClinicByName"
            MinimumPrefixLength="1" CompletionInterval="500" CompletionListItemCssClass="CompletionListItemStyle"
            UseContextKey="false" CompletionListHighlightedItemCssClass="CompletionListHighlightedItemStyle"
            EnableCaching="false" CompletionSetCount="12" DelimiterCharacters="" Enabled="True"
            CompletionListCssClass="CopmletionListStyleWidth" 
        />
    </div>
    <div style="float:right">
        <asp:ImageButton ID="btnClinicPopUp" runat="server" ImageUrl="../Images/Applic/icon_magnify.gif" ></asp:ImageButton>
    </div>
        <div style="float:right">
        <asp:TextBox ID="txtDeptCode" 
            Width="50px" 
            runat="server" 
            EnableTheming="false"
            Height="20px"></asp:TextBox>
        </div>
</div>