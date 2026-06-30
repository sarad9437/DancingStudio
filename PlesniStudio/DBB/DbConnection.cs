using Microsoft.Data.SqlClient;

namespace DBB
{
    public class DbConnection
    {
        private const string ConnectionString =
            @"Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=PlesniStudio;" +
            "Integrated Security=True;Connect Timeout=30;Encrypt=False;" +
            "Trust Server Certificate=False;Application Intent=ReadWrite;" +
            "Multi Subnet Failover=False;MultipleActiveResultSets=True";

        public SqlConnection CreateNewConnection()
        {
            var conn = new SqlConnection(ConnectionString);
            conn.Open();
            return conn;
        }

        public void OpenConnection() { }
        public void CloseConnection() { }
        public SqlCommand CreateCommand() =>
            throw new InvalidOperationException("Koristi CreateNewConnection().");
    }
}