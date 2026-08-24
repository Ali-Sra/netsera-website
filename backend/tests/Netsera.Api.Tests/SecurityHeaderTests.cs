using System.Net;

namespace Netsera.Api.Tests;

public sealed class SecurityHeaderTests(CustomWebApplicationFactory factory)
    : IClassFixture<CustomWebApplicationFactory>
{
    [Fact]
    public async Task Api_response_contains_security_headers()
    {
        var client = factory.CreateClient();
        var response = await client.GetAsync("/api/system/info");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.True(response.Headers.Contains("X-Content-Type-Options"));
        Assert.True(response.Headers.Contains("X-Frame-Options"));
        Assert.True(response.Headers.Contains("Referrer-Policy"));
        Assert.True(response.Headers.Contains("Permissions-Policy"));
    }
}
