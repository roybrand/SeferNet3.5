using System;
using System.Collections.Generic;
using System.Text;
using System.Transactions;

namespace SeferNet.Globals
{
    public static class TranscationScopeFactory
    {
        public static TransactionScope GetForInsertedRecords()
        {
            TransactionOptions tranOption = new TransactionOptions();
            tranOption.IsolationLevel = IsolationLevel.ReadCommitted;  
            tranOption.Timeout = TransactionManager.DefaultTimeout;
            return new TransactionScope(TransactionScopeOption.Required, tranOption);
        }

        public static TransactionScope GetForUpdatedRecords()
        {
            TransactionOptions tranOption = new TransactionOptions();
            tranOption.IsolationLevel = IsolationLevel.ReadCommitted;  
            tranOption.Timeout = TransactionManager.DefaultTimeout;
            return new TransactionScope(TransactionScopeOption.Required, tranOption);
        }

        public static TransactionScope GetForDeleteRecords()
        {
            //default is serializable!!!
            //which is the most strict - that's what we want when we delete
            return new TransactionScope(TransactionScopeOption.Required);
        }
    }
}
