import requests
import time
import hmac
import hashlib
import access
import json

# url = "https://api.coinbase.com/api/v3/brokerage/products/BTC-USD"
url = "https://api.coinbase.com/api/v3/brokerage/accounts"
base_url = "https://api.coinbase.com"

with open("cdp_api_key.json", "r", encoding="utf-8") as fp:
    access = json.load(fp)

timestamp = str(int(time.time()))
method = "GET"
requestPath = url[len(base_url):]
body = ""  # Empty
message = timestamp + method + requestPath + body
signature = hmac.new(access["privateKey"].encode("utf-8"), message.encode("utf-8"), digestmod=hashlib.sha256).digest()

print(message)
print(signature.hex())
print(url)
headers = {
    'Content-Type': 'application/json',
    "CB-ACCESS-KEY": access["name"],
    "CB-ACCESS-SIGN": signature.hex(),
    "CB-ACCESS-TIMESTAMP": timestamp,
}

req = requests.get(url, headers=headers)
print(req.status_code)

