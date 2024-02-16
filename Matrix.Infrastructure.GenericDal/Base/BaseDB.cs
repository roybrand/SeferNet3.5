#region System

using System;
using System.Data;
using System.Collections;
using System.Reflection;

#endregion

#region Application Blocks

using GotDotNet.ApplicationBlocks.Data;

#endregion

namespace Matrix.Infrastructure.GenericDal
{
	/// <summary>
	/// handles all common functionality for DAL objects
	/// </summary>
	public class BaseDB : ContextBoundObject
	{
		#region Private members

		private string m_assembly						= @"GotDotNet.ApplicationBlocks.Data";
		private string m_typeRead						= string.Empty;
		private string m_typeWrite						= "GotDotNet.ApplicationBlocks.Data.OleDb";
		private string m_ConnectionStringRead			= string.Empty;
		private string m_ConnectionStringWrite			= string.Empty;
		private IDbConnection m_dbConnectionRead		= null;
		private IDbConnection m_dbConnectionWrite		= null;

		private AdoHelper m_adoHelperRead				= null;
		private AdoHelper m_adoHelperWrite				= null;
		protected MethodBase m_methodInfo				= null;

		#endregion

		#region Constructor and Destructor

		public BaseDB(string helperTypeRead,
					string helperTypeWrite,
					string ConnectionStringRead, 
					string ConnectionStringWrite)
		{
			m_typeRead = helperTypeRead;
			m_typeWrite = helperTypeWrite;

			m_ConnectionStringRead = ConnectionStringRead;
			m_ConnectionStringWrite = ConnectionStringWrite;
		}

		public BaseDB(string helperType, string ConnectionString)
		{
			m_typeRead = helperType;
			m_typeWrite = helperType;

			m_ConnectionStringRead = ConnectionString;
			m_ConnectionStringWrite = ConnectionString;
		}

		~BaseDB()
		{
		}

		#endregion

		#region Properties

		protected string ConnectionStringRead
		{
			get
			{
				return m_ConnectionStringRead;
			}
		}

		protected string ConnectionStringWrite
		{
			get
			{
				return m_ConnectionStringWrite;
			}
		}

		/// <summary>
		/// Gets the OracleConnection for this instance
		/// </summary>
		public IDbConnection ConnectionRead
		{
			get
			{
				if(m_dbConnectionRead == null)
				{
					m_dbConnectionRead = AdoHelperRead.GetConnection(m_ConnectionStringRead);
				}
				return m_dbConnectionRead;
			}
			set
			{
				m_dbConnectionRead = value;
			}
		}

		public IDbConnection ConnectionWrite
		{
			get
			{
				if(m_dbConnectionWrite == null)
				{
					m_dbConnectionWrite = AdoHelperWrite.GetConnection(m_ConnectionStringWrite);
				}
				return m_dbConnectionWrite;
			}
			set
			{
				m_dbConnectionWrite = value;
			}
		}

		/// <summary>
		/// Gets the Current AdoHelper object for read
		/// </summary>
		protected virtual AdoHelper AdoHelperRead
		{
			get
			{
				if(m_adoHelperRead == null)
				{
					m_adoHelperRead = AdoHelper.CreateHelper(m_assembly, m_typeRead);
				}
				return m_adoHelperRead;
			}
		}

		/// <summary>
		/// Gets the Current AdoHelper object for write
		/// </summary>
		protected virtual AdoHelper AdoHelperWrite
		{
			get
			{
				if(m_adoHelperWrite == null)
				{
					m_adoHelperWrite = AdoHelper.CreateHelper(m_assembly, m_typeWrite);
				}
				return m_adoHelperWrite;
			}
		}

		#endregion

		#region ExecuteReader

		#region Internal methods

		private IDataReader ExecuteReaderInternal(string spName, bool IsUseOutputParameters, ref object[] outputParams, params object[] parameters)
		{
			IDataReader reader	= null;
			IDataParameter[] commandParameters = null;
			AdoHelper helper = null;

			try
			{
				//add Package to the SP name
				spName = FormatProcedureName(spName);

				//get connection by provided connection type
				IDbConnection cnn = GetConnectionByType(ConnectionType.Read);

				//get Helper object by it's type
				helper = GetAdoHelperByConnectionType(ConnectionType.Read);

				//create command parameters and assign the parameters
				commandParameters	= helper.GetSpParameterSet(cnn, spName, true);

				//check parameters count and add if needed
				if(IsUseOutputParameters)
					CheckParameters(commandParameters.Length, ref parameters, ref outputParams);

				helper.AssignParameterValues(commandParameters, parameters);

				reader	= helper.ExecuteReader(cnn, CommandType.StoredProcedure, spName, commandParameters);

				//fill output parameters
				if(IsUseOutputParameters)
					FillOutputParameters(ref commandParameters, ref outputParams);
			}
			catch
			{
				CloseConnection(reader);

				throw;
			}
		
			return reader;
		}

