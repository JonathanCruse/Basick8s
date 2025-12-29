using Microsoft.AspNetCore.Mvc;
using InternalApp.Services;

namespace InternalApp.Controllers;

[ApiController]
[Route("api/[controller]")]
public class DatabaseController : ControllerBase
{
    private readonly RedisService _redisService;
    private readonly MongoDbService _mongoDbService;
    private readonly ElasticsearchService _elasticsearchService;
    private readonly SqlServerService _sqlServerService;
    private readonly ILogger<DatabaseController> _logger;

    public DatabaseController(
        RedisService redisService,
        MongoDbService mongoDbService,
        ElasticsearchService elasticsearchService,
        SqlServerService sqlServerService,
        ILogger<DatabaseController> logger)
    {
        _redisService = redisService;
        _mongoDbService = mongoDbService;
        _elasticsearchService = elasticsearchService;
        _sqlServerService = sqlServerService;
        _logger = logger;
    }

    [HttpGet("test-connections")]
    public async Task<IActionResult> TestConnections()
    {
        var results = new Dictionary<string, object>();

        try
        {
            results["redis"] = new 
            { 
                status = await _redisService.TestConnectionAsync() ? "connected" : "failed",
                timestamp = DateTime.UtcNow
            };
        }
        catch (Exception ex)
        {
            results["redis"] = new { status = "error", message = ex.Message };
        }

        try
        {
            results["mongodb"] = new 
            { 
                status = await _mongoDbService.TestConnectionAsync() ? "connected" : "failed",
                timestamp = DateTime.UtcNow
            };
        }
        catch (Exception ex)
        {
            results["mongodb"] = new { status = "error", message = ex.Message };
        }

        try
        {
            results["elasticsearch"] = new 
            { 
                status = await _elasticsearchService.TestConnectionAsync() ? "connected" : "failed",
                timestamp = DateTime.UtcNow
            };
        }
        catch (Exception ex)
        {
            results["elasticsearch"] = new { status = "error", message = ex.Message };
        }

        try
        {
            results["sqlserver"] = new 
            { 
                status = await _sqlServerService.TestConnectionAsync() ? "connected" : "failed",
                timestamp = DateTime.UtcNow
            };
        }
        catch (Exception ex)
        {
            results["sqlserver"] = new { status = "error", message = ex.Message };
        }

        return Ok(results);
    }
}
