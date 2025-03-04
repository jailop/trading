#ifndef _INDICATORS_H
#define _INDICATORS_H

#include <vector>
#include <utility>
#include <cmath>

class MA {
public:
    MA(size_t periods);
    double update(double value);
    double get() { return m_len < m_periods ? NAN : m_accum / m_periods; }
private:
    double m_accum = 0.0;
    size_t m_periods;
    size_t m_len = 0;
    size_t m_pos = 0;  // current m_prevs position
    std::vector<double> m_prevs; // n-periods array
};

class EMA {
public:
    EMA(size_t periods, double alpha = 2.0): m_periods(periods), m_alpha(alpha) {
        m_smooth = alpha / (1.0 + m_periods);
    }
    double update(double value);
    double get() { return m_len >= m_periods ? m_prev : NAN; }
private:
    size_t m_periods;
    double m_alpha;
    size_t m_len = 0;
    double m_prev = 0.0;
    double m_smooth;
};

class RSI {
public:
    RSI(size_t periods = 14): m_losses(periods), m_gains(periods) { }
    double update(double open, double close);
    double get();
private:
    MA m_losses;
    MA m_gains;
};

class MACD {
public:
    MACD(size_t short_period, size_t long_period, size_t avg_period, double alpha = 2.0):
        m_short(short_period, alpha), m_long(long_period, alpha), m_avg(avg_period, alpha), m_start(long_period) {};
    std::pair<double, double> update(double value);
    std::pair<double, double> get();
private:
    EMA m_short;
    EMA m_long;
    EMA m_avg;
    size_t m_start;
    size_t m_len = 0;
};

#endif // _INDICATORS_H
