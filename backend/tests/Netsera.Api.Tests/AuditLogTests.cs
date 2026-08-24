using System.Net;
using System.Net.Http.Json;
using Microsoft.Extensions.DependencyInjection;
using Netsera.Infrastructure.Persistence;

namespace Netsera.Api.Tests;

public sealed class AuditLogTests(CustomWebApplicationFactory factory)
    : IClassFixture<CustomWebApplicationFactory>
{
    [Fact]
    public async Task Successful_admin_login_creates_audit_record()
    {
        await factory.SeedAdminAsync();
        var client = factory.CreateClient();

        var response = await client.PostAsJsonAsync("/api/admin/auth/login", new
        {
            email = "admin@test.local",
            password = "VeryStrongTestPassword123!"
        });

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        using var scope = factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

        Assert.Contains(db.AuditLogs, x =>
            x.Action == "Admin.Login" &&
            x.EntityType == "AdminUser" &&
            x.ActorEmail == "admin@test.local");
    }
}
