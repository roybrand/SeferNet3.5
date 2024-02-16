using System;
using System.Collections.Generic;
using System.Text;
using SeferNet.BusinessLayer.BusinessObject;

namespace SeferNet.BusinessLayer.WorkFlow
{
    public class QueryParamManager
    {
        List<QueryParam> QueryParamList;
        public QueryParamManager()
        {
            QueryParamList = new List<QueryParam>();
        }

        public void AddQueryParam(QueryParam param)
        {
            QueryParamList.Add(param);
        }

        public void RemoveQueryParam(QueryParam param)
        {
            QueryParamList.Remove(param);
        }

        public void ClearQueryParamList()
        {
            QueryParamList.Clear();
        }

        public List<QueryParam> getQueryParamList()
        {
            return QueryParamList;
        }

       
    }
}
