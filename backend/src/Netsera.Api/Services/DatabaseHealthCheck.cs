using Microsoft.Extensions.Diagnostics.HealthChecks;
using Netsera.Infrastructure.Persistence;

namespace Netsera.Api.Services;

public sealed class DatabaseHealthCheck(
    IServiceScopeFactory scopeFactory) : IHealthCheck
{
    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context,
        CancellationToken cancellationToken = default)
    {
        try
        {
            await using var scope = scopeFactory.CreateAsyncScope();
            var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

            var canConnect = await db.Database.CanConnectAsync(cancellationToken);

            return canConnect
                ? HealthCheckResult.Healthy("PostgreSQL connection is healthy.")
                : HealthCheckResult.Unhealthy("PostgreSQL connection failed.");
        }
        catch (Exception ex)
        {
            return HealthCheckResult.Unhealthy(
                "PostgreSQL health check failed.",
                ex);
        }
    }
}
