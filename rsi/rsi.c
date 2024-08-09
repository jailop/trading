#include <stdio.h>
#include <math.h>

#define SIZE 10

int rsi(double open[], double close[], double result[], int n_items, int backsteps) {
    double gain[n_items], loss[n_items];
    for (int i = 0; i < n_items; i++) {
        double ptc = (close[i] - open[i]) / open[i];
        gain[i] = ptc >= 0 ? ptc : 0.0;
        loss[i] = ptc < 0 ? -ptc : 0.0;
    }
    for (int i = n_items - 1; i >= 0; i--) {
        if (i < backsteps - 1) {
            result[i] = NAN;
            continue;
        }
        double sum_gain = 0.0;
        double sum_loss = 0.0;
        for (int j = 0; j < backsteps; j++) {
            sum_gain += gain[i - j];
            sum_loss += loss[i - j];
        }
        double avg_gain = sum_gain / (double) backsteps;
        double avg_loss = sum_loss / (double) backsteps;
        result[i] = 100.0 - 100.0 / (1.0 + avg_gain / avg_loss);
    }
    return 0;
}

int sma(double input[], double result[], int n_items, int backsteps) {
    for (int i = n_items - 1; i >= 0; i--) {
        if (i < backsteps - 1) {
            result[i] = NAN;
            continue;
        }
        double sum = 0.0;
        for (int j = 0; j < backsteps; j++)
            sum += input[i - j];
        result[i] = sum / backsteps;
    }
    return 0;
}

int main() {
    double open[] = {23.21, 24.2, 23.9, 25.0, 23.75, 24.1, 23.6, 22.9, 24.5, 24.75};
    double close[] = {24.1, 23.6, 22.9, 24.5, 24.75, 23.21, 24.2, 23.9, 25.0, 23.75};
    double result[SIZE];
    rsi(open, close, result, SIZE, 5);
    for (int i = 0; i < SIZE; i++)
        printf("%f\n", result[i]);
    sma(close, result, SIZE, 5);
    for (int i = 0; i < SIZE; i++)
        printf("%f\n", result[i]);
    return 0;
}
