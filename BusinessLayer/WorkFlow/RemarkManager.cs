using System;
using System.Collections.Generic;
using System.Text;
using SeferNet.DataLayer;
using System.Data;
using System.Text.RegularExpressions;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Linq;

namespace SeferNet.BusinessLayer.WorkFlow
{
    public class RemarkManager
    {
        string m_ConnStr;

        public RemarkManager()
        {
            m_ConnStr = ConnectionHandler.ResolveConnStrByLang(); 
        }

        /// <summary>
        /// replaces all the places for input parameter with "..."
        /// </summary>
        /// <param name="remark">remark format text</param>
        /// <returns></returns>
        public string GetRemarkTextForView(string remark)
        {
            Regex regex = new Regex(@"[#](?<text>.*?)[#]");
            return regex.Replace(remark, "...");
        }

        public string GetRemarkTextForEdit(string remark)
        {
            Regex regex = new Regex(@"[#](?<text>.*?)[#]");

            string replace = String.Format(@"<span  style={0}visibility:hidden{0}>#</span><div runat={0}server{0} style={0}border:1px solid black;display:inline; background-color:white;width:50px; overflow:hidden;height:20px{0} contenteditable></div><span  style={0}visibility:hidden{0}>#</span>", '\u0022');

            remark = regex.Replace(remark, replace);

            return remark;
        }


        /// <summary>
        /// set the values in the list inside the appropriate place in the remark text format
        /// </summary>
        /// <param name="remark">remark text format</param>
        /// <param name="list">list of values to insert to remark body</param>
        /// <returns>remark text</returns>
        public string SetRemarkTextToDB(string remark, List<string> list)
        {
            StringBuilder sb = new StringBuilder();
            Regex regex = new Regex(@"[#](?<text>.*?)[#]");
            MatchCollection col = regex.Matches(remark);
            int index = 0;

            foreach (Match match in col)
            {
                remark = remark.Replace(match.Value, "#" + list[index] + "#");
                index++;
            }

            return remark;
        }


        public string[] SplitRemarkTextByFormat(string remarkText)
        {
            Regex regex = new Regex(@"[#]\d+[#]");
            return regex.Split(remarkText);           
        }


        public string[] SplitRemarkTextWithValuesInserted(string remarkText)
        {
            Regex regex = new Regex(@"[#](?<text>.*?)[#]");
            MatchCollection col = regex.Matches(remarkText);

            foreach (Match mat in col)
            {
                remarkText = remarkText.Replace(mat.Value, "~");
            }

            return remarkText.Split('~');
        }


        public string[] GetInsertedValuesFromText(string remarkText)
        {
            Regex regex = new Regex(@"[#](?<text>.*?)[#]");
            MatchCollection col = regex.Matches(remarkText);
            string[] arr = new string[col.Count];
            int index = 0;

            foreach (Match mat in col)
            {
                arr[index] = mat.Value.Replace("#","");
                index++;
            }

            return arr;                     
        }

        public string getFormatedRemark(string remarkText)
        {
            string res = "";
            string pattern = @"[#](?<text>.*?)[#]";

            string[] arrPlainText = Regex.Split(remarkText, pattern);

            foreach (string plainText in arrPlainText)
            {

                if (res == "")
                {
                    res += plainText.Split('~')[0];
                }
                else
                {
                    res += " " + plainText.Split('~')[0];
                }

            }

            return res;
        }

        public HtmlTable getSimpleText(string value, string ind, bool newRow, string rowClientID, ref string listOfInputID)
        {
            HtmlTable table = getTable();
            HtmlTableRow tr = new HtmlTableRow();
            HtmlTableCell td = new HtmlTableCell();
            HtmlGenericControl span = new HtmlGenericControl("span");




            table.Style.Add("height", "25px");

            if (!newRow)
            {
                td.Style.Add("width", "3px");
                tr.Controls.Add(td);


            }
            td = new HtmlTableCell();
            td.Style.Add("padding", "0");
            span.ID = "spanSimple_" + ind;
            span.InnerHtml = value;

            setListOfInputIDs(rowClientID + "_" + span.ID, "", ref listOfInputID);

            td.Controls.Add(span);
            tr.Controls.Add(td);

            td = new HtmlTableCell();
            td.Style.Add("width", "3px");
            tr.Controls.Add(td);

            table.Controls.Add(tr);

            return table;
        }


