<%@ Page Language="C#" %>
<html>
<head id="Head1" runat="server">
  <title>GridView DetailsView Master-Details (with Editing)</title>
</head>
<script runat="server">

    protected void DetailsView1_ItemUpdated(Object sender, System.Web.UI.WebControls.DetailsViewUpdatedEventArgs e) {
        GridView1.DataBind();
        DropDownList1.DataBind();
    }

    protected void GridView1_SelectedIndexChanged(object sender, EventArgs e)
    {
        DetailsView1.ChangeMode(DetailsViewMode.ReadOnly);
    }

    protected void GridView1_Sorted(object sender, EventArgs e)
    {
        DetailsView1.ChangeMode(DetailsViewMode.ReadOnly);
    }

    protected void DropDownList1_SelectedIndexChanged(object sender, EventArgs e)
    {
        DetailsView1.ChangeMode(DetailsViewMode.ReadOnly);
    }

  protected void GridView1_PageIndexChanged(object sender, EventArgs e)
  {
        DetailsView1.ChangeMode(DetailsViewMode.ReadOnly);
  }
  
</script>
<body>
  <form id="form1" runat="server">
    <b>Choose a state:</b>
    <asp:DropDownList ID="DropDownList1" DataSourceID="SqlDataSource2" AutoPostBack="true"
      DataTextField="state" runat="server" OnSelectedIndexChanged="DropDownList1_SelectedIndexChanged" />
    <asp:SqlDataSource ID="SqlDataSource2" runat="server" SelectCommand="SELECT DISTINCT [state] FROM [authors]"
      ConnectionString="<%$ ConnectionStrings:Pubs %>" />
    <br />
    <br />
    <table>
      <tr>
        <td valign="top">
          <asp:GridView ID="GridView1" AllowSorting="True" AllowPaging="True" runat="server"
            DataSourceID="SqlDataSource1" DataKeyNames="au_id"
            AutoGenerateColumns="False" Width="427px" OnSelectedIndexChanged="GridView1_SelectedIndexChanged" OnSorted="GridView1_Sorted" OnPageIndexChanged="GridView1_PageIndexChanged">
            <Columns>
              <asp:CommandField ShowSelectButton="True" />
              <asp:BoundField DataField="au_id" HeaderText="au_id" ReadOnly="True" SortExpression="au_id" />
              <asp:BoundField DataField="au_lname" HeaderText="au_lname" SortExpression="au_lname" />
              <asp:BoundField DataField="au_fname" HeaderText="au_fname" SortExpression="au_fname" />
              <asp:BoundField DataField="state" HeaderText="state" SortExpression="state" />
            </Columns>
          </asp:GridView>
          <asp:SqlDataSource ID="SqlDataSource1" runat="server" SelectCommand="SELECT [au_id], [au_lname], [au_fname], [state] FROM [authors] WHERE ([state] = @state)"
            ConnectionString="<%$ ConnectionStrings:Pubs %>">
            <SelectParameters>
              <asp:ControlParameter ControlID="DropDownList1" Name="state" PropertyName="SelectedValue"
                Type="String" />
            </SelectParameters>
          </asp:SqlDataSource>
        </td>
        <td valign="top">
          <asp:DetailsView AutoGenerateRows="False" DataKeyNames="au_id" OnItemUpdated="DetailsView1_ItemUpdated" DataSourceID="SqlDataSource3"
            HeaderText="Author Details" ID="DetailsView1" runat="server" Width="275px">
            <Fields>
              <asp:BoundField DataField="au_id" HeaderText="au_id" ReadOnly="True" SortExpression="au_id" />
              <asp:BoundField DataField="au_lname" HeaderText="au_lname" SortExpression="au_lname" />
              <asp:BoundField DataField="au_fname" HeaderText="au_fname" SortExpression="au_fname" />
              <asp:BoundField DataField="phone" HeaderText="phone" SortExpression="phone" />
              <asp:BoundField DataField="address" HeaderText="address" SortExpression="address" />
              <asp:BoundField DataField="city" HeaderText="city" SortExpression="city" />
              <asp:BoundField DataField="state" HeaderText="state" SortExpression="state" />
              <asp:BoundField DataField="zip" HeaderText="zip" SortExpression="zip" />
              <asp:CheckBoxField DataField="contract" HeaderText="contract" SortExpression="contract" />
              <asp:CommandField ShowEditButton="True" />
            </Fields>
          </asp:DetailsView>
          <asp:SqlDataSource ID="SqlDataSource3" runat="server" ConnectionString="<%$ ConnectionStrings:Pubs %>"
            SelectCommand="SELECT [au_id], [au_lname], [au_fname], [phone], [address], [city], [state], [zip], [contract] FROM [authors] WHERE ([au_id] = @au_id)"
            UpdateCommand="UPDATE [authors] SET [au_lname] = @au_lname, [au_fname] = @au_fname, [phone] = @phone, [address] = @address, [city] = @city, [state] = @state, [zip] = @zip, [contract] = @contract WHERE [au_id] = @au_id">
            <SelectParameters>
              <asp:ControlParameter ControlID="GridView1" Name="au_id" PropertyName="SelectedValue"
                Type="String" />
            </SelectParameters>
            <UpdateParameters>
              <asp:Parameter Name="au_lname" Type="String" />
              <asp:Parameter Name="au_fname" Type="String" />
              <asp:Parameter Name="phone" Type="String" />
              <asp:Parameter Name="address" Type="String" />
              <asp:Parameter Name="city" Type="String" />
              <asp:Parameter Name="state" Type="String" />
              <asp:Parameter Name="zip" Type="String" />
              <asp:Parameter Name="contract" Type="Boolean" />
              <asp:Parameter Name="au_id" Type="String" />
            </UpdateParameters>
          </asp:SqlDataSource>
        </td>
      </tr>
    </table>
    <br />
  </form>
</body>
</html>
