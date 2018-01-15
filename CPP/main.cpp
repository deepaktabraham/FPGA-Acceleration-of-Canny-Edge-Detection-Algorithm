// main.cpp
// Description: This file is the software portion of the
// Canny Edge Detection algorithm implemented on the FPGA

#include <iostream>
#include <cstdlib>
#include <cassert>
#include <cstring>
#include <cstdio>
#include<math.h>
#include<fstream>


#include "Board.h"
#include "Timer.h"


using namespace std;


// DONOT CHANGE WITHOUT ALSO CHANGING VHDL TO MATCH
#define ADDR_WIDTH 15
#define MAX_SIZE (1<<ADDR_WIDTH)
#define MEM_IN_ADDR 0
#define MEM_OUT_ADDR 0
#define GO_ADDR ((1<<MMAP_ADDR_WIDTH)-3)
#define SIZE_ADDR ((1<<MMAP_ADDR_WIDTH)-2)
#define DONE_ADDR ((1<<MMAP_ADDR_WIDTH)-1)


// function to read data from text file, for the FPGA implementation of canny edge detection algorithm
void HW_Read_Input_Data(unsigned dataInput[128*128])
{
        ifstream fin;
        fin.open("test.txt");
        for(int i=0; i<128*128; i++)
	{
                fin >> dataInput[i];
	}
        fin.close();
}


// function to convert data to words
void HW_Data_To_Words(unsigned dataInput[128*128], unsigned hwInput[4096])
{
        for (unsigned i=0, j=0; j<128*128; i++, j+=4)
	{
                // pack 4 8-bit words into one 32-bit words
                hwInput[i] = ((dataInput[j]) & 0xff) << 24 |
                        ((dataInput[j+1]) & 0xff) << 16 |
                        ((dataInput[j+2]) & 0xff) << 8 |
                        ((dataInput[j+3]) & 0xff);
        }
}


// function to convert words to data
void HW_Words_To_Data(unsigned hwOutput[3844], unsigned dataOutput[124*124])
{
	for (unsigned i=0, j=0; i<3844; i++, j+=4)
        {
                dataOutput[j] = (hwOutput[i] >> 24) & 0xff;
                dataOutput[j+1] = (hwOutput[i] >> 16) & 0xff;
                dataOutput[j+2] = (hwOutput[i] >> 8) & 0xff;
                dataOutput[j+3] = (hwOutput[i]) & 0xff;
        }

        ofstream fout;
        fout.open("hw_out.txt", ios::out | ios::trunc);
        for(unsigned i=0; i<124*124; i++)
        {
                fout << dataOutput[i]<<endl;
                cout<<dataOutput[i]<<endl;
        }
        fout.close();
}


// function to read data from text file, for the software implementation
// of Canny Edge Detection Algorithm
void SW_Read_Input_Data(int swInput[128][128])
{
        ifstream fin;
        fin.open("test.txt");
        for(int i=0; i<128; i++)
        {
                for(int j=0; j<128; j++)
                {
                        fin >> swInput[i][j];
                }
        }
        fin.close();
}


// software based canny edge detection algorithm
void SW_Canny(int swInput[128][128], int filterx[3][3], int filtery[3][3], int th1, int th2, int swOutput[124][124])
{
        int  gx[126][126], gy[126][126];
        for(int i=0; i<126; i++)
        {
                for(int j=0; j<126; j++)
                {
                        gx[i][j] = 0;
                        for(int k=0; k<3; k++)
                        {
                                for(int l=0; l<3; l++)
                                {
                                        gx[i][j] += swInput[i+k][j+l] * filterx[k][l];
                                        gy[i][j] += swInput[i+k][j+l] * filtery[k][l];
                                }
                        }
                }
        }

        float magnitude[126][126];
        for(int i=0; i<126; i++)
        {
                for(int j=0; j<126; j++)
                {
                        magnitude[i][j] = sqrt(gx[i][j] * gx[i][j] + gy[i][j] * gy[i][j]);
                }
        }

        for(int i=0; i<124; i++)
        {
                for(int j=0; j<124; j++)
                {
                        if(magnitude[i+1][j+1] > th1)
                        {
                                swOutput[i][j] = 255;
                                continue;
                        }
                        if(magnitude[i+1][j+1] < th2)
                        {
                                swOutput[i][j] = 0;
                                continue;
                        }
                        if(swInput[i][j] > th1 || swInput[i][j+1] > th1 ||
                                swInput[i][j+2] > th1 || swInput[i+1][j] > th1 ||
                                swInput[i+1][j+2] > th1 || swInput[i+2][j] > th1 ||
                                swInput[i+2][j+1] > th1 || swInput[i+2][j+2] > th1)
                        {
                                swOutput[i][j] = 255;
                        }
                        else
                        {
                                swOutput[i][j] = 0;
                        }
                }
        }


	// rearranging outputs
	int temp[124][124];
	for(int i=0; i<124; i++)
	{
		for(int j=0; j<124; j++)
		{
			temp[i][j] = swOutput[i][j];
		}
	}
	for(int i=0; i<124; i++)
	{
		for(int j=0; j<124; j++)
		{
			swOutput[i][j] = temp[j][i];
		}
	}
}


