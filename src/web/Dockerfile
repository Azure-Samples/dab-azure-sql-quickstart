FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base

USER app
WORKDIR /app

EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
ARG BUILD_CONFIGURATION=Development

WORKDIR /src

COPY *.csproj ./
COPY *.props ./
RUN dotnet restore "Microsoft.Samples.DataApiBuilder.AzureSQLQuickstartWeb.csproj"
COPY . ./
RUN dotnet build "Microsoft.Samples.DataApiBuilder.AzureSQLQuickstartWeb.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Development
RUN dotnet publish "Microsoft.Samples.DataApiBuilder.AzureSQLQuickstartWeb.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Microsoft.Samples.DataApiBuilder.AzureSQLQuickstartWeb.dll"]