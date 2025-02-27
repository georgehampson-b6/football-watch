import asyncio
import random

from nats.aio.client import Client as NATS

async def publish_messages():
    nc = NATS()

    # Connect to the NATS server
    await nc.connect("nats://k8s-charlton-traefike-c77fcc4307-40bb375fa565688a.elb.eu-west-2.amazonaws.com:4222")

    subject = "external.goal"
    message = '{"status": "goal"}'

    # Publish 100 messages per second
    try:
        while True:
            for _ in range(1000):
                message = random.choice(["goal", "no-goal"])
                data = str(message)
                print(message)
                await nc.publish(subject, data.encode())
                await asyncio.sleep(30) # Wait for 1 second
            print("Sent 100 messages.")
            await asyncio.sleep(30)  # Wait for 1 second
    except asyncio.CancelledError:
        print("Stopped sending messages.")
    finally:
        await nc.close()


async def main():
    task = asyncio.create_task(publish_messages())

    # Run for 10 seconds and then stop
    # await asyncio.sleep(10)
    # task.cancel()
    await asyncio.gather(task, return_exceptions=True)


# Run the script
asyncio.run(main())