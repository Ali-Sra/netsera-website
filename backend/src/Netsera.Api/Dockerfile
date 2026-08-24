FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY backend/src/Netsera.Domain/Netsera.Domain.csproj backend/src/Netsera.Domain/
COPY backend/src/Netsera.Application/Netsera.Application.csproj backend/src/Netsera.Application/
COPY backend/src/Netsera.Infrastructure/Netsera.Infrastructure.csproj backend/src/Netsera.Infrastructure/
COPY backend/src/Netsera.Api/Netsera.Api.csproj backend/src/Netsera.Api/

COPY backend/src/ backend/src/

RUN dotnet restore backend/src/Netsera.Api/Netsera.Api.csproj

RUN dotnet publish backend/src/Netsera.Api/Netsera.Api.csproj -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

RUN adduser --disabled-password --home /app --gecos "" --uid 10001 appuser

COPY --from=build /app/publish .

ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

USER appuser

EXPOSE 8080

ENTRYPOINT ["dotnet", "Netsera.Api.dll"]
