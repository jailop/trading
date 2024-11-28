import sys
import asyncio
import math
import logging
from datetime import datetime
from dataclasses import dataclass

from indicators import SMA
from wsclient import subscribe, Bot
from portfolio import SimplePortfolio

logging.basicConfig(stream=sys.stdout, level=logging.INFO)

PORT = 12300

LONG_TERM = 480
SHORT_TERM = 240
PORTFOLIO_VALUE = 10000.0

long_tracer = SMA(LONG_TERM)
short_tracer = SMA(SHORT_TERM)
portfolio = SimplePortfolio(1000.0)


def showIndicators(timestamp, long_sma, short_sma):
    """"
    This function logs the candlebars data.
    """
    logging.info(
        "%s - Long SMA: %.4f, Short SMA: %.4f",
        datetime.fromtimestamp(timestamp).strftime("%Y-%m-%d %H:%M:%S"),
        long_sma,
        short_sma,
    )


def strategy(candlebars):
    """
    This function implements the strategy. It receives the candlebars data and
    sends buy or sell signals to the portfolio.
    """
    # Updating the indicators
    close_price = candlebars["close"]
    if close_price == 0:
        return
    long_tracer.update(close_price)
    short_tracer.update(close_price)
    # Getting the current values of the indicators
    long_sma = long_tracer.level()
    short_sma = short_tracer.level()
    # Implementing the strategy
    if math.isnan(long_sma) or math.isnan(short_sma):
        return
    # Buy Signal
    if (short_sma > long_sma) and (close_price > short_sma):
        # showIndicators(candlebars["time"], long_sma, short_sma)
        portfolio.buy(close_price)
    # Sell Signal
    elif (close_price < short_sma) or (short_sma < long_sma):
        # showIndicators(candlebars["time"], long_sma, short_sma)
        portfolio.sell(close_price)


if __name__ == "__main__":
    asyncio.run(subscribe(strategy))