        public HtmlInputText getTextBox(string id, string value, string width)
        {
            HtmlInputText text = new HtmlInputText();
            text.ID = id;
            text.Style.Add("width", width);
            text.Attributes.Add("class", "TextBoxRegular");
            text.Value = value;

            return text;
        }

        public HtmlInputText getTextBoxChangeableLength(string id, string value, int maxwidth)
        {
            HtmlInputText text = new HtmlInputText();
            text.ID = id;
            int width = (int)(value.Length * 7);
            if (width > maxwidth)
                width = maxwidth;
            text.Style.Add("width", width.ToString() + "px");
            text.Attributes.Add("class", "TextBoxRegular");
            text.Value = value;

            return text;
        }

        public HtmlTextArea getTextArea(string id, string value, string width, string height)
        {
            HtmlTextArea text = new HtmlTextArea();
            text.ID = id;
            text.Style.Add("width", width);
            text.Style.Add("height", height);
            text.Attributes.Add("class", "TextBoxRegular");
            text.Value = value;

            return text;
        }


        public HtmlTable getDayTextBox(string value, string inputType, string ind, string rowClientID, ref string listOfInputID)
        {
            HtmlInputText text = getTextBox("txtDay_" + ind, value, "50px");
            HtmlTable table = getTable();
            HtmlTableCell td = getTD();
            HtmlTableRow tr = new HtmlTableRow();
            HtmlImage image = new HtmlImage();

            image.ID = "txtImg_" + ind;
            image.Src = "../Images/DDImageDown.bmp";


            setListOfInputIDs(rowClientID + "_" + text.ID, inputType, ref listOfInputID);

            td.Style.Add("height", "20px");
            td.Controls.Add(text);
            tr.Controls.Add(td);

            td = new HtmlTableCell();
            td.Style.Add("padding", "0");
            td.RowSpan = 2;
            td.Controls.Add(image);
            tr.Controls.Add(td);

            table.Controls.Add(tr);

            td = new HtmlTableCell();
            tr = new HtmlTableRow();

            td.ID = "tdDays_" + ind;
            tr.Controls.Add(td);
            table.Controls.Add(tr);
            
            return table;

        }



        public HtmlTable getHourTextBox(string value, string inputType, string ind, string rowClientID, ref string listOfInputID)
        {
            HtmlTable table = getTable();
            HtmlInputText text = getTextBox("txtDynamicHour_" + ind, value, "50px");
            HtmlTableRow tr = new HtmlTableRow();
            HtmlTableCell td = getTD();
            HtmlGenericControl div = new HtmlGenericControl("div");

            div.ID = "divDynamicHour_" + ind;



            setListOfInputIDs(rowClientID + "_" + text.ID, inputType, ref listOfInputID);

            div.Controls.Add(text);
            td.Controls.Add(div);
            tr.Controls.Add(td);

            td = getTD();
            td.ID = "tdHoursNotValid_" + ind;
            td.InnerHtml = "*";
            td.Style.Add("width", "10px");
            td.Style.Add("text-align", "center");
            td.Style.Add("color", "red");
            td.Style.Add("display", "none");
            tr.Controls.Add(td);

            table.Controls.Add(tr);

            return table;
        }

        public HtmlTable getRegularTextBox(string value, string inputType, string ind, string rowClientID, ref string listOfInputID)
        {
            HtmlInputText text = getTextBox("txtRegular_" + ind, value, "50px");
            HtmlTable table = getTable();

            HtmlTableRow tr = new HtmlTableRow();
            HtmlTableCell td = getTD();

            setListOfInputIDs(rowClientID + "_" + text.ID, inputType, ref listOfInputID);

            td.Controls.Add(text);
            tr.Controls.Add(td);

            table.Controls.Add(tr);

            return table;
        }

