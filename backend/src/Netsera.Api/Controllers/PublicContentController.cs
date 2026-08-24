using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Netsera.Infrastructure.Persistence;

namespace Netsera.Api.Controllers;

[ApiController]
[Route("api/content")]
public sealed class PublicContentController(ApplicationDbContext db) : ControllerBase
{
    [HttpGet("projects")]
    public async Task<IActionResult> Projects(CancellationToken cancellationToken)
    {
        var items = await db.Projects
            .AsNoTracking()
            .Where(x => x.IsPublished)
            .OrderBy(x => x.DisplayOrder)
            .ThenBy(x => x.Title)
            .Select(x => new
            {
                x.Id,
                x.Title,
                x.Slug,
                x.ShortDescription,
                x.Description,
                x.ImageUrl,
                x.ProjectUrl,
                x.GithubUrl,
                x.DisplayOrder
            })
            .ToListAsync(cancellationToken);

        return Ok(items);
    }

    [HttpGet("services")]
    public async Task<IActionResult> Services(CancellationToken cancellationToken)
    {
        var items = await db.Services
            .AsNoTracking()
            .Where(x => x.IsPublished)
            .OrderBy(x => x.DisplayOrder)
            .ThenBy(x => x.Title)
            .Select(x => new
            {
                x.Id,
                x.Title,
                x.Slug,
                x.Description,
                x.Icon,
                x.DisplayOrder
            })
            .ToListAsync(cancellationToken);

        return Ok(items);
    }
}
