<%@ Control Language="C#" AutoEventWireup="true"
    Inherits="UserControls_GridTreeViewTableList" Codebehind="GridTreeViewTableList.ascx.cs" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<link href="../CSS/General/general.css" type="text/css" rel="STYLESHEET" />

<script type="text/javascript" src="../Scripts/LoadJqueryIfNeeded.js"></script>

<script language="javascript" type="text/javascript">
    
    function ChooseFile(obj) {

        document.getElementById("fileUpload").click();
        var txt = $('#' + obj.id).closest('table').closest('tr').find("input:text[id$='txtChosenFile']");
        txt.val(document.getElementById("fileUpload").value);
    }   
</script>

<asp:GridView ID="GridView1" SkinID="GridViewTree" runat="server" OnRowCreated="GridView1_RowCreated"
    OnRowDataBound="GridView1_RowDataBound" OnRowCommand="GridView1_RowCommand" OnSorting="GridView1_Sorting"
    OnRowEditing="GridView1_Editing" OnRowUpdating="GridView1_Updating">
    <Columns>
        <%-- אב --%>
        <asp:TemplateField HeaderText="אב" SortExpression="Root">
            <ItemTemplate>
                <asp:ImageButton ID="btnPlus" runat="server" Visible="False" Height="16px" CommandName="_Show"
                    ImageUrl="~/Images/Applic/btn_Plus_Blue_12.gif" />
                <asp:ImageButton ID="btnMinus" runat="server" Height="16px" CommandName="_Hide" ImageUrl="~/Images/Applic/btn_Minus_Blue_12.gif" />
            </ItemTemplate>
            <ItemStyle Width="45px"></ItemStyle>
        </asp:TemplateField>
        
        <%-- קוד אב --%>
        <asp:TemplateField Visible="false" HeaderText="קוד הבא">
            <ItemTemplate>
                <asp:Label runat="server" ID="lblParentCode" Text='<%# Eval("ParentCode") %>'></asp:Label>
            </ItemTemplate>
        </asp:TemplateField>
        
        <%-- קוד בן --%>        
        <asp:TemplateField Visible="false" HeaderText="קוד הבן">
            <ItemTemplate>
                <asp:Label runat="server" ID="lblChildCode" Text='<%# Eval("ChildCode") %>'></asp:Label>
            </ItemTemplate>
        </asp:TemplateField>
        
        <%-- group by parent --%>        
        <asp:TemplateField Visible="false" HeaderText="GroupByParent">
            <ItemTemplate>
                <asp:Label runat="server" ID="lblGroupByParent" Text='<%# Eval("GroupByParent") %>'></asp:Label>
            </ItemTemplate>
        </asp:TemplateField>
        
        <%-- מין --%>        
        <asp:TemplateField Visible="false" HeaderText="Sex">
            <ItemTemplate>
                <asp:Label runat="server" ID="lblSex" Text='<%# Eval("Sex") %>'></asp:Label>
            </ItemTemplate>
        </asp:TemplateField>
        
        <%-- קוד  --%>        
        <asp:TemplateField SortExpression="Code" HeaderText="קוד">
            <ItemTemplate>
                <asp:Label runat="server" ID="lblCode" Text='<%# Eval("Code") %>'></asp:Label>
            </ItemTemplate>
        </asp:TemplateField>
        
        <%--  תאור --%>        
        <asp:TemplateField HeaderText="תאור" SortExpression="Name">
            <ItemTemplate>
                <asp:Label runat="server" ID="lblName" Text='<%# Eval("Name") %>'></asp:Label>
            </ItemTemplate>
            <EditItemTemplate>
                <asp:TextBox ID="txtName" runat="server" Text='<%# Eval("Name") %>' Width="300px"></asp:TextBox>
                <asp:RequiredFieldValidator runat="server" ID="RFV_Name" Text="*" ControlToValidate="txtName"
                    ValidationGroup="ctrl" ErrorMessage="*"></asp:RequiredFieldValidator>
            </EditItemTemplate>
        </asp:TemplateField>
        
        <%--  gender --%>        
        <asp:TemplateField SortExpression="Gender" HeaderText="מגדר">
            <ItemTemplate>
                <asp:Label runat="server" ID="lblGender" Text='<%# Eval("Gender") %>'></asp:Label>
            </ItemTemplate>
        </asp:TemplateField>
        
        <%--  show on internet--%>                
        <asp:TemplateField SortExpression="ShowInInternet" HeaderText="האם להציג באינטרנט">
            <ItemTemplate>
                <asp:CheckBox ID="chkBxShowInInternet" Enabled="false" runat="server" />
            </ItemTemplate>
            <ItemStyle Width="50px" />
            <EditItemTemplate>
                <asp:CheckBox ID="chkBxShowInInternet" Enabled="true" runat="server" />
            </EditItemTemplate>
        </asp:TemplateField>
        
        <%--  queue order --%>
        <asp:TemplateField SortExpression="AllowQueueOrder" HeaderText="אופן הזימון">
            <ItemTemplate>
                <asp:CheckBox ID="chkBxAllowQueueOrder" Enabled="false" runat="server" />
            </ItemTemplate>
            <EditItemTemplate>
                <asp:CheckBox ID="chkBxAllowQueueOrder" Enabled="true" runat="server" />
            </EditItemTemplate>
        </asp:TemplateField>
        
        <%-- sector --%>        
        <asp:TemplateField SortExpression="sectorDescription" HeaderText="מגזר">
            <ItemTemplate>
                <asp:Label ID="lblSectorID" runat="server" Text='<%# Eval("relevantSector") %>' Visible="false"></asp:Label>
                <asp:Label ID="lblSector" runat="server" Text='<%# Eval("sectorDescription") %>'></asp:Label>
            </ItemTemplate>
            <EditItemTemplate>
                <asp:DropDownList ID="ddlSector" runat="server" DataSourceID="SqlDataSourceSector"
                    DataTextField="EmployeeSectorDescription" DataValueField="EmployeeSectorCode"
                    AutoPostBack="false" OnPreRender="ddlSector_PreRender">
                </asp:DropDownList>
            </EditItemTemplate>
        </asp:TemplateField>
        
        <%-- is active --%>                
        <asp:TemplateField HeaderText="האם פעיל" Visible="false">
            <ItemTemplate>
                <asp:CheckBox ID="chkIsActive" runat="server" Enabled="false" />
            </ItemTemplate>
            <EditItemTemplate>
                <asp:CheckBox ID="chkIsActive" runat="server" Enabled="true" />
            </EditItemTemplate>
        </asp:TemplateField>
        
        
                
        <%-- attached files --%>        
        <asp:TemplateField HeaderText="שיוך קובץ" ItemStyle-Width="350px" Visible="false">
            <ItemTemplate>
                <asp:GridView ID="gvAttachedFiles" runat="server" AutoGenerateColumns="false"></asp:GridView> 
            </ItemTemplate>
            <EditItemTemplate>
                <table>
                    <tr>
                        <td>
                            <table cellpadding="0" cellspacing="0">
                                <tr>
                                    <td class="buttonRightCorner">
                                        &nbsp;
                                    </td>
                                    <td class="buttonCenterBackground">
                                        <asp:Button ID="btnChooseFile" Text="בחירת קובץ" runat="server" CausesValidation="false"
                                            CssClass="RegularUpdateButton" OnClientClick="ChooseFile(this);" />
                                    </td>
                                    <td class="buttonLeftCorner">
                                        &nbsp;
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td>
                            <asp:TextBox ID="txtChosenFile" runat="server" Width="240px"></asp:TextBox>
                            <input id="fileUpload" type="file" style="display: none" />
                        </td>
                    </tr>
                </table>
            </EditItemTemplate>
        </asp:TemplateField>
        
        
        
        <%-- update/delete --%>        
        <asp:TemplateField HeaderText="">
            <ItemTemplate>
                <asp:ImageButton ID="imgUpdate" runat="server" OnClick="imgUpdate_Click" ImageUrl="~/Images/btn_edit.gif"
                    ToolTip="עדכן סוג יחידה" CausesValidation="false" />
                
            </ItemTemplate>
            <EditItemTemplate>
                <table width="45px">
                    <tr>
                        <td>
                            <asp:ImageButton ID="imgCancel" runat="server" CausesValidation="false" CommandName="canel"
                                OnClick="imgCancel_Click" ImageUrl="~/Images/btn_cancel.gif" />
                        </td>
                        <td>
                            <asp:ImageButton ID="imgSave" runat="server" CausesValidation="true" CommandName="save"
                                OnClick="imgSave_Click" ImageUrl="~/Images/btn_approve.gif" ValidationGroup="ctrl" />
                        </td>
                    </tr>
                </table>
            </EditItemTemplate>
            <ItemStyle Width="45px" />
        </asp:TemplateField>
    </Columns>
</asp:GridView>
<asp:HiddenField ID="hdnSortOrder" runat="server" />
<asp:SqlDataSource ID="SqlDataSourceSector" runat="server" ConnectionString="<%$ ConnectionStrings:SeferNetConnectionStringNew %>"
    SelectCommand="SELECT [EmployeeSectorCode], [EmployeeSectorDescription] FROM [EmployeeSector] "
    DataSourceMode="DataReader"></asp:SqlDataSource>
<asp:HiddenField ID="hdnRestoreUnitTypes" Value="0" runat="server" />
