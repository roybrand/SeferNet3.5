<%@ Page Title="" Language="C#" MasterPageFile="~/SeferMasterPageIEwide.Master" AutoEventWireup="true" CodeBehind="Test_with_master.aspx.cs" Inherits="SeferNet.UI.Apps.Tests.Test_with_master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="phHead" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="pageContent" runat="server">
<%--<script type="text/javascript" src="/SeferNet/Scripts/jquery-ui/jquery_inputmask_bundle.js"></script>--%> 
    <script type="text/javascript">    

    </script>

    <div>
        <table>
            <tr>
                <td>'input time'</td>
                <td><input id="time" type="text" style="width:50px" /></td>
            </tr>
            <tr>
                <td>'txtFromHour'</td>
                <td><asp:TextBox ID="txtFromHour" name="txtHour" runat="server" EnableTheming="false" Width="70px" ></asp:TextBox></td>
            </tr>

            <tr>
                <td>'endTime'</td>
                <td><input id="endTime" type="text" style="width:50px" /></td>
            </tr>
            <tr>
                <td>'text box endTime'</td>
                <td><asp:TextBox ID="txtEndTime" runat="server" EnableTheming="false" Width="70px" ></asp:TextBox></td>
            </tr>
        </table>
        
        
        
    </div>
<%--<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.10/jquery.mask.js"></script>--%>
    <script type="text/javascript">
        $("#time").inputmask("hh:mm", {
            placeholder: "__:__",
            insertMode: false,
            showMaskOnHover: false,
            alias: "datetime"//,
        }
        );

        $("#txtFromHour").inputmask("hh:mm", {
            placeholder: "__:__",
            insertMode: false,
            showMaskOnHover: false,
            alias: "datetime"//,
        }
        );


        $('input[id$="endTime"]').inputmask("hh:mm:ss", {
            placeholder: "HH:MM:SS",
            insertMode: false,
            showMaskOnHover: false,
            //hourFormat: 12
        }
        );

        $('input[id$="txtEndTime"]').inputmask("hh:mm", {
            placeholder: "__:__",
            insertMode: false,
            showMaskOnHover: false,
            //hourFormat: 12
        }
        );

</script>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="postBackContent" runat="server">
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="postBackPageContent" runat="server">
</asp:Content>
