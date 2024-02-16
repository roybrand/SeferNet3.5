#region System
using System;
using System.Collections;
using System.Collections.Specialized;
using GotDotNet.ApplicationBlocks.Data;
using Matrix.Infrastructure.GenericDal;
using System.Data.Common;
using System.Data;
using System.Collections.Generic;
using Clalit.Infrastructure.Dal;

#endregion

namespace SeferNet.DataLayer.Base
{
    /// <summary>
    /// Base class for all other SQL datalayer classes
    /// </summary>
    public abstract class SqlDal : BaseMSSQL
    {
        #region Constructors

        //Provider=MSDAORA;

        /// <summary>
        /// contructor that get parametr connection string
        /// </summary>
        /// <param name="p_connectionString"></param>
        public SqlDal(string p_connectionString)
            :
            base("GotDotNet.ApplicationBlocks.Data.SqlServer",
            "GotDotNet.ApplicationBlocks.Data.SqlServer",
            p_connectionString,
            p_connectionString)
        { }


        #endregion

        #region Methods

        protected override string FormatProcedureName(string spName)
        {
            return spName.ToUpper();
        }

        #endregion

        #region Properties

        /// <summary>
        /// Get Max rows in dataset
        /// </summary>
        protected virtual int MaxRowsCount
        {
            get
            {
                return 1000;
            }
        }

        /*
        /// <summary>
        /// Get Application Configuration Object
        /// </summary>
        protected AppConfiguration AppConfig
        {
            get
            {
                return ConfigurationManager.Instance.AppConfig;
            }
        }

        /// <summary>
        /// Get Application Errors Object
        /// </summary>
        protected ApplicationErrors AppErrors
        {
            get
            {
                return ConfigurationManager.Instance.AppErrors;
            }
        }
*/
        #endregion

        #region Auditing and Exception Management

        #region Exception Publishing

        /// <summary>
        /// Write exception into the log
        /// </summary>
        /// <param name="ex">Exception</param>
        /// <param name="messageID">Message relation ID (error category)</param>
        /// <param name="transactionID">Transaction ID (subcategory for search proposes)</param>
        protected void PublishException(Exception ex,
            string messageID,
            string transactionID,
            string systemID)
        {
            NameValueCollection nvc = new NameValueCollection();

            /*nvc.Add(LogAdditionalInfo.UserName.ToString(), AppContextHelper.UserName);
            nvc.Add(LogAdditionalInfo.OperatorName.ToString(), AppContextHelper.OperatorName);
            nvc.Add(LogAdditionalInfo.RequestedURL.ToString(), AppContextHelper.RequestUrl);
            nvc.Add(LogAdditionalInfo.MessageID.ToString(), ((int)messageID).ToString());
            nvc.Add(LogAdditionalInfo.TransactionGUID.ToString(), transactionID);
            nvc.Add(LogAdditionalInfo.SystemID.ToString(), systemID);*/

            //Microsoft.ApplicationBlocks.ExceptionManagement.ExceptionManager.Publish(ex, nvc);
        }

        /// <summary>
        /// Write exception into the log
        /// </summary>
        /// <param name="ex">Exception</param>
        /// <param name="messageID">Message relation ID</param>
        protected void PublishException(Exception ex,
            string messageID)
        {
            PublishException(ex, messageID, "", "");
        }

        /// <summary>
        /// Write exception into the log
        /// </summary>
        /// <param name="ex">Exception</param>
        protected void PublishException(Exception ex)
        {
            PublishException(ex);
        }

        #endregion

