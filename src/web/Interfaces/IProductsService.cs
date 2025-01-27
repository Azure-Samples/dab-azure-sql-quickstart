namespace Microsoft.Samples.DataApiBuilder.AzureSQLQuickstartWeb.Interfaces;

internal interface IProductsService
{
    Task<IEnumerable<Product>> GetProductsAsync();
}
