<%@ Control Language="C#" AutoEventWireup="true" Inherits="UserControls_GridUnitTypes" Codebehind="GridUnitTypes.ascx.cs" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagPrefix="uc1" TagName="SortableColumnHeader" Src="~/UserControls/SortableColumnHeader.ascx" %>
<link href="../CSS/General/general.css" type="text/css" rel="STYLESHEET" />

<script type="text/javascript" src="../Scripts/LoadJqueryIfNeeded.js"></script>

<script type="text/javascript">

    function GetScrollPosition(obj) {
        $("#<%=hfScrollTop.ClientID %>").val(obj.scrollTop);
    }

    function CreateExcelReport() {
        var url = "../Reports/Reports_CreateExcel.aspx?ReportForUpdatePages=1";
        window.open(url, "CreateExcel", "height=800, width=1000, top=50, left=100");
        return false;
    }
</script>

<div class="roundFrame">
    <div class="rightCornerTop"></div>
    <div class="frameTop" style="width:960px;"></div>
    <div class="leftCornerTop"></div>
    
    <div class="frameMiddle" style="height:28px;">
        <span class="RegularLabel" style="float:right;margin-top:5px;margin-right:10px;">תיאור</span>
        <asp:TextBox ID="txtDescription" runat="server" CssClass="TextBoxRegular" style="margin-right:5px;margin-top:4px;float:right;"></asp:TextBox>
        <span class="RegularLabel" style="float:right;margin-top:5px;margin-right:20px;">קוד</span>
        <asp:TextBox ID="txtSearchCode" Width="40px" runat="server" CssClass="TextBoxRegular" style="margin-right:5px;margin-top:4px;float:right;"></asp:TextBox>
        <span class="RegularLabel" style="float:right;margin-top:5px;margin-right:20px;">שיוכים</span>
        <asp:TextBox ID="txtBelong" runat="server" CssClass="TextBoxRegular" style="margin-right:5px;margin-top:4px;float:right;"></asp:TextBox>
        <span class="RegularLabel" style="float:right;margin-top:5px;margin-right:20px;">קטגוריה</span>
        <asp:TextBox ID="txtCategory" runat="server" CssClass="TextBoxRegular" style="margin-right:5px;margin-top:4px;float:right;"></asp:TextBox>

        <div style="margin-right:20px;margin-top:4px;float:right;height:20px;width:50px;">
            <div class="button_RightCorner"></div>
            <div class="button_CenterBackground"><asp:Button ID="btnSearch" runat="server" 
                    Text="חיפוש" CssClass="RegularUpdateButton" onclick="btnSearch_Click" /></div>
            <div class="button_LeftCorner"></div>
        </div>
        <div style="float:right;margin-right:10px;margin-top:5px;">
            <a href="#TB_inline?s=1&width=270&height=310&inlineId=hiddenModalContent&modal=true" class="thickbox">
                <img style="border:none;" src="../Images/btn_add.gif" />
                
            </a>
        </div>
    </div>

    <div class="rightCornerBottom"></div>
    <div class="frameBottom" style="width:960px;"></div>
    <div class="leftCornerBottom"></div>
</div>
<div style="height:20px;"></div>

<div class="roundFrame">
    <div class="rightCornerTop"></div>
    <div class="frameTop" style="width:960px"></div>
    <div class="leftCornerTop"></div>

    <div class="frameMiddle">
    <div style="height:30px; padding-right:10px">
        <asp:Label ID="lblTitle" runat="server" Text="רשימת סוגי יחידות" EnableTheming="false" CssClass="RegularUpdateButton"></asp:Label>
        <div style="width:125px; float:left" >
            <asp:ImageButton ID="imgCreateExcelReport" runat="server" ImageUrl="~/Images/Applic/Excel_Button.png" CausesValidation="False" OnClick="imgCreateExcelReport_Click"  />
        </div>

