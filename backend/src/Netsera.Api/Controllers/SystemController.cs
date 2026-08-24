using Microsoft.AspNetCore.Mvc;

namespace Netsera.Api.Controllers;

[ApiController]
[Route("api/system")]
public sealed class SystemController : ControllerBase
{
    [HttpGet("info")]
    public IActionResult Info() => Ok(new
    {
        service = "Netsera.Api",
        status = "ok",
        utc = DateTime.UtcNow
    });
}
