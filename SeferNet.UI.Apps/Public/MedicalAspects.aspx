<%@ Page Language="C#" AutoEventWireup="true" Inherits="MedicalAspects" Codebehind="MedicalAspects.aspx.cs" EnableViewState="true" %>
<%@ Register TagPrefix="uc1" TagName="SortableColumnHeader" Src="~/UserControls/SortableColumnHeader.ascx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link type="text/css" rel="Stylesheet" href="~/css/general/general.css" />
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.1/themes/base/jquery-ui.css"/>
    <link rel="stylesheet" href="https://code.jquery.com/resources/demos/style.css"/>

    <script type="text/javascript" src="../Scripts/BrowserVersions.js"></script>
    <script type="text/javascript">
        function guidGenerator() {
            var S4 = function () {
                return (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1);
            };
            return (S4() + S4() + "-" + S4() + "-" + S4() + "-" + S4() + "-" + S4() + S4() + S4());
        }

        function OpenPopup(popupType, deptCode, textControl, hiddenControl) {
            var searchID = guidGenerator();
            //url = "../Admin/GetAllDataPopup.aspx?popupType=" + popupType + "&deptCode=" + deptCode + "&searchID=" + searchID;
            url = "SelectPopUp.aspx?popupType=" + popupType + "&deptCode=" + deptCode + "&searchID=" + searchID;
            url += "&returnValuesTo='txtMedicalAspectsToAdd'"; 
            url += "&returnTextTo='txtMedicalAspectsTextToAdd'";
            url += "&functionToExecute=" + "RefreshParent";

            var dialogWidth = 440;
            var dialogHeight = 670;
            var title = "היבטים למרפאה";

            OpenJQueryDialog(url, dialogWidth, dialogHeight, title);
        }

        function RefreshParent() {
            document.forms[0].submit();
        }

        function RefreshParentAfterDelete() {
             window.parent.document.forms[0].submit();
        }

