<%@ Page Title="הערות למשתמשים בסל השירותים" Language="C#" MasterPageFile="~/SeferMasterPage.master"
    AutoEventWireup="true" EnableEventValidation="false"
    Inherits="Admin_UpdateAdminComments" Codebehind="UpdateSalServicesAdminComments.aspx.cs" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<asp:Content ID="Content1" ContentPlaceHolderID="phHead" runat="Server">
    <link rel="stylesheet" href="../css/General/thickbox.css" type="text/css" media="screen" />
    <script type="text/javascript">

        function ClearAddSection()
        {
            document.getElementById('<% = hfAdminComment_Title.ClientID %>').value = '';
            document.getElementById('<% = hfAdminComment_Comment.ClientID %>').value = '';
            document.getElementById('<% = hfAdminComment_StartDate.ClientID %>').value = '';
            document.getElementById('<% = hfAdminComment_ExpiredDate.ClientID %>').value = '';
            document.getElementById('<% = hfAdminComment_Active.ClientID %>').value = '';

            document.getElementById('<% = tbAdminComment_Title.ClientID %>').value = '';
            document.getElementById('<% = tbAdminComment_Comment.ClientID %>').value = '';
            document.getElementById('<% = tbAdminComment_StartDate.ClientID %>').value = '';
            document.getElementById('<% = tbAdminComment_ExpiredDate.ClientID %>').value = '';
            document.getElementById('<% = cbAdminComment_Active.ClientID %>').checked = true;
        }

        function ClearSearchFeilds()
        {
            
        }

        function AddNewAdminComment()
        {

            document.getElementById('UpdateInsertButton').value = 'הוספת ההערה';

            document.getElementById('<% = hfAdminComment_ID.ClientID %>').value = '';
            document.getElementById('<% = hfAdminComment_Title.ClientID %>').value = '';
            document.getElementById('<% = hfAdminComment_Comment.ClientID %>').value = '';
            document.getElementById('<% = hfAdminComment_StartDate.ClientID %>').value = '';
            document.getElementById('<% = hfAdminComment_ExpiredDate.ClientID %>').value = '';
            document.getElementById('<% = hfAdminComment_Active.ClientID %>').value = '';

            document.getElementById('<% = tbAdminComment_Title.ClientID %>').value = '';
            document.getElementById('<% = tbAdminComment_Comment.ClientID %>').value = '';
            document.getElementById('<% = tbAdminComment_StartDate.ClientID %>').value = '';
            document.getElementById('<% = tbAdminComment_ExpiredDate.ClientID %>').value = '';
            document.getElementById('<% = cbAdminComment_Active.ClientID %>').checked = true;

            var tWidth = 310; // 335;
            var tHeight = 260; //165;

            var tmpHref = "#TB_inline?inlineId=divAddNewAdminComment&modal=true&height=" + tHeight + "&width=" + tWidth;

            $("#aTBOpenPopup_inline").attr("href", tmpHref);
            $("#aTBOpenPopup_inline").click();
        }

        function EditAdminComment(editControlId) 
        {
            document.getElementById('UpdateInsertButton').value = 'עדכון ההערה';

            var id = document.getElementById(editControlId.id.replace('ibEdit', 'hfAdminComment_ID')).value;
            var title = document.getElementById(editControlId.id.replace('ibEdit', 'hfAdminComment_Title')).value;
            var comment = document.getElementById(editControlId.id.replace('ibEdit', 'hfAdminComment_Comment')).value;
            var startDate = document.getElementById(editControlId.id.replace('ibEdit', 'hfAdminComment_StartDate')).value;
            var expiredDate = document.getElementById(editControlId.id.replace('ibEdit', 'hfAdminComment_ExpiredDate')).value;
            var active = document.getElementById(editControlId.id.replace('ibEdit', 'hfAdminComment_Active')).value;

            // Set the values from the datagrid to the popup

            document.getElementById('<% = hfAdminComment_ID.ClientID %>').value = id;
            document.getElementById('<% = tbAdminComment_Title.ClientID %>').value = title;
            document.getElementById('<% = tbAdminComment_Comment.ClientID %>').value = comment;
            document.getElementById('<% = tbAdminComment_StartDate.ClientID %>').value = startDate;
            document.getElementById('<% = tbAdminComment_ExpiredDate.ClientID %>').value = expiredDate;

            if (active == 1)
                document.getElementById('<% = cbAdminComment_Active.ClientID %>').checked = true;
            else
                document.getElementById('<% = cbAdminComment_Active.ClientID %>').checked = false;

            var tWidth = 310;
            var tHeight = 260;

            var tmpHref = "#TB_inline?inlineId=divAddNewAdminComment&modal=true&height=" + tHeight + "&width=" + tWidth;

            $("#aTBOpenPopup_inline").attr("href", tmpHref);
            $("#aTBOpenPopup_inline").click();
        }

        function AddUpdateAdminCommentSubmit()
        {
            var title = document.getElementById('<% = tbAdminComment_Title.ClientID %>').value;
            var comment = document.getElementById('<% = tbAdminComment_Comment.ClientID %>').value;
            var startDate = document.getElementById('<% = tbAdminComment_StartDate.ClientID %>').value;
            var expiredDate = document.getElementById('<% = tbAdminComment_ExpiredDate.ClientID %>').value;
            var active = document.getElementById('<% = cbAdminComment_Active.ClientID %>').checked;

            document.getElementById('<% = hfAdminComment_Title.ClientID %>').value = title;
            document.getElementById('<% = hfAdminComment_Comment.ClientID %>').value = comment;
            document.getElementById('<% = hfAdminComment_StartDate.ClientID %>').value = startDate;
            document.getElementById('<% = hfAdminComment_ExpiredDate.ClientID %>').value = expiredDate;
            document.getElementById('<% = hfAdminComment_Active.ClientID %>').value = active;

            document.getElementById('<% = btnAddAdminComment.ClientID %>').click();
        }
        
    </script>
    <style type="text/css">
        .mrgTop
        {
            margin-top: 2px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="postBackContent" runat="Server" EnableViewState="true">
    <asp:UpdatePanel runat="server" ID="upUpdateContent">
        <Triggers>
            <asp:PostBackTrigger ControlID="btnAddAdminComment" />
            <asp:PostBackTrigger ControlID="btnSearch" />
        </Triggers>
        <ContentTemplate>
            <div>
                <div style="margin-top: 5px; margin-right: 10px;">
                    <table cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7">
                        <tr>
                            <td style="padding: 0; height: 10px; background-image: url('../Images/Applic/RTcornerGrey10.gif');
                                background-repeat: no-repeat; background-position: top right">
                            </td>
                            <td style="padding: 0; background-image: url('../Images/Applic/borderGreyH.jpg');
                                background-repeat: repeat-x; background-position: top">
                            </td>
                            <td style="padding: 0; background-image: url('../Images/Applic/LTcornerGrey10.gif');
                                background-repeat: no-repeat; background-position: top left">
                            </td>
                        </tr>
                        <tr>
                            <td style="border-right: solid 2px #909090;">
                                &nbsp;
                            </td>
                            <td align="right">
                                <div style="width: 960px">
                                    <table cellpadding="0" cellspacing="0" width="100%">
                                        <tr>
                                            <td><asp:Label ID="lblSearchPanel_Title" runat="server" Text="כותרת"></asp:Label></td>
                                            <td><asp:TextBox runat="server" ID="tbSearchPanel_Title" Width="100px"></asp:TextBox></td>

                                            <td><asp:Label ID="lblSearchPanel_Comment" runat="server" Text="הערה"></asp:Label></td>
                                            <td><asp:TextBox runat="server" ID="tbSearchPanel_Comment" Width="100px"></asp:TextBox></td>

                                            <td><asp:Label ID="lblSearchPanel_StartDate" runat="server">ת. התחלה:</asp:Label></td>
                                            <td>
                                                <asp:TextBox ID="tbSearchPanel_StartDate" runat="server" Width="80px"></asp:TextBox>
                                                <asp:ImageButton ID="btnSearchPanelRunCalendar_StartDate" runat="server" ImageUrl="~/Images/Applic/calendarIcon.png" style="position:relative;top:4px" />
                                                <ajaxToolkit:MaskedEditValidator ID="mevStartDateValidator" runat="server" ControlExtender="SearchPanelStartDateExtender"
                                                    ControlToValidate="tbSearchPanel_StartDate" Display="Dynamic" ErrorMessage="התאריך אינו תקין"
                                                    InvalidValueBlurredMessage="*" InvalidValueMessage="התאריך אינו תקין" />
                                                <ajaxToolkit:CalendarExtender ID="calSearchPanelStartDateExtender" runat="server" Enabled="True"
                                                    FirstDayOfWeek="Sunday" Format="dd/MM/yyyy" PopupButtonID="btnSearchPanelRunCalendar_StartDate" 
                                                    PopupPosition="BottomRight" TargetControlID="tbSearchPanel_StartDate">
                                                </ajaxToolkit:CalendarExtender>
                                                <ajaxToolkit:MaskedEditExtender ID="SearchPanelStartDateExtender" runat="server" ClearMaskOnLostFocus="true"
                                                    Enabled="True" ErrorTooltipEnabled="True" Mask="99/99/9999" MaskType="Date" TargetControlID="tbSearchPanel_StartDate">
                                                </ajaxToolkit:MaskedEditExtender>
                                            </td>

                                            <td><asp:Label ID="lblSearchPanel_ExpiredDate" runat="server">ת. סיום:</asp:Label></td>
                                            <td>
                                                <asp:TextBox ID="tbSearchPanel_ExpiredDate" runat="server" Width="80px"></asp:TextBox>
                                                <asp:ImageButton ID="btnSearchPanelRunCalendar_ExpiredDate" runat="server" ImageUrl="~/Images/Applic/calendarIcon.png" style="position:relative;top:4px" />
                                                <ajaxToolkit:MaskedEditValidator ID="mevExpiredDateValidator" runat="server" ControlExtender="SearchPanelExpiredDateExtender"
                                                    ControlToValidate="tbSearchPanel_ExpiredDate" Display="Dynamic" ErrorMessage="התאריך אינו תקין"
                                                    InvalidValueBlurredMessage="*" InvalidValueMessage="התאריך אינו תקין" />
                                                <ajaxToolkit:CalendarExtender ID="calSearchPanelExpiredDateExtender" runat="server" Enabled="True"
                                                    FirstDayOfWeek="Sunday" Format="dd/MM/yyyy" PopupButtonID="btnSearchPanelRunCalendar_ExpiredDate" 
                                                    PopupPosition="BottomRight" TargetControlID="tbSearchPanel_ExpiredDate">
                                                </ajaxToolkit:CalendarExtender>
                                                <ajaxToolkit:MaskedEditExtender ID="SearchPanelExpiredDateExtender" runat="server" ClearMaskOnLostFocus="true"
                                                    Enabled="True" ErrorTooltipEnabled="True" Mask="99/99/9999" MaskType="Date" TargetControlID="tbSearchPanel_ExpiredDate">
                                                </ajaxToolkit:MaskedEditExtender>
                                            </td>
                                            <td>
                                                <asp:Label ID="lblSearchPanel" runat="server" Text="פעיל"></asp:Label>
                                            </td>
                                            <td>
                                                <asp:DropDownList ID="ddlSearchPanel_Active" runat="server" Width="60px" DataValueField="Code"
                                                    DataTextField="Description">
                                                    <asp:ListItem Text="הכל" Value=""></asp:ListItem>
                                                    <asp:ListItem Text="כן" Value="1"></asp:ListItem>
                                                    <asp:ListItem Text="לא" Value="0"></asp:ListItem>
                                                </asp:DropDownList>
                                            </td>
                                            <td style="width: 10px;">
                                                &nbsp;
                                            </td>
                                            <td>
                                                <table cellpadding="0" cellspacing="0">
                                                    <tr>
                                                        <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                            background-position: bottom left;">
                                                            &nbsp;
                                                        </td>
                                                        <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                            background-repeat: repeat-x; background-position: bottom;">
                                                            <asp:Button ID="btnSearch" runat="server" Text="סינון" CssClass="RegularUpdateButton"
                                                                ValidationGroup="vgrSearch" OnClick="btnSearch_Click"></asp:Button>
                                                        </td>
                                                        <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                            background-repeat: no-repeat;">
                                                            &nbsp;
                                                        </td>
                                                        <%--<td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                            background-position: bottom left;">
                                                            &nbsp;
                                                        </td>
                                                        <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                            background-repeat: repeat-x; background-position: bottom;">
                                                            <input type="button" value="ניקוי" class="RegularUpdateButton" onclick="clearSearchFeilds();" />
                                                        </td>
                                                        <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                            background-repeat: no-repeat;">
                                                            &nbsp;
                                                        </td>--%>
                                                        <td style="width: 40px;">
                                                        </td>
                                                        <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                            background-position: bottom left;">
                                                            &nbsp;
                                                        </td>
                                                        <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                            background-repeat: repeat-x; background-position: bottom;">
                                                            <input type="button" style="width: 66px;" value="הוספה" class="RegularUpdateButton"
                                                                onclick="AddNewAdminComment();" />
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
                                </div>
                            </td>
                            <td style="border-left: solid 2px #909090;">
                                <div style="width: 6px;">
                                </div>
                            </td>
                        </tr>
                        <tr style="height: 10px">
                            <td style="background-image: url('../Images/Applic/RBcornerGrey10.gif'); background-repeat: no-repeat;
                                background-position: bottom right">
                            </td>
                            <td style="background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x;
                                background-position: bottom">
                            </td>
                            <td style="background-image: url('../Images/Applic/LBcornerGrey10.gif'); background-repeat: no-repeat;
                                background-position: bottom left">
                            </td>
                        </tr>
                    </table>
                </div>
                <div id="divResults" visible="false" runat="server" style="margin-top: 20px; padding-right: 10px">
                    <table cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7;width:100%">
                        <tr>
                            <td style="width: 8px; height: 10px; background-image: url('../Images/Applic/RTcornerGrey10.gif');
                                background-repeat: no-repeat; background-position: top right">
                            </td>
                            <td style="background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x;
                                background-position: top">
                            </td>
                            <td style="width: 8px; background-image: url('../Images/Applic/LTcornerGrey10.gif');
                                background-repeat: no-repeat; background-position: top left;">
                            </td>
                        </tr>
                        <tr>
                            <td style="border-right: 2px solid #949494;">
                                &nbsp;
                            </td>
                            <td dir="rtl">
                                <div style="min-height:380px">
                                <asp:GridView ID="gvAdminCommentsResults" runat="server" SkinID="GridViewForSearchResults"
                                    OnRowDeleting="gvAdminCommentsResults_OnRowDeleting" AutoGenerateColumns="false"
                                    OnRowDataBound="gvAdminCommentsResults_RowDataBound" Width="100%">
                                    <EmptyDataTemplate>
                                        <asp:Label ID="lblEmptyData" runat="server" Text="אין מידע" CssClass="RegularLabel"></asp:Label>
                                    </EmptyDataTemplate>
                                    <Columns>
                                           
                                        <asp:BoundField DataField="ID" HeaderStyle-CssClass="DisplayNone" ItemStyle-CssClass="DisplayNone" />

                                        <asp:BoundField DataField="Title" HeaderText="כותרת" 
                                            HeaderStyle-Width="220px" ItemStyle-Width="220px" 
                                            HeaderStyle-CssClass="ColumnHeader2" />    
                                            
                                        <asp:BoundField DataField="Comment" HeaderText="הערה" 
                                            HeaderStyle-Width="370px" ItemStyle-Width="370px"
                                            HeaderStyle-CssClass="ColumnHeader2" />
                                            
                                        <asp:BoundField DataField="StartDate" HeaderText="תאריך התחלה" 
                                            HeaderStyle-Width="100px" ItemStyle-Width="100px" 
                                            HeaderStyle-CssClass="ColumnHeader2" DataFormatString="{0:dd/MM/yyyy}" />

                                        <asp:BoundField DataField="ExpiredDate" HeaderText="תאריך סיום" HeaderStyle-CssClass="ColumnHeader2" 
                                            HeaderStyle-Width="100px" ItemStyle-Width="100px" DataFormatString="{0:dd/MM/yyyy}" />

                                        <asp:TemplateField HeaderStyle-Width="70px" ItemStyle-Width="70px" HeaderText="פעיל" HeaderStyle-CssClass="ColumnHeader2">
                                            <ItemTemplate>

                                                <asp:HiddenField ID="hfAdminComment_ID" runat="server" Value='<%# Eval("ID") %>' />
                                                <asp:HiddenField ID="hfAdminComment_Title" runat="server" Value='<%# Eval("Title") %>' />
                                                <asp:HiddenField ID="hfAdminComment_Comment" runat="server" Value='<%# Eval("Comment") %>' />
                                                <asp:HiddenField ID="hfAdminComment_StartDate" runat="server" Value='<%# Eval("StartDate" , "{0:dd/MM/yyyy}") %>' />
                                                <asp:HiddenField ID="hfAdminComment_ExpiredDate" runat="server" Value='<%# Eval("ExpiredDate" , "{0:dd/MM/yyyy}") %>' />
                                                <asp:HiddenField ID="hfAdminComment_Active" runat="server" Value='<%# Eval("Active") %>' />

                                                <asp:CheckBox ID="cbActive" runat="server" Enabled="false"></asp:CheckBox>

                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderStyle-Width="90px" ItemStyle-Width="90px" ItemStyle-HorizontalAlign="Center">
                                            <HeaderTemplate>&nbsp;</HeaderTemplate>
                                            <ItemTemplate>
                                                <asp:ImageButton runat="server" ID="ibEdit" ImageUrl="~/Images/btn_edit.gif" ToolTip="עדכון" AlternateText="עדכון" BorderStyle="None" OnClientClick="EditAdminComment(this);return false;" />
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField ItemStyle-HorizontalAlign="Center">
                                            <HeaderTemplate>&nbsp;</HeaderTemplate>
                                            <ItemTemplate>
                                                <asp:ImageButton CssClass="mrgTop" ID="btnDelete" runat="server" ImageUrl="~/Images/Applic/btn_X_red.gif"
                                                        OnClientClick="if (!confirm('האם ברצונך למחוק את ההערה?')) return false;" CausesValidation="false" ToolTip="מחיקה" CommandName="Delete" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                                </div>
                            </td>
                            <td style="border-left: 2px solid #949494;">
                                &nbsp;
                            </td>
                        </tr>
                        <tr style="height: 10px">
                            <td style="background-image: url('../Images/Applic/RBcornerGrey10.gif'); background-repeat: no-repeat;
                                background-position: bottom right">
                            </td>
                            <td style="background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x;
                                background-position: bottom">
                            </td>
                            <td style="background-image: url('../Images/Applic/LBcornerGrey10.gif'); background-repeat: no-repeat;
                                background-position: bottom left">
                            </td>
                        </tr>
                    </table>
                </div>

                <asp:HiddenField ID="hfAdminComment_ID" runat="server" />
                <asp:HiddenField ID="hfAdminComment_Title" runat="server" />
                <asp:HiddenField ID="hfAdminComment_Comment" runat="server" />
                <asp:HiddenField ID="hfAdminComment_StartDate" runat="server" />
                <asp:HiddenField ID="hfAdminComment_ExpiredDate" runat="server" />
                <asp:HiddenField ID="hfAdminComment_Active" runat="server" />
                <asp:Button ID="btnAddAdminComment" runat="server" Text="הוספת ההערה" CausesValidation="false"
                    CssClass="DisplayNone" OnClick="btnAddAdminComment_Click"></asp:Button>

            </div>

        </ContentTemplate>
        

        
    </asp:UpdatePanel>
    <div id="divAddNewAdminComment" style="display: none;">
        <table cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7;
            direction: rtl; text-align: right;">
            <tr>
                <td style="padding: 0; height: 10px; background-image: url('../Images/Applic/RTcornerGrey10.gif');
                    background-repeat: no-repeat; background-position: top right">
                </td>
                <td style="padding: 0; background-image: url('../Images/Applic/borderGreyH.jpg');
                    background-repeat: repeat-x; background-position: top">
                </td>
                <td style="padding: 0; background-image: url('../Images/Applic/LTcornerGrey10.gif');
                    background-repeat: no-repeat; background-position: top left">
                </td>
            </tr>
            <tr>
                <td style="border-right: solid 2px #909090;">
                    &nbsp;
                </td>
                <td>
                    <table cellpadding="0" cellspacing="0">
                        <tr>
                            <td colspan="2" style="height: 5px; _height: 0;">
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label ID="lblAdminComment_Title" runat="server">כותרת</asp:Label>
                            </td>
                            <td>
                                <asp:TextBox ID="tbAdminComment_Title" runat="server" Width="200px"></asp:TextBox>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2" style="height: 5px;">
                            </td>
                        </tr>
                        <tr>
                            <td valign="top" style="padding:2px">
                                <asp:Label ID="lblAdminComment_Comment" runat="server">הערה:</asp:Label>
                            </td>
                            <td>
                                <asp:TextBox ID="tbAdminComment_Comment" runat="server" Width="200px" TextMode="MultiLine" Height="51px">
                                </asp:TextBox>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2" style="height: 5px;">
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label ID="lblAdminComment_StartDate" runat="server">תאריך התחלה:</asp:Label>
                            </td>
                            <td>
                                <asp:TextBox ID="tbAdminComment_StartDate" runat="server" Width="100px"></asp:TextBox>
                                <asp:ImageButton ID="btnRunCalendar_NewStartDate" runat="server" ImageUrl="~/Images/Applic/calendarIcon.png" style="position:relative;top:4px" />
                                <ajaxToolkit:MaskedEditValidator ID="NewStartDateValidator" runat="server" ControlExtender="NewStartDateExtender"
                                    ControlToValidate="tbAdminComment_StartDate" Display="Dynamic" ErrorMessage="התאריך אינו תקין"
                                    InvalidValueBlurredMessage="*" InvalidValueMessage="התאריך אינו תקין" />
                                <ajaxToolkit:CalendarExtender ID="calNewStartDateExtender" runat="server" Enabled="True"
                                    FirstDayOfWeek="Sunday" Format="dd/MM/yyyy" PopupButtonID="btnRunCalendar_NewStartDate" 
                                    PopupPosition="BottomRight" TargetControlID="tbAdminComment_StartDate">
                                </ajaxToolkit:CalendarExtender>
                                <ajaxToolkit:MaskedEditExtender ID="NewStartDateExtender" runat="server" ClearMaskOnLostFocus="true"
                                    Enabled="True" ErrorTooltipEnabled="True" Mask="99/99/9999" MaskType="Date" TargetControlID="tbAdminComment_StartDate">
                                </ajaxToolkit:MaskedEditExtender>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2" style="height: 5px;">
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label ID="lblAdminComment_ExpiredDate" runat="server">תאריך סיום:</asp:Label>
                            </td>
                            <td>
                                <asp:TextBox ID="tbAdminComment_ExpiredDate" runat="server" Width="100px"></asp:TextBox>
                                <asp:ImageButton ID="btnRunCalendar_NewExpiredDate" runat="server" ImageUrl="~/Images/Applic/calendarIcon.png" style="position:relative;top:4px" />
                                <ajaxToolkit:MaskedEditValidator ID="NewExpiredDateValidator" runat="server" ControlExtender="NewExpiredDateExtender"
                                    ControlToValidate="tbAdminComment_ExpiredDate" Display="Dynamic" ErrorMessage="התאריך אינו תקין"
                                    InvalidValueBlurredMessage="*" InvalidValueMessage="התאריך אינו תקין" />
                                <ajaxToolkit:CalendarExtender ID="calNewExpiredDateExtender" runat="server" Enabled="True"
                                    FirstDayOfWeek="Sunday" Format="dd/MM/yyyy" PopupButtonID="btnRunCalendar_NewExpiredDate" 
                                    PopupPosition="BottomRight" TargetControlID="tbAdminComment_ExpiredDate">
                                </ajaxToolkit:CalendarExtender>
                                <ajaxToolkit:MaskedEditExtender ID="NewExpiredDateExtender" runat="server" ClearMaskOnLostFocus="true"
                                    Enabled="True" ErrorTooltipEnabled="True" Mask="99/99/9999" MaskType="Date" TargetControlID="tbAdminComment_ExpiredDate">
                                </ajaxToolkit:MaskedEditExtender>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2" style="height: 5px;">
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label ID="lblAdminComment_Active" runat="server">פעיל:</asp:Label>
                            </td>
                            <td>
                                <asp:CheckBox ID="cbAdminComment_Active" runat="server" Checked="true"></asp:CheckBox>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2" style="height: 5px;">
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <table cellpadding="0" cellspacing="0" style="margin-top: 10px; width: 100%;">
                                    <tr>
                                        <td>
                                            <table cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td class="buttonRightCorner">
                                                        &nbsp;
                                                    </td>
                                                    <td class="buttonCenterBackground">
                                                        <input value="הוספת ההערה" id="UpdateInsertButton" class="RegularUpdateButton" OnClick="AddUpdateAdminCommentSubmit()" style="Width:90px" />
                                                    </td>
                                                    <td class="buttonLeftCorner">
                                                        &nbsp;
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td>
                                            <table cellpadding="0" cellspacing="0" style="float: left; margin-left: 5px;">
                                                <tr>
                                                    <td class="buttonRightCorner">
                                                        &nbsp;
                                                    </td>
                                                    <td class="buttonCenterBackground">
                                                        <asp:Button ID="btnClearAddSection" runat="server" Text="ניקוי" CssClass="RegularUpdateButton"
                                                            Width="45px" OnClientClick="ClearAddSection(); return false;" CausesValidation="false">
                                                        </asp:Button>
                                                    </td>
                                                    <td class="buttonLeftCorner">
                                                        &nbsp;
                                                    </td>
                                                    <td class="buttonRightCorner">
                                                        &nbsp;
                                                    </td>
                                                    <td class="buttonCenterBackground">
                                                        <input type="button" value="ביטול" class="RegularUpdateButton" onclick="javascript:tb_remove();ClearAddSection();"
                                                            style="width: 45px;" />
                                                    </td>
                                                    <td class="buttonLeftCorner">
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
                </td>
                <td style="border-left: solid 2px #909090;">
                    &nbsp;
                </td>
            </tr>
            <tr style="height: 10px">
                <td style="background-image: url('../Images/Applic/RBcornerGrey10.gif'); background-repeat: no-repeat;
                    background-position: bottom right">
                </td>
                <td style="background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x;
                    background-position: bottom">
                </td>
                <td style="background-image: url('../Images/Applic/LBcornerGrey10.gif'); background-repeat: no-repeat;
                    background-position: bottom left">
                </td>
            </tr>
        </table>
    </div>
    <a id="aTBOpenPopup_inline" style="display: none;" href="" class="thickbox">Show hidden
        modal content.</a>
    <script type="text/javascript" src="../Scripts/srcScripts/Thickbox.js"></script>
</asp:Content>
