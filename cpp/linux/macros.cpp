#include "header.h"

#define _CALL_FUNC(FUNC, CTRL) \
    if (auto result = FUNC) \
    { \
        std::cout << #FUNC " Failed: " << result << std::endl; \
        std::cout << "CTRL " #CTRL << std::endl; \
        CTRL; \
    }

#define BREAK_ON_ERROR(FUNC) _CALL_FUNC(FUNC, break)
#define CONTINUE_ON_ERROR(FUNC) _CALL_FUNC(FUNC, continue)

#define TEST(MACRO, MSG) \
    { \
        int max = 5; \
        do \
        { \
            MACRO \
            std::cout << MSG << std::endl; \
        }while(max--); \
    }

static int getResult(int data)
{
    if (data > 0)
    {
        return 1;
    }
    else if (data < 0)
    {
        return -1;
    }
    else
    {
        return 0;
    }
}

static TestRegister regist("macros", [](){
    TEST(BREAK_ON_ERROR(getResult(10)), "First: shall not be printed")
    TEST(CONTINUE_ON_ERROR(getResult(-10)), "Second: shall not be printed")
    TEST(BREAK_ON_ERROR(getResult(0)), "Third: shall be printed")
});

