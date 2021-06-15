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

typedef struct  __attribute__((packed)){
    char type;
    char id;
    int account;
    float balance;
    char mask;
}Account1;

typedef struct{
    char type;
    char id;
    int account;
    float balance;
    char mask;
}Account2;

typedef struct __attribute__((packed)) {
    char idx;
    Account1 account;
    char mask;
}IdxAccount1;

typedef struct __attribute__((packed)) {
    char idx;
    Account2 account;
    char mask;
}IdxAccount2;

TEST_BEGIN
    BaseClass::say("hello");
    SubClass::say("world");
    AnotherSubClass::say("good");
    Devices devices;
    std::cout << "default value for enum class:" << (int)devices["test"] << std::endl;
    std::cout << "Account1 Packed: " << sizeof(Account1) << std::endl;
    std::cout << "Account2 Unpacked: " << sizeof(Account2) << std::endl;
    std::cout << "IdxAccount1 with Packed Account1: " << sizeof(IdxAccount1) << std::endl;
    std::cout << "IdxAccount2 with Unpacked Account2: " << sizeof(IdxAccount2) << std::endl;
TEST_END

