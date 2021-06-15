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
        do \
        { \
            MACRO \
            std::cout << MSG << std::endl; \
        }while(0); \
    }


#define COUT(MSG) std::cout<< "file: " << __FILE__ << ", line: " << __LINE__ << ", msg: " << MSG << std::endl

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

#define MICRO_CONFLICT(x, o) std::cout<<x<<o<<std::endl;

TEST_BEGIN
    TEST(BREAK_ON_ERROR(getResult(10)), "First: shall not be printed")
    TEST(CONTINUE_ON_ERROR(getResult(-10)), "Second: shall not be printed")
    TEST(BREAK_ON_ERROR(getResult(0)), "Third: shall be printed")
    MICRO_CONFLICT("hello world!", 10);

    COUT("hello world");

    COUT("hello world");
TEST_END

