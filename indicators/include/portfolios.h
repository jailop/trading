#ifndef _PORTFOLIO_H
#define _PORTFOLIO_H

#include <unordered_map>
#include <string>

enum Signal {
    Buy,
    Sell
};

struct Asset {
    double quantity = 0.0;
    double price = 0.0;
    time_t updated = 0;
};

class DummyPortfolio {
public:
    DummyPortfolio(double initial_value): m_value(initial_value) {};
    bool setSignal(std::string ticker, double price, Signal signal);
    void updateAssetPrice(std::string ticker, double price);
    double valuation();
    double cash() { return m_value; }
private:
    double m_value;
    std::unordered_map<std::string, struct Asset> m_assets;
};

#endif // _PORTFOLIO_H
