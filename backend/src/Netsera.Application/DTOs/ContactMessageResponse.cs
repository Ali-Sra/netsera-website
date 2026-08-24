namespace Netsera.Application.DTOs;

public sealed record ContactMessageResponse(Guid Id, string Status, DateTime CreatedAtUtc);
