using System.Net;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;

namespace DAB.Samples.AzureSQL.Quickstart.Api;

public class RandomNumber
{
    private readonly Random _random;

    private readonly ILogger _logger;

    public RandomNumber(ILoggerFactory loggerFactory)
    {
        _logger = loggerFactory.CreateLogger<RandomNumber>();
        _random = new Random();
    }

    [Function("RandomNumber")]
    public async Task<HttpResponseData> RunAsync([HttpTrigger(AuthorizationLevel.Anonymous, "GET")] HttpRequestData req)
    {
        _logger.LogInformation("C# HTTP trigger function processed a request.");

        var response = req.CreateResponse(HttpStatusCode.OK);
        await response.WriteAsJsonAsync(_random.Next(1, 100));
        return response;
    }
}