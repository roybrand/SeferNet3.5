using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using SeferNet.Globals;

namespace SeferNet.DataLayer
{
    public class CachedTablesDB : Base.SqlDal
    {
        SqlConnection m_Connection;
        string m_ConnString;
        public CachedTablesDB(string p_conString)
            : base(p_conString)
        {
            m_ConnString = p_conString;
        }

        public DataSet getCachedTablesDB()
        {
            string spName = "rpc_getCachedTables";
            DBActionNotification.RaiseOnDBSelect(spName,new object[]{});
            DataSet ds = FillDataSet(spName);
            return ds;


            //DataSet ds = new DataSet();
            //string connStr = ConfigurationManager.ConnectionStrings["SeferNetConnectionString"].ConnectionString;
            //if (m_Connection==null)
            //{
            //    m_Connection = new SqlConnection(connStr);
            //}

            //using (SqlCommand command = new SqlCommand(string.Empty, m_Connection))
            //{


            //    command.CommandType = CommandType.StoredProcedure;
            //    command.CommandText = "getCachedTables";

            //    SqlDataAdapter da;
            //    using (da = new SqlDataAdapter(command))
            //    {
            //        da.SelectCommand = command;
            //        try
            //        {
                        
            //            da.Fill(ds);
            //        }
            //        catch (Exception ex)
            //        {
            //            string err = ex.ToString();
            //            throw;
            //        }
            //    }


            //}
            //return ds;        
        }

        public DataTable getTableData(string tableName)
        {            
            DataSet ds = new DataSet();

            
            if (m_Connection==null)
            {
                m_Connection = new SqlConnection(m_ConnString);
            }

            using (SqlCommand command = new SqlCommand(string.Empty, m_Connection))
            {


                command.CommandType = CommandType.Text;
                command.CommandText = "select * from "+tableName;

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
            ds.Tables[0].TableName = tableName;
            return ds.Tables[0];

        }
        
    }
}
