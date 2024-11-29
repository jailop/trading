#include <string>
#include <gtest/gtest.h>
#include <portfolios.h>

TEST(Portfolio, DummyPortfolio) {
    std::string ticker("BTC-USD");
    DummyPortfolio pf(1000.0);
    ASSERT_NEAR(pf.valuation(), 1000.0, 1e-6);
    ASSERT_TRUE(pf.setSignal(ticker, 100, Signal::Buy));
    ASSERT_NEAR(pf.valuation(), 1000.0, 1e-6);
    ASSERT_NEAR(pf.cash(), 0.0, 1e-6);
    ASSERT_FALSE(pf.setSignal(ticker, 100, Signal::Buy));
    ASSERT_TRUE(pf.setSignal(ticker, 110, Signal::Sell));
    ASSERT_NEAR(pf.valuation(), 1100.0, 1e-6);
    ASSERT_FALSE(pf.setSignal(ticker, 110, Signal::Sell));
}
