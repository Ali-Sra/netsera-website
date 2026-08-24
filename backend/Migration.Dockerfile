FROM mcr.microsoft.com/dotnet/sdk:8.0
WORKDIR /src
COPY backend/src/Netsera.Domain/Netsera.Domain.csproj backend/src/Netsera.Domain/
COPY backend/src/Netsera.Application/Netsera.Application.csproj backend/src/Netsera.Application/
COPY backend/src/Netsera.Infrastructure/Netsera.Infrastructure.csproj backend/src/Netsera.Infrastructure/
COPY backend/src/Netsera.Api/Netsera.Api.csproj backend/src/Netsera.Api/
RUN dotnet restore backend/src/Netsera.Api/Netsera.Api.csproj
COPY backend/src/ backend/src/
RUN dotnet tool install --global dotnet-ef --version 8.0.8
ENV PATH="${PATH}:/root/.dotnet/tools"
ENTRYPOINT ["dotnet", "ef", "database", "update", "--project", "backend/src/Netsera.Infrastructure", "--startup-project", "backend/src/Netsera.Api"]
