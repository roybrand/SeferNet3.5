using System;
using System.Collections.Generic;
using System.Text;

namespace SeferNet.BusinessLayer.BusinessObject
{
    public class QueryParam
    {
        string controlName;
        string fieldName;
        string fieldValue;
        string queryOperator;
        string headerControl;

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

        public string HeaderControl
        {
            get { return headerControl; }
            set { headerControl = value; }
        }

        public string FieldValue
        {
            get { return fieldValue; }
            set { fieldValue = value; }
        }
        public string QueryOperator
        {
            get { return queryOperator; }
            set { queryOperator = value; }
        }
       
    }
}
