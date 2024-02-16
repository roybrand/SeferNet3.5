using System;
using System.Collections.Generic;
using System.Text;
using SeferNet.BusinessLayer.BusinessObject;
using System.Data;
using System.Web;
using Clalit.SeferNet.GeneratedEnums;
using Clalit.Infrastructure.ServiceInterfaces;
using Clalit.Infrastructure.ServicesManager;


namespace SeferNet.BusinessLayer.WorkFlow
{
    public class QueryGenerator
    {        
        List<QueryParam> QueryParamList;
        List<QueryField> QueryFieldList;
        List<QueryJoin>  QueryJoinList;

        public virtual string generateQuery(string leadingTable)    
        {
            string selectClause = generateSelectClause();
            if (selectClause == string.Empty)
            {
                throw new ApplicationException("No Fields were selected for report");
            }
            string fromClause = genereateFromClause(leadingTable);
            string whereClause = generateWhereClause();
            StringBuilder queryBuilder = new StringBuilder(selectClause);
            queryBuilder.Append(" ");
            queryBuilder.Append(fromClause);
            queryBuilder.Append(" ");
            queryBuilder.Append(whereClause);
            return queryBuilder.ToString();
        }

        #region select
        protected virtual string generateSelectClause()
        {
            getFieldListFromSession();
            return buildSelectClause();
        }

        private string buildSelectClause()
        {
            if (QueryFieldList == null)
                return string.Empty;
            if (QueryFieldList.Count == 0)
                return string.Empty;
            StringBuilder selectBuilder = new StringBuilder("SELECT DISTINCT ");
            for (int i = 0; i < QueryFieldList.Count; i++)
            {
                selectBuilder.Append(QueryFieldList[i].FieldName);
                if (i!=QueryFieldList.Count-1)
                    selectBuilder.Append(",");
            }
            return selectBuilder.ToString();
        }

        
       private void getFieldListFromSession()
        {
            SessionParams sessionParams = SessionParamsHandler.GetSessionParams();
            QueryFieldList = sessionParams.queryFieldsList;
        }
        #endregion

        #region from

        protected virtual string genereateFromClause(string leadingTable)
        {
            getJoinListFromSession();
            return buildFromClause(leadingTable);
        }
        private string buildFromClause(string leadingTable)
        {
            if (QueryJoinList == null)
                return " FROM " + leadingTable;
            if (QueryJoinList.Count == 0)
                return " FROM " + leadingTable;
            List<QueryJoin> orderedQueryJoinsList = new List<QueryJoin>();

            ICacheService cacheHandler = ServicesManager.GetService<ICacheService>();
            DataTable tbl = cacheHandler.getCachedDataTable(eCachedTables.ReportJoins.ToString());
            StringBuilder fromBuilder = new StringBuilder(" FROM ");
            fromBuilder.Append(leadingTable);
            fromBuilder.Append(" ");
            DataRow[] rows;
            foreach (QueryJoin joinItem in QueryJoinList)
            {

                string joinkey = joinItem.JoinName;
                rows = tbl.Select("joinKey ='" + joinItem.JoinName + "'");
                joinItem.JoinValue = rows[0]["joinClause"].ToString();
                //fromBuilder.Append(rows[0]["joinClause"].ToString());
                //fromBuilder.Append(" ");
            }
            for (int j = 0; j < QueryJoinList.Count; j++)
            {
                foreach (QueryJoin joinItem in QueryJoinList)
                {
                    if (joinItem.IsIncluded)
                        continue;
                    int OnIndex = joinItem.JoinValue.ToUpper().IndexOf(" ON ");
                    string strAfterOn = joinItem.JoinValue.Substring(OnIndex + 4, joinItem.JoinValue.Length - (OnIndex + 4)).Trim();
                    string TableName1 = strAfterOn.Substring(0, strAfterOn.IndexOf('.')).ToUpper().Trim();
                    int EqualIndex = joinItem.JoinValue.ToUpper().IndexOf("=");
                    string strAfterEqual = joinItem.JoinValue.Substring(EqualIndex + 1, joinItem.JoinValue.Length - (EqualIndex + 1) ).Trim();
                    string TableName2 = strAfterEqual.Substring(0, strAfterEqual.IndexOf('.')).ToUpper().Trim();

                    if (joinItem.JoinValue.ToUpper().Contains(leadingTable.ToUpper() + ".") ||
                        IsJoinTableContained(orderedQueryJoinsList, TableName1) || IsJoinTableContained(orderedQueryJoinsList, TableName2))
                    {
                        QueryJoin newJoinItem = new QueryJoin();
                        newJoinItem.JoinName = joinItem.JoinName;
                        newJoinItem.JoinValue = joinItem.JoinValue;
                        orderedQueryJoinsList.Add(newJoinItem);
                        joinItem.IsIncluded = true;
                    }

                }
            }

            for (int i = 0; i < orderedQueryJoinsList.Count; i++ )
            {
                fromBuilder.Append(orderedQueryJoinsList[i].JoinValue);
                //fromBuilder.Append(rows[0]["joinClause"].ToString());
                fromBuilder.Append(" ");
            }
            
            return fromBuilder.ToString();

        }
        private bool IsJoinTableContained(List<QueryJoin> orderedQueryJoinsList,string TableName)
        {
            foreach (QueryJoin joinItem in orderedQueryJoinsList)
            {
                if (joinItem.JoinValue.ToUpper().Contains(TableName))
                    return true;
            }
            return false;
        }
        private void getJoinListFromSession()
        {
            SessionParams sessionParams = SessionParamsHandler.GetSessionParams();
            QueryJoinList = sessionParams.queryJoinList;
        }
        #endregion

        #region where
        protected virtual string generateWhereClause()
        {
            getQueryParamListFromSession();
            return buildWhereClause();

        }
        private void getQueryParamListFromSession()
        {
            SessionParams sessionParams = SessionParamsHandler.GetSessionParams();
            QueryParamList = sessionParams.queryParamsList; 
        }

        private string buildWhereClause()
        {
            if (QueryParamList == null)
                return string.Empty;
            if (QueryParamList.Count==0)
                return string.Empty;

            StringBuilder whereClauseBuilder;
            
            whereClauseBuilder = new StringBuilder(" Where ");
            appendWhereCondition(whereClauseBuilder, QueryParamList[0]);

            for (int i=1; i<QueryParamList.Count;i++)
            {
                whereClauseBuilder.Append(" and ");

                appendWhereCondition(whereClauseBuilder, QueryParamList[i]);
                
                whereClauseBuilder.Append(" ");
            }

            return whereClauseBuilder.ToString();
        }

        private void appendWhereCondition(StringBuilder whereClauseBuilder, QueryParam queryParam )
        {
            whereClauseBuilder.Append(queryParam.FieldName);

            if (queryParam.QueryOperator == null)
                {
                    whereClauseBuilder.Append(" = ");
                    whereClauseBuilder.Append(queryParam.FieldValue);
                }
                else
                {
                    if (queryParam.QueryOperator == "like")
                    {
                        string strExpression = " like " + "'" + queryParam.FieldValue + "%'";
                        whereClauseBuilder.Append(strExpression);
                    }
                    else
                    {

                    }
                }
        }
        #endregion


       

    }
}
