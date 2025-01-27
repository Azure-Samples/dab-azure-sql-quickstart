namespace Microsoft.Samples.DataApiBuilder.AzureSQLQuickstartWeb.Models;

/// <summary>
/// Represents a payload of <see cref="Product"/> data.
/// </summary>
public sealed record Payload
{
    /// <summary>
    /// Gets the value of the payload.
    /// </summary>
    public required List<Product> Value { get; init; }
}