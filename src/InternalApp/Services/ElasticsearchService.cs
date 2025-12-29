using Elastic.Clients.Elasticsearch;

namespace InternalApp.Services;

public class ElasticsearchService
{
    private readonly ElasticsearchClient _client;
    private readonly ILogger<ElasticsearchService> _logger;

    public ElasticsearchService(IConfiguration configuration, ILogger<ElasticsearchService> logger)
    {
        _logger = logger;
        var connectionString = configuration.GetConnectionString("Elasticsearch");
        
        try
        {
            var settings = new ElasticsearchClientSettings(new Uri(connectionString!));
            _client = new ElasticsearchClient(settings);
            _logger.LogInformation("Connected to Elasticsearch at {ConnectionString}", connectionString);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to connect to Elasticsearch");
            throw;
        }
    }

    public ElasticsearchClient GetClient() => _client;

    public async Task<bool> TestConnectionAsync()
    {
        try
        {
            var response = await _client.PingAsync();
            return response.IsValidResponse;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Elasticsearch connection test failed");
            return false;
        }
    }
}
