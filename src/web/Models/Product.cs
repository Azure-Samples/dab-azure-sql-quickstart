namespace Microsoft.Samples.DataApiBuilder.AzureSQLQuickstartWeb.Models;

/// <summary>
/// Represents a product with its details.
/// </summary>
public sealed record Product
{
    /// <summary>
    /// Gets the unique identifier for the product.
    /// </summary>
    public required int ProductId { get; init; }

    /// <summary>
    /// Gets the name of the product.
    /// </summary>
    public required string Name { get; init; }

    /// <summary>
    /// Gets the stock keeping unit (SKU) for the product.
    /// </summary>
    public required string ProductNumber { get; init; }

    /// <summary>
    /// Gets the color of the product.
    /// </summary>
    public required string? Color { get; init; }

    /// <summary>
    /// Gets the list price of the product.
    /// </summary>
    public required decimal ListPrice { get; init; }

    /// <summary>
    /// Gets the actual cost of the product.
    /// </summary>
    public required decimal StandardCost { get; init; }
}