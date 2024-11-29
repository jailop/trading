#include <iostream>
#include <chrono>
#include <vector>
#include "indicators.h"

double mean(size_t start, size_t size, double *data) {
    double accum = 0.0;
    for (size_t i = start; i < start + size; ++i) {
        accum += data[i];
    }
    return accum / size;
}

double static_ma(size_t size, size_t periods) {
    std::vector<double> ts(size, 1.0);;
    auto start = std::chrono::high_resolution_clock::now();
    for (size_t i = 0; i < ts.size(); ++i) {
        if (i < periods) continue;
        mean(i, periods, ts.data());
    }
    auto end = std::chrono::high_resolution_clock::now();
    return std::chrono::duration_cast<std::chrono::nanoseconds>(end-start).count();
}

double streaming_ma(size_t size, size_t periods) {
    std::vector<double> ts(size, 1.0);;
    MA ma(periods);
    auto start = std::chrono::high_resolution_clock::now();
    for (size_t i = 0; i < ts.size(); ++i) {
        ma.update(ts[i]);
    }

    auto end = std::chrono::high_resolution_clock::now();
    return std::chrono::duration_cast<std::chrono::nanoseconds>(end-start).count();
}

void compare(size_t size, size_t periods) {
    std::cout << size << "," << periods << "," 
        << static_ma(size, periods) / 1e3 << ","
        << streaming_ma(size, periods) / 1e3 << std::endl;
}

int main() {
    compare(1000, 100);
    compare(10000, 1000);
}
