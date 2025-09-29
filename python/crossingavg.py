# Crossing Moving Averages
# 
# This strategy is based in two moving averages, one faster than the
# other. When the faster moving average cross over the slower, it could
# be interpreted as an uptrend movement and it can be a good time to
# buy. In the same way, when the faster moving average cross under the
# slower, it could be interpreted as a downtrend movement in the
# market, signing a good time to sell.
#
# To use this script, use the following command:
#
#     uv run crossingavg.py [OPTIONS]
#
# Options can be:
#
#   -h, --help       show this help message and exit
#   --symbol SYMBOL  Ticker symbol
#   --fast FAST      Fast MA length
#   --slow SLOW      Slow MA length
#   --ema            Use EMA if True, SMA if False
#
# (2025) Jaime Lopez <https://github.com/jailop>

# /// script
# dependencies = [
#     "yfinance",
#     "pandas",
#     "matplotlib",
#     "PyQt5",
# ]
# ///

import argparse
import yfinance as yf
import pandas as pd
import matplotlib

matplotlib.use("QtAgg")
import matplotlib.pyplot as plt

# Parsing arguments
parser = argparse.ArgumentParser(description="Crossing Moving Averages")
parser.add_argument("--symbol", type=str, default="AAPL", help="Ticker symbol")
parser.add_argument("--fast", type=int, default=9, help="Fast MA length")
parser.add_argument("--slow", type=int, default=21, help="Slow MA length")
parser.add_argument(
    "--ema", action="store_false", help="Use EMA if True, SMA if False"
)
args = parser.parse_args()

# Fetching Data
df = yf.download(args.symbol, period="1y", interval="1d", auto_adjust=True)
df = df[["Close"]].copy()

# Compute Moving Averages
if args.ema:
    df["FastMA"] = df["Close"].ewm(span=args.fast, adjust=False).mean()
    df["SlowMA"] = df["Close"].ewm(span=args.slow, adjust=False).mean()
else:
    df["FastMA"] = df["Close"].rolling(args.fast).mean()
    df["SlowMA"] = df["Close"].rolling(args.slow).mean()

# Detect Buy/Sell Signals
df["Buy"] = (df["FastMA"].shift(1) <= df["SlowMA"].shift(1)) & (
    df["FastMA"] > df["SlowMA"]
)
df["Sell"] = (df["FastMA"].shift(1) >= df["SlowMA"].shift(1)) & (
    df["FastMA"] < df["SlowMA"]
)

subset = df[df["Buy"] | df["Sell"]]
print(subset[["Close", "FastMA", "SlowMA", "Buy", "Sell"]])

# Plot using Matplotlib
plt.figure(figsize=(15, 7))

# Price and MAs
plt.plot(df.index, df["Close"], label="Close", color="gray")
plt.plot(df.index, df["FastMA"], label=f"Fast MA ({args.fast})", color="orange")
plt.plot(df.index, df["SlowMA"], label=f"Slow MA ({args.slow})", color="blue")

plt.fill_between(df.index, df["SlowMA"], df["FastMA"],
                 where=df["FastMA"] > df["SlowMA"], color="green", alpha=0.2)
plt.fill_between(df.index, df["SlowMA"], df["FastMA"],
                 where=df["FastMA"] < df["SlowMA"], color="red", alpha=0.2)
# Buy/Sell markers
plt.scatter(
    df.index[df["Buy"]],
    df["Close"][df["Buy"]],
    marker="o",
    color="green",
    s=100,
    label="Buy",
)
plt.scatter(
    df.index[df["Sell"]],
    df["Close"][df["Sell"]],
    marker="o",
    color="red",
    s=100,
    label="Sell",
)

plt.title(f"{args.symbol} Crossing Moving Averages")
plt.xlabel("Date")
plt.ylabel("Price")
plt.legend()
plt.grid(True)
plt.show()
