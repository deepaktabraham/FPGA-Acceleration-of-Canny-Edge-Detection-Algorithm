#include <iostream>
#include <string>
#include <sstream>
#include <cassert>
#include <cstdio>
#include <cstring>
#include <cmath>
#include <stdlib.h>
#include <unistd.h>
#include <sys/mman.h>
#include <fcntl.h>

#include "Board.h"

using namespace std;

#define CLK_EXPORT_FILE "/sys/devices/soc0/amba/f8007000.devcfg/fclk_export"
#define CLK_BASE_PATH "/sys/devices/soc0/amba/f8007000.devcfg/fclk/"
#define CLK_SET_RATE_FILE "set_rate"
#define CLK_ENABLE_FILE "enable"
#define CLK_NAME "fclk"

/*
#define CLK0_PATH "/sys/devices/soc0/amba/f8007000.devcfg/fclk/fclk0/set_rate"
#define CLK0 "fclk0"
#define CLK1 "fclk1"
#define CLK2 "fclk2"
#define CLK3 "fclk3"
*/

Board::Board(const char *bitfile, const vector<float> &clocks) : PAGE_SIZE(sysconf(_SC_PAGESIZE)) {

  if (clocks.size() != NUM_FPGA_CLOCKS) {

    ostringstream errorMsg;
    errorMsg << "Error: clocks vector must have " << NUM_FPGA_CLOCKS << " frequencies.";
    handleError(errorMsg.str());
  }

  // make sure unsigned is 4 bytes on this machine
  assert(sizeof(unsigned) == 4);
  
  configureFpgaClocks(clocks);
  loadBitfile(bitfile);
  initializeMemoryMap();
}


Board::~Board() {

  delete mmapPages;
}

/*
void Board::setClockStatus(unsigned clk, bool enable) {

  FILE *outFile;
  char value = enable ? 1 : 0;
  outFile = fopen(name.c_str(), "w");
  if (outFile==NULL) {handleError("Error opening " + name);}
  fwrite(&value, sizeof(char), 1, outFile);
  fclose(outFile);
}
*/

void Board::writeToDriver(string file, string data) const {
  
  FILE *outFile = fopen(file.c_str(), "w");
  if (outFile==NULL) {handleError("Error opening " + file);}
  fwrite(data.c_str(), sizeof(char), data.size(), outFile);
  fclose(outFile);
}

string Board::readFromDriver(string file) const {

  FILE *inFile = fopen(file.c_str(), "rb" );
  if (inFile==NULL) {handleError("Error opening " + file);}
      
  unsigned long fileSize;
  fseek(inFile , 0 , SEEK_END);
  fileSize = ftell(inFile);
  rewind(inFile);

  char *buffer = (char*) new char[fileSize];
  unsigned long size = fread(buffer, sizeof(char), fileSize, inFile); 
  fclose(inFile);
  
  string returnVal;
  returnVal.assign(buffer, size);
  delete buffer;
  return returnVal;
}


void Board::configureFpgaClock(unsigned clockId, double freq) {
  
  ostringstream name;
  ostringstream path;
  ostringstream freqFile;
  ostringstream enableFile;
  ostringstream freqData;
  string enableData;

  name << CLK_NAME << clockId;
  path << CLK_BASE_PATH << name.str() << "/";
  freqFile << path.str() << CLK_SET_RATE_FILE;
  enableFile << path.str() << CLK_ENABLE_FILE;
  freqData << (int) (freq * 1000000);
  enableData = freq != 0.0 ? "1" : "0";

  //  printf("Configuring clock %d:\n", clockId);
  //printf("%s %s %s %s %s %s\n", name.str().c_str(), path.str().c_str(), freqFile.str().c_str(), enableFile.str().c_str(), freqData.str().c_str(), enableData.c_str());
  
  // expose the corresponding clock drivers to the file system
  writeToDriver(CLK_EXPORT_FILE, name.str());

  // enable/disable the corresponding clock
  writeToDriver(enableFile.str(), enableData);  

  // set the clock frequency
  if (freq != 0.0) {
    
    writeToDriver(freqFile.str(), freqData.str());
  }

  /*
  string debugFreq = readFromDriver(freqFile.str());
  string debugEnable = readFromDriver(enableFile.str());
  cout << "->" << debugFreq << "<-" << endl;
  cout << "->" << debugEnable << "<-" << endl;
  */
}


