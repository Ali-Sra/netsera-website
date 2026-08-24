using System.Net;
using System.Net.Http.Json;
using Microsoft.Extensions.DependencyInjection;
using Netsera.Infrastructure.Persistence;

namespace Netsera.Api.Tests;

public sealed class ContactApiTests(CustomWebApplicationFactory factory)
    : IClassFixture<CustomWebApplicationFactory>
{
    [Fact]
    public async Task Valid_contact_request_returns_201_and_persists_message()
    {
        var client = factory.CreateClient();

        var response = await client.PostAsJsonAsync("/api/contact", new
        {
            name = "  Ali Test  ",
            email = "ALI.TEST@EXAMPLE.COM",
            subject = "  Phase 8  ",
            message = "This is a valid integration test message."
        });

        Assert.Equal(HttpStatusCode.Created, response.StatusCode);

        using var scope = factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var stored = Assert.Single(db.ContactMessages);

        Assert.Equal("Ali Test", stored.Name);
        Assert.Equal("ali.test@example.com", stored.Email);
        Assert.Equal("Phase 8", stored.Subject);
        Assert.Equal("New", stored.Status);
    }

    [Fact]
    public async Task Invalid_contact_request_returns_400()
    {
        var client = factory.CreateClient();

        var response = await client.PostAsJsonAsync("/api/contact", new
        {
            name = "A",
            email = "not-an-email",
            subject = "Test",
            message = "short"
        });

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }
}
