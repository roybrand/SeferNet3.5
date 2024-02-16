<%@ Reference Page="AdminBasePage.aspx" %>

<%@ Page Language="C#" 
    AutoEventWireup="true" 
    Title="ניהול משתמשים" 
    MasterPageFile="~/seferMasterPageIE.master" 
    Inherits="UserAdministration" 
    EnableEventValidation="false" 
    Codebehind="UserAdministration.aspx.cs" %>

<%@ MasterType VirtualPath="~/seferMasterPageIE.master" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<asp:Content ID="Content2" ContentPlaceHolderID="phHead" runat="Server">
    <script type="text/javascript">

        function selectRowOnLoad(rowPrefix, rowInd) {
            rowInd = rowInd + 2;
            if (rowInd < 10)
                rowInd = "0" + rowInd;
            var newIndex = parseInt(rowInd, 10) + 5;
            if (newIndex < 10) {
                newIndex = "0" + newIndex;
            }
            else {
                newIndex = newIndex + "";
            }
            var newClientIdPrefix = rowPrefix.replace(rowInd, newIndex);

            var row = document.getElementById(newClientIdPrefix + "_btnUpdateUser");
            if (row == null)
                row = document.getElementById(rowPrefix + "_btnUpdateUser");
            //ctl00_pageContent_gvUsers_ctl02_btnUpdateUser
            if (row != null)
                row.focus();
        }

        function SelectUser(userID) {
            var txtSelectedUserName = document.getElementById('<% =txtSelectedUserName.ClientID%>');
            var btnDoPostBack = document.getElementById('<% =btnDoPostBack.ClientID%>');
            txtSelectedUserName.value = userID;
            btnDoPostBack.click();
        }

        function ExpandUserID(userID) {
            var txtUserIDToExpand = document.getElementById('<% =txtUserIDToExpand.ClientID%>');
            txtUserIDToExpand.value = userID;
        }

        function CollapsUserID(userID) {
            var txtUserIDToCollaps = document.getElementById('<% =txtUserIDToCollaps.ClientID%>');
            txtUserIDToCollaps.value = userID;
        }

        function OpenUpdateUser(UserID, UserName, Domain, DefinedInAD) {
            var url = "UpdateUser.aspx";
            url = url + "?UserID=" + UserID + "&UserName=" + UserName + "&Domain=" + Domain + "&DefinedInAD=" + DefinedInAD;

            var dialogWidth = 620;
            var dialogHeight = 700;
            var title = "עדכון פרטי משתמש";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

            return false;
        }

        function GetDivScrollPosition() {
            var scrollPosition = document.getElementById('<%=pnlGvUsers.ClientID %>').scrollTop;
            var txtDiv_ScrollPosition = document.getElementById('<%=txtDiv_ScrollPosition.ClientID %>');
            txtDiv_ScrollPosition.value = scrollPosition;
        }

        function SetDivScrollPosition() {
            var divPnlGvUsers = document.getElementById('<%=pnlGvUsers.ClientID %>');
            var txtDiv_ScrollPosition = document.getElementById('<%=txtDiv_ScrollPosition.ClientID %>');
            divPnlGvUsers.scrollTop = txtDiv_ScrollPosition.value;
        }

    </script>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="pageContent" runat="server">
            <div id="progress" style="position: absolute; top: 300px; left: 500px">
                <asp:UpdateProgress ID="UpdateProgress1" runat="server">
                    <ProgressTemplate>
                        <asp:Image ID="img" runat="server" ImageUrl="~/Images/Applic/progressBar.gif" />
                    </ProgressTemplate>
                </asp:UpdateProgress>
            </div>
            <table cellpadding="0" cellspacing="0" dir="rtl">
                <tr>
                    <td style="padding-right: 8px">
                        <table cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7">
                            <tr>
                                <td style="height: 8px; background-image: url('../Images/Applic/RTcornerGrey10.gif');
                                    background-repeat: no-repeat; background-position: top right">
                                </td>
                                <td style="background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x;
                                    background-position: top">
                                </td>
                                <td style="background-image: url('../Images/Applic/LTcornerGrey10.gif'); background-repeat: no-repeat;
                                    background-position: top left">
                                </td>
                            </tr>
                            <tr>
                                <td style="border-right: solid 2px #909090;">
                                    <div style="width: 6px;">
                                    </div>
                                </td>
                                <td align="right">
                                    <div style="width: 960px">
                                        <table cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td style="padding-left: 5px; width:90px;" valign="middle">
                                                    <asp:Label ID="lblDdlDistrictCapture" runat="server" Text="מחוז"></asp:Label>
                                                </td>
                                                <td style="padding-bottom: 5px; padding-top: 5px;">
                                                    <asp:DropDownList Width="180px" ID="ddlDistrict" runat="server" AppendDataBoundItems="True"
                                                        DataTextField="districtName" DataValueField="districtCode">
                                                        <asp:ListItem Text="כל המחוזות" Value="-1"></asp:ListItem>
                                                    </asp:DropDownList>
                                                </td>
                                                <td style="padding-right: 10px; padding-left: 5px; width:90px;" valign="middle" align="left">
                                                    <asp:Label ID="lblDdlPermissionType" runat="server" Text="סוג הרשאה"></asp:Label>
                                                </td>
                                                <td>
                                                    <asp:DropDownList Width="180px" ID="ddlPermissionType" runat="server" AppendDataBoundItems="True"
                                                        DataTextField="permissionDescription" DataValueField="permissionCode">
                                                        <asp:ListItem Text="כל ההרשאות" Value="-1"></asp:ListItem>
                                                    </asp:DropDownList>
                                                </td>
                                                <td style="padding-left: 5px; width:90px;" align="left">
                                                    <asp:Label ID="lblUserDomain" runat="server" Text="domain"></asp:Label>
                                                </td>
                                                <td>
                                                    <asp:DropDownList Width="180px" ID="ddlUserDomain" runat="server" DataTextField="DomainName" DataValueField="DomainName" AppendDataBoundItems="True">
                                                        <asp:ListItem Text="הכל" Value=""></asp:ListItem>
                                                    </asp:DropDownList>
                                                </td>
                                                <td style="padding-right: 100px;">
                                                    <table cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                background-position: bottom left;">
                                                                &nbsp;
                                                            </td>
                                                            <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                background-repeat: repeat-x; background-position: bottom;">
                                                                <asp:Button ID="btnSearch" runat="server" Text="חיפוש" CssClass="RegularUpdateButton"
                                                                    OnClick="btnSearch_Click" ValidationGroup="grSearchParameters"></asp:Button>
                                                            </td>
                                                            <td style="background-position: right bottom; background-image: url(../Images/Applic/regButtonBG_Left.gif);
                                                                background-repeat: no-repeat;">
                                                                &nbsp;
                                                            </td>
                                                        </tr>
                                                    </table>
                                                    <asp:TextBox ID="txtDiv_ScrollPosition" runat="server" EnableTheming="false" CssClass="DisplayNone" ></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="padding-left: 5px;" >
                                                    <asp:Label ID="lblUserNameSearch" runat="server" Text="שם משתמש"></asp:Label>
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtUserNameSearch" runat="server" Width="175px"></asp:TextBox>
                                                </td>
                                                <td style="padding-left: 5px;" align="left">
                                                    <asp:Label ID="lblUserFirstNameSearch" runat="server" Text="שם פרטי"></asp:Label>
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtUserFirstNameSearch" runat="server" Width="175px"></asp:TextBox>
                                                </td>
                                                 <td style="padding-right: 10px; padding-left: 5px;" align="left">
                                                    <asp:Label ID="lblUserLastNameSearch" runat="server" Text="שם משפחה"></asp:Label>
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtUserLastNameSearch" runat="server" Width="175px"></asp:TextBox>
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtSelectedUserName" Width="20px" runat="server" EnableTheming="false"
                                                        CssClass="DisplayNone"></asp:TextBox>
                                                    <asp:TextBox ID="txtUserIDToExpand" Width="20px" runat="server" EnableTheming="false"
                                                        CssClass="DisplayNone"></asp:TextBox>
                                                    <asp:TextBox ID="txtUserIDToCollaps" Width="20px" runat="server" EnableTheming="false"
                                                        CssClass="DisplayNone"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="6">
                                                    <table>
                                                        <tr>
                                                            <td style="padding-right: 0px; padding-top: 5px; width:235px" align="right" valign="middle" >
                                                                <asp:Label ID="lblReportRemarksChange" runat="server" Text="הודעה על הוספת הערה ליחידה"></asp:Label>
                                                                <asp:DropDownList Width="50px" ID="ddlReportRemarksChange" runat="server">
                                                                    <asp:ListItem Text="הכל" Value="-1"></asp:ListItem>
                                                                    <asp:ListItem Text="כן" Value="1"></asp:ListItem>
                                                                    <asp:ListItem Text="לא" Value="0"></asp:ListItem>
                                                                </asp:DropDownList>
                                                            </td>

                                                            <td style="padding-right: 15px; padding-top: 5px; width:175px" align="left" valign="middle" >
                                                                <asp:Label ID="lblUserIsInDomain" runat="server" Text="משתמש מוגדר בAD"></asp:Label>
                                                                <asp:DropDownList Width="50px" ID="ddlUserIsInDomain" runat="server">
                                                                    <asp:ListItem Text="הכל" Value="-1"></asp:ListItem>
                                                                    <asp:ListItem Text="כן" Value="1"></asp:ListItem>
                                                                    <asp:ListItem Text="לא" Value="0"></asp:ListItem>
                                                                </asp:DropDownList>
                                                            </td>
                                                            <td style="padding-right: 15px; padding-top: 5px; width:175px" align="left" >
                                                                <asp:Label ID="lblReportErrors" runat="server" Text="דיוח פרטים שגוים"></asp:Label>


                                                                <asp:DropDownList Width="50px" ID="ddlReportErrors" runat="server">
                                                                    <asp:ListItem Text="הכל" Value="-1"></asp:ListItem>
                                                                    <asp:ListItem Text="כן" Value="1"></asp:ListItem>
                                                                    <asp:ListItem Text="לא" Value="0"></asp:ListItem>
                                                                </asp:DropDownList>
                                                            </td>
                                                            <td style="padding-right: 15px; padding-top: 5px; width:185px" align="left">
                                                                <asp:Label ID="lblTrackingNewClinic" runat="server" Text="הודעה על פתיחת יחידה"></asp:Label>
                                                                <asp:DropDownList Width="50px" ID="ddlTrackingNewClinic" runat="server">
                                                                    <asp:ListItem Text="הכל" Value="-1"></asp:ListItem>
                                                                    <asp:ListItem Text="כן" Value="1"></asp:ListItem>
                                                                    <asp:ListItem Text="לא" Value="0"></asp:ListItem>
                                                                </asp:DropDownList>
                                                            </td>
                                                        </tr>

                                                    </table>

                                                </td>

                                                <td style="padding-right: 65px;">
                                                    <table cellpadding="0" cellspacing="0">
                                                    <tr>
                                                        <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                            background-position: bottom left;">
                                                            &nbsp;
                                                        </td>
                                                        <td align="center" style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                            background-repeat: repeat-x; background-position: bottom;">
                                                            <asp:Button runat="server" ID="bExportToExcel" Text="ייצוא לאקסל" CssClass="RegularUpdateButton" OnClick="bExportToExcel_Click" CausesValidation="false" />
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
                            <tr style="height: 8px">
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
                    </td>
                </tr>
            </table>
    <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Conditional" runat="server" >
        <ContentTemplate>

            <table cellpadding="0" cellspacing="0" border="0" dir="rtl">
                <tr>
                    <td valign="top" style="padding-right: 8px; padding-top: 8px">
                        <!-- users list -->
                        <table cellpadding="0" cellspacing="0" border="0" style="background-color: #F7F7F7">
                            <tr>
                                <td style="height: 8px; background-image: url('../Images/Applic/RTcornerGrey10.gif');
                                    background-repeat: no-repeat; background-position: top right">
                                </td>
                                <td style="background-image: url('../Images/Applic/borderGreyH.jpg'); background-repeat: repeat-x;
                                    background-position: top">
                                </td>
                                <td style="background-image: url('../Images/Applic/LTcornerGrey10.gif'); background-repeat: no-repeat;
                                    background-position: top left">
                                </td>
                            </tr>
                            <tr>
                                <td style="border-right: solid 2px #909090;">
                                    <div style="width: 6px;">
                                    </div>
                                </td>
                                <td align="right">
                                    <table cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td style="padding-right: 5px; padding-bottom: 5px; border-bottom: solid 1px #BEBCB7;">
                                                <table cellpadding="0" cellspacing="0" width="100%">
                                                    <tr>
                                                        <td style="padding-right: 15px">
                                                            <asp:Label ID="lblUsersListCap" runat="server" EnableTheming="false" CssClass="LabelCaptionBlueBold_14"
                                                                Text="רשימת משתמשים"></asp:Label>
                                                        </td>
                                                        <td style="padding-left: 4px" align="left">
                                                            <table cellpadding="0" cellspacing="0">
                                                                <tr>
                                                                    <td style="background-image: url(../Images/Applic/regButtonBG_Right.gif); background-repeat: no-repeat;
                                                                        background-position: bottom left;">
                                                                        &nbsp;
                                                                    </td>
                                                                    <td style="vertical-align: bottom; background-image: url(../Images/Applic/regButtonBG_Middle.gif);
                                                                        background-repeat: repeat-x; background-position: bottom;">
                                                                        <asp:Button ID="btnAddUser" runat="server" Text="הוספת משתמש" CssClass="RegularUpdateButton"
                                                                            OnClientClick="OpenUpdateUser(0,'','',0); return false;" ValidationGroup="grSearchParameters"></asp:Button>
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
                                        <tr>
                                            <td style="height: 10px;">
                                                <table cellpadding="0" cellspacing="0">
                                                    <tr>
                                                        <td style="width: 45px">
                                                            &nbsp;
                                                        </td>
                                                        <td style="width: 130px">
                                                            <asp:Label ID="lblUserNameCap" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                                runat="server" Text="שם משתמש"></asp:Label>
                                                        </td>
                                                        <td style="width: 75px">
                                                            <asp:Label ID="lblUserIDCap" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                                runat="server" Text="תעודת זהות"></asp:Label>
                                                        </td>
                                                        <td style="width: 140px" align="right">
                                                            <asp:Label ID="lblUserDetailsCap" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                                runat="server" Text="פרטי משתמש"></asp:Label>
                                                        </td>
                                                        <td style="width: 80px" align="right">
                                                            <asp:Label ID="lblPhoneNumberCap" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                                runat="server" Text="טלפון"></asp:Label>
                                                        </td>
                                                        <td style="width: 135px" align="right">
                                                            <asp:Label ID="lblEmailCap" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                                runat="server" Text="email"></asp:Label>
                                                        </td>
                                                        <td style="width: 80px" align="right">
                                                            <asp:Label ID="lblUserDescriptionCap" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                                runat="server" Text="פרטים נוספים"></asp:Label>
                                                        </td>
                                                        <td style="width: 120px" align="right">
                                                            <asp:Label ID="lblMaxUpdateDate" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                                runat="server" Text="התאריך האחרון שבו המשתמש עדכן פריט כלשהו בספר השירות"></asp:Label>
                                                        </td>
                                                        <td style="width: 45px" align="right">
                                                            <asp:Label ID="lblDefinedInADCap" EnableTheming="false" CssClass="LabelBoldDirtyBlue"
                                                                runat="server" Text="מוגדר בAD"></asp:Label>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td dir="ltr" style="border-top: solid 1px #BEBCB7;">
                                                <div id="pnlGvUsers" runat="server" style="height: 400px; width: 958px; overflow-y: scroll"
                                                    class="ScrollBarDiv" onscroll="GetDivScrollPosition()">
                                                    <div dir="rtl">
                                                        <asp:GridView Width="930px" ID="gvUsers" runat="server" AllowSorting="True" HeaderStyle-CssClass="DisplayNone"
                                                            AutoGenerateColumns="False" DataKeyNames="UserName"
                                                            OnDataBound="gvUsers_DataBound" SkinID="GridViewForSearchResults" 
                                                            onrowdatabound="gvUsers_RowDataBound">
                                                            <Columns>
                                                                <asp:TemplateField>
                                                                    <ItemTemplate>
                                                                        <table cellpadding="0" cellspacing="0" style="cursor: pointer" onclick="SelectUser('<%# Eval("UserID")%>')" >
                                                                            <tr>
                                                                                <td style="width: 25px" align="center">
                                                                                    <asp:ImageButton ID="btnPlus" runat="server" Mode="Expand" UserID='<%# Eval("UserID")%>'
                                                                                        OnClick="btnPlus_Click" ImageUrl="~/Images/Applic/btn_Plus_Blue_12.gif" />
                                                                                    <asp:ImageButton ID="btnMinus" runat="server" Mode="Collapse" UserID='<%# Eval("UserID")%>'
                                                                                        OnClick="btnMinus_Click" Visible="false" ImageUrl="~/Images/Applic/btn_Minus_Blue_12.gif" />
                                                                                </td>
                                                                                <td style="width: 140px;">
                                                                                    <asp:Label ID="lblUserName" runat="server" Text='<%#Bind("UserName") %>'></asp:Label>
                                                                                </td>
                                                                                <td style="width: 75px">
                                                                                    <asp:Label ID="lblUserID" runat="server" Text='<%#Bind("UserID") %>'></asp:Label>
                                                                                </td>
                                                                                <td style="width: 130px">
                                                                                    <asp:Label ID="lblUserDetails" EnableTheming="false" CssClass="RegularLabelNormal"
                                                                                        runat="server" Text='<%#Bind("UserDetails") %>'></asp:Label>
                                                                                </td>
                                                                                <td style="width: 80px">
                                                                                    <asp:Label ID="lblPhoneNumber" EnableTheming="false" CssClass="RegularLabelNormal"
                                                                                        runat="server" Text='<%#Bind("PhoneNumber") %>'></asp:Label>
                                                                                </td>
                                                                                <td style="width: 140px">
                                                                                    <asp:Label ID="lblEmail" EnableTheming="false" CssClass="RegularLabelNormal"
                                                                                        runat="server" Text='<%#Bind("Email") %>'></asp:Label>
                                                                                </td>
                                                                                <td style="width: 80px">
                                                                                    <asp:Label ID="lblUserDescription" EnableTheming="false" CssClass="RegularLabelNormal"
                                                                                        runat="server" Text='<%#Bind("UserDescription") %>'></asp:Label>
                                                                                </td>
                                                                                <td style="width: 100px">
                                                                                    <asp:Label ID="lblMaxUpdateDate" EnableTheming="false" CssClass="RegularLabelNormal"
                                                                                        runat="server" Text='<%#Bind("MaxUpdateDate") %>'></asp:Label>
                                                                                </td>
                                                                                <td style="width: 45px" align="center">
                                                                                    <asp:Label ID="lblDefinedInAD_text" EnableTheming="false" CssClass="RegularLabelNormal"
                                                                                        runat="server" Text='<%#Bind("DefinedInAD_text") %>'></asp:Label>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td id="tdUserPermissions" runat="server" colspan="10" style="padding-right:9px;">
                                                                                    <asp:GridView BorderColor="Gray" BorderStyle="Solid" BorderWidth="1px" ID="gvUserPermissions" runat="server" 
                                                                                        AutoGenerateColumns="false" SkinID="GridViewForSearchResults">
                                                                                        <HeaderStyle BackColor="White" HorizontalAlign="Right" />
                                                                                        <Columns>
                                                                                            <asp:BoundField HeaderStyle-CssClass="LabelBoldDirtyBlue" HeaderStyle-Width="90px" HeaderText="סוג הרשאה" DataField="permissionDescription" />
                                                                                            <asp:BoundField HeaderStyle-CssClass="LabelBoldDirtyBlue" HeaderStyle-Width="60px" HeaderText="קוד יחידה" DataField="deptCode" />
                                                                                            <asp:BoundField HeaderStyle-CssClass="LabelBoldDirtyBlue" HeaderStyle-Width="250px" HeaderText="שם יחידה" DataField="deptName" />
                                                                                            <asp:BoundField HeaderStyle-CssClass="LabelBoldDirtyBlue" HeaderStyle-Width="110px" HeaderText="דיווח פרטים שגויים" DataField="ErrorReport" />  
                                                                                            <asp:BoundField HeaderStyle-CssClass="LabelBoldDirtyBlue" HeaderStyle-Width="130px" HeaderText="הודעה על פתיחת יחידה" DataField="TrackingNewClinic" />
                                                                                            <asp:BoundField HeaderStyle-CssClass="LabelBoldDirtyBlue" HeaderStyle-Width="170px" HeaderText="הודעה על הוספת הערה ליחידה" DataField="TrackingRemarkChanges" />                                                                                   
                                                                                        </Columns>
                                                                                    </asp:GridView>
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField ItemStyle-Width="55px" ItemStyle-VerticalAlign="Top" ItemStyle-HorizontalAlign="Center">
                                                                    <ItemTemplate>
                                                                        <asp:ImageButton ID="btnUpdateUser" runat="server" ImageUrl="../Images/btn_edit.gif" ToolTip="עדכון" />
                                                                        <asp:Label ID="lblDefinedInAD" runat="server" Text='<%# Eval("DefinedInAD")%>' EnableTheming="false" CssClass="DisplayNone"></asp:Label>
                                                                        <asp:Label ID="lblDomain" runat="server" Text='<%# Eval("Domain")%>' EnableTheming="false" CssClass="DisplayNone"></asp:Label>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:TemplateField ItemStyle-Width="25px" ItemStyle-VerticalAlign="Top" ItemStyle-HorizontalAlign="Center">
                                                                    <ItemTemplate>
                                                                        <asp:ImageButton ID="btnDeleteUser" runat="server" ImageUrl="../Images/Applic/btn_X_red.gif"
                                                                            UserID='<%# Eval("UserID")%>' OnClick="btnDeleteUser_Click" ToolTip="מחיקה"
                                                                            OnClientClick="return confirm('?האם הנך בטוח שברצונך למחוק את המשתמש')"></asp:ImageButton>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                            </Columns>
                                                            <SelectedRowStyle BackColor="#9FD5F9" />
                                                        </asp:GridView>
                                                    </div>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>
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
                    </td>
                </tr>
            </table>
            <asp:Button ID="btnDoPostBack" runat="server" CssClass="DisplayNone" />
            <asp:HiddenField ID="hdnDeptCode" runat="server" />
            <asp:HiddenField ID="hdnMinheletValue" runat="server" />
        </ContentTemplate>
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="btnSearch" EventName="Click" />
            <asp:PostBackTrigger ControlID="bExportToExcel" />
        </Triggers>
        
    </asp:UpdatePanel>
    
</asp:Content>
