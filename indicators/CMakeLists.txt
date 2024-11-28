cmake_minimum_required(VERSION 3.10)
project(IndicatorsProject)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED True)

include_directories(inclulude)

set(SOURCES
    src/indicators.cpp
)

set(HEADERS
    include/indicators.h
)

set(TEST_SOURCES
    test/indicators.test.cpp
)

include_directories(include)

include(FetchContent)
FetchContent_Declare(
    googletest
    URL https://github.com/google/googletest/releases/download/v1.15.2/googletest-1.15.2.tar.gz
)
FetchContent_MakeAvailable(googletest)

enable_testing()

add_library(indicators SHARED ${SOURCES} ${HEADERS})
add_executable(indicators_test ${TEST_SOURCES})

target_link_libraries(indicators_test indicators gtest_main)

include(GoogleTest)
gtest_discover_tests(indicators_test)