        public HtmlTable getRegularTextBoxChangeableLength(string value, string inputType, string ind, string rowClientID, ref string listOfInputID)
        {
            HtmlInputText text = getTextBoxChangeableLength("txtRegular_" + ind, value, 880);
            HtmlTable table = getTable();

            HtmlTableRow tr = new HtmlTableRow();
            HtmlTableCell td = getTD();

            setListOfInputIDs(rowClientID + "_" + text.ID, inputType, ref listOfInputID);

            td.Controls.Add(text);
            tr.Controls.Add(td);

            table.Controls.Add(tr);

            return table;
        }

        public HtmlTable getLongTextBox(string value, string inputType, string ind, string rowClientID, ref string listOfInputID)
        {
            HtmlTextArea text = getTextArea("txtLong_" + ind, value, "410px", "50px");
            HtmlTable table = getTable();

            HtmlTableRow tr = new HtmlTableRow();
            HtmlTableCell td = getTD();

            setListOfInputIDs(rowClientID + "_" + text.ID, inputType, ref listOfInputID);

            td.Controls.Add(text);
            tr.Controls.Add(td);

            table.Controls.Add(tr);

            return table;
        }
        public HtmlTable getLongTextBoxMaxWidth(string value, string inputType, string ind, string rowClientID, ref string listOfInputID, int maxWidth)
        {
            string areaWidth = maxWidth.ToString() + "px";
            HtmlTextArea text = getTextArea("txtLong_" + ind, value, areaWidth, "50px");
            HtmlTable table = getTable();

            HtmlTableRow tr = new HtmlTableRow();
            HtmlTableCell td = getTD();

            setListOfInputIDs(rowClientID + "_" + text.ID, inputType, ref listOfInputID);

            td.Controls.Add(text);
            tr.Controls.Add(td);

            table.Controls.Add(tr);

            return table;
        }
        public HtmlTable getTable()
        {
            HtmlTable table = new HtmlTable();
            table.Style.Add("display", "inline");
            table.CellPadding = 0;
            table.CellSpacing = 0;
            return table;
        }

        public HtmlTableCell getTD()
        {
            HtmlTableCell td = new HtmlTableCell();
            td.Style.Add("padding", "0");
            td.Style.Add("height", "25px");

            return td;
        }



        public HtmlTable getDateTextBox(string value, string inputType, string ind, string rowClientID, ref string listOfInputID)
        {
            HtmlTable table = getTable();
            HtmlInputText text = new HtmlInputText();
            HtmlTableRow tr = new HtmlTableRow();
            HtmlTableCell td = getTD();
            HtmlImage image = new HtmlImage();
            HtmlGenericControl div = new HtmlGenericControl("div");

            div.ID = "divDynamicDate_" + ind;
            text.ID = "txtDynamicDate_" + ind;
            image.ID = "imgDynamicDate_" + ind;




            setListOfInputIDs(rowClientID + "_" + text.ID, inputType, ref listOfInputID);


            text.Style.Add("width", "65px");
            text.Attributes.Add("class", "TextBoxRegular");
            text.Value = value;

            image.Src = "../Images/Applic/calendarIcon.png";
            image.Style.Add("margin-right", "4px");

            div.Controls.Add(text);
            div.Controls.Add(image);
            td.Controls.Add(div);
            tr.Controls.Add(td);
            table.Controls.Add(tr);
            return table;
        }

        public void setListOfInputIDs(string objID, string inputType, ref string listOfInputID)
        {
            if (listOfInputID == "")
            {
                listOfInputID = objID;
                if (inputType != "")
                {
                    listOfInputID += "~" + inputType;
                }
            }
            else
            {
                listOfInputID += "#" + objID;
                if (inputType != "")
                {
                    listOfInputID += "~" + inputType;
                }
            }
        }

