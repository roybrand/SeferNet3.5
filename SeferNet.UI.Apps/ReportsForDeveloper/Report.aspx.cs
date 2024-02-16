using System;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Configuration;

using System.Data.SqlClient;

namespace ExceptionLogger
{
	public partial class Report : System.Web.UI.Page
	{

        SqlDataReader rdr = null;
        SqlConnection cn = null;
        SqlCommand cmd = null;	

		protected void Page_Load(object sender, System.EventArgs e)
		{
					 
			string strSQL="";
			if(Request.QueryString["EvtId"]!=null)
			{
				strSQL="SELECT * FROM LOGITEMS WHERE EventId='" +
					Request.QueryString["EvtId"].ToString()+"' ";	
			}
			else

			{
					strSQL="SELECT TOP 100 * FROM LOGITEMS";									
			}
			strSQL+=" order by LogDateTime DESC";			
			
	string dbConnString=
		ConfigurationManager.AppSettings["exceptionLogConnString"].ToString();
			 cn = new SqlConnection(dbConnString);      			 
			cmd = new SqlCommand(strSQL,cn);
			cn.Open();
			try
			{		
				rdr=cmd.ExecuteReader(CommandBehavior.CloseConnection);
				DataGrid1.DataSource=rdr;
				DataGrid1.DataBind();				
			}
			catch(Exception ex)
			{
				System.Diagnostics.Debug.Write(ex.Message );
			}
			finally
			{
				if(rdr!=null)
				rdr.Close();
                cn.Close();
			}			
		}
		#region Web Form Designer generated code
		override protected void OnInit(EventArgs e)
		{
			//
			// CODEGEN: This call is required by the ASP.NET Web Form Designer.
			//
			InitializeComponent();
			base.OnInit(e);
		}
		
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{    

		}
		#endregion

        protected void Button1_Click(object sender, EventArgs e)
        {
            /*@AppName varchar(150)=null,
            @beginDate datetime=null,
            @endDate datetime = null,
            @source char(100)=null,
            @Message varchar(1000)=null,
            @TargetSite varchar(300) = null,
            @referer varchar(250) = null,
            @path varchar(300) = null */

            string dbConnString =
        ConfigurationManager.AppSettings["exceptionLogConnString"].ToString();
           cn = new SqlConnection(dbConnString);
          cmd = new SqlCommand();
          cmd.CommandType = CommandType.StoredProcedure;
          cmd.CommandText = "dbo.SearchExceptionLog";
         cmd.Connection = cn;
         cmd.Parameters.AddWithValue("@AppName", this.txtAppName.Text == String.Empty?(object)DBNull.Value:txtAppName.Text);
         cmd.Parameters.AddWithValue("@BeginDate", this.dtBeginDate.IsNull?DBNull.Value:dtBeginDate.SelectedValue);
         cmd.Parameters.AddWithValue("@EndDate", this.dtEndDate.IsNull ? DBNull.Value:dtEndDate.SelectedValue);
       
         cmd.Parameters.AddWithValue("@Message", this.txtMessage.Text == "" ? (object)DBNull.Value : txtMessage.Text);
         cmd.Parameters.AddWithValue("@TargetSite", this.txtTargetSite.Text == "" ? (object)DBNull.Value : txtTargetSite.Text);
         cmd.Parameters.AddWithValue("@Referer", this.txtReferer.Text == "" ? (object)DBNull.Value : txtReferer.Text);
         cmd.Parameters.AddWithValue("@Path", this.txtPath.Text == "" ? (object)DBNull.Value : txtPath.Text);
         cn.Open();
         rdr = cmd.ExecuteReader(CommandBehavior.CloseConnection);
         DataGrid1.DataSource = rdr;
         DataGrid1.DataBind();
         rdr.Close();








        }
	}
}
