<%@ Reference Page="AdminBasePage.aspx" %>

<%@ Page Language="C#" AutoEventWireup="true" Title="עדכון תפריט ראשי" MasterPageFile="~/seferMasterPage.master" Inherits="UpdateMainMenu" meta:resourcekey="PageResource1" Codebehind="UpdateMainMenu.aspx.cs" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<%@ Register Assembly="System.Web.Extensions, Version=1.0.61025.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
    Namespace="System.Web.UI" TagPrefix="asp" %>
<%@ MasterType VirtualPath="~/seferMasterPage.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="pageContent" runat="server">
    <script type="text/javascript">
        var BG_ReadOnly = "#F7F7F7";
        var BG_notReadOnly = "White";

        function SetNewWindowControls() {
            var cbNewWindow = document.getElementById('<%=cbNewWindow.ClientID%>');
            var cbModalDialog = document.getElementById('<%=cbModalDialog.ClientID%>');
            var txtSizeX = document.getElementById('<%=txtSizeX.ClientID%>');
            var txtSizeY = document.getElementById('<%=txtSizeY.ClientID%>');
            var cbResize = document.getElementById('<%=cbResize.ClientID%>');

            cbModalDialog.checked = false;
            txtSizeX.value = "";
            txtSizeY.value = "";
            cbResize.checked = true;

            if (cbNewWindow.checked == true) {

                cbModalDialog.disabled = false;
                cbModalDialog.removeAttribute("disabled");
                txtSizeX.disabled = false;
                txtSizeX.style.background = BG_notReadOnly;

                txtSizeY.disabled = false;
                txtSizeY.style.background = BG_notReadOnly;

                cbResize.disabled = false;
            }
            else {
                cbModalDialog.disabled = true;
                txtSizeX.disabled = true;
                txtSizeX.style.background = BG_ReadOnly;

                txtSizeY.disabled = true;
                txtSizeY.style.background = BG_ReadOnly;

                cbResize.disabled = true;

                cbResize.checked = false;
            }
        }

        function SetEmptyEntry() {
            var cbNewWindow = document.getElementById('<%=cbNewWindow.ClientID%>');
            var cbModalDialog = document.getElementById('<%=cbModalDialog.ClientID%>');
            var txtSizeX = document.getElementById('<%=txtSizeX.ClientID%>');
            var txtSizeY = document.getElementById('<%=txtSizeY.ClientID%>');
            var cbResize = document.getElementById('<%=cbResize.ClientID%>');
            var cbEmptyEntry = document.getElementById('<%=cbEmptyEntry.ClientID%>');
            var txtUrl = document.getElementById('<%=txtUrl.ClientID%>');

            if (cbEmptyEntry.checked == true) {

                cbModalDialog.disabled = true;
                cbModalDialog.checked = false;

                txtSizeX.disabled = true;
                txtSizeX.style.background = BG_ReadOnly;
                txtSizeX.value = "";

                txtSizeY.disabled = true;
                txtSizeY.style.background = BG_ReadOnly;
                txtSizeY.value = "";

                txtUrl.disabled = true;
                txtUrl.style.background = BG_ReadOnly;
                txtUrl.value = "";

                cbResize.checked = false;
                cbResize.disabled = true;

                cbNewWindow.checked = false;
                cbNewWindow.disabled = true;
            }
            else {
                cbModalDialog.disabled = false;
                cbModalDialog.removeAttribute("disabled");


                txtSizeX.disabled = false;
                txtSizeX.style.background = BG_notReadOnly;

                txtSizeY.disabled = false;
                txtSizeY.style.background = BG_notReadOnly;

                txtUrl.disabled = false;
                txtUrl.style.background = BG_notReadOnly;

                cbResize.disabled = false;
                cbNewWindow.disabled = false;
            }

        }
    </script>
    <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Always" runat="server">
        <ContentTemplate>
            <table cellpadding="0" cellspacing="0">
                <tr id="trError" runat="server">
                    <td>
                        <asp:Label ID="lblGeneralError" runat="server" SkinID="lblError"></asp:Label>
                    </td>
                </tr>
                <tr style="display: none">
                    <td>
                        <asp:CheckBox ID="cbBackToZoomClinic" runat="server" />
                    </td>
                </tr>
            </table>
            <table cellspacing="0" cellpadding="0" dir="rtl">
                <tr>
                    <td style="padding-right: 10px; padding-bottom: 0px">
                        <!-- Upper Blue Bar -->
                        <table cellpadding="0" cellspacing="0" style="background-color: #298AE5;" width="980px">
                            <tr>
                                <td style="padding-right: 15px">
                                    <div style="height: 18px">
                                    </div>
                                </td>
                                <td align="left" style="padding-left: 10px">
                                </td>
                                <td>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td style="padding-top: 0px;">
                        <table cellpadding="0" cellspacing="0" dir="rtl">
                            <tr>
                                <td valign="top" style="padding-right: 10px; padding-top: 0px; border-left: solid 1px #949494;">
                                    <table cellpadding="0" cellspacing="0" border="0" width="100%" style="background-color: #F7F7F7">
                                        <tr>
                                            <td style="padding-top: 3px; border-top: solid 2px #949494; border-bottom: solid 2px #949494;">
                                                <div style="height: 36px">
                                                    <table cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td>
                                                                <table cellpadding="0" cellspacing="0">
                                                                    <tr>
                                                                        <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                            background-position: bottom left;">
                                                                            &nbsp;
                                                                        </td>
                                                                        <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                            background-repeat: repeat-x; background-position: bottom;">
                                                                            <asp:Button ID="btnAddItem" Width="90px" runat="server" Text="כניסה חדשה" CssClass="RegularUpdateButton"
                                                                                OnClick="btnAddItem_Click"></asp:Button>
                                                                        </td>
                                                                        <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                                            background-repeat: no-repeat;">
                                                                            &nbsp;
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </td>
                                                            <td style="padding-right: 45px">
                                                                <table cellpadding="0" cellspacing="0">
                                                                    <tr>
                                                                        <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                            background-position: bottom left;">
                                                                            &nbsp;
                                                                        </td>
                                                                        <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                            background-repeat: repeat-x; background-position: bottom;">
                                                                            <asp:Button ID="btnAddChildItem" Width="80px" Enabled="false" runat="server" Text="הוספת בן"
                                                                                CssClass="RegularUpdateButton" OnClick="btnAddChildItem_Click"></asp:Button>
                                                                        </td>
                                                                        <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                                            background-repeat: no-repeat;">
                                                                            &nbsp;
                                                                        </td>
                                                                    </tr>
                                                                </table>
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
                                                                            <asp:Button ID="btnUpdateItem" Width="70px" Enabled="false" runat="server" Text="עדכון"
                                                                                CssClass="RegularUpdateButton" OnClick="btnUpdateItem_Click"></asp:Button>
                                                                        </td>
                                                                        <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                                            background-repeat: no-repeat;">
                                                                            &nbsp;
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </td>
                                                            <td style="padding-right: 15px; padding-top: 6px">
                                                                <table width="100%" cellpadding="0" cellspacing="0">
                                                                    <tr>
                                                                        <td align="right">
                                                                            <asp:ImageButton ID="btnMooveUp" runat="server" ImageUrl="../Images/Applic/btnUp_disabled.gif"
                                                                                OnClick="btnMooveUp_Click" />
                                                                            <asp:ImageButton ID="btnMooveDown" runat="server" ImageUrl="../Images/Applic/btnDown_disabled.gif"
                                                                                OnClick="btnMooveDown_Click" />
                                                                        </td>
                                                                        <td style="padding-right: 5px">
                                                                            <asp:ImageButton ID="btnDelete" runat="server" ImageUrl="../Images/Applic/btn_X_grey.gif"
                                                                                OnClientClick="return confirm('?האם הנך בטוח שברצונך למחוק את האיטם מהתפריט')"
                                                                                OnClick="btnDelete_Click" />
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td style="width: 10px">
                                    &nbsp;
                                </td>
                                <td id="tblUpdateItem" rowspan="2" runat="server" style="padding-top: 0px; display: none"
                                    valign="top">
                                    <table cellpadding="0" cellspacing="0" border="0" style="border-right: solid 1px #949494;
                                        border-top: solid 2px #949494; background-color: #F7F7F7;">
                                        <tr>
                                            <td style="">
                                                <div style="width: 500px; height: 522px">
                                                    <table cellpadding="0" cellspacing="0" width="100%" border="0">
                                                        <tr>
                                                            <td>
                                                            </td>
                                                            <td colspan="2" style="padding-top: 10px">
                                                                <table cellpadding="0" cellspacing="0">
                                                                    <tr>
                                                                        <td>
                                                                            <asp:CheckBox ID="cbRoot" Enabled="false" runat="server" CssClass="RegularLabel"
                                                                                Text="Root" />
                                                                        </td>
                                                                        <td>
                                                                            <asp:TextBox EnableTheming="false" CssClass="DisplayNone" ID="txtSelectedNode" Width="15px"
                                                                                runat="server"></asp:TextBox>
                                                                            <asp:TextBox EnableTheming="false" CssClass="DisplayNone" ID="txtParrentID" Width="15px"
                                                                                runat="server"></asp:TextBox>
                                                                            <asp:CheckBox EnableTheming="false" CssClass="DisplayNone" ID="cbItIsUpdate" runat="server" />
                                                                        </td>
                                                                        <td>
                                                                            <span>
                                                                                <asp:CheckBox ID="cbEmptyEntry" Enabled="true" runat="server" CssClass="RegularLabel"
                                                                                    Text="Empty entry" />
                                                                            </span>
                                                                        </td>
                                                                        <td>
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="padding-right: 10px">
                                                                <asp:Label ID="lblParrent" runat="server" Text="שם אב"></asp:Label>
                                                            </td>
                                                            <td colspan="2">
                                                                <asp:TextBox Width="400px" ID="txtParrent" ReadOnly="true" runat="server"></asp:TextBox>
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="padding-right: 10px">
                                                                <asp:Label ID="lblTitle" runat="server" Text="כותרת"></asp:Label>
                                                            </td>
                                                            <td colspan="2">
                                                                <asp:TextBox Width="400px" ID="txtTitle" runat="server"></asp:TextBox>
                                                            </td>
                                                            <td>
                                                                <asp:RequiredFieldValidator ID="vldTitle" runat="server" Text="*" ErrorMessage="**"
                                                                    ValidationGroup="vgrMenuItem" ControlToValidate="txtTitle"></asp:RequiredFieldValidator>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="padding-right: 10px;">
                                                                <asp:Label ID="lblUrl" runat="server" Text="Url"></asp:Label>
                                                            </td>
                                                            <td colspan="2" align="right" dir="ltr">
                                                                <asp:TextBox Width="400px" ID="txtUrl" runat="server"></asp:TextBox>
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="padding-right: 10px; padding-left: 5px" valign="top">
                                                                <asp:Label ID="lblPermissionLevel" Width="70px" runat="server" Text="רמת הרשאה"></asp:Label>
                                                            </td>
                                                            <td colspan="2" style="padding-bottom: 10px; border-bottom: solid 1px #949494">
                                                                <div style="height: 80px; overflow-y: auto; direction: ltr; width: 190px; text-align: right">
                                                                    <asp:CheckBoxList ID="lstPermissionsTypes" runat="server" DataTextField="permissionDescription"
                                                                        DataValueField="permissionCode" Height="100px" CssClass="RegularLabel rtl">
                                                                    </asp:CheckBoxList>
                                                                </div>
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="3" style="padding-right: 90px; padding-top: 5px">
                                                                <asp:Label Width="90px" ID="lblNewWindow" runat="server" Text="New window"></asp:Label>
                                                                <input type="checkbox" id="cbNewWindow" runat="server" />
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="2" style="padding-right: 90px;">
                                                                <asp:Label Width="90px" ID="lblModalDialog" runat="server" Text="Modal dialog"></asp:Label>
                                                                <input type="checkbox" id="cbModalDialog" runat="server" />
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="2" style="padding-right: 90px;">
                                                                <asp:Label Width="90px" ID="lblSizeX" runat="server" Text="גודל X"></asp:Label>&nbsp;
                                                                <asp:TextBox ID="txtSizeX" runat="server"></asp:TextBox>
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="2" style="padding-right: 90px;">
                                                                <asp:Label Width="90px" ID="lblSizeY" runat="server" Text="גודל Y"></asp:Label>&nbsp;
                                                                <asp:TextBox ID="txtSizeY" runat="server"></asp:TextBox>
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="2" style="padding-right: 90px; padding-bottom: 10px">
                                                                <asp:Label Width="90px" ID="lblResize" runat="server" Text="Resize"></asp:Label>
                                                                <input type="checkbox" id="cbResize" runat="server" />
                                                            </td>
                                                            <td>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="4" style="background-color: White; height: 2px; padding: 0px 0px 0px 0px;
                                                                font-size: 1px; border-top: solid 1px #949494; border-bottom: solid 1px #949494;">
                                                                &nbsp;
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="4" style="padding-right: 10px; padding-bottom: 7px;">
                                                                <asp:Label ID="lblRestrictionTitle" EnableTheming="false" CssClass="LabelCaptionBlueBold_14"
                                                                    runat="server" Text="דפים בהם מופיע תפריט"></asp:Label>
                                                                <br />
                                                                &nbsp;
                                                                <asp:Label ID="lblRestrictionTitle2" Height="12px" EnableTheming="false" CssClass="LabelNormalDirtyBlue_12"
                                                                    runat="server" Text="* אם לא מצויין אף דף התפריט יראה בכל דפי המערכת"></asp:Label>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="padding-right: 10px;" valign="top" >
                                                                <asp:Label ID="lblPageName" runat="server" Text="שם הדף"></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:TextBox ID="txtPageName" Width="330px" runat="server"></asp:TextBox>
                                                                <asp:RequiredFieldValidator ID="vldTxtPageName" ControlToValidate="txtPageName" runat="server"
                                                                   Display="Dynamic" Text="*" ValidationGroup="grAddPageName"></asp:RequiredFieldValidator>
                                                            </td>
                                                            <td valign="top">
                                                                <table cellpadding="0" cellspacing="0">
                                                                    <tr>
                                                                        <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                            background-position: bottom left;">
                                                                            &nbsp;
                                                                        </td>
                                                                        <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                            background-repeat: repeat-x; background-position: bottom;">
                                                                            <asp:Button ID="btnAddPageName" runat="server" CssClass="RegularUpdateButton" Text="הוספה"
                                                                                OnClick="btnAddPageName_Click" ValidationGroup="grAddPageName" />
                                                                        </td>
                                                                        <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                                            background-repeat: no-repeat;">
                                                                            &nbsp;
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </td>
                                                            <td>
                                                                <asp:RegularExpressionValidator ID="vldRegTxtPageName" runat="server" ValidationExpression="^[a-zA-Z0-9\-'_]*$"
                                                                 Display="Dynamic" Text="*" ControlToValidate="txtPageName" ValidationGroup="grAddPageName"></asp:RegularExpressionValidator>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="border-bottom: solid 2px #949494">
                                                                &nbsp;
                                                            </td>
                                                            <td colspan="3" style="padding-bottom: 5px; border-bottom: solid 2px #949494" valign="top">
                                                                <div style="height: 50px; overflow-y: auto; direction: ltr;">
                                                                    <div style="direction: rtl">
                                                                        <asp:GridView ID="gvRestrictions" Width="400px" runat="server" AutoGenerateColumns="False"
                                                                            SkinID="GridViewForSearchResults" HeaderStyle-BackColor="White" HeaderStyle-CssClass="LabelBoldDirtyBlue">
                                                                            <Columns>
                                                                                <asp:BoundField DataField="MainMenuRestrictionsID" ItemStyle-CssClass="DisplayNone"
                                                                                    HeaderStyle-CssClass="DisplayNone" />
                                                                                <asp:BoundField DataField="MainMenuItemID" ItemStyle-CssClass="DisplayNone" HeaderStyle-CssClass="DisplayNone" />
                                                                                <asp:BoundField DataField="PageName" ItemStyle-Width="370px" HeaderStyle-HorizontalAlign="Right"
                                                                                    HeaderText="שם הדף" />
                                                                                <asp:TemplateField ItemStyle-Width="25px">
                                                                                    <ItemTemplate>
                                                                                        <asp:ImageButton ID="btnDeleteRestriction" runat="server" ImageUrl="../Images/Applic/btn_X_red.gif"
                                                                                            MainMenuItemID='<%# Eval("MainMenuItemID")%>' PageName='<%# Eval("PageName")%>'
                                                                                            OnClick="btnDeleteRestriction_Click" ToolTip="מחיקה" OnClientClick="return confirm('?האם הנך בטוח שברצונך למחוק את הדף')">
                                                                                        </asp:ImageButton>
                                                                                    </ItemTemplate>
                                                                                </asp:TemplateField>
                                                                            </Columns>
                                                                        </asp:GridView>
                                                                    </div>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="3" style="padding-top: 5px;" align="left">
                                                                <table cellpadding="0" cellspacing="0">
                                                                    <tr>
                                                                        <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                            background-position: bottom left;">
                                                                            &nbsp;
                                                                        </td>
                                                                        <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                            background-repeat: repeat-x; background-position: bottom;">
                                                                            <asp:Button ID="btnSave" runat="server" CssClass="RegularUpdateButton" Text="שמירה"
                                                                                ValidationGroup="vgrMenuItem" OnClick="btnSave_Click" />
                                                                        </td>
                                                                        <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                                            background-repeat: no-repeat;">
                                                                            &nbsp;
                                                                        </td>
                                                                        <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                            background-position: bottom left;">
                                                                            &nbsp;
                                                                        </td>
                                                                        <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                            background-repeat: repeat-x; background-position: bottom;">
                                                                            <asp:Button ID="btnCancel" runat="server" CssClass="RegularUpdateButton" Text="ביטול"
                                                                                CausesValidation="False" OnClick="btnCancel_Click" />
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
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td align="right" dir="ltr" valign="top" style="padding-right: 10px; border-left: solid 1px #949494">
                                    <!-- Selected Remarks -->
                                    <div id="divTrvMaimMenu" class="ScrollBarDiv" runat="server" style="background-color: #F7F7F7;
                                        width: 440px; height: 480px; overflow-y: scroll">
                                        <table cellpadding="0" cellspacing="0" border="0">
                                            <tr>
                                                <td dir="rtl">
                                                    <asp:TreeView ID="trvMaimMenu" runat="server" Width="420px" OnSelectedNodeChanged="trvMaimMenu_SelectedNodeChanged"
                                                        OnTreeNodeDataBound="trvMaimMenu_TreeNodeDataBound">
                                                        <LevelStyles>
                                                            <asp:TreeNodeStyle ChildNodesPadding="5" CssClass="TreeNodeGreen" />
                                                            <asp:TreeNodeStyle ChildNodesPadding="5" CssClass="TreeNodeGreen" />
                                                            <asp:TreeNodeStyle ChildNodesPadding="5" CssClass="TreeNodeGreen" />
                                                            <asp:TreeNodeStyle ChildNodesPadding="5" CssClass="TreeNodeGreen" />
                                                        </LevelStyles>
                                                        <SelectedNodeStyle CssClass="TreeNodeSelected" />
                                                    </asp:TreeView>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </td>
                                <td style="width: 10px">
                                    &nbsp;
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td style="padding-right: 10px">
                        <!-- Lower Blue Bar -->
                        <table cellpadding="0" cellspacing="0" style="background-color: #298AE5; height: 20px;"
                            width="980px">
                            <tr>
                                <td align="left" style="padding-left: 10px">
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
