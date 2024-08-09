import jwt
from cryptography.hazmat.primitives import serialization
import time
import json
import secrets
import requests

ENCODING = "utf-8"

request_method = "GET"
request_host = "api.coinbase.com"
request_path = "/api/v3/brokerage/accounts"
# request_path = "/api/v3/brokerage/products/BTC-USD"

def coinbase_time():
    clock_url = "https://api.coinbase.com/v2/time"
    req = requests.get(clock_url)
    info = req.json()
    return info["data"]["epoch"]

def build_jwt(uri):
    with open("cdp_api_key.json", "r", encoding=ENCODING) as fp:
        key = json.load(fp)
    private_key_bytes = key["privateKey"].encode(ENCODING)
    private_key = serialization.load_pem_private_key(private_key_bytes, password=None)
    timestamp = coinbase_time()
    jwt_payload = {
        "sub": key["name"],
        "iss": "cdp",
        "nbf": int(timestamp),
        "exp": int(timestamp) + 120,
        "uri": uri,
    }
    jwt_token = jwt.encode(
        jwt_payload,
        private_key,
        algorithm="ES256",
        headers={"kid": key["name"], "nonce": secrets.token_hex()},
    )
    return jwt_token

def main():
    uri = f"{request_method} {request_host}{request_path}"
    jwt_token = build_jwt(uri)
    headers = {
        "Authorization": f"Bearer ${jwt_token}"
    }
    req = requests.get(f"https://{request_host}{request_path}", headers=headers)
    print(jwt_token)
    print(req)

if __name__ == "__main__":
    main()
