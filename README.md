### 🏆 Football Watch - Garmin Connect IQ App ###

This is a Garmin Connect IQ application that displays goal/no-goal notifications on a Garmin watch by making HTTP GET requests to a server. 
The app updates the watch screen with an image based on the received status (Goal, No-Goal, or No Data).

 # 📌 Features

✔️ Real-time goal updates from an external server
✔️ Displays different images based on the received status
✔️ Vibration alerts when a goal is detected

# 📂 Folder Structure

📦 football-watch
 ┣ 📂 source         # Contains all Monkey C source files
 ┃ ┣ 📜 main.mc      # Main application logic
 ┃ ┣ 📜 app.xml      # Application metadata and device support
 ┣ 📂 resources      # Resources used in the app
 ┃ ┣ 📂 images
 ┃ ┃ ┣ 🏆 goalImage.png      # Image shown when a goal is detected
 ┃ ┃ ┣ ❌ noGoalImage.png    # Image shown when no goal is detected
 ┃ ┃ ┣ 🔄 noDataImage.png    # Image shown when no data is received
 ┃ ┣ 📜 layouts.xml  # UI layout definitions
 ┣ 📜 monkey.jungle  # Build configuration
 ┣ 📜 README.md      # This file!

# 🔧 Installation & Setup

# 1️⃣ Install the Garmin Connect IQ SDK

Download and install the Garmin Connect IQ SDK from:🔗 https://developer.garmin.com/connect-iq/sdk/

After installation, make sure MonkeyC, MonkeyDo, and Simulator are accessible in your terminal.

Test your installation:

monkeyc --version

# 2️⃣ Clone the Repository

git clone https://github.com/YOUR_USERNAME/football-watch.git
cd football-watch

# 3️⃣ Install Dependencies

Ensure your monkey.jungle file has the correct SDK path and devices:

sdk = "path/to/connectiq-sdk"
device = "fr265"

If using a different device, update the device field (see below).

# 4️⃣ Build and Run the Application

To compile and run the app in the Garmin simulator:

monkeyc -d fr265 -f monkey.jungle -o FootballWatch.prg -y developer_key.der
monkeydo FootballWatch.prg fr265

# 📡 Configuring the Server

The app fetches goal updates from an external server. To modify the server URL:

Open main.mc

Find the line:

var url = "http://192.168.178.73:8889";

Replace it with your server's IP and port:

var url = "http://your-server-ip:your-port";

Ensure the server is reachable over Wi-Fi.

# 📱 Adding a New Garmin Device

If you want to run this app on a different Garmin watch (e.g., Forerunner 265):

Open app.xml

Add your device inside <products>:

<products>
   <product id="fenix6pro"/>
   <product id="forerunner265"/>
</products>

Modify the build command to use your new device:

monkeyc -d forerunner265 -f monkey.jungle -o FootballWatch.prg -y developer_key.der
monkeydo FootballWatch.prg forerunner265

# 🛠 Customizing the Images

To modify the images displayed on the watch:

Replace goalImage.png, noGoalImage.png, and noDataImage.png inside resources/images/

Ensure the image dimensions match your device's screen resolution

Rebuild the project after updating the images:

monkeyc -d fenix6pro -f monkey.jungle -o FootballWatch.prg -y developer_key.der

# 📍 Debugging Issues

Common Errors & Fixes

Error

Cause

Fix

Response Code: -1001

Watch cannot connect to the server

Ensure server is running & reachable

Invalid device id specified

Device name not in app.xml

Add device ID under <products>

Error: Unhandled Exception

Code crash due to missing variables

Run monkeydo and check logs

View Debug Logs

Run the application in verbose mode to see logs:

monkeydo FootballWatch.prg fenix6pro

If you don't see 📡 Sending request, check if Wi-Fi is enabled on your watch.

✅ Contributing

Feel free to fork this repository, modify the app, and submit pull requests!For feature requests or bug reports, open an issue on GitHub.

🚀 Enjoy breaking the Football Watch!








##########################################################


### NATS to HTTP Relay Server ###

## Overview

This Python script acts as a relay server that listens for messages from a NATS topic and exposes a simple HTTP endpoint to provide status updates. 
The HTTP response alternates between goal and no-goal based on the NATS message received.

## Features
Listens to a specified NATS topic
Starts an HTTP server to provide status updates
Updates the HTTP response dynamically based on received NATS messages
Handles errors gracefully and attempts reconnection if needed

## Prerequisites

Python 3.7+

nats-py for NATS messaging

aiohttp for HTTP server

asyncio for asynchronous operations

## Installation

Ensure you have Python 3.7+ installed, then install the required dependencies:

pip install nats-py aiohttp

## Configuration

The script requires a configuration file (config.json) with the following structure:

{
    "nats_servers": {
        "url": "nats://localhost:4222",
        "topic": "game.status"
    },
    "http_port": 8080,
    "http_host": "127.0.0.1",
    "http_path": "/"
}

## Running the Server

Start the relay server using:

python relay_server.py --config config.json

## How It Works

The script connects to a NATS server and subscribes to the specified topic.

It starts an HTTP server that returns the latest status (goal or no-goal).

When a NATS message is received, the status is updated accordingly.

The HTTP response dynamically reflects the current status.

If a goal message is received, the response remains goal for 15 seconds before switching back to no-goal.

## Endpoints

GET / - Returns the latest status in JSON format:

{"status": "goal", "message": "Simulated response"}

## Example Usage

To test the HTTP server:

curl http://127.0.0.1:8080

To send a test message via NATS:

nats-pub -s nats://localhost:4222 game.status "goal"

## Debugging

Logs will print received messages and errors.

If the HTTP server fails to start, ensure the port is not in use.

If no messages are received, verify the NATS connection.

## Troubleshooting

If the script fails to connect to NATS, ensure the NATS server is running and reachable.

If the HTTP endpoint does not update, verify that messages are being published to the correct topic.


