using System;
using System.Text;

namespace Matrix.Infrastructure.GenericDal
{
	/// <summary>
	/// Convert string from Unicode into Hebrew encoding
	/// </summary>
	public sealed class HebrewEncoder
	{
		#region Consts

		private const int UNICODE = 1200;
		private const int WINDOWS_HEBREW = 1255;

		#endregion

		#region Private Variables

		private static Encoding uniEnc = Encoding.GetEncoding(UNICODE);
		private static Encoding hebEnc = Encoding.GetEncoding(WINDOWS_HEBREW);

		#endregion

		#region Public Methods

		public static object FromatData(object src)
		{
			string srcString = "", hebString = "";
			byte[] buffer = null, result = null;
			//char[] chars = null;

			if (src == null) return null;

			if (src is string) 
			{
				// convert the encoding represntation of the string.
				srcString = src.ToString();
				buffer = new byte[srcString.Length];
				for(int i =0; i<srcString.Length; i++)
				{
					//chars = srcString.ToCharArray();
					//chars.CopyTo(buffer, 0);
					buffer[i] = (byte)srcString[i];
				}

				result = Encoding.Convert(hebEnc, uniEnc, buffer);
				hebString = uniEnc.GetString(result);
				hebString = FormatNumber(hebString);

				return hebString;
			}
			else
			{
				return src;
			}
		}

		public static string FormatNumber(string src)
		{
			string result;
			Double tempNum;
			if(src.EndsWith("-"))
			{
				result = src.Substring(0,src.Length-1);
				try
				{
					tempNum=Convert.ToDouble(result);
					result = "-" + result;
					return result;
				}
				catch
				{
					tempNum=0;
					return src;
				}
			}
			else
				return src;

		}

		#endregion
	}
}
