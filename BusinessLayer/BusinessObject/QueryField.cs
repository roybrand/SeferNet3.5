using System;
using System.Collections.Generic;
using System.Text;

namespace SeferNet.BusinessLayer.BusinessObject
{
    public class QueryField
    {
        string controlName;
        string fieldName;
        string fieldValue;

        public string ControlName
        {
            get { return controlName; }
            set { controlName = value; }
        }

        public string FieldName
        {
            get { return fieldName; }
            set { fieldName = value; }
        }

        public string FieldValue
        {
            get { return fieldValue; }
            set { fieldValue = value; }
        }

        
    }
}
