using MongoDB.Driver;

namespace InternalApp.Services;

public class MongoDbService
{
    private readonly IMongoClient _client;
    private readonly ILogger<MongoDbService> _logger;

    public MongoDbService(IConfiguration configuration, ILogger<MongoDbService> logger)
    {
        _logger = logger;
        var connectionString = configuration.GetConnectionString("MongoDB");
        
        try
        {
            _client = new MongoClient(connectionString);
            _logger.LogInformation("Connected to MongoDB at {ConnectionString}", connectionString);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to connect to MongoDB");
            throw;
        }
    }

    public IMongoDatabase GetDatabase(string databaseName = "testdb") 
        => _client.GetDatabase(databaseName);

    public async Task<bool> TestConnectionAsync()
    {
        try
        {
            var databases = await _client.ListDatabaseNamesAsync();
            await databases.MoveNextAsync();
            return databases.Current != null;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "MongoDB connection test failed");
            return false;
        }
    }
}