        public void setRemarkWithInputs(string remarkText, string RemarkID, ref Panel p, ref int objectIndex, string rowClientID , ref string ListOfInputID)
        {
            bool newRow = true;
            
            string[] arrPlainText = remarkText.Split('#');

            string remarkFormat = "";

            // Vadim Rasin, 23.09.2012 - add long textbox to the remark with only textbox.
            // Get the actual format of the remark template to know if the long textbox should be added to this type of remark.
            SeferNet.BusinessLayer.WorkFlow.Remarks rem = new SeferNet.BusinessLayer.WorkFlow.Remarks();
            DataSet dsRemarkDetails = rem.GetDeptRemarkDetails(int.Parse(RemarkID));
            if (dsRemarkDetails != null && dsRemarkDetails.Tables.Count > 0 && dsRemarkDetails.Tables[0].Rows.Count > 0)
            {
                DataRow drRemarkDetails = dsRemarkDetails.Tables[0].Rows[0];
                remarkFormat = drRemarkDetails["RemarkFormat"].ToString();
                remarkFormat = remarkFormat.Trim();
            }

            foreach (string plainText in arrPlainText)
            {
                string value = "";
                int inputType = 0;
                if (plainText.Contains('~'))
                {
                    value = plainText.Split('~')[0];
                    if (plainText.Split('~')[1] != "")
                        inputType = int.Parse(plainText.Split('~')[1]);
                    else
                        inputType = 10;

                    if (Enumerable.Range(0, 20).Contains(inputType))
                    {
                        // Vadim Rasin, 23.09.2012 - add long textbox to the remark with only textbox.
                        if (remarkFormat != "#10#")
                            p.Controls.Add(this.getRegularTextBox(value, inputType.ToString(), objectIndex.ToString(), rowClientID, ref ListOfInputID));
                        else
                            p.Controls.Add(this.getLongTextBox(value, inputType.ToString(), objectIndex.ToString(), rowClientID, ref ListOfInputID));
                    }
                    else
                    {
                        if (Enumerable.Range(20, 10).Contains(inputType))
                        {
                            p.Controls.Add(getDayTextBox(value, inputType.ToString(), objectIndex.ToString(), rowClientID, ref ListOfInputID));
                        }
                        else
                        {
                            if (Enumerable.Range(30, 10).Contains(inputType))
                            {
                                p.Controls.Add(getDateTextBox(value, inputType.ToString(), objectIndex.ToString(), rowClientID, ref ListOfInputID));
                            }
                            else
                            {
                                if (Enumerable.Range(40, 10).Contains(inputType))
                                {
                                    p.Controls.Add(getHourTextBox(value, inputType.ToString(), objectIndex.ToString(), rowClientID, ref ListOfInputID));
                                }
                            }
                        }
                    }
                }
                else
                {
                    value = plainText;
                    p.Controls.Add(getSimpleText(value, objectIndex.ToString(), newRow, rowClientID, ref ListOfInputID));
                }
                newRow = false;



                objectIndex++;
            }


        }

