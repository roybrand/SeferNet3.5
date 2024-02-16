using System;
using System.Collections.Generic;
using System.Text;
using SeferNet.BusinessLayer.BusinessObject;

namespace SeferNet.BusinessLayer.WorkFlow
{
    public class QueryJoinManager
    {
        List<QueryJoin> QueryJoinList;
        public QueryJoinManager()
        {
            QueryJoinList = new List<QueryJoin>();
        }

        public void AddQueryJoin(QueryJoin join)
        {
            QueryJoinList.Add(join);
        }

        public void RemoveQueryParam(QueryJoin join)
        {
            QueryJoinList.Remove(join);
        }

        public void ClearQueryLoinList()
        {
            QueryJoinList.Clear();
        }

        public List<QueryJoin> getQueryJoinList()
        {
            return QueryJoinList;
        }
       
    }
}
