import json
from coinbase.rest import RESTClient

ENCODING = "utf-8"

with open("cdp_api_key.json", "r", encoding=ENCODING) as fp:
    key = json.load(fp)

client = RESTClient(key_file="cdp_api_key.json")

kwargs = {
    "param1": 10,
    "param2": "mock_param",
}

product = client.get_product(product_id="BTC-USD", **kwargs)
print(product)
