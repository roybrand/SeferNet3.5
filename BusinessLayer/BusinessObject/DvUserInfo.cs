using System;
using System.Collections.Generic;
using System.Text;

namespace SeferNet.BusinessLayer.BusinessObject
{
    public class DvUserInfo
    {
        private string userName;
        public string UserName
        {
            get { return userName; }
            set { userName = value; }
        }

        private string firstName;
        public string FirstName
        {
            get { return firstName; }
            set { firstName = value; }
        }

        private string lastName;
        public string LastName
        {
            get { return lastName; }
            set { lastName = value; }
        }

        private string phoneNumber;
        public string PhoneNumber
        {
            get { return phoneNumber; }
            set { phoneNumber = value; }
        }

        private string userDescription;
        public string UserDescription
        {
            get { return userDescription; }
            set { userDescription = value; }
        }

    }
}
