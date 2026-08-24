namespace Netsera.Domain.Entities;

public sealed class AuditLog
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid? AdminUserId { get; set; }
    public string? ActorEmail { get; set; }
    public string Action { get; set; } = string.Empty;
    public string EntityType { get; set; } = string.Empty;
    public string? EntityId { get; set; }
    public string? Metadata { get; set; }
    public string? TraceId { get; set; }
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
}
