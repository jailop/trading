"""
This module is intended to provide classes for various technical indicators.

Classes defined in this module share common names for their methods:

- __init__(...) : initializes the indicator with the required parameters.
- update(value) : updates the indicator with a new value, for example the
  current closing price of a stock.
- level() : returns the current value of the indicator.
"""

import math

class SMA:
    """
    Simple Moving Average (SMA) indicator.
    It works accumulating the last N values and dividing by N.
    It keeps track of every previous value inputed, so when a new value is
    inputed, the oldest value is subtracted from the accumulated sum.
    In that way, this indicator doesn't need to keep track of all the values
    that conform the series. Moreover, it doesn't need to sum all the values
    in the series, because they are already accumulated.
    """
    periods: int        # number of periods
    accum: float = 0.0  # accumulated sum of values
    counter: int = 0    # number of values inputed
    prev: float = 0.0   # previous inputed value
    def __init__(self, periods: int):
        """
        Initializes the indicator with the number of periods.
        """
        self.periods = periods
    def update(self, value):
        """
        Updates the indicator with a new value.
        """
        self.accum += value  # accumulate the new value
        if self.counter == self.periods:
            self.accum -= self.prev  # subtract the oldest value
        else:
            self.counter += 1  # there are not enough periods yet
        self.prev = value
    def level(self):
        """
        Returns the current value of the indicator.
        """
        if self.counter != self.periods:
            return math.nan
        return self.accum / self.periods

class TrendDirection:
    """
    Trend Direction indicator.
    """
    period: int
    prev_value: float = math.nan
    prev_delta: float = 0
    accum: float = 0.0
    counter: int = 0
    def __init__(self, period: int):
        self.period = period
    def update(self, value):
        if self.prev_value == math.nan:
            self.prev_value = value
            return
        diff = value - self.prev_value
        delta = 1 if diff > 0 else -1 if diff < 0 else 0
        self.accum += delta
        if self.counter == self.period:
            self.accum -= self.prev_delta
        else:
            self.counter += 1
        self.prev_value = value
        self.prev_delta = delta
        print(self.level())
    def level(self):
        if self.counter != self.period:
            return math.nan
        print(self.accum)
        return self.accum / (self.period)

def test_trend_direction():
    td = TrendDirection(3)
    td.update(1.0)
    td.update(2.0)
    td.update(3.0)
    td.update(4.0)
    td.update(5.0)
    td.update(2.0)
    td.update(1.0)
    print(td.level())

if __name__ == "__main__":
    test_trend_direction()