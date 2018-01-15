#ifndef _TIMER_H_
#define _TIMER_H_

class Timer 
{
 public:
  Timer();
  ~Timer();

  void start();
  void stop();
  double elapsedTime() const;  

 protected:
  double startTime;
  double stopTime;

  double currentTime() const;
};


#endif
