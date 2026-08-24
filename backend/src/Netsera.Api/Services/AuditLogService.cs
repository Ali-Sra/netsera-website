using System.Security.Claims;
using System.Text.Json;
using Netsera.Domain.Entities;
using Netsera.Infrastructure.Persistence;

namespace Netsera.Api.Services;

public sealed class AuditLogService(
    ApplicationDbContext db,
    IHttpContextAccessor httpContextAccessor)
{
    public async Task WriteAsync(
        string action,
        string entityType,
        string? entityId = null,
        object? metadata = null,
        Guid? adminUserIdOverride = null,
        string? actorEmailOverride = null,
        CancellationToken cancellationToken = default)
    {
        var context = httpContextAccessor.HttpContext;
        var user = context?.User;

        Guid? adminUserId = adminUserIdOverride;
        if (adminUserId is null)
        {
            var idClaim = user?.FindFirstValue(ClaimTypes.NameIdentifier);
            if (Guid.TryParse(idClaim, out var parsed))
            {
                adminUserId = parsed;
            }
        }

        var actorEmail =
            actorEmailOverride ??
            user?.FindFirstValue(ClaimTypes.Email);

        var safeMetadata = metadata is null
            ? null
            : JsonSerializer.Serialize(metadata);

        db.AuditLogs.Add(new AuditLog
        {
            AdminUserId = adminUserId,
            ActorEmail = actorEmail,
            Action = action,
            EntityType = entityType,
            EntityId = entityId,
            Metadata = safeMetadata,
            TraceId = context?.TraceIdentifier
        });

        await db.SaveChangesAsync(cancellationToken);
    }
}