		private IDataReader ExecuteReaderInternal(string commandText)
		{
			IDataReader reader	= null;
			AdoHelper helper = null;

			try
			{
				//get connection by provided connection type
				IDbConnection cnn = GetConnectionByType(ConnectionType.Read);

				//get Helper object by it's type
				helper = GetAdoHelperByConnectionType(ConnectionType.Read);

				reader	= helper.ExecuteReader(cnn, CommandType.Text, commandText);
			}
			catch
			{
				CloseConnection(reader);

				throw;
			}
		
			return reader;
		}

		private IDataReader ExecuteReaderInternal(string spName, bool IsUseOutputParameters, ref IDataParameter[] parameters)
		{
			IDataReader reader	= null;
			AdoHelper helper = null;

			try
			{
				//add Package to the SP name
				spName = FormatProcedureName(spName);

				//get connection by provided connection type
				IDbConnection cnn = GetConnectionByType(ConnectionType.Read);

				//get Helper object by it's type
				helper = GetAdoHelperByConnectionType(ConnectionType.Read);

				reader	= helper.ExecuteReader(cnn, CommandType.StoredProcedure, spName, parameters);
			}
			catch
			{
				CloseConnection(reader);

				throw;
			}
		
			return reader;
		}

		#endregion

		/// <summary>
		/// ExecuteReader and handles the auditing functinality
		/// </summary>
		/// <param name="spName">StoredProcedure name</param>
		/// <param name="status">status to return</param>
		/// <param name="outputParams">output parameters array</param>
		/// <param name="parameters">input parameters</param>
		/// <returns>returns IDataReader</returns>
		protected virtual IDataReader ExecuteReader(string spName, ref object[] outputParams, params object[] parameters)
		{
			return ExecuteReaderInternal(spName, true, ref outputParams, parameters);
		}

		/// <summary>
		/// ExecuteReader and handles the auditing functinality
		/// </summary>
		/// <param name="CommandText">Command text</param>
		/// <returns>returns IDataReader</returns>
		protected virtual IDataReader ExecuteReader(string CommandText)
		{
			return ExecuteReaderInternal(CommandText);
		}

		/// <summary>
		/// ExecuteReader and handles the auditing functinality
		/// </summary>
		/// <param name="spName">StoredProcedure name</param>
		/// <param name="status">status to return</param>
		/// <param name="outputParams">output parameters array</param>
		/// <param name="parameters">input parameters</param>
		/// <returns>returns IDataReader</returns>
		protected virtual IDataReader ExecuteReader(string spName, params IDataParameter[] parameters)
		{
			return ExecuteReaderInternal(spName, true, ref parameters);
		}
		
		/// <summary>
		/// ExecuteReader
		/// </summary>
		/// <param name="spName">stored procedure name</param>
		/// <param name="status">status - output param</param>
		/// <param name="parameters">sp query parameters</param>
		/// <returns>IDataReader</returns>
		protected IDataReader ExecuteReader(string spName, ref int status, params object[] parameters)
		{
			IDataReader data = null;
			object[] objs = new object[1]{-1};
			
			try
			{
				data = ExecuteReader(spName, ref objs, parameters);

				status = Convert.ToInt32(objs[0]);
			}
			catch
			{
				CloseConnection(data);

				throw;
			}

			return data;
		}

		/// <summary>
		/// ExecuteReader
		/// </summary>
		/// <param name="spName">stored procedure name</param>
		/// <param name="status">status - output param</param>
		/// <param name="parameters">sp query parameters</param>
		/// <returns>IDataReader</returns>
		protected IDataReader ExecuteReader(string spName, ref int status, params IDataParameter[] parameters)
		{
			IDataReader data = null;
			object[] objs = new object[1]{-1};
			
			try
			{
				data = ExecuteReader(spName, ref objs, parameters);

				status = Convert.ToInt32(objs[0]);
			}
			catch
			{
				CloseConnection(data);

				throw;
			}

			return data;
		}

		#endregion

		#region Fill Dataset

