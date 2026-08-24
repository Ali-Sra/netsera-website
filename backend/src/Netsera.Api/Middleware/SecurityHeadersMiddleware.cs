namespace Netsera.Api.Middleware;

public sealed class SecurityHeadersMiddleware(RequestDelegate next)
{
    public async Task InvokeAsync(HttpContext context)
    {
        var headers = context.Response.Headers;

        headers["X-Content-Type-Options"] = "nosniff";
        headers["X-Frame-Options"] = "DENY";
        headers["Referrer-Policy"] = "strict-origin-when-cross-origin";
        headers["Permissions-Policy"] =
            "camera=(), microphone=(), geolocation=(), payment=()";

        if (!context.Request.Path.StartsWithSegments("/swagger"))
        {
            headers["Content-Security-Policy"] =
                "default-src 'none'; frame-ancestors 'none'; base-uri 'none'";
        }

        await next(context);
    }
}
