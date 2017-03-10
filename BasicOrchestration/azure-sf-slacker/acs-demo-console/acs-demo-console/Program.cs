using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.ServiceBus;
using Microsoft.ServiceBus.Messaging;
using System.Net;
using Slack.Webhooks;

namespace acs_demo_console
{

    class Program
    {
        static void Main(string[] args)
        {
            // Gather environment variables and connect to Azure SB queue
            string AZURE_SB_SERVICE_NAMESPACE = "acslogging";
            string AZURE_SB_SHARED_ACCESS_KEY_NAME = "RootManageSharedAccessKey";
            string AZURE_SB_SHARED_ACCESS_KEY = "gnLZ2ixKkXng7rNvaCbgl9ucxsEKK7vuD5QkLl1iemM=";
            string sbEndpoint = "Endpoint=sb://" + AZURE_SB_SERVICE_NAMESPACE + ".servicebus.windows.net/;SharedAccessKeyName=" + AZURE_SB_SHARED_ACCESS_KEY_NAME + ";SharedAccessKey=" + AZURE_SB_SHARED_ACCESS_KEY;
            string SLACK_CHANNEL = "https://hooks.slack.com/services/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";

            long iterations = 0;

            var slackClient = new SlackClient(SLACK_CHANNEL);

            //QueueClient Client = QueueClient.CreateFromConnectionString(sbEndpoint, "statistics");
            var nsmgr = Microsoft.ServiceBus.NamespaceManager.CreateFromConnectionString(sbEndpoint);

            while (true)
            {
                long queueLength = nsmgr.GetQueue("statistics").MessageCount;

                string msgText = "Messages in queue: " + System.Convert.ToString(queueLength);
                Console.WriteLine(msgText);

                var slackMessage = new SlackMessage
                {
                    Channel = "#general",
                    Text = msgText,
                    IconEmoji = Emoji.BlackJoker,
                    Username = "service-fabric"
                };
                slackClient.Post(slackMessage);

                Thread.Sleep(500);
                iterations = iterations + 1;
            }
        }
 
    }
}
