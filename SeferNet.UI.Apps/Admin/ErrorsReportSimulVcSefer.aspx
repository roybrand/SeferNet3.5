<%@ Reference Page="AdminBasePage.aspx" %>
<%@ Page Language="C#" AutoEventWireup="true" Title="דו''ח קליטה ושגויים" MasterPageFile="~/seferMasterPageIE.master" Inherits="ErrorsReportSimulVcSefer"  meta:resourcekey="PageResource1" Codebehind="ErrorsReportSimulVcSefer.aspx.cs" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>

<%@ Register Assembly="System.Web.Extensions, Version=1.0.61025.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
    Namespace="System.Web.UI" TagPrefix="asp" %>
<%@ MasterType  VirtualPath="~/seferMasterPageIE.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="pageContent" runat="server">
 

<script type="text/javascript">
    function OpenClinicDetailesPopUp(deptCode) {
        var url = "ClinicDetails.aspx?deptCode=" + deptCode;

        var dialogWidth = 420;
        var dialogHeight = 380;
        var title = "פרטים נוספים לרשומה השגויה";

        OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

        return false;
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
            <table cellpadding="0" cellspacing="0" style="background-color:#298AE5; height:25px;" width="975px">
                <tr>
                    <td style=" padding-right:15px">
                        <asp:Label ID="lblInterfaceDateCaption" EnableTheming="false" CssClass="LabelBoldWhite_13" runat="server" Text="תאריך ממשק:"></asp:Label>
                        &nbsp;
                        <asp:Label ID="lblInterfaceDate" EnableTheming="false" CssClass="LabelBoldWhite_13" runat="server" Text=""></asp:Label>
                        <asp:TextBox ID="txtDeptCode" Width="50px" runat="server" EnableTheming="false" CssClass="DisplayNone"></asp:TextBox>
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
                            <table cellpadding="0" cellspacing="0">
                                <tr>
                                    <td>
                                        <table cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td style="width:110px">
                                                    <asp:Label ID="lblInterfaceErrorCodes" runat="server" Text="סינון לפי קוד שגיאה"></asp:Label>
                                                </td>
                                                <td>
                                                    <asp:DropDownList ID="ddlInterfaceErrorCodes" runat="server" 
                                                        DataTextField="ErrorDesc" DataValueField="ErrorCode" 
                                                        AppendDataBoundItems="true" AutoPostBack="true" 
                                                        onselectedindexchanged="ddlInterfaceErrorCodes_SelectedIndexChanged">
                                                        <asp:ListItem Text="הכול" Value="-1"></asp:ListItem>
                                                    </asp:DropDownList>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr id="trErrorsListHeader" runat="server">
                                    <td style="padding:0px 0px 0px 0px; margin:0px 0px 0px 0px;">
                                        <table cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td style="width:35px">&nbsp;</td>
                                                <td style="width:65px">
                                                    <asp:Label ID="lblDeptCodeCaption" runat="server" Text="קוד מרפאה" EnableTheming="false" CssClass="LabelCaptionBlueBold_12" ></asp:Label>
                                                </td>
                                                <td style="width:100px">
                                                    <asp:Label ID="lblDistrictNameCaption" runat="server" Text="מחוז" EnableTheming="false" CssClass="LabelCaptionBlueBold_12" ></asp:Label>
                                                </td>
                                                <td style="width:285px">
                                                    <asp:Label ID="lblDeptNameCaption" runat="server" Text="שם מרפאה" EnableTheming="false" CssClass="LabelCaptionBlueBold_12" ></asp:Label>
                                                </td>
                                                <td style="width:70px">
                                                    <asp:Label ID="lblErrorCodeCaption" runat="server" Text="קוד שגיאה" EnableTheming="false" CssClass="LabelCaptionBlueBold_12" ></asp:Label>
                                                </td>
                                                <td style="width:275px">
                                                    <asp:Label ID="lblErrorDescCaption" runat="server" Text="תיאור שגיאה" EnableTheming="false" CssClass="LabelCaptionBlueBold_12" ></asp:Label>
                                                </td>
                                                <td style="width:90px">
                                                    <asp:Label ID="lblInterfaceDateCaption2" runat="server" Text="תאריך ממשק" EnableTheming="false" CssClass="LabelCaptionBlueBold_12" ></asp:Label>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr id="trErrorsList" runat="server">
                                    <td>
                                        <div style="width:950px; class="ScrollBarDiv">
                                            <table cellpadding="0" cellspacing="0" style="width:100%">
                                                <tr id="trNoErrors" runat="server" style="width:100%">
                                                    <td align="center" valign="middle" style="height:300px;">
                                                        <asp:Label ID="lblNoErrors" runat="server" CssClass="LabelCaptionGreenBold_20" EnableTheming="false" Text="לא נמצאו קודי שגיאה"></asp:Label>
                                                    </td>
                                                </tr>
                                            </table>
                                            <asp:GridView ID="gvErrorsList" runat="server" AutoGenerateColumns="False"
                                                SkinID="GridViewForSearchResults" HeaderStyle-CssClass="DisplayNone" 
                                                onrowdatabound="gvErrorsList_RowDataBound">
                                                <Columns>
                                                    <asp:TemplateField HeaderText="" ItemStyle-Width="35px" ItemStyle-HorizontalAlign="Center">
                                                        <ItemTemplate>
                                                            <asp:Image ID="imgDetailes" runat="server" ImageUrl="~/Images/Applic/bookc.gif" ToolTip="הקש להצג פרטים נוספים לרשומה השגויה" Style="cursor: hand" />
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField HeaderText="קוד מרפאה" ItemStyle-Width="60px">
                                                        <ItemTemplate>
                                                            <asp:LinkButton runat="server" EnableTheming="false" CssClass="LooksLikeHRef" ID="deptCodeLink" Text='<%#Eval("deptCode")%>' OnClick="deptCodeLink_Click"></asp:LinkButton>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField HeaderText="מחוז" ItemStyle-Width="100px">
                                                        <ItemTemplate>
                                                            <asp:Label ID="lblDistrictName" runat="server" Text='<%#Eval("districtName")%>'></asp:Label>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField HeaderText="שם מרפאה" ItemStyle-Width="300px">
                                                        <ItemTemplate>
                                                            <asp:Label ID="lblDeptName" runat="server" Text='<%#Eval("deptName")%>'></asp:Label>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField HeaderText="קוד שגיאה" ItemStyle-Width="70px" ItemStyle-HorizontalAlign="Center">
                                                        <ItemTemplate>
                                                            <asp:Label ID="lblErrorCode" runat="server" Text='<%#Eval("ErrorCode")%>'></asp:Label>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField HeaderText="תיאור שגיאה" ItemStyle-Width="280px">
                                                        <ItemTemplate>
                                                            <asp:Label ID="lblErrorDesc" runat="server" Text='<%#Eval("ErrorDesc")%>'></asp:Label>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField HeaderText="תאריך ממשק" ItemStyle-Width="90px">
                                                        <ItemTemplate>
                                                            <asp:Label ID="lblInterfaceDate" runat="server" Text='<%#Eval("InterfaceDate","{0:d}")%>'></asp:Label>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    
                                                </Columns>
                                            </asp:GridView>
                                        </div>
                                    </td>
                                </tr>
                            </table>
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
</table>
</asp:Content>