        /*
				#region Write Log Messages

				/// <summary>
				/// Writes messages to the Log
				/// </summary>
				/// <param name="messageType">Type of the message (severity)</param>
				/// <param name="messageID">Message ID</param>
				/// <param name="messageDetails">Content of the message</param>
				/// <param name="transactionGUID">Some unique value to identify a transaction</param>
				/// <param name="methodBase">MethodBase object of the method which called the Logger</param>
				protected void LogMessage(string messageType,
					string messageID,
					string messageDetails,
					string transactionGUID,
					string systemID,
					System.Reflection.MethodBase methodBase)
				{
					Auditing.Instance.WriteMessage(messageType, 
						((int)messageID).ToString(),
						messageDetails,
						AppContextHelper.UserName,
						AppContextHelper.OperatorName,
						transactionGUID,
						AppContextHelper.RequestUrl,
						systemID,
						methodBase);
				}

				/// <summary>
				/// Writes messages to the Log
				/// </summary>
				/// <param name="messageType">Type of the message (severity)</param>
				/// <param name="messageID">Message ID</param>
				/// <param name="messageDetails">Content of the message</param>
				/// <param name="transactionGUID">Some unique value to identify a transaction</param>
				/// <param name="methodBase">MethodBase object of the method which called the Logger</param>
				protected void LogMessage(string messageType,
					string messageID,
					string messageDetails,
					System.Reflection.MethodBase methodBase)
				{
					LogMessage(messageType, messageID, messageDetails,
						"", "", methodBase);
				}

				/// <summary>
				/// Writes messages to the Log
				/// </summary>
				/// <param name="messageID">Message ID</param>
				/// <param name="messageDetails">Content of the message</param>
				/// <param name="transactionGUID">Some unique value to identify a transaction</param>
				/// <param name="methodBase">MethodBase object of the method which called the Logger</param>
				protected void LogMessage(string messageID,
					string messageDetails,
					string transactionGUID,
					string systemID,
					System.Reflection.MethodBase methodBase)
				{
					LogMessage(LogMessageTypes.Information, messageID, messageDetails,
						transactionGUID, systemID, methodBase);
				}

				/// <summary>
				/// Writes messages to the Log
				/// </summary>
				/// <param name="messageID">Message ID</param>
				/// <param name="messageDetails">Content of the message</param>
				/// <param name="methodBase">MethodBase object of the method which called the Logger</param>
				protected void LogMessage(string messageID,
					string messageDetails,
					System.Reflection.MethodBase methodBase)
				{
					LogMessage(LogMessageTypes.Information, messageID, messageDetails,
						"", "", methodBase);
				}

				#endregion
		*/
        #endregion

        #region Extract Error Description
        /*
				/// <summary>
				/// Returns error description according to it's ID
				/// </summary>
				/// <param name="p_errorID">Error ID</param>
				/// <returns>Error description</returns>
				public static string GetErrorDescription(string p_errorID)
				{
					return ConfigurationManager.Instance.AppErrors.GetErrorDescription(p_errorID);
				}

				/// <summary>
				/// Returns error description according to it's ID
				/// </summary>
				/// <param name="p_errorID">Error ID</param>
				/// <returns>Error description</returns>
				public static string GetErrorDescription(int p_errorID)
				{
					return ConfigurationManager.Instance.AppErrors.GetErrorDescription(p_errorID);
				}

		
				/// <summary>
				/// Returns error description according to it's ID
				/// </summary>
				/// <param name="p_errorID">Error ID</param>
				/// <returns>Error description</returns>
				public static string GetErrorDescription(string p_errorID)
				{
					return ConfigurationManager.Instance.AppErrors.GetErrorDescription(p_errorID);
				}
		*/
        #endregion

        public IDataParameter[] GetInputParameters(string spName, object[] parametersValues)
        {
            //create command parameters and assign the parameters
            IDataParameter[] paramsToReturn = null;

            try
            {
                //get connection by provided connection type
                IDbConnection cnn = GetConnectionByType(ConnectionType.Read);

                //get Helper object by it's type
                AdoHelper helper = GetAdoHelperByConnectionType(ConnectionType.Read);


                //helper list
                List<IDataParameter> inputParamsList = new List<IDataParameter>();

                IDataParameter[] allParamsFromHelper = helper.GetSpParameterSet(cnn, spName);
                foreach (IDataParameter param in allParamsFromHelper)
                {
                    //we assign  params that are ReturnValue just so the AssignParameterValues will work
                    //properly ( the lenght of the  parametersValues has to equal to amount of the paramaters themselves )  we don't really need it otherwise
                    if (param.Direction == ParameterDirection.Input)
                    {
                        inputParamsList.Add(param);
                    }
                }
                //IDataParameter[] paramsToReturn = helper.GetSpParameterSet(cnn, spName);
                paramsToReturn = inputParamsList.ToArray();
                helper.AssignParameterValues(paramsToReturn, parametersValues);
            }
            catch (Exception ex)
            {
                paramsToReturn = new IDataParameter[] { };
                
            }           

            return paramsToReturn;
        }

        protected override int ExecuteNonQuery(IDbTransaction trans, string spName, ConnectionType ConnectionType, ref object[] outputParams, params object[] parameters)
        {
            int result =  base.ExecuteNonQuery(trans, spName, ConnectionType, ref outputParams, parameters);

            DBActionNotification.RaiseOnExecNonQuerySPCalled(spName);

            return result;
        }

        protected override int ExecuteNonQuery(string spName, ConnectionType ConnectionType, ref object[] outputParams, params object[] parameters)
        {
            int result = base.ExecuteNonQuery(spName, ConnectionType, ref outputParams, parameters);

            // gitit, 11.1.10: change to Clalit.Infrastucture.Dal
            DBActionNotification.RaiseOnExecNonQuerySPCalled(spName);

            return result;
        }
    }
}
