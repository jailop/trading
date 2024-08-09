#include <iostream>
#include <cstdlib>
#include <cstring>
extern "C" {
#include "requests.h"
}

using namespace std;

class AlphaAvantage {
    public:
        void time_series_daily(const char *symbol, bool compact_size = true) {
            string url = string(base_url_) + "function=TIME_SERIES_DAILY";
            url += "&symbol=" + string(symbol);
            url += "&outputsize=" + string(compact_size ? "compact" : "full");
            url += "&apikey=" + string(api_key_);
            cout << url << endl;
            char *s = requests_get(url.c_str());
            cout << s << endl;
            free(s);
        }
        const char *base_url_ = "https://www.alphavantage.co/query?";
        const char *api_key_ = "YOUR_API_KEY";
};

int main(int argc, char **argv) {
    AlphaAvantage aa;
    aa.time_series_daily(argv[1]);
}