        public void setRemarkWithInputsVariableLength(string remarkText, string RemarkID, ref Panel p, ref int objectIndex, string rowClientID, ref string ListOfInputID)
        {
            bool newRow = true;

            string[] arrPlainText = remarkText.Split('#');

            string remarkFormat = "";

            // Vadim Rasin, 23.09.2012 - add long textbox to the remark with only textbox.
            // Get the actual format of the remark template to know if the long textbox should be added to this type of remark.
            SeferNet.BusinessLayer.WorkFlow.Remarks rem = new SeferNet.BusinessLayer.WorkFlow.Remarks();
            DataSet dsRemarkDetails = rem.GetDeptRemarkDetails(int.Parse(RemarkID));
            if (dsRemarkDetails != null && dsRemarkDetails.Tables.Count > 0 && dsRemarkDetails.Tables[0].Rows.Count > 0)
            {
                DataRow drRemarkDetails = dsRemarkDetails.Tables[0].Rows[0];
                remarkFormat = drRemarkDetails["RemarkFormat"].ToString();
                remarkFormat = remarkFormat.Trim();
            }

            foreach (string plainText in arrPlainText)
            {
                string value = "";
                int inputType = 0;
                if (plainText.Contains('~'))
                {
                    value = plainText.Split('~')[0];
                    if (plainText.Split('~')[1] != "")
                        inputType = int.Parse(plainText.Split('~')[1]);
                    else
                        inputType = 10;

                    if (Enumerable.Range(0, 20).Contains(inputType))
                    {
                        // Vadim Rasin, 23.09.2012 - add long textbox to the remark with only textbox.
                        if (remarkFormat != "#10#")
                            p.Controls.Add(this.getRegularTextBoxChangeableLength(value, inputType.ToString(), objectIndex.ToString(), rowClientID, ref ListOfInputID));
                        else
                            p.Controls.Add(this.getLongTextBox(value, inputType.ToString(), objectIndex.ToString(), rowClientID, ref ListOfInputID));
                    }
                    else
                    {
                        if (Enumerable.Range(20, 10).Contains(inputType))
                        {
                            p.Controls.Add(getDayTextBox(value, inputType.ToString(), objectIndex.ToString(), rowClientID, ref ListOfInputID));
                        }
                        else
                        {
                            if (Enumerable.Range(30, 10).Contains(inputType))
                            {
                                p.Controls.Add(getDateTextBox(value, inputType.ToString(), objectIndex.ToString(), rowClientID, ref ListOfInputID));
                            }
                            else
                            {
                                if (Enumerable.Range(40, 10).Contains(inputType))
                                {
                                    p.Controls.Add(getHourTextBox(value, inputType.ToString(), objectIndex.ToString(), rowClientID, ref ListOfInputID));
                                }
                            }
                        }
                    }
                }
                else
                {
                    value = plainText;
                    p.Controls.Add(getSimpleText(value, objectIndex.ToString(), newRow, rowClientID, ref ListOfInputID));
                }
                newRow = false;



                objectIndex++;
            }


        }

        public void setDICremarkToCorrectTextVariableLength(string remarkText, string RemarkID, ref Panel p, ref int objectIndex, string rowClientID, ref string ListOfInputID)
        {
            bool newRow = true;
            bool res = false;
            int intResult = 0;

            string[] arrPlainText = remarkText.Split('#');

            for (int i = 0; i < arrPlainText.Length; i++)
            {
                res = int.TryParse(arrPlainText[i], out intResult);

                if (res)
                {
                    arrPlainText[i] = '#' + arrPlainText[i] + '#';
                }
            }

                string remarkFormat = remarkText;

            // Vadim Rasin, 23.09.2012 - add long textbox to the remark with only textbox.
            // Get the actual format of the remark template to know if the long textbox should be added to this type of remark.
            //SeferNet.BusinessLayer.WorkFlow.Remarks rem = new SeferNet.BusinessLayer.WorkFlow.Remarks();
            //DataSet dsRemarkDetails = rem.GetDeptRemarkDetails(int.Parse(RemarkID));
            //if (dsRemarkDetails != null && dsRemarkDetails.Tables.Count > 0 && dsRemarkDetails.Tables[0].Rows.Count > 0)
            //{
            //    DataRow drRemarkDetails = dsRemarkDetails.Tables[0].Rows[0];
            //    remarkFormat = drRemarkDetails["RemarkFormat"].ToString();
            //    remarkFormat = remarkFormat.Trim();
            //}

            foreach (string plainText in arrPlainText)
            {
                string value = "";
                int inputType = 0;

                value = plainText;

                if (plainText.Contains('#'))
                {
                    p.Controls.Add(getSimpleText(value, objectIndex.ToString(), newRow, rowClientID, ref ListOfInputID));

                    //value = plainText.Split('~')[0];
                    //if (plainText.Split('~')[1] != "")
                    //    inputType = int.Parse(plainText.Split('~')[1]);
                    //else
                    //    inputType = 10;

                    //if (Enumerable.Range(0, 20).Contains(inputType))
                    //{
                    //    // Vadim Rasin, 23.09.2012 - add long textbox to the remark with only textbox.
                    //    if (remarkFormat != "#10#")
                    //        p.Controls.Add(this.getRegularTextBoxChangeableLength(value, inputType.ToString(), objectIndex.ToString(), rowClientID, ref ListOfInputID));
                    //    else
                    //        p.Controls.Add(this.getLongTextBox(value, inputType.ToString(), objectIndex.ToString(), rowClientID, ref ListOfInputID));
                    //}
                    //else
                    //{
                    //    if (Enumerable.Range(20, 10).Contains(inputType))
                    //    {
                    //        p.Controls.Add(getDayTextBox(value, inputType.ToString(), objectIndex.ToString(), rowClientID, ref ListOfInputID));
                    //    }
                    //    else
                    //    {
                    //        if (Enumerable.Range(30, 10).Contains(inputType))
                    //        {
                    //            p.Controls.Add(getDateTextBox(value, inputType.ToString(), objectIndex.ToString(), rowClientID, ref ListOfInputID));
                    //        }
                    //        else
                    //        {
                    //            if (Enumerable.Range(40, 10).Contains(inputType))
                    //            {
                    //                p.Controls.Add(getHourTextBox(value, inputType.ToString(), objectIndex.ToString(), rowClientID, ref ListOfInputID));
                    //            }
                    //        }
                    //    }
                    //}
                }
                else
                {
                    p.Controls.Add(this.getRegularTextBoxChangeableLength(value, inputType.ToString(), objectIndex.ToString(), rowClientID, ref ListOfInputID));
                    //p.Controls.Add(getSimpleText(value, objectIndex.ToString(), newRow, rowClientID, ref ListOfInputID));
                }
                newRow = false;



                objectIndex++;
            }


        }


