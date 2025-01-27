namespace Microsoft.Samples.DataApiBuilder.AzureSQLQuickstartWeb.Services;

internal sealed class DataApiBuilderProductsService(
    HttpClient httpClient,
    IOptions<Configuration> configurationOptions
) : IProductsService
{
    private readonly Configuration configuration = configurationOptions.Value;

    public async Task<IEnumerable<Product>> GetProductsAsync()
    {
        httpClient.BaseAddress = new Uri(configuration.DataApiBuilder.BaseApiUrl, UriKind.Absolute);

        HttpResponseMessage response = await httpClient.GetAsync("api/product");

        response.EnsureSuccessStatusCode();

        Payload? payload = await response.Content.ReadFromJsonAsync<Payload?>() ?? throw new InvalidOperationException("REST API query failed.");
        List<Product> products = payload?.Value ?? [];

        return [.. products];
    }
}