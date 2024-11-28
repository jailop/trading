"""
This module is intended to provide basic definitions, like order side.
"""

from enum import Enum

class OrderSide(Enum):
    BUY = 1
    SELL = 2
