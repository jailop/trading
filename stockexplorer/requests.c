#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <curl/curl.h>
#include "requests.h"

struct growing_string {
    char *s;
    int len;
};

static size_t write_data(void *ptr, size_t size, size_t nmemb, void *content) {
    char *aux;
    int len = size * nmemb;
    int pos = 0;
    struct growing_string *gs = (struct growing_string *) content;
    if (size > 0) {
        if (gs->s) {
            pos = strlen(gs->s);
            aux = realloc(gs->s, pos + len + 1); 
            gs->s = aux;
        }
        else
            gs->s = malloc(len + 1);
        memcpy(gs->s + pos, ptr, len);
        gs->s[pos + len] = '\0';
    }
    return len;
}

char* requests_get(const char *url) {
    CURL *curl;
    CURLcode res;
    struct growing_string gs = {NULL, 0};
    curl_global_init(CURL_GLOBAL_DEFAULT);
    curl = curl_easy_init();
    if (curl) {
        curl_easy_setopt(curl, CURLOPT_URL, url);
        curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 1L);
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 1L);
        curl_easy_setopt(curl, CURLOPT_USERAGENT, "libcurl-agent/1.0");
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_data);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, (void*) &gs);
        res = curl_easy_perform(curl);
        if (res != CURLE_OK) {
            fprintf(stderr, "requests get failed: %s\n", 
                curl_easy_strerror(res));
        }
        curl_easy_cleanup(curl);
    }
    curl_global_cleanup();
    return gs.s;
}
