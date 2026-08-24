using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Netsera.Domain.Entities;
using Netsera.Infrastructure.Persistence;

namespace Netsera.Api.Services;

public static class AdminBootstrapper
{
    public static async Task SeedAsync(
        IServiceProvider services,
        IConfiguration configuration,
        ILogger logger)
    {
        var email = configuration["AdminBootstrap:Email"]?.Trim();
        var password = configuration["AdminBootstrap:Password"];

        if (string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(password))
        {
            logger.LogInformation("Admin bootstrap skipped because credentials are not configured.");
            return;
        }

        if (password.Length < 12)
        {
            throw new InvalidOperationException(
                "AdminBootstrap:Password must be at least 12 characters.");
        }

        await using var scope = services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var hasher = scope.ServiceProvider.GetRequiredService<IPasswordHasher<AdminUser>>();

        var normalizedEmail = email.ToUpperInvariant();

        if (await db.AdminUsers.AnyAsync(x => x.NormalizedEmail == normalizedEmail))
        {
            logger.LogInformation("Admin bootstrap user already exists.");
            return;
        }

        var user = new AdminUser
        {
            Email = email,
            NormalizedEmail = normalizedEmail,
            IsActive = true
        };

        user.PasswordHash = hasher.HashPassword(user, password);

        db.AdminUsers.Add(user);
        await db.SaveChangesAsync();

        logger.LogInformation("Initial admin account created for {Email}.", email);
    }
}
