#include "header.h"
#include <vector>
#include <array>

using Values = std::vector<int>;

Values& getValues()
{
    static Values values = { 1, 2, 3, 4, 5, 9, 8, 7, 6 };
    return values;
}

static TestRegister regist("functions", [](){
    Values& values = getValues();

    printdatas(values, "value: ", "");
    printdatas(values, "\t ");
    values.data()[0] = 100;
    printdatas(values, "\t*");

    constexpr int size = 100;
    std::array<int, size> numbers;
    std::cout << numbers.size() << std::endl;
    std::cout << numbers.data() << std::endl;
});

