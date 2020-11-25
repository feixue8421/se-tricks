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

TEST_BEGIN
    BaseClass::say("hello");
    SubClass::say("world");
    AnotherSubClass::say("good");
TEST_END

