#CC = g++
CC = arm-linux-g++
CFLAGS = -O3 -Wall -ansi -g

OBJS = main.o Board.o Timer.o

#set up C suffixes & relationship between .cpp and .o files
.SUFFIXES: .cpp

.cpp.o:
	$(CC) $(CFLAGS) -c $<


fabric: $(OBJS)
	${CC} -o zed_app $(OBJS)

main.o : Board.h Timer.h
Board.o : Board.h
Timer.o : Timer.h

clean:
	rm -f *.o *~ zed_app

# DO NOT DELETE
