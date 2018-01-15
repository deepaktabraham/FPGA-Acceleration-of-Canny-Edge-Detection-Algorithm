#include <sys/time.h>
#include <cstddef>

#include "Timer.h"

Timer::Timer() : startTime(0.0), stopTime(0.0) {

}

Timer::~Timer() {

}

double Timer::currentTime() const {

   timeval st;
   gettimeofday(&st,NULL);
   return st.tv_sec + st.tv_usec*1e-6;
}

void Timer::start() {

  startTime = currentTime();
}

void Timer::stop() {
  
  stopTime = currentTime();
}

double Timer::elapsedTime() const {

  return stopTime-startTime;
}
