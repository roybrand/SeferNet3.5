using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace SeferNet.DataLayer.Base
{
    public class SqlDalEx:SqlDal
    {
        public SqlDalEx():base(ConnectionHandler.ResolveConnStrByLang())
        {

        }
    }
}
