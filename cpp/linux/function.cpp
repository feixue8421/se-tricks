#include "header.h"
#include <vector>
#include <array>
#include <map>
#include <sstream>

using Values = std::vector<int>;

Values& getValues()
{
    static Values values = { 1, 2, 3, 4, 5, 9, 8, 7, 6 };
    return values;
}

typedef std::map<unsigned char, unsigned char> PairedPons;
static PairedPons pairedpons;

void setpairedpons(unsigned char first, unsigned char second)
{
    pairedpons[first] = second;
    pairedpons[second] = first;
}

unsigned char getpairedpon(unsigned char pon)
{
    return pairedpons[pon];
}

const char* getpairedpons()
{
    std::stringstream result;
    for (PairedPons::iterator it = pairedpons.begin(); it != pairedpons.end(); ++it)
    {
        result << "     " << (int)it->first << "<----->" << (int)it->second << "\r\n";
    }
    return result.str().c_str();
}

class PairedPonInitializer
{
public:
    PairedPonInitializer() { setpairedpons(15, 13); }
};

static PairedPonInitializer pairedponinitializer;

TEST_BEGIN
    Values& values = getValues();

    printdatas(values, "value: ", "");
    printdatas(values, "\t ");
    values.data()[0] = 100;
    printdatas(values, "\t*");

    constexpr int size = 100;
    std::array<int, size> numbers;
    std::cout << numbers.size() << std::endl;
    std::cout << numbers.data() << std::endl;

    std::cout << "paired pons:" << std::endl;
    std::string result(getpairedpons());
    std::cout << getpairedpons();
    std::cout << "in a string:" << result;
TEST_END

