<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="Admin_SubUnitTypesDictionaryPopUp" Codebehind="SubUnitTypesDictionaryPopUp.aspx.cs" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<%@ Register Assembly="System.Web.Extensions, Version=3.5.0.0, Culture=neutral, PublicKeyToken=31BF3856AD364E35"
    Namespace="System.Web.UI" TagPrefix="asp" %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="-1" />
    <title>שיוכים</title>
    <link rel="STYLESHEET" href="../CSS/General/general.css" type="text/css" />
    <link rel="STYLESHEET" href="../CSS/General/StyleGuide.css" type="text/css" />
    <link rel="SHORTCUT ICON" type="image/x-icon" href="../Images/Applic/favicon.ico" />
    <style type="text/css">
        .style1
        {
            width: 146px;
        }
    </style>

    <script type="text/javascript" src="../Scripts/LoadJqueryIfNeeded.js"></script>

    <script language="javascript" type="text/javascript">
        function GetSelectedValues() {

            var checkboxes = $('input:checkbox[id*=chkSybUnitTypes_]');
            var selectedSubUnitTypeName = null;
            var selectedSubUnitTypeID = "";
            for (i = 0; i < checkboxes.length; i++) {

                if (checkboxes[i].checked) {

                    var id = checkboxes[i].id;

                    var indx = id.indexOf("_");
                    if (indx > 0) {
                        indx++

                        selectedSubUnitTypeID += id.substring(indx, id.length) + ",";
                    }
                    var selectedSubUnitTypeName = checkboxes[i].nextSibling.innerHTML;
                }
            }


            var parentUnitTypeCode = '<%=_parentUnitTypeCode %>';
            var userName = '<%=getUserName()%>';
            if (parentUnitTypeCode != null && userName != null) {
                PageMethods.InsertNewSubUnitTypeCodes(selectedSubUnitTypeID, parentUnitTypeCode, userName);
            }

            self.close();

        }
    </script>

</head>
<body style="background-color: White">
    <form id="form1" runat="server">
    <div>
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="True">
        </asp:ScriptManager>
        <asp:UpdatePanel runat="server" ID="UpdatePanel1">
            <ContentTemplate>
                <table style="width: 300px; margin-right: 20px" align="right">
                    <tr>
                        <td class="style1">
                            &nbsp;
                        </td>
                        <td align="right">
                            <asp:Label ID="lblTitle" runat="server" EnableTheming="false" Text="שיוכים" CssClass="LabelCaptionGreenBold_18"></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td align="right" colspan="2">
                            <asp:Label ID="lblChoice" CssClass="LabelCaptionGreenBold_12" EnableTheming="false"
                                runat="server" Text=": נא לבחור את השיוך" meta:resourcekey="lblChoiceResource1"></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td align="right" colspan="2">
                            <asp:CheckBoxList ID="chkSybUnitTypes" RepeatDirection="Vertical" RepeatLayout="Flow"
                                dir="rtl" runat="server" DataSourceID="SqlDataSource1" 
                                EnableTheming="false" CssClass="CheckBoxListFlat_15"
                                Width="100%" DataTextField="subUnitTypeName" DataValueField="subUnitTypeCode"
                                OnDataBound="chkSybUnitTypes_DataBound" OnPreRender="chkSybUnitTypes_PreRender">
                            </asp:CheckBoxList>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                        </td>
                    </tr>
                    <tr>
                        <td align="right" style="margin-top: 5px">
                            <table cellpadding="0" cellspacing="0" border="0px" style="padding-right: 7px;">
                                <tr align="right">
                                    <td class="buttonLeftCorner">
                                    </td>
                                    <td class="buttonCenterBackground" style="width: 40px">
                                        <asp:Button ID="btnCancel" runat="server" Text="ביטול" OnClientClick="javascript:window.close()"
                                            CssClass="RegularUpdateButton" />
                                    </td>
                                    <td class="buttonRightCorner">
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td align="right">
                            <table cellpadding="0" cellspacing="0" border="0px">
                                <tr align="right">
                                    <td class="buttonLeftCorner" style="width: 2px; margin-right: 3px; margin-left: 3px;
                                        padding-left: 5px; padding-right: 5px;">
                                    </td>
                                    <td class="buttonCenterBackground" style="width: 40px">
                                        <asp:Button ID="btnSelect" runat="server" Text="שמור" OnClientClick="javascript:GetSelectedValues();"
                                            CssClass="RegularUpdateButton" />
                                    </td>
                                    <td class="buttonRightCorner" style="width: 2px; margin-right: 5px; margin-left: 5px;
                                        padding-left: 5px; padding-right: 5px;">
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
                <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:SeferNetConnectionStringNew %>"
                    SelectCommand="rpc_getSubUnitTypes" SelectCommandType="StoredProcedure" OnSelecting="SqlDataSource1_Selecting">
                    <SelectParameters>
                        <asp:Parameter Name="UnitTypeCode" Type="Int32" />
                    </SelectParameters>
                </asp:SqlDataSource>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>
    </form>
</body>
</html>
