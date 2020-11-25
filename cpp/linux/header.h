#ifndef __TASTE_HEADER__
#define __TASTE_HEADER__

#include <string>
#include <functional>
#include <map>
#include <iostream>
#include <algorithm>

class TestRegister
{
public:
    using Tests = std::map<std::string, std::function<void(void)>>;
    using Test = const Tests::key_type&;
    using Function = Tests::mapped_type;

    TestRegister(Test test, Function func)
    {
        TestRegister::getTests()[test] = func;
    }

    static Tests& getTests() { static Tests tests; return tests; }
    static void run(Test test)
    {
        auto& tests = TestRegister::getTests();
        auto it = tests.find(test);
        if (it != tests.end())
        {
            it->second();
        }
        else
        {
            std::for_each(tests.begin(), tests.end(), [](const typename Tests::value_type& test) {
                    std::cout << "***********" << test.first << "***********" << std::endl;
                    test.second();
                    std::cout << "***********" << test.first << "***********" << std::endl;
                    });
        }
    }
};

#define TEST_BEGIN static TestRegister regist(__FILE__, [](){
#define TEST_END });
#define TEST_RUN(X) TestRegister::run(#X ".cpp")

template<class Datas>
void printdatas(Datas& datas, const std::string& prefix, const std::string& postfix)
{
    bool more = false;
    std::for_each(datas.begin(), datas.end(), [&](const typename Datas::value_type& value) {
                if (more)
                {
                    std::cout << postfix;
                    if (postfix.empty())
                    {
                        std::cout << std::endl;
                    }
                }
                std::cout << prefix << value;
                more = true;
            });

    std::cout << std::endl;
}

template<class Datas>
void printdatas(Datas& datas)
{
    printdatas(datas, "", "");
}

template<class Datas>
void printdatas(Datas& datas, const std::string& postfix)
{
    printdatas(datas, "", postfix);
}


#endif

