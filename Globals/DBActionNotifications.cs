using System;
using System.Collections.Generic;
using System.Text;
using System.Data.Common;
using System.Data;

namespace SeferNet.Globals
{
    public delegate IDataParameter[] OnGetParametersDelegate(string spName, object[] paramValues);
    public delegate void OnDBActionDelegate(string spName, IDataParameter[] paramCollection);
    public delegate void OnDBActionDelegate_targeted(int target, int changeType, int districtID, int adminClinicID, int clinicID);
    public delegate void OnExecNonQuerySPCalledDelegate(string spName);

    public class DBActionNotification
    {
        public static event OnGetParametersDelegate OnGetParameters;

        public static void RegisterOnGetParametersMethod(OnGetParametersDelegate onGetParameters)
        {
            OnGetParameters -= onGetParameters;
            OnGetParameters += onGetParameters;
        }

        public static event OnDBActionDelegate OnDBUpdate;
        public static event OnDBActionDelegate OnDBInsert;
        public static event OnDBActionDelegate OnDBDelete;
        public static event OnDBActionDelegate OnDBSelect;

        public static event OnDBActionDelegate_targeted OnDBAction_targeted;

        public static event OnExecNonQuerySPCalledDelegate OnExecNonQuerySPCalled;

        public static void RaiseOnDBUpdate(string spName, object[] paramValues)
        {
            if (OnGetParameters != null)
            {
                IDataParameter[] paramCollection = OnGetParameters(spName, paramValues);

                if (OnDBUpdate != null)
                {
                    OnDBUpdate(spName, paramCollection);
                }
            }
        }

        public static void RaiseOnDBInsert(string spName, object[] paramValues)
        {
            if (OnGetParameters != null)
            {
                IDataParameter[] paramCollection = OnGetParameters(spName, paramValues);

                if (OnDBInsert != null)
                {
                    OnDBInsert(spName, paramCollection);
                }
            }
        }

        public static void RaiseOnDBDelete(string spName, object[] paramValues)
        {
            if (OnGetParameters != null)
            {
                IDataParameter[] paramCollection = OnGetParameters(spName, paramValues);

                if (OnDBDelete != null)
                {
                    OnDBDelete(spName, paramCollection);
                }
            }
        }

        public static void RaiseOnDBAction_targeted(int target_of_action, int changeType, int districtID, int adminClinicID, int clinicID)
        {
            if (OnGetParameters != null)
            {
                //IDataParameter[] paramCollection = OnGetParameters(spName, paramValues);

                if (OnDBAction_targeted != null)
                {
                    OnDBAction_targeted(target_of_action, changeType, districtID, adminClinicID, clinicID);
                }
            }
        }

        public static void RaiseOnDBSelect(string spName, object[] paramValues)
        {
            if (OnGetParameters != null)
            {
                IDataParameter[] paramCollection = OnGetParameters(spName, paramValues);

                if (OnDBSelect != null)
                {
                    OnDBSelect(spName, paramCollection);
                }
            }
        }

        public static void RaiseOnExecNonQuerySPCalled(string spName)
        {
            if (OnExecNonQuerySPCalled != null)
            {
                OnExecNonQuerySPCalled(spName);
            }
        }
    }
}
