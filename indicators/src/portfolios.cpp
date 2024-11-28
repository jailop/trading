#include <time.h>
#include <portfolios.h>

bool DummyPortfolio::setSignal(std::string ticker, double price,
    Signal signal)
{
    if (signal == Signal::Buy && m_value > 0.0) {
        m_assets[ticker].quantity = m_value / price;
        m_assets[ticker].price = price;
        m_assets[ticker].updated = time(nullptr);
        m_value -= m_assets[ticker].quantity * price;
        return true;
    }
    if (signal == Signal::Sell && m_assets[ticker].quantity > 0.0) {
        m_value += m_assets[ticker].quantity * price;
        m_assets[ticker].quantity = 0;
        m_assets[ticker].price = price;
        m_assets[ticker].updated = time(nullptr);
        return true;
    }
    return false;
}

void DummyPortfolio::updateAssetPrice(std::string ticker, double price) {
    m_assets[ticker].price = price;
    m_assets[ticker].updated = time(nullptr);
}


double DummyPortfolio::valuation() {
    double value = m_value;
    for (const auto& n: m_assets) {
        value += n.second.price * n.second.quantity;
    }
    return value;
}
