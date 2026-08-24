using Microsoft.EntityFrameworkCore;
using Netsera.Domain.Entities;

namespace Netsera.Application.Interfaces;

public interface IApplicationDbContext
{
    DbSet<ContactMessage> ContactMessages { get; }
    DbSet<Project> Projects { get; }
    DbSet<ServiceItem> Services { get; }
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
