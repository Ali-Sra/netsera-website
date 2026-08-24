using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using Netsera.Application.DTOs;
using Netsera.Application.Interfaces;

namespace Netsera.Api.Controllers;

[ApiController]
[Route("api/contact")]
public sealed class ContactController(IContactMessageService service) : ControllerBase
{
    [HttpPost]
    [EnableRateLimiting("contact")]
    [ProducesResponseType(typeof(ContactMessageResponse), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status429TooManyRequests)]
    public async Task<ActionResult<ContactMessageResponse>> Create(
        [FromBody] CreateContactMessageRequest request,
        CancellationToken cancellationToken)
    {
        var result = await service.CreateAsync(request, cancellationToken);
        return StatusCode(StatusCodes.Status201Created, result);
    }
}
