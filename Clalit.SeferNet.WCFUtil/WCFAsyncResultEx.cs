using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Clalit.SeferNet.WCFUtil
{
    /// <summary>
    /// this class is used to return the result of an asyncronized action of wcf service, it lets the user 
    /// enter input and get  result of the action
    /// </summary>
    public   class WCFAsyncResultEx : WCFAsyncResult
    {
        public object Input { get; set; }

        public object Result { get; set; }

        public WCFAsyncResultEx(object input, AsyncCallback callback,
            object state)
            : base(callback, state)
        {
            Input = input;
        }
    }
}
