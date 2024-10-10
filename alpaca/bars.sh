#!/bin/sh
API_KEY=""
SECRET_KEY=""
SYMBOLS="INTC,NVDA,MSFT,AMD"
START="2024-01-01"
END="2024-06-30"
URL="https://data.alpaca.markets/v2/stocks/bars?symbols=$SYMBOLS&timeframe=1D&start=$START&end=$END"

curl $URL \
    -H "APCA-API-KEY-ID: $API_KEY" \
    -H "APCA-API-SECRET-KEY: $SECRET_KEY"
