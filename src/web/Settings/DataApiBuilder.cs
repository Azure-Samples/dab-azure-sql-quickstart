// Copyright (c) Microsoft Corporation. All rights reserved.
namespace Microsoft.Samples.DataApiBuilder.AzureSQLQuickstartWeb.Settings;

/// <summary>
/// Represents the configuration settings for the application.
/// </summary>
internal sealed record DataApiBuilder
{
    /// <summary>
    /// Gets the base URL for the Data API builder (DAB) instance.
    /// </summary>
    public required string BaseApiUrl { get; init; }
}