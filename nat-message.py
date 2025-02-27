import asyncio
import random
import time  # Import time module

from nats.aio.client import Client as NATS

async def publish_messages():
    nc = NATS()

    # Connect to the NATS server
    await nc.connect("nats://k8s-charlton-traefike-c77fcc4307-40bb375fa565688a.elb.eu-west-2.amazonaws.com:4222")

    subject = "external.goal"
    message = '{"status": "goal"}'

    # Publish 1000 messages per second
    try:
        while True:
            for _ in range(1000):
                start_time = time.perf_counter()  # Start timing
                message = random.choice(["goal", "no-goal"])
                data = str(message)
                await nc.publish(subject, data.encode())
                end_time = time.perf_counter()  # End timing

                elapsed_time = (end_time - start_time) * 1000  # Convert to milliseconds
                print(f"Message: {message} | Time Taken: {elapsed_time:.3f} ms")

                await asyncio.sleep(5)  # Wait for 30 seconds

            print("Sent 100 messages.")
            await asyncio.sleep(5)  # Wait for 30 seconds
    except asyncio.CancelledError:
        print("Stopped sending messages.")
    finally:
        await nc.close()


async def main():
    task = asyncio.create_task(publish_messages())

    # Run indefinitely
    await asyncio.gather(task, return_exceptions=True)


# Run the script
asyncio.run(main())
