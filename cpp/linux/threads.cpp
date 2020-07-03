#include "header.h"
#include <thread>
#include <mutex>
#include <condition_variable>

volatile int flag = 0;
static std::mutex gMutex;
static std::condition_variable gCV;

void waitForCV()
{
    auto pred = []() { std::cout << "in pred function" << std::endl; return flag == 1; };

    std::unique_lock<std::mutex> locker(gMutex);
    gCV.wait(locker, pred);
    std::cout << "in waitForCV function" << std::endl;
}

void notifyCV()
{
    std::unique_lock<std::mutex> locker(gMutex);
    flag = 1;
    gCV.notify_all();
}

static TestRegister regist("threads", [](){
    std::thread([](){ waitForCV(); return 0;}).detach();

    std::cout << "wait thread to run" << std::endl;
    std::this_thread::sleep_for(std::chrono::seconds(3));
    notifyCV();

    std::this_thread::sleep_for(std::chrono::seconds(3));
    std::cout << "finished" << std::endl;
});

