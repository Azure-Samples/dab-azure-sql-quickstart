namespace DAB.Samples.AzureSQL.Quickstart.Web.Models;

public record Payload<T>(
    IEnumerable<T> Value,
    Uri NextLink
);