</div>

        
        <div style="float:right;width:55px;margin-right:30px;">
            <uc1:SortableColumnHeader ID="columnCode" runat="server" OnSortClick="btnSort_click"
                  Text="קוד" ColumnIdentifier="PositionCode"/>
        </div>
        <div style="float:right;width:110px;">
            <uc1:SortableColumnHeader ID="בolumnName" runat="server" OnSortClick="btnSort_click"
                  Text="תיאור" ColumnIdentifier="Name"/>
        </div>
        <div style="float:right;width:130px;">
            <uc1:SortableColumnHeader ID="columnShowInInternet" runat="server" OnSortClick="btnSort_click"
                  Text="תצוגה באינטרנט" ColumnIdentifier="ShowInInternet"/>
        </div>
        <div style="float:right;width:95px;">
            <uc1:SortableColumnHeader ID="columnQueueOrder" runat="server" OnSortClick="btnSort_click"
                  Text="אופן הזימון" ColumnIdentifier="QueueOrder"/>
        </div>
        <div class="ColumnHeader" style="float:right;width:60px;margin-top:2px;">פעיל</div>
        <div class="ColumnHeader" style="float:right;width:160px;margin-top:2px;">שיוך ברירת מחדל</div>
        <div class="ColumnHeader" style="float:right;width:135px;margin-top:2px;">שיוכים</div>
        <div class="ColumnHeader" style="float:right;width:120px;margin-top:2px;">קטגוריה</div>
    
        <div style="background-color: #bebcb7;height:1px;font-size:1px;width:937px;margin-right:10px;margin-top:2px;margin-bottom:5px;"></div>
    
        <div id="divMainGrid" onscroll="GetScrollPosition(this);" style="overflow-x:hidden;overflow-y:scroll;height:430px;width:940px;margin-right:10px;direction:ltr;">
        <div style="direction:rtl;">
        <asp:GridView ID="GridView1" SkinID="GridViewForSearchResults" AutoGenerateColumns="false" runat="server" 
            OnRowDataBound="GridView1_RowDataBound"
             ShowHeader="false">
            <Columns>
               
        
                <%-- קוד  --%>        
                <asp:TemplateField>
                    <ItemTemplate>
                        <div style="margin-right:5px;"> 
                        <asp:Label runat="server" ID="lblCode" Text='<%# Eval("UnitTypeCode") %>'></asp:Label>
                        </div>
                    </ItemTemplate>
                    <ItemStyle Width="55px"></ItemStyle>
                </asp:TemplateField>
        
                <%--  תאור --%>
                  
                
                <asp:TemplateField>
                    <ItemTemplate>
                        <asp:Label runat="server" ID="lblName" Text='<%# Eval("UnitTypeName") %>'></asp:Label>
                    </ItemTemplate>
                    
                    <ItemStyle Width="140px"></ItemStyle>
                </asp:TemplateField>
        
                
        
                <%--  show on internet--%>                
                <asp:TemplateField>
                    <ItemTemplate>
                        <asp:CheckBox ID="chkBxShowInInternet" Enabled="false" runat="server" />
                    </ItemTemplate>
                    <ItemStyle Width="120px" />
                    
                </asp:TemplateField>
        
                <%--  queue order --%>
                <asp:TemplateField>
                    <ItemTemplate>
                        <asp:CheckBox ID="chkBxAllowQueueOrder" Enabled="false" runat="server" />
                    </ItemTemplate>
                    <ItemStyle Width="70px" />
                    
                </asp:TemplateField>
        
                
        
                <%-- is active --%>                
                <asp:TemplateField>
                    <ItemTemplate>
                        <asp:CheckBox ID="chkIsActive" runat="server" Enabled="false" />
                    </ItemTemplate>
                    <ItemStyle Width="60px" />
                    
                </asp:TemplateField>
        
                <%-- default sub unit type --%>
                <asp:TemplateField ItemStyle-Width="150px">
                    <ItemTemplate>
                        <asp:Label ID="lblDefaultSubUnitType" runat="server" Text='<%# Eval("DefaultSubUnit") %>'></asp:Label>
                    </ItemTemplate>
                    
                </asp:TemplateField>
                
                <%-- related --%>
                <asp:TemplateField ItemStyle-Width="140px">
                    <ItemTemplate>
                        <asp:Label ID="lblRelatedSubUnitType" runat="server" Text='<%# Eval("Related") %>'></asp:Label>
                    </ItemTemplate>
                    
                </asp:TemplateField>

                <%-- category --%>
                <asp:TemplateField ItemStyle-Width="125px">
                    <ItemTemplate>
                        <asp:Label ID="lblCategorySubUnitType" runat="server" Text='<%# Eval("CategoryName") %>'></asp:Label>
                    </ItemTemplate>
                    
                </asp:TemplateField>
                
        
                <%-- update/delete --%>        
                <asp:TemplateField>
                    <ItemTemplate>
                        <a href="#TB_inline?s=1&width=270&height=310&inlineId=hiddenModalContent&modal=true" class="thickbox">
                            <asp:ImageButton ID="imgUpdate" runat="server" ImageUrl="~/Images/btn_edit.gif"
                                ToolTip="עדכן סוג יחידה" />
                        </a>
                    </ItemTemplate>
                    <ItemStyle Width="45px" />
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
        </div>
        </div>
    </div>
    <div class="rightCornerBottom"></div>
    <div class="frameBottom" style="width:960px;"></div>
    <div class="leftCornerBottom"></div>
</div>
<asp:HiddenField ID="hdnSortOrder" runat="server" />
<asp:HiddenField ID="hfScrollTop" runat="server" Value="0" />
<asp:SqlDataSource ID="SqlDataSourceSector" runat="server" ConnectionString="<%$ ConnectionStrings:SeferNetConnectionStringNew %>"
    SelectCommand="SELECT [EmployeeSectorCode], [EmployeeSectorDescription] FROM [EmployeeSector] "
    DataSourceMode="DataReader"></asp:SqlDataSource>
<asp:HiddenField ID="hdnRestoreUnitTypes" Value="0" runat="server" />
<script type="text/javascript">
    function initPage() {
        pageLoad();
        $("#divMainGrid").scrollTop($("#<%=hfScrollTop.ClientID %>").val());
    }
    function pageLoad()
    {
        var isAsyncPostback = Sys.WebForms.PageRequestManager.getInstance().get_isInAsyncPostBack();
        if (isAsyncPostback)
        {
            tb_init('a.thickbox, area.thickbox, input.thickbox');
        }
    }

    window.onload = initPage;


</script>