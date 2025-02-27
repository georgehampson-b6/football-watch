import asyncio
import nats
from nats.aio.client import Client as NATS
import argparse
import logging
import json
from aiohttp import web

# Set up logging with the specified format and date format
logging.basicConfig(
    format='[%(asctime)s.%(msecs)03d %(levelname)s] %(message)s',
    level=logging.INFO,
    datefmt='%Y-%m-%d %H:%M:%S'
)
logger = logging.getLogger(__name__)

MAX_QUEUE_SIZE = 1000
RECONNECT_DELAY = 2  # Delay before attempting to reconnect

responseData = {
    "status": "no-goal"
}


async def http_request_handler(request):
    try:
        # data = await request.text()  # Read the POST body
        #
        # if not data:
        #     return web.Response(status=200, text="Empty request body")

        return web.json_response(responseData, status=200)
    except Exception as e:
        logger.error(f"Error in HTTP handler: {e}")
        return web.Response(status=500, text="Internal Server Error")
    except asyncio.CancelledError:
        logger.info("HTTP request handler task was cancelled.")

async def start_http_server(http_port, http_host, http_path):
    app = web.Application()
    app.router.add_get(http_path, lambda request: http_request_handler(request))

    while True:
        try:
            runner = web.AppRunner(app)
            await runner.setup()
            site = web.TCPSite(runner, http_host, http_port)
            logger.info(f"HTTP Server running at http://{http_host}:{http_port}{http_path}")
            await site.start()
            while True:
                await asyncio.sleep(3600)  # Keep the server running
        except OSError as e:
            logger.error(f"Failed to start HTTP server on {http_host}:{http_port}: {e}. Retrying in {RECONNECT_DELAY} seconds...")
            await asyncio.sleep(RECONNECT_DELAY)
        except asyncio.CancelledError:
            logger.info("HTTP server task was cancelled.")
            break


async def message_handler(msg):
    subject = msg.subject
    data = msg.data.decode()
    print(f"Received a message on '{subject}': {data}")
    if data == 'goal':
        responseData['status'] = "goal"
        await asyncio.sleep(15)
        responseData['status'] = "no-goal"


async def main(config):
    server_task = asyncio.create_task(
        start_http_server(config.get("http_port", 8080), config.get("http_host", "127.0.0.1"),
                          config.get("http_path", "/")))
    nats = NATS()
    # Connect to the NATS server
    await nats.connect(config['nats_servers']['url'])
    # Subscribe to the subject
    subject = config['nats_servers']['topic']
    await nats.subscribe(subject, cb=message_handler)
    print(f"Subscribed to '{subject}'")
    # Keep the connection open to listen for messages
    while True:
        await asyncio.sleep(1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="TCP to NATS Forwarder")
    parser.add_argument("--config", type=str, default="config.json", help="Path to the config JSON")

    args = parser.parse_args()

    config_path = args.config

    config = json.load(open(config_path))

    if "nats_servers" not in config:
        raise RuntimeError(f"nats_servers list not in config. Please check that it is present and spelt correctly.")
    if len(config["nats_servers"]['url']) == 0:
        raise RuntimeError(f"nats_servers URL is empty in config.")
    if len(config["nats_servers"]['topic']) == 0:
        raise RuntimeError(f"nats_servers topic is empty in config.")
    asyncio.run(main(config))
