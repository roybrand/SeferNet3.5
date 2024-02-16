using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SPS
{
    /// <summary>
    /// Represents the SPS service input class
    /// </summary>
    public class SPServiceSenderParameters
    {
        /// <summary>
        /// Gets or sets location name
        /// </summary>
        public string LocationName { get; set; }

        /// <summary>
        /// Gets or sets latitude
        /// </summary>
        public string Latitude { get; set; }

        /// <summary>
        /// Gets or sets longitude
        /// </summary>
        public string Longitude { get; set; }

        /// <summary>
        /// Gets or sets adress of the place
        /// </summary>
        public string Address { get; set; }

        /// <summary>
        /// Gets or sets the all additional info
        /// </summary>
        public string ExtraInformation { get; set; }

        /// <summary>
        /// Gets or sets department id 
        /// </summary>
        public double DepartmentId { get; set; }

        /// <summary>
        /// Returns the parameters and values string
        /// </summary>
        /// <returns></returns>
        public override string ToString()
        {
            return string.Format(
                "LocationName: {0}; Latitude: {1}; Longitude: {2}; " +
                "Address: {3}; ExtraInformation: {4}; idDepartment {5}",
                LocationName, Latitude, Longitude,
                Address, string.IsNullOrEmpty(ExtraInformation) ? "" : ExtraInformation, DepartmentId.ToString());
        }
    }
}
