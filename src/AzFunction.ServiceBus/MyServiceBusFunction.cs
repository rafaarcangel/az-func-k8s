using Azure.Messaging.ServiceBus;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace AzFunction.ServiceBus
{
    public class MyServiceBusFunction
    {
        private readonly ILogger<MyServiceBusFunction> _logger;

        public MyServiceBusFunction(ILogger<MyServiceBusFunction> logger)
        {
            _logger = logger;
        }

        [Function(nameof(MyServiceBusFunction))]
        public async Task Run(
            [ServiceBusTrigger("%ServiceBusOptions:QueueName%", Connection = "ServiceBusOptions:ConnectionString")]
            ServiceBusReceivedMessage message,
            ServiceBusMessageActions messageActions)
        {
            _logger.LogInformation("Message ID: {id}", message.MessageId);
            _logger.LogInformation("Message Body: {body}", message.Body);
            _logger.LogInformation("Message Content-Type: {contentType}", message.ContentType);

            // Complete the message
            await messageActions.CompleteMessageAsync(message);
        }
    }
}
