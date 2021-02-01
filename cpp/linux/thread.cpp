#include "header.h"
#include <thread>
#include <mutex>
#include <condition_variable>
#include <random>

volatile int flag = 0;
static std::mutex gMutex;
static std::condition_variable gCV;

static std::default_random_engine randomengine(time(NULL));
static std::uniform_int_distribution<int> range(0, 30);
static std::map<int, std::thread> threads;

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

TEST_BEGIN
    std::thread([](){ waitForCV(); return 0;}).detach();

    std::cout << "wait thread to run" << std::endl;
    std::this_thread::sleep_for(std::chrono::seconds(3));
    notifyCV();

    std::this_thread::sleep_for(std::chrono::seconds(3));
    std::cout << "finished" << std::endl;

    for (int i = 0 ; i < 10; ++i)
    {
        threads[i] = std::thread([idx=i](){ std::this_thread::sleep_for(std::chrono::seconds(range(randomengine))); std::cout << "in thread function:" << idx << std::endl; });
    }

    for_each(threads.begin(), threads.end(), [](std::map<int, std::thread>::reference item){ item.second.join(); });
TEST_END

