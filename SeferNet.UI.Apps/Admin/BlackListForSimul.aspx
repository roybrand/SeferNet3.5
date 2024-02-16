<%@ Reference Page="AdminBasePage.aspx" %>
<%@ Page Language="C#" AutoEventWireup="true" Title="יחידות לטיפול פרטני בממשק הקליטה מסימול" MasterPageFile="~/seferMasterPage.master" Inherits="BlackListForSimul"  meta:resourcekey="PageResource1" Codebehind="BlackListForSimul.aspx.cs" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>

<%@ Register Assembly="System.Web.Extensions, Version=1.0.61025.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
    Namespace="System.Web.UI" TagPrefix="asp" %>
<%@ MasterType  VirtualPath="~/seferMasterPage.master" %>
<%@ Register src="../UserControls/GridDeptReceptionHoursUC.ascx" tagname="GridDeptReceptionHoursUC" tagprefix="uc3" %>
<asp:Content ID="Content1" ContentPlaceHolderID="pageContent" runat="server">

<script type="text/javascript">
    function OkMessage() {
        alert("שמירה בוצעה בהצלחה");
    }
</script>

<table cellpadding="0" cellspacing="0">
    <tr id="trError" runat="server">
        <td>
            <asp:Label id="lblGeneralError" runat="server" SkinID="lblError"></asp:Label> 
        </td>
    </tr>
   
</table>
<table cellspacing="0" cellpadding="0">
    <tr>
        <td style="padding-right:10px"><!-- Upper Blue Bar -->
            <table cellpadding="0" cellspacing="0" style="background-color:#298AE5; height:25px;" width="980px">
                <tr>
                    <td style=" padding-right:15px">
                        <asp:Label ID="lblInterfaceDateCaption" EnableTheming="false" CssClass="LabelBoldWhite_13" runat="server" Text=""></asp:Label>
                        &nbsp;
                        <asp:Label ID="lblInterfaceDate" EnableTheming="false" CssClass="LabelBoldWhite_13" runat="server" Text=""></asp:Label>
                        <asp:TextBox ID="txtDeptCode" Width="50px" runat="server" CssClass="DisplayNone" EnableTheming="false" ></asp:TextBox>
                    </td>
               </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td style="padding-right:10px"><!-- Phones and QueueOrderMethods --> 
            <table cellpadding="0" cellspacing="0" border="0" style="background-color:#F7F7F7">
                <tr>
                    <td style="height:10px; background-image:url('../Images/Applic/RTcornerGrey10.gif'); background-repeat:no-repeat; background-position: top right">
                    </td>
                    <td style="background-image:url('../Images/Applic/borderGreyH.jpg'); background-repeat:repeat-x; background-position: top">
                    </td>
                    <td style="background-image:url('../Images/Applic/LTcornerGrey10.gif'); background-repeat:no-repeat; background-position: top left">
                    </td>
                </tr>
                <tr>
                    <td style="border-right:solid 2px #909090;">
                        <div style="width:6px;"></div>
                    </td>
                    <td>
                        <div style="width:958px; height:90px">
                            <table>
                                <tr>
                                    <td>
                                        <asp:ValidationSummary ID="vldSummary" runat="server" ValidationGroup="grBlackList" />
                                    </td>
                                </tr>
                            </table>
                            <table>
                                <tr>
                                    <td style="height:80px" valign="middle">
                                        <table cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td style="width:100px">
                                                    <asp:Label ID="lblCodeSimul" runat="server" Text="קוד יחידה בסימול"></asp:Label>
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtCodeSimul" Width="100px" runat="server"></asp:TextBox>
                                                </td>
                                                <td style="width:20px">
                                                    <asp:RequiredFieldValidator ValidationGroup="grBlackList" ID="vldCodeSimulRequired" runat="server" ControlToValidate="txtCodeSimul" Text="*" ErrorMessage="חובה להזין קוד יחידה בסימול"></asp:RequiredFieldValidator>
                                                    <asp:CompareValidator ValidationGroup="grBlackList" ID="vldCodeSimulInteger" runat="server" ControlToValidate="txtCodeSimul" Operator="DataTypeCheck" Type="Integer" Text="*" ErrorMessage="אפשר להזין רק מיספרים"></asp:CompareValidator>
                                                </td>
                                                <td style="padding-top:2px">
                                                    <asp:DropDownList ID="ddlIsForSeferSherut" runat="server">
                                                        <asp:ListItem Text="לכלול בממשק" Value="1"></asp:ListItem>
                                                        <asp:ListItem Text="לא לכלול בממשק" Value="0"></asp:ListItem>
                                                    </asp:DropDownList>
                                                </td>
                                                <td style="padding-right:15px">
                                                    <table cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td class="buttonRightCorner"></td>
                                                            <td class="buttonCenterBackground">
                                                                <asp:Button ValidationGroup="grBlackList" ID="btnUpdateBlackList" Width="100px" runat="server" 
                                                                    CssClass="RegularUpdateButton" Text="עדכון / הוספה" 
                                                                    onclick="btnUpdateBlackList_Click" />
                                                            </td>
                                                            <td class="buttonLeftCorner"></td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </td>
                    <td style="border-left:solid 2px #909090;">
                        <div style="width:6px;"></div>
                    </td>
                </tr>
                <tr style="height:10px">
                    <td style="background-image:url('../Images/Applic/RBcornerGrey10.gif'); background-repeat:no-repeat; background-position: bottom right">
                    </td>
                    <td style="background-image:url('../Images/Applic/borderGreyH.jpg'); background-repeat:repeat-x; background-position: bottom">
                    </td>
                    <td style="background-image:url('../Images/Applic/LBcornerGrey10.gif'); background-repeat:no-repeat; background-position: bottom left">
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td style="padding-right:10px"><!-- Lower Blue Bar -->
            <table cellpadding="0" cellspacing="0" style="background-color:#298AE5; height:25px;" width="980px">
                <tr>
                    <td align="left" style="padding-left:10px">
                    </td>
               </tr>
            </table>
        </td>
    </tr>    
</table>
</asp:Content>