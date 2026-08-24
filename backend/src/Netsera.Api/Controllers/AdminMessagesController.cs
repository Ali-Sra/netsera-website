using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Netsera.Api.Services;
using Netsera.Infrastructure.Persistence;

namespace Netsera.Api.Controllers;

[ApiController]
[Route("api/admin/messages")]
[Authorize(Roles = "Admin")]
public sealed class AdminMessagesController(
    ApplicationDbContext db,
    AuditLogService audit) : ControllerBase
{
    private static readonly HashSet<string> AllowedStatuses =
        new(StringComparer.OrdinalIgnoreCase)
        {
            "New",
            "Read",
            "Archived"
        };

    [HttpGet]
    public async Task<IActionResult> List(
        [FromQuery] string? status,
        CancellationToken cancellationToken)
    {
        var query = db.ContactMessages.AsNoTracking();

        if (!string.IsNullOrWhiteSpace(status))
        {
            query = query.Where(x => x.Status == status);
        }

        var messages = await query
            .OrderByDescending(x => x.CreatedAtUtc)
            .Take(100)
            .Select(x => new
            {
                x.Id,
                x.Name,
                x.Email,
                x.Subject,
                x.Message,
                x.Status,
                x.CreatedAtUtc,
                x.UpdatedAtUtc
            })
            .ToListAsync(cancellationToken);

        return Ok(messages);
    }

    [HttpPatch("{id:guid}/status")]
    public async Task<IActionResult> UpdateStatus(
        Guid id,
        [FromBody] UpdateMessageStatusRequest request,
        CancellationToken cancellationToken)
    {
        if (!HasAdminRequestHeader())
        {
            return BadRequest(new { message = "Missing admin request header." });
        }

        if (!AllowedStatuses.Contains(request.Status))
        {
            return BadRequest(new
            {
                message = "Status must be New, Read or Archived."
            });
        }

        var message = await db.ContactMessages
            .SingleOrDefaultAsync(x => x.Id == id, cancellationToken);

        if (message is null)
        {
            return NotFound();
        }

        var oldStatus = message.Status;

        message.Status = AllowedStatuses
            .Single(x => x.Equals(request.Status, StringComparison.OrdinalIgnoreCase));

        message.UpdatedAtUtc = DateTime.UtcNow;

        await db.SaveChangesAsync(cancellationToken);

        await audit.WriteAsync(
            "ContactMessage.StatusChanged",
            "ContactMessage",
            message.Id.ToString(),
            new { from = oldStatus, to = message.Status },
            cancellationToken: cancellationToken);

        return NoContent();
    }

    private bool HasAdminRequestHeader() =>
        Request.Headers.TryGetValue("X-Netsera-Admin", out var value)
        && value == "1";
}

public sealed record UpdateMessageStatusRequest(string Status);
