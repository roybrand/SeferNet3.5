<%@ Page Title="עדכון פרטי רופאים ועובדים - שעות קבלה" Language="C#" MasterPageFile="~/seferMasterPageIE.master"
    AutoEventWireup="true" Inherits="Admin_UpdateEmployeeReception" Codebehind="UpdateEmployeeReception.aspx.cs" %>

<%@ MasterType VirtualPath="~/seferMasterPageIE.master" %>
<%@ Register Src="../UserControls/GridReceptionHoursUC.ascx" TagName="GridReceptionHoursUC"
    TagPrefix="uc1" %>
<asp:Content ID="Content1" ContentPlaceHolderID="pageContent" runat="Server">
    
    
    <div style="height: 100%;">
        <div style="height: 30px; width: 1040px; margin-right: 5px; margin-top: 10px; background-color: #298AE5;"
            class="LabelBoldWhite_18">
            <span class="buttonDecorator" style="float: left; margin-left: 10px"><span class="buttonContainer">
                <asp:Button ID="btnCancel" runat="server" CssClass="RegularUpdateButton" Text="ביטול"
                    OnClick="btnCancel_click" />
            </span></span><span class="buttonDecorator" style="float: left; margin-left: 10px"><span
                class="buttonContainer">
                <asp:Button ID="btnSave" runat="server" CssClass="RegularUpdateButton" Text="שמירה"
                    OnClick="btnSave_click" />
            </span></span>
            
                <asp:Label Style="line-height: 30px; margin-right: 10px; display: inline-block" EnableTheming="false"
                    runat="server">תואר:</asp:Label>
                <asp:Label ID="lblDegree" EnableTheming="false" runat="server" Style="margin-right: 50px;"></asp:Label>
                <asp:Label EnableTheming="false" runat="server">שם:</asp:Label>
                <asp:Label ID="lblName" runat="server" EnableTheming="false" Style="margin-right: 50px;"></asp:Label>
                <asp:Label EnableTheming="false" runat="server">סקטור:</asp:Label>
                <asp:Label EnableTheming="false" ID="lblSector" runat="server" Style="margin-right: 50px;"></asp:Label>
                <asp:Label EnableTheming="false" ID="lblSpeciality" runat="server" Style="margin-right: 50px;"></asp:Label>
            
        </div>
        <div style="padding-top:5px;padding-right:7px;width:1040px">
            <span class="LabelCaptionGreenBold_18 header4">שעות קבלה בכל היחידות</span>
            <uc1:GridReceptionHoursUC ID="gvReceptionHours" runat="server" />
            
            
        </div>
    </div>
</asp:Content>
