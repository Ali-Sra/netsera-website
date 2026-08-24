using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Netsera.Domain.Entities;

namespace Netsera.Infrastructure.Configurations;

public sealed class AdminUserConfiguration : IEntityTypeConfiguration<AdminUser>
{
    public void Configure(EntityTypeBuilder<AdminUser> builder)
    {
        builder.ToTable("admin_users");
        builder.HasKey(x => x.Id);

        builder.Property(x => x.Email)
            .HasMaxLength(254)
            .IsRequired();

        builder.Property(x => x.NormalizedEmail)
            .HasMaxLength(254)
            .IsRequired();

        builder.Property(x => x.PasswordHash)
            .HasMaxLength(1000)
            .IsRequired();

        builder.HasIndex(x => x.NormalizedEmail)
            .IsUnique();

        builder.HasIndex(x => x.IsActive);
    }
}
