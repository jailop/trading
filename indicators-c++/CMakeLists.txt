cmake_minimum_required(VERSION 3.10)
project(IndicatorsProject)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED True)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

include_directories(include)

set(SOURCES
    src/indicators.cpp
    src/portfolios.cpp
)

set(HEADERS
    include/indicators.h
    include/portfolios.h
)

set(TEST_SOURCES
    test/indicators.test.cpp
    test/portfolios.test.cpp
)

include_directories(include)

include(FetchContent)
FetchContent_Declare(
    googletest
    URL https://github.com/google/googletest/releases/download/v1.15.2/googletest-1.15.2.tar.gz
)
FetchContent_MakeAvailable(googletest)

enable_testing()

add_library(indicators ${SOURCES} ${HEADERS})
add_executable(indicators_test ${TEST_SOURCES})

target_link_libraries(indicators_test indicators gtest_main)

include(GoogleTest)
gtest_discover_tests(indicators_test)
