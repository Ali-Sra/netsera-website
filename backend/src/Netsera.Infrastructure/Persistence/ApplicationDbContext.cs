using Microsoft.EntityFrameworkCore;
using Netsera.Application.Interfaces;
using Netsera.Domain.Entities;

namespace Netsera.Infrastructure.Persistence;

public sealed class ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
    : DbContext(options), IApplicationDbContext
{
    public DbSet<ContactMessage> ContactMessages => Set<ContactMessage>();
    public DbSet<Project> Projects => Set<Project>();
    public DbSet<ServiceItem> Services => Set<ServiceItem>();
    public DbSet<AdminUser> AdminUsers => Set<AdminUser>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(ApplicationDbContext).Assembly);
    }
}
