namespace DAB.Samples.AzureSQL.Quickstart.Api.Models;

public record Product(
    int ProductID,
    string Name,
    string ProductNumber,
    decimal ListPrice,
    DateTime SellStartDate
);