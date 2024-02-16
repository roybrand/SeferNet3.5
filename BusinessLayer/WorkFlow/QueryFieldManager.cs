using System;
using System.Collections.Generic;
using System.Text;
using SeferNet.BusinessLayer.BusinessObject;

namespace SeferNet.BusinessLayer.WorkFlow
{
    public class QueryFieldManager
    {
        List<QueryField> QueryFielaList;
        public QueryFieldManager()
        {
            QueryFielaList = new List<QueryField>();
        }

        public void AddQueryParam(QueryField field)
        {
            QueryFielaList.Add(field);
        }

        public void RemoveQueryParam(QueryField field)
        {
            QueryFielaList.Remove(field);
        }

        public void ClearQueryParamList()
        {
            QueryFielaList.Clear();
        }

        public List<QueryField> getQueryFieldList()
        {
            return QueryFielaList;
        }
       
    }
}
