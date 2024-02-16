<%@ page language="C#" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">

  void SubmitBtn_Click(object sender, EventArgs e)
  {
    Message.Text = "Hello World!";    
  }

</script>

<html  >
<head id="head1" runat="server">
  <title>Button.UseSubmitBehavior Example</title>
</head>
<body>
    <%--<iframe src="http://mkwebd034/SeferNet/SearchClinics.aspx"></iframe>--%> 
  <form id="form1" runat="server">

    <h3>Button.UseSubmitBehavior Example</h3> 

    Click the Submit button.

    <br /><br /> 

    <!--The value of the UseSubmitBehavior property
    is false. Therefore the button uses the ASP.NET 
    postback mechanism.-->
    <asp:button id="Button1"
      text="Submit"
      onclick="SubmitBtn_Click" 
      usesubmitbehavior="false"
      runat="server"/>       

    <br /><br /> 

    <asp:label id="Message" runat="server"/>
       <input id="time" name="test1" type="text"/>
<asp:TextBox ID="txtFromHour" runat="server" EnableTheming="false" Width="70px" ></asp:TextBox>
<%--<script src="https://code.jquery.com/jquery-2.2.4.js" type="text/javascript"></script>--%>
<script src="/SeferNet/Scripts/jquery/jquery.js" type="text/javascript"></script>

<script type="text/javascript" src="/SeferNet/Scripts/jquery-ui/jquery_inputmask_bundle.js"></script> 
<%--<script src="https://rawgit.com/RobinHerbots/jquery.inputmask/3.x/dist/jquery.inputmask.bundle.js" type="text/javascript"></script>--%>

<script type="text/javascript">
$("#time").inputmask("hh:mm", {
  placeholder: "__:__", 
  insertMode: false, 
  showMaskOnHover: false,
  alias: "datetime"//,
  //hourFormat: 24
}
    );

    $("#txtFromHour").inputmask("hh:mm", {
        placeholder: "__:__",
        insertMode: false,
        showMaskOnHover: false,
        alias: "datetime"//,
        //hourFormat: 24
    }
    );
</script>

  </form>
</body>
</html>