<%@ Page Language="C#"   EnableViewState="false" AutoEventWireup="true" Inherits="SelectGeneralRemarkPopUp" Codebehind="SelectGeneralRemarkPopUp.aspx.cs" %>


<html>
<head runat=server>
<script language="JavaScript" src="../Scripts/Applic/PopupSearch.js" type="text/javascript"></script>
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="-1" />

<title>בחר הערה</title>
<script>
       
		function ReturnSelectedValue(remarkContent)
		{	
            //var selectedRemarkContent = remarkContent.replace( / #/g," <a href='javascript:handleParameter()'> #");
            //selectedRemarkContent = selectedRemarkContent.replace(/# /g,"# </a> ");
            // parameterHendlerReference - opener's JS function which handles parameters. By default - "handleParameter()"

            var parameterHendlerReference = <%=Request.QueryString["parameterHendlerReference"].ToString() %>;

            var selectedRemarkContent = remarkContent.replace( / #/g," <span class=LooksLikeHRef onClick='javascript:" + parameterHendlerReference + "'> #");

//            var selectedRemarkContent = remarkContent.replace( / #/g," <span class=LooksLikeHRef onClick='javascript:handleParameter()'> #");

            selectedRemarkContent = selectedRemarkContent.replace(/# /g,"# </span> ");
                
            //var lblRemark = window.opener.document.getElementById("ctl00_pageContent_dvRemarkInfo_lblSelectedRemark");		   
            //		   var text = <%=Request.QueryString["linkedTo"].ToString() %>;
            var lblID = <%=Request.QueryString["lblSelectedRemark"].ToString() %>;
            //		   alert(lblID);
            var lblRemark = window.opener.document.getElementById(lblID);
            //		   alert(lblRemark);
            lblRemark.innerHTML = selectedRemarkContent;
            self.close();
		}
    
</script>

</head>
<body dir=rtl>
    <form id="form1" runat="server">       
         <table width=500px cellpadding=0 cellspacing=0>
        <tr>
            <td id="tdMainHeader" runat=server colspan=2 align=right>
            </td>
		</tr>
		</table>
		<table width=500px cellpadding=0 cellspacing=0>
            <tr>
                <td>
                    <asp:Panel runat=server ID="pnlList"   Height="300px" ScrollBars=Auto>
                        <asp:DataList    CellPadding=0 CellSpacing=0 GridLines=Horizontal   Width="97%" id="dlPopup" runat=server 
                        DataSourceID="dsGeneralRemarks" CssClass="DataListBlue">
                            <ItemTemplate>
                                    <a  style="text-decoration:none;color:#316AC5;"
                                    href='javascript:ReturnSelectedValue("<%#Eval("remark")%>")'  
                                    onMouseOver="MouseOverItem()"
                                    onMouseOut="MouseOutItem()"
                                    ><div style="width:100%;height:100%;cursor:hand;text-decoration:none">&nbsp;&nbsp;&nbsp;<%# Eval("remark")%></div></a>
                                        
                                      
                            </ItemTemplate> 
             
                            <ItemStyle CssClass="DataListItem" BorderColor="#ECE9D8" Height="20px" />
                        </asp:DataList>
                    </asp:Panel>
                </td>
            </tr>
         </table>
         <asp:SqlDataSource ID="dsGeneralRemarks" 
                runat="server" 
                SelectCommandType=StoredProcedure
                SelectCommand="rpc_getDeptRemarksForPopUpSelection" OnSelecting="dsGeneralRemarks_Selecting">
            <SelectParameters>
                <asp:Parameter Name="LinkedToDept" ConvertEmptyStringToNull=true Type=Byte />
                <asp:Parameter Name="LinkedToDoctor" ConvertEmptyStringToNull=true Type="Byte" />
                <asp:Parameter Name="LinkedToDoctorInClinic" ConvertEmptyStringToNull=true  Type="Byte" />
                <asp:Parameter Name="LinkedToServiceInClinic" ConvertEmptyStringToNull=true  Type="Byte" />
                <asp:Parameter Name="LinkedToReceptionHours" ConvertEmptyStringToNull=true  Type="Byte" />
                <asp:Parameter Name="EnableOverlappingHours" ConvertEmptyStringToNull=true  Type="Byte" />
            </SelectParameters>   
        </asp:SqlDataSource>
</form>
</body>
</html>
