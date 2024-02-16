using System;
using System.Collections.Generic;
using System.Text;
using System.Data; 


namespace SeferNet.BusinessLayer.BusinessObject
{
    [Serializable]
    public class doctor
    {
        private string m_Connstr; 

        private int m_doctorId;
        private string m_firstName;
        private string m_lastName;


        public doctor(string p_ConnStr)
        {
            m_Connstr = p_ConnStr; 
        }


        public int doctorId
        {
            get { return m_doctorId; }
            set { m_doctorId = value; }
        }

        public string firstName
        {
            get { return m_firstName; }
            set { m_firstName = value; }
        }

        public string lastName
        {
            get { return m_lastName; }
            set { m_lastName = value; }
        }


        #region EmployeeReception
        public void GetEmployeeReceptions(ref DataSet p_ds, long p_EmployeeCode, int? p_deptCode)
        {
            SeferNet.DataLayer.DoctorDB docdb = new SeferNet.DataLayer.DoctorDB();

            docdb.GetEmployeeReceptions(ref p_ds, p_EmployeeCode, p_deptCode); 
        }

        #endregion 

       

        public void GetEmployeeGeneralData(ref DataSet p_ds, int p_EmployeeCode)
        {
            SeferNet.DataLayer.DoctorDB docdb = new SeferNet.DataLayer.DoctorDB();

            docdb.GetEmployeeGeneralData(ref p_ds, p_EmployeeCode);
        }

    }
       
}
