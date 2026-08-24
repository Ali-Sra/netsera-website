using System.ComponentModel.DataAnnotations;

namespace Netsera.Application.DTOs;

public sealed class CreateContactMessageRequest
{
    [Required, StringLength(120, MinimumLength = 2)]
    public string Name { get; init; } = string.Empty;

    [Required, EmailAddress, StringLength(254)]
    public string Email { get; init; } = string.Empty;

    [StringLength(160)]
    public string? Subject { get; init; }

    [Required, StringLength(5000, MinimumLength = 10)]
    public string Message { get; init; } = string.Empty;
}
