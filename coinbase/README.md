Three ways to try to connect to Coinbase API:

legacy.py : https://docs.cdp.coinbase.com/advanced-trade/docs/rest-api-auth-legacy/

jwt.py: https://docs.cdp.coinbase.com/advanced-trade/docs/rest-api-auth/#generating-a-jwt

coinbase-advanced.py: https://docs.cdp.coinbase.com/advanced-trade/docs/rest-api-auth/#generating-a-jwt

To be able to run these scripts, install this libraries:

```bash
pip3 install coinbase-advanced-py PyJWT cryptography
```

To run them:

```bash
python3 legacy.py
python3 jwt.py
python3 coinbase-advanced.py
```
