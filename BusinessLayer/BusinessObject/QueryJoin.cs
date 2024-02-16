using System;
using System.Collections.Generic;
using System.Text;

namespace SeferNet.BusinessLayer.BusinessObject
{
    public class QueryJoin
    {
        string joinName;
        string joinValue;
        bool isIncluded = false;

        public string JoinName
        {
            get { return joinName; }
            set { joinName = value; }
        }

        public string JoinValue
        {
            get { return joinValue; }
            set { joinValue = value; }
        }
        public bool IsIncluded
        {
            get { return isIncluded; }
            set { isIncluded = value; }

        }
    }
}