// function to write software based canny edge detected output to file
void SW_Write_Output_Data(int output[124][124])
{
        ofstream fout;
        fout.open("sw_out.txt", ios::out | ios::trunc);
        for(int i=0; i<124; i++)
                for(int j=0; j<124; j++)
                {
                        fout << output[i][j]<<endl;
                        //cout<<output[i][j]<<endl;
                }
        fout.close();
}


// check if hardware and software outputs match
void Check_HW_SW_Output(unsigned dataOutput[124*124], int swOutput[124][124])
{
	int k = 0;
	for(int i=0; i<124; i++)
	{
		for(int j=0; j<124; j++)
		{
			if(dataOutput[k++] != (unsigned)swOutput[i][j])
			{
				cout<<"Error: HW - SW output mismatch!"<<endl;
				return;
			}	
		}
	}	
	cout<<"HW - SW outputs match!"<<endl;
}


// main
int main(int argc, char* argv[])
{
        if (argc != 2)
        {
                cerr << "Usage: " << argv[0] << " bitfile" << endl;
                return -1;
        }

        // setup clock frequencies
        vector<float> clocks(Board::NUM_FPGA_CLOCKS);
        clocks[0] = 100.0;
        clocks[1] = 0.0;
        clocks[2] = 0.0;
        clocks[3] = 0.0;

        // initialize board
        Board *board;
        try
        {
                board = new Board(argv[1], clocks);
        }
        catch(...)
        {
                cout<<"Could not initialize clock frequencies... Exiting!"<<endl;
                exit(-1);
        }


        /*
         * hardware implementation
         */
        unsigned size = MAX_SIZE;
        unsigned go, done;
        unsigned dataInput[128*128], hwInput[4096], hwOutput[3844], dataOutput[124*124];
        Timer hwTime, readTime, writeTime, waitTime;

		// transfer words and size to FPGA
		HW_Read_Input_Data(dataInput);
		HW_Data_To_Words(dataInput, hwInput);
        hwTime.start();
        writeTime.start();
        board->write(hwInput, MEM_IN_ADDR, 4096);
        board->write(&size, SIZE_ADDR, 1);
        writeTime.stop();

        // assert go. Note that the memory map automatically sets go back to 1 to
        // avoid an additional transfer.
        go = 1;
        board->write(&go, GO_ADDR, 1);

        // wait for the board to assert done
        waitTime.start();
        done = 0;
        while (!done)
        {
                board->read(&done, DONE_ADDR, 1);
        }
        waitTime.stop();

        // read the outputs back from the FPGA
        readTime.start();
        board->read(hwOutput, MEM_OUT_ADDR, 3844);
        readTime.stop();
        hwTime.stop();
        HW_Words_To_Data(hwOutput, dataOutput);


		/*
		* software implementation
		*/
		int swInput[128][128];
		int filter1[3][3] = {{1,2,1},{0,0,0},{-1,-2,-1}};
        int filter2[3][3] = {{1,0,-1},{2,0,-2},{1,0,-1}};
        int swOutput[124][124];
        int th1=100, th2=30;
        Timer swTime;
 
		SW_Read_Input_Data(swInput);
		swTime.start();
        SW_Canny(swInput, filter1, filter2, th1, th2, swOutput);
        swTime.stop();
        SW_Write_Output_Data(swOutput);


        /*
         * check if hardware and software outputs match
		 * -- should not match due to use of approximate methods in hardware implementation
         */
        //Check_HW_SW_Output(dataOutput, swOutput);


        /*
         *  calculate speedup
         */
        double transferTime = writeTime.elapsedTime() + readTime.elapsedTime();
        double hwTimeNoTransfer = hwTime.elapsedTime() - transferTime;
        cout << "Speedup: " << swTime.elapsedTime()/hwTime.elapsedTime() << endl;
        cout << "Speedup (no transfers): " << swTime.elapsedTime()/hwTimeNoTransfer << endl;
}	
