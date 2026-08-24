using System.Net;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Mvc.Testing;

namespace Netsera.Api.Tests;

public sealed class AdminAuthorizationTests(CustomWebApplicationFactory factory)
    : IClassFixture<CustomWebApplicationFactory>
{
    private HttpClient CreateHttpsClient()
    {
        return factory.CreateClient(new WebApplicationFactoryClientOptions
        {
            BaseAddress = new Uri("https://localhost"),
            HandleCookies = true,
            AllowAutoRedirect = false
        });
    }

    [Fact]
    public async Task Anonymous_user_cannot_read_admin_messages()
    {
        var client = CreateHttpsClient();

        var response = await client.GetAsync("/api/admin/messages");

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task Invalid_login_returns_401()
    {
        await factory.SeedAdminAsync();
        var client = CreateHttpsClient();

        var response = await client.PostAsJsonAsync("/api/admin/auth/login", new
        {
            email = "admin@test.local",
            password = "WrongPassword123!"
        });

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task Authenticated_admin_can_read_messages()
    {
        await factory.SeedAdminAsync();
        await factory.SeedContactMessageAsync();

        var client = CreateHttpsClient();

        var login = await client.PostAsJsonAsync("/api/admin/auth/login", new
        {
            email = "admin@test.local",
            password = "VeryStrongTestPassword123!"
        });

        Assert.Equal(HttpStatusCode.OK, login.StatusCode);

        var response = await client.GetAsync("/api/admin/messages");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }
}
