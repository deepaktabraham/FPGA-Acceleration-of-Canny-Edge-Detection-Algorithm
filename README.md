# FPGA Acceleration of Canny Edge Detection Algorithm

Canny Edge Detection Algorithm is a multi-stage algorithm to detect wide range of edges in images. It can be broken down in to the following steps:
* Apply Gaussian filter to smooth the image in order to remove the noise
* Find the intensity gradients of the image
* Apply non-maximum suppression to get rid of spurious response to edge detection
* Apply double threshold to determine potential edges
* Track edge by hysteresis: Finalize the detection of edges by suppressing all the other edges that are weak and not connected to strong edges. 


### Directory Structure
VHDL code for hardware implementation of algorithm is in the **VHDL** directory.
CPP code for software implementation of algorithm is in the **CPP** directory.
MATLAB scripts to convert image to text and vice versa is in the **MATLAB** directory.
