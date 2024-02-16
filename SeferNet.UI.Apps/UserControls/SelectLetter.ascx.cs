using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

public partial class SelectLetter : System.Web.UI.UserControl
{

    private string m_selectedCharacter;
    protected void Page_Load(object sender, EventArgs e)
    {
        BuildABC();
    }

    private void BuildABC()
    {
        int i;
        //Define letters array
        string[] arrABCHeb = new string[] {"à","á","â","ã","ä","å","æ","ç",
												  "è","é","ë","ì","î","ð",
												  "ñ","ò","ô","ö","÷","ø","ù","ú"};

        //			string[] arrABCEngl = new string[]	{"a", "b", "c", "d", "e", "f", "g", "h", "i", 
        //													"j", "k", "l", "m", "n", "o", "p", "q", "r", 
        //													"s", "t", "u", "v", "w", "x", "y", "z"} ;

        HtmlTableRow rowABCHeb = new HtmlTableRow();
        for (i = 0; i < arrABCHeb.Length; i++)
        {
            // Create a new cell and add it to the Cells collection.
            HtmlTableCell cellOneLetterHeb = new HtmlTableCell();
            cellOneLetterHeb.Attributes.Add("class", "cellOneLetter");
            cellOneLetterHeb.Attributes.Add("OnClick", "validFalse();");
            
           
           
            //cellOneLetterHeb.Attributes.Add("bgColor", "#D3e5fd");
            //Create linkbutton control 
            LinkButton btnLetter = new LinkButton();
            btnLetter.ID = "btnLetter_" + arrABCHeb[i];
            btnLetter.Text = @"&nbsp;&nbsp;" + arrABCHeb[i].ToString() + @"&nbsp;&nbsp;";
            btnLetter.Attributes.Add("OnMouseOver", "letterMouseOver();");
            btnLetter.Attributes.Add("OnMouseOut", "letterMouseOut()");
            btnLetter.Click += new EventHandler(btnLetter_Click);
            
            
            
            //btnLetter.CssClass = "lnkLetter";
           
            //Add controls to label in the runtime
            cellOneLetterHeb.Controls.Add(btnLetter);
            rowABCHeb.Cells.Add(cellOneLetterHeb);
        }
        tblHebLetters.Rows.Add(rowABCHeb);

        //			HtmlTableRow rowABCEngl = new HtmlTableRow();
        //			for(i = 0; i < arrABCEngl.Length; i++)
        //			{
        //				// Create a new cell and add it to the Cells collection.
        //				HtmlTableCell cellOneLetterEngl = new HtmlTableCell();
        //				cellOneLetterEngl.Attributes.Add("class","cellOneLetter");
        //				//Create linkbutton control 
        //				LinkButton btnLetter = new LinkButton();
        //				btnLetter.Text = arrABCEngl[i].ToString();
        //				btnLetter.Click += new EventHandler(btnLetter_Click) ;
        //				btnLetter.CssClass = "lnkLetter";
        //				//Add controls to label in the runtime
        //				cellOneLetterEngl.Controls.Add(btnLetter);
        //				rowABCEngl.Cells.Add(cellOneLetterEngl);
        //			}
        //			tblEngLetters.Rows.Add(rowABCEngl);
    }

    private void btnLetter_Click(object sender, System.EventArgs e)
    {
        LinkButton btn = sender as LinkButton;
        ((HtmlTableCell)btn.Parent).Style.Add("background-color","#D3e5fd");
        ((HtmlTableCell)btn.Parent).Style.Add("border", "1px solid blue");
        btn.Style.Add("background-color","#D3e5fd");
        string strLetter = btn.Text.Replace(@"&nbsp;", string.Empty);
        SelectedCharacter = strLetter;
       
       
    }

    

    public string SelectedCharacter
    {
        get { return m_selectedCharacter; }
        set { m_selectedCharacter = value; }
    }
	
}
