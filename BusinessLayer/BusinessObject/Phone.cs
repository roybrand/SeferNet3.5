using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;

namespace SeferNet.BusinessLayer.BusinessObject
{
    public class Phone
    {
        private int _prePrefix = -1;
        private int _preFix = -1;
        private int _phone = -1;
        private int _extension = -1;
        private bool _isUnListed;
        private int _phoneType;


        #region Properties

        public int PhoneType
        {
            get
            {
                return _phoneType;
            }
            set
            {
                _phoneType = value;
            }
        }

        public bool IsUnListed
        {
            get
            {
                return _isUnListed;
            }
            set
            {
                _isUnListed = value;
            }
        }

        public int Extension
        {
            get
            {
                return _extension;
            }
            set
            {
                _extension = value;
            }
        }

        public int PhoneNumber
        {
            get
            {
                return _phone;
            }
            set
            {
                _phone = value;
            }
        }

        public int PreFix
        {
            get
            {
                return _preFix;
            }
            set
            {
                _preFix = value;
            }
        }

        public int PrePrefix
        {
            get
            {
                return _prePrefix;
            }
            set
            {
                _prePrefix = value;
            }
        }

        #endregion

        /// <summary>
        ///
        /// </summary>
        /// <param name="row">data row object in the same format from phone grid control to set all the properties</param>
        public Phone(DataRow row)
        {
            if (row.Table.Columns.Contains("PhoneType"))
            {
                if (row["PhoneType"] != DBNull.Value)
                {
                    _phoneType = Convert.ToInt32(row["PhoneType"]);
                }
            }

            if (row.Table.Columns.Contains("PrePreFix"))
            {
                if (row["PrePreFix"] != DBNull.Value)
                {
                    _prePrefix = Convert.ToInt32(row["PrePreFix"]);
                }
            }

            if (row.Table.Columns.Contains("PreFixCode"))
            {
                if (row["PreFixCode"] != DBNull.Value)
                {
                    _preFix = Convert.ToInt32(row["PreFixCode"]);
                }
            }

            if (row.Table.Columns.Contains("Phone"))
            {
                if (row["Phone"] != DBNull.Value)
                {
                    _phone = Convert.ToInt32(row["Phone"]);
                }
            } 

            if (row.Table.Columns.Contains("Extension"))
            {
                if (row["Extension"] != DBNull.Value)
                {
                    _extension = Convert.ToInt32(row["Extension"]);
                }
            }
        }


        public static void CreateTableStructure(ref DataTable phoneTable)
        {
            phoneTable.Columns.Add("phoneID", typeof(int));
            phoneTable.Columns.Add("phoneOrder", typeof(int));
            phoneTable.Columns.Add("prePrefix", typeof(int));
            phoneTable.Columns.Add("prefixCode", typeof(int));
            phoneTable.Columns.Add("prefixText", typeof(string));
            phoneTable.Columns.Add("phone", typeof(int));
            phoneTable.Columns.Add("extension", typeof(int));
            phoneTable.Columns.Add("phoneType", typeof(int));
            phoneTable.Columns.Add("remark", typeof(string));
        }
    }
}
