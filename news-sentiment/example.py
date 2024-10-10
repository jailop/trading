from alpaca_trade_api import REST, Stream
import config

rest_client = REST(config.API_KEY, config.API_SECRET)
news = res_client.get_news("AAPL", "2024-07-01", "2024-07-31")

