FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY backend/Netsera.sln backend/
COPY backend/src/Netsera.Domain/Netsera.Domain.csproj backend/src/Netsera.Domain/
COPY backend/src/Netsera.Application/Netsera.Application.csproj backend/src/Netsera.Application/
COPY backend/src/Netsera.Infrastructure/Netsera.Infrastructure.csproj backend/src/Netsera.Infrastructure/
COPY backend/src/Netsera.Api/Netsera.Api.csproj backend/src/Netsera.Api/
RUN dotnet restore backend/Netsera.sln
COPY backend/ backend/
RUN dotnet publish backend/src/Netsera.Api/Netsera.Api.csproj -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=build /app/publish .
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
ENTRYPOINT ["dotnet", "Netsera.Api.dll"]
