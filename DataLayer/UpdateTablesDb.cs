using System;
using System.Collections.Generic;
using System.Text;
using System.Data.SqlClient;
using System.Data;
using SeferNet.Globals;

namespace SeferNet.DataLayer
{
    public class UpdateTablesDb
    {

        string m_ConnStr;
        SqlConnection m_conn;
        
        public UpdateTablesDb()
        {
            m_ConnStr = ConnectionHandler.ResolveConnStrByLang();
            m_conn = new SqlConnection(m_ConnStr);
        }

        private SqlDataAdapter getAdapter(string selectCommandText)
        {
            SqlCommand command = new SqlCommand(string.Empty, m_conn);
            command.CommandType = CommandType.Text;
            command.CommandText = selectCommandText;
            SqlDataAdapter da = new SqlDataAdapter(command);
            da.SelectCommand = command;
            SqlCommandBuilder builder = new SqlCommandBuilder(da);
            da.InsertCommand = builder.GetInsertCommand();
            da.DeleteCommand = builder.GetDeleteCommand();
            da.UpdateCommand = builder.GetUpdateCommand();

            return da;
        }

    }
}
