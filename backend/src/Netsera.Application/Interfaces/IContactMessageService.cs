using Netsera.Application.DTOs;

namespace Netsera.Application.Interfaces;

public interface IContactMessageService
{
    Task<ContactMessageResponse> CreateAsync(CreateContactMessageRequest request, CancellationToken cancellationToken = default);
}
