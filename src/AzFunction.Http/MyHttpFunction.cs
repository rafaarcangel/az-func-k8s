using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using System.Net;

namespace AzFunction.Http
{
    public class MyHttpFunction(ILoggerFactory loggerFactory)
    {
        private readonly string _line = Environment.NewLine;

        private readonly ILogger _logger = loggerFactory.CreateLogger<MyHttpFunction>();

        [Function("MyHttpFunction")]
        public HttpResponseData Run([HttpTrigger(AuthorizationLevel.Anonymous, "get", "post")] HttpRequestData req)
        {
            _logger.LogInformation("C# HTTP trigger function processed a request.");

            return req.Method switch
            {
                WebRequestMethods.Http.Post => POST(req),
                _ => GET(req),
            };


        }

        private HttpResponseData POST(HttpRequestData req)
        {
            var response = GET(req);

            var requestBody = new StreamReader(req.Body).ReadToEnd();
            //dynamic data = JsonSerializer.Deserialize<object>(requestBody);

            response.WriteString($"{_line}{_line}This is you PO`ST BODY:");
            response.WriteString(_line);
            response.WriteString(requestBody);

            return response;
        }

        private HttpResponseData GET(HttpRequestData req)
        {
            var response = req.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Content-Type", "text/plain; charset=utf-8");

            response.WriteString("WELCOME TO AZURE FUNCTIONS!!");
            if (req.Query?.Keys.Count > 0)
            {
                response.WriteString(_line);
                response.WriteString($"{_line}Your mapped query params:");
                foreach (var key in req.Query.Keys)
                {
                    response.WriteString($"{_line}    - {key}: {req.Query[key.ToString()]}");
                }
            }

            return response;
        }
    }
}