		#region Internal methods

		/// <summary>
		/// Encode hebrew values in the dataset
		/// </summary>
		/// <param name="p_dataSet">DataSet to go through and encode</param>
		/// <returns>Encoded DataSet</returns>
		protected virtual DataSet EncodeHebrew(DataSet p_dataSet)
		{
			return p_dataSet;
		}

		private DataSet FillDatasSetInternal(string spName, ConnectionType p_connectionType, bool IsUseOutputParameters, ref object[] outputParams, params object[] parameters)
		{
			DataSet ds = new DataSet();
			IDataParameter[] commandParameters = null;
			AdoHelper helper = null;

			//add Package to the SP name
			spName = FormatProcedureName(spName);

			try
			{
				//get connection by provided connection type
				IDbConnection cnn = GetConnectionByType(p_connectionType);

				//get Helper object by it's type
				helper = GetAdoHelperByConnectionType(p_connectionType);

				//create command parameters and assign the parameters
				commandParameters	= helper.GetSpParameterSet(cnn, spName, true);

				//check parameters count and add if needed
				if(IsUseOutputParameters)
				{
					CheckParameters(commandParameters.Length, ref parameters, ref outputParams);
				}

				helper.AssignParameterValues(commandParameters, parameters);

				helper.FillDataset(cnn, CommandType.StoredProcedure, spName, ds, null, commandParameters);

				//fill output parameters
				if(IsUseOutputParameters == true)
				{
					FillOutputParameters(ref commandParameters, ref outputParams);
				}
			}
			finally
			{
				CloseConnection();
			}
		
			return EncodeHebrew(ds);
		}

		private DataSet FillDatasSetInternal(string commandText)
		{
			DataSet ds = new DataSet();
			AdoHelper helper = null;

			try
			{
				//get connection by provided connection type
				IDbConnection cnn = GetConnectionByType(ConnectionType.Read);

				//get Helper object by it's type
				helper = GetAdoHelperByConnectionType(ConnectionType.Read);

				helper.FillDataset(cnn, CommandType.Text, commandText, ds, null);
			}
			finally
			{
				CloseConnection();
			}
		
			return EncodeHebrew(ds);
		}

		private DataSet FillDatasSetInternal(string spName, bool IsUseOutputParameters, ref IDataParameter[] parameters)
		{
			DataSet ds = new DataSet();
			AdoHelper helper = null;

			try
			{
				//add Package to the SP name
				spName = FormatProcedureName(spName);

				//get connection by provided connection type
				IDbConnection cnn = GetConnectionByType(ConnectionType.Read);

				//get Helper object by it's type
				helper = GetAdoHelperByConnectionType(ConnectionType.Read);

				helper.FillDataset(cnn, CommandType.StoredProcedure, spName, ds, null, parameters);
			}
			finally
			{
				CloseConnection();
			}
		
			return EncodeHebrew(ds);
		}

		#endregion

		/// <summary>
		/// ExecuteReader and handles the auditing functinality
		/// </summary>
		/// <param name="spName">StoredProcedure name</param>
		/// <param name="status">status to return</param>
		/// <param name="outputParams">output parameters array</param>
		/// <param name="parameters">input parameters</param>
		/// <returns>returns IDataReader</returns>
		protected virtual DataSet FillDataSet(string spName, ref object[] outputParams, params object[] parameters)
		{
			return FillDatasSetInternal(spName, ConnectionType.Read, true, ref outputParams, parameters);
		}

		/// <summary>
		/// ExecuteReader and handles the auditing functinality
		/// </summary>
		/// <param name="spName">StoredProcedure name</param>
		/// <param name="p_connectionType">Type of connection (Read/Write)</param>
		/// <param name="status">status to return</param>
		/// <param name="outputParams">output parameters array</param>
		/// <param name="parameters">input parameters</param>
		/// <returns>returns IDataReader</returns>
		protected virtual DataSet FillDataSet(string spName, ConnectionType p_connectionType, ref object[] outputParams, params object[] parameters)
		{
			return FillDatasSetInternal(spName, p_connectionType, true, ref outputParams, parameters);
		}

		/// <summary>
		/// ExecuteReader and handles the auditing functinality
		/// </summary>
		/// <param name="CommandText">Command text</param>
		/// <returns>returns IDataReader</returns>
		protected virtual DataSet FillDataSet(string CommandText)
		{
			return FillDatasSetInternal(CommandText);
		}

