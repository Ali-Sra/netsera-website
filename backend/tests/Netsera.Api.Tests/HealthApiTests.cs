using System.Net;

namespace Netsera.Api.Tests;

public sealed class HealthApiTests(CustomWebApplicationFactory factory)
    : IClassFixture<CustomWebApplicationFactory>
{
    [Theory]
    [InlineData("/health")]
    [InlineData("/health/live")]
    [InlineData("/health/ready")]
    public async Task Health_endpoints_return_success(string path)
    {
        var client = factory.CreateClient();
        var response = await client.GetAsync(path);
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }
}
