using System;

namespace Matrix.Infrastructure.GenericDal
{
	/// <summary>
	/// BaseMSSQL - handles all common functionality for DAL SqlServer objects
	/// </summary>
	public class BaseMSSQL : BaseDB
	{
		public BaseMSSQL(string helperTypeRead,
						string helperTypeWrite,
						string ConnectionStringRead, 
						string ConnectionStringWrite) : 
						base(helperTypeRead,
						helperTypeWrite,
						ConnectionStringRead,
						ConnectionStringWrite)
		{

		}

		public BaseMSSQL(string helperType, string ConnectionString) 
			: base(helperType, ConnectionString)
		{

		}

	}
}
