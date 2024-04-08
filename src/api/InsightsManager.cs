using System.Net;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using DAB.Samples.AzureSQL.Quickstart.Api.Models;
using FromBodyAttribute = Microsoft.Azure.Functions.Worker.Http.FromBodyAttribute;

namespace DAB.Samples.AzureSQL.Quickstart.Api;

public class InsightsManager
{
    private readonly ILogger _logger;

    public InsightsManager(ILoggerFactory loggerFactory)
    {
        _logger = loggerFactory.CreateLogger<InsightsManager>();
    }

    [Function("insights")]
    public HttpResponseData Run([HttpTrigger(AuthorizationLevel.Anonymous, "POST")] HttpRequestData request, [FromBody] IEnumerable<Product> products)
    {
        Insights insights = new(
            Count: products.Count()
        );

        var response = request.CreateResponse(HttpStatusCode.OK);
        response.WriteAsJsonAsync(insights);
        return response;
    }
}