		/// <summary>
		/// ExecuteReader and handles the auditing functinality
		/// </summary>
		/// <param name="spName">StoredProcedure name</param>
		/// <param name="status">status to return</param>
		/// <param name="outputParams">output parameters array</param>
		/// <param name="parameters">input parameters</param>
		/// <returns>returns IDataReader</returns>
		protected virtual DataSet FillDataSet(string spName, params IDataParameter[] parameters)
		{
			return FillDatasSetInternal(spName, true, ref parameters);
		}
		
		/// <summary>
		/// ExecuteReader
		/// </summary>
		/// <param name="spName">stored procedure name</param>
		/// <param name="status">status - output param</param>
		/// <param name="parameters">sp query parameters</param>
		/// <returns>IDataReader</returns>
		protected DataSet FillDataSet(string spName, ref int status, params object[] parameters)
		{
			DataSet ds = null;
			object[] objs = new object[1]{-1};
			
			try
			{
				ds = FillDataSet(spName, ref objs, parameters);

				status = Convert.ToInt32(objs[0]);
			}
			finally
			{
				CloseConnection();
			}

			return ds;
		}

		/// <summary>
		/// ExecuteReader
		/// </summary>
		/// <param name="spName">stored procedure name</param>
		/// <param name="status">status - output param</param>
		/// <param name="parameters">sp query parameters</param>
		/// <returns>IDataReader</returns>
		protected DataSet FillDataSet(string spName, ref int status, params IDataParameter[] parameters)
		{
			DataSet ds = null;
			object[] objs = new object[1]{-1};
			
			try
			{
				ds = FillDataSet(spName, ref objs, parameters);

				status = Convert.ToInt32(objs[0]);
			}
			finally
			{
				CloseConnection();
			}

			return ds;
		}

		#endregion

		#region Execute ExecuteNonQuery

		#region Internal Methods

		private int ExecuteNonQueryInternal(string spName, ConnectionType ConnectionType, bool IsUseOutputParameters, ref object[] outputParams, params object[] parameters)
		{
			int status;
			IDataParameter[] commandParameters = null;
			AdoHelper helper = null;

			try
			{
				//add Package to the SP name
				spName = FormatProcedureName(spName);

				//get connection by provided connection type
				IDbConnection cnn = GetConnectionByType(ConnectionType);

				//get Helper object by it's type
				helper = GetAdoHelperByConnectionType(ConnectionType);

				commandParameters	= helper.GetSpParameterSet(cnn, spName, true);

				//check parameters count and add if needed
				if(IsUseOutputParameters)
				{
					CheckParameters(commandParameters.Length, ref parameters, ref outputParams);
				}

				helper.AssignParameterValues(commandParameters, parameters);

				status = helper.ExecuteNonQuery(cnn, CommandType.StoredProcedure, spName, commandParameters);

				//fill output parameters
				if(IsUseOutputParameters == true)
				{
					FillOutputParameters(ref commandParameters, ref outputParams);
				}
			}
			finally
			{
				//check if we should close conection on exit
				CloseConnection(ConnectionType);
			}

			return status;
		}

		private int ExecuteNonQueryInternal(IDbTransaction trans, string spName, ConnectionType ConnectionType, bool IsUseOutputParameters, ref object[] outputParams, params object[] parameters)
		{
			int status;
			IDataParameter[] commandParameters = null;
			AdoHelper helper = null;

			//add Package to the SP name
			spName = FormatProcedureName(spName);

			//get connection by provided connection type
			IDbConnection cnn = GetConnectionByType(ConnectionType);

			//get Helper object by it's type
			helper = GetAdoHelperByConnectionType(ConnectionType);

			//create command parameters and assign the parameters
			commandParameters	= helper.GetSpParameterSet(cnn, spName, true);

			//check parameters count and add if needed
			if(IsUseOutputParameters == true)
			{
				CheckParameters(commandParameters.Length, ref parameters, ref outputParams);
			}

			helper.AssignParameterValues(commandParameters, parameters);

			status = helper.ExecuteNonQuery(trans, CommandType.StoredProcedure, spName, commandParameters);

			//fill output parameters
			if(IsUseOutputParameters == true)
			{
				FillOutputParameters(ref commandParameters, ref outputParams);
			}

			return status;
		}

		#endregion

