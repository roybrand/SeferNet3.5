<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ServicesControl.ascx.cs" Inherits="SeferNet.UI.Apps.UserControls.ServicesControl" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
    <script type="text/javascript">
        var txtProfessionListCodesClientID = '<%=txtProfessionListCodes.ClientID %>';
        var txtProfessionListClientID = '<%=txtProfessionList.ClientID %>';
    </script>

    <script type="text/javascript">
        //function SelectServicesAndEvents_OLD() {
        //    alert("SelectServicesAndEvents");

        //    var url = "../Public/SelectPopUp.aspx";

        //    var txtProfessionListCodes = document.getElementById(txtProfessionListCodesClientID);
        //    var txtProfessionList = document.getElementById(txtProfessionListClientID);
        //    var selectedCodes = txtProfessionListCodes.value;
        //    var SelectedProfessionList = txtProfessionListCodes.value;
        //    url = url + "?SelectedValuesList=" + SelectedProfessionList;
        //    url = url + "&popupType=12";
        //    url += "&AgreementTypes=Community";
        //    url += "&isInCommunity=true";
        //    url += "&returnValuesTo='txtProfessionListCodes'";
        //    url += "&returnTextTo='txtProfessionList'";

        //    var dialogWidth = 420;
        //    var dialogHeight = 660;
        //    var title = "בחר שירות או פעילות";
        //    alert("Before OpenJQueryDialog");
        //    //return false;
        //    OpenJQueryDialog(url, dialogWidth, dialogHeight, title);

        //    return false;
        //}
    </script>
<div>
    <div style="float:right">
        <asp:TextBox ID="txtProfessionList" ReadOnly="false" 
            runat="server" Width="150px" TextMode="MultiLine"
            Height="20px" CssClass="TextBoxMultiLine" EnableTheming="false"></asp:TextBox>
    </div>
    <div style="float:right">
        <%--<img src="../Images/Applic/icon_magnify.gif" onclick="javascript:SelectServicesAndEvents_3();"/>--%>
        <%--<input type="image" id="btnServicePopUp" style="cursor: pointer;" src="../Images/Applic/icon_magnify.gif" onclick="SelectServicesAndEvents_ForRemark(); return false;" />--%>
        <%--<input type="image" id="btnServicePopUp" runat="server" style="cursor: pointer;" src="../Images/Applic/icon_magnify.gif" onclick="SelectServicesAndEvents_ForRemark('<%=txtProfessionListCodes.ClientID %>'); return false;" />--%>
        <%--<asp:ImageButton ID="btnServicePopUp" runat="server" ImageUrl="../Images/Applic/icon_magnify.gif" OnClientClick="SelectServicesAndEvents_ForRemark('40,2');return false;" ></asp:ImageButton>--%>
        <asp:ImageButton ID="btnServicePopUp" runat="server" ImageUrl="../Images/Applic/icon_magnify.gif" ></asp:ImageButton>
    </div>
    <div style="float:right">
        <asp:TextBox ID="txtProfessionListCodes" runat="server" TextMode="multiLine" EnableTheming="false"
            CssClass="TextBoxMultiLine"></asp:TextBox>
    </div>

</div>