#region System

using System;
using System.Data;
using System.Reflection;

#endregion

using GotDotNet.ApplicationBlocks.Data;

namespace Matrix.Infrastructure.GenericDal
{
	/// <summary>
	/// BaseOracle - handles all common functionality for DAL Oracle objects
	/// </summary>
	public class BaseOracle : BaseDB
	{

		#region Constructor and Destructor

		/// <summary>
		/// Constructor
		/// </summary>
		public BaseOracle(string helperTypeRead,
							string helperTypeWrite,
							string ConnectionStringRead, 
							string ConnectionStringWrite) : 
							base(helperTypeRead,
							helperTypeWrite,
							ConnectionStringRead,
							ConnectionStringWrite)
									
		{
		}

		/// <summary>
		/// Constructor
		/// </summary>
		public BaseOracle(string helperType, string ConnectionString) : 
											base(helperType,
											ConnectionString)
									
		{
		}

		#endregion

		#region Public Methods
		/// <summary>
		/// Convert Oracle DataReader to DataTable while reformating hebrew strings
		/// </summary>
		/// <param name="p_reader">IDataReader</param>
		/// <returns>DataTable</returns>
		public DataTable ConvertToDataTable(IDataReader p_reader) 
		{ 
			DataTable table = new DataTable(); 
			int fieldCount = p_reader.FieldCount; 
			for (int i = 0; i < fieldCount; i++) 
			{ 
				table.Columns.Add(p_reader.GetName(i), p_reader.GetFieldType(i)); 
			} 

			table.BeginLoadData();
			object[] values = new object[fieldCount]; 
			HebOracleDataReader hreader = new HebOracleDataReader(p_reader);

			while(hreader.Read())
			{
				hreader.GetValues(ref values);
				table.LoadDataRow(values, true); 				
			}

			table.EndLoadData(); 
			return table; 
		} 
		#endregion

		#region Overloads

		/// <summary>
		/// Encode hebrew values in the dataset
		/// </summary>
		/// <param name="p_dataSet">DataSet to go through and encode</param>
		/// <returns>Encoded DataSet</returns>
		protected override DataSet EncodeHebrew(DataSet p_dataSet)
		{
			DataTable dt = null;
			DataRow dr = null;

			//go through tables
			if(p_dataSet != null)
			{
				for(int tablesIndex = 0; tablesIndex < p_dataSet.Tables.Count; tablesIndex++)
				{
					dt = p_dataSet.Tables[0];

					//go throug the table rows
					for(int i = 0; i<dt.Rows.Count; i++)
					{
						dr = dt.Rows[i];

						//go through all the columns
						for(int j=0; j<dt.Columns.Count; j++)
						{
							//if this is column of "string" type
							if(dt.Columns[j].DataType == typeof(string))
							{
								dr[j] = HebrewEncoder.FromatData(dr[j]);
							}
						}
					}
				}
			}

			return p_dataSet;
		}

		#endregion
	}
}