		/// <summary>
		/// Execute non query procedure
		/// </summary>
		/// <param name="spName">Stored procedure name</param>
		/// <param name="ConnectionType">type of connection</param>
		/// <param name="AutoCloseConnection">should we close connection on exit</param>
		/// <param name="outputParams">output parameters</param>
		/// <param name="parameters">input parameters</param>
		/// <returns>status code</returns>
		protected virtual int ExecuteNonQuery(string spName, ConnectionType ConnectionType, ref object[] outputParams, params object[] parameters)
		{
			return ExecuteNonQueryInternal(spName, ConnectionType, true, ref outputParams, parameters);
		}

		/// <summary>
		/// Execute non query procedure
		/// </summary>
		/// <param name="spName">Stored procedure name</param>
		/// <param name="AutoCloseConnection">should we close connection on exit</param>
		/// <param name="parameters">input parameters</param>
		/// <returns>status code</returns>
		protected int ExecuteNonQuery(string spName, params object[] parameters)
		{
			object[] objs = new object[1]{-1};
			
			return ExecuteNonQuery(spName, ConnectionType.Read, ref objs, parameters);
		}

		/// <summary>
		/// Execute non query procedure
		/// </summary>
		/// <param name="spName">Stored procedure name</param>
		/// <param name="ConnectionType">type of connection</param>
		/// <param name="AutoCloseConnection">should we close connection on exit</param>
		/// <param name="parameters">input parameters</param>
		/// <returns>status code</returns>
		protected int ExecuteNonQuery(string spName, ConnectionType ConnectionType, params object[] parameters)
		{
			object[] objs = new object[1]{-1};
			
			return ExecuteNonQuery(spName, ConnectionType, ref objs, parameters);
		}

		/// <summary>
		/// Execute non query procedure
		/// </summary>
		/// <param name="trans">Transaction</param>
		/// <param name="spName">Stored procedure name</param>
		/// <param name="ConnectionType">type of connection we'll use</param>
		/// <param name="outputParams">Output parameters</param>
		/// <param name="parameters">Input parameters</param>
		/// <returns>status</returns>
		protected virtual int ExecuteNonQuery(IDbTransaction trans, string spName, ConnectionType ConnectionType, ref object[] outputParams, params object[] parameters)
		{
			return ExecuteNonQueryInternal(trans, spName, ConnectionType, true, ref outputParams, parameters);
		}

		/// <summary>
		/// Execute non query procedure
		/// </summary>
		/// <param name="trans">Transaction</param>
		/// <param name="spName">Stored procedure name</param>
		/// <param name="ConnectionType">type of connection we'll use</param>
		/// <param name="parameters">input parameters</param>
		/// <returns>status code</returns>
		protected int ExecuteNonQuery(IDbTransaction trans, string spName, ConnectionType ConnectionType, params object[] parameters)
		{
			object[] objs = new object[1]{-1};
			
			return ExecuteNonQuery(trans, spName, ConnectionType, ref objs, parameters);
		}

		#endregion

		#region AdoHelper processing

		protected AdoHelper GetAdoHelperByConnectionType(ConnectionType Type)
		{
			if(Type == ConnectionType.Read)
				return AdoHelperRead;
			else
				return AdoHelperWrite;
		}

		#endregion

		#region Parameters processing

		/// <summary>
		/// Fills output parameters value from the parameters collection
		/// </summary>
		/// <param name="commandParameters">parameters collection (IN/OUT)</param>
		/// <param name="outputParams">target output params collection to fill</param>
		protected static void FillOutputParameters(ref IDataParameter[] commandParameters, ref object[] outputParams)
		{
			int j = 0, OutputParamsCount = outputParams.Length;

			//go through all the parameters and assign output values
			for(int i=0; i < commandParameters.Length; i++)
			{
				//if found output parameter
				if(commandParameters[i].Direction == ParameterDirection.Output ||
					commandParameters[i].Direction == ParameterDirection.InputOutput)
				{
					outputParams.SetValue(commandParameters[i].Value,j); //get parameter value
					j++;

					//check if we got the max output parameters
					if(j >= OutputParamsCount)
						break;
				}
			}
		}

		/// <summary>
		/// Check parameters count and adds params if needed
		/// </summary>
		/// <param name="ProcedureParamsCount">Parameters amount to be</param>
		/// <param name="parameters">Source parameters</param>
		protected static void CheckParameters(int p_procedureParamsCount, ref object[] parameters, ref object[] outParams)
		{
			int j = 0;
			int inputParamsCount = 0;
			object[] newParams = null;

			//if we have parameters to add
			if(p_procedureParamsCount != 0) 
			{
				newParams = new object[p_procedureParamsCount];

				//copy all input parameters into the new array
				if(parameters != null)
				{
					parameters.CopyTo(newParams, 0);
					inputParamsCount = parameters.Length;
				}

				//go through all the parameters and fill output parameters values
				for(int i=inputParamsCount; i<p_procedureParamsCount; i++)
				{
					if(j < outParams.Length)
					{
						newParams[i] = outParams[j++];
					}
					else
					{
						newParams[i] = DBNull.Value;
					}
				}

				parameters = newParams;
			}
		}

