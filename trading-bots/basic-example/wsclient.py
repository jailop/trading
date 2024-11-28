"""
This module contains the websocket client that connects to the server.
"""

import json
from typing import Dict, Callable
import logging
import websockets

SERVER = "localhost"
PORT = 12300

Bot = Callable[[Dict[str, float]], None]


async def subscribe(bot: Bot):
    """
    Connects to the server and subscribes to the trades stream.
    It uses a bot function that process candlestick data.
    """
    uri = f"ws://{SERVER}:{PORT}"
    try:
        async with websockets.connect(uri) as websocket:
            while True:
                try:
                    message = await websocket.recv()
                    canblebars = json.loads(message)
                    bot(canblebars)
                except websockets.ConnectionClosed:
                    logging.warning("Connection closed")
                    break
    except ConnectionRefusedError:
        logging.info("Start trading...")
        logging.error("Connection refused")
