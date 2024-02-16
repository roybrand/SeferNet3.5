using System;

namespace Matrix.Infrastructure.GenericDal
{
	/// <summary>
	/// represents type of connection (read/write)
	/// </summary>
	public enum ConnectionType
	{
		Read,
		Write
	}

	/// <summary>
	/// represents database type
	/// </summary>
	public enum DatabaseType
	{
		Oracle,
		SqlServer,
		DB2
	}

}
