using Microsoft.AspNetCore.Mvc;

namespace Netsera.Api.Middleware;

public sealed class ExceptionHandlingMiddleware(
    RequestDelegate next,
    ILogger<ExceptionHandlingMiddleware> logger)
{
    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await next(context);
        }
        catch (Exception ex)
        {
            logger.LogError(
                ex,
                "Unhandled exception. TraceId: {TraceId}",
                context.TraceIdentifier);

            if (context.Response.HasStarted)
            {
                throw;
            }

            context.Response.Clear();
            context.Response.StatusCode =
                StatusCodes.Status500InternalServerError;

            context.Response.ContentType = "application/problem+json";

            var problem = new ProblemDetails
            {
                Status = StatusCodes.Status500InternalServerError,
                Title = "Ein interner Fehler ist aufgetreten.",
                Detail = "Die Anfrage konnte nicht verarbeitet werden."
            };

            problem.Extensions["traceId"] = context.TraceIdentifier;

            await context.Response.WriteAsJsonAsync(problem);
        }
    }
}
