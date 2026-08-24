using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Netsera.Infrastructure.Persistence;

namespace Netsera.Api.Controllers;

[ApiController]
[Route("api/admin/audit-logs")]
[Authorize(Roles = "Admin")]
public sealed class AuditLogsController(ApplicationDbContext db) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> List(
        [FromQuery] int take = 100,
        CancellationToken cancellationToken = default)
    {
        take = Math.Clamp(take, 1, 250);

        var items = await db.AuditLogs
            .AsNoTracking()
            .OrderByDescending(x => x.CreatedAtUtc)
            .Take(take)
            .Select(x => new
            {
                x.Id,
                x.AdminUserId,
                x.ActorEmail,
                x.Action,
                x.EntityType,
                x.EntityId,
                x.Metadata,
                x.TraceId,
                x.CreatedAtUtc
            })
            .ToListAsync(cancellationToken);

        return Ok(items);
    }
}