void Board::configureFpgaClocks(const vector<float> &clocks) {
  
  for (unsigned i=0; i < clocks.size(); i++) {

    configureFpgaClock(i, clocks[i]);
  }
}


void Board::copy(const char *to, const char *from) {

  FILE *inFile, *outFile;
  unsigned long lSize;
  char * buffer;
  size_t result;
  
  // open input file
  inFile = fopen(from, "rb" );
  if (inFile==NULL) {handleError("Error opening " + (string) from);}

  // obtain file size:
  fseek (inFile , 0 , SEEK_END);
  lSize = ftell (inFile);
  rewind (inFile);

  // allocate memory to contain the whole file:
  buffer = (char*) malloc (sizeof(char)*lSize);
  if (buffer == NULL) {fputs ("Memory error",stderr); exit (2);}

  // copy the file into the buffer:
  result = fread (buffer,1,lSize,inFile);
  if (result != lSize) {handleError("Error reading " + (string) from);}

  // open and write to output file
  outFile = fopen (to, "w" );
  if (outFile==NULL) {handleError("Error opening " + (string) to);}
  fwrite(buffer, sizeof(char), lSize, outFile);

  // terminate
  fclose(inFile);
  fclose(outFile);
  free(buffer);
}


void Board::loadBitfile(const char* bitfile) {

  copy("/dev/xdevcfg", bitfile);
}


void Board::initializeMemoryMap() {
  
  // Open /dev/mem file
  int fd = open("/dev/mem", O_RDWR);
  if (fd < 1) {
    handleError("Can't open /dev/mem");
  }

  //this->pageSize=sysconf(_SC_PAGESIZE);

  // calculate the number of pages required for the memory-map address space
  unsigned numPages = (MEM_INT_ADDR_SPACE * (MMAP_DATA_WIDTH/8)) / PAGE_SIZE;
  mmapPages = new unsigned*[numPages];

  // save a ptr to the start of each page.
  // This is necessary because the pages are unlikely to be adjacent 
  // in physical memory.
  for (unsigned i=0; i < numPages; i++) {

    unsigned startAddr = AXI_MMAP_ADDR+i*PAGE_SIZE;
    unsigned pageAddr = (startAddr & (~(PAGE_SIZE-1)));
    unsigned pageOffset = startAddr - pageAddr;

    void *ptr = mmap(NULL, PAGE_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, fd, pageAddr);
    mmapPages[i] = (unsigned *) ptr + pageOffset;
  }
}


inline void Board::handleError(std::string str) const {
	std::cerr << str << std::endl;
	throw 1;
}


inline bool Board::write(unsigned *data, unsigned long addr, unsigned long words) {

  // identify the starting page, the number of pages for the 
  // entire transfer, and the addr within the starting page
  unsigned page = addr*sizeof(unsigned) / PAGE_SIZE;
  unsigned pages = ceil(words*sizeof(unsigned) / (float) PAGE_SIZE);
  addr = addr % (PAGE_SIZE/4);

  // for each page, transfer the corresponding data
  for (unsigned i=0; i < pages; i++) {

    unsigned pageWords = words > PAGE_SIZE/4 ? PAGE_SIZE/4 - addr : words;
    memcpy(mmapPages[page]+addr, data+i*PAGE_SIZE/4, pageWords*sizeof(unsigned));
    addr = 0;
    words -= pageWords;
    page ++;
  }

  return true;
}


inline bool Board::read(unsigned *data, unsigned long addr, unsigned long words) {

// identify the starting page, the number of pages for the 
  // entire transfer, and the addr within the starting page
  unsigned page = addr*sizeof(unsigned) / PAGE_SIZE;
  unsigned pages = ceil(words*sizeof(unsigned) / (float) PAGE_SIZE);
  addr = addr % (PAGE_SIZE/4);

  // for each page, transfer the corresponding data
  for (unsigned i=0; i < pages; i++) {

    unsigned pageWords = words > PAGE_SIZE/4 ? PAGE_SIZE/4 - addr : words;
    memcpy(data+i*PAGE_SIZE/4, mmapPages[page]+addr, pageWords*sizeof(unsigned));
    addr = 0;
    words -= pageWords;
    page ++;
  }

  return true;
}
