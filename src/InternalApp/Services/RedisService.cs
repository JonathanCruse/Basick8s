using StackExchange.Redis;

namespace InternalApp.Services;

public class RedisService
{
    private readonly IConnectionMultiplexer _redis;
    private readonly ILogger<RedisService> _logger;

    public RedisService(IConfiguration configuration, ILogger<RedisService> logger)
    {
        _logger = logger;
        var connectionString = configuration.GetConnectionString("Redis");
        
        try
        {
            _redis = ConnectionMultiplexer.Connect(connectionString!);
            _logger.LogInformation("Connected to Redis at {ConnectionString}", connectionString);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to connect to Redis");
            throw;
        }
    }

    public IDatabase GetDatabase() => _redis.GetDatabase();

    public async Task<bool> TestConnectionAsync()
    {
        try
        {
            var db = GetDatabase();
            await db.StringSetAsync("test:connection", DateTime.UtcNow.ToString());
            var value = await db.StringGetAsync("test:connection");
            return !value.IsNullOrEmpty;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Redis connection test failed");
            return false;
        }
    }
}
