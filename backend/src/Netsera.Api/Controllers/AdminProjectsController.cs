using System.ComponentModel.DataAnnotations;
using System.Text.RegularExpressions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Netsera.Api.Services;
using Netsera.Domain.Entities;
using Netsera.Infrastructure.Persistence;

namespace Netsera.Api.Controllers;

[ApiController]
[Route("api/admin/projects")]
[Authorize(Roles = "Admin")]
public sealed class AdminProjectsController(
    ApplicationDbContext db,
    AuditLogService audit) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> List(CancellationToken cancellationToken)
    {
        var items = await db.Projects
            .AsNoTracking()
            .OrderBy(x => x.DisplayOrder)
            .ThenBy(x => x.Title)
            .ToListAsync(cancellationToken);

        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create(
        [FromBody] ProjectRequest request,
        CancellationToken cancellationToken)
    {
        if (!HasAdminRequestHeader())
            return BadRequest(new { message = "Missing admin request header." });

        var slug = NormalizeSlug(request.Slug, request.Title);

        if (await db.Projects.AnyAsync(x => x.Slug == slug, cancellationToken))
            return Conflict(new { message = "Slug already exists." });

        var entity = new Project
        {
            Title = request.Title.Trim(),
            Slug = slug,
            ShortDescription = request.ShortDescription.Trim(),
            Description = Clean(request.Description),
            ImageUrl = Clean(request.ImageUrl),
            ProjectUrl = Clean(request.ProjectUrl),
            GithubUrl = Clean(request.GithubUrl),
            IsPublished = request.IsPublished,
            DisplayOrder = request.DisplayOrder
        };

        db.Projects.Add(entity);
        await db.SaveChangesAsync(cancellationToken);

        await audit.WriteAsync(
            "Project.Created",
            "Project",
            entity.Id.ToString(),
            new { entity.Title, entity.Slug, entity.IsPublished },
            cancellationToken: cancellationToken);

        return CreatedAtAction(nameof(List), new { id = entity.Id }, entity);
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(
        Guid id,
        [FromBody] ProjectRequest request,
        CancellationToken cancellationToken)
    {
        if (!HasAdminRequestHeader())
            return BadRequest(new { message = "Missing admin request header." });

        var entity = await db.Projects
            .SingleOrDefaultAsync(x => x.Id == id, cancellationToken);

        if (entity is null)
            return NotFound();

        var slug = NormalizeSlug(request.Slug, request.Title);

        if (await db.Projects.AnyAsync(
            x => x.Id != id && x.Slug == slug,
            cancellationToken))
        {
            return Conflict(new { message = "Slug already exists." });
        }

        entity.Title = request.Title.Trim();
        entity.Slug = slug;
        entity.ShortDescription = request.ShortDescription.Trim();
        entity.Description = Clean(request.Description);
        entity.ImageUrl = Clean(request.ImageUrl);
        entity.ProjectUrl = Clean(request.ProjectUrl);
        entity.GithubUrl = Clean(request.GithubUrl);
        entity.IsPublished = request.IsPublished;
        entity.DisplayOrder = request.DisplayOrder;
        entity.UpdatedAtUtc = DateTime.UtcNow;

        await db.SaveChangesAsync(cancellationToken);

        await audit.WriteAsync(
            "Project.Updated",
            "Project",
            entity.Id.ToString(),
            new { entity.Title, entity.Slug, entity.IsPublished },
            cancellationToken: cancellationToken);

        return Ok(entity);
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(
        Guid id,
        CancellationToken cancellationToken)
    {
        if (!HasAdminRequestHeader())
            return BadRequest(new { message = "Missing admin request header." });

        var entity = await db.Projects
            .SingleOrDefaultAsync(x => x.Id == id, cancellationToken);

        if (entity is null)
            return NotFound();

        entity.DeletedAtUtc = DateTime.UtcNow;
        entity.IsPublished = false;
        entity.UpdatedAtUtc = DateTime.UtcNow;

        await db.SaveChangesAsync(cancellationToken);

        await audit.WriteAsync(
            "Project.Deleted",
            "Project",
            entity.Id.ToString(),
            new { entity.Title, entity.Slug },
            cancellationToken: cancellationToken);

        return NoContent();
    }

    private bool HasAdminRequestHeader() =>
        Request.Headers.TryGetValue("X-Netsera-Admin", out var value)
        && value == "1";

    private static string? Clean(string? value) =>
        string.IsNullOrWhiteSpace(value) ? null : value.Trim();

    private static string NormalizeSlug(string? slug, string title)
    {
        var value = string.IsNullOrWhiteSpace(slug) ? title : slug;
        value = value.Trim().ToLowerInvariant();
        value = Regex.Replace(value, @"[^a-z0-9]+", "-").Trim('-');

        return string.IsNullOrWhiteSpace(value)
            ? Guid.NewGuid().ToString("N")
            : value;
    }
}

public sealed class ProjectRequest
{
    [Required, StringLength(160, MinimumLength = 2)]
    public string Title { get; init; } = string.Empty;

    [StringLength(180)]
    public string? Slug { get; init; }

    [Required, StringLength(500, MinimumLength = 5)]
    public string ShortDescription { get; init; } = string.Empty;

    public string? Description { get; init; }

    [StringLength(1000)]
    public string? ImageUrl { get; init; }

    [StringLength(1000)]
    public string? ProjectUrl { get; init; }

    [StringLength(1000)]
    public string? GithubUrl { get; init; }

    public bool IsPublished { get; init; }
    public int DisplayOrder { get; init; }
}
