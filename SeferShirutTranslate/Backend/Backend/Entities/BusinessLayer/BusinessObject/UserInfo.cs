namespace Backend.Entities.BusinessLayer.BusinessObject
{
    public class UserInfo
    {
        #region Properties

        public Int64 UserID { get; set; }

        public string Domain { get; set; }

        public string UserAD { get; set; }

        public string UserNameWithPrefix { get; set; }

        public string FirstName { get; set; }

        public string LastName { get; set; }

        public string Name { get; set; }

        public string Title { get; set; }

        public string Phone { get; set; }

        public string PhoneMobile { get; set; }

        public string Fax { get; set; }

        public string Mail { get; set; }

        public int DistrictCode { get; set; }

        public bool DefinedInAD { get; set; }

        public string Description { get; set; }

        public bool IsAdministrator { get; internal set; }

        public string NameForLog { get; internal set; }

        public List<int> UserDepts { get; set; }

        public Error Error { get; set; }

        #endregion

        public UserInfo()
        {
            this.UserID = -1;
            this.DistrictCode = -1;
            this.Error = new Error();
        }

        public UserInfo(int errorNumber)
        { 
            this.UserID = -1;
            this.DistrictCode = -1;
            this.Error = new Error(errorNumber);
        }
    }
}
