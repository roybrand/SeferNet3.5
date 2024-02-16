using System;
using System.Collections.Generic;
using System.Text;

namespace SeferNet.BusinessLayer.BusinessObject
{
    public class Dept
    {
        int m_DeptCode;
        deptType m_DeptType;


        public Dept()
        {

        }
        public Dept(int deptCode)
        {
            this.m_DeptCode = deptCode;
        }
        public int DeptCode
        {
            get { return m_DeptCode; }
            set { m_DeptCode = value; }
        }

        public deptType DeptType
        {
            get { return m_DeptType; }
            set { m_DeptType = value; }
        }

        public bool IsDistrict
        {
            get
            {
                return (this.m_DeptType == deptType.District); 
                
            }
            
        }

        public bool IsAdministration
        {
            get
            {
                return (this.m_DeptType == deptType.Administration);
                   
            }

        }

        public bool IsClinic
        {
            get
            {
                return (this.m_DeptType == deptType.Clinic);
                    
            }

        }

        public bool IsCommunity { get; set; }
        
        public bool IsMushlam { get; set; }
                        
        public bool IsHospital { get; set; }


	
    }
}
