#include <cmath>
#include <iostream>
#include <indicators.h>

MA::MA(size_t periods): m_periods(periods) {
    m_prevs.resize(periods);
}

double MA::update(double value) {
    if (m_len < m_periods) {
        ++m_len;
    } else {
        m_accum -= m_prevs[m_pos];
    }
    m_prevs[m_pos] = value;
    m_accum += value;
    m_pos = (m_pos + 1) % m_periods;
    return get();
}

double MA::get() {
    if (m_len < m_periods) {
        return NAN;  
    }
    return m_accum / m_periods;
}

double EMA::update(double value) {
    ++m_len;
    if (m_len < m_periods) {
        m_prev += value;
    } else if (m_len == m_periods) {
        m_prev += value;
        m_prev /= 1.0 * m_periods;
    } else {
        m_prev = (value * m_smooth) + m_prev * (1 - m_smooth);    
    }
    return get();
}

double RSI::update(double open, double close) {
    double diff = close - open;
    m_losses.update(diff < 0.0 ? -diff : 0.0);
    m_gains.update(diff > 0.0 ? diff : 0.0);
    return get();
}

double RSI::get() {
    if (std::isnan(m_losses.get())) {
        return NAN;
    }
    return 100.0 - 100.0 / (1 + m_gains.get() / m_losses.get());
}

std::pair<double, double> MACD::update(double value) {
    ++m_len;
    m_short.update(value);
    m_long.update(value);
    if (m_len >= m_start)
        m_avg.update(m_short.get() - m_long.get());
    return get();
}


std::pair<double, double> MACD::get() {
    return m_len >= m_start 
        ? std::make_pair(m_short.get() - m_long.get(), m_avg.get())
        : std::make_pair((double) NAN, (double) NAN);
}
