using System.ComponentModel.DataAnnotations;
using System.Text.RegularExpressions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Netsera.Domain.Entities;
using Netsera.Infrastructure.Persistence;

namespace Netsera.Api.Controllers;

[ApiController]
[Route("api/admin/services")]
[Authorize(Roles = "Admin")]
public sealed class AdminServicesController(ApplicationDbContext db) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> List(CancellationToken cancellationToken)
    {
        var items = await db.Services
            .AsNoTracking()
            .OrderBy(x => x.DisplayOrder)
            .ThenBy(x => x.Title)
            .ToListAsync(cancellationToken);

        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create(
        [FromBody] ServiceRequest request,
        CancellationToken cancellationToken)
    {
        if (!HasAdminRequestHeader()) return BadRequest(new { message = "Missing admin request header." });

        var slug = NormalizeSlug(request.Slug, request.Title);

        if (await db.Services.AnyAsync(x => x.Slug == slug, cancellationToken))
            return Conflict(new { message = "Slug already exists." });

        var entity = new ServiceItem
        {
            Title = request.Title.Trim(),
            Slug = slug,
            Description = request.Description.Trim(),
            Icon = Clean(request.Icon),
            IsPublished = request.IsPublished,
            DisplayOrder = request.DisplayOrder
        };

        db.Services.Add(entity);
        await db.SaveChangesAsync(cancellationToken);

        return CreatedAtAction(nameof(List), new { id = entity.Id }, entity);
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(
        Guid id,
        [FromBody] ServiceRequest request,
        CancellationToken cancellationToken)
    {
        if (!HasAdminRequestHeader()) return BadRequest(new { message = "Missing admin request header." });

        var entity = await db.Services.SingleOrDefaultAsync(x => x.Id == id, cancellationToken);
        if (entity is null) return NotFound();

        var slug = NormalizeSlug(request.Slug, request.Title);

        if (await db.Services.AnyAsync(x => x.Id != id && x.Slug == slug, cancellationToken))
            return Conflict(new { message = "Slug already exists." });

        entity.Title = request.Title.Trim();
        entity.Slug = slug;
        entity.Description = request.Description.Trim();
        entity.Icon = Clean(request.Icon);
        entity.IsPublished = request.IsPublished;
        entity.DisplayOrder = request.DisplayOrder;
        entity.UpdatedAtUtc = DateTime.UtcNow;

        await db.SaveChangesAsync(cancellationToken);
        return Ok(entity);
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id, CancellationToken cancellationToken)
    {
        if (!HasAdminRequestHeader()) return BadRequest(new { message = "Missing admin request header." });

        var entity = await db.Services.SingleOrDefaultAsync(x => x.Id == id, cancellationToken);
        if (entity is null) return NotFound();

        db.Services.Remove(entity);
        await db.SaveChangesAsync(cancellationToken);
        return NoContent();
    }

    private bool HasAdminRequestHeader() =>
        Request.Headers.TryGetValue("X-Netsera-Admin", out var value) && value == "1";

    private static string? Clean(string? value) =>
        string.IsNullOrWhiteSpace(value) ? null : value.Trim();

    private static string NormalizeSlug(string? slug, string title)
    {
        var value = string.IsNullOrWhiteSpace(slug) ? title : slug;
        value = value.Trim().ToLowerInvariant();
        value = Regex.Replace(value, @"[^a-z0-9]+", "-").Trim('-');
        return string.IsNullOrWhiteSpace(value) ? Guid.NewGuid().ToString("N") : value;
    }
}

public sealed class ServiceRequest
{
    [Required, StringLength(160, MinimumLength = 2)]
    public string Title { get; init; } = string.Empty;

    [StringLength(180)]
    public string? Slug { get; init; }

    [Required, StringLength(2000, MinimumLength = 5)]
    public string Description { get; init; } = string.Empty;

    [StringLength(100)]
    public string? Icon { get; init; }

    public bool IsPublished { get; init; }
    public int DisplayOrder { get; init; }
}