        public void setRemarkWithInputs(string remarkTemplate, string remarkText, string RemarkID, ref Panel p, ref int objectIndex, string rowClientID, ref string ListOfInputID)
        {
            bool newRow = true;

            string[] arrPlainText = remarkText.Split('#');

            string remarkFormat = remarkTemplate;

            foreach (string plainText in arrPlainText)
            {
                string value = "";
                int inputType = 0;
                if (plainText.Contains('~'))
                {
                    value = plainText.Split('~')[0];
                    if (plainText.Split('~')[1] != "")
                        inputType = int.Parse(plainText.Split('~')[1]);
                    else
                        inputType = 10;

                    if (Enumerable.Range(0, 20).Contains(inputType))
                    {
                        // Vadim Rasin, 23.09.2012 - add long textbox to the remark with only textbox.
                        if (remarkFormat != "#10#")
                            p.Controls.Add(this.getRegularTextBox(value, inputType.ToString(), objectIndex.ToString(), rowClientID, ref ListOfInputID));
                        else
                            p.Controls.Add(this.getLongTextBox(value, inputType.ToString(), objectIndex.ToString(), rowClientID, ref ListOfInputID));
                    }
                    else
                    {
                        if (Enumerable.Range(20, 10).Contains(inputType))
                        {
                            p.Controls.Add(getDayTextBox(value, inputType.ToString(), objectIndex.ToString(), rowClientID, ref ListOfInputID));
                        }
                        else
                        {
                            if (Enumerable.Range(30, 10).Contains(inputType))
                            {
                                p.Controls.Add(getDateTextBox(value, inputType.ToString(), objectIndex.ToString(), rowClientID, ref ListOfInputID));
                            }
                            else
                            {
                                if (Enumerable.Range(40, 10).Contains(inputType))
                                {
                                    p.Controls.Add(getHourTextBox(value, inputType.ToString(), objectIndex.ToString(), rowClientID, ref ListOfInputID));
                                }
                            }
                        }
                    }
                }
                else
                {
                    value = plainText;
                    p.Controls.Add(getSimpleText(value, objectIndex.ToString(), newRow, rowClientID, ref ListOfInputID));
                }
                newRow = false;



                objectIndex++;
            }


        }

