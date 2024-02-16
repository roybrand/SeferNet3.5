using System;
using System.Xml.XPath;
using System.Xml;
using System.Data;
using System.Web.SessionState;
using System.Collections;
using System.Collections.Generic;
using System.Threading;
using System.Globalization;
using System.Web;
using System.Data.SqlClient;

/// <summary>
/// Summary description for ManagingServicesProfessionsHelper
/// </summary>

    public class _ManagingServicesProfessionsHelper
    {
        public _ManagingServicesProfessionsHelper()
        { }


       
       

        public DataTable GetListTables(string path)
        {
            DataTable tablesList = null;
            string tblNumber = String.Empty;
            string tblName = String.Empty;

            try
            {
                XPathDocument document = new XPathDocument(path);
                if (document != null)
                {
                    XPathNavigator navigator = document.CreateNavigator();
                    if (navigator != null)
                    {
                        XPathNodeIterator iterator = navigator.Select("/Administration/Tables/Table");
                        XmlNamespaceManager ns = new XmlNamespaceManager(navigator.NameTable);

                        tablesList = CreateDataTableListTables();
                        //AddNewRow(tablesList, "0", "All");  
                        while (iterator.MoveNext())
                        {
                            tblNumber = iterator.Current.GetAttribute("tableMFNumber", ns.DefaultNamespace);
                            tblName = iterator.Current.Value.Trim();
                            AddNewRow(tablesList, tblNumber, tblName);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            return tablesList;
        }


        public DataTable GetListCategories(string path, string columnName)
        {
            DataTable dtList = null;
            string value = String.Empty;
            string name = String.Empty;
            string nodePath = String.Empty;

            try
            {
                XPathDocument document = new XPathDocument(path);
                if (document != null)
                {
                    XPathNavigator navigator = document.CreateNavigator();
                    if (navigator != null)
                    {
                        if (columnName == "Category")
                            nodePath = "/Administration/Categories/Category";
                        else if (columnName == "OldCategory")
                            nodePath = "/Administration/OldCategories/OldCategory";

                        XPathNodeIterator iterator = navigator.Select(nodePath);
                        XmlNamespaceManager ns = new XmlNamespaceManager(navigator.NameTable);

                        dtList = CreateDataTable("id","desc");
                       
                        while (iterator.MoveNext())
                        {
                            value = iterator.Current.GetAttribute("value", ns.DefaultNamespace);
                            name = iterator.Current.Value.Trim();
                            AddNewRow(dtList, value, name);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            return dtList;
        }


        public DataTable GetListCategories(DataTable dt601, DataTable dt606, string columnName)
        {
            DataTable tablesList = null;

            try
            {
                Hashtable hTblCategories = new Hashtable();
                GetHashTableCategories(dt601, ref hTblCategories , columnName);
                GetHashTableCategories(dt606, ref hTblCategories, columnName);


                tablesList = new DataTable();
                DataColumn columnID = new DataColumn("tblNumber");
                DataColumn columnDesc = new DataColumn("tblName");
                tablesList.Columns.Add(columnID);
                tablesList.Columns.Add(columnDesc);

                IDictionaryEnumerator enumerator = hTblCategories.GetEnumerator();

                while (enumerator.MoveNext())
                {
                    DataRow newRow = tablesList.NewRow();
                    newRow["tblNumber"] = enumerator.Key.ToString();
                    newRow["tblName"] = enumerator.Value.ToString();
                    if (newRow["tblName"] != String.Empty)
                    tablesList.Rows.Add(newRow);
                }
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            return tablesList;
        }


        

        private SortedDictionary<string, string> BuildDictionaryItemDesc(DataTable dt, string columnCode, string columnCodeDesc, string columnCategory, bool isProfession)
        {
            string itemCode = String.Empty;
            string itemDesc = String.Empty;
            string category = String.Empty;

            SortedDictionary<string, string> hDictionaryItemDesc = new SortedDictionary<string, string>();

            foreach (DataRow curRow in dt.Rows)
            {
                itemCode = curRow[columnCode].ToString();
                itemDesc = curRow[columnCodeDesc].ToString();
                category = curRow[columnCategory].ToString();
                if (isProfession)
                {
                    if (category == GetResources(@"~/Admin/ManagingServicesProfessions.aspx" ,"Profession"))
                    {
                        hDictionaryItemDesc[itemCode] = itemDesc;
                    }
                }
                else
                {
                    if (category == GetResources(@"~/Admin/ManagingServicesProfessions.aspx" ,"Service"))
                    {
                        hDictionaryItemDesc[itemCode] = itemDesc;
                    }
                }
            }

            return hDictionaryItemDesc;
        }

        public Dictionary<string, string> GetListCode(DataTable dt601, DataTable dt606, string columnCode, string columnCodeDesc)
        {
            //DataTable tablesList = null;
            Dictionary<string, string> dicParentCode = new Dictionary<string, string>();
            Dictionary<string, string> dicParentCode601 = new Dictionary<string, string>();
            Dictionary<string, string> dicParentCode606 = new Dictionary<string, string>();


            try
            {
                ArrayList arrCode = GetArrayCodes(dt601, dt606, columnCode);

                //return  dictionary with all parents code and their  names and save in session 
                //dictionary for table 601 and 606               
                GetDictionaryCodeDescription(dt601, dt606, arrCode, columnCode, columnCodeDesc, ref dicParentCode, ref dicParentCode601, ref dicParentCode606);

                if (columnCode == "ParentCode")
                {
                    if (dicParentCode601.Count > 0)
                    {
                        System.Web.HttpContext.Current.Session["dicParentCode601"] = dicParentCode601;
                    }
                    if (dicParentCode606.Count > 0)
                    {
                        System.Web.HttpContext.Current.Session["dicParentCode606"] = dicParentCode606;
                    }
                }
                else if (columnCode == "Sector")
                {
                    string without = GetResources(@"~/Admin/ManagingServicesProfessions.aspx" , "Without");
                    dicParentCode.Add("4", without);

                    if (dicParentCode601.Count > 0)
                    {
                        dicParentCode601.Add("4", without);
                        System.Web.HttpContext.Current.Session["dicSector601"] = dicParentCode601;
                    }
                    if (dicParentCode606.Count > 0)
                    {
                        dicParentCode606.Add("4", without);
                        System.Web.HttpContext.Current.Session["dicSector606"] = dicParentCode606;
                    }
                }
                else if (columnCode == "OldCode")
                {

                    if (dicParentCode601.Count > 0)
                    {
                        System.Web.HttpContext.Current.Session["dicOldCode601"] = dicParentCode601;
                    }
                    if (dicParentCode606.Count > 0)
                    {
                        System.Web.HttpContext.Current.Session["dicOldCode606"] = dicParentCode606;
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            return dicParentCode;
        }

        public string GetResources(string page,string p_key)
        {
            try
            {
                string value = String.Empty;
                Thread.CurrentThread.CurrentUICulture = new CultureInfo("he-IL");
                Thread.CurrentThread.CurrentCulture = new CultureInfo("he-IL");

                value = HttpContext.GetLocalResourceObject(page, p_key, Thread.CurrentThread.CurrentCulture) as string;
                return value;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }

        private ArrayList GetArrayCodes(DataTable dt601, DataTable dt606, string columnName)
        {
            //int[] arrCode = null;
            ArrayList arrCode601 = new ArrayList();
            ArrayList arrCode606 = new ArrayList();

            GetHashTableCodes(dt601, ref arrCode601, columnName);
            GetHashTableCodes(dt606, ref arrCode606, columnName);

            ArrayList arrCode = new ArrayList();//int[arrCode601.Count + arrCode606.Count];

            arrCode601.Sort();
            arrCode606.Sort();
            //errot - if i did CopyTo - arrCode doesn't include all values
            //arrCode601.CopyTo(arrCode);
            //arrCode606.CopyTo(arrCode);
            foreach (int code in arrCode601)
            {
                arrCode.Add(code);
            }
            foreach (int code in arrCode606)
            {
                arrCode.Add(code);
            }
            arrCode.Sort();
            return arrCode;
        }

        internal Dictionary<string, string> GetListSectors(DataTable dt601, DataTable dt606)
        {
            Dictionary<string, string> dicSectors = new Dictionary<string, string>();
            try
            {
                //dicSectors.Add("0", "הכל");

                //foreach (DataRow row in dt601.Rows)
                //{
                //    = row["Sector"].ToString();
                //    row["SectorDescription"].ToString();
                //}
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            return dicSectors;
        }

        private void GetHashTableCodes(DataTable dt, ref ArrayList arrCodes, string columnName)
        {
            if (dt != null)
            {
                foreach (DataRow row in dt.Rows)
                {
                    if (row[columnName] != null && row[columnName].ToString() != String.Empty)
                    {
                        int code = int.Parse(row[columnName].ToString());
                        if (!arrCodes.Contains(code))
                        {
                            arrCodes.Add(code);
                        }
                    }
                }
            }
        }

 

        private void GetDictionaryCodeDescription(DataTable dt601, DataTable dt606, ArrayList arrParentCodes, string columnCode, string columnCodeDesc, ref Dictionary<string, string> dicParentCode, ref Dictionary<string, string> dicParentCode601, ref Dictionary<string, string> dicParentCode606)
        {
            string codeDesc = String.Empty;
            string codeDescValue = String.Empty;

            dicParentCode.Add("0", GetResources(@"~/Admin/ManagingServicesProfessions.aspx", "All"));
            dicParentCode601.Add("0", GetResources(@"~/Admin/ManagingServicesProfessions.aspx","All"));
            dicParentCode606.Add("0", GetResources(@"~/Admin/ManagingServicesProfessions.aspx","All"));

            foreach (int parentCode in arrParentCodes)
            {
                codeDesc = GetCodeName(dt601, parentCode, columnCode, columnCodeDesc);

                if (string.IsNullOrEmpty(codeDesc))
                {
                    codeDesc = GetCodeName(dt606, parentCode, columnCode, columnCodeDesc);
                }

                if (columnCode != "Sector")
                    codeDescValue = parentCode.ToString() + " - " + codeDesc;
                else
                    codeDescValue = codeDesc;


                if (CheckParentCodeIndataTable(dt601, parentCode, codeDesc, columnCode))
                {
                    if (!dicParentCode601.ContainsKey(parentCode.ToString()))
                    {
                        dicParentCode601.Add(parentCode.ToString(), codeDescValue);
                    }
                }

                if (CheckParentCodeIndataTable(dt606, parentCode, codeDesc, columnCode))
                {
                    if (!dicParentCode606.ContainsKey(parentCode.ToString()))
                    {
                        dicParentCode606.Add(parentCode.ToString(), codeDescValue);
                    }
                }

                if (!string.IsNullOrEmpty(codeDesc))
                {
                    if (!dicParentCode.ContainsKey(parentCode.ToString()))
                        dicParentCode.Add(parentCode.ToString(), codeDescValue);
                }
            }

            List<string> song = new List<string>(dicParentCode.Keys);
            song.Sort();
            song = new List<string>(dicParentCode601.Keys);
            song.Sort();
            song = new List<string>(dicParentCode606.Keys);
            song.Sort();
        }

        //i check - this table contains this specific parent code or not 
        private bool CheckParentCodeIndataTable(DataTable dt, int parentCode, string codeName, string columnCode)
        {
            DataRow[] rowsParentCode = dt.Select(columnCode + " = " + parentCode);
            if (rowsParentCode != null && rowsParentCode.Length > 0)
            {
                return true;
            }
            else
                return false;
        }

       

        private string GetCodeName(DataTable dt, int parentCode, string columnCode, string codeDesc)
        {
            try
            {
                string codeName = String.Empty;

                DataRow[] rows = dt.Select(columnCode + " = " + parentCode);
                if (rows != null && rows.Length > 0)
                {
                    codeName = rows[0][codeDesc].ToString();
                }
                else
                    codeName = "";

                return codeName;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }



        private void GetHashTableCategories(DataTable dt, ref Hashtable hTblCategories , string columnName)
        {

            int count = 0;

            if (dt != null)
            {
                foreach (DataRow row in dt.Rows)
                {
                    if (row[columnName] != null)
                    {
                        string category = row[columnName].ToString();
                        if (!hTblCategories.ContainsValue(category))
                        {
                            count++;
                            hTblCategories.Add(count, category);
                        }
                    }
                }
                if (!hTblCategories.ContainsValue(GetResources(@"~/Admin/ManagingServicesProfessions.aspx","All")))
                {
                    count++;
                    hTblCategories.Add(count, GetResources(@"~/Admin/ManagingServicesProfessions.aspx","All"));
                }
            }
        }

        public DataTable GetListCategoriesNames(string path)
        {
            DataTable tablesList = null;
            string tblNumber = String.Empty;
            string tblName = String.Empty;

            try
            {
                XPathDocument document = new XPathDocument(path);
                if (document != null)
                {
                    XPathNavigator navigator = document.CreateNavigator();
                    if (navigator != null)
                    {
                        XPathNodeIterator iterator = navigator.Select("/Administration/ServicesNames/Service");
                        XmlNamespaceManager ns = new XmlNamespaceManager(navigator.NameTable);

                        tablesList = CreateDataTableListTables();
                        AddNewRow(tablesList, "0", "");
                        while (iterator.MoveNext())
                        {
                            tblNumber = iterator.Current.GetAttribute("tableName", ns.DefaultNamespace);
                            tblName = iterator.Current.Value.Trim();
                            AddNewRow(tablesList, tblNumber, tblName);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            return tablesList;
        }


        public string GetNode(string path, string nodeName)
        {
            string nodeValue = String.Empty;

            try
            {
                XPathDocument document = new XPathDocument(path);
                if (document != null)
                {
                    XPathNavigator navigator = document.CreateNavigator();
                    if (navigator != null)
                    {
                        XPathNodeIterator iterator = navigator.Select(nodeName);
                        XmlNamespaceManager ns = new XmlNamespaceManager(navigator.NameTable);

                        while (iterator.MoveNext())
                        {
                            nodeValue = iterator.Current.Value.Trim();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            return nodeValue;
        }


        private static void AddNewRow(DataTable tablesList, string tblNumber, string tblName)
        {
            DataRow row = tablesList.NewRow();
            row[0] = tblNumber;
            row[1] = tblName;
            tablesList.Rows.Add(row);
        }


        public DataTable CreateDataTableListTables()
        {
            DataTable tablesList = null;

            try
            {
                //tablesList = new DataTable();
                //DataColumn columnID = new DataColumn("tblNumber");
                //DataColumn columnName = new DataColumn("tblName");
                //tablesList.Columns.Add(columnID);
                //tablesList.Columns.Add(columnName);
                tablesList = CreateDataTable("tblNumber", "tblName");

            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            return tablesList;
        }

        public DataTable CreateDataTable(string columnCode, string columnDesc)
        {
            DataTable tablesList = null;

            try
            {
                tablesList = new DataTable();
                DataColumn columnID = new DataColumn(columnCode);
                DataColumn columnName = new DataColumn(columnDesc);
                tablesList.Columns.Add(columnID);
                tablesList.Columns.Add(columnName);

            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            return tablesList;
        }

        public DataTable GetSelectedData(DataTable dtNew, string columnName, string code)
        {
            DataTable dtResult = null;
            try
            {
                string filter = columnName + " like '%" + code + "%'";
                DataRow[] rows = dtNew.Select(filter);
                if (rows != null && rows.Length > 0)
                {
                    dtResult = rows.CopyToDataTable();
                }
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            return dtResult;
        }




    }

