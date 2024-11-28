import json
import asyncio
import websockets

PORT = 12300
clients = set()

def dataset_path():
    refPath = "../../datasets/btcusd-1min.path.txt"
    with open(refPath, "r", encoding="utf-8") as fd:
        return fd.read()

def prepare_message(line):
    tokens = line.strip().split(",")
    return json.dumps({
        "time": float(tokens[0]),
        "open": float(tokens[1]),
        "high": float(tokens[2]),
        "low": float(tokens[3]),
        "close": float(tokens[4]),
        "volume": float(tokens[5]),
    })

async def register_client(websocket):
    clients.add(websocket)
    try:
        await websocket.wait_closed()
    finally:
        clients.remove(websocket)

async def broadcast_message(message):
    if clients:
        await asyncio.gather(*(client.send(message) for client in clients))

async def stream_content():
    try:
        first = True
        with open(dataset_path(), "r", encoding="utf-8") as fd:
            for line in fd:
                if first:
                    first = False
                    continue
                line = line.strip()
                if line:
                    await broadcast_message(prepare_message(line))
                    await asyncio.sleep(0.1)
    except FileNotFoundError:
        print("Dataset not found")

async def start_server():
    server = websockets.serve(register_client, "localhost", PORT)
    await asyncio.gather(server, stream_content())

if __name__ == "__main__":
    asyncio.run(start_server())
