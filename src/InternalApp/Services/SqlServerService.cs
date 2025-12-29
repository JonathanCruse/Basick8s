using Microsoft.Data.SqlClient;

namespace InternalApp.Services;

public class SqlServerService
{
    private readonly string _connectionString;
    private readonly ILogger<SqlServerService> _logger;

    public SqlServerService(IConfiguration configuration, ILogger<SqlServerService> logger)
    {
        _logger = logger;
        _connectionString = configuration.GetConnectionString("SqlServer")!;
        _logger.LogInformation("SQL Server connection string configured");
    }

    public async Task<SqlConnection> GetConnectionAsync()
    {
        var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();
        return connection;
    }

    public async Task<bool> TestConnectionAsync()
    {
        try
        {
            using var connection = await GetConnectionAsync();
            using var command = new SqlCommand("SELECT 1", connection);
            var result = await command.ExecuteScalarAsync();
            return result != null;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "SQL Server connection test failed");
            return false;
        }
    }
}