</script>
</head>
<body>
    <form id="form1" runat="server">
    <div class="BackColorBlue" style="height: 29px;">
        <div style="float: right; margin-top: 5px; margin-right: 3px;">
            <asp:Image ID="imgAttributed_4" runat="server" ToolTip="שירותי בריאות כללית" />
        </div>
        <div style="float: right; margin-right: 10px; margin-top: 3px;">
            <asp:Label ID="lblDeptName" EnableTheming="false" CssClass="LabelBoldWhite_18"
                runat="server" Text=""></asp:Label>
        </div>
        <div style="float: left; margin-top: 4px; margin-left: 2px;" id="divUpdateMedicalaspects"
            runat="server">
            <table cellpadding="0" cellspacing="0" style="direction:rtl;">
                <tr>
                    <td class="buttonRightCorner">
                    </td>
                    <td class="buttonCenterBackground">
                        <asp:Button ID="btnAddMedicalAspects" CssClass="RegularUpdateButton" runat="server"
                        Text="הוספת היבטים רפואיים" Width="140px" onclick="btnAddMedicalAspects_Click" 
                         />
                    </td>
                    <td class="buttonLeftCorner">
                    </td>
                </tr>
            </table>
        </div>
    </div>
    <div>
        <table width="100%" cellpadding="0" cellspacing="0" dir="rtl">
            <tr>
                <td colspan="2" style="padding-right:5px">
                    <asp:Panel ID="pnlServicesHeader" runat="server">
                        <asp:Label ID="lblServiceName" Width="265px" EnableTheming="false" CssClass="LabelCaptionGreenBold_12" runat="server">שם בספר</asp:Label>
                        <asp:Label ID="lblMedicalAspectCode" Width="65px" runat="server" EnableTheming="false" CssClass="LabelCaptionGreenBold_12">קוד היבט</asp:Label>
                        <asp:Label ID="lblMedicalAspectName" Width="270px" runat="server" EnableTheming="false" CssClass="LabelCaptionGreenBold_12">שם היבט</asp:Label>
                        <asp:Label ID="lblClalitServiceCode" Width="65px" runat="server" EnableTheming="false" CssClass="LabelCaptionGreenBold_12">קוד כללית</asp:Label>
                        <asp:Label ID="lblClalitServiceName" Width="260px" EnableTheming="false" CssClass="LabelCaptionGreenBold_12" runat="server">שם כללית</asp:Label>
                    </asp:Panel>
                </td>
            </tr>
            <tr>
                <td colspan="2" style="padding-right:5px">
                    <asp:GridView ID="gvMedicalAspects" runat="server" AutoGenerateColumns="False" EnableTheming="false"
                        Width="980px" ShowHeader="False" GridLines="None" 
                        onrowdatabound="gvMedicalAspects_RowDataBound" >
                        <RowStyle BackColor="#F3F3F3" />
                        <AlternatingRowStyle BackColor="#FEFEFE" />
                        <Columns>
                            <asp:TemplateField ItemStyle-Width="260px">  
                                <ItemTemplate>
                                    <asp:Label ID="lblServiceName" EnableTheming="false" CssClass="RegularLabel" runat="server" Text='<%#Eval("ServiceDescription") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField ItemStyle-Width="65px">  
                                <ItemTemplate>
                                    <asp:Label ID="lblMedicalAspectCode" EnableTheming="false" CssClass="RegularLabel" runat="server" Text='<%#Eval("MedicalAspectCode") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField ItemStyle-Width="265px">  
                                <ItemTemplate>
                                    <asp:Label ID="lblMedicalAspectName" EnableTheming="false" CssClass="RegularLabel" runat="server" Text='<%#Eval("MedicalAspectName") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField ItemStyle-Width="65px">  
                                <ItemTemplate>
                                    <asp:Label ID="lblClalitServiceCode" EnableTheming="false" CssClass="RegularLabel" runat="server" Text='<%#Eval("ClalitServiceCode") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField ItemStyle-Width="260px">  
                                <ItemTemplate>
                                    <asp:Label ID="lblClalitServiceName" EnableTheming="false" CssClass="RegularLabel" runat="server" Text='<%#Eval("ClalitServiceName") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField ItemStyle-Width="25px">  
                                <ItemTemplate>
                                    <asp:ImageButton ID="btnDeleteMedicalAspect" runat="server" ImageUrl="../Images/Applic/btn_X_red.gif"
                                        DeptCode='<%# Eval("DeptCode")%>' MedicalAspectCode='<%# Eval("MedicalAspectCode")%>' 
                                        ToolTip="מחיקה" OnClick="btnDeleteMedicalAspect_Click"
                                        OnClientClick="return confirm('?האם הנך בטוח שברצונך למחוק את היבט במרפאה')">
                                    </asp:ImageButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </td>            
            </tr>
            <tr>
                <td>
                    <asp:TextBox ID="txtMedicalAspectsToAdd" runat="server" EnableTheming="false" ></asp:TextBox>
                    <asp:TextBox ID="txtMedicalAspectsTextToAdd" runat="server" CssClass="DisplayNone" EnableTheming="false" ></asp:TextBox>
                </td>
            </tr>
        </table>
    </div>
    <div id="dialog-modal-select" title="Modal Dialog Select" style="display:none; vertical-align:top; width:100%;">
        <iframe id="modalSelectIFrame" style="width:100%; height:100%; background-color:white;" title="Dialog Title">
    </iframe>
    </div>
    </form>
    <script type="text/javascript" src="https://code.jquery.com/jquery-3.6.0.js"></script>
    <script type="text/javascript" src="https://code.jquery.com/ui/1.13.1/jquery-ui.js"></script>

    <script type="text/javascript">
        function OpenJQueryDialog(url, dialogWidth, dialogHeight, Title) {
            $('#dialog-modal-select').dialog({ autoOpen: false, bgiframe: true, modal: true });
            $('#dialog-modal-select').dialog("option", "width", dialogWidth);
            $('#dialog-modal-select').dialog("option", "height", dialogHeight);
            $('#dialog-modal-select').dialog("option", "title", Title);
            $('#dialog-modal-select').dialog('open');
            $('#dialog-modal-select').parent().appendTo($("form:first"));
            $("#modalSelectIFrame").attr('src', url);

            return false;
        }
    </script>
</body>
</html>
