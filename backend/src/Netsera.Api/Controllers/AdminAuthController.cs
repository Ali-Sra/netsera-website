using System.ComponentModel.DataAnnotations;
using System.Security.Claims;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.EntityFrameworkCore;
using Netsera.Domain.Entities;
using Netsera.Infrastructure.Persistence;

namespace Netsera.Api.Controllers;

[ApiController]
[Route("api/admin/auth")]
public sealed class AdminAuthController(
    ApplicationDbContext db,
    IPasswordHasher<AdminUser> passwordHasher) : ControllerBase
{
    [HttpPost("login")]
    [AllowAnonymous]
    [EnableRateLimiting("admin-login")]
    public async Task<IActionResult> Login(
        [FromBody] AdminLoginRequest request,
        CancellationToken cancellationToken)
    {
        var normalizedEmail = request.Email.Trim().ToUpperInvariant();

        var user = await db.AdminUsers
            .SingleOrDefaultAsync(
                x => x.NormalizedEmail == normalizedEmail,
                cancellationToken);

        if (user is null || !user.IsActive)
        {
            return Unauthorized(new { message = "E-Mail oder Passwort ist falsch." });
        }

        var verification = passwordHasher.VerifyHashedPassword(
            user,
            user.PasswordHash,
            request.Password);

        if (verification == PasswordVerificationResult.Failed)
        {
            return Unauthorized(new { message = "E-Mail oder Passwort ist falsch." });
        }

        if (verification == PasswordVerificationResult.SuccessRehashNeeded)
        {
            user.PasswordHash = passwordHasher.HashPassword(user, request.Password);
        }

        user.LastLoginAtUtc = DateTime.UtcNow;
        await db.SaveChangesAsync(cancellationToken);

        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Email, user.Email),
            new Claim(ClaimTypes.Role, "Admin")
        };

        var identity = new ClaimsIdentity(
            claims,
            CookieAuthenticationDefaults.AuthenticationScheme);

        await HttpContext.SignInAsync(
            CookieAuthenticationDefaults.AuthenticationScheme,
            new ClaimsPrincipal(identity),
            new AuthenticationProperties
            {
                IsPersistent = false,
                AllowRefresh = true
            });

        return Ok(new { email = user.Email, role = "Admin" });
    }

    [HttpPost("logout")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Logout()
    {
        if (!HasAdminRequestHeader())
        {
            return BadRequest(new { message = "Missing admin request header." });
        }

        await HttpContext.SignOutAsync(
            CookieAuthenticationDefaults.AuthenticationScheme);

        return NoContent();
    }

    [HttpGet("me")]
    [Authorize(Roles = "Admin")]
    public IActionResult Me()
    {
        return Ok(new
        {
            email = User.FindFirstValue(ClaimTypes.Email),
            role = "Admin"
        });
    }

    private bool HasAdminRequestHeader() =>
        Request.Headers.TryGetValue("X-Netsera-Admin", out var value)
        && value == "1";
}

public sealed class AdminLoginRequest
{
    [Required, EmailAddress, StringLength(254)]
    public string Email { get; init; } = string.Empty;

    [Required, StringLength(200, MinimumLength = 12)]
    public string Password { get; init; } = string.Empty;
}
