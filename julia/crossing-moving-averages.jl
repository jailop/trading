using YahooFinance
using Indicators
using Statistics
using Plots

slow_period = 9
fast_period = 21

# Pulling data
data = history("AAPL"; period="1year", interval="1d")
close_prices = data.close
dates = date.timestamp

# Moving averages
fastMA = ema(close_prices, fast_period)
slowMA = ema(close_prices, slow_period)

# Signals
buy_signal = [
    i > 1 &&
    fastMA[i - 1] <= slowMA[i - 1] &&
    fastMA[i] > slowMA[i]
    for i in 1:length(fastMA)
]
sell_signal = [
    i > 1 &&
    fastMA[i - 1] >= slowMA[i - 1] &&
    fastMA[i] < slowMA[i]
    for i in 1:length(fastMA)
]

buy_idx = findall(buy_signal)
sell_idx = findall(sell_signal)

# Plotting
plot(dates, close_prices, label="Close Price", lw=2, color=:gray,
     legend=:topleft)
plot!(dates, fastMA, label="Fast Moving Average", lw=2, color=:orange)
plot!(dates, slowMA, label="Slow Moving Average", lw=2, color=:blue)
scatter!(dates[buy_idx], close_prices[buy_idx], markershape=:triangle,
         color=:green, label="Buy")
scatter!(dates[sell_idx], close_prices[sell_idx], markershape=:vline,
        color=:red, label="Sell")

