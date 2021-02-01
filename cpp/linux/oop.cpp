#include "header.h"

class BaseClass
{
public:
    static void say(const char* msg) { std::cout << "in base " << msg << std::endl; }
};

class SubClass: public BaseClass
{
public:
    static void say(const char* msg) { std::cout << "in sub " << msg << std::endl; }
};

class AnotherSubClass: public BaseClass
{
};

enum class ETest {
    FAIL,
    OK,
    UNKNOWN
};

using Devices = std::map<std::string, ETest>;

TEST_BEGIN
    BaseClass::say("hello");
    SubClass::say("world");
    AnotherSubClass::say("good");
    Devices devices;
    std::cout << "default value for enum class:" << (int)devices["test"] << std::endl;
TEST_END

