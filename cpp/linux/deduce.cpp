#include "header.h"
#include <cxxabi.h>

TEST_BEGIN
    const int& data = 10;
    auto result = 0;

    std::cout << abi::__cxa_demangle(typeid(data).name(), 0, 0, &result) << std::endl;
TEST_END

