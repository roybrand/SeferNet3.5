namespace Backend.Entities.BusinessLayer.BusinessObject
{
    public class Error
    {
        public int Number { get; set; }
        public string Message { get; set; }

        public Error() 
        {
            this.Number = -1;
            this.Message = string.Empty;
        }
        
        public Error(int number) 
        {
            this.Number = number;
            this.Message = this.getMessage(this.Number);
        }

        private string getMessage(int number)
        {
            switch (number)
            {
                case 0:
                    return string.Empty;
                
                case 1:
                    return "לא ניתן לאמת את פרטי המשתמש";

                case 2:
                    return "בעיה בחיבור";

                default:
                    return string.Empty;
            }
        }
    }
}