		protected static void CheckParametersTypes(AdoHelper helper, ref IDataParameter[] sourceParameters, ref IDataParameter[] targetParameters, bool setValues, bool setSize, int size)
		{
			for(int i=0; i<targetParameters.Length && i<sourceParameters.Length; i++)
			{
				if(sourceParameters[i] != null)
				{
					//if we want to set the new size to the parameter
					if(setSize)
					{
						targetParameters[i] = helper.GetParameter(sourceParameters[i].ParameterName,
							sourceParameters[i].DbType, size, 
							sourceParameters[i].Direction);
					}
					else
					{
						targetParameters[i] = helper.GetParameter(sourceParameters[i].ParameterName,
							sourceParameters[i].DbType, 255, 
							sourceParameters[i].Direction);
					}

					//change param's type
					if(sourceParameters[i].DbType != targetParameters[i].DbType)
					{
						targetParameters[i].DbType = sourceParameters[i].DbType;
					}

					//change param's value
					if(setValues)
					{
						targetParameters[i].Value = sourceParameters[i].Value;
					}
				}
			}
		}

		protected static void CheckParametersTypes(ref IDataParameter[] sourceParameters, ref IDataParameter[] targetParameters)
		{
			for(int i=0; i<targetParameters.Length && i<sourceParameters.Length; i++)
			{
				if(sourceParameters[i] != null)
				{
					//copy parameter into the target parameter array
					targetParameters[i] = sourceParameters[i];
				}
			}
		}

		#endregion

		#region Connection processing methods

		public virtual void CloseConnection()
		{
			if(m_dbConnectionRead != null)
			{
				m_dbConnectionRead.Close();
				m_dbConnectionRead.Dispose();

				m_dbConnectionRead = null;
			}

			if(m_dbConnectionWrite != null)
			{
				m_dbConnectionWrite.Close();
				m_dbConnectionWrite.Dispose();

				m_dbConnectionWrite = null;
			}
		}

		public virtual void CloseConnection(ConnectionType Type)
		{
			if(Type == ConnectionType.Read)
			{
				if(m_dbConnectionRead != null)
				{
					m_dbConnectionRead.Close();
					m_dbConnectionRead.Dispose();

					m_dbConnectionRead = null;
				}
			}
			else
			{
				if(m_dbConnectionWrite != null)
				{
					m_dbConnectionWrite.Close();
					m_dbConnectionWrite.Dispose();

					m_dbConnectionWrite = null;
				}
			}
		}

		public virtual void CloseConnection(IDataReader dr)
		{
			if(dr != null)
			{
				dr.Close();
				dr.Dispose();
			}

			CloseConnection();
		}

		/// <summary>
		/// get right connection by providet ConnectionType
		/// </summary>
		/// <param name="CnnType">ConnectionType Attribute to check</param>
		/// <returns>Connection</returns>
		protected IDbConnection GetConnectionByType(ConnectionType CnnType)
		{
			if(CnnType==ConnectionType.Read)
			{
				return ConnectionRead;
			}
			else
			{
				return ConnectionWrite;
			}
		}

		#endregion

		#region Transactions Mennagement Methods

		public IDbTransaction OpenTransaction()
		{
			IDbConnection cnn = GetConnectionByType(ConnectionType.Write);

			cnn.Open();

			return cnn.BeginTransaction();
		}

		public void CloseTransaction(IDbTransaction p_transaction)
		{
			p_transaction.Dispose();

			CloseConnection(ConnectionType.Write);
		}

		#endregion

		#region Data checks

		/// <summary>
		/// Check if the value equals null or equals DBNull
		/// </summary>
		/// <param name="Value"></param>
		/// <returns></returns>
		protected static bool IsNull(object Value)
		{
			if(Value == System.DBNull.Value || Value == null)
				return true;
			else
				return false;
		}

		#endregion

		#region Common checks

		protected virtual string FormatProcedureName(string spName)
		{
			return spName;
		}

		#endregion

	}
}
