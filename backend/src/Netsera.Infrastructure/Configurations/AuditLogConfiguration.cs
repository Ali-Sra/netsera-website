using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Netsera.Domain.Entities;

namespace Netsera.Infrastructure.Configurations;

public sealed class AuditLogConfiguration : IEntityTypeConfiguration<AuditLog>
{
    public void Configure(EntityTypeBuilder<AuditLog> builder)
    {
        builder.ToTable("audit_logs");
        builder.HasKey(x => x.Id);

        builder.Property(x => x.ActorEmail)
            .HasMaxLength(254);

        builder.Property(x => x.Action)
            .HasMaxLength(120)
            .IsRequired();

        builder.Property(x => x.EntityType)
            .HasMaxLength(120)
            .IsRequired();

        builder.Property(x => x.EntityId)
            .HasMaxLength(100);

        builder.Property(x => x.Metadata)
            .HasMaxLength(2000);

        builder.Property(x => x.TraceId)
            .HasMaxLength(100);

        builder.HasIndex(x => x.CreatedAtUtc);
        builder.HasIndex(x => x.AdminUserId);
        builder.HasIndex(x => new { x.EntityType, x.EntityId });
    }
}
