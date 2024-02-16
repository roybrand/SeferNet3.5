using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;
using SeferNet.DataLayer;
using System.Text.RegularExpressions;

public partial class Tests_TestRemarksPopUp : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
       
       

    }


   


    public DataSet GetSourceData(int employeeID)
    {
        DataSet ds = new DataSet();
        string connStr = ConnectionHandler.ResolveConnStrByLang();
        SqlConnection m_Connection = new SqlConnection(connStr);

        using (SqlCommand command = new SqlCommand(string.Empty, m_Connection))
        {

            command.CommandType = CommandType.Text;
            string query = " select remarkID, remark from dbo.DIC_GeneralRemarks where linkedToReceptionHours=1 and active=1";                        

            command.CommandText = query;
            SqlDataAdapter da;
            using (da = new SqlDataAdapter(command))
            {
                da.SelectCommand = command;
                try
                {
                    da.FillSchema(ds, SchemaType.Mapped);
                    da.Fill(ds);                    
                }
                catch (Exception ex)
                {
                    string err = ex.ToString();
                    throw;
                }
            }
        }

        return ds;
    }

    protected void imgBtn_Click(object sender, ImageClickEventArgs e)
    {

    }
}
