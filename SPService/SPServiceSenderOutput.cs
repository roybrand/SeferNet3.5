using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SPS
{
    /// <summary>
    /// Represents the service output
    /// </summary>
    public class SPServiceSenderOutput
    {
        /// <summary>
        /// Gets or sets the sps service answer
        /// </summary>
        public string ServiceAnswer { get; set; }

        /// <summary>
        /// Gets or sets sps service statu code
        /// </summary>
        public string SPServiceStatusCode { get; set; }

        /// <summary>
        /// Gets or sets methods error message
        /// </summary>
        public string ErrorMessage { get; set; }
    }
}
