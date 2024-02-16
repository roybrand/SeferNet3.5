<%@ Page Language="C#" AutoEventWireup="true" Inherits="DeptEventPopUp"
    Theme="SeferGeneral"  Codebehind="DeptEventPopUp.aspx.cs" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>פעילות של מרפאה</title>
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="-1" />
    <link rel="STYLESHEET" href="~/CSS/General/general.css" type="text/css" />
    <script type="text/javascript" src="../scripts/LoadJqueryIfNeeded.js"></script>
<style type="text/css">
.LooksLikeHRef
{	
	font-family:arial; 
	font-size:13px;
	color:blue;
	text-decoration:underline;
	cursor:pointer;
}
</style>
</head>
<body>
    <form id="form1" runat="server" dir="rtl" defaultbutton="btnClose">
    <table cellpadding="0" cellspacing="0" border="0" width="100%">
        <tr>
            <td>
                <table dir="rtl" id="tblEventDetails" class="SimpleText" cellpadding="0" cellspacing="0"
                    style="color: #505050; background-color: white;" width="100%;">
                    <tr>
                        <td style="border: solid 1px #B9DBFC">
                            <div id="cff" style="background-color: #2889E4; padding: 5px">
                                <asp:Label ID="lblDeptName_EventDetails" EnableTheming="false" CssClass="LabelBoldWhite"
                                    runat="server" Text=""></asp:Label>
                                &nbsp;
                                <asp:Label ID="lblDeptAddress_EventDetails" EnableTheming="false" CssClass="LabelBoldWhite"
                                    runat="server" Text=""></asp:Label>
                                <asp:Label ID="lblDeptPhones_EventDetails" EnableTheming="false" CssClass="LabelBoldWhite"
                                    runat="server" Text=""></asp:Label>
                            </div>
                            <div id="divTitles" style="border-bottom: 1px solid #B9DBFC; padding-right: 5px;
                                padding-bottom: 5px; padding-top: 3px;">
                                <asp:Label ID="lblEventName_EventDetails" runat="server" CssClass="LabelCaptionGreenBold_14"
                                    EnableTheming="false" Style="margin-right: 5px"></asp:Label>
                                <br />
                                <asp:Label ID="lblEventDescription_EventDetails" runat="server"></asp:Label>
                            </div>
                            <table cellpadding="0" cellspacing="0" width="100%">
                                <tr>
                                    <td style="padding-top: 5px; padding-left: 10px" valign="top">
                                        <table cellpadding="0" cellspacing="0" width="260px">
                                            <tr>
                                                <td style="background-color: #F0F0F0; width: 100%; padding-right: 5px;">
                                                    <asp:Label ID="lblRegistrationStatus_EventDetailsCaption" runat="server" CssClass="LabelCaptionBlueBold_12"
                                                        EnableTheming="false" Text="הרשמה"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="padding-right: 5px;">
                                                    <asp:Label ID="lblRegistrationStatus_EventDetails" runat="server"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="background-color: #F0F0F0; width: 100%; padding-right: 5px;">
                                                    <asp:Label ID="lblPayOrderDescription_EventDetailsCaption" runat="server" CssClass="LabelCaptionBlueBold_12"
                                                        EnableTheming="false" Text="עלות"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="padding-right: 5px;">
                                                    <table cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td valign="top">
                                                                <asp:Label ID="lblPayOrderDescription_EventDetails" runat="server"></asp:Label>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <table id="tblPrices" runat="server" cellpadding="0" cellspacing="0" border="0">
                                                                    <tr>
                                                                        <td>
                                                                            <asp:Panel ID="pnlMemberPrice" runat="server">
                                                                                <asp:Label ID="lblMemberPrice_EventDetailsCaption" runat="server" CssClass="LabelCaptionBlueBold_12"
                                                                                    EnableTheming="false" Text="מחיר ללקוחות כללית:"></asp:Label>
                                                                                <asp:Label ID="lblMemberPrice_EventDetails" runat="server" Width="25px"></asp:Label>
                                                                                <asp:Label ID="lblNIS_1" runat="server" CssClass="LabelCaptionBlueBold_12" EnableTheming="false"
                                                                                    Text="ש``ח"></asp:Label>
                                                                            </asp:Panel>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td>
                                                                            <asp:Panel ID="pnlFullMember" runat="server">
                                                                                <asp:Label ID="lblFullMemberPrice_EventDetailsCaption" runat="server" CssClass="LabelCaptionBlueBold_12"
                                                                                    EnableTheming="false" Text="מחיר ללקוחות כללית מושלם:"></asp:Label>
                                                                                <asp:Label ID="lblFullMemberPrice_EventDetails" runat="server" Width="25px"></asp:Label>
                                                                                <asp:Label ID="lblNIS_2" runat="server" CssClass="LabelCaptionBlueBold_12" EnableTheming="false"
                                                                                    Text="ש``ח"></asp:Label>
                                                                            </asp:Panel>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td>
                                                                            <asp:Panel ID="pnlCommonMember" runat="server">
                                                                                <asp:Label ID="lblCommonPrice_EventDetailsCaption" runat="server" CssClass="LabelCaptionBlueBold_12"
                                                                                    EnableTheming="false" Text="מחיר ללקוחות קופות אחרות:"></asp:Label>
                                                                                <asp:Label ID="lblCommonPrice_EventDetails" runat="server" Width="25px"></asp:Label>
                                                                                <asp:Label ID="lblNIS_3" runat="server" CssClass="LabelCaptionBlueBold_12" EnableTheming="false"
                                                                                    Text="ש``ח"></asp:Label>
                                                                            </asp:Panel>
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="background-color: #F0F0F0; width: 100%; padding-right: 5px;">
                                                    <asp:Label ID="lblTargetPopulation_EventDetailsCaption" runat="server" CssClass="LabelCaptionBlueBold_12"
                                                        EnableTheming="false" Text="אוכלוסיית יעד"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="padding-right: 5px;">
                                                    <asp:Label ID="lblTargetPopulation_EventDetails" runat="server"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="background-color: #F0F0F0; width: 100%; padding-right: 5px;">
                                                    <asp:Label ID="lblEventPhones_EventDetailsCaption" runat="server" CssClass="LabelCaptionBlueBold_12"
                                                        EnableTheming="false" Text="טלפון לבירורים"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="padding-right: 5px;" align="right" dir="ltr">
                                                    <asp:Label ID="lblEventPhones_EventDetails" runat="server" Text=""></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="background-color: #F0F0F0; padding-right: 5px;">
                                                    <asp:Label ID="lblEventRemark_EventDetailsCaption" runat="server" CssClass="LabelCaptionBlueBold_12"
                                                        EnableTheming="false" Text="הערה"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="padding-right: 5px;">
                                                    <asp:Label ID="lblEventRemark_EventDetails" runat="server"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                               <td style="background-color: #F0F0F0;padding-right:5px">
                                                    <asp:Label ID="lblEventFiles" runat="server" Text="קבצים מצורפים" EnableTheming="false" CssClass="LabelCaptionBlueBold_12"></asp:Label>
                                               </td>
                                            </tr>   
                                            <tr>    
                                                <td style="padding-right:10px">
                                                    <asp:GridView ID="gvAttachedFiles" runat="server" AutoGenerateColumns="false" ShowHeader="false"
                                                            Width="100%" OnRowDataBound="gvAttachedFiles_OnRowDataBound">
                                                        <Columns>
                                                            <asp:TemplateField>
                                                                <ItemTemplate>
                                                                    <asp:HyperLink ID="hlOpenFile" CssClass="LooksLikeHRef" runat="server">'<%# Eval("fileName") %>'</asp:HyperLink>
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                        </Columns>
                                                    </asp:GridView>
                                                </td>
                                            </tr>                                         
                                        </table>
                                    </td>
                                    <td style="padding-top: 5px" valign="top">
                                        <table cellpadding="0" cellspacing="0" style="border: solid 1px #B9DBFC">
                                            <tr style="background-color: #26A53F">
                                                <td>
                                                    <table cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td align="center" style="width: 40px; border-left: 1px solid #B9DBFC">
                                                                <asp:Label ID="lblOrderNumberCaption" runat="server" CssClass="LabelBoldWhite" EnableTheming="false"
                                                                    Text="מפגש מס'"></asp:Label>
                                                            </td>
                                                            <td align="center" style="border-left: solid 1px #B9DBFC; width: 41px">
                                                                <asp:Label ID="lblDayCaption" runat="server" CssClass="LabelBoldWhite" EnableTheming="false"
                                                                    Text="יום"></asp:Label>
                                                            </td>
                                                            <td align="center" style="border-left: solid 1px #B9DBFC; width: 91px">
                                                                <asp:Label ID="lblDateCaption" runat="server" CssClass="LabelBoldWhite" EnableTheming="false"
                                                                    Text="תאריך"></asp:Label>
                                                            </td>
                                                            <td align="center" style="border-left: solid 1px #B9DBFC; width: 51px">
                                                                <asp:Label ID="lblOpeningHourCaption" runat="server" CssClass="LabelBoldWhite" EnableTheming="false"
                                                                    Text="משעה"></asp:Label>
                                                            </td>
                                                            <td align="center" style="border-left: solid 1px #B9DBFC; width: 51px">
                                                                <asp:Label ID="lblClosingHourCaption" runat="server" CssClass="LabelBoldWhite" EnableTheming="false"
                                                                    Text="עד שעה"></asp:Label>
                                                            </td>
                                                            <td align="center" style="width: 50px">
                                                                <asp:Label ID="lblDurationCaption" runat="server" CssClass="LabelBoldWhite" EnableTheming="false"
                                                                    Text="משך"></asp:Label>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <div class="ScrollBarDiv" style="height: 400px; overflow-y: auto">
                                                        <asp:GridView ID="gvEventParticulars" runat="server" SkinID="GridViewForSearchResults"
                                                            AutoGenerateColumns="false" HeaderStyle-CssClass="DisplayNone" RowStyle-BorderColor="#B9DBFC"
                                                            RowStyle-BorderWidth="1px" RowStyle-BorderStyle="solid">
                                                            <Columns>
                                                                <asp:TemplateField ItemStyle-Width="40px" ItemStyle-HorizontalAlign="Center">
                                                                    <ItemTemplate>
                                                                        <div style="border-left: solid 1px #B9DBFC; border-top: solid 1px #B9DBFC;">
                                                                            <asp:Label ID="lblOrderNumber" runat="server" Text='<%#Eval("OrderNumber") %>'></asp:Label>
                                                                        </div>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField ItemStyle-Width="40px" ItemStyle-HorizontalAlign="Center">
                                                                    <ItemTemplate>
                                                                        <div style="border-left: solid 1px #B9DBFC; border-top: solid 1px #B9DBFC;">
                                                                            <asp:Label ID="lblDay" runat="server" Text='<%#Eval("Day") %>'></asp:Label>
                                                                        </div>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField ItemStyle-Width="90px" ItemStyle-HorizontalAlign="Center">
                                                                    <ItemTemplate>
                                                                        <div style="border-left: solid 1px #B9DBFC; border-top: solid 1px #B9DBFC;">
                                                                            <asp:Label ID="lblDate" runat="server" Text='<%#Eval("Date","{0:d}") %>'></asp:Label>
                                                                        </div>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                                                    <ItemTemplate>
                                                                        <div style="border-left: solid 1px #B9DBFC; border-top: solid 1px #B9DBFC;">
                                                                            <asp:Label ID="lblOpeningHour" runat="server" Text='<%#Eval("OpeningHour") %>'></asp:Label>
                                                                        </div>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                                                    <ItemTemplate>
                                                                        <div style="border-left: solid 1px #B9DBFC; border-top: solid 1px #B9DBFC;">
                                                                            <asp:Label ID="lblClosingHour" runat="server" Text='<%#Eval("ClosingHour") %>'></asp:Label>
                                                                        </div>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                                                    <ItemTemplate>
                                                                        <div style="border-top: solid 1px #B9DBFC;">
                                                                            <asp:Label ID="lblDuration" runat="server" Text='<%#Eval("Duration") %>'></asp:Label>
                                                                        </div>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                            </Columns>
                                                        </asp:GridView>
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td align="left" style="padding: 10px">
                            <table cellpadding="0" cellspacing="0" dir="rtl">
                                <tr>
                                    <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                        background-position: bottom left;">
                                        &nbsp;
                                    </td>
                                    <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                        background-repeat: repeat-x; background-position: bottom;">
                                        <asp:Button ID="btnClose" runat="server" Text="סגירה" CssClass="RegularUpdateButton" TabIndex="1"
                                            OnClientClick="JQueryDialogClose();"></asp:Button>
                                    </td>
                                    <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                        background-repeat: no-repeat;">
                                        &nbsp;
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    </form>
    <script type="text/javascript">
        function JQueryDialogClose() {
            window.parent.$("#dialog-modal-select").dialog('close');
            return false;
        }
    </script>
</body>
</html>