        public void setRemarkWithInputsVariableLength(string remarkTemplate, string remarkText, string RemarkID, ref Panel p, ref int objectIndex, string rowClientID, ref string ListOfInputID)
        {
            bool newRow = true;

            string[] arrPlainText = remarkText.Split('#');

            string remarkFormat = remarkTemplate;

            foreach (string plainText in arrPlainText)
            {
                string value = "";
                int inputType = 0;
                if (plainText.Contains('~'))
                {
                    value = plainText.Split('~')[0];
                    if (plainText.Split('~')[1] != "")
                        inputType = int.Parse(plainText.Split('~')[1]);
                    else
                        inputType = 10;

                    if (Enumerable.Range(0, 20).Contains(inputType))
                    {
                        // Vadim Rasin, 23.09.2012 - add long textbox to the remark with only textbox.
                        if (remarkFormat != "#10#")
                            p.Controls.Add(this.getRegularTextBoxChangeableLength(value, inputType.ToString(), objectIndex.ToString(), rowClientID, ref ListOfInputID));
                        else
                            p.Controls.Add(this.getLongTextBox(value, inputType.ToString(), objectIndex.ToString(), rowClientID, ref ListOfInputID));
                    }
                    else
                    {
                        if (Enumerable.Range(20, 10).Contains(inputType))
                        {
                            p.Controls.Add(getDayTextBox(value, inputType.ToString(), objectIndex.ToString(), rowClientID, ref ListOfInputID));
                        }
                        else
                        {
                            if (Enumerable.Range(30, 10).Contains(inputType))
                            {
                                p.Controls.Add(getDateTextBox(value, inputType.ToString(), objectIndex.ToString(), rowClientID, ref ListOfInputID));
                            }
                            else
                            {
                                if (Enumerable.Range(40, 10).Contains(inputType))
                                {
                                    p.Controls.Add(getHourTextBox(value, inputType.ToString(), objectIndex.ToString(), rowClientID, ref ListOfInputID));
                                }
                            }
                        }
                    }
                }
                else
                {
                    value = plainText;
                    p.Controls.Add(getSimpleText(value, objectIndex.ToString(), newRow, rowClientID, ref ListOfInputID));
                }
                newRow = false;



                objectIndex++;
            }


        }

        public void setRemarkWithInputsVariableLengthAndMaxWidth(string remarkTemplate, string remarkText, string RemarkID, ref Panel p, ref int objectIndex, string rowClientID, ref string ListOfInputID, int maxWidth)
        {
            bool newRow = true;

            string[] arrPlainText = remarkText.Split('#');

            string remarkFormat = remarkTemplate;

            foreach (string plainText in arrPlainText)
            {
                string value = "";
                int inputType = 0;
                if (plainText.Contains('~'))
                {
                    value = plainText.Split('~')[0];
                    if (plainText.Split('~')[1] != "")
                        inputType = int.Parse(plainText.Split('~')[1]);
                    else
                        inputType = 10;

                    if (Enumerable.Range(0, 20).Contains(inputType))
                    {
                        // Vadim Rasin, 23.09.2012 - add long textbox to the remark with only textbox.
                        if (remarkFormat != "#10#")
                            p.Controls.Add(this.getRegularTextBoxChangeableLength(value, inputType.ToString(), objectIndex.ToString(), rowClientID, ref ListOfInputID));
                        else
                            p.Controls.Add(this.getLongTextBoxMaxWidth(value, inputType.ToString(), objectIndex.ToString(), rowClientID, ref ListOfInputID, maxWidth));
                    }
                    else
                    {
                        if (Enumerable.Range(20, 10).Contains(inputType))
                        {
                            p.Controls.Add(getDayTextBox(value, inputType.ToString(), objectIndex.ToString(), rowClientID, ref ListOfInputID));
                        }
                        else
                        {
                            if (Enumerable.Range(30, 10).Contains(inputType))
                            {
                                p.Controls.Add(getDateTextBox(value, inputType.ToString(), objectIndex.ToString(), rowClientID, ref ListOfInputID));
                            }
                            else
                            {
                                if (Enumerable.Range(40, 10).Contains(inputType))
                                {
                                    p.Controls.Add(getHourTextBox(value, inputType.ToString(), objectIndex.ToString(), rowClientID, ref ListOfInputID));
                                }
                            }
                        }
                    }
                }
                else
                {
                    value = plainText;
                    if (value != string.Empty)
                    { 
                        p.Controls.Add(getSimpleText(value, objectIndex.ToString(), newRow, rowClientID, ref ListOfInputID));
                    }
                }
                newRow = false;



                objectIndex++;
            }


        }

    }
}
