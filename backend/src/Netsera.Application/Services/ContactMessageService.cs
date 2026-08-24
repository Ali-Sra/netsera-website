using Netsera.Application.DTOs;
using Netsera.Application.Interfaces;
using Netsera.Domain.Entities;

namespace Netsera.Application.Services;

public sealed class ContactMessageService(IApplicationDbContext dbContext) : IContactMessageService
{
    public async Task<ContactMessageResponse> CreateAsync(CreateContactMessageRequest request, CancellationToken cancellationToken = default)
    {
        var entity = new ContactMessage
        {
            Name = request.Name.Trim(),
            Email = request.Email.Trim().ToLowerInvariant(),
            Subject = string.IsNullOrWhiteSpace(request.Subject) ? null : request.Subject.Trim(),
            Message = request.Message.Trim()
        };

        dbContext.ContactMessages.Add(entity);
        await dbContext.SaveChangesAsync(cancellationToken);

        return new ContactMessageResponse(entity.Id, entity.Status, entity.CreatedAtUtc);
    }
}
