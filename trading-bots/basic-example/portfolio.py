"""
This module is intended to represent portfolios and their policy implementaions.
"""

class SimplePortfolio:
    """
    This is a simple portfolio. It works only with one asset. When it receives a
    buy signal, it uses all the available funds to buy the asset. When it
    receives a sell signal, it sells all the asset.
    """

    value: float
    qty: float = 0

    def __init__(self, value: float):
        self.value = value

    def sell(self, price):
        if self.qty > 0:
            print(
                "Selling %.4f shares by USD %.4f each" % (self.qty, price)
            )
            self.value = price * self.qty
            print("  Portfolio value: USD %.4f" % (self.value))
            self.qty = 0

    def buy(self, price):
        if self.value > 0:
            self.qty = self.value / price
            print("Buying %.4f shares by USD %.4f each" % (self.qty, price))
            self.value = 0
            print("  Portfolio value: USD %.4f" % (self.qty * price))
