using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Netsera.Domain.Entities;
using Netsera.Infrastructure.Persistence;

namespace Netsera.Api.Tests;

public sealed class CustomWebApplicationFactory : WebApplicationFactory<Program>
{
    private readonly string _databaseName = $"netsera-tests-{Guid.NewGuid():N}";

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Testing");

        builder.ConfigureAppConfiguration((_, configuration) =>
        {
            configuration.AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["ConnectionStrings:DefaultConnection"] = "Host=unused-for-tests",
                ["Cors:AllowedOrigins:0"] = "http://localhost:3000"
            });
        });

        builder.ConfigureServices(services =>
        {
            services.RemoveAll<DbContextOptions<ApplicationDbContext>>();
            services.RemoveAll<ApplicationDbContext>();

            services.AddDbContext<ApplicationDbContext>(options =>
                options.UseInMemoryDatabase(_databaseName));
        });
    }

    public async Task SeedAdminAsync(
        string email = "admin@test.local",
        string password = "VeryStrongTestPassword123!")
    {
        using var scope = Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var hasher = scope.ServiceProvider.GetRequiredService<IPasswordHasher<AdminUser>>();

        if (await db.AdminUsers.AnyAsync(x => x.NormalizedEmail == email.ToUpperInvariant()))
            return;

        var user = new AdminUser
        {
            Email = email,
            NormalizedEmail = email.ToUpperInvariant(),
            IsActive = true
        };

        user.PasswordHash = hasher.HashPassword(user, password);
        db.AdminUsers.Add(user);
        await db.SaveChangesAsync();
    }

    public async Task SeedContactMessageAsync()
    {
        using var scope = Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

        db.ContactMessages.Add(new ContactMessage
        {
            Name = "Test User",
            Email = "test@example.com",
            Subject = "Integration Test",
            Message = "This is a seeded integration-test message."
        });

        await db.SaveChangesAsync();
    }
}
