using System;
using System.Text;
using System.Data;
using System.Data.SqlClient;

namespace Matrix.Infrastructure.GenericDal
{
	/// <summary>
	/// Summary description for HebOraReader.
	/// </summary>
	public class HebOracleDataReader : IDisposable
	{
		private IDataReader _reader = null;
		private const int UNICODE = 1200;
		private const int WINDOWS_HEBREW = 1255;

		public HebOracleDataReader(IDataReader reader)
		{
			_reader = reader;
		}

		public object this [int index] 
		{
			get { return FromatData(_reader[index]); }
		}
		public object this [string columnName] 
		{
			get { return FromatData(_reader[columnName]); }
		}
		private object FromatData(object src)
		{

			if (src == null) return null;

			if (src is string) 
			{
				// convert the encoding represntation of the string.
				Encoding uniEnc = Encoding.GetEncoding(UNICODE);
				Encoding hebEnc = Encoding.GetEncoding(WINDOWS_HEBREW);
				String srcString = src.ToString();
				byte [] buffer = new byte [srcString.Length];
				for (int i =0;i<srcString.Length;i++)
					buffer[i] = (byte)srcString[i];

				byte [] result = Encoding.Convert(hebEnc,uniEnc,buffer);
				string hebString = uniEnc.GetString(result);
				hebString = FormatNumber(hebString);
                return hebString;
			}
			return src;
		}
		private string FormatNumber(string src)
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
		public void Dispose()
		{
			if (_reader != null)
			{
				_reader.Dispose();
			}
		}

		public bool Read()
		{
			return _reader.Read();
		}

		public void GetValues(ref object[] row)
		{	
			_reader.GetValues(row);
			int fieldCount = _reader.FieldCount;
			for (int i=0; i < fieldCount; ++i)
			{
				row[i] = FromatData(row[i]);
			}
		}

		public void Close()
		{
			if (_reader != null)
			{
				_reader.Close();
			}
		}

	}